//
//  Stage.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/2/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "Scenery.h"

@implementation Scenery

- (instancetype)initWithType:(SceneryType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (SKColor *)color {
    switch (_type) {
        case StageTypeLime:
            return [SKColor colorWithRed:250/255.0 green:239/255.0 blue:100/255.0 alpha:1];
            
        case StageTypeWhale:
            return [SKColor colorWithRed:184/255.0 green:74/255.0 blue:87/255.0 alpha:1];
            
        case StageTypeParty:
            return [SKColor colorWithRed:112/255.0 green:56/255.0 blue:162/255.0 alpha:1];
            
        case StageTypeCandy:
            return [SKColor colorWithRed:56/255.0 green:54/255.0 blue:54/255.0 alpha:1];
            
        case StageTypeSpace:
            return [SKColor colorWithRed:66/255.0 green:210/255.0 blue:142/255.0 alpha:1];
            
        default:
            return [SKColor colorWithWhite:0.5 alpha:1.0];
    }
}

- (AudioType)audio {
    switch (_type) {
        case StageTypeLime:
            return AudioTypeMusicBurningMan;
            
        case StageTypeWhale:
            return AudioTypeMusicCelebration;
            
        case StageTypeParty:
            return AudioTypeMusicParty;
            
        case StageTypeCandy:
            return AudioTypeMusicSpace;
            
        case StageTypeSpace:
            return AudioTypeMusicWhale;
            
        default:
            return AudioTypeMusicWhale;
    }
}

- (NSString*) spriteName {
    switch (_type) {
        case StageTypeLime:
            return @"Lime";
            
        case StageTypeWhale:
            return @"Whale";
            
        case StageTypeParty:
            return @"Party";
            
        case StageTypeCandy:
            return @"Candy";
            
        case StageTypeSpace:
            return @"Space";
            
        default:
            return nil;
    }
}

- (SKSpriteNode*)sprite {
    SKSpriteNode* scene = [[SKSpriteNode alloc] init];
    [self transitionToSceneryWithType:_type sceneSprite:scene];
    scene.userData = [@{@"scene" : scene} mutableCopy];
    scene.alpha = 100.0;
    return scene;
}

- (SKSpriteNode*)transitionToSceneryWithType:(SceneryType)type sceneSprite:(SKSpriteNode*)sprite {
    _type = type;
    sprite.texture = [SKTexture textureWithImageNamed:self.spriteName];
    sprite.alpha = 0.0;
    return sprite;
}

- (SKAction*)actionToAnimateToScenery {
    SKAction* scaleAction = [SKAction scaleTo:2 duration:0.6];
    scaleAction.timingMode = SKActionTimingEaseOut;
    SKAction* colorAction = [SKAction colorizeWithColor:self.color colorBlendFactor:1.0 duration:0.6];
    colorAction.timingMode = SKActionTimingEaseOut;
    return [SKAction group:@[scaleAction, colorAction]];
}

- (NSString *)particleFileName {
    return [NSString stringWithFormat:@"%@Particles", [self spriteName]];
}

- (NSString *)stampSpriteName {
    return [NSString stringWithFormat:@"%@Stamp", [self spriteName]];
}

+ (SceneryType)sceneryTypeAtRandom {
    NSArray* types = @[@(StageTypeSpace), @(StageTypeCandy), @(StageTypeWhale), @(StageTypeLime), @(StageTypeParty)];
    uint32_t random = arc4random_uniform([types count]);
    NSNumber* randomType = [types objectAtIndex:random];
    SceneryType tt;
    
    if (randomType.intValue == 0) tt = StageTypeLime;
    else if (randomType.intValue == 1) tt = StageTypeWhale;
    else if (randomType.intValue == 2) tt = StageTypeParty;
    else if (randomType.intValue == 3) tt = StageTypeCandy;
    else tt = StageTypeSpace;
    
    return tt;
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _type = [decoder decodeIntForKey:@"type"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_type forKey:@"type"];
}


@end
