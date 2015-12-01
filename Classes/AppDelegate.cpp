#include "AppDelegate.h"
#include "Constants.h"
#include "WelcomeLayer.h"
#include "CreateLayer.h"
#include "GameManager.h"
#include "IntroLayer.h"
#include "Utils.h"
#include "SimpleAudioEngine.h"
#include "native.h"

USING_NS_CC;

static cocos2d::Size designResolutionSize = cocos2d::Size(2048, 1536);

AppDelegate::AppDelegate() {

}

AppDelegate::~AppDelegate() 
{
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching() {
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {
        glview = GLViewImpl::create("My Game");
        director->setOpenGLView(glview);
    }

    Size screenSize = glview->getFrameSize();
    
    CCLOG("screenSize: %f, %f", screenSize.width, screenSize.height);
    
    glview->setDesignResolutionSize(designResolutionSize.width, designResolutionSize.height, ResolutionPolicy::NO_BORDER);
    
    std::vector<std::string> searchPaths;
    
    if (screenSize.width <= 1024.0) { // iPhone 6-

        director->setContentScaleFactor(1.0);
        searchPaths.push_back("images/iPhone");
    
        // TODO: add downloaded assets folder
        
    } else { // iPhone 6 plus, iPad, iPad retina
    
        director->setContentScaleFactor(1.0);
        searchPaths.push_back("images/iPad");
        
        // TODO: add downloaded assets folder
    }
    
    searchPaths.push_back("images/other");

    FileUtils::getInstance()->setSearchPaths(searchPaths);
    
    srand(Utils::timeInMillisecond());
    
//    Texture2D::setDefaultAlphaPixelFormat(Texture2D::PixelFormat::RGBA4444);
    
    // turn on display FPS
//    director->setDisplayStats(true);

    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 60);

    // create a scene. it's an autorelease object
    auto scene = IntroLayer::scene();
    
    CocosDenshion::SimpleAudioEngine::getInstance()->setBackgroundMusicVolume(0.4);
//    CocosDenshion::SimpleAudioEngine::getInstance()->setEffectsVolume(0.1);
    
//    GameManager::getInstance()->randomSelectActors();
//    GameManager::getInstance()->m_currentActorIndex = 1;
//    
//    auto scene = CreateLayer::scene();
    
    // run
    director->runWithScene(scene);

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground() {
    Director::getInstance()->stopAnimation();

    NativeHelper::getInstance()->dismissParentSection();
    
    // if you use SimpleAudioEngine, it must be pause
    // SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground() {

    auto runningScene = Director::getInstance()->getRunningScene();
    
    auto layer = runningScene->getChildByTag(CREATE_LAYER_TAG);
    
    if (layer) {
        CreateLayer *createLayer = (CreateLayer *)layer;
        createLayer->fastCleanUp();
    }

    GameManager::getInstance()->m_firstStart = true;
    
    Director::getInstance()->startAnimation();

    auto scene = IntroLayer::scene();
    
    CocosDenshion::SimpleAudioEngine::getInstance()->setBackgroundMusicVolume(0.4);
    
    Director::getInstance()->replaceScene(scene);
    
    // if you use SimpleAudioEngine, it must resume here
    // SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
