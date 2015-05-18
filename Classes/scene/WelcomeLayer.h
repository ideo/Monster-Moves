//
//  WelcomeLayer.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/20.
//
//

#ifndef __MonsterMove__WelcomeLayer__
#define __MonsterMove__WelcomeLayer__

#include "cocos2d.h"
#include "BaseLayer.h"
#include "JsonSprite.h"

USING_NS_CC;

class WelcomeLayer : public BaseLayer, public JsonSpriteDelegate
{
public:

    static Scene* scene();
    
    virtual bool init();

    CREATE_FUNC(WelcomeLayer);
    
    virtual void onEnterTransitionDidFinish();

    virtual void actionStopped(JsonSprite *actor);
    
    virtual void actionPreloaded(std::string actionName);
    
    virtual void onExit();

protected:
    
    bool m_spaceshipTouchable;
    
    bool m_eggReady;
    
    JsonSprite *m_paceControler;
    
    int m_pace;
    
protected:
    
    virtual bool onTouchBegan( Touch *pTouch, Event *pEvent );
    
    virtual void onTouchMoved(cocos2d::Touch *pTouch, cocos2d::Event *pEvent);
    
    virtual void onTouchEnded( Touch *pTouch, Event *pEvent );
    
    void spaceshipFloat();
    
    void spaceshipFlyInAndDropEggs();

    void spaceshipFlyInAndTakeAwayEggs();

    void dropEggs();
    
    void takeAwayEggs();
    
private:
    
    int m_preloadingAmount;
    int m_preloadCount;
    int m_sequenceReadyCount;
    
    bool m_isNewGame;
    
    int m_eggCrackSoundId;
    int m_stampSoundId;
    
    bool m_isPlaying;
    
    bool m_dragging;
    
    bool m_dragEnabled;
    
    Point m_lastTouchPos;
    
    int m_starFreq;
    
private:
    
    void addBackground(bool visible);
    
    void eggsReady();
    
    void prepareNewGame();
    
    void setupNewGameScene();
    
    void addSuccessParticles();
    
    void removeSuccessParticles();
    
    void showLoadingUI();
    
    void playEggCrackSound();
    
    void rewindBackgroundMusic();
    
    void playStampSound();
    
    void startGroupDancing();
    
    void playNextDance(float dt);
    
    void addStamp(Point point);
    
};

#endif /* defined(__MonsterMove__WelcomeLayer__) */
