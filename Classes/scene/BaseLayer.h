//
//  BaseLayer.h
//  MonsterMove
//
//  Created by Zhou Yang on 4/7/15.
//
//

#ifndef __MonsterMove__BaseLayer__
#define __MonsterMove__BaseLayer__

#include "cocos2d.h"

USING_NS_CC;

class BaseLayer : public Layer
{
    
public:
    
    Size visibleSize;
    Vec2 origin;
    Size screenSize;
    float screenRatio;
    
    float actorScale;
    
    float actorDanceScale;

public:

    virtual bool init();

};

#endif /* defined(__MonsterMove__BaseLayer__) */
