//
//  NativeHelper.m
//  AlmostSame
//
//  Created by Zhou Yang on 6/10/14.
//
//

#import "NativeHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>


#import "AppController.h"
#import "RootViewController.h"
#import "IDEOParentsSectionLib.h"
#import "RootViewController.h"

bool NativeHelper::init() {
    //Do you have anything to init?
    
    return true;
}

NativeHelper* NativeHelper::getInstance()
{
    if (s_sharedNativeHelper == nullptr)
    {
        s_sharedNativeHelper = new NativeHelper();
        if(!s_sharedNativeHelper->init())
        {
            delete s_sharedNativeHelper;
            s_sharedNativeHelper = nullptr;
        }
    }
    return s_sharedNativeHelper;
}

void NativeHelper::openURL(const char* pszUrl)
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithCString:pszUrl encoding:NSASCIIStringEncoding]]];
}

std::string NativeHelper::getUniqueId() {
    return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] cStringUsingEncoding:NSUTF8StringEncoding];
}

void NativeHelper::share(const char* imageFile, const char* info) {
    CCLOG("\nimageFile : %s\ninfo : %s", imageFile, info);
    
    //    NSURL *url = [NSURL URLWithString:APP_URL];
    
    NSMutableArray *shareItems = [NSMutableArray array];
    
    UIImage *image1 = [UIImage imageNamed:[NSString stringWithUTF8String:imageFile]];
    [shareItems addObject:image1];
    
    NSString *s = [NSString stringWithUTF8String:info];
    [shareItems addObject:s];
    
    //    [shareItems addObject:url];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityViewController animated:YES completion:nil];
    }

}

void NativeHelper::prepareIntroVideo(int listenerId)
{
    RootViewController *rootViewController = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    rootViewController.listenerId = listenerId;
    [rootViewController prepareVideo];
}

void NativeHelper::showIntroVideo(int listenerId)
{
    RootViewController *rootViewController = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    rootViewController.listenerId = listenerId;
    [rootViewController playVideo];
}

void NativeHelper::dismissIntroVideo()
{
    RootViewController *rootViewController = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController dismissVideo];
}

int NativeHelper::addNativeEventListener(NativeEventListener *listener) {
    if (listener) {
        int listenerId = m_globalListenerIndex++;
        m_eventListeners[listenerId] = listener;
        return listenerId;
    }
    return -1;
}

void NativeHelper::removeNativeEventListener(int listenerId)
{
    NativeEventListener *listener = m_eventListeners[listenerId];
    if (listener) {
        m_eventListeners[listenerId] = NULL;
        delete listener;
    }
}

void NativeHelper::dispatchNativeEvent(NativeEvent e)
{
    NativeEventListener *listener = m_eventListeners[e.listenerId];
    if (listener && listener->onEvent) {
        listener->onEvent(e);
    }
}

void NativeHelper::track(std::string category, std::string action, std::string label)
{
    
//    [[IDEOParentsSectionLib sharedInstance] trackCategory:[NSString stringWithUTF8String:category.c_str()] action:[NSString stringWithUTF8String:action.c_str()] label:[NSString stringWithUTF8String:label.c_str()] value:nil];
}

void NativeHelper::enableDeviceSleep()
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

void NativeHelper::disableDeviceSleep()
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

void NativeHelper::removeFlickCover()
{
    UIView *view = [[UIApplication sharedApplication].keyWindow viewWithTag:9528];
    if (view) {
        [view removeFromSuperview];
        view = nil;
    }
}

void NativeHelper::showParentSection()
{
    AppController *appController = [UIApplication sharedApplication].delegate;
    
    [(RootViewController*)appController.viewController showParentSection];
    
}

void NativeHelper::dismissParentSection()
{
    AppController *appController = [UIApplication sharedApplication].delegate;
    
    [(RootViewController*)appController.viewController dismissParentSection];
    
}

void NativeHelper::logFlurryEvent(std::string eventName)
{
    return;
    
    [[IDEOParentsSectionLib sharedInstance] logFlurryEvent:[NSString stringWithCString:eventName.c_str() encoding:[NSString defaultCStringEncoding]]];
}

void NativeHelper::logFlurryEvent(std::string eventName, bool timed)
{
    return;
    [[IDEOParentsSectionLib sharedInstance] logFlurryEvent:[NSString stringWithCString:eventName.c_str() encoding:[NSString defaultCStringEncoding]] timed:timed];
}

void NativeHelper::endFlurryTimedEvent(std::string eventName, std::unordered_map<std::string, FlurryParemeter> parameters)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(std::unordered_map<std::string, FlurryParemeter>::iterator it = parameters.begin(); it != parameters.end(); it++)
    {
        std::string n = it->first;
        FlurryParemeter fp = it->second;
        
        NSString *key = [NSString stringWithCString:n.c_str() encoding:[NSString defaultCStringEncoding]];
        
        switch (fp.type) {
            case 0:
                [dict setObject:[NSString stringWithCString:fp.s.c_str() encoding:[NSString defaultCStringEncoding]] forKey:key];
                break;
            case 1:
                [dict setObject:[NSNumber numberWithInt:fp.i] forKey:key];
                break;
            case 2:
                [dict setObject:[NSNumber numberWithFloat:fp.f] forKey:key];
                break;
            default:
                break;
        }
    }
    
    [[IDEOParentsSectionLib sharedInstance] endFlurryTimedEvent:[NSString stringWithCString:eventName.c_str() encoding:[NSString defaultCStringEncoding]] withParameters:dict];

}

void NativeHelper::logFlurryEvent(std::string eventName, std::unordered_map<std::string, FlurryParemeter> parameters)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(std::unordered_map<std::string, FlurryParemeter>::iterator it = parameters.begin(); it != parameters.end(); it++)
    {
        std::string n = it->first;
        FlurryParemeter fp = it->second;
        
        NSString *key = [NSString stringWithCString:n.c_str() encoding:[NSString defaultCStringEncoding]];
        
        switch (fp.type) {
            case 0:
                [dict setObject:[NSString stringWithCString:fp.s.c_str() encoding:[NSString defaultCStringEncoding]] forKey:key];
                break;
            case 1:
                [dict setObject:[NSNumber numberWithInt:fp.i] forKey:key];
                break;
            case 2:
                [dict setObject:[NSNumber numberWithFloat:fp.f] forKey:key];
                break;
            default:
                break;
        }
    }
    
    [[IDEOParentsSectionLib sharedInstance] logFlurryEvent:[NSString stringWithCString:eventName.c_str() encoding:[NSString defaultCStringEncoding]] withParameters:dict];
}

void NativeHelper::endFlurryTimedEvent(std::string eventName)
{
    std::unordered_map<std::string, FlurryParemeter> parameters;
    endFlurryTimedEvent(eventName, parameters);
}

void NativeHelper::endFlurryTimedEvent(std::string eventName, std::string parameterName, std::string parameterValue)
{
    std::unordered_map<std::string, FlurryParemeter> parameters;
    FlurryParemeter fp;
    fp.type = 0;
    fp.s = parameterValue;
    
    parameters[parameterName] = fp;
    
    endFlurryTimedEvent(eventName, parameters);
    parameters.clear();
}

void NativeHelper::logFlurryEvent(std::string eventName, std::string parameterName, std::string parameterValue)
{
    std::unordered_map<std::string, FlurryParemeter> parameters;
    FlurryParemeter fp;
    fp.type = 0;
    fp.s = parameterValue;
    
    parameters[parameterName] = fp;
    
    logFlurryEvent(eventName, parameters);
    parameters.clear();
}

FlurryParemeter NativeHelper::getFlurryStringParameter(std::string value)
{
    FlurryParemeter fp;
    fp.type = 0;
    fp.s = value;
    return fp;
}

std::string NativeHelper::getLanguage()
{
    LanguageType curLanguage = Application::getInstance()->getCurrentLanguage();
    
    std::string language;
    switch (curLanguage) {
        case LanguageType::ENGLISH:
            language = "en";
            break;
        case LanguageType::CHINESE:
            language = "zh-Hans";
            break;
        case LanguageType::TCHINESE:
            language = "zh-Hant";
            break;
        case LanguageType::FRENCH:
            language = "fr";
            break;
        case LanguageType::ITALIAN:
            language = "it";
            break;
        case LanguageType::GERMAN:
            language = "de";
            break;
        case LanguageType::SPANISH:
            language = "es";
            break;
        case LanguageType::RUSSIAN:
            language = "ru";
            break;
        case LanguageType::KOREAN:
            language = "ko";
            break;
        case LanguageType::JAPANESE:
            language = "ja";
            break;
        case LanguageType::HUNGARIAN:
            language = "hu";
            break;
            /**
             case for more localize
             */
        default:
            language = "en";
            break;
    }
    return language;
}


