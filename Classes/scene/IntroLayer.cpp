//
//  IntroLayer.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 4/2/15.
//
//

#include "IntroLayer.h"

#include "ui/CocosGUI.h"
#include "WelcomeLayer.h"
#include "Constants.h"
#include "SimpleAudioEngine.h"

USING_NS_CC;
using namespace cocos2d::ui;

Scene* IntroLayer::scene()
{
    auto scene = Scene::create();
    
    auto layer = IntroLayer::create();
    
    scene->addChild(layer);
    
    return scene;
}

bool IntroLayer::init()
{
    //    if ( !LayerColor::initWithColor(Color4B(255, 255, 255, 255)) )
    if ( !BaseLayer::init() )
    {
        return false;
    }
    
    NativeHelper::getInstance()->logFlurryEvent("Time on Intro Video screen", true);
    
    CocosDenshion::SimpleAudioEngine::getInstance()->preloadBackgroundMusic("sound/common/IntroFinalAssetwithextralooping.mp3");

    CCLOG("\nvisibleSize : %f, %f\nscreenSize : %f, %f", visibleSize.width, visibleSize.height, screenSize.width, screenSize.height);
    std::string bgFile = "images/intro/Intro" + std::to_string((int)screenSize.width) + ".png";
    CCLOG("bg : %s", bgFile.c_str());
    auto sprite = Sprite::create(bgFile);
    sprite->setPosition(Vec2(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));
    float scale = visibleSize.height / screenSize.height * Director::getInstance()->getContentScaleFactor();
    sprite->setScale(scale);
    this->addChild(sprite);
    
    return true;
}

bool IntroLayer::onTouchBegan(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    if (m_videoStopped) return true;
    m_videoStopped = true;

    NativeHelper::getInstance()->dismissIntroVideo();
    
    NativeEvent e;
    videoFinished(e);
    
    return true;
}

void IntroLayer::onEnterTransitionDidFinish()
{
    NativeEventListener *listener = new NativeEventListener();
    listener->onEvent = CC_CALLBACK_1(IntroLayer::videoReady, this);
    int listenerId = NativeHelper::getInstance()->addNativeEventListener(listener);
    
    NativeHelper::getInstance()->prepareIntroVideo(listenerId);
}

void IntroLayer::playButtonBlowing(MenuItem *playButton)
{
//    Button *playButton = (Button *)getChildByTag(PLAY_BUTTON_TAG);
    playButton->runAction(RepeatForever::create(Sequence::create(
                                                                 ScaleTo::create(2.0, 1.0 * m_playButtonScale),
                                                                 ScaleTo::create(2.0, 1.2 * m_playButtonScale),
//                                                               DelayTime::create(0.2),
                                                               NULL)));
}

void IntroLayer::menuParentCallback(cocos2d::Ref *sender)
{
    NativeHelper::getInstance()->logFlurryEvent("Taps Parents Section button");
    NativeHelper::getInstance()->showParentSection();
}

void IntroLayer::onExit()
{
    NativeHelper::getInstance()->endFlurryTimedEvent("Time on Intro Video screen");
    CocosDenshion::SimpleAudioEngine::getInstance()->stopBackgroundMusic();
    Layer::onExit();
}

void IntroLayer::menuPlayCallback(cocos2d::Ref *sender)
{
    NativeHelper::getInstance()->logFlurryEvent("Taps Play button");
    auto scene = WelcomeLayer::scene();
    Director::getInstance()->replaceScene(TransitionCrossFade::create(0.5, scene));
}

void IntroLayer::videoReady(NativeEvent e)
{
    NativeEventListener *listener = new NativeEventListener();
    listener->onEvent = CC_CALLBACK_1(IntroLayer::videoFinished, this);
    int listenerId = NativeHelper::getInstance()->addNativeEventListener(listener);
    
    NativeHelper::getInstance()->removeFlickCover();
    
    CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic("sound/common/IntroFinalAssetwithextralooping.mp3", true);
    
    NativeHelper::getInstance()->showIntroVideo(listenerId);
    
    auto touchListener = EventListenerTouchOneByOne::create();
    touchListener->setSwallowTouches(true);
    
    touchListener->onTouchBegan = CC_CALLBACK_2(IntroLayer::onTouchBegan, this);
    
    _eventDispatcher->addEventListenerWithSceneGraphPriority(touchListener, this);
}

void IntroLayer::videoFinished(NativeEvent e)
{
    auto parentItem = MenuItemImage::create("common/grownup0.png", "common/grownup1.png", CC_CALLBACK_1(IntroLayer::menuParentCallback, this));
    parentItem->setAnchorPoint(Point(0.0, 1.0));
    
    float dx = 57;
    float dy = 58;
    if (screenSize.width == 2208) {
        dx += 5;
        dy += 5;
        parentItem->setScale(0.855);
    } else if (screenSize.width == 1334) {
        dx += 2;
        dy += 2;
        parentItem->setScale(1.0);
    } else if (screenSize.width == 1136) {
        dx += 1.0;
        dy += 1.0;
        parentItem->setScale(1.17);
    } else if (screenSize.width == 960) {
        dx += 3;
        dy += 3;
        parentItem->setScale(1.25);
    }
    
    parentItem->setPosition(origin.x + dx, origin.y + visibleSize.height - dy);
    
    m_menu = Menu::create();
    m_menu->addChild(parentItem, 5);
    m_menu->setPosition(Point::ZERO);
    addChild(m_menu, 100);
    
    auto playItem = MenuItemImage::create("common/YayButton.png", "common/YayButton.png", CC_CALLBACK_1(IntroLayer::menuPlayCallback, this));
    
    dx = 706;
    dy = 476;
    m_playButtonScale = 1.0;
    
    if (screenRatio > 1.5) {
        if (screenSize.width == 2208) {
            dx = 620;
        } else if (screenSize.width == 1334) {
            dx = 610;
        } else {
            dx = 630;
        }
        dy = 330;
        m_playButtonScale = 0.9;
    } else if (screenRatio == 1.5) {
        dx = 730;
        dy = 360;
        m_playButtonScale = 0.9;
    }
    
    playItem->setPosition(Point(origin.x + visibleSize.width / 2 + dx, origin.y + visibleSize.height / 2 + dy));
    playItem->setScale(0.9);
    playItem->setTag(PLAY_BUTTON_TAG);
    m_menu->addChild(playItem, 5);
    playItem->runAction(Sequence::create(
                                         ScaleTo::create(0.2, 1.2 * m_playButtonScale),
                                         //                                         ScaleTo::create(0.2, 1.0 * m_playButtonScale),
                                         //                                         ScaleTo::create(0.2, 1.2 * m_playButtonScale),
                                         CallFuncN::create(std::bind(&IntroLayer::playButtonBlowing, this, playItem)),
                                         NULL));
}
