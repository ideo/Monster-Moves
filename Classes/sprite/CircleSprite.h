//
//  CircleSprite.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/21.
//
//

#ifndef __MonsterMove__CircleSprite__
#define __MonsterMove__CircleSprite__

#include "cocos2d.h"
#include "GLSprite.h"

USING_NS_CC;

class CircleSprite : public GLSprite {
public:
    
    virtual bool init(Color4F fc, Color4F sc, float r, float lw);
    
    static CircleSprite* create(Color4F fc, Color4F sc, float r, float lw)
    {
        CircleSprite *pRet = new CircleSprite();
        if (pRet && pRet->init(fc, sc, r, lw))
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
    
    void setRadiaus(float r);

protected:
    
    Color4F m_fillColor;
    Color4F m_strokeColor;
    float m_radius;
    float m_lineWidth;
    
protected:
    
    virtual void onDraw(const Mat4 &transform, uint32_t flags);
    
    
};

#endif /* defined(__MonsterMove__CircleSprite__) */
