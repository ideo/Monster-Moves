//
//  DropzoneSprite.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/29.
//
//

#include "DropzoneSprite.h"
#include "Constants.h"
#include "native.h"
#include "GameManager.h"

DropzoneSprite* DropzoneSprite::create(const std::string& filename)
{
    DropzoneSprite *sprite = new (std::nothrow) DropzoneSprite();
    if (sprite && sprite->initWithFile(filename))
    {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

bool DropzoneSprite::initWithFile(const std::string &filename)
{
    if (!Sprite::initWithFile(filename))
    {
        return false;
    }
    
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    float screenRatio = screenSize.width / screenSize.height;
    
    scaleAdjust = 1.0;
    
    if (screenRatio < 1.5) {
        scaleAdjust = 1.35;
    } else if (screenSize.width == 960) {
        scaleAdjust = 1.1;
    } else if (screenSize.width <= 1334) {
        scaleAdjust = 1.05;
    }
    
    m_frameTime = 1.0 / 20.0;
    m_totalDanceTime = m_frameTime * 50 - 0.6;
    
    return true;
}

void DropzoneSprite::dropTile(TileSprite *tile)
{
    if (m_tile) {
        if (m_tile != tile) {
            removeCurrentTile();
        }
    }
    m_tile = tile;
    tile->m_dropzoneIndex = m_index;
    
    float dropTime = m_tile->getPosition().distance(getPosition()) / 2000.0;
    if (dropTime < 0.1) {
        dropTime = 0.1;
    }
    
    m_tile->m_dropping = true;
    
    tile->runAction(Sequence::create(
                                     MoveTo::create(dropTime, getPosition()),
                                     CallFunc::create(std::bind(&DropzoneSprite::showCircle, this)),
                                     NULL));
}

void DropzoneSprite::removeCurrentTile()
{
    if (!m_tile) return;
    
    float dx = 200.0 - rand() % 400;
    float dy = 300 + rand() % 50;
    m_tile->runAction(Sequence::create(
                                        Spawn::create(
                                                      MoveBy::create(0.5, Point(dx, dy)),
                                                      ScaleTo::create(0.5, 0.0),
                                                      NULL),
                                        CallFunc::create(std::bind(&Node::removeFromParent, m_tile)),
                                        NULL));
    
    m_tile = NULL;
}

void DropzoneSprite::removeCircle()
{
    if (m_circle) {
        m_circle->stopAllActions();
        removeChild(m_circle, true);
        m_circle = NULL;
    }
}

void DropzoneSprite::bounce()
{
    stopAllActions();
    m_tile->setRotation(0);
    
    float dropzoneScale = DROPZONE_DEFAULT_SCALE;
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    if (screenSize.width == 960) {
        dropzoneScale *= scaleAdjust;
    }
    
    runAction(Sequence::create(
                               ScaleTo::create(m_totalDanceTime / 6.0, 1.30 * dropzoneScale),
                               DelayTime::create(m_totalDanceTime / 6.0 * 7.0),
                               ScaleTo::create(m_totalDanceTime / 6.0, dropzoneScale),
                               NULL));
    
    m_tile->runAction(RotateBy::create(m_totalDanceTime / 2.0, 360));
    
//    m_tile->runAction(Sequence::create(
//                               Spawn::create(
//                                             ScaleTo::create(totalDanceTime / 4, 1.3 * 0.85),
//                                             RotateBy::create(0.5, -90),
//                                             NULL),
//                               RotateBy::create(totalDanceTime / 2, -180),
//                               Spawn::create(
//                                             ScaleTo::create(totalDanceTime / 4, 0.85),
//                                             RotateBy::create(totalDanceTime / 4, -90),
//                                             NULL),
//                               NULL));
}

void DropzoneSprite::showCircle()
{
    auto gm = GameManager::getInstance();
    
    if (!m_circle) {
        m_circle = Sprite::create("tiles/" + gm->m_currentActors[gm->m_currentActorIndex].name + "/tileCircle.png");
        m_circle->setPosition(getContentSize().width / 2, getContentSize().height / 2);
        m_circle->setOpacity(0);
        m_circle->setBlendFunc(BlendFunc::ALPHA_PREMULTIPLIED);
        
        addChild(m_circle);
        m_circle->runAction(FadeIn::create(0.1));
    }
    
    m_tile->m_dropping = false;
}

void DropzoneSprite::restore()
{
    removeCircle();
    m_tile->removeFromParent();
    scaleDown();
    m_tile = NULL;
}

void DropzoneSprite::scaleUp()
{
    stopAllActions();
    runAction(ScaleTo::create(m_totalDanceTime / 6.0, 1.30 * DROPZONE_DEFAULT_SCALE));
}

void DropzoneSprite::scaleDown()
{
    stopAllActions();
    runAction(ScaleTo::create(m_totalDanceTime / 6.0, 1.0 * DROPZONE_DEFAULT_SCALE));
}
