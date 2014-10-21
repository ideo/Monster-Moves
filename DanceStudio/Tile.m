//
//  Tile.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 9/30/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "Tile.h"
#import "DraggableShapeNode.h"

@implementation Tile {
    SKSpriteNode* _sprite;
}

- (instancetype)initWithMove:(NSString*)move monsterName:(NSString*)monsterName monsterShortName:(NSString*)monsterShortName{
    self = [super init];
    if (self) {
        _move = move;
        _monsterName = monsterName;
        _monsterShortName = monsterShortName;
    }
    return self;
}

- (NSString *)textureName {
    return [NSString stringWithFormat:@"%@%@", self.monsterName, self.move];
}

- (NSString *)textureAtlasName {
    return [NSString stringWithFormat:@"%@Animation%@", self.monsterName, self.move];
}

- (NSString *)textureAtlasNameSpriteFormat {
    return [NSString stringWithFormat:@"%@_%@%@", self.monsterShortName, [self.move lowercaseString], @"%03d"];
}

- (SKSpriteNode*)sprite {
    if (_sprite) return _sprite;
    
    DraggableShapeNode* tile = [DraggableShapeNode spriteNodeWithImageNamed:self.textureName];
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
    
    _sprite = tile;
    
    return _sprite;
}

- (NSString *)soundEffectName {
    return [NSString stringWithFormat:@"%@.%@", self.textureName, @"mp3"];
}

#pragma mark - Animations

+ (SKAction*)actionOnTouchDown {
    SKAction* scaleUp = [SKAction scaleTo:kTileScaleFactor+0.08 duration:0.1];
    scaleUp.timingMode = SKActionTimingEaseOut;
    return scaleUp;
}

+ (SKAction*)actionOnTouchUp {
    SKAction* scaleDown = [SKAction scaleTo:kTileScaleFactor duration:0.1];
    scaleDown.timingMode = SKActionTimingEaseOut;
    return scaleDown;
}

+ (SKAction*)actionForHighlight {
    SKAction* scaleUp = [SKAction scaleTo:kTileScaleFactor+0.25 duration:0.4];
    scaleUp.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *leftWiggle = [SKAction rotateByAngle:M_PI/12 duration:0.3];
    SKAction *rightWiggle = [leftWiggle reversedAction];
    SKAction *fullWiggle =[SKAction sequence: @[leftWiggle, rightWiggle]];
    SKAction *wiggle = [SKAction repeatActionForever:fullWiggle];
    //SKAction *colorize = [SKAction colorizeWithColor:[SKColor yellowColor] colorBlendFactor:1.0 duration:0.3];
    
    return [SKAction sequence:@[[SKAction group:@[scaleUp]], wiggle]];
}

+ (SKAction*)actionForResting {
    SKAction* scaleDown = [SKAction scaleTo:kTileScaleFactor+0.05 duration:0.4];
    scaleDown.timingMode = SKActionTimingEaseInEaseOut;
    return [SKAction group:@[scaleDown]];
}

+ (SKAction *)actionForPlay {
    SKAction* rotate = [SKAction rotateByAngle:degToRad(-360.0) duration:1];
    rotate.timingMode = SKActionTimingEaseInEaseOut;
    return [SKAction group:@[rotate]];
}

+ (SKAction *)actionForSound:(NSString *)soundFile {
    return [SKAction playSoundFileNamed:soundFile waitForCompletion:NO];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _move = [decoder decodeObjectForKey:@"move"];
    _monsterName = [decoder decodeObjectForKey:@"monsterName"];
    _monsterShortName = [decoder decodeObjectForKey:@"monsterShortName"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_move forKey:@"move"];
    [encoder encodeObject:_monsterName forKey:@"monsterName"];
    [encoder encodeObject:_monsterShortName forKey:@"monsterShortName"];
}


float degToRad(float degree) {
    return degree / 180.0f * M_PI;
}


@end