//
//  BaseLayer.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 4/7/15.
//
//

#include "BaseLayer.h"
#include "Constants.h"

bool BaseLayer::init()
{
    if (!Layer::init()) {
        return false;
    }

    visibleSize = Director::getInstance()->getVisibleSize();
    origin = Director::getInstance()->getVisibleOrigin();
    screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    screenRatio = screenSize.width / screenSize.height;
    
    actorScale = ACTOR_SCALE;
    actorDanceScale = ACTOR_DANCE_SCALE;
    if (screenRatio < 1.5) {
        //iPad
        actorScale *= 1.15;
        actorDanceScale *= 1.15;
    }
    
    if (screenSize.width <= 1024.0) {
        actorScale *= LOW_RES_SCALE_ADJUST;
        actorDanceScale *= LOW_RES_SCALE_ADJUST;
    }

    return true;
}
