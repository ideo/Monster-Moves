//
//  CreateLayer.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/20.
//
//

#ifndef __MonsterMove__CreateLayer__
#define __MonsterMove__CreateLayer__

#include "cocos2d.h"
#include "BaseLayer.h"
#include "JsonSprite.h"
#include "DropzoneSprite.h"
#include "../../cocos2d/external/Box2D/Box2D.h"
#include "GLES-Render.h"

USING_NS_CC;

class CreateLayer : public BaseLayer, public TileSpriteDelegate, JsonSpriteDelegate
{
public:
    
    static Scene* scene();
    
//    static CreateLayer* createWithPhysicsWorld(PhysicsWorld* world);
    
    CREATE_FUNC(CreateLayer);
    
    ~CreateLayer();

    virtual bool init();
    
    virtual void onEnterTransitionDidFinish();

    virtual void tilePressed(TileSprite* tile);
    
    virtual void actionStopped(JsonSprite *sprite);
    
    virtual void actionPreloaded(std::string actionName);
    
    virtual void onExit();

    virtual void update(float delta);

    void addColorChangeTile(float dt);
    
protected:
    
    Sprite *m_circle;
    
    Sprite *m_bg;
    
    float m_bgRadius;
    
    JsonSprite *m_actor;
    
    b2World *m_world;
    
    b2Body *m_centralCircleBody;
    b2Body *m_forwardButtonBody;
    b2Body *m_backButtonBody;
    b2Body *m_dropzoneBodies[4];
    
//    GLESDebugDraw *m_debugDraw;
    
    bool m_isPlaying;
    
    bool m_isGoingBack;
    
    float m_yAdj;
    
protected:
    
//    virtual void draw(Renderer *renderer, const Mat4& transform, uint32_t flags);
    
    virtual bool onTouchBegan( Touch *pTouch, Event *pEvent );

    virtual void onTouchMoved( Touch *pTouch, Event *pEvent );
    
    virtual void onTouchCancelled( Touch *pTouch, Event *pEvent );
    
    virtual void onTouchEnded( Touch *pTouch, Event *pEvent );
    
private:
    
    Point m_touchBeginPos;
    
    Point m_lastTouchPos;
    
    Point m_touchOffset;
    
    bool m_dragging;
    
    bool m_draggingDisabled;
    
    bool m_zoneLinkBreaked;
    
    Vec2 m_lastDragSpeed;
    
    TileSprite *m_currentTile;

    unsigned long long m_t0;
    
    unsigned long long m_t1;
    
    float minTileGenY;
    
    int m_lastReactionId;
    
    float m_hue;
    
    float m_lightHue;
    
    int m_lastLightId;
    
    int m_currentSequenceIndex;
    
    bool m_isSequenceFull;
    
    float m_dropzoneYC;
    
    float m_cornerYC;
    
    bool m_colorChanging;
    
    bool m_colorChanged;
    
    int m_pace;
    
    int m_reactionReady;
    
    int m_reactionPreloadedCount;
    
    std::string m_enterAction;

    float scaleAdjust;
    
    Menu *m_menu;
    
    int m_sparkleSoundId;
    
    int m_dancePreloadedCount;
    
    int m_starFreq;
    
    unsigned long long m_showStartTime;
    
private:
    
    void setupPhysics();
    
    void setupCentralCircle();
    
    void setupDropzones();
    
    void setupWorld();
    
    void setupTiles();
    
    void addActionTile(std::string actionName);
    
    void addTile(std::string actionName, TileType type);
    
    void startIdle();

    Point getTargetPos(Point p);
    
    void tryDropNewTile(TileSprite *tile);
    
    bool dropzoneIsFull();
    
    void checkDropzonesToPlay();
    
//    void playBackgroudMusic(float delta);
    
    void prepareToForward(Ref *sender);
    
    void prepareToPlay(Ref *sender);
    
    void prepareToGoBack(Ref *sender);
    
    void goBack();
    
    void scheduleNextColorChangeTile();
    
    void startColorChangeShow();
    
    void endColorChangeShow();

    void showLights();

    void hideLights();
    
    void removeFloatingTiles();
    
    void removeAllFloatingTiles();

    void playSparkleSound();
    
    void removeTileFromZone(DropzoneSprite *zone);
    
    void removeDuplicatedTile(TileSprite *tileA);
    
    bool tileInCollisions(TileSprite *tile);
    
    void restoreCreateMode(Ref *sender);
    
    void playNextDance(float dt);

    void imageLoaded(Texture2D *texture);
    
    void showFirworks(float dt);
    
    void addStars(Point point);

};

#endif /* defined(__MonsterMove__CreateLayer__) */
