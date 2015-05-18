//
//  IDEOPopUpGate.h
//  IDEOParentsSectionLib
//
//  Created by rui wang on 5/5/14.
//  Copyright (c) 2014 wang rui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol IDEOPopUpGateDelegate <NSObject>

- (void)popupGateDidEnterCorrectAnswer;

@end

@interface IDEOPopUpGate : UIView <UITextFieldDelegate,AVAudioPlayerDelegate>

@property(nonatomic, weak)id <IDEOPopUpGateDelegate> delegate;

- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
