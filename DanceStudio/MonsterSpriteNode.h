//
//  Monster.h
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/1/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Tile.h"
#import "UpdateableTile.h"
#import "Monster.h"

static NSString * const kMonsterNodeName = @"monster";
static double const kMonsterScaleFactor = 0.9;
static double const kMonsterScaleFactorEgg = 0.7;
static double const kMonsterYOffset = -140;
static double const kMonsterXOffset = 90;

@interface MonsterSpriteNode : UpdateableTile

@property (nonatomic,readonly) Monster* monster;
@property (nonatomic,readonly) NSString* currentAnimationKey;
@property (nonatomic,readonly) NSString* name;
@property (nonatomic,readonly) SKTexture* defaultTexture;

- (instancetype)initWithMonster:(Monster*)monster;

- (void)tapped;

- (SKAction*)animateMonsterWithTile:(Tile*)tile repeatForever:(BOOL)repeat;
- (SKAction*)idleAnimation;
- (SKAction*)randomReaction;
- (SKAction*)danceWithTile1:(Tile*)t1 tile2:(Tile*)t2 tile3:(Tile*)t3 tile4:(Tile*)t4 repeatForever:(BOOL)repeat;

+ (SKAction *)actionForMonsterAppearing;
+ (SKAction *)actionForMonsterDisappearing;

@end
