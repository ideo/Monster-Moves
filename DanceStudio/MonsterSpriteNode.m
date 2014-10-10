//
//  Monster.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/1/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "MonsterSpriteNode.h"

@interface MonsterSpriteNode ()
@property (nonatomic) NSString* waveAnimationName;
@property (nonatomic) NSString* egyptianAnimationName;
@property (nonatomic) NSString* spinAnimationName;
@property (nonatomic) NSString* rockAnimationName;
@property (nonatomic) NSString* twistAnimationName;
@property (nonatomic) NSString* blowAnimationName;
@property (nonatomic) NSString* jumpAnimationName;

@property (nonatomic) NSString* blinkAnimationName;
@property (nonatomic) NSString* breatheAnimationName;
@property (nonatomic) NSString* reactionAAnimationName;
@property (nonatomic) NSString* reactionBAnimationName;
@property (nonatomic) NSString* reactionCAnimationName;
@property (nonatomic) NSString* roofAnimationName;
@property (nonatomic) NSString* searchAnimationName;
@end

@implementation MonsterSpriteNode {
    NSString* _currentAnimationKey;
    
    SKAction* _waveAnimation;
    SKAction* _spinAnimation;
    SKAction* _egyptianAnimation;
    SKAction* _rockAnimation;
    SKAction* _twistAnimation;
    SKAction* _blowAnimation;
    SKAction* _jumpAnimation;
    SKAction* _blinkAnimation;
    SKAction* _breatheAnimation;
    SKAction* _roofAnimation;
}

- (instancetype)initWithMonster:(Monster*)monster {
    
    self = [super initWithImageNamed:@"LeBlob1"];
    if (self) {
        
        _monster = monster;
        
        switch (monster.type) {
            case MonsterTypeLeBlob:
                self.waveAnimationName = @"LeBlobAnimationWave";
                self.egyptianAnimationName = @"LeBlobAnimationEgyptian";
                self.spinAnimationName = @"LeBlobAnimationSpin";
                self.rockAnimationName = @"LeBlobAnimationRock";
                self.twistAnimationName = @"LeBlobAnimationTwist";
                self.blowAnimationName = @"LeBlobAnimationBlow";
                self.jumpAnimationName = @"LeBlobAnimationJump";
                self.blinkAnimationName = @"LeBlobAnimationBlink";
                self.breatheAnimationName = @"LeBlobAnimationBreathe";
                self.reactionAAnimationName = @"LeBlobAnimationReactionA";
                self.reactionBAnimationName = @"LeBlobAnimationReactionB";
                self.reactionCAnimationName = @"LeBlobAnimationReactionC";
                self.roofAnimationName = @"LeBlobAnimationRoof";
                self.searchAnimationName = @"LeBlobAnimationSearch";
                break;
                
            case MonsterTypeLeBlobOrange:
                self.waveAnimationName = @"LeBlobOrangeAnimationWave";
                self.egyptianAnimationName = @"LeBlobOrangeAnimationEgyptian";
                self.spinAnimationName = @"LeBlobOrangeAnimationSpin";
                self.rockAnimationName = @"LeBlobOrangeAnimationRock";
                self.twistAnimationName = @"LeBlobOrangeAnimationTwist";
                self.blowAnimationName = @"LeBlobOrangeAnimationBlow";
                self.jumpAnimationName = @"LeBlobOrangeAnimationJump";
                self.blinkAnimationName = @"LeBlobOrangeAnimationBlink";
                self.breatheAnimationName = @"LeBlobOrangeAnimationBreathe";
                self.reactionAAnimationName = @"LeBlobOrangeAnimationReactionA";
                self.reactionBAnimationName = @"LeBlobOrangeAnimationReactionB";
                self.reactionCAnimationName = @"LeBlobOrangeAnimationReactionC";
                self.roofAnimationName = @"LeBlobOrangeAnimationRoof";
                self.searchAnimationName = @"LeBlobOrangeAnimationSearch";
                break;
                
            case MonsterTypeLeBlobBlue:
                self.waveAnimationName = @"LeBlobBlueAnimationWave";
                self.egyptianAnimationName = @"LeBlobBlueAnimationEgyptian";
                self.spinAnimationName = @"LeBlobBlueAnimationSpin";
                self.rockAnimationName = @"LeBlobBlueAnimationRock";
                self.twistAnimationName = @"LeBlobBlueAnimationTwist";
                self.blowAnimationName = @"LeBlobBlueAnimationBlow";
                self.jumpAnimationName = @"LeBlobBlueAnimationJump";
                self.blinkAnimationName = @"LeBlobBlueAnimationBlink";
                self.breatheAnimationName = @"LeBlobBlueAnimationBreathe";
                self.reactionAAnimationName = @"LeBlobBlueAnimationReactionA";
                self.reactionBAnimationName = @"LeBlobBlueAnimationReactionB";
                self.reactionCAnimationName = @"LeBlobBlueAnimationReactionC";
                self.roofAnimationName = @"LeBlobBlueAnimationRoof";
                self.searchAnimationName = @"LeBlobBlueAnimationSearch";
                break;
                
            default:
                break;
        }
        
        
        _waveAnimation = [self animateMonsterWithTileType:TileTypeWave repeatForever:NO];
        _egyptianAnimation = [self animateMonsterWithTileType:TileTypeEgyptian repeatForever:NO];
        _spinAnimation = [self animateMonsterWithTileType:TileTypeSpin repeatForever:NO];
        _rockAnimation = [self animateMonsterWithTileType:TileTypeRockstar repeatForever:NO];
        _blowAnimation = [self animateMonsterWithTileType:TileTypeBlow repeatForever:NO];
        _twistAnimation = [self animateMonsterWithTileType:TileTypeTwist repeatForever:NO];
        _jumpAnimation = [self animateMonsterWithTileType:TileTypeJump repeatForever:NO];
        _roofAnimation = [self animateMonsterWithTileType:TileTypeRoof repeatForever:NO];
        
        self.xScale = kMonsterScaleFactor;
        self.yScale = kMonsterScaleFactor;
        self.name = kMonsterNodeName;
        
        [self update];
    }
    return self;
}

- (void)update {
    [self removeAllActions];
    switch (_monster.evolutionStage) {
        case MonsterEvolutionEgg:
            self.texture = _monster.type == MonsterTypeLeBlob ? [SKTexture textureWithImageNamed:@"Egg1"] : [SKTexture textureWithImageNamed:@"Egg2"];
            break;
            
        case MonsterEvolutionEggCracked:
            self.texture = _monster.type == MonsterTypeLeBlob ? [SKTexture textureWithImageNamed:@"Egg1-1"] : [SKTexture textureWithImageNamed:@"Egg2-1"];
            break;
            
        case MonsterEvolutionEggCracked2:
            self.texture = _monster.type == MonsterTypeLeBlob ? [SKTexture textureWithImageNamed:@"Egg1-2"] : [SKTexture textureWithImageNamed:@"Egg2-2"];
            break;
            
        case MonsterEvolutionEggHatched:
            self.texture = [self framesForAnimationWithName:self.waveAnimationName fileNameFormat:@"blob_wave%03d"][0];
            [self runAction:[self idleAnimation]];
            break;
            
        case MonsterEvolutionEggDancing:
            self.texture = [self framesForAnimationWithName:self.waveAnimationName fileNameFormat:@"blob_wave%03d"][0];
            [self runAction:[self idleAnimation]];
            break;
            
        default:
            self.texture = [self framesForAnimationWithName:self.waveAnimationName fileNameFormat:@"blob_wave%03d"][0];
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
    SKTextureAtlas* monsterAnimatedAtlas = [SKTextureAtlas atlasNamed:name];
    int numImages = monsterAnimatedAtlas.textureNames.count;
    for (int i=0; i < numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:format, i];
        SKTexture *temp = [monsterAnimatedAtlas textureNamed:textureName];
        [animatedMonsterFrames addObject:temp];
    }
    return animatedMonsterFrames;
}

- (SKAction*)animateMonsterWithTileType:(TileType)tileType repeatForever:(BOOL)repeat {
    NSString* fileNameFormat;
    
    switch (tileType) {
        case TileTypeWave:
            if (_waveAnimation) return _waveAnimation;
            _currentAnimationKey = self.waveAnimationName;
            fileNameFormat = @"blob_wave%03d";
            break;
        case TileTypeEgyptian:
            if (_egyptianAnimation) return _egyptianAnimation;
            _currentAnimationKey = self.egyptianAnimationName;
            fileNameFormat = @"blob_egyptian%03d";
            break;
        case TileTypeSpin:
            if (_spinAnimation) return _spinAnimation;
            _currentAnimationKey = self.spinAnimationName;
            fileNameFormat = @"blob_spin%03d";
            break;
        case TileTypeRockstar:
            if (_rockAnimation) return _rockAnimation;
            _currentAnimationKey = self.rockAnimationName;
            fileNameFormat = @"blob_rock%03d";
            break;
        case TileTypeTwist:
            if (_twistAnimation) return _twistAnimation;
            _currentAnimationKey = self.twistAnimationName;
            fileNameFormat = @"blob_twist%03d";
            break;
        case TileTypeBlow:
            if (_blowAnimation) return _blowAnimation;
            _currentAnimationKey = self.blowAnimationName;
            fileNameFormat = @"blob_blow%03d";
            break;
        case TileTypeJump:
            if (_jumpAnimation) return _jumpAnimation;
            _currentAnimationKey = self.jumpAnimationName;
            fileNameFormat = @"blob_jump%03d";
            break;
        case TileTypeBlink:
            _currentAnimationKey = self.blinkAnimationName;
            fileNameFormat = @"blob_blink%03d";
            break;
        case TileTypeBreathe:
            _currentAnimationKey = self.breatheAnimationName;
            fileNameFormat = @"blob_breathe%03d";
            break;
        case TileTypeReactionA:
            _currentAnimationKey = self.reactionAAnimationName;
            fileNameFormat = @"blob_reactionA%03d";
            break;
        case TileTypeReactionB:
            _currentAnimationKey = self.reactionBAnimationName;
            fileNameFormat = @"blob_reactionB%03d";
            break;
        case TileTypeReactionC:
            _currentAnimationKey = self.reactionCAnimationName;
            fileNameFormat = @"blob_reactionC%03d";
            break;
        case TileTypeRoof:
            if (_roofAnimation) return _roofAnimation;
            _currentAnimationKey = self.roofAnimationName;
            fileNameFormat = @"blob_roof%03d";
            break;
        case TileTypeSearch:
            _currentAnimationKey = self.searchAnimationName;
            fileNameFormat = @"blob_search%03d";
            break;
        default:
            _currentAnimationKey = self.breatheAnimationName;
            fileNameFormat = @"blob_breathe%03d";
            break;
    }
    
    SKAction* action = [SKAction animateWithTextures:[self framesForAnimationWithName:self.currentAnimationKey fileNameFormat:fileNameFormat] timePerFrame:0.04f resize:NO restore:YES];
    
    return repeat ? [SKAction repeatActionForever:action] : action;
}

- (SKAction*)idleAnimation {
    SKAction* breatheSequence = [SKAction sequence:@[[self animateMonsterWithTileType:TileTypeBreathe repeatForever:NO],
                                                     [self animateMonsterWithTileType:TileTypeBreathe repeatForever:NO],
                                                     [self animateMonsterWithTileType:TileTypeBreathe repeatForever:NO],
                                                     [self animateMonsterWithTileType:TileTypeBreathe repeatForever:NO],
                                                     [self animateMonsterWithTileType:TileTypeBreathe repeatForever:NO],
                                                     [self animateMonsterWithTileType:TileTypeBreathe repeatForever:NO],
                                                     [self animateMonsterWithTileType:TileTypeBreathe repeatForever:NO],
                                                     [self animateMonsterWithTileType:TileTypeBlink repeatForever:NO]]];
    return [SKAction repeatActionForever:breatheSequence];
}

- (SKAction*)randomReaction {
    return [self animateMonsterWithTileType:[Tile reactionTileTypeAtRandom] repeatForever:NO];
}

- (SKAction *)danceWithTile1:(TileType)t1 tile2:(TileType)t2 tile3:(TileType)t3 repeatForever:(BOOL)repeat {
    MonsterSpriteNode* monsterSprite = (MonsterSpriteNode*)self.monster.sprite;
    SKAction* step1 = [monsterSprite animateMonsterWithTileType:t1 repeatForever:NO];
    SKAction* step2 = [monsterSprite animateMonsterWithTileType:t2 repeatForever:NO];
    SKAction* step3 = [monsterSprite animateMonsterWithTileType:t3 repeatForever:NO];
    SKAction* danceSequence = [SKAction sequence:@[step1, step2, step3]];
    return repeat ? [SKAction repeatActionForever:danceSequence] : danceSequence;
}

@end
