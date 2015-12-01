//
//  LoadingLayer.h
//  MonsterMove
//
//  Created by Zhou Yang on 4/9/15.
//
//

#ifndef __MonsterMove__LoadingLayer__
#define __MonsterMove__LoadingLayer__

#include "cocos2d.h"
#include "BaseLayer.h"

USING_NS_CC;

class LoadingLayer : public BaseLayer
{
public:
    
    static Scene* scene();
    
    virtual bool initWithColor(Color4B loadingColor);
    
    static LoadingLayer* createWithColor(Color4B loadingColor);

    virtual bool onTouchBegan( Touch *pTouch, Event *pEvent );
    
    void scaleStamp(Sprite *stamp);
    
    void bounceStamp(Sprite *stamp);
    
    void moveStamp(Sprite *stamp);
    
    void scaleNextStamp(float dt);
    
private:
    
    int m_currentDotIndex;

};

#endif /* defined(__MonsterMove__LoadingLayer__) */
