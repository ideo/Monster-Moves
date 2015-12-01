//
//  LoadingLayer.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 4/9/15.
//
//

#include "LoadingLayer.h"

#include "native.h"
#include "GameManager.h"
#include "Constants.h"

USING_NS_CC;
using namespace cocos2d::ui;


LoadingLayer* LoadingLayer::createWithColor(Color4B loadingColor)
{
    LoadingLayer* pRet = new LoadingLayer();
    if (pRet && pRet->initWithColor(loadingColor))
    {
        pRet->autorelease();
        return pRet;
    }
    else
    {
        delete pRet;
        pRet = NULL;
        return NULL;
    }
}

bool LoadingLayer::initWithColor(Color4B loadingColor)
{
    //    if ( !LayerColor::initWithColor(Color4B(255, 255, 255, 255)) )
    if ( !BaseLayer::init() )
    {
        return false;
    }
    
    auto overlay = LayerColor::create(loadingColor);
    overlay->setPosition(Point::ZERO);
    addChild(overlay);

    auto gm = GameManager::getInstance();
    SceneData scene = gm->m_scenes[gm->m_currentSceneIndex];
    
//    float totalWidth = step * (scene.stamps.size() - 1);
    float step = 100;
    float totalWidth = step * 4;
//    int index = 0;
    
    std::set<int> seq;
    while(seq.size() < 5) {
        int n = rand() % 6;
        if (seq.count(n) > 0) {
            continue;
        } else {
            seq.insert(n);
        }
    }
    
    std::set<int>::iterator it;
    int i = 0;
    for(it = seq.begin(); it != seq.end(); it++) {
        auto stamp = Sprite::create("common/s" + std::to_string(*it) + ".png");
        stamp->setTag(LOADING_DOT_TAG + i);
        stamp->setScale(0.7);
        
//        if (++index == scene.stamps.size()) {
//            index = 0;
//        }
        
        stamp->setPosition(visibleSize.width / 2 - totalWidth / 2 + step * i, visibleSize.height / 2);
        
//        stamp->setPosition(visibleSize.width / 2 + totalWidth / 2, visibleSize.height / 2);
//        stamp->setOpacity(0);
        
        m_currentDotIndex = 0;
        
        schedule(CC_SCHEDULE_SELECTOR(LoadingLayer::scaleNextStamp), 0.5);
//        stamp->runAction(Sequence::create(
//                                          DelayTime::create(0.5 * i + 0.6),
//                                          CallFuncN::create(std::bind(&LoadingLayer::scaleStamp, this, stamp)),
//                                          NULL));
        
        addChild(stamp);
        
        i++;
    }
    
    return true;
}

void LoadingLayer::scaleNextStamp(float dt)
{
    m_currentDotIndex++;
    if (m_currentDotIndex > 4) {
        m_currentDotIndex = 0;
    }
    Sprite *stamp = (Sprite *)getChildByTag(LOADING_DOT_TAG + m_currentDotIndex);
    if (stamp) {
        stamp->stopAllActions();
        stamp->runAction(RepeatForever::create(Sequence::create(
                                                                ScaleTo::create(0.2, 1.0),
                                                                DelayTime::create(0.05),
                                                                ScaleTo::create(0.2, 0.7),
                                                                DelayTime::create(0.5 * 4 + 0.05),
                                                                NULL)));
    }
}

void LoadingLayer::scaleStamp(Sprite *stamp)
{
    stamp->stopAllActions();
    stamp->runAction(RepeatForever::create(Sequence::create(
                                                            ScaleTo::create(0.2, 1.0),
                                                            DelayTime::create(0.05),
                                                            ScaleTo::create(0.2, 0.7),
                                                            DelayTime::create(0.5 * 4 + 0.05),
                                                            NULL)));
}

void LoadingLayer::bounceStamp(Sprite *stamp)
{
    stamp->stopAllActions();
    stamp->runAction(RepeatForever::create(Sequence::create(
                                                            MoveBy::create(0.4, Vec2(0, 200)),
                                                            DelayTime::create(0.04),
                                                            MoveBy::create(0.4, Vec2(0, -200)),
                                                            DelayTime::create(2.0),
                                                            NULL)));
}

void LoadingLayer::moveStamp(Sprite *stamp)
{
    stamp->stopAllActions();
    stamp->runAction(RepeatForever::create(Sequence::create(
                                                            Spawn::create(
                                                                          FadeIn::create(1.0),
                                                                          MoveBy::create(1.0, Vec2(-300, 0)),
                                                                          NULL),
                                                            MoveBy::create(2.0, Vec2(-600, 0)),
                                                            Spawn::create(
                                                                          FadeOut::create(1.0),
                                                                          MoveBy::create(1.0, Vec2(-300, 0)),
                                                                          NULL),
                                                            MoveBy::create(0, Vec2(1200, 0)),
                                                            NULL)));
}


bool LoadingLayer::onTouchBegan(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
    return true;
}