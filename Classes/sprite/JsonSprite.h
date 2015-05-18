//
//  JsonSprite.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/19.
//
//

#ifndef __MonsterMove__JsonSprite__
#define __MonsterMove__JsonSprite__

#include "cocos2d.h"
#include <vector>
#include <unordered_map>
//#include "HueSprite.h"

USING_NS_CC;

typedef struct {
    std::string actionName;
    std::string realName;
    std::string filePrefix;
    int frameStart;
    int frameEnd;
    float framerate;
    int repeat;
    int type;
    std::string soundEffect;
    std::string followedAction;
} ActionData;

class JsonSprite;

class JsonSpriteDelegate
{
public:
    
    virtual void actionStopped(JsonSprite *sprite) = 0;
    
    virtual void actionPreloaded(std::string actionName) = 0;
    
};

class JsonSprite : public Sprite
{
public:
    
    JsonSpriteDelegate *m_delegate;
    
    std::string m_name;
    
    std::string m_selectedEffect;
    
    std::string m_currentActionName;
    
    std::string m_backgroundSound;
    
    Rect m_touchArea;
    
    Rect m_touchArea2;
    
    float m_feetOffset;
    
    Color4B m_backgroundColor;

    Color4B m_circleColor;
    
    Color4B m_tileColor;
    
    Color4B m_starColor;
    
    float m_hue;
    
    std::unordered_map<std::string, ActionData> m_actions;
    
    std::unordered_map<std::string, SpriteBatchNode*> m_actorHolders;
    
    SpriteBatchNode* m_currentActorHolder;
    
    SpriteBatchNode* m_nextActionHolder;
    
    Texture2D::PixelFormat m_pixelFormat;
    
    bool m_silenceMode;
    
    bool m_cancelLoading;
    
    int m_soundId;
    
    unsigned long long m_lastPlayTime;

public:
    
    static JsonSprite* create(const std::string& filename);

    static JsonSprite* create(const std::string& filename, const std::string& defaultAction);
    
    virtual bool initWithConfigFile(const std::string& filename);

    virtual bool initWithConfigFile(const std::string& filename, const std::string& defaultAction);
    
    virtual void onExit();
    
    void playAction(std::string name);
    
    void playActionReverse(std::string name);
    
    Rect getTouchAreaInParent();
    
    void preloadActions(std::vector<std::string> actions);
    
    virtual void setHue(float h);

    void clearAssets(bool reserveSequence);
    
    void clearUnusedAssets();
    
    void clearAction(std::string name, bool reserveIfInSequence);
    
    void stopPerform();
    
protected:
    
    float m_stopped;
    
    std::vector<std::string> m_preloadActions;
    
    void actionStopped();
    
    void imageLoaded(Texture2D *texture);
    
    void playActionWithDirection(std::string name, bool reverse);
    
private:
    
    SpriteBatchNode* addBatchNode(std::string actorName, std::string action, int start, int end);

};

#endif /* defined(__MonsterMove__JsonSprite__) */
