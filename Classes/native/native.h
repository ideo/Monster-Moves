#ifndef NativeDEF_h__
#define NativeDEF_h__

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "android/NativeHelper.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "iOS/NativeHelper.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
#include "win32/NativeHelper.h"
#endif

#endif // NativeDEF_h__