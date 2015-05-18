//
//  GameManager.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/21.
//
//

#ifndef __MonsterMove__GameManager__
#define __MonsterMove__GameManager__

#include "cocos2d.h"
#include <vector>

using namespace cocos2d;

typedef struct {
    std::string name;
    int pos;
    std::string lastActionName;
    std::string sequence[4];
    float hue;
    bool isSequenceReady;
    int currentSequenceIndex;
} ActorData;

typedef struct {
    std::string file;
    float topPos;
    float offsetY;
    float scaleUpTime;
    float scaleDownTime;
    float fadeInTime;
    float fadeOutTime;
    std::string particleFile;
    bool shouldAdjustTime;
} ParticleData;

typedef struct {
    std::string bg;
    std::string selectBeats;
    std::string createBeats;
    std::string playBeats;
    std::string allBeats;
    int beatCount;
    std::vector<ParticleData> successParticles;
    std::vector<std::string> stamps;
    int stampIndex;
    Point offsets[3];
    Color4B loadingColor;
} SceneData;

class GameManager
{
public:
    
    int m_currentActorIndex;
    
    int m_currentSceneIndex;
    
    std::vector<std::string> m_actorNames;

    std::vector<SceneData> m_scenes;
    
    ActorData m_currentActors[3];
    
    bool m_firstStart;
    
public:
    
    static GameManager* getInstance();
    
    void randomSelectActors();
    
private:
    
    GameManager(){}
    
    virtual bool init();
    
};

static GameManager* s_sharedGameManager;

#endif /* defined(__MonsterMove__GameManager__) */
