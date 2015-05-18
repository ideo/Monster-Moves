//
//  GameManager.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/21.
//
//

#include "GameManager.h"
#include "json/rapidjson.h"
#include "json/document.h"

GameManager* GameManager::getInstance()
{
    if (s_sharedGameManager == nullptr)
    {
        s_sharedGameManager = new GameManager();
        if(!s_sharedGameManager->init())
        {
            delete s_sharedGameManager;
            s_sharedGameManager = nullptr;
        }
    }
    return s_sharedGameManager;
}

bool GameManager::init()
{
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    float screenRatio = screenSize.width / screenSize.height;
    
    rapidjson::Document doc;
    std::string fileData = FileUtils::getInstance()->getStringFromFile("config/scenes.json");
    doc.Parse<0>(fileData.c_str());

    if (doc.HasMember("scenes")) {
        rapidjson::Value &sceneDocArray = doc["scenes"];
        if (sceneDocArray.IsArray())
        {
            for (rapidjson::SizeType i = 0; i < sceneDocArray.Size(); i++)
            {
                rapidjson::Value& sceneDoc = sceneDocArray[i];
                SceneData sd;
                sd.bg = sceneDoc["bg"].GetString();
                
                if (sceneDoc.HasMember("selectBeats")) {
                    sd.selectBeats = sceneDoc["selectBeats"].GetString();
                }
                
                if (sceneDoc.HasMember("createBeats")) {
                    sd.createBeats = sceneDoc["createBeats"].GetString();
                }
                
                if (sceneDoc.HasMember("playBeats")) {
                    sd.playBeats = sceneDoc["playBeats"].GetString();
                }

                if (sceneDoc.HasMember("allBeats")) {
                    sd.allBeats = sceneDoc["allBeats"].GetString();
                }
                
                if (sceneDoc.HasMember("beatCount")) {
                    sd.beatCount = sceneDoc["beatCount"].GetInt();
                } else {
                    sd.beatCount = 4;
                }
                
                if (sceneDoc.HasMember("successParticles"))
                {
                    rapidjson::Value& successParticlesArray = sceneDoc["successParticles"];
                    if (successParticlesArray.IsArray())
                    {
                        for (rapidjson::SizeType j = 0; j < successParticlesArray.Size(); j++) {
                            rapidjson::Value& successParticlesDoc = successParticlesArray[j];
                            ParticleData pd;
                            pd.file = successParticlesDoc["file"].GetString();
                            pd.topPos = successParticlesDoc["top"].GetDouble();
                            pd.offsetY = successParticlesDoc["offsetY"].GetDouble();
                            if (successParticlesDoc.HasMember("shouldAdjustTime"))
                            {
                                pd.shouldAdjustTime = successParticlesDoc["shouldAdjustTime"].GetInt() > 0;
                            } else {
                                pd.shouldAdjustTime = true;
                            }
                            if (successParticlesDoc.HasMember("particleFile"))
                            {
                                pd.particleFile = successParticlesDoc["particleFile"].GetString();
                            }
                            if (successParticlesDoc.HasMember("scaleUpTime"))
                            {
                                pd.scaleUpTime = successParticlesDoc["scaleUpTime"].GetDouble();
                            }
                            else
                            {
                                pd.scaleUpTime = 0.0;
                            }
                            
                            if (successParticlesDoc.HasMember("scaleDownTime"))
                            {
                                pd.scaleDownTime = successParticlesDoc["scaleDownTime"].GetDouble();
                            }
                            else
                            {
                                pd.scaleDownTime = 0.0;
                            }
                            
                            if (successParticlesDoc.HasMember("fadeInTime"))
                            {
                                pd.fadeInTime = successParticlesDoc["fadeInTime"].GetDouble();
                            }
                            else
                            {
                                pd.fadeInTime = 0.0;
                            }
                            
                            if (successParticlesDoc.HasMember("fadeOutTime"))
                            {
                                pd.fadeOutTime = successParticlesDoc["fadeOutTime"].GetDouble();
                            }
                            else
                            {
                                pd.fadeOutTime = 0.0;
                            }
                            sd.successParticles.push_back(pd);
                        }
                    }
                }
                
                if (sceneDoc.HasMember("loadingColor"))
                {
                    rapidjson::Value &loadingColor = sceneDoc["loadingColor"];
                    sd.loadingColor.r = loadingColor["r"].GetInt();
                    sd.loadingColor.g = loadingColor["g"].GetInt();
                    sd.loadingColor.b = loadingColor["b"].GetInt();
                    sd.loadingColor.a = loadingColor["a"].GetInt();
                }
                
                if (sceneDoc.HasMember("stamps")) {
                    rapidjson::Value& stampDocArray = sceneDoc["stamps"];
                    if (stampDocArray.IsArray())
                    {
                        for (rapidjson::SizeType j = 0; j < stampDocArray.Size(); j++)
                        {
                            sd.stamps.push_back(stampDocArray[j].GetString());
                        }
                        sd.stampIndex = -1;
                    }
                }
                
                std::string offsetName;
                if (screenRatio > 1.5) {
                    offsetName = "iPhone5Offset";
                } else if (screenRatio == 1.5) {
                    offsetName = "iPhone4Offset";
                } else {
                    offsetName = "iPadOffset";
                }
                for (int k = 0; k < 3; k++) {
                    std::string memberName = offsetName + std::to_string(k);
                    if (sceneDoc.HasMember(memberName.c_str())) {
                        rapidjson::Value& offsetDoc = sceneDoc[memberName.c_str()];
                        sd.offsets[k].x = offsetDoc["x"].GetDouble();
                        sd.offsets[k].y = offsetDoc["y"].GetDouble();
                    } else {
                        sd.offsets[k].x = 0.0;
                        sd.offsets[k].y = 0.0;
                    }
                }
                
                m_scenes.push_back(sd);
            }
        }
    }
    
    m_actorNames.push_back("Meep");
    m_actorNames.push_back("Guac");
    m_actorNames.push_back("Pom");
    m_actorNames.push_back("Freds");
    m_actorNames.push_back("Sausalito");
    m_actorNames.push_back("LeBlob");
    
    m_currentActorIndex = -1;
    m_currentSceneIndex = -1;
    m_firstStart = true;
    return true;
}

void GameManager::randomSelectActors()
{
    int sceneIndex = rand() % m_scenes.size();
    while(sceneIndex == m_currentSceneIndex) {
        sceneIndex = rand() % m_scenes.size();
    }
    
    m_currentSceneIndex = sceneIndex;

    // 0 Desert
    // 1 Candy
    // 2 Jungle
    // 3 Space
    // 4 Ocean
    // 5 Yay
//    m_currentSceneIndex = 1;
    
    int stampIndex = rand() % m_scenes[m_currentSceneIndex].stamps.size();
    while( stampIndex == m_scenes[m_currentSceneIndex].stampIndex) {
        stampIndex = rand() % m_scenes[m_currentSceneIndex].stamps.size();
    }
    m_scenes[m_currentSceneIndex].stampIndex = stampIndex;

//    for(int i = 0; i < 3; i++) {
//        m_currentActors[i].name = m_actorNames[i];
//        m_currentActors[i].pos = i;
//        m_currentActors[i].isSequenceReady = false;
//        m_currentActors[i].hue = 0.0;
//    }
    
    std::set<int> seq;
    int repeatCount = 0;
    while(seq.size() < 3) {
        int n = rand() % m_actorNames.size();
        if (seq.count(n) > 0) {
            continue;
        } else {
            for(int i = 0; i < 3; i++) {
                if (m_currentActors[i].name == m_actorNames[n]) {
                    repeatCount++;
                    break;
                }
            }
            if (repeatCount >= 2) {
                repeatCount--;
                continue;
            }
            seq.insert(n);
        }
    }
    
    std::set<int>::iterator it;
    int i = 0;
    for(it = seq.begin(); it != seq.end(); it++)
    {
        m_currentActors[i].name = m_actorNames[*it];
        m_currentActors[i].pos = i;
        m_currentActors[i].isSequenceReady = false;
        m_currentActors[i].hue = 0.0;
        i++;
    }
    
}

