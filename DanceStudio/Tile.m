//
//  Tile.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 9/30/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "Tile.h"
#import "DraggableShapeNode.h"

@implementation Tile

- (instancetype)initWithType:(TileType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (SKColor *)color {
    switch (_type) {
        case TileTypeEgyptian:
            return [SKColor colorWithRed:133/255.0 green:225/255.0 blue:241/255.0 alpha:1];
            
        case TileTypeSpin:
            return [SKColor colorWithRed:236/255.0 green:122/255.0 blue:136/255.0 alpha:1];
            
        case TileTypeTwist:
            return [SKColor colorWithRed:114/255.0 green:113/255.0 blue:187/255.0 alpha:1];
            
        case TileTypeRockstar:
            return [SKColor colorWithRed:167/255.0 green:106/255.0 blue:179/255.0 alpha:1];
            
        case TileTypeWave:
            return [SKColor colorWithRed:91/255.0 green:198/255.0 blue:173/255.0 alpha:1];
            
        case TileTypeBlow:
            return [SKColor colorWithRed:124/255.0 green:91/255.0 blue:151/255.0 alpha:1];
            
        case TileTypeJump:
            return [SKColor colorWithRed:240/255.0 green:177/255.0 blue:72/255.0 alpha:1];
            
        default:
            return [SKColor colorWithWhite:0.5 alpha:1.0];
    }
//    
    //    return [SKColor colorWithRed:240/255.0 green:225/255.0 blue:39/255.0 alpha:1];
    //    return [SKColor colorWithRed:169/255.0 green:211/255.0 blue:127/255.0 alpha:1];
}

- (NSString*) spriteName {
    switch (_type) {
        case TileTypeEgyptian:
            return @"Egyptian";
            
        case TileTypeSpin:
            return @"Spin";
            
        case TileTypeTwist:
            return @"Twist";
            
        case TileTypeRockstar:
            return @"Rockstar";
            
        case TileTypeWave:
            return @"Wave";
            
        case TileTypeBlow:
            return @"Buldge";
            
        case TileTypeJump:
            return @"Jump";
            
        case TileTypeRoof:
            return @"Roof";
            
        default:
            return @"Bounce";
    }
}

- (SKSpriteNode*)sprite {
    DraggableShapeNode* tile = [DraggableShapeNode spriteNodeWithImageNamed:[self spriteName]];
    tile.xScale = 0.01;
    tile.yScale = 0.01;
    tile.name = kTileNodeName;
    tile.zPosition = 0.0;
    tile.userData = nil;
    
    tile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:tile.size.width/2.0];
    tile.physicsBody.dynamic = YES;
    tile.physicsBody.categoryBitMask = tileCategory;
    tile.physicsBody.contactTestBitMask = tileCategory;
    tile.physicsBody.affectedByGravity = NO;
    tile.physicsBody.friction = 0.2;
    tile.physicsBody.restitution = 0.05;
    tile.physicsBody.mass = 7;
    
    return tile;
}

- (SKAction*)actionOnTouchDown {
    SKAction* scaleUp = [SKAction scaleTo:kTileScaleFactor+0.08 duration:0.1];
    scaleUp.timingMode = SKActionTimingEaseOut;
    return scaleUp;
}

- (SKAction*)actionOnTouchUp {
    SKAction* scaleDown = [SKAction scaleTo:kTileScaleFactor duration:0.1];
    scaleDown.timingMode = SKActionTimingEaseOut;
    return scaleDown;
}

+(SKAction*)actionForHighlight {
    SKAction* scaleUp = [SKAction scaleTo:kTileScaleFactor+0.1 duration:0.4];
    scaleUp.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *leftWiggle = [SKAction rotateByAngle:M_PI/12 duration:0.3];
    SKAction *rightWiggle = [leftWiggle reversedAction];
    SKAction *fullWiggle =[SKAction sequence: @[leftWiggle, rightWiggle]];
    SKAction *wiggle = [SKAction repeatActionForever:fullWiggle];
    
    return [SKAction sequence:@[[SKAction group:@[scaleUp]], wiggle]];
}

+ (SKAction*)actionForResting {
    SKAction* scaleDown = [SKAction scaleTo:kTileScaleFactor duration:0.4];
    scaleDown.timingMode = SKActionTimingEaseInEaseOut;
    return [SKAction group:@[scaleDown]];
}

+ (TileType)tileTypeAtRandom {
    NSArray* types = @[@(TileTypeEgyptian), @(TileTypeWave), @(TileTypeRockstar), @(TileTypeSpin), @(TileTypeTwist), @(TileTypeJump), @(TileTypeBlow), @(TileTypeRoof), @(TileTypeSearch)];
    uint32_t random = arc4random_uniform([types count]);
    NSNumber* randomType = [types objectAtIndex:random];
    TileType tt;
    
    if (randomType.intValue == 0) tt = TileTypeEgyptian;
    else if (randomType.intValue == 1) tt = TileTypeRockstar;
    else if (randomType.intValue == 2) tt = TileTypeSpin;
    else if (randomType.intValue == 3) tt = TileTypeTwist;
    else if (randomType.intValue == 4) tt = TileTypeWave;
    else if (randomType.intValue == 5) tt = TileTypeBlow;
    else if (randomType.intValue == 6) tt = TileTypeJump;
    else tt = TileTypeRoof;
    
    return tt;
}

+ (TileType)reactionTileTypeAtRandom {
    NSArray* types = @[@(TileTypeReactionA), @(TileTypeReactionB), @(TileTypeReactionC), @(TileTypeSearch)];
    uint32_t random = arc4random_uniform([types count]);
    NSNumber* randomType = [types objectAtIndex:random];
    TileType tt;
    
    NSLog(@"%d", randomType.intValue);
    
    if (randomType.intValue == 11) tt = TileTypeReactionA;
    else if (randomType.intValue == 12) tt = TileTypeReactionB;
    else if (randomType.intValue == 8) tt = TileTypeSearch;
    else tt = TileTypeReactionC;
    
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