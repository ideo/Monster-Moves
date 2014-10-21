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

@interface Tile : NSObject<NSCoding>

@property (nonatomic,readonly) NSString* move;
@property (nonatomic,readonly) NSString* monsterName;
@property (nonatomic,readonly) NSString* monsterShortName;
@property (nonatomic,readonly) NSString* textureName;
@property (nonatomic,readonly) NSString* textureAtlasName;
@property (nonatomic,readonly) NSString* textureAtlasNameSpriteFormat;
@property (nonatomic,readonly) SKColor* color;
@property (nonatomic,readonly) SKSpriteNode* sprite;
@property (nonatomic,readonly) NSString* soundEffectName;

- (instancetype)initWithMove:(NSString*)move monsterName:(NSString*)monsterName monsterShortName:(NSString*)monsterShortName;

+ (SKAction*)actionOnTouchDown;
+ (SKAction*)actionOnTouchUp;
+ (SKAction*)actionForHighlight;
+ (SKAction*)actionForResting;
+ (SKAction*)actionForPlay;
+ (SKAction*)actionForSound:(NSString*)soundFile;

@end