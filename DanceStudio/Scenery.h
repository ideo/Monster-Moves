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

typedef enum SceneryType {
    StageTypeCandy = 0,
    StageTypeLime = 1,
    StageTypeSpace = 2,
    StageTypeParty = 3,
    StageTypeWhale = 4
} SceneryType;

@interface Scenery : NSObject<NSCoding>

@property (nonatomic,readonly) SceneryType type;
@property (nonatomic,readonly) SKColor* color;
@property (nonatomic,readonly) SKSpriteNode* sprite;
@property (nonatomic,readonly) AudioType audio;
@property (nonatomic,readonly) NSString* particleFileName;
@property (nonatomic,readonly) NSString* stampSpriteName;

- (instancetype)initWithType:(SceneryType)type;
- (SKSpriteNode*)transitionToSceneryWithType:(SceneryType)type sceneSprite:(SKSpriteNode*)sprite;
- (SKAction*)actionToAnimateToScenery;

+ (SceneryType)sceneryTypeAtRandom;

@end
