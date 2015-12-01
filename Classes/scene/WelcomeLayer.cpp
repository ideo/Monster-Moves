//
//  WelcomeLayer.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/20.
//
//

#include "WelcomeLayer.h"

#include "HueSprite.h"
#include "JsonSprite.h"
#include "Constants.h"
#include "CreateLayer.h"
#include "GameManager.h"
#include "SimpleAudioEngine.h"
#include "native.h"
#include "ui/CocosGUI.h"
#include "FadeParticleSystem.h"
#include <vector>
#include "LoadingLayer.h"

USING_NS_CC;
using namespace cocos2d::ui;

Scene* WelcomeLayer::scene()
{
    auto scene = Scene::create();
    
    auto layer = WelcomeLayer::create();
    
    scene->addChild(layer);
    
    return scene;
}

bool WelcomeLayer::init()
{
//    if ( !LayerColor::initWithColor(Color4B(255, 255, 255, 255)) )
    if ( !BaseLayer::init() )
    {
        return false;
    }
    
    NativeHelper::getInstance()->logFlurryEvent("Time on Select Screen", true);
    
    auto gm = GameManager::getInstance();
    
    m_isNewGame = false;
    

    if (GameManager::getInstance()->m_firstStart) {
        GameManager::getInstance()->m_firstStart = false;
        gm->randomSelectActors();
        m_isNewGame = true;
    }
    
    gm->m_currentActorIndex = -1;
    
    showLoadingUI();
    
    return true;
}

void WelcomeLayer::showLoadingUI()
{
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    auto loadingLayer = LoadingLayer::createWithColor(scene.loadingColor);
    loadingLayer->setPosition(origin);
    loadingLayer->setTag(LOADING_TAG);
    addChild(loadingLayer, LOADING_LAYER);

}

void WelcomeLayer::addBackground(bool visible)
{
//    CCLOG("\nvisibleSize : %f, %f\nscreenSize : %f, %f", visibleSize.width, visibleSize.height, screenSize.width, screenSize.height);

    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];

    std::string bgFile = "images/bg/" + scene.bg + std::to_string((int)screenSize.width) + ".png";
//    CCLOG("bg : %s", bgFile.c_str());
    auto sprite = Sprite::create(bgFile);
    sprite->setPosition(Vec2(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));
    float scale = visibleSize.height / screenSize.height * Director::getInstance()->getContentScaleFactor();
    sprite->setScale(scale);
    sprite->setTag(BG_TAG);
    sprite->setVisible(visible);
    this->addChild(sprite, BACKGROUND_LAYER);
}

void WelcomeLayer::onEnterTransitionDidFinish()
{
    SpriteFrameCache::getInstance()->removeUnusedSpriteFrames();
    Director::getInstance()->getTextureCache()->removeUnusedTextures();
    
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    m_preloadingAmount = 0;
    m_preloadCount = 0;
    m_sequenceReadyCount = 0;
    
    m_eggCrackSoundId = -1;
    m_stampSoundId = -1;
    
    addBackground(true);
    
    for (int i = 0; i < 3; i++) {
        std::string file = "config/select/" + gm->m_currentActors[i].name + ".json";
        JsonSprite *actor;
        
        if (m_isNewGame) {
            actor = JsonSprite::create(file);
        } else if (gm->m_currentActors[i].isSequenceReady) {
            m_sequenceReadyCount++;
            actor = JsonSprite::create(file, "idle0");
        } else {
            if (gm->m_currentActors[i].lastActionName.empty()) {
                gm->m_currentActors[i].lastActionName = "eggIdle";
            }
            
            if (gm->m_currentActors[i].lastActionName != "eggIdle")
            {
                m_preloadingAmount--;
            }
            
            actor = JsonSprite::create(file, gm->m_currentActors[i].lastActionName);
            
        }
        
        actor->m_delegate = this;
        
        if (m_isNewGame) {
            actor->setPosition(Point(origin.x + visibleSize.width / 2,
                                     origin.y + visibleSize.height / 2 + EGG_LANDING_INIT_Y));
        } else {
            actor->setPosition(Point(origin.x + visibleSize.width / 2 + EGG_LANDING_OFFX * (i - 1),
                                     origin.y + EGG_LANDING_Y + actor->m_feetOffset * ACTOR_SCALE)
                               + scene.offsets[i]);
        }
        
        actor->setTag(ACTOR_TAG_BASE + i);
        actor->setScale(actorScale);
        
        if (m_isNewGame) {
            actor->setVisible(false);
        }
        
        if (gm->m_currentActors[i].isSequenceReady) {
            gm->m_currentActors[i].currentSequenceIndex = 0;
            std::vector<std::string> actions;
            for(int j = 0; j < 4; j++) {
//                CCLOG("Try preload %s", gm->m_currentActors[i].sequence[j].c_str());
                if (std::find(actions.begin(), actions.end(), gm->m_currentActors[i].sequence[j]) == actions.end())
                {
                    m_preloadingAmount++;
                    CCLOG("To be preloaded : %s", gm->m_currentActors[i].sequence[j].c_str());
                    actions.push_back(gm->m_currentActors[i].sequence[j]);
                }
            }
            m_preloadingAmount++;
            actions.push_back("exit");
            actor->preloadActions(actions);
        } else {
            m_preloadingAmount += 4;
            actor->preloadActions({"eggCrack0", "eggCrack1", "crackEntrance", "idle"});
        }
        
        addChild(actor, ACTOR_LAYER);
    }
    
    if (m_isNewGame || m_sequenceReadyCount <= 0) {
        CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.selectBeats.c_str(), true);
    }
    
    if (m_sequenceReadyCount >= 3) {
        addSuccessParticles();
    }
}

void WelcomeLayer::actionPreloaded(std::string actionName)
{
    m_preloadCount++;
//    CCLOG("Action %s preloaded: %d, %d", actionName.c_str(), m_preloadingAmount, m_preloadCount);
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    if (m_preloadCount >= m_preloadingAmount) {
//        CCLOG("Loading completed!");
        LoadingLayer *loadingLayer = (LoadingLayer *)getChildByTag(LOADING_TAG);
        if (loadingLayer) {
            loadingLayer->runAction(Sequence::create(
                                                     FadeOut::create(0.7),
                                                     CallFunc::create(std::bind(&Node::removeFromParent, loadingLayer)),
                                                     NULL));
        }
        if (m_isNewGame) {
            m_isNewGame = false;
            runAction(Sequence::create(
                                       DelayTime::create(0.7),
                                       CallFunc::create(std::bind(&WelcomeLayer::spaceshipFlyInAndDropEggs, this)),
                                       NULL));
        } else {
            
            for (int i = 0; i < 3; i++) {
                JsonSprite* actor = (JsonSprite*)getChildByTag(i + 100);
                std::string actionName;
                if (gm->m_currentActors[i].isSequenceReady) {
                    actionName = gm->m_currentActors[i].sequence[0];
                    m_paceControler = actor;
                } else {
                    // play last action
                    actionName = gm->m_currentActors[i].lastActionName;
                    actor->runAction(Sequence::create(
                                                      DelayTime::create(0.7),
                                                      CallFuncN::create(std::bind(&JsonSprite::playAction, actor, actionName)),
                                                      NULL));
                }
            }
            if (m_sequenceReadyCount >= 3) {
//                addSuccessParticles();
                
                spaceshipFloat();
                m_spaceshipTouchable = true;
            }
            
            if (m_paceControler) {
                m_pace = 0;
                runAction(Sequence::create(
                                           DelayTime::create(0.7),
                                           CallFunc::create(std::bind(&WelcomeLayer::startGroupDancing, this)),
                                           NULL));
            }
            
            m_eggReady = true;
        }
        
        auto firebugs = FadeParticleSystem::create("particles/Firebugs.plist");
        firebugs->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 - 300);
        firebugs->setBlendFunc(BlendFunc::ALPHA_PREMULTIPLIED);
        firebugs->setTag(FIREBUG_TAG);
        firebugs->m_fadeOutTime = 0.2;
        firebugs->m_scaleDownTime = 0.2;
        
        if (scene.bg == "Space" || scene.bg == "Ocean" || scene.bg == "Jungle") {
            firebugs->setStartColor(Color4F(1.0, 1.0, 1.0, 1.0));
            firebugs->setEndColor(Color4F(1.0, 1.0, 1.0, 1.0));
        } else {
            firebugs->setStartColor(Color4F(0.957, 0.976, 0.302, 1.0));
            firebugs->setEndColor(Color4F(0.957, 0.976, 0.302, 1.0));
        }
        addChild(firebugs, PARTICLE_LAYER);
        
        auto touchListener = EventListenerTouchOneByOne::create();
        touchListener->setSwallowTouches(true);
        
        touchListener->onTouchBegan = CC_CALLBACK_2(WelcomeLayer::onTouchBegan, this);
        touchListener->onTouchMoved = CC_CALLBACK_2(WelcomeLayer::onTouchMoved, this);
        touchListener->onTouchEnded = CC_CALLBACK_2(WelcomeLayer::onTouchEnded, this);
        
        _eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener, this);
        
    }
}

void WelcomeLayer::spaceshipFlyInAndDropEggs()
{
    auto spaceship = Sprite::create("Spaceship.png");
    spaceship->setPosition(origin.x + 150, origin.y + visibleSize.height - 200);
    spaceship->setScale(0.3);
    spaceship->setTag(SPACESHIP_TAG);
    addChild(spaceship, SPACESHIP_LAYER);
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/FlyInAndDrop.mp3");
    
    spaceship->runAction(Sequence::create(
                                          Spawn::create(
                                                        ScaleTo::create(0.3, 1.0),
                                                        MoveTo::create(0.6, Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 + 380)),
                                                        RotateTo::create(0.6, 20),
                                                        NULL),
                                          RotateBy::create(0.2, -20),
//                                          RotateBy::create(0.1, 5.0),
                                          CallFunc::create(std::bind(&WelcomeLayer::dropEggs, this)),
                                          Spawn::create(
                                                        MoveBy::create(1.5, Point(0, -60)),
//                                                        RotateBy::create(1.0, -3.0),
                                                        NULL),
                                          Spawn::create(
                                                        RotateBy::create(0.6, 53),
                                                        MoveBy::create(1.0, Point(origin.x + visibleSize.width + 300, origin.y + visibleSize.height + 200)),
                                                        ScaleTo::create(1.0, 0.2),
                                                        NULL),
                                          CallFunc::create(std::bind(&Node::removeFromParent, spaceship)),
                                          NULL));
}

void WelcomeLayer::spaceshipFloat()
{
    auto spaceship = Sprite::create("Spaceship.png");
    spaceship->setPosition(origin.x + 180, origin.y + visibleSize.height - 150);
    spaceship->setScale(0.3);
    spaceship->setTag(SPACESHIP_TAG);
    addChild(spaceship, SPACESHIP_LAYER);
    
    spaceship->runAction(RepeatForever::create(
                                               Sequence::create(
                                                                Spawn::create(
                                                                              RotateTo::create(0.9, 5.0),
                                                                              MoveBy::create(1.0, Point(0, -30)),
                                                                              NULL),
                                                                Spawn::create(
                                                                              RotateTo::create(2.0, 1.0),
                                                                              MoveBy::create(2.0, Point(0, -70)),
                                                                              NULL),
                                                                MoveBy::create(0.5, Point(0, -7.0)),
                                                                Spawn::create(
                                                                              RotateTo::create(0.5, -1.0),
                                                                              MoveBy::create(0.5, Point(0, 10)),
                                                                              NULL),
                                                                Spawn::create(
                                                                              RotateTo::create(1.0, 1.0),
                                                                              MoveBy::create(1.0, Point(0, 40)),
                                                                              NULL),
                                                                Spawn::create(
                                                                              RotateTo::create(1.0, 0.0),
                                                                              MoveBy::create(1.5, Point(0, 50)),
                                                                              NULL),
                                                                MoveBy::create(0.5, Point(0, 7.0)),
                                                                NULL)
                                               ));
    m_spaceshipTouchable = true;
}

void WelcomeLayer::spaceshipFlyInAndTakeAwayEggs()
{
    auto spaceship = getChildByTag(SPACESHIP_TAG);
    if (spaceship) {
        CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/FlyAway.mp3");

        spaceship->runAction(Sequence::create(
                                              Spawn::create(
                                                            ScaleTo::create(0.3, 1.0),
                                                            MoveTo::create(0.6, Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 + 380)),
                                                            RotateTo::create(0.6, 20),
                                                            NULL),
                                              RotateBy::create(0.2, -20),
//                                              RotateBy::create(0.1, 5),
                                              CallFunc::create(std::bind(&WelcomeLayer::takeAwayEggs, this)),
                                              Spawn::create(
                                                            MoveBy::create(1.5, Point(0, -60)),
//                                                            RotateBy::create(1.0, -3.0),
                                                            NULL),
                                              Spawn::create(
                                                            RotateBy::create(0.6, 53),
                                                            MoveBy::create(1.0, Point(origin.x + visibleSize.width + 300, origin.y + visibleSize.height + 200)),
//                                                            ScaleTo::create(1.0, 0.3),
                                                            NULL),
//                                              CallFunc::create(std::bind(&WelcomeLayer::startNewGame, this)),
                                              NULL));
    }
}

void WelcomeLayer::dropEggs()
{
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    JsonSprite* actor = (JsonSprite*)getChildByTag(ACTOR_TAG_BASE);
    actor->runAction(Sequence::create(
                                      DelayTime::create(0.6),
                                      Show::create(),
                                      Spawn::create(
                                                    ScaleTo::create(0.5, actorScale),
                                                    MoveTo::create(0.5, Point(origin.x + visibleSize.width / 2 - EGG_LANDING_OFFX, origin.y + EGG_LANDING_Y + actor->m_feetOffset * ACTOR_SCALE) + scene.offsets[0]),
                                                    NULL),
                                      NULL));
    
    actor = (JsonSprite*)getChildByTag(ACTOR_TAG_BASE + 1);
    actor->runAction(Sequence::create(
                                      DelayTime::create(0.6),
                                      Show::create(),
                                      Spawn::create(
                                                    ScaleTo::create(0.5, actorScale),
                                                    MoveTo::create(0.5, Point(origin.x + visibleSize.width / 2, origin.y + EGG_LANDING_Y + actor->m_feetOffset * ACTOR_SCALE) + scene.offsets[1]),
                                                    NULL),
                                      NULL));
    
    
    actor = (JsonSprite*)getChildByTag(ACTOR_TAG_BASE + 2);
    actor->runAction(Sequence::create(
                                      DelayTime::create(0.6),
                                      Show::create(),
                                      Spawn::create(
                                                    ScaleTo::create(0.5, actorScale),
                                                    MoveTo::create(0.5, Point(origin.x + visibleSize.width / 2 + EGG_LANDING_OFFX, origin.y + EGG_LANDING_Y + actor->m_feetOffset * ACTOR_SCALE) + scene.offsets[2]),
                                                    NULL),
                                      CallFunc::create(std::bind(&WelcomeLayer::eggsReady, this)),
                                      NULL));
    
//    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/Hooray_2.mp3");

}

void WelcomeLayer::takeAwayEggs()
{
    m_isPlaying = false;
    unschedule(CC_SCHEDULE_SELECTOR(WelcomeLayer::playNextDance));

    for(int i = 0; i <= 3; i++) {
        JsonSprite* actor = (JsonSprite*)getChildByTag(ACTOR_TAG_BASE + i);
        if (actor) {
            actor->stopPerform();
            actor->runAction(Sequence::create(
                                              DelayTime::create(0.2),
                                              Spawn::create(
                                                            RotateBy::create(0.2, - 20.0 * (i - 1)),
                                                            CallFuncN::create(std::bind(&JsonSprite::playAction, actor, "exit")),
                                                            MoveTo::create(0.5, Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 + EGG_LANDING_INIT_Y)),
                                                            ScaleTo::create(0.5, 0.5),
                                                            NULL),
                                              CallFuncN::create(std::bind(&JsonSprite::clearAssets, actor, false)),
                                              CallFunc::create(std::bind(&Node::removeFromParent, actor)),
                                           NULL));
        }
    }
}

void WelcomeLayer::eggsReady()
{
    for(int i = 0; i <= 3; i++) {
        JsonSprite* actor = (JsonSprite*)getChildByTag(i + 100);
        if (actor) {
            actor->runAction(Sequence::create(
                                               DelayTime::create(3 + i + rand() % 6),
                                               CallFuncN::create(std::bind(&JsonSprite::playAction, actor, "eggIdle")),
                                               NULL));
        }
    }
    m_eggReady = true;
}

bool WelcomeLayer::onTouchBegan(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    Point point = pTouch->getLocationInView();
    point = Director::getInstance()->convertToUI(point);
    
    m_lastTouchPos = point;
    
//    CCLOG("x = %f, y = %f", point.x, point.y);
    
    if (m_spaceshipTouchable) {
        Sprite* spaceship = (Sprite*)getChildByTag(SPACESHIP_TAG);
        float s = spaceship->getScale();
        if (spaceship && Rect(spaceship->getPosition().x - spaceship->getContentSize().width * s / 2,
                              spaceship->getPosition().y - spaceship->getContentSize().height * s / 2,
                              spaceship->getContentSize().width * s,
                              spaceship->getContentSize().height * s).containsPoint(point))
        {
            CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/TileTap1.mp3");

            m_spaceshipTouchable = false;
            prepareNewGame();
            NativeHelper::getInstance()->logFlurryEvent("Taps Spaceship");
            return true;
        }
    }
    
    auto gm = GameManager::getInstance();
    auto scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    if (m_eggReady) {
        
        std::string positions[3] = {"Left", "Middle", "Right"};
        
        for(int i = 0; i <= 3; i++) {
            JsonSprite* actor = (JsonSprite*)getChildByTag(ACTOR_TAG_BASE + i);
            
            
            if (actor && actor->getTouchAreaInParent().containsPoint(point)) {
//                auto touchAreaLayer = LayerColor::create(Color4B(0, 128, 255, 120),  actor->getTouchAreaInParent().size.width, actor->getTouchAreaInParent().size.height);
//                touchAreaLayer->setPosition(actor->getTouchAreaInParent().origin);
//                addChild(touchAreaLayer, 10000);
//                touchAreaLayer->runAction(Sequence::create(DelayTime::create(1.0),
//                                                      FadeOut::create(0.3),
//                                                      CallFunc::create(std::bind(&Node::removeFromParent, touchAreaLayer)),
//                                                      NULL));
                
                if (actor->m_currentActionName.empty() || actor->m_currentActionName == "eggIdle") {
                    actor->stopAllActions();
                    playEggCrackSound();
                    actor->playAction("eggCrack0");
                    actor->clearAction("eggIdle", false);
                    return true;
                } else if (actor->m_currentActionName == "eggCrack0") {
                    actor->stopAllActions();
                    playEggCrackSound();
                    actor->playAction("eggCrack1");
                    actor->clearAction("eggCrack0", false);
                    return true;
                } else if (actor->m_currentActionName == "eggCrack1") {
                    actor->stopAllActions();
//                    playMonsterPopSound();
                    actor->playAction("crackEntrance");
                    actor->clearAction("eggCrack1", false);
                    NativeHelper::getInstance()->logFlurryEvent("Cracks " + positions[i] + " Egg");
                    return true;
//                } else if (actor->m_currentActionName == "idle") {
                } else {
//                    CCLOG("selected monster : %d", i);
//                    return true;
                    m_eggReady = false;
                    m_isPlaying = false;

                    unschedule(CC_SCHEDULE_SELECTOR(WelcomeLayer::playNextDance));
                    
                    for(int j = 0; j < 3; j++) {
                        JsonSprite* a = (JsonSprite*)getChildByTag(ACTOR_TAG_BASE + j);
                        if (gm->m_currentActors[j].isSequenceReady) {
                            a->playAction("idle0");
                        } else if (j != i) {
                            if (a->m_currentActionName == "crackEntrance") {
                                gm->m_currentActors[j].lastActionName = "idle";
                            } else {
                                gm->m_currentActors[j].lastActionName = a->m_currentActionName;
                            }
                        }
                        
                        
                        a->stopPerform();
                        a->clearAssets(false);
                    }
                    
                    gm->m_currentActors[i].lastActionName = "idle";

                    removeSuccessParticles();
                    
                    FadeParticleSystem *firebug = (FadeParticleSystem*)getChildByTag(FIREBUG_TAG);
                    if (firebug) {
                        firebug->removeFromParent();
                    }
                    
                    Sprite *oldBg = (Sprite *)getChildByTag(BG_TAG);
                    if (oldBg) {
                        oldBg->removeFromParent();
                        std::string bgFile = "images/bg/" + scene.bg + std::to_string((int)screenSize.width) + ".png";
                        Director::getInstance()->getTextureCache()->removeTextureForKey(bgFile);
                        CCLOG("removed old bg");
                    }
                    
                    CocosDenshion::SimpleAudioEngine::getInstance()->stopAllEffects();
                    
//                    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect("sound/common/grunt.mp3");
                    
                    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect(actor->m_selectedEffect.c_str());
                    
                    CocosDenshion::SimpleAudioEngine::getInstance()->stopBackgroundMusic();
                    
                    NativeHelper::getInstance()->logFlurryEvent("Taps Monster to go to Create Screen", "Type of Monster", gm->m_currentActors[i].name);
                    
                    gm->m_currentActorIndex = i;
                    auto scene = CreateLayer::scene();
                    Director::getInstance()->replaceScene(TransitionCrossFade::create(0.5, scene));
                    return true;
                }
            }
        }
    }

    addStamp(point);
    
    std::unordered_map<std::string, FlurryParemeter> parameters;
    parameters["Type of Scene"] = NativeHelper::getInstance()->getFlurryStringParameter(scene.bg);
    parameters["Type of Sticker"] = NativeHelper::getInstance()->getFlurryStringParameter(scene.stamps[scene.stampIndex]);
    
    NativeHelper::getInstance()->logFlurryEvent("Taps Background to add Sticker", parameters);
    
    parameters.clear();
    
    m_starFreq = 1;
    
    m_dragEnabled = true;
    
    return true;
}

void WelcomeLayer::onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    Point point = pTouch->getLocationInView();
    point = Director::getInstance()->convertToUI(point);
    
    if (m_dragEnabled && !m_dragging && point != m_lastTouchPos)
    {
        m_dragging = true;
    }
    
    if (m_dragging) {
        
        if (m_starFreq % 6 == 0) {
            addStamp(point);
        } else {
        }
        m_starFreq++;
    }
}

void WelcomeLayer::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
    m_dragging = false;
    m_dragEnabled = false;
    m_starFreq = 0;
}

void WelcomeLayer::actionStopped(JsonSprite *actor)
{
//    actor->stopAllActions();
    int index = actor->getTag() - ACTOR_TAG_BASE;
    
    GameManager *gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    if (actor == m_paceControler) {
//        // use m_paceController to control all dance, make them sync.
//        playNextDance(0);
    } else if (!gm->m_currentActors[index].isSequenceReady) {
        if (actor->m_currentActionName == "eggIdle") {
            actor->runAction(Sequence::create(
                                              DelayTime::create(5 + rand() % 4),
                                              CallFuncN::create(std::bind(&JsonSprite::playAction, actor, "eggIdle")),
                                              NULL));
        } else if (actor->m_currentActionName == "crackEntrance") {
            actor->playAction("idle");
        }
    }
    if (gm->m_currentActors[index].isSequenceReady) {
        
    }
}

void WelcomeLayer::prepareNewGame()
{
    auto p = ParticleSystemQuad::create("particles/sunBurn.plist");
    p->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height + 200);
    p->setTag(SUN_TAG);
    addChild(p, PARTICLE_LAYER);
    
    spaceshipFlyInAndTakeAwayEggs();
    
    runAction(Sequence::create(
                               DelayTime::create(3.5),
                               CallFunc::create(std::bind(&WelcomeLayer::setupNewGameScene, this)),
                               NULL));
    
    
}

void WelcomeLayer::setupNewGameScene()
{
    // If current bg exists, then remove it.
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];

    FadeParticleSystem *firebug = (FadeParticleSystem*)getChildByTag(FIREBUG_TAG);
    if (firebug) {
        firebug->removeFromParent();
    }
    
    Sprite *oldBg = (Sprite *)getChildByTag(BG_TAG);
    if (oldBg) {
        oldBg->removeFromParent();
        std::string bgFile = "images/bg/" + scene.bg + std::to_string((int)screenSize.width) + ".png";
        Director::getInstance()->getTextureCache()->removeTextureForKey(bgFile);
        CCLOG("removed old bg");
    }
    
    removeSuccessParticles();

    gm->randomSelectActors();
    scene = gm->m_scenes[gm->m_currentSceneIndex];
    
//    addBackground(false);
//    Sprite *sprite = (Sprite *)getChildByTag(BG_TAG);
//    sprite->runAction(Sequence::create(
//                                       DelayTime::create(0.7),
//                                       Show::create(),
//                                       NULL));
    
    ParticleSystemQuad *sun = (ParticleSystemQuad*)getChildByTag(SUN_TAG);

    auto overlay = LayerColor::create(Color4B(0, 0, 0, 255), visibleSize.width, visibleSize.height);
    overlay->setOpacity(0);
    overlay->setPosition(origin);
    addChild(overlay, OVERLAY_LAYER);
    
    m_isNewGame = true;
    
    overlay->runAction(Sequence::create(
                                        FadeIn::create(0.7),
                                        CallFunc::create(std::bind(&Node::removeFromParent, sun)),
                                        DelayTime::create(0.2),
                                        FadeOut::create(0.7),
                                        CallFunc::create(std::bind(&WelcomeLayer::showLoadingUI, this)),
                                        CallFunc::create(std::bind(&WelcomeLayer::onEnterTransitionDidFinish, this)),
                                        NULL));
    
}

void WelcomeLayer::addSuccessParticles()
{
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
    for(int j = 0; j < scene.successParticles.size(); j++) {
        auto successParticles = FadeParticleSystem::create("particles/" + scene.successParticles[j].file);
        successParticles->setPosition(origin.x + visibleSize.width / 2,
                                      origin.y + visibleSize.height * scene.successParticles[j].topPos + scene.successParticles[j].offsetY);
        
        successParticles->m_scaleUpTime = scene.successParticles[j].scaleUpTime;
        successParticles->m_scaleDownTime = scene.successParticles[j].scaleDownTime;
        successParticles->m_fadeInTime = scene.successParticles[j].fadeInTime;
        successParticles->m_fadeOutTime = scene.successParticles[j].fadeOutTime;
        
        if (!scene.successParticles[j].particleFile.empty()) {
            successParticles->setTexture(Director::getInstance()->getTextureCache()->addImage("particles/" + scene.successParticles[j].particleFile));
        }
        
        // TODO : More configuration to remove following hardcode.
        if (scene.successParticles[j].shouldAdjustTime) {
            float l = successParticles->getLife();
            if (screenRatio > 1.5) {
                l -= 0.75;
            } else if (screenRatio > 1.4) {
                l -= 0.45;
            }
            successParticles->setLife(l);
        }
        
        successParticles->setTotalParticles(successParticles->getTotalParticles() / scene.successParticles.size());
        
        successParticles->setBlendFunc(BlendFunc::ALPHA_PREMULTIPLIED);
        successParticles->setTag(SUCCESS_PARTICLE_TAG + j);
        addChild(successParticles, PARTICLE_LAYER);
    }
}

void WelcomeLayer::removeSuccessParticles()
{
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    for(int j = 0; j < scene.successParticles.size(); j++) {
        ParticleSystemQuad *successParticles = (ParticleSystemQuad*)getChildByTag(SUCCESS_PARTICLE_TAG + j);
        if (successParticles) {
            successParticles->removeFromParent();
        }
    }

}

void WelcomeLayer::onExit()
{
    NativeHelper::getInstance()->endFlurryTimedEvent("Time on Select Screen");
    Layer::onExit();
}

void WelcomeLayer::playEggCrackSound()
{
    int i = rand() % 3 + 1;
    while(i == m_eggCrackSoundId){
        i = rand() % 3 + 1;
    }
    m_eggCrackSoundId = i;
    
    std::string soundfile = "sound/common/EggCrack_" + std::to_string(m_eggCrackSoundId) + ".mp3";
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect(soundfile.c_str());
}

void WelcomeLayer::rewindBackgroundMusic()
{
//    CocosDenshion::SimpleAudioEngine::getInstance()->rewindBackgroundMusic();

    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    if (m_sequenceReadyCount < 3) {
        CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.playBeats.c_str(), true);
    } else {
        CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.allBeats.c_str(), true);
    }

}


void WelcomeLayer::playStampSound()
{
    int i = rand() % 3 + 1;
    while(i == m_stampSoundId){
        i = rand() % 3 + 1;
    }
    m_stampSoundId = i;
    
    std::string soundfile = "sound/common/Tap" + std::to_string(m_stampSoundId) + ".wav";
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playEffect(soundfile.c_str());
}

void WelcomeLayer::startGroupDancing()
{
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];

    if (m_sequenceReadyCount < 3) {
        CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.playBeats.c_str(), true);
    } else {
        CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(scene.allBeats.c_str(), true);
    }
    
    for (int i = 0; i < 3; i++) {
        JsonSprite* actor = (JsonSprite*)getChildByTag(i + 100);
        std::string actionName;
        if (gm->m_currentActors[i].isSequenceReady) {
            actionName = gm->m_currentActors[i].sequence[0];
            m_paceControler = actor;
        
            actor->runAction(Sequence::create(
                                              DelayTime::create(0.7),
                                              CallFuncN::create(std::bind(&JsonSprite::playAction, actor, actionName)),
                                              NULL));
        }
    }
    m_isPlaying = true;
    schedule(CC_SCHEDULE_SELECTOR(WelcomeLayer::playNextDance), PACE_TIME);

}

void WelcomeLayer::playNextDance(float dt)
{
    if (!m_isPlaying) return;
    
    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    // use m_paceController to control all dance, make them sync.
    m_pace++;
    
    if (m_pace > scene.beatCount - 1) {
        m_pace = 0;
        rewindBackgroundMusic();
    }
    for (int i = 0; i < 3; i++) {
        JsonSprite* actorForPlay = (JsonSprite*)getChildByTag(i + 100);
        if (gm->m_currentActors[i].isSequenceReady) {
            gm->m_currentActors[i].currentSequenceIndex++;
            if (gm->m_currentActors[i].currentSequenceIndex > 3) {
                gm->m_currentActors[i].currentSequenceIndex = 0;
            }
            actorForPlay->playAction(gm->m_currentActors[i].sequence[gm->m_currentActors[i].currentSequenceIndex]);
        }
    }
}

void WelcomeLayer::addStamp(Point point)
{
    auto gm = GameManager::getInstance();
    auto scene = gm->m_scenes[gm->m_currentSceneIndex];

    auto stamp = Sprite::create("stamp/" + scene.stamps[scene.stampIndex]);
    stamp->setPosition(point);
    addChild(stamp, STAMP_LAYER);
    
    playStampSound();
    
    stamp->setRotation(rand() % 360);
    
    stamp->setScale((125.0 - rand() % 51) / 100.0);
    
    stamp->runAction(Sequence::create(
                                      DelayTime::create(1.0),
                                      FadeOut::create(1.0),
                                      CallFunc::create(std::bind(&Node::removeFromParent, stamp)),
                                      NULL));

}
