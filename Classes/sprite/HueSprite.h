//
//  HueSprite.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/15.
//
//

#ifndef __MonsterMove__HueSprite__
#define __MonsterMove__HueSprite__

#include <stdio.h>
#include "cocos2d.h"

USING_NS_CC;

class HueSprite : public Sprite
{
public:
    
    float m_hue;
    
public:
    
    ~HueSprite() {delete m_shader;};
    
    static HueSprite* create(const std::string& filename);

    static HueSprite* createWithSpriteFrameName(const std::string& spriteFrameName);
    
    static HueSprite* createWithSpriteFrame(SpriteFrame *spriteFrame);
    
//    virtual bool initWithFile(const std::string& filename);

    virtual bool initWithTexture(Texture2D *texture, const Rect& rect, bool rotated);
    
    virtual void setHue(float h);
    
private:
    GLProgram *m_shader;
};

#endif /* defined(__MonsterMove__HueSprite__) */
