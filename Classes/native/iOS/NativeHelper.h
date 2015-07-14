//
//  NativeHelper.h
//  AlmostSame
//
//  Created by Zhou Yang on 6/10/14.
//
//
#ifndef __AlmostSame__NativeHelper__
#define __AlmostSame__NativeHelper__

#include "cocos2d.h"
#include <map>

USING_NS_CC;

typedef struct
{
    int type; // 0: str, 1: int, 2, float;
    float f;
    int i;
    std::string s;
} FlurryParemeter;

typedef struct
{
    int listenerId;
    int state;
    void *data;
} NativeEvent;

class NativeEventListener {
    
public:
    
    std::function<void(NativeEvent)> onEvent;
    
};

class CC_DLL NativeHelper {

public:
    
    std::map<int, NativeEventListener *> m_eventListeners;
    
public:
    
    virtual bool init();
    
    static NativeHelper* getInstance();
    
    std::string getUniqueId();
    
    void openURL(const char* pszUrl);

    void share(const char* imageFile, const char* info);
    
    void track(std::string category, std::string action, std::string label);
    
    void enableDeviceSleep();

    void disableDeviceSleep();
    
    void showParentSection();
    
    void dismissParentSection();
    
    void removeFlickCover();
    
    void prepareIntroVideo(int listenerId);
    
    void showIntroVideo(int listenerId);
    
    void dismissIntroVideo();
    
    int addNativeEventListener(NativeEventListener * listener);
    
    void removeNativeEventListener(int listenerId);
    
    void dispatchNativeEvent(NativeEvent e);
    
    FlurryParemeter getFlurryStringParameter(std::string value);
    
    void logFlurryEvent(std::string eventName);

    void logFlurryEvent(std::string eventName, bool timed);
    
    void endFlurryTimedEvent(std::string eventName);

    void endFlurryTimedEvent(std::string eventName, std::string parameterName, std::string parameterValue);
    
    void endFlurryTimedEvent(std::string eventName, std::unordered_map<std::string, FlurryParemeter> parameters);
    
    void logFlurryEvent(std::string eventName,  std::unordered_map<std::string, FlurryParemeter> parameters);

    void logFlurryEvent(std::string eventName,  std::string parameterName, std::string parameterValue);
    
    std::string getLanguage();
  
private:
    
    int m_globalListenerIndex;
    
};

static NativeHelper* s_sharedNativeHelper;

#endif