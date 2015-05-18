//
//  HueSprite.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/15.
//
//

#include "HueSprite.h"

HueSprite* HueSprite::create(const std::string& filename)
{
    HueSprite *sprite = new (std::nothrow) HueSprite();
    if (sprite && sprite->initWithFile(filename))
    {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}


HueSprite* HueSprite::createWithSpriteFrameName(const std::string& spriteFrameName)
{
    SpriteFrame *frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(spriteFrameName);
    
#if COCOS2D_DEBUG > 0
    char msg[256] = {0};
    sprintf(msg, "Invalid spriteFrameName: %s", spriteFrameName.c_str());
    CCASSERT(frame != nullptr, msg);
#endif
    
    return createWithSpriteFrame(frame);
}

HueSprite* HueSprite::createWithSpriteFrame(SpriteFrame *spriteFrame)
{
    HueSprite *sprite = new (std::nothrow) HueSprite();
    if (sprite && spriteFrame && sprite->initWithSpriteFrame(spriteFrame))
    {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

bool HueSprite::initWithTexture(cocos2d::Texture2D *texture, const cocos2d::Rect &rect, bool rotated)
{
    if (!Sprite::initWithTexture(texture, rect, rotated))
    {
        return false;
    }
    m_shader = new GLProgram();
    m_shader->initWithFilenames("ccPositionTextureColor_noMVP.vert", "hueAdjust.frag");
    
    setGLProgram(m_shader);
//    getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
//    getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORD);
    getGLProgram()->link();
    getGLProgram()->updateUniforms();
    getGLProgram()->setUniformLocationWith1f(getGLProgram()->getUniformLocation("hueAdjust"), 0.0);
//    getGLProgram()->use();

    return true;
}

//bool HueSprite::initWithFile(const std::string &filename)
//{
//    if (!Sprite::initWithFile(filename))
//    {
//        return false;
//    }
//    
//    m_shader = new GLProgram();
//    m_shader->initWithFilenames("ccPositionTextureColor_noMVP.vert", "hueAdjust.frag");
//
//    setGLProgram(m_shader);
////    getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
////    getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORD);
//    getGLProgram()->link();
//    getGLProgram()->updateUniforms();
//    getGLProgram()->setUniformLocationWith1f(getGLProgram()->getUniformLocation("hueAdjust"), 0.0);
////    getGLProgram()->use();
//    
//    return true;
//}

void HueSprite::setHue(float h)
{
//    CCLOG("setHue : %f", h);
    m_hue = h;
    getGLProgram()->updateUniforms();
    getGLProgram()->setUniformLocationWith1f(getGLProgram()->getUniformLocation("hueAdjust"), h);
}