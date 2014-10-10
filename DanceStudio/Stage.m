//
//  Stage.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/2/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "Stage.h"

@implementation Stage

- (instancetype)initWithType:(StageType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (SKColor *)color {
    switch (_type) {
        case StageTypeBurningMan:
            return [SKColor colorWithRed:250/255.0 green:239/255.0 blue:100/255.0 alpha:1];
            
        case StageTypeCelebration:
            return [SKColor colorWithRed:184/255.0 green:74/255.0 blue:87/255.0 alpha:1];
            
        case StageTypeParty:
            return [SKColor colorWithRed:112/255.0 green:56/255.0 blue:162/255.0 alpha:1];
            
        case StageTypeSpace:
            return [SKColor colorWithRed:56/255.0 green:54/255.0 blue:54/255.0 alpha:1];
            
        case StageTypeWhale:
            return [SKColor colorWithRed:66/255.0 green:210/255.0 blue:142/255.0 alpha:1];
            
        default:
            return [SKColor colorWithWhite:0.5 alpha:1.0];
    }
}

- (AudioType)audio {
    switch (_type) {
        case StageTypeBurningMan:
            return AudioTypeMusicBurningMan;
            
        case StageTypeCelebration:
            return AudioTypeMusicCelebration;
            
        case StageTypeParty:
            return AudioTypeMusicParty;
            
        case StageTypeSpace:
            return AudioTypeMusicSpace;
            
        case StageTypeWhale:
            return AudioTypeMusicWhale;
            
        default:
            return AudioTypeMusicWhale;
    }
}

- (NSString*) spriteName {
    switch (_type) {
        case StageTypeBurningMan:
            return @"BurningMan";
            
        case StageTypeCelebration:
            return @"Celebration";
            
        case StageTypeParty:
            return @"Party";
            
        case StageTypeSpace:
            return @"Space";
            
        case StageTypeWhale:
            return @"Whale";
            
        default:
            return @"Whale";
    }
}

- (SKSpriteNode*)sprite {
    SKSpriteNode* scene = [[SKSpriteNode alloc] init];
    [self transitionToStageWithType:_type sceneSprite:scene];
    scene.userData = [@{@"scene" : scene} mutableCopy];
    scene.alpha = 100.0;
    return scene;
}

- (SKSpriteNode*)transitionToStageWithType:(StageType)type sceneSprite:(SKSpriteNode*)sprite {
    _type = type;
    sprite.texture = [SKTexture textureWithImageNamed:self.spriteName];
    sprite.alpha = 0.0;
    return sprite;
}

- (SKAction*)actionToAnimateToStage {
    SKAction* scaleAction = [SKAction scaleTo:2 duration:0.6];
    scaleAction.timingMode = SKActionTimingEaseOut;
    SKAction* colorAction = [SKAction colorizeWithColor:self.color colorBlendFactor:1.0 duration:0.6];
    colorAction.timingMode = SKActionTimingEaseOut;
    return [SKAction group:@[scaleAction, colorAction]];
}

+ (StageType)stageTypeAtRandom {
    NSArray* types = @[@(StageTypeWhale), @(StageTypeSpace), @(StageTypeCelebration), @(StageTypeBurningMan), @(StageTypeParty)];
    uint32_t random = arc4random_uniform([types count]);
    NSNumber* randomType = [types objectAtIndex:random];
    StageType tt;
    
    if (randomType.intValue == 0) tt = StageTypeBurningMan;
    else if (randomType.intValue == 1) tt = StageTypeCelebration;
    else if (randomType.intValue == 2) tt = StageTypeParty;
    else if (randomType.intValue == 3) tt = StageTypeSpace;
    else tt = StageTypeWhale;
    
    return tt;
}


@end
