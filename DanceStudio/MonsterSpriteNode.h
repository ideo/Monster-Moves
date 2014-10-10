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
static double const kMonsterScaleFactor = 0.7;
static double const kMonsterYOffset = -140;
static double const kMonsterXOffset = 90;

@interface MonsterSpriteNode : UpdateableTile

@property (nonatomic,readonly) Monster* monster;
@property (nonatomic,readonly) NSString* currentAnimationKey;

- (instancetype)initWithMonster:(Monster*)monster;

- (void)tapped;

- (SKAction*)animateMonsterWithTileType:(TileType)tileType repeatForever:(BOOL)repeat;
- (SKAction*)idleAnimation;
- (SKAction*)randomReaction;
- (SKAction*)danceWithTile1:(TileType)t1 tile2:(TileType)t2 tile3:(TileType)t3 repeatForever:(BOOL)repeat;

@end
