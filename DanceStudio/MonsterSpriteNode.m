//
//  Monster.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/1/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "MonsterSpriteNode.h"
#import "LeBlobBlue.h"
#import "LeBlobOrange.h"
#import "LeBlobMonster.h"

@interface MonsterSpriteNode ()
@property (nonatomic, strong) NSMutableDictionary* textureAtlases;
@property (nonatomic, strong) NSMutableDictionary* animations;
@end

@implementation MonsterSpriteNode {
    NSString* _currentAnimationKey;
}

- (instancetype)initWithMonster:(Monster*)monster {
    
    self = [super initWithImageNamed:@"LeBlob1"];
    if (self) {
        _monster = monster;
        self.xScale = kMonsterScaleFactor;
        self.yScale = kMonsterScaleFactor;
        self.name = kMonsterNodeName;
        
        self.textureAtlases = [[NSMutableDictionary alloc] init];
        
        [self update];
    }
    return self;
}

- (NSString *)name {
    return self.monster.name;
}

- (SKTexture *)defaultTexture {
    NSString* randomMove = self.monster.moves.firstObject;
    Tile* randomTile = [[Tile alloc] initWithMove:randomMove monsterName:self.monster.name monsterShortName:self.monster.shortName];
    _currentAnimationKey = randomTile.textureAtlasName;
    return [self framesForAnimationWithName:_currentAnimationKey fileNameFormat:randomTile.textureAtlasNameSpriteFormat].firstObject;
}

- (void)update {
    [self removeAllActions];
    switch (_monster.evolutionStage) {
        case MonsterEvolutionEgg:
            self.texture = [SKTexture textureWithImageNamed:_monster.eggName];
            self.xScale = kMonsterScaleFactorEgg;
            self.yScale = kMonsterScaleFactorEgg;
            break;
            
        case MonsterEvolutionEggCracked:
            self.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-1", _monster.eggName]];
            self.xScale = kMonsterScaleFactorEgg;
            self.yScale = kMonsterScaleFactorEgg;
            break;
            
        case MonsterEvolutionEggCracked2:
            self.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-2", _monster.eggName]];
            self.xScale = kMonsterScaleFactorEgg;
            self.yScale = kMonsterScaleFactorEgg;
            break;
            
        case MonsterEvolutionEggHatched:
            self.texture = self.defaultTexture;
            self.xScale = kMonsterScaleFactor;
            self.yScale = kMonsterScaleFactor;
            [self runAction:[self idleAnimation]];
            break;
            
        case MonsterEvolutionEggDancing:
            self.texture = self.defaultTexture;
            self.xScale = kMonsterScaleFactor;
            self.yScale = kMonsterScaleFactor;
            [self runAction:[self idleAnimation]];
            break;
            
        default:
            self.texture = self.defaultTexture;
            self.xScale = kMonsterScaleFactor;
            self.yScale = kMonsterScaleFactor;
            [self runAction:[self idleAnimation]];
            break;
    }
}

#pragma mark - Events

- (void)tapped {
    NSLog(@"Tapped the monster");
    [self.monster evolve];
}

#pragma mark - Animations

- (NSString *)currentAnimationKey {
    return _currentAnimationKey;
}

- (NSArray*)framesForAnimationWithName:(NSString*)name fileNameFormat:(NSString*)format {
    NSMutableArray* animatedMonsterFrames = [NSMutableArray array];
    
    SKTextureAtlas* atlas = (SKTextureAtlas*)[self.textureAtlases objectForKey:name];
    if (!atlas) {
        atlas = [SKTextureAtlas atlasNamed:name];
        [self.textureAtlases setObject:atlas forKey:name];
    }
    
    NSUInteger numImages = atlas.textureNames.count;
    for (int i=0; i < numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:format, i];
        SKTexture *temp = [atlas textureNamed:textureName];
        [animatedMonsterFrames addObject:temp];
    }
    return animatedMonsterFrames;
}

- (SKAction*)animateMonsterWithTile:(Tile*)tile repeatForever:(BOOL)repeat {
    _currentAnimationKey = [NSString stringWithFormat:@"%@", tile.textureAtlasName];
    NSString* fileNameFormat = tile.textureAtlasNameSpriteFormat;
    
    
    NSArray* textures = (NSArray*)[self.animations objectForKey:tile.textureAtlasName];
    if (!textures) {
        textures = [self framesForAnimationWithName:self.currentAnimationKey fileNameFormat:fileNameFormat];
        [self.animations setObject:textures forKey:tile.textureAtlasName];
    }
    
    SKAction* soundEffect = [SKAction playSoundFileNamed:tile.soundEffectName waitForCompletion:NO];
    SKAction* action = [SKAction group:@[[SKAction animateWithTextures:textures timePerFrame:0.04f resize:NO restore:YES], soundEffect]];
    
    return repeat ? [SKAction repeatActionForever:action] : action;
}

- (SKAction*)idleAnimation {
    SKAction* breatheSequence = [SKAction sequence:@[[self animateMonsterWithTile:[[Tile alloc] initWithMove:@"Breathe" monsterName:self.monster.name monsterShortName:self.monster.shortName] repeatForever:NO]]];
    return [SKAction repeatActionForever:breatheSequence];
}

- (SKAction*)randomReaction {
    return nil; //[self animateMonsterWithTileType:[Tile reactionTileTypeAtRandom] repeatForever:NO];
}

- (SKAction *)danceWithTile1:(Tile*)t1 tile2:(Tile*)t2 tile3:(Tile*)t3 tile4:(Tile*)t4 repeatForever:(BOOL)repeat {
    MonsterSpriteNode* monsterSprite = (MonsterSpriteNode*)self.monster.sprite;
    SKAction* step1 = [monsterSprite animateMonsterWithTile:t1 repeatForever:NO];
    SKAction* step2 = [monsterSprite animateMonsterWithTile:t2 repeatForever:NO];
    SKAction* step3 = [monsterSprite animateMonsterWithTile:t3 repeatForever:NO];
    SKAction* step4 = [monsterSprite animateMonsterWithTile:t4 repeatForever:NO];
    SKAction* danceSequence = [SKAction sequence:@[step1, step2, step3, step4]];
    return repeat ? [SKAction repeatActionForever:danceSequence] : danceSequence;
}

+ (SKAction *)actionForMonsterAppearing {
    SKAction* fadeAction = [SKAction fadeInWithDuration:0.2];
    fadeAction.timingMode = SKActionTimingEaseOut;
    SKAction* scaleAction = [SKAction scaleTo:kMonsterScaleFactorEgg duration:0.2];
    scaleAction.timingMode = SKActionTimingEaseOut;
    return [SKAction group:@[fadeAction, scaleAction]];
}

+ (SKAction *)actionForMonsterDisappearing {
    SKAction* fadeAction = [SKAction fadeOutWithDuration:0.2];
    fadeAction.timingMode = SKActionTimingEaseIn;
    SKAction* scaleAction = [SKAction scaleTo:0.0001 duration:0.4];
    scaleAction.timingMode = SKActionTimingEaseIn;
    return [SKAction group:@[[SKAction sequence:@[[SKAction waitForDuration:0.18], fadeAction]], scaleAction]];
}

@end
