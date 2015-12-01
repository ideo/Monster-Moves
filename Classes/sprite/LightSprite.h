//
//  LightSprite.h
//  MonsterMove
//
//  Created by Zhou Yang on 4/22/15.
//
//

#ifndef __MonsterMove__LightSprite__
#define __MonsterMove__LightSprite__

#include "cocos2d.h"

USING_NS_CC;

class LightSprite : public Sprite
{
public:
    
    float m_hue;
    
    std::string m_name;
    
    Sprite *m_actor;
    
    SpriteBatchNode *m_actorHolder;
    
public:
    
    static LightSprite* create(const std::string& lightName);

    bool initWithLightName(std::string lightName);
    
    void setHueAndSaturate(float hue, float saturate);
    
};
#endif /* defined(__MonsterMove__LightSprite__) */
