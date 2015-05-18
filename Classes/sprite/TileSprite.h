//
//  TileSprite.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/21.
//
//

#ifndef __MonsterMove__TileSprite__
#define __MonsterMove__TileSprite__

#include "cocos2d.h"
#include "../../cocos2d/external/Box2D/Box2D.h"
#include "HueSprite.h"

USING_NS_CC;

typedef enum
{
    TileTypeNormal,
    TileTypeColorChange
} TileType;

typedef enum
{
    TileModeNormal = 0,
    TileModeEnter = 1,
    TileModeLeaving = 2,
    TileModeReenter = 3
} TileMode;

class TileSprite;

class TileSpriteDelegate
{
public:
    
    virtual void tilePressed(TileSprite* tile) = 0;
    
};

class TileSprite : public HueSprite
{
public:
    
    std::string m_actionName;

    TileSpriteDelegate *m_delegate;
    
    b2Body *m_body;
    
    int m_dropzoneIndex;
    
    TileType m_type;
    
    bool m_dropping;
    
    int m_mode;
    
    b2World *m_world;
    
public:
    
    ~TileSprite();

    static TileSprite* create(const std::string& filename);
    
    virtual bool initWithFile(const std::string& filename);

    void detachPhysics(b2World *world);

    void attachPhysics(b2World *world);

    void attachPhysicsFromCache(b2World *world, std::string shapeName);
    
    void attachPhysicsInReenterMode(b2World *world);
    
    void setEnterMode();
    
    void removeEnterMode();
    
    void setLeavingMode();
    
    void removeLeavingMode();
    
    void setReenterMode();
    
    void removeReenterMode();
    
    virtual void update(float delta);

protected:
    
    virtual bool onTouchBegan( Touch *pTouch, Event *pEvent );

    virtual void onTouchMoved( Touch *pTouch, Event *pEvent );
    
    virtual void onTouchCancelled( Touch *pTouch, Event *pEvent );
    
    virtual void onTouchEnd( Touch *pTouch, Event *pEvent );
    
private:
    
    Point m_lastTouchPos;
    
    Point m_touchOffset;
    
    bool m_dragging;
    
    Vec2 m_lastDragSpeed;
    
    unsigned long long m_t0;
    unsigned long long m_t1;
    
    float scaleAdjust;

private:
    
};

#endif /* defined(__MonsterMove__TileSprite__) */
