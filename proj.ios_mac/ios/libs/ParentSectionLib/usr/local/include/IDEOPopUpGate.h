//
//  IDEOPopUpGate.h
//  IDEOParentsSectionLib
//
//  Created by rui wang on 5/5/14.
//  Copyright (c) 2014 wang rui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


/**
 PopUpGateType
 
 - PopUpGateAge: Gate with age. eg. Enter yoru age and validate using that
 - PopUpGateRandom: Gate with random number type in. eg. Please enter "forty-two"
 */
typedef NS_ENUM(NSInteger, PopUpGateType) {
    PopUpGateAge,
    PopUpGateRandom,
};




@protocol IDEOPopUpGateDelegate <NSObject>

- (void)popupGateDidEnterCorrectAnswer;

@end

@interface IDEOPopUpGate : UIView <UITextFieldDelegate,AVAudioPlayerDelegate>

@property(nonatomic, weak)id <IDEOPopUpGateDelegate> delegate;
@property PopUpGateType type;

/// rootview : So that the analytics know from where the rootview was called.
@property(nonatomic,strong) NSString *rootView;

- (void)showInView:(UIView *)view withViewName:(NSString *)rootView;
- (void)dismiss;

@end
