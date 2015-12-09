//
//  CreateLayer.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/20.
//
//

#include "CreateLayer.h"
#include "Constants.h"
#include "GameManager.h"
#include "SimpleAudioEngine.h"
#include "native.h"
#include "HueSprite.h"
#include "ui/CocosGUI.h"
#include "WelcomeLayer.h"
#include "FadeParticleSystem.h"
#include "Utils.h"
#include "LightSprite.h"
#include "GB2ShapeCacheX.h"

using namespace cocos2d::ui;
//using namespace cocos2d::experimental;

Scene* CreateLayer::scene()
{
    auto scene = Scene::createWithPhysics();
    
    auto layer = CreateLayer::create();
    layer->setTag(CREATE_LAYER_TAG);
    scene->addChild(layer);
    
    return scene;
}

bool CreateLayer::init()
{
    if ( !BaseLayer::init() )
    {
        return false;
    }
    
    GB2ShapeCache::getInstance()->addShapesWithFile("common/starShape.plist");
    
    SpriteFrameCache::getInstance()->removeUnusedSpriteFrames();
    Director::getInstance()->getTextureCache()->removeUnusedTextures();
    
//    Texture2D::setDefaultAlphaPixelFormat(Texture2D::PixelFormat::RGBA8888);
    
    scaleAdjust = 1.0;
    
    if (screenRatio < 1.5) {
        scaleAdjust = 1.35;
    } else if (screenSize.width == 960) {
        scaleAdjust = 1.1;
    } else if (screenSize.width <= 1334) {
        scaleAdjust = 1.05;
    }
    
    m_cornerYC = 0.0;
    m_dropzoneYC = 0.0;
    if (screenRatio > 1.5) {
        // wide screen
        m_cornerYC = 40.0;
    } else if (screenRatio == 1.5) {
        m_cornerYC = 30;
        m_dropzoneYC = 30;
    } else {
        //iPad
        m_dropzoneYC = 66;
    }
    
    m_yAdj = 0.0;
    
    
    
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
//    gm->m_currentActors[gm->m_currentActorIndex].isSequenceReady = false;

    NativeHelper::getInstance()->logFlurryEvent("Time on " + gm->m_currentActors[gm->m_currentActorIndex].name + " Create Screen", true);

    CocosDenshion::SimpleAudioEngine::getInstance()->preloadBackgroundMusic("sound/common/beat_loop.mp3");
    CocosDenshion::SimpleAudioEngine::getInstance()->preloadEffect("sound/common/TileTap1.mp3");
    CocosDenshion::SimpleAudioEngine::getInstance()->preloadEffect("sound/common/SimpleShimmer.mp3");
    CocosDenshion::SimpleAudioEngine::getInstance()->preloadEffect("sound/common/Sparkle_01_Subtle.mp3");
    
    m_world = new b2World(b2Vec2(0, 0));
    
//    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
//    m_world->SetDebugDraw(m_debugDraw);
//    uint32  flags  =  0 ;
//    flags +=  b2Draw::e_shapeBit ;
//    flags += b2Draw::e_jointBit;
//    flags += b2Draw::e_aabbBit;
//    flags += b2Draw::e_pairBit;
//    flags += b2Draw::e_centerOfMassBit;
//    m_debugDraw->SetFlags (flags);

    m_reactionReady = false;
    m_lastLightId = -1;
    m_reactionPreloadedCount = 0;
    
    m_menu = Menu::create();
    m_menu->setPosition(Point::ZERO);
    addChild(m_menu, 50);
    
    m_actor = JsonSprite::create("config/create/" + gm->m_currentActors[gm->m_currentActorIndex].name + ".json");
    
    Point p = Point(origin.x + visibleSize.width / 2 + (gm->m_currentActorIndex - 1) * EGG_LANDING_OFFX,
                    origin.y + EGG_LANDING_Y + m_actor->m_feetOffset * ACTOR_SCALE) + scene.offsets[gm->m_currentActorIndex];
    
    m_actor->setPosition(p);
    m_actor->setTag(ACTOR_TAG_BASE);
    m_actor->setScale(actorScale);
    m_hue = gm->m_currentActors[gm->m_currentActorIndex].hue;
    
    m_actor->setHue(m_hue);
    
    addChild(m_actor, STAGE_ACTOR_LAYER);
    
    m_actor->playAction("idle0");
    
    //    auto bg = LayerColor::create(m_actor->m_backgroundColor, visibleSize.width, visibleSize.height);
    auto bg = LayerColor::create(Color4B(255, 255, 255, 255), visibleSize.width, visibleSize.height);
    bg->setPosition(origin);
    addChild(bg, 0);
    
    setupPhysics();
    
    setupCentralCircle();
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.createBeats.c_str(), true);
    
    scheduleUpdate();
    
    auto touchListener = EventListenerTouchOneByOne::create();
    touchListener->setSwallowTouches(true);
    
    touchListener->onTouchBegan = CC_CALLBACK_2(CreateLayer::onTouchBegan, this);
    touchListener->onTouchMoved = CC_CALLBACK_2(CreateLayer::onTouchMoved, this);
    touchListener->onTouchEnded = CC_CALLBACK_2(CreateLayer::onTouchEnded, this);
    touchListener->onTouchCancelled = CC_CALLBACK_2(CreateLayer::onTouchCancelled, this);
    
    _eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener, this);

//    startColorChangeShow();
    
    return true;
}

CreateLayer::~CreateLayer()
{
    m_centralCircleBody = NULL;
    for(int i = 0; i < 4; i++) {
        m_dropzoneBodies[i] = NULL;
    }
    
    delete m_world;
//    delete m_debugDraw;
}

void CreateLayer::onEnterTransitionDidFinish()
{
    m_actor->m_delegate = this;
    
    std::vector<std::string> actions;
    actions.push_back("idle");
    m_actor->preloadActions(actions);

    std::string backButtonFile = "tiles/" + m_actor->m_name + "/back.png";
    
//    auto backButton = MenuItemImage::create(backButtonFile, backButtonFile, CC_CALLBACK_1(CreateLayer::prepareToGoBack, this));
    auto backButton = Button::create(backButtonFile);
    backButton->addClickEventListener(CC_CALLBACK_1(CreateLayer::prepareToGoBack, this));
    backButton->setPosition(Point(origin.x + backButton->getContentSize().width / 2 + 98 - m_cornerYC, origin.y + visibleSize.height - backButton->getContentSize().height / 2 - 100 + m_cornerYC));
    backButton->setTag(BACK_BUTTON_TAG);
//    backButton->setScale(0.0);
//    m_menu->addChild(backButton);
    addChild(backButton, 50);
    
//    float baseScale = 1.0;
//    backButton->runAction(Sequence::create(
//                                           ScaleTo::create(0.1, baseScale * 1.3),
//                                           CallFunc::create(std::bind(&CreateLayer::backButtonBlowing, this)),
//                                           NULL));
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(backButton->getPosition().x/PTM_RATIO, backButton->getPosition().y/PTM_RATIO);
    m_backButtonBody = m_world->CreateBody(&bodyDef);
    m_backButtonBody->SetUserData(backButton);
    
    b2CircleShape circleBox;
    circleBox.m_radius = BUTTON_BODY_RADIUS / PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.95f;
    fixtureDef.filter.categoryBits = FixtureButton;
    fixtureDef.filter.maskBits = FixtureTile;
    m_backButtonBody->CreateFixture(&fixtureDef);
    m_backButtonBody->SetFixedRotation(true);
}

void CreateLayer::actionPreloaded(std::string actionName)
{
    CCLOG("Action %s preloaded", actionName.c_str());

    if (actionName == "idle") {
        switch (GameManager::getInstance()->m_currentActors[GameManager::getInstance()->m_currentActorIndex].pos) {
            case 0:
                m_enterAction = "moveRight";
                break;
            case 1:
                m_enterAction = "moveForward";
                break;
            default:
                m_enterAction = "moveLeft";
        }

        std::vector<std::string> actions;
        actions.push_back(m_enterAction);
        m_actor->preloadActions(actions);
    } else if (actionName == m_enterAction) {
        m_actor->playAction(m_enterAction);
        
        if (screenRatio < 1.5) {
            m_yAdj = -18.0;
        } else if (screenSize.width == 1.5) {
            m_yAdj = -10.0;
        } else {
            m_yAdj = 10.0;
        }
        
        if (screenRatio > 1.5) {
            if (m_actor->m_name == "Freds") {
                actorDanceScale *= 0.85;
                m_yAdj = -50.0;
            } else if (m_actor->m_name == "LeBlob") {
                actorDanceScale *= 0.95;
            } else if (m_actor->m_name == "Sausalito") {
            }
        } else if (screenRatio == 1.5) {
            if (m_actor->m_name == "Freds") {
                actorDanceScale *= 0.9;
                m_yAdj = -30.0;
            }
        }
        
        m_actor->runAction(Sequence::create(
                                            Spawn::create(
                                                          ScaleTo::create(ACTOR_ENTER_TIME, actorDanceScale),
                                                          MoveTo::create(ACTOR_ENTER_TIME, Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 + 220 + m_yAdj + m_actor->m_feetOffset * ACTOR_DANCE_SCALE)),
                                                          NULL),
                                            CallFunc::create(std::bind(&CreateLayer::startIdle, this)),
                                            NULL));
        
    } else if (Utils::startsWith(actionName, "reaction")) {
        if (++m_reactionPreloadedCount == 3) {
            m_reactionReady = true;
        }
    } else if (Utils::startsWith(actionName, "dance")) {
        addActionTile(actionName);
//        m_dancePreloadedCount++;
    }
    
}

void CreateLayer::actionStopped(JsonSprite *sprite)
{
    if (m_isGoingBack) return;
    
    if (m_isPlaying) {
//        playNextDance(0);
    } else if (sprite->m_currentActionName != "idle0") {
        sprite->playAction("idle");
    }
}

void CreateLayer::startIdle()
{
    m_actor->playAction("idle");
    
    runAction(Sequence::create(CallFunc::create(std::bind(&CreateLayer::setupDropzones, this)),
                               DelayTime::create(0.5),
//                               CallFunc::create(std::bind(&CreateLayer::setupTiles, this)),
                               NULL));
    m_dancePreloadedCount = 0;
    std::vector<std::string> actions;
    actions.push_back("dance1");
    actions.push_back("dance2");
    actions.push_back("dance3");
    actions.push_back("dance4");
    actions.push_back("dance5");
    actions.push_back("dance6");
    actions.push_back("dance7");
    actions.push_back("dance8");
    actions.push_back("reaction1");
    actions.push_back("reaction2");
    actions.push_back("reaction3");
    m_actor->preloadActions(actions);
    
    Director::getInstance()->getTextureCache()->addImageAsync("lights/laser.png", CC_CALLBACK_1(CreateLayer::imageLoaded, this));
    Director::getInstance()->getTextureCache()->addImageAsync("lights/light.png", CC_CALLBACK_1(CreateLayer::imageLoaded, this));

}

//void CreateLayer::draw(Renderer *renderer, const Mat4& transform, uint32_t flags)
//{
//    Layer::draw(renderer, transform, flags);
//    Director* director = Director::getInstance();
//    GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POSITION );
//    director->pushMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
//    m_world->DrawDebugData();
//    director->popMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
//}

void CreateLayer::update(float delta)
{
    m_world->Step(delta, 8, 3);
    
    if (m_colorChanging) {
        
        auto *bgOverLay = (LayerColor *)getChildByTag(BG_OVERLAY_TAG);
        if (!bgOverLay) {
            startColorChangeShow();
        }
        
        m_hue += delta / 8.0;
        m_lightHue += delta / 4.0;
        if (m_hue > 1.0) {
            endColorChangeShow();
        }
        
        LightSprite *light = (LightSprite *)getChildByTag(LIGHT_TAG);
        if (light) {
            float s = m_hue > 0.1 ? 0.5 : m_hue * 5;
            light->setHueAndSaturate(m_lightHue, s);
        }
        
        m_actor->setHue(m_hue);
    }
    
    for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL && b->GetType() == b2_dynamicBody) {
            Sprite *sprite = (Sprite *)b->GetUserData();
            TileSprite *tile = dynamic_cast<TileSprite *>(sprite);
            
            if (tile) {
                if (tile->m_mode == TileModeReenter) {
                    if (!tileInCollisions(tile)) {
                        tile->removeReenterMode();
                        removeDuplicatedTile(tile);
                        CCLOG("Tile reenter complete!");
                    }
                }
                
                b2Vec2 v = b->GetLinearVelocity();
                
                bool speedChanged = false;
                if (tile->m_mode != TileModeReenter) {
                if (fabs(v.x) < 1.0) {
                    v.x = v.x < 0 ? -1.0 : 1.0;
                    speedChanged = true;
                }
                }
                if (fabs(v.y) < 1.0) {
                    v.y = v.y < 0 ? -1.0 : 1.0;
                    speedChanged = true;
                }
                if (speedChanged) {
                    b->SetLinearVelocity(v);
                }
            }
            
            sprite->setPosition(Point(b->GetPosition().x * PTM_RATIO,
                                      b->GetPosition().y * PTM_RATIO));
            sprite->setRotation(-1 * CC_RADIANS_TO_DEGREES(b->GetAngle()));
        }
    }
}

void CreateLayer::setupPhysics() {
    
    // Create edges around the entire screen
    
    b2Body *groundBody;
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    groundBody = m_world->CreateBody(&groundBodyDef);
    
    b2EdgeShape groundBox;
    b2FixtureDef groundBoxDef;
    groundBoxDef.shape = &groundBox;
    groundBoxDef.density = 1.0;
    groundBoxDef.filter.categoryBits = FixtureBorder;
    groundBoxDef.filter.maskBits = FixtureTile;
//    groundBoxDef.friction = 0.1;
    
    // bottom
    groundBox.Set(b2Vec2((origin.x - WALL_OFFSET_X) / PTM_RATIO, (origin.y - WALL_OFFSET_Y) / PTM_RATIO),
                  b2Vec2((origin.x + visibleSize.width + WALL_OFFSET_X) / PTM_RATIO, (origin.y - WALL_OFFSET_Y) / PTM_RATIO));
    groundBody->CreateFixture(&groundBoxDef);
    
    // left
    groundBox.Set(b2Vec2((origin.x - WALL_OFFSET_X) / PTM_RATIO, (origin.y - WALL_OFFSET_Y) / PTM_RATIO),
                  b2Vec2((origin.x - WALL_OFFSET_X) / PTM_RATIO, (origin.y + visibleSize.height + WALL_OFFSET_Y) / PTM_RATIO));
    groundBody->CreateFixture(&groundBoxDef);
    
    // top
    groundBox.Set(b2Vec2((origin.x - WALL_OFFSET_X) / PTM_RATIO, (origin.y + visibleSize.height + WALL_OFFSET_Y) / PTM_RATIO),
                  b2Vec2((origin.x + visibleSize.width + WALL_OFFSET_X) / PTM_RATIO, (origin.y + visibleSize.height + WALL_OFFSET_Y) / PTM_RATIO));
    groundBody->CreateFixture(&groundBoxDef);
    
    // right
    groundBox.Set(b2Vec2((origin.x + visibleSize.width + WALL_OFFSET_X) / PTM_RATIO, (origin.y + visibleSize.height + WALL_OFFSET_Y) / PTM_RATIO),
                  b2Vec2((origin.x + visibleSize.width + WALL_OFFSET_X) / PTM_RATIO, (origin.y - WALL_OFFSET_Y) / PTM_RATIO));
    groundBody->CreateFixture(&groundBoxDef);
}

void CreateLayer::setupCentralCircle()
{    
    m_circle = Sprite::create("tiles/" + m_actor->m_name + "/bgCircle.png");
    m_circle->setPosition(Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 + 145));
    m_circle->setTag(BG_TAG);
    m_circle->setScale(scaleAdjust);
    
    auto noise = Sprite::create("images/bg/noise2.png");
    noise->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2);
    noise->setScale(2.0);
    noise->setTag(NOISE_TAG);
    addChild(noise, BACKGROUND_LAYER + 2);
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(m_circle->getPosition().x/PTM_RATIO, m_circle->getPosition().y/PTM_RATIO);
    m_centralCircleBody = m_world->CreateBody(&bodyDef);
    
    b2CircleShape circleBox;
    circleBox.m_radius = (CENTER_CIRCLE_RADIUS * scaleAdjust - 3.0) / PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.8f;
    fixtureDef.filter.categoryBits = FixtureCentralCircle;
    fixtureDef.filter.maskBits = FixtureTile;
    
    m_centralCircleBody->CreateFixture(&fixtureDef);
    m_centralCircleBody->SetFixedRotation(true);
    
    addChild(m_circle, BACKGROUND_LAYER + 1);
}

bool CreateLayer::tileInCollisions(TileSprite *tile)
{
    if (tile->getPosition().distance(m_circle->getPosition()) < CENTER_CIRCLE_RADIUS * scaleAdjust + tile->getContentSize().width / 2)
    {
        return true;
    }
    
    for(int i = 0; i < 4; i++)
    {
        if (m_dropzoneBodies[i]) {
            DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
            if (tile->getPosition().distance(zone->getPosition()) < zone->getContentSize().width / 2 + tile->getContentSize().width / 2) {
                return true;
            }
        }
    }
    
    return false;
}

void CreateLayer::setupDropzones()
{
    if (m_isGoingBack) return;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    
    b2CircleShape circleBox;
    b2FixtureDef fixtureDef;
    
    //    char filename[100];
    
    float dropzoneTotalWidth = DROPZONE_TOTAL_WIDTH;
    if (screenSize.width == 960) {
        dropzoneTotalWidth += 120;
    }
    
    for(int i = 0; i < 4; i++) {
        //        sprintf(filename, "dropzone/dropzone%d.png", i + 1);
        auto dropzone = DropzoneSprite::create("common/dropzone.png");

        dropzone->setPosition(Point(origin.x + visibleSize.width / 2, origin.y)
                              + Point(-dropzoneTotalWidth / 2 + dropzoneTotalWidth / 3 * i, DROPZONE_Y + m_dropzoneYC));
        dropzone->m_index = i;
        dropzone->m_tileColor = C4B2C4F(m_actor->m_tileColor);
        dropzone->setScale(0);
        
        addChild(dropzone, DROPZONE_LAYER);
        
        float dropzoneScale = DROPZONE_DEFAULT_SCALE;
        
        if (screenSize.width == 960) {
            dropzoneScale *= scaleAdjust;
        }
        
        dropzone->runAction(ScaleTo::create(1.0, dropzoneScale));
        
        minTileGenY = dropzone->getPosition().y + dropzone->getContentSize().height / 2;
        
        bodyDef.position.Set(dropzone->getPosition().x/PTM_RATIO, dropzone->getPosition().y/PTM_RATIO);
        m_dropzoneBodies[i] = m_world->CreateBody(&bodyDef);
        m_dropzoneBodies[i]->SetUserData(dropzone);
        
        circleBox.m_radius = (dropzone->getContentSize().width / 2 * dropzoneScale - 5.0) / PTM_RATIO;
        
        fixtureDef.shape = &circleBox;
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.2f;
        fixtureDef.restitution = 0.8f;
        fixtureDef.filter.categoryBits = FixtureDropzone;
        fixtureDef.filter.maskBits = FixtureTile;
        m_dropzoneBodies[i]->CreateFixture(&fixtureDef);
        m_dropzoneBodies[i]->SetFixedRotation(true);
    }
    
//    auto underLayer = LayerColor::create(Color4B(255, 255, 0, 100), dropzoneTotalWidth, DROPZONE_Y + m_dropzoneYC);
//    underLayer->setPosition(origin.x + visibleSize.width / 2 - dropzoneTotalWidth / 2, origin.y);
//    addChild(underLayer);
//    
//    b2Body *underBoxBody;
//    
//    b2BodyDef underBoxBodyDef;
//    
//    underBoxBodyDef.type = b2_staticBody;
//    underBoxBodyDef.position.Set((origin.x + visibleSize.width / 2)/PTM_RATIO,
//                                 (origin.y)/PTM_RATIO);
//    
//    underBoxBody = m_world->CreateBody(&underBoxBodyDef);
//    
//    b2PolygonShape underBox;
//    underBox.SetAsBox((dropzoneTotalWidth / 2) / PTM_RATIO, ((DROPZONE_Y + m_dropzoneYC) * 1.5) / PTM_RATIO);
//    
//    b2FixtureDef underBoxfixtureDef;
//    underBoxfixtureDef.shape = &underBox;
//    underBoxfixtureDef.density = 1.0f;
//    underBoxfixtureDef.friction = 0.2f;
//    underBoxfixtureDef.restitution = 0.8f;
//    underBoxfixtureDef.filter.categoryBits = FixtureTile;
//    underBoxfixtureDef.filter.maskBits = FixtureTile;
//    
//    underBoxBody->CreateFixture(&underBoxfixtureDef);
//    underBoxBody->SetFixedRotation(true);
    
}

void CreateLayer::setupTiles()
{
    int i = 0;
    for(std::unordered_map<std::string, ActionData>::iterator iter = m_actor->m_actions.begin(); iter != m_actor->m_actions.end(); ++iter)
    {
        std::string actionName = iter->first;
        ActionData ad = iter->second;
        if (ad.type == 1) {
            runAction(Sequence::create(
                                       DelayTime::create(i * 0.3),
                                       CallFuncN::create(std::bind(&CreateLayer::addActionTile, this, ad.actionName)),
                                       NULL));
            i++;
        }
    }
    
}

void CreateLayer::scheduleNextColorChangeTile()
{
    scheduleOnce(CC_SCHEDULE_SELECTOR(CreateLayer::addColorChangeTile), 10.0);
}

void CreateLayer::addColorChangeTile(float dt)
{
    if (m_isPlaying && !m_colorChanged) {
        int lightId = rand() % 3;
        while (lightId == m_lastLightId) {
            lightId = rand() % 3;
        }
        m_lastLightId = lightId;
//        m_lastLightId = 2;
        addTile("changeColor", TileTypeColorChange);
    }
    //    scheduleNextColorChangeTile();
}

void CreateLayer::addActionTile(std::string actionName)
{
    addTile(actionName, TileTypeNormal);
}

void CreateLayer::addTile(std::string actionName, TileType type)
{
    if (m_isGoingBack) return;
    
    if (dropzoneIsFull() && type != TileTypeColorChange) return;
    
    if (type == TileTypeColorChange && getChildByTag(COLOR_CHANGE_TILE_TAG)) {
        return;
    } else {
        for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                Sprite *sprite = (Sprite *)b->GetUserData();
                if (b->GetType() == b2_dynamicBody) {
                    TileSprite *tile = dynamic_cast<TileSprite *>(sprite);
                    if (tile && tile->m_actionName == actionName && tile->m_mode != TileModeLeaving) {
                        CCLOG("Duplicated tile");
                        return;
                    }
                }
            }
        }
    }
    
    char filename[255];
    
    switch (type) {
        case TileTypeColorChange:
            switch (m_lastLightId) {
                case 1:
                    sprintf(filename, "common/lasers.png");
                    break;
                case 2:
                    sprintf(filename, "common/fireworks.png");
                    break;
                default:
                    sprintf(filename, "common/lights.png");
                    break;
            }
            break;
        default:
            sprintf(filename, "tiles/%s/%s.png", m_actor->m_name.c_str(), actionName.c_str());
            break;
    }
    //    CCLOG("actionName : %s", filename);
    
    auto tile = TileSprite::create(filename);
    tile->m_type = type;
    tile->m_actionName = actionName;
    tile->m_delegate = this;
    if (type == TileTypeColorChange) {
//        tile->setHue(m_hue);
//        m_hue += 0.2;
//        if (m_hue >= 1.0) {
//            m_hue = 0.0;
//        }
        tile->setTag(COLOR_CHANGE_TILE_TAG);
    }
    Point p;
    
    int leftCount = 0;
    int rightCount = 0;
    for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL && b->GetType() == b2_dynamicBody) {
            Sprite *sprite = (Sprite *)b->GetUserData();
            if (sprite->getPosition().x < origin.x + visibleSize.width / 2) {
                leftCount++;
            } else {
                rightCount++;
            }
        }
    }
    
    bool left;
    
    if (leftCount == rightCount) {
        left = ((rand() % 10) <= 4);
    } else {
        left = (leftCount < rightCount);
    }
    
    //For testing.
    //    if (type == TileTypeColorChange) {
    //        left = false;
    //    }
    
    float tileY = minTileGenY + tile->getContentSize().height / 2 + rand() % (int)(visibleSize.height - minTileGenY - tile->getContentSize().width - 400);
    
    if (left)
    {
        if (type == TileTypeColorChange || m_dancePreloadedCount < 8) {
            p = Point(tile->getContentSize().width / 2 + 70.0 +
                      rand() % (int)(visibleSize.width / 2 - CENTER_CIRCLE_RADIUS - tile->getContentSize().width - 70.0),
                      tileY);
        } else {
            p = Point( - WALL_OFFSET_X - tile->getContentSize().width / 2, tileY);
        }
    } else {
        if (type == TileTypeColorChange || m_dancePreloadedCount < 8) {
            p = Point(visibleSize.width / 2 + CENTER_CIRCLE_RADIUS + tile->getContentSize().width / 2 +
                      rand() % (int)(visibleSize.width / 2 - CENTER_CIRCLE_RADIUS - tile->getContentSize().width - 70.0),
                      tileY);
        } else {
            p = Point(visibleSize.width + WALL_OFFSET_X + tile->getContentSize().width / 2, tileY);
        }
    }
    
    tile->setPosition(origin + Point(p));
    
    tile->setScale(0.0);
    
    addChild(tile, TILE_LAYER);
    
    if (type == TileTypeColorChange && m_lastLightId > 0) {
        tile->attachPhysicsFromCache(m_world, "starTile");
    } else {
        tile->attachPhysics(m_world);
    }
    
    float speedX = rand() % 4;
    float speedY = rand() % 3 - 5;
    
    float timeMult = 1.0;
    
    if (type != TileTypeColorChange && m_dancePreloadedCount >= 8) {
        speedX /= 5.0;
        speedY /= 5.0;
        timeMult = 3.0;
    }
    if (type == TileTypeColorChange || m_dancePreloadedCount < 8) {
        tile->m_body->SetLinearVelocity(b2Vec2(speedX, speedY));
    } else {
        tile->setEnterMode();
        if (left) {
            tile->m_body->SetLinearVelocity(b2Vec2(2.0, -0.5));
        } else {
            tile->m_body->SetLinearVelocity(b2Vec2(-2.0, -0.5));
        }
    }
    
    float tileScale = 1.0;
    
    if (screenSize.width == 960) {
        tileScale *= scaleAdjust;
    }

    if (type == TileTypeNormal) {
        if (m_dancePreloadedCount < 8) {
            tile->runAction(ScaleTo::create(0.5 * timeMult, 1.0 * tileScale));
            m_dancePreloadedCount++;
        } else {
            tile->setScale(1.0);
//            tile->runAction(Sequence::create(DelayTime::create(5.0),
//                                             CallFunc::create(std::bind(&TileSprite::removeHeavyMode, tile)),
//                                             NULL));
        }
    } else if (type == TileTypeColorChange) {
        tile->runAction(Sequence::create(
                                         ScaleTo::create(0.5, 1.0 * tileScale),
                                         DelayTime::create(5.0),
                                         ScaleTo::create(0.5, 0.0),
                                         CallFunc::create(std::bind(&Node::removeFromParent, tile)),
                                         CallFuncN::create(std::bind(&TileSprite::detachPhysics, tile, m_world)),
                                         CallFunc::create(std::bind(&CreateLayer::scheduleNextColorChangeTile, this)),
                                         NULL));
    }
    
}

void CreateLayer::fastCleanUp()
{
    unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::playNextDance));
    unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::addColorChangeTile));
    
    m_isGoingBack = true;
    
    CocosDenshion::SimpleAudioEngine::getInstance()->stopAllEffects();
    CocosDenshion::SimpleAudioEngine::getInstance()->stopBackgroundMusic();

    m_actor->stopAllActions();
    m_actor->m_cancelLoading = true;
    
    m_actor->stopPerform();
    m_actor->clearAssets(true);

    removeAllFloatingTiles();
    
    endColorChangeShow();
    
    if (m_backButtonBody) {
        m_backButtonBody->SetUserData(NULL);
        m_world->DestroyBody(m_backButtonBody);
        m_backButtonBody = NULL;
    }
    
    Node* backButton = getChildByTag(BACK_BUTTON_TAG);
    if (backButton) {
        backButton->removeFromParent();
    }
    Node* forwardButton = getChildByTag(FORWARD_BUTTON_TAG);
    if (forwardButton) {
        forwardButton->removeFromParent();
    }
    
    if (m_forwardButtonBody) {
        m_forwardButtonBody->SetUserData(NULL);
        m_world->DestroyBody(m_forwardButtonBody);
        m_forwardButtonBody = NULL;
    }
    
    if (m_centralCircleBody) {
        m_centralCircleBody->SetUserData(NULL);
        m_world->DestroyBody(m_centralCircleBody);
        m_centralCircleBody = NULL;
    }
    
    for(int i = 0; i < 4; i++)
    {
        if (m_dropzoneBodies[i]) {
            DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
            if (zone) {
                TileSprite *tile = zone->m_tile;
                if (tile) {
                    tile->removeFromParent();
                }
                zone->removeFromParent();
            }
        }
    }
    
    GameManager *gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
}

void CreateLayer::onExit()
{
    NativeHelper::getInstance()->endFlurryTimedEvent("Time on " + m_actor->m_name + " Play Screen");
    
    Sprite *noise = (Sprite *)getChildByTag(NOISE_TAG);
    if (noise) {
        noise->removeFromParent();
        Director::getInstance()->getTextureCache()->removeTextureForKey("images/bg/noise2.png");
        CCLOG("removed noise");
    }
    
    Sprite *bg = (Sprite *)getChildByTag(BG_TAG);
    if (bg) {
        bg->removeFromParent();
        Director::getInstance()->getTextureCache()->removeTextureForKey("tiles/" + m_actor->m_name + "/bgCircle.png");
        CCLOG("removed bg");
    }

    Layer::onExit();
}

void CreateLayer::tilePressed(TileSprite *tile)
{
    if (tile->m_dropzoneIndex >= 0) {
        //        DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[tile->m_dropzoneIndex]->GetUserData();
        //        if (zone)
        //        {
        //            zone->bounce();
        //        }
    } else {
        for(int i = 0; i < 4; i++)
        {
            DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
            if (!zone->m_tile) {
                zone->dropTile(tile);
                addActionTile(tile->m_actionName);
                checkDropzonesToPlay();
                break;
            }
        }
    }
    //    m_actor->playAction(tile->m_actionName);
}

bool CreateLayer::onTouchBegan(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    if (m_isGoingBack) return true;
    Point point = pTouch->getLocationInView();
    point = Director::getInstance()->convertToUI(point);
    m_lastTouchPos = point;
    m_touchBeginPos = point;
    
    Point screenCenter = origin + Point(visibleSize.width / 2, visibleSize.height / 2);
    
    if (!m_colorChanging) {
        for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
            if (b && b->GetUserData() != NULL) {
                Sprite *sprite = (Sprite *)b->GetUserData();
                if (sprite && b->GetType() == b2_dynamicBody) {
                    TileSprite *tile = dynamic_cast<TileSprite *>(sprite);
                    if (tile)
                    {
                        if (point.distance(tile->getPosition()) <= tile->getContentSize().width / 2 && !tile->m_dropping) {
                            if (tile->m_type == TileTypeNormal) {
                                m_currentTile = tile;
                                m_currentTile->detachPhysics(m_world);
                                m_touchOffset = point - tile->getPosition();
                                CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/TileTap1.mp3");
                                m_actor->playAction(m_currentTile->m_actionName);
                                
                                NativeHelper::getInstance()->logFlurryEvent("Taps Dance Tile", "Type of Dance Tile", m_actor->m_name + ":" + m_actor->m_actions[m_currentTile->m_actionName].realName);
                                
                                struct timeval tv;
                                gettimeofday(&tv, NULL);
                                m_t0 = (unsigned long long)(tv.tv_sec) * 1000 + (unsigned long long)(tv.tv_usec) / 1000;
                                
                                m_currentTile->setZOrder(DRAG_TILE_LAYER);
                            } else if (tile->m_type == TileTypeColorChange && !m_colorChanging) {
                                m_hue = 0.0;
                                m_colorChanging = true;
                                tile->detachPhysics(m_world);
                                tile->runAction(Sequence::create(
                                                                 ScaleTo::create(0.5, 0.0),
                                                                 CallFunc::create(std::bind(&Node::removeFromParent, tile)),
                                                                 NULL));
                                scheduleOnce(CC_SCHEDULE_SELECTOR(CreateLayer::addColorChangeTile), 10.0);
                                // change tile here.
                            }
                            return true;
                        }
                    }
                }
                else if (b->GetType() == b2_staticBody )
                {
                    DropzoneSprite *zone = dynamic_cast<DropzoneSprite *>(sprite);
                    if (zone) {
                        TileSprite *tile = zone->m_tile;
                        if (tile) {
                            if (point.distance(tile->getPosition()) < tile->getContentSize().width / 2 && !tile->m_dropping) {
                                m_currentTile = zone->m_tile;
                                //                            tilePressed(m_currentTile);
                                
                                if (m_isPlaying) {
                                    NativeHelper::getInstance()->logFlurryEvent("Taps Dance Tile in Drop Zone");

                                    addStars(point);

//                                    scheduleNextAction(zone->m_index);
                                } else {
                                    
                                    NativeHelper::getInstance()->logFlurryEvent("Taps Dance Tile", "Type of Dance Tile", m_actor->m_actions[m_currentTile->m_actionName].realName);
                                    
                                    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/TileTap1.mp3");

                                    m_actor->playAction(m_currentTile->m_actionName);
                                    if (m_isSequenceFull) {
                                        zone->bounce();
                                    }
                                }
                                m_currentTile->setZOrder(DRAG_TILE_LAYER);
                                m_touchOffset = point - m_currentTile->getPosition();
                                return true;
                            }
                        } else if (point.distance(zone->getPosition()) < zone->getContentSize().width / 2) {
                            NativeHelper::getInstance()->logFlurryEvent("Tries Tapping a Drop Zone");
                        }
                    }
                }
            }
        }
    }
    
    if (m_circle->getPosition().distance(point) < CENTER_CIRCLE_RADIUS) {
        
        NativeHelper::getInstance()->logFlurryEvent("Taps Monster");
        
        if (m_actor->m_currentActionName == "idle" && m_reactionReady) {
            
            int reactionId = 1 + rand() % 3;
            while (reactionId == m_lastReactionId) {
                reactionId = 1 + rand() % 3;
            }
            char actionName[100];
            sprintf(actionName, "reaction%d", reactionId);
            CCLOG("Play reaction : %s", actionName);
            m_actor->playAction(actionName);
        }
        /*
         Sausalito: #ac3434 (R:172 G:52 B:52)
         Freds: #30788b (R:48 G:120 B:139)
         Guac: #2d7c6a (R: 45 G: 124 B:106)
         Pom: #df6005 (R:223 G:96 B:96)
         Le Blob:  #225d8d (R:34 G:93 B:141)
         Meep: #59347c (R:89 G:52 B:124)
         */
        static Color4F ep[5];
        ep[0] = Color4F(255.0 / 255.0, 134.0 / 255.0, 134.0 / 255.0, 1.0);
        ep[1] = Color4F(153.0 / 255.0, 84.0 / 255.0, 213.0 / 255.0, 1.0);
        ep[2] = Color4F(249.0 / 255.0, 238.0 / 255.0, 100.0 / 255.0, 1.0);
        ep[3] = Color4F(184.0 / 255.0, 233.0 / 255.0, 134.0 / 255.0, 1.0);
        ep[4] = Color4F(139.0 / 255.0, 226.0 / 255.0, 206.0 / 255.0, 1.0);
//        ep[0] = Color4F(172.0 / 255.0, 52.0 / 255.0, 52.0 / 255.0, 1.0);
//        ep[1] = Color4F(48.0 / 255.0, 120.0 / 255.0, 139.0 / 255.0, 1.0);
//        ep[2] = Color4F(45.0 / 255.0, 124.0 / 255.0, 106.0 / 255.0, 1.0);
//        ep[3] = Color4F(223.0 / 255.0, 96.0 / 255.0, 96.0 / 255.0, 1.0);
//        ep[4] = Color4F(34.0 / 255.0, 93.0 / 255.0, 141.0 / 255.0, 1.0);
//        ep[5] = Color4F(89.0 / 255.0, 52.0 / 255.0, 124.0 / 255.0, 1.0);
        
        for (int i = 0; i < 5; i++) {
            auto p = FadeParticleSystem::create("particles/explode.plist");
            p->m_fadeOutTime = 0.1;
            p->setStartColor(ep[i]);
            p->setEndColor(ep[i]);
            p->setPosition(point);
            addChild(p, STAR_LAYER);
            p->runAction(Sequence::create(
                                          DelayTime::create(5.0),
                                          CallFunc::create(std::bind(&Node::removeFromParent, p)),
                                          NULL));
            
        }
//        float v = CocosDenshion::SimpleAudioEngine::getInstance()->getEffectsVolume();
//        CocosDenshion::SimpleAudioEngine::getInstance()->setEffectsVolume(v * 0.2);
//        playSparkleSound();
        CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/Sparkle_01_Subtle.mp3");
//        CocosDenshion::SimpleAudioEngine::getInstance()->setEffectsVolume(v);
    } else {
        addStars(point);
    }
    
    m_starFreq = 0;
    
    return true;
}

void CreateLayer::addStars(Point point)
{
//    static Color4F ep[6];
//    ep[0] = Color4F(172.0 / 255.0, 52.0 / 255.0, 52.0 / 255.0, 1.0);
//    ep[1] = Color4F(48.0 / 255.0, 120.0 / 255.0, 139.0 / 255.0, 1.0);
//    ep[2] = Color4F(45.0 / 255.0, 124.0 / 255.0, 106.0 / 255.0, 1.0);
//    ep[3] = Color4F(223.0 / 255.0, 96.0 / 255.0, 96.0 / 255.0, 1.0);
//    ep[4] = Color4F(34.0 / 255.0, 93.0 / 255.0, 141.0 / 255.0, 1.0);
//    ep[5] = Color4F(89.0 / 255.0, 52.0 / 255.0, 124.0 / 255.0, 1.0);
//    for (int i = 0; i < 6; i++) {
        auto p = FadeParticleSystem::create("particles/stars.plist");
        p->m_fadeOutTime = 0.1;
//        p->setStartColor(ep[i]);
//        p->setEndColor(ep[i]);
        p->setPosition(point);
        addChild(p, FINGER_LAYER);
        p->runAction(Sequence::create(
                                      DelayTime::create(5.0),
                                      CallFunc::create(std::bind(&Node::removeFromParent, p)),
                                      NULL));
//    }
    
//    float v = CocosDenshion::SimpleAudioEngine::getInstance()->getEffectsVolume();
//    CocosDenshion::SimpleAudioEngine::getInstance()->setEffectsVolume(v * 0.15);
    playSparkleSound();
//    CocosDenshion::SimpleAudioEngine::getInstance()->setEffectsVolume(v);
}

void CreateLayer::onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    Point point = pTouch->getLocationInView();
    point = Director::getInstance()->convertToUI(point);
    
    if (!m_dragging && point != m_lastTouchPos)
    {
        m_dragging = true;
    }
    
    if (m_dragging)
    {
        if (!m_draggingDisabled && m_currentTile) {
            struct timeval tv;
            gettimeofday(&tv, NULL);
            m_t1 = (unsigned long long)(tv.tv_sec) * 1000 + (unsigned long long)(tv.tv_usec) / 1000;
            
            float t = ((double)m_t1 - (double)m_t0) / 500.0;
            if (t <= 0) {
                t = 0.2;
            }
            m_t0 = m_t1;
            m_lastDragSpeed = (point - m_lastTouchPos) / t * 64.0;
            m_lastTouchPos = point;

            if (m_currentTile->m_dropzoneIndex < 0) {
                m_currentTile->setPosition(getTargetPos(point));
            } else {
                if (point.getDistance(m_touchBeginPos) > DRAG_GATE_DISTANCE) {
                    m_zoneLinkBreaked = true;
                }
                if (m_zoneLinkBreaked) {
                    m_currentTile->setPosition(getTargetPos(point));
                    DropzoneSprite *zone = (DropzoneSprite *)m_dropzoneBodies[m_currentTile->m_dropzoneIndex]->GetUserData();
                    zone->removeCircle();
                    m_lastTouchPos = point;
                }
            }
        } else {
            if (m_starFreq % 5 == 0) {
                addStars(point);
            } else {
//                CCLOG("skipping addStars...");
            }
            m_starFreq++;
        }
    }
}

void CreateLayer::onTouchEnded(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    Point point = pTouch->getLocationInView();
    point = Director::getInstance()->convertToUI(point);
    if (!m_draggingDisabled && m_dragging && m_currentTile && point.distance(m_touchBeginPos) > 10)
    {
        tryDropNewTile(m_currentTile);
    } else if (m_currentTile && point.getDistance(m_touchBeginPos) <= DRAG_GATE_DISTANCE) {
        // trigger event here;
        tilePressed(m_currentTile);
        if (m_currentTile->m_dropzoneIndex < 0) {
            m_currentTile->attachPhysics(m_world);
        }
    }
    
    if (m_currentTile) {
        if (m_currentTile->m_dropzoneIndex < 0) {
            m_currentTile->setZOrder(TILE_LAYER);
        } else {
            m_currentTile->setZOrder(DROP_TILE_LAYER);
        }
    }
    m_currentTile = NULL;
    m_touchOffset = Point::ZERO;
    m_dragging = false;
    m_zoneLinkBreaked = false;
}

void CreateLayer::onTouchCancelled(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    onTouchEnded(pTouch, pEvent);
//    if (m_currentTile) {
//        if (m_currentTile->m_dropzoneIndex < 0) {
//            m_currentTile->setZOrder(TILE_LAYER);
//            m_currentTile->attachPhysics(m_world);
//        } else {
//            m_currentTile->setZOrder(DROP_TILE_LAYER);
//        }
//    }
//    m_currentTile = NULL;
//    m_touchOffset = Point::ZERO;
//    m_dragging = false;
}

void CreateLayer::removeDuplicatedTile(TileSprite *tileA)
{
    if (tileA->m_body && tileA->m_mode != TileModeLeaving && tileA->m_body->GetType() == b2_dynamicBody) {
        for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                Sprite *sprite = (Sprite *)b->GetUserData();
                if (b->GetType() == b2_dynamicBody) {
                    TileSprite *tileB = dynamic_cast<TileSprite *>(sprite);
                    if (tileA == tileB) {
                        continue;
                    }
                    if (tileB && tileB->m_mode != TileModeLeaving && tileB->m_actionName == tileA->m_actionName) {
                        CCLOG("Duplicated tile after drag");
                        
                        float axl = tileA->getPosition().x - origin.x;
                        float axr = origin.x + visibleSize.width - tileA->getPosition().x;
                        float ayb = tileA->getPosition().y - origin.y;
                        float ayu = origin.y + visibleSize.height - tileA->getPosition().y;
                        
                        float bxl = tileB->getPosition().x - origin.x;
                        float bxr = origin.x + visibleSize.width - tileB->getPosition().x;
                        float byb = tileB->getPosition().y - origin.y;
                        float byu = origin.y + visibleSize.height - tileB->getPosition().y;
                        
                        float axmin = fminf(axl, axr);
                        float aymin = fminf(ayb, ayu);
                        
                        float bxmin = fminf(bxl, bxr);
                        float bymin = fminf(byb, byu);
                        
                        if (fminf(axmin, aymin) < fminf(bxmin, bymin)) {
                            tileA->setLeavingMode();
                            if (axmin < aymin) {
                                if (axl < axr) {
                                    tileA->m_body->SetLinearVelocity(b2Vec2(-2.0, 0));
                                } else {
                                    tileA->m_body->SetLinearVelocity(b2Vec2(2.0, 0));
                                }
                            } else {
                                if (ayb < ayu) {
                                    tileA->m_body->SetLinearVelocity(b2Vec2(0.0, -2.0));
                                } else {
                                    tileA->m_body->SetLinearVelocity(b2Vec2(0.0, 2.0));
                                }
                            }
                        } else {
                            tileB->setLeavingMode();
                            if (bxmin < bymin) {
                                if (bxl < bxr) {
                                    tileB->m_body->SetLinearVelocity(b2Vec2(-2.0, 0));
                                } else {
                                    tileB->m_body->SetLinearVelocity(b2Vec2(2.0, 0));
                                }
                            } else {
                                if (byb < byu) {
                                    tileB->m_body->SetLinearVelocity(b2Vec2(0.0, -2.0));
                                } else {
                                    tileB->m_body->SetLinearVelocity(b2Vec2(0.0, 2.0));
                                }
                            }                        }
                    }
                }
            }
        }
    }
}

Point CreateLayer::getTargetPos(Point point)
{
    Point targetPos = point - m_touchOffset;
    if (targetPos.x < origin.x + m_currentTile->getContentSize().width / 2)
    {
        targetPos.x = origin.x + m_currentTile->getContentSize().width / 2;
    }
    
    if (targetPos.y < origin.y + m_currentTile->getContentSize().height / 2)
    {
        targetPos.y = origin.y + m_currentTile->getContentSize().height / 2;
    }
    
    if (targetPos.x > origin.x + visibleSize.width -  + m_currentTile->getContentSize().width / 2)
    {
        targetPos.x = origin.x + visibleSize.width -  + m_currentTile->getContentSize().width / 2;
    }
    
    if (targetPos.y > origin.y + visibleSize.height -  + m_currentTile->getContentSize().height / 2)
    {
        targetPos.y = origin.y + visibleSize.height -  + m_currentTile->getContentSize().height / 2;
    }
    return targetPos;
}

void CreateLayer::tryDropNewTile(TileSprite *tile)
{
    int newIndex = -1;
    for(int i = 0; i < 4; i++)
    {
        DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
        if (zone->getPosition().distance(tile->getPosition()) < DRAG_GATE_DISTANCE) {
            newIndex = i;
            break;
        }
    }
    
    if (newIndex < 0) {
        // Dropping out of any dropzone
        if (tile->m_dropzoneIndex < 0)
        {
            if (tile->getPosition().distance(m_circle->getPosition()) <= CENTER_CIRCLE_RADIUS - 50) {
                // Dropping in the center area
                for(int i = 0; i < 4; i++)
                {
                    DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
                    if (zone && !zone->m_tile) {
                        zone->dropTile(tile);
                        addActionTile(tile->m_actionName);
                        checkDropzonesToPlay();
                        break;
                    }
                }
            } else {
                if (tile->getPosition().x > origin.x + visibleSize.width / 2 - DROPZONE_TOTAL_WIDTH / 2 &&
                    tile->getPosition().x < origin.x + visibleSize.width / 2 + DROPZONE_TOTAL_WIDTH / 2 &&
                    tile->getPosition().y >= origin.y &&
                    tile->getPosition().y < origin.y + DROPZONE_Y + m_dropzoneYC) {
                    tile->setPosition(tile->getPosition().x, tile->getPosition().y + 252);
                }
                tile->attachPhysicsInReenterMode(m_world);
                CCLOG("lastDrag : %f, %f", m_lastDragSpeed.x, m_lastDragSpeed.y);
                tile->m_body->ApplyForceToCenter(b2Vec2(m_lastDragSpeed.x * tile->m_body->GetFixtureList()->GetDensity(), m_lastDragSpeed.y * tile->m_body->GetFixtureList()->GetDensity()), true);
            }
        } else {
            // tile is from a dropzone
            NativeHelper::getInstance()->logFlurryEvent("Removes Tile from Drop Zone", "Type of Dance Tile", m_actor->m_actions[tile->m_actionName].realName);
            DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[tile->m_dropzoneIndex]->GetUserData();
//            zone->removeCurrentTile();
            removeTileFromZone(zone);
        }
    } else {
        DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[newIndex]->GetUserData();
        m_currentTile = NULL;
        if (zone->m_tile)
        {
            TileSprite* oldTile = zone->m_tile;
            if (tile == oldTile) {
                zone->dropTile(tile);
            } else {
                m_lastDragSpeed = Vec2(-m_lastDragSpeed.x, -m_lastDragSpeed.y);
                zone->m_tile->removeFromParent();
                zone->m_tile = NULL;
                if (tile->m_dropzoneIndex < 0) {
                    addActionTile(tile->m_actionName);
                } else {
                    DropzoneSprite *oldZone = (DropzoneSprite*)m_dropzoneBodies[tile->m_dropzoneIndex]->GetUserData();
                    oldZone->m_tile = NULL;
                }
                zone->dropTile(tile);
                checkDropzonesToPlay();
            }
        } else {
            if (tile->m_dropzoneIndex < 0) {
                addActionTile(tile->m_actionName);
            } else {
                DropzoneSprite *oldZone = (DropzoneSprite*)m_dropzoneBodies[tile->m_dropzoneIndex]->GetUserData();
                oldZone->m_tile = NULL;
            }
            zone->dropTile(tile);
            checkDropzonesToPlay();
        }
    }
}

bool CreateLayer::dropzoneIsFull()
{
    int dropCount = 0;
    for(int i = 0; i < 4; i++)
    {
        DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
        if (zone->m_tile) {
            dropCount++;
        }
    }
    
    return dropCount == 4;
}

void CreateLayer::removeTileFromZone(DropzoneSprite *zone)
{
    if (!zone || !zone->m_tile) return;
    
//    float dx = 200.0 - rand() % 400;
//    float dy = 200 + rand() % 50;
    TileSprite *tile = zone->m_tile;
    zone->m_tile = NULL;

    tile->m_dropzoneIndex = -1;

//    tile->setZOrder(ACTOR_LAYER - 1);
    tile->attachPhysicsInReenterMode(m_world);

    tile->m_body->ApplyForceToCenter(b2Vec2(m_lastDragSpeed.x * tile->m_body->GetFixtureList()->GetDensity() / 2, m_lastDragSpeed.y * tile->m_body->GetFixtureList()->GetDensity() / 2), true);
    
//    float d = Point(m_lastDragSpeed.x, m_lastDragSpeed.y).distance(Point::ZERO);
//    float sx = 1.0;
//    float sy = 10.0;
//    if (d > 3.0) {
//        sx = 10.0 * m_lastDragSpeed.x / d;
//        sy = 10.0 * m_lastDragSpeed.y / d;
//    }
//    
//    CCLOG("lastDrag : %f, %f, %f, %f", m_lastDragSpeed.x, m_lastDragSpeed.y, sx, sy);
//
////    tile->m_body->SetLinearVelocity(b2Vec2(sx, sy));
}

void CreateLayer::removeFloatingTiles()
{
    int i = 0;
    
    for(Vector<Node *>::iterator it = getChildren().begin(); it != getChildren().end(); it++)
    {
        Node *n = *it;
        TileSprite *tile = dynamic_cast<TileSprite *>(n);
        if (tile && tile->m_type != TileTypeColorChange && tile->m_dropzoneIndex < 0) {
            tile->stopAllActions();
            tile->detachPhysics(m_world);
            tile->runAction(Sequence::create(
                                             DelayTime::create(0.05 * i),
                                             ScaleTo::create(0.1, 0),
                                             CallFunc::create(std::bind(&Node::removeFromParent, tile)),
                                             NULL));
        }
    }
    
//    for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
//        if (b->GetUserData() != NULL && b->GetType() == b2_dynamicBody) {
//            Sprite *sprite = (Sprite *)b->GetUserData();
//            TileSprite *tile = dynamic_cast<TileSprite *>(sprite);
//            if (tile && tile->m_type != TileTypeColorChange) {
//                tile->stopAllActions();
//                tile->detachPhysics(m_world);
//                tile->runAction(Sequence::create(
//                                                 DelayTime::create(0.05 * i),
//                                                 ScaleTo::create(0.1, 0),
//                                                 CallFunc::create(std::bind(&Node::removeFromParent, tile)),
//                                                 NULL));
//                i++;
//            }
//        }
//    }
}

void CreateLayer::removeAllFloatingTiles()
{
    int i = 0;
    for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL && b->GetType() == b2_dynamicBody) {
            Sprite *sprite = (Sprite *)b->GetUserData();
            TileSprite *tile = dynamic_cast<TileSprite *>(sprite);
            if (tile) {
                tile->stopAllActions();
                tile->detachPhysics(m_world);
                tile->removeFromParent();
                i++;
            }
        }
    }
}

void CreateLayer::checkDropzonesToPlay()
{
    if (dropzoneIsFull()) {
        m_draggingDisabled = true;
        // remove floating tiles
        removeFloatingTiles();
        
        // show play button
        
        std::string buttonFile = "tiles/" + m_actor->m_name + "/play.png";
        
//        auto forwardButton = MenuItemImage::create(buttonFile, buttonFile, CC_CALLBACK_1(CreateLayer::prepareToForward, this));
        auto forwardButton = Button::create(buttonFile);
        forwardButton->addClickEventListener(CC_CALLBACK_1(CreateLayer::prepareToForward, this));
        forwardButton->setTag(FORWARD_BUTTON_TAG);
//        forwardButton->setRotation(180.0);
        forwardButton->setPosition(Point(origin.x + visibleSize.width - forwardButton->getContentSize().width / 2 - 98 + m_cornerYC, origin.y + visibleSize.height - forwardButton->getContentSize().height / 2 - 101 + m_cornerYC));
//        m_menu->addChild(forwardButton);
        addChild(forwardButton, 50);
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_staticBody;
        bodyDef.position.Set(forwardButton->getPosition().x/PTM_RATIO, forwardButton->getPosition().y/PTM_RATIO);
        m_forwardButtonBody = m_world->CreateBody(&bodyDef);
        
        b2CircleShape circleBox;
        circleBox.m_radius = BUTTON_BODY_RADIUS / PTM_RATIO;
        
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &circleBox;
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.2f;
        fixtureDef.restitution = 0.95f;
        fixtureDef.filter.categoryBits = FixtureButton;
        fixtureDef.filter.maskBits = FixtureTile;
        m_forwardButtonBody->CreateFixture(&fixtureDef);
        m_forwardButtonBody->SetFixedRotation(true);
        m_forwardButtonBody->SetUserData(forwardButton);
        
        m_isSequenceFull = true;
        
        prepareToPlay(NULL);
    }
}

void CreateLayer::prepareToPlay(Ref *sender)
{
    
    NativeHelper::getInstance()->logFlurryEvent("Tap Play");
    
    m_isPlaying = true;
    
    GameManager *gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];

    for(int i = 0; i < 4; i++)
    {
        DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
        gm->m_currentActors[gm->m_currentActorIndex].sequence[i] = zone->m_tile->m_actionName;
    }
    gm->m_currentActors[gm->m_currentActorIndex].isSequenceReady = true;

    
    m_currentSequenceIndex = 3;
    
    if (m_backButtonBody) {
        m_backButtonBody->SetUserData(NULL);
        m_world->DestroyBody(m_backButtonBody);
        m_backButtonBody = NULL;
    }
    
    Node* oldBackButton = getChildByTag(BACK_BUTTON_TAG);

    std::string backButtonFile = "tiles/" + m_actor->m_name + "/back.png";
    
//    auto backButton = MenuItemImage::create(backButtonFile, backButtonFile, CC_CALLBACK_1(CreateLayer::restoreCreateMode, this));
    auto backButton = Button::create(backButtonFile);
    backButton->addClickEventListener(CC_CALLBACK_1(CreateLayer::restoreCreateMode, this));
    backButton->setPosition(Point(origin.x + backButton->getContentSize().width / 2 + 98 - m_cornerYC, origin.y + visibleSize.height - backButton->getContentSize().height / 2 - 100 + m_cornerYC));
    backButton->setTag(BACK_BUTTON_TAG);
//    m_menu->addChild(backButton);
    addChild(backButton, 50);
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(backButton->getPosition().x/PTM_RATIO, backButton->getPosition().y/PTM_RATIO);
    m_backButtonBody = m_world->CreateBody(&bodyDef);
    m_backButtonBody->SetUserData(backButton);
    
    b2CircleShape circleBox;
    circleBox.m_radius = BUTTON_BODY_RADIUS / PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.95f;
    fixtureDef.filter.categoryBits = FixtureButton;
    fixtureDef.filter.maskBits = FixtureTile;
    m_backButtonBody->CreateFixture(&fixtureDef);
    m_backButtonBody->SetFixedRotation(true);
    
    if (oldBackButton) {
        oldBackButton->removeFromParent();
    }
    
    m_circle->runAction(Spawn::create(
                                      MoveTo::create(0.3, Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2)),
                                      ScaleTo::create(0.3, 5.0),
                                      NULL));

    scheduleOnce(CC_SCHEDULE_SELECTOR(CreateLayer::addColorChangeTile), 5);
    
    int sequenceReadyCount = 0;
    for (int i = 0; i < 3; i++) {
        if (gm->m_currentActors[i].isSequenceReady) {
            sequenceReadyCount++;
        }
    }
    
    if (sequenceReadyCount >= 3) {
        CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/Hooray_2.mp3");
    } else {
        CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/Hooray_1.mp3");
    }
    
    m_pace = 0;
    CocosDenshion::SimpleAudioEngine::getInstance()->stopBackgroundMusic();

    CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.playBeats.c_str(), true);
    
    DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[m_currentSequenceIndex]->GetUserData();
    TileSprite *tile = zone->m_tile;
    m_actor->playAction(tile->m_actionName);
    
    zone->bounce();
    
    schedule(CC_SCHEDULE_SELECTOR(CreateLayer::playNextDance), PACE_TIME);
    
    
    m_colorChanged = false;
    
//    m_actor->clearUnusedAssets();

    NativeHelper::getInstance()->endFlurryTimedEvent("Time on " + gm->m_currentActors[gm->m_currentActorIndex].name + " Create Screen");
    
    NativeHelper::getInstance()->logFlurryEvent("Time on " + gm->m_currentActors[gm->m_currentActorIndex].name + " Play Screen", true);
}

void CreateLayer::playNextDance(float dt)
{
    if (m_isGoingBack) return;
    
    CCLOG("dt = %f", dt);
    
    GameManager *gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    m_pace++;
    if (m_pace > 3) {
        m_pace = 0;
    }

    if (m_pace == 0) {
        CCLOG("Background music rewinded!");
        CocosDenshion::SimpleAudioEngine::getInstance()->rewindBackgroundMusic();
    }
    
    m_currentSequenceIndex++;
    if (m_currentSequenceIndex > 3) {
        m_currentSequenceIndex = 0;
    }
    
    DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[m_currentSequenceIndex]->GetUserData();
    TileSprite *tile = zone->m_tile;
    m_actor->playAction(tile->m_actionName);
    zone->bounce();
    
}

void CreateLayer::restoreCreateMode(cocos2d::Ref *sender)
{
    m_isPlaying = false;
    
    unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::playNextDance));
    
    endColorChangeShow();
    
    TileSprite *colorTile = (TileSprite*)getChildByTag(COLOR_CHANGE_TILE_TAG);
    if (colorTile) {
        colorTile->detachPhysics(m_world);
        colorTile->runAction(Sequence::create(
                                              ScaleTo::create(0.5, 0.0),
                                              CallFunc::create(std::bind(&Node::removeFromParent, colorTile)),
                                              NULL));
    }

    unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::addColorChangeTile));
    
    CocosDenshion::SimpleAudioEngine::getInstance()->stopAllEffects();
    
    GameManager *gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.createBeats.c_str(), true);

    if (m_backButtonBody) {
        m_backButtonBody->SetUserData(NULL);
        m_world->DestroyBody(m_backButtonBody);
        m_backButtonBody = NULL;
    }
    
    Node* oldBackButton = getChildByTag(BACK_BUTTON_TAG);
    
    std::string backButtonFile = "tiles/" + m_actor->m_name + "/back.png";
    
//    auto backButton = MenuItemImage::create(backButtonFile, backButtonFile, CC_CALLBACK_1(CreateLayer::prepareToGoBack, this));
    auto backButton = Button::create(backButtonFile);
    backButton->addClickEventListener(CC_CALLBACK_1(CreateLayer::prepareToGoBack, this));
    backButton->setPosition(Point(origin.x + backButton->getContentSize().width / 2 + 98 - m_cornerYC, origin.y + visibleSize.height - backButton->getContentSize().height / 2 - 100 + m_cornerYC));
    backButton->setTag(BACK_BUTTON_TAG);
//    m_menu->addChild(backButton);
    addChild(backButton, 50);
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(backButton->getPosition().x/PTM_RATIO, backButton->getPosition().y/PTM_RATIO);
    m_backButtonBody = m_world->CreateBody(&bodyDef);
    m_backButtonBody->SetUserData(backButton);
    
    b2CircleShape circleBox;
    circleBox.m_radius = BUTTON_BODY_RADIUS / PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.95f;
    fixtureDef.filter.categoryBits = FixtureButton;
    fixtureDef.filter.maskBits = FixtureTile;
    m_backButtonBody->CreateFixture(&fixtureDef);
    m_backButtonBody->SetFixedRotation(true);
    
    if (oldBackButton) {
        oldBackButton->removeFromParent();
    }

    m_actor->playAction("idle");

    if (m_forwardButtonBody) {
        m_forwardButtonBody->SetUserData(NULL);
        m_world->DestroyBody(m_forwardButtonBody);
        m_forwardButtonBody = NULL;
    }
    
    Node* forwardButton = getChildByTag(FORWARD_BUTTON_TAG);
    if (forwardButton) {
        forwardButton->removeFromParent();
    }
    
    m_circle->runAction(Spawn::create(
                                      MoveTo::create(0.3, Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 + 145)),
                                      ScaleTo::create(0.3, scaleAdjust),
                                      NULL));
    
    for(int i = 0; i < 4; i++)
    {
        if (m_dropzoneBodies[i]) {
            DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
            if (zone) {
                TileSprite *tile = zone->m_tile;
                if (tile) {
                    zone->restore();
                }
            }
        }
    }
    
    m_dancePreloadedCount = 0;
    
    setupTiles();

    m_currentTile = NULL;
    m_isSequenceFull = false;
    m_draggingDisabled = false;
}

void CreateLayer::prepareToForward(Ref *sender)
{
//    GameManager *gm = GameManager::getInstance();
//    
//    for(int i = 0; i < 4; i++)
//    {
//        DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
//        gm->m_currentActors[gm->m_currentActorIndex].sequence[i] = zone->m_tile->m_actionName;
//    }
//    gm->m_currentActors[gm->m_currentActorIndex].isSequenceReady = true;

    prepareToGoBack(sender);
}

void CreateLayer::prepareToGoBack(Ref *sender)
{
    NativeHelper::getInstance()->logFlurryEvent("Taps Back Arrow");
    
    unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::playNextDance));

    m_isGoingBack = true;
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/TileTap1.mp3");

    removeAllFloatingTiles();
    
    endColorChangeShow();
    
    if (m_backButtonBody) {
        m_backButtonBody->SetUserData(NULL);
        m_world->DestroyBody(m_backButtonBody);
        m_backButtonBody = NULL;
    }
    
    Node* backButton = getChildByTag(BACK_BUTTON_TAG);
    if (backButton) {
        backButton->runAction(Sequence::create(
                                                  ScaleTo::create(0.1, 0),
                                                  CallFunc::create(std::bind(&Node::removeFromParent, backButton)),
                                                  NULL));
    }

    
    if (m_forwardButtonBody) {
        m_forwardButtonBody->SetUserData(NULL);
        m_world->DestroyBody(m_forwardButtonBody);
        m_forwardButtonBody = NULL;
    }

    if (m_centralCircleBody) {
        m_centralCircleBody->SetUserData(NULL);
        m_world->DestroyBody(m_centralCircleBody);
        m_centralCircleBody = NULL;
    }
    
    CocosDenshion::SimpleAudioEngine::getInstance()->stopAllEffects();
    
    unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::addColorChangeTile));
    
    Node* forwardButton = getChildByTag(FORWARD_BUTTON_TAG);
    if (forwardButton) {
        forwardButton->runAction(Sequence::create(
                                               ScaleTo::create(0.1, 0),
                                               CallFunc::create(std::bind(&Node::removeFromParent, forwardButton)),
                                               NULL));
    }
    
    for(int i = 0; i < 4; i++)
    {
        if (m_dropzoneBodies[i]) {
            DropzoneSprite *zone = (DropzoneSprite*)m_dropzoneBodies[i]->GetUserData();
            if (zone) {
                TileSprite *tile = zone->m_tile;
                if (tile) {
                    tile->runAction(Sequence::create(
                                                     ScaleTo::create(0.2, 0),
                                                     CallFunc::create(std::bind(&Node::removeFromParent, tile)),
                                                     NULL));
                }
                zone->runAction(Sequence::create(
                                                 ScaleTo::create(0.2, 0),
                                                 CallFunc::create(std::bind(&Node::removeFromParent, zone)),
                                                 NULL));
            }
        }
    }
    
    GameManager *gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    m_actor->stopAllActions();
    m_actor->m_cancelLoading = true;

    std::string actionName;
    switch (GameManager::getInstance()->m_currentActors[GameManager::getInstance()->m_currentActorIndex].pos) {
        case 0:
            actionName = "moveLeft";
            break;
        case 1:
            actionName = "moveForward";
            break;
        default:
            actionName = "moveRight";
    }
    
    if (m_actor->m_currentActionName == "idle0") {
        goBack();
    } else {
        
        Point dancePoint = Point(origin.x + visibleSize.width / 2,
                                 origin.y + visibleSize.height / 2 + 220 + m_yAdj + m_actor->m_feetOffset * ACTOR_DANCE_SCALE);
        
        Point startPoint = Point(origin.x + visibleSize.width / 2 + (gm->m_currentActorIndex - 1) * EGG_LANDING_OFFX,
                                 origin.y + EGG_LANDING_Y + m_actor->m_feetOffset * ACTOR_SCALE) + scene.offsets[gm->m_currentActorIndex];
        
        float d = dancePoint.distance(startPoint);
        float r = m_actor->getPosition().distance(startPoint);
        
        float ta = r / d;
        
        m_actor->playAction(actionName);
        m_actor->runAction(Sequence::create(
                                            Spawn::create(
                                                          ScaleTo::create(ACTOR_ENTER_TIME * ta, actorScale),
                                                          MoveTo::create(ACTOR_ENTER_TIME * ta, startPoint),
                                                          NULL),
                                            CallFuncN::create(std::bind(&JsonSprite::playAction, m_actor, "idle0")),
                                            DelayTime::create(0.06),
                                            CallFunc::create(std::bind(&CreateLayer::goBack, this)),
                                            NULL));
    }
}

void CreateLayer::goBack()
{
    CocosDenshion::SimpleAudioEngine::getInstance()->stopBackgroundMusic();

    auto scene = WelcomeLayer::scene();
    m_actor->stopPerform();
    m_actor->clearAssets(true);
    Director::getInstance()->replaceScene(TransitionCrossFade::create(0.5, scene));
}

void CreateLayer::showLights()
{
    
//    m_lastLightId = 2;
    
    if (m_lastLightId < 2) {
    
        std::string lightName;
        
        if (m_lastLightId == 0) {
            lightName = "light";
        } else {
            lightName = "laser";
        }
        auto light = LightSprite::create(lightName);
        
        float scaleAdjust = 1.0;
        if (screenSize.width <= 1024.0) {
            scaleAdjust = LOW_RES_SCALE_ADJUST;
        }
        
        light->setScale(2.15 * scaleAdjust);
        if (screenRatio < 1.5) {
            light->setScale(2.3 * scaleAdjust);
        }
        light->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2);
        
        light->setTag(LIGHT_TAG);
        addChild(light, LIGHT_LAYER);
    } else {
        // show do firework
        schedule(CC_SCHEDULE_SELECTOR(CreateLayer::showFirworks), 0.3);
    }
}

void CreateLayer::hideLights()
{
    if (m_lastLightId < 2) {
    LightSprite *light = (LightSprite *)getChildByTag(LIGHT_TAG);
    if (light) {
        light->stopAllActions();
//        light->runAction(Sequence::create(
//                                           FadeOut::create(0.1),
//                                           CallFunc::create(std::bind(&Node::removeFromParent, light)),
//                                           NULL));
//        std::string textureFile = "lights/" + light->m_name + ".png";

        light->removeFromParent();
        
//        Texture2D *texture = Director::getInstance()->getTextureCache()->getTextureForKey(textureFile);
//        if (texture) {
//            SpriteFrameCache::getInstance()->removeSpriteFramesFromTexture(texture);
//        }
//        Director::getInstance()->getTextureCache()->removeTexture(texture);
    }
    } else {
        // remove firework
        
        unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::showFirworks));
    }
}

void CreateLayer::startColorChangeShow()
{
    if (m_colorChanged) return;
    m_colorChanged = true;
    
    m_showStartTime = Utils::timeInMillisecond();
    
    unschedule(CC_SCHEDULE_SELECTOR(CreateLayer::showFirworks));
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/SimpleShimmer.mp3");
    auto bgOverLay = LayerColor::create(Color4B(30, 30, 30, 255), visibleSize.width, visibleSize.height);
    bgOverLay->setPosition(origin);
    bgOverLay->setTag(BG_OVERLAY_TAG);
    bgOverLay->setOpacity(0);
    
    addChild(bgOverLay, BG_OVERLAY_LAYER);
    
    bgOverLay->runAction(Sequence::create(
                                          FadeIn::create(0.2),
                                          CallFunc::create(std::bind(&CreateLayer::showLights, this)),
                                          NULL));
}

void CreateLayer::endColorChangeShow()
{
    m_colorChanging = false;
    m_hue = 0.0;
    m_actor->setHue(m_hue);
    auto bgOverLay = (LayerColor *)getChildByTag(BG_OVERLAY_TAG);
    if (bgOverLay) {
        bgOverLay->runAction(Sequence::create(
                                              CallFunc::create(std::bind(&CreateLayer::hideLights, this)),
                                              FadeOut::create(0.2),
                                              CallFunc::create(std::bind(&Node::removeFromParent, bgOverLay)),
                                              NULL));
    }
    
    CCLOG("Color show last : %llu", Utils::timeInMillisecond() - m_showStartTime);
}

void CreateLayer::playSparkleSound()
{
    int i = rand() % 6 + 1;
    while(i == m_sparkleSoundId){
        i = rand() % 6 + 1;
    }
    m_sparkleSoundId = i;
    
    std::string soundfile = "sound/stars/xylo_" + std::to_string(m_sparkleSoundId) + ".mp3";
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect(soundfile.c_str());

}

void CreateLayer::showFirworks(float dt)
{
    auto firework = ParticleSystemQuad::create("particles/fireworks.plist");
    firework->setPosition(origin.x + visibleSize.width / 2 + 800 - rand() %1600, origin.y + visibleSize.height / 2 + 250 + rand() % 350);
    addChild(firework, ACTOR_LAYER - 1);
    
    firework->runAction(Sequence::create(
                                  DelayTime::create(6.0),
                                  CallFunc::create(std::bind(&Node::removeFromParent, firework)),
                                  NULL));
}

void CreateLayer::imageLoaded(cocos2d::Texture2D *texture)
{
    // No thing to be done yet.
}