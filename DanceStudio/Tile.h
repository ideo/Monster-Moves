//
//  Tile.h
//  DanceStudio
//
//  Created by Kevin Gaunt on 9/30/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

static NSString * const kTileNodeName = @"movable";
static const uint32_t tileCategory =  0x1 << 0;
static double const kTileScaleFactor = 0.5;

typedef enum TileType {
    TileTypeEgyptian = 0,
    TileTypeRockstar = 1,
    TileTypeSpin = 2,
    TileTypeTwist = 3,
    TileTypeWave = 4,
    TileTypeBlow = 5,
    TileTypeJump = 6,
    TileTypeRoof = 7,
    TileTypeSearch = 8,
    TileTypeBlink = 9,
    TileTypeBreathe = 10,
    TileTypeReactionA = 11,
    TileTypeReactionB = 12,
    TileTypeReactionC = 13,
    TileTypeIdle = 14,
} TileType;

@interface Tile : NSObject<NSCoding>

@property (nonatomic,readonly) TileType type;
@property (nonatomic,readonly) SKColor* color;
@property (nonatomic,readonly) SKSpriteNode* sprite;

- (instancetype)initWithType:(TileType)type;
- (SKAction*)actionOnTouchDown;
- (SKAction*)actionOnTouchUp;

+ (SKAction*)actionForHighlight;
+ (SKAction*)actionForResting;
+ (TileType)tileTypeAtRandom;
+ (TileType)reactionTileTypeAtRandom;

@end