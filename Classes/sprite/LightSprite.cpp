//
//  LightSprite.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 4/22/15.
//
//

#include "LightSprite.h"

LightSprite* LightSprite::create(const std::string &lightName)
{
    LightSprite *sprite = new (std::nothrow) LightSprite();
    if (sprite && sprite->initWithLightName(lightName))
    {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

bool LightSprite::initWithLightName(std::string lightName)
{
    if (!Sprite::init()) {
        return false;
    }
    m_name = lightName;
    
    std::string plistFile = "lights/" + lightName + ".plist";
    std::string textureFile = "lights/" + lightName + ".png";
    
    Texture2D *texture = Director::getInstance()->getTextureCache()->addImage(textureFile);
    
    m_actorHolder = SpriteBatchNode::createWithTexture(texture, 1);
    
    auto shader = new GLProgram();
    shader->initWithFilenames("ccPositionTextureColor.vert", "colorAdjust.frag");
    
    m_actorHolder->setGLProgram(shader);
    
    m_actorHolder->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
    m_actorHolder->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
    m_actorHolder->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);
    m_actorHolder->getGLProgram()->link();
    m_actorHolder->getGLProgram()->updateUniforms();
    m_actorHolder->getGLProgram()->setUniformLocationWith1f(m_actorHolder->getGLProgram()->getUniformLocation("hueAdjust"), 0.0);
    m_actorHolder->getGLProgram()->setUniformLocationWith1f(m_actorHolder->getGLProgram()->getUniformLocation("saturateAdjust"), 0.0);
    
    SpriteFrameCache::getInstance()->addSpriteFramesWithFile(plistFile, texture);

    char filename[100];
    sprintf(filename, "%s%04d.png", lightName.c_str(), 0);
    m_actor = Sprite::createWithSpriteFrameName(filename);
    if (getContentSize().width <= m_actor->getContentSize().width || getContentSize().height < m_actor->getContentSize().height) {
        setContentSize(m_actor->getContentSize());
    }
    
    m_actor->setPosition(Point::ZERO);
    
    m_actorHolder->addChild(m_actor);
    
    m_actorHolder->setPosition(Point(getContentSize().width / 2.0, getContentSize().height / 2.0));
    
    addChild(m_actorHolder);
    
    Vector<SpriteFrame *> spriteFrames;
//    char filename[100];
    
    if (m_name == "light") {
        for(int i = 0; i <= 23; i++)
        {
            if (i % 6 == 0) continue;
            sprintf(filename, "%s%04d.png", m_name.c_str(), i % 6);
            auto frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);;
            spriteFrames.pushBack(frame);
        }
        
        for(int i = 6; i <= 20; i++)
        {
            sprintf(filename, "%s%04d.png", m_name.c_str(), i);
            auto frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);;
            spriteFrames.pushBack(frame);
        }
    } else {
        for(int i = 0; i <= 19; i++)
        {
            sprintf(filename, "%s%04d.png", m_name.c_str(), i);
            auto frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);;
            spriteFrames.pushBack(frame);
        }
        
        for(int i = 0; i <= 1; i++)
        {
            sprintf(filename, "%s%04d.png", m_name.c_str(), 20);
            auto frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);;
            spriteFrames.pushBack(frame);
        }
        
    }
    
    auto animation = Animation::createWithSpriteFrames(spriteFrames);
    //    CCLOG("action framerate : %f", action.framerate);
    animation->setDelayPerUnit(1.0 / 15.0);
    
    auto animate = Animate::create(animation);
    
    m_actor->runAction(RepeatForever::create(animate));

    return true;
}

void LightSprite::setHueAndSaturate(float hue, float saturate)
{
    m_actorHolder->getGLProgram()->updateUniforms();
    m_actorHolder->getGLProgram()->setUniformLocationWith1f(m_actorHolder->getGLProgram()->getUniformLocation("hueAdjust"), hue);
    m_actorHolder->getGLProgram()->setUniformLocationWith1f(m_actorHolder->getGLProgram()->getUniformLocation("saturateAdjust"), saturate);
}
