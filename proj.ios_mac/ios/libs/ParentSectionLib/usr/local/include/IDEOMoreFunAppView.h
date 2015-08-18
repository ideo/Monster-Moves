//
//  IDEOMoreFunAppView.h
//  IDEOParentsSectionLib
//
//  Created by SatinnoGroup on 15/8/10.
//  Copyright (c) 2015 wang rui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    kIDEOMoreFunAppViewAnimateDirectionUp = 500,
    kIDEOMoreFunAppViewAnimateDirectionDown
} kIDEOMoreFunAppViewAnimateDirection;

typedef enum{
    kIDEOMoreFunAppViewAnimateLowerRightCorner = 503,
    kIDEOMoreFunAppViewAnimateLowerLeftCorner,
    kIDEOMoreFunAppViewAnimateUpperRightCorner,
    kIDEOMoreFunAppViewAnimateUpperLeftCorner
} kIDEOMoreFunAppViewAnimateCorner;


@class IDEOMoreFunAppView;
@protocol IDEOMoreFunAppViewDelegate <NSObject>

@optional

/**
 *  did click moreFunAppView
 *
 *  @param moreFunAppView moreFunAppView
 */
- (void)moreFunAppViewDidClick:(IDEOMoreFunAppView *) moreFunAppView;

@end


@interface IDEOMoreFunAppView : UIView

/** animationDirection */
@property (nonatomic,assign) kIDEOMoreFunAppViewAnimateDirection animateDirection;
/** corner */
@property (nonatomic,assign) kIDEOMoreFunAppViewAnimateCorner appearCorner;
/** delegate */
@property (nonatomic,weak) id<IDEOMoreFunAppViewDelegate> delegate;

/**
 *  appear
 */
- (void)appear;

/**
 *  disappear
 */
- (void)disappear;

@end
