//
//  Stage.h
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/2/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "AudioPlayer.h"

typedef enum StageType {
    StageTypeSpace = 0,
    StageTypeBurningMan = 1,
    StageTypeWhale = 2,
    StageTypeParty = 3,
    StageTypeCelebration = 4
} StageType;

@interface Stage : NSObject

@property (nonatomic,readonly) StageType type;
@property (nonatomic,readonly) SKColor* color;
@property (nonatomic,readonly) SKSpriteNode* sprite;
@property (nonatomic,readonly) AudioType audio;

- (instancetype)initWithType:(StageType)type;
- (SKSpriteNode*)transitionToStageWithType:(StageType)type sceneSprite:(SKSpriteNode*)sprite;
- (SKAction*)actionToAnimateToStage;

+ (StageType)stageTypeAtRandom;

@end
