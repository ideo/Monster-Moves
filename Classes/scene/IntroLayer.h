//
//  IntroLayer.h
//  MonsterMove
//
//  Created by Zhou Yang on 4/2/15.
//
//

#ifndef __MonsterMove__IntroLayer__
#define __MonsterMove__IntroLayer__

#include "cocos2d.h"
#include "BaseLayer.h"
#include "native.h"

USING_NS_CC;

class IntroLayer : public BaseLayer
{
public:
    static Scene* scene();
    
    virtual bool init();
    
    CREATE_FUNC(IntroLayer);
    
    virtual void onExit();
    
    virtual void onEnterTransitionDidFinish();

    virtual bool onTouchBegan( Touch *pTouch, Event *pEvent );
    
private:
    
    float m_playButtonScale;
    
    Menu *m_menu;
    
    bool m_videoStopped;
    
private:
    
    void playButtonBlowing(MenuItem *playItem);
    
    void menuParentCallback( Ref *sender );

    void menuPlayCallback(cocos2d::Ref *sender);
    
    void videoReady(NativeEvent e);

    void videoFinished(NativeEvent e);
};

#endif /* defined(__MonsterMove__IntroLayer__) */
