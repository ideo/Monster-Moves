//
//  TileSprite.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/21.
//
//

#include "TileSprite.h"
#include "Constants.h"
#include "GB2ShapeCacheX.h"

TileSprite* TileSprite::create(const std::string& filename)
{
    TileSprite *sprite = new (std::nothrow) TileSprite();
    if (sprite && sprite->initWithFile(filename))
    {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

bool TileSprite::initWithFile(const std::string &filename)
{
    if (!Sprite::initWithFile(filename))
    {
        return false;
    }
    
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    float screenRatio = screenSize.width / screenSize.height;

    scaleAdjust = 1.0;
    
    if (screenRatio < 1.5) {
        scaleAdjust = 1.35;
    } else if (screenSize.width == 960) {
        scaleAdjust = 1.1;
    } else if (screenSize.width <= 1334) {
        scaleAdjust = 1.05;
    }

    m_dropzoneIndex = -1;
//    auto touchListener = EventListenerTouchOneByOne::create();
//    touchListener->setSwallowTouches(true);
//    
//    touchListener->onTouchBegan = CC_CALLBACK_2(TileSprite::onTouchBegan, this);
//    touchListener->onTouchMoved = CC_CALLBACK_2(TileSprite::onTouchMoved, this);
//    touchListener->onTouchEnded = CC_CALLBACK_2(TileSprite::onTouchEnd, this);
//    touchListener->onTouchCancelled = CC_CALLBACK_2(TileSprite::onTouchCancelled, this);
//    
//    _eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener, this);

    scheduleUpdate();
    
    return true;
}

bool TileSprite::onTouchBegan(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    Point point = pTouch->getLocationInView();
    point = Director::getInstance()->convertToUI(point);
    
    m_lastTouchPos = point;
    m_touchOffset = point - getPosition();
    
    if (point.distance(getPosition()) <= getContentSize().width / 2) {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        m_t0 = (unsigned long long)(tv.tv_sec) * 1000 + (unsigned long long)(tv.tv_usec) / 1000;

        return true;
    }
    
    return false;
}

void TileSprite::onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    Point point = pTouch->getLocationInView();
    point = Director::getInstance()->convertToUI(point);

    if (!m_dragging && point != m_lastTouchPos) {
        m_dragging = true;
//        getPhysicsBody()->setVelocity(Vec2::ZERO);
        m_body->SetLinearVelocity(b2Vec2(0,0));
//        m_body->SetUserData(NULL);
    }
    
    struct timeval tv;
    gettimeofday(&tv, NULL);
    m_t1 = (unsigned long long)(tv.tv_sec) * 1000 + (unsigned long long)(tv.tv_usec) / 1000;

    float t = ((double)m_t1 - (double)m_t0) / 500.0;
//    CCLOG("move interval : %llu - %llu = %f", m_t1, m_t0, t);
    if (t <= 0) {
        t = 0.2;
    }
    m_t0 = m_t1;
    m_lastDragSpeed = (point - m_lastTouchPos) / t * 64.0;
    
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();

    Point targetPos = point - m_touchOffset;
    if (targetPos.x < origin.x + getContentSize().width / 2)
    {
        targetPos.x = origin.x + getContentSize().width / 2;
    }
    
    if (targetPos.y < origin.y + getContentSize().height / 2)
    {
        targetPos.y = origin.y + getContentSize().height / 2;
    }
    
    if (targetPos.x > origin.x + visibleSize.width -  + getContentSize().width / 2)
    {
        targetPos.x = origin.x + visibleSize.width -  + getContentSize().width / 2;
    }
    
    if (targetPos.y > origin.y + visibleSize.height -  + getContentSize().height / 2)
    {
        targetPos.y = origin.y + visibleSize.height -  + getContentSize().height / 2;
    }
    
//    setPosition(targetPos);
    m_body->SetTransform(b2Vec2(targetPos.x / PTM_RATIO, targetPos.y / PTM_RATIO), m_body->GetAngle());
    m_lastTouchPos = point;
}

void TileSprite::onTouchEnd(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    if (m_dragging)
    {
        // should not trigger touch event;
//        getPhysicsBody()->setVelocity(m_lastDragSpeed);
        CCLOG("Apply speed: %f, %f", m_lastDragSpeed.x, m_lastDragSpeed.y);
//        m_body->SetUserData(this);
//        m_body->SetTransform(b2Vec2(getPosition().x / PTM_RATIO, getPosition().y / PTM_RATIO), m_body->GetAngle());
        m_body->ApplyForceToCenter(b2Vec2(m_lastDragSpeed.x, m_lastDragSpeed.y), true);
    } else {
        // trigger event here;
        if (m_delegate) {
            m_delegate->tilePressed(this);
        }
    }
    m_dragging = false;
}

void TileSprite::onTouchCancelled(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    m_dragging = false;
}

void TileSprite::detachPhysics(b2World *world)
{
//    CCLOG("detached : %s", m_actionName.c_str());
    if (!m_body) {
        return;
    }
    m_mode = TileModeNormal;
    m_body->SetLinearVelocity(b2Vec2(0,0));
    m_body->SetUserData(NULL);
    world->DestroyBody(m_body);
    m_body = NULL;
}

void TileSprite::attachPhysics(b2World *world)
{
//    CCLOG("attached : %s", m_actionName.c_str());
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(getPosition().x/PTM_RATIO, getPosition().y/PTM_RATIO);
    m_body = world->CreateBody(&bodyDef);
    m_world = world;
    
    b2CircleShape circleBox;
    
    float tileScale = 1.0;
    
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    if (screenSize.width == 960) {
        tileScale *= scaleAdjust;
    }
   
    circleBox.m_radius = (getContentSize().width / 2 * tileScale - 5.0) / PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.95f;
    fixtureDef.filter.categoryBits = FixtureTile;
    fixtureDef.filter.maskBits = FixtureTile | FixtureBorder | FixtureCentralCircle | FixtureDropzone | FixtureButton;
    m_body->CreateFixture(&fixtureDef);
    m_body->SetFixedRotation(true);
    m_body->SetTransform(b2Vec2(getPosition().x / PTM_RATIO, getPosition().y / PTM_RATIO), m_body->GetAngle());
    m_body->SetUserData(this);
}

void TileSprite::attachPhysicsFromCache(b2World *world, std::string shapeName)
{
    //    CCLOG("attached : %s", m_actionName.c_str());
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(getPosition().x/PTM_RATIO, getPosition().y/PTM_RATIO);
    m_body = world->CreateBody(&bodyDef);
    m_world = world;
    
    float tileScale = 1.0;
    
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    if (screenSize.width == 960) {
        tileScale *= scaleAdjust;
    }
    
    GB2ShapeCache::getInstance()->addFixturesToBody(m_body, shapeName);
    setAnchorPoint(GB2ShapeCache::getInstance()->anchorPointForShape(shapeName));

    m_body->SetFixedRotation(true);
    m_body->SetTransform(b2Vec2(getPosition().x / PTM_RATIO, getPosition().y / PTM_RATIO), m_body->GetAngle());
    m_body->SetUserData(this);
}

void TileSprite::attachPhysicsInReenterMode(b2World *world)
{
    //    CCLOG("attached : %s", m_actionName.c_str());
    m_mode = TileModeReenter;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(getPosition().x/PTM_RATIO, getPosition().y/PTM_RATIO);
    m_body = world->CreateBody(&bodyDef);
    m_world = world;
    
    b2CircleShape circleBox;
    
    float tileScale = 1.0;
    
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    if (screenSize.width == 960) {
        tileScale *= scaleAdjust;
    }
    
    circleBox.m_radius = (getContentSize().width / 2 * tileScale - 5.0) / PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleBox;
    fixtureDef.density = 10000.0f;
    fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.95f;
    fixtureDef.filter.categoryBits = FixtureTile;
    fixtureDef.filter.maskBits = FixtureTile | FixtureBorder | FixtureDropzone;
    m_body->CreateFixture(&fixtureDef);
    m_body->SetFixedRotation(true);
    m_body->SetTransform(b2Vec2(getPosition().x / PTM_RATIO, getPosition().y / PTM_RATIO), m_body->GetAngle());
    m_body->SetUserData(this);
}

void TileSprite::setEnterMode()
{
    if (m_body) {
        m_mode = TileModeEnter;
        b2Fixture *fixture = m_body->GetFixtureList();
        b2Filter filter = fixture->GetFilterData();
        filter.maskBits = FixtureTile | FixtureCentralCircle | FixtureDropzone | FixtureButton;
        fixture->SetFilterData(filter);
        fixture->SetDensity(100000000.0);
        m_body->ResetMassData();
    }
}

void TileSprite::removeEnterMode()
{
    if (m_body) {
        m_mode = TileModeNormal;
        b2Fixture *fixture = m_body->GetFixtureList();
        b2Filter filter = fixture->GetFilterData();
        filter.maskBits = FixtureTile | FixtureBorder | FixtureCentralCircle | FixtureDropzone | FixtureButton;
        fixture->SetFilterData(filter);
        fixture->SetDensity(1.0);
        m_body->ResetMassData();
    }
}

void TileSprite::setLeavingMode()
{
    if (m_body) {
        m_mode = TileModeLeaving;
        b2Fixture *fixture = m_body->GetFixtureList();
        b2Filter filter = fixture->GetFilterData();
        filter.maskBits = FixtureTile | FixtureDropzone;
        fixture->SetFilterData(filter);
        fixture->SetDensity(10000.0f);
        m_body->ResetMassData();
    }
}

void TileSprite::setReenterMode()
{
    if (m_body) {
        m_mode = TileModeReenter;
        b2Fixture *fixture = m_body->GetFixtureList();
        b2Filter filter = fixture->GetFilterData();
        filter.maskBits = FixtureTile | FixtureBorder | FixtureDropzone;
        fixture->SetFilterData(filter);
        fixture->SetDensity(10000.0f);
        m_body->ResetMassData();
    }
}

void TileSprite::removeReenterMode()
{
    if (m_body) {
        m_mode = TileModeNormal;
        b2Fixture *fixture = m_body->GetFixtureList();
        b2Filter filter = fixture->GetFilterData();
        filter.maskBits = FixtureTile | FixtureBorder | FixtureCentralCircle | FixtureDropzone | FixtureButton;
        fixture->SetFilterData(filter);
        fixture->SetDensity(1.0f);
        m_body->ResetMassData();
    }
}

void TileSprite::update(float delta)
{
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();

    if (m_mode == TileModeEnter) {
        if (getPosition().x > origin.x - WALL_OFFSET_X + getContentSize().width / 2 &&
            getPosition().x < origin.x + visibleSize.width + WALL_OFFSET_X - getContentSize().width / 2) {
            removeEnterMode();
            
            CCLOG("New tile enter completed!");
        }
    }
    
    if (m_mode == TileModeLeaving) {
        Rect r = Rect(origin.x - getContentSize().width / 2,
                      origin.y - getContentSize().height / 2,
                      visibleSize.width + getContentSize().width,
                      visibleSize.height + getContentSize().height);
        if (!r.containsPoint(getPosition())) {
            detachPhysics(m_world);
            removeFromParent();
            CCLOG("Old tile disappeared!");
        }
    }
}

TileSprite::~TileSprite()
{
    if (m_body) {
        m_body->SetUserData(NULL);
        m_body = NULL;
    }
}