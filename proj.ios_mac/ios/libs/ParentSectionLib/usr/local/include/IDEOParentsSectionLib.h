//
//  IDEOParentsSectionLib.h
//  IDEOParentsSectionLib
//
//  Created by rui wang on 4/30/14.
//  Copyright (c) 2014 rui wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IDEOPurchasedItemOpenedNotification @"IDEOPurchasedItemOpenedNotification"

@protocol IDEOParentsSectionDelegate <NSObject>

- (void)parentsSectionDidDismiss;

@end

@interface IDEOParentsSectionLib : NSObject

@property(nonatomic, weak)id <IDEOParentsSectionDelegate> delegate;
@property(nonatomic, assign, readonly)BOOL haveIAP;
@property(nonatomic, assign, readonly)BOOL getIAPFinished;
@property(nonatomic, assign, readonly)BOOL getAdsFinished;
@property(nonatomic, assign, readonly)BOOL getMoreAppsFinished;
@property(nonatomic, strong, readonly)NSMutableArray *iapList;
@property(nonatomic, strong, readonly)NSMutableArray *moreAppList;
@property(nonatomic, strong, readonly)NSMutableArray *adList;
@property(nonatomic, strong, readonly)NSMutableArray *featureList;


+ (id)sharedInstance;
// setup with default app id in config.plist
- (void)registerApplication;
- (void)showParentsSecionWithController:(UIViewController *)controller;
- (void)showMoreFunAppsWithController:(UIViewController *)controller;
- (void)dismissParentsSecionWithController:(UIViewController *)controller;
- (void)dismissMoreFunAppsWithController:(UIViewController *)controller;
- (BOOL)isPurchasedItem:(NSString *)productId;
//- (void)trackCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

//Flurry
- (void)logFlurryEvent:(NSString*)eventName;
- (void)logFlurryEvent:(NSString *)eventName timed:(BOOL)timed;
- (void)endFlurryTimedEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;
- (void)logFlurryEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

- (void)registerApplicationWithID:(NSString *)appID;
- (void)fetchCompanyListSuccess:(void(^)(NSMutableArray *list))success failure:(void(^)(NSError *error))failure;
- (void)fetchCompanyAppListWithID:(NSString *)companyID onSuccess:(void(^)(NSMutableArray *list))success failure:(void(^)(NSError *error))failure;

- (void)destroy;

@end
