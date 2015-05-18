//
//  IDEOLockBar.h
//  IDEOParentsSectionLib
//
//  Created by rui wang on 4/30/14.
//  Copyright (c) 2014 wang rui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDEOLockBar;

@protocol IDEOLockBarDelegate <NSObject>

- (void)lockBarDidPressEnough:(IDEOLockBar *)bar;

@end

@interface IDEOLockBar : UIView

@property(nonatomic, readonly)BOOL progressVisible;
@property(nonatomic, weak)id <IDEOLockBarDelegate> delegate;

- (void)showProgress;
- (void)hideProgress;

@end
