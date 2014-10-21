//
//  DanceScene.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 07/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "DanceScene.h"
#import "TrainingStage.h"
#import "Scenery.h"
#import "Monster.h"
#import "LeBlobOrange.h"
#import "LeBlobBlue.h"
#import "LeBlobMonster.h"
#import "SausalitoMonster.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

static NSString * const kSwitchButtonName = @"switchButton";
static NSString * const kStampNodeName = @"stampNode";
static NSString * const kBackgroundNodeName = @"backgroundNode";
static int const kLayerNumberBackground = 0;
static int const kLayerNumberFog = 2;
static int const kLayerNumberMidground = 1;
static int const kLayerNumberMonster = 3;
static int const kLayerNumberUI = 4;

@interface DanceScene ()
@property (nonatomic) SKSpriteNode * stageSprite;
@property (nonatomic) NSArray* monsters;
@property (nonatomic) SKEmitterNode* fogEmitter;
@property (nonatomic) Scenery* scenery;
@property (nonatomic, strong) Scenery* lastScenery;
@property (nonatomic) AudioPlayer* audioPlayer;
@end

@implementation DanceScene {
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    BOOL _transitioning;
    BOOL _readyToTransitionToNextScene;
    CGPoint _switchButtonPosition;
    BOOL _transitionedToNewScenery;
}

-(void)didMoveToView:(SKView *)view {
    [self load];
    
    if (self.scenery) {
        if (self.lastScenery)
            _transitionedToNewScenery = (self.lastScenery.type != self.scenery.type);
        else
            _transitionedToNewScenery = NO;
    } else
        _transitionedToNewScenery = YES;
    
    self.audioPlayer = [[AudioPlayer alloc] init];
    _readyToTransitionToNextScene = NO;
    _switchButtonPosition = CGPointMake(90, self.frame.size.height - 100);
    
    self.backgroundColor = [SKColor colorWithRed:82/255.0 green:60/255.0 blue:102/255.0 alpha:1.0];
    [self initialiseStage];
    
    NSString *fogParticleName = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
    self.fogEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:fogParticleName];
    self.fogEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + 100);
    self.fogEmitter.zPosition = kLayerNumberFog;
    [self.fogEmitter advanceSimulationTime:8];
    [self addChild:self.fogEmitter]; 
    
    Monster* monster1 = [self findMonsterWithNumber:0];
    Monster* monster2 = [self findMonsterWithNumber:1];
    Monster* monster3 = [self findMonsterWithNumber:2];
    
    if (!monster1)
        monster1 = [[LeBlobMonster alloc] initWithNumber:0];
    
    if (!monster2)
        monster2 = [[SausalitoMonster alloc] initWithNumber:1];
    
    if (!monster3)
        monster3 = [[LeBlobBlue alloc] initWithNumber:2];
    
    monster1 = [self initialiseMonster:monster1 inSpaceship:_transitionedToNewScenery];
    monster2 = [self initialiseMonster:monster2 inSpaceship:_transitionedToNewScenery];
    monster3 = [self initialiseMonster:monster3 inSpaceship:_transitionedToNewScenery];
    
    if (!self.monsters)
        self.monsters = @[monster1, monster2, monster3];
    
   NSString *firefliesFilename = [[NSBundle mainBundle] pathForResource:@"Fireflies" ofType:@"sks"];
    SKEmitterNode *firefliesEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:firefliesFilename];
    firefliesEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 250);
    [self addChild:firefliesEmitter];
    
    if (monster1.timeline.isFull && monster2.timeline.isFull && monster3.timeline.isFull) {
        [self celebration];
        //[self initialiseAudio];
        [self initialiseSwitchButton];
    }
    
    if (_transitionedToNewScenery) {
        [self initialiseSwitchButton];
        [self sceneTransitionAnimation:YES];
    }
    
    [self.audioPlayer playMusicForType:self.scenery.audio];
}

- (void)initialiseAudio {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:44100.0], AVSampleRateKey, [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey, [NSNumber numberWithInt:1], AVNumberOfChannelsKey, [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey, nil];
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (recorder) {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    }
    else {
        NSLog(@"%@", [error description]);
    }
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    CGFloat peakInput = [recorder peakPowerForChannel:0];
    //NSLog(@"Average input: %f Peak input: %f", [recorder averagePowerForChannel:0], peakInput);
}

- (Monster*)findMonsterWithNumber:(int)number {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number == %i", number];
    NSArray *filteredArray = [self.monsters filteredArrayUsingPredicate:predicate];
    id firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    return firstFoundObject;
}

#pragma mark - Sprite Setup

- (void)initialiseStage {
    
    if (_transitionedToNewScenery) {
        SceneryType randomSceneryType;
        do { randomSceneryType = [Scenery sceneryTypeAtRandom]; } while (randomSceneryType == self.lastScenery.type);
        self.scenery = [[Scenery alloc] initWithType:randomSceneryType];
    }
    
    self.stageSprite = self.scenery.sprite;
    self.stageSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.stageSprite.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.stageSprite.zPosition = kLayerNumberBackground;
    self.stageSprite.name = kBackgroundNodeName;
    [self addChild:self.stageSprite];
}

- (Monster*)initialiseMonster:(Monster*)monster inSpaceship:(BOOL)inSpaceship {
    MonsterSpriteNode* sprite = (MonsterSpriteNode*)monster.sprite;
    sprite.position = CGPointMake(300 + monster.number * 300, CGRectGetMidY(self.frame) + kMonsterYOffset);
    sprite.zPosition = kLayerNumberMonster;
    sprite.name = kMonsterNodeName;
    
    if (inSpaceship) {
        sprite.alpha = 0.0;
        sprite.xScale = 0.001;
        sprite.yScale = 0.001;
    }
    
    if (monster.number == 1)
        sprite.position = CGPointMake(CGRectGetMidX(self.frame) + 30, CGRectGetMidY(self.frame) + kMonsterYOffset);
    
    [self addChild:sprite];
    
    if (monster.timeline.isFull) {
        //[sprite removeAllActions];
        [sprite runAction:[sprite danceWithTile1:[monster.timeline tileAtSlot:0] tile2:[monster.timeline tileAtSlot:1] tile3:[monster.timeline tileAtSlot:2] tile4:[monster.timeline tileAtSlot:3] repeatForever:YES]];
    }
    
    return monster;
}

- (void)initialiseSwitchButton {
    SKSpriteNode* button = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship_v2"];
    button.xScale = 0.7;
    button.yScale = 0.7;
    button.position = _switchButtonPosition;
    button.zPosition = kLayerNumberUI;
    button.name = kSwitchButtonName;
    [self.scene addChild:button];
    
    SKAction* moveActionUp = [SKAction moveByX:0 y:60 duration:3];
    SKAction* moveActionDown = [SKAction moveByX:0 y:-60 duration:3];
    SKAction* rotateLeft = [SKAction rotateByAngle:[self degToRad:-9] duration:2];
    SKAction* rotateRight = [SKAction rotateByAngle:[self degToRad:7] duration:2];
    moveActionDown.timingMode = SKActionTimingEaseInEaseOut;
    moveActionUp.timingMode = SKActionTimingEaseInEaseOut;
    rotateLeft.timingMode = SKActionTimingEaseInEaseOut;
    rotateRight.timingMode = SKActionTimingEaseInEaseOut;
    
    [button runAction:[SKAction repeatActionForever:[SKAction group:@[[SKAction sequence:@[moveActionDown, moveActionUp]], [SKAction sequence:@[rotateRight, rotateLeft]] ]]]];
}

#pragma mark - Interaction

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch* eachTouch = touches.allObjects.firstObject;
    
    //for (UITouch *eachTouch in touches) {
    CGPoint eachTouchLocation = [eachTouch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:eachTouchLocation];
    
    for (SKNode* node in nodes) {
        if ([node.name isEqualToString:kSwitchButtonName]) {
            NSLog(@"Switch Button Pressed");
            [self runAction:[self.audioPlayer actionToPlaySoundWithType:AudioTypeCloseButtonTapped]];
            [self transitionToNextScenery];
        }
        else if ([node.name isEqualToString:kBackgroundNodeName]) {
            [self addStampAtPoint:eachTouchLocation];
        }
    }
    
    if (!_transitioning) {
    
        for (MonsterSpriteNode *touchedMonster in nodes) {
            if ([touchedMonster isKindOfClass:[MonsterSpriteNode class]] == NO) continue;
            
            [touchedMonster tapped];
            
            for (Monster* monster in self.monsters) {
                if (![touchedMonster.monster isEqual:monster]) continue;
                
                if (monster.evolutionStage < MonsterEvolutionEggHatched)
                    [self runAction:[self.audioPlayer actionToPlaySoundWithType:AudioTypeEggTapped]];
                
                if (monster.evolutionStage > MonsterEvolutionEggHatched) {
                    _transitioning = YES;
                    [self runAction:[self.audioPlayer actionToPlaySoundWithType:AudioTypeTickleMonster]];
                    [self transitionToTrainingStageWith:monster];
                }
            }
        }
        
    }
}

- (void)addStampAtPoint:(CGPoint)point {
    SKSpriteNode* stampNode = [SKSpriteNode spriteNodeWithImageNamed:self.scenery.stampSpriteName];
    stampNode.position = point;
    stampNode.zPosition = kLayerNumberBackground;
    stampNode.name = kStampNodeName;
    stampNode.xScale = 0.6;
    stampNode.yScale = stampNode.xScale;
    stampNode.zRotation = [self degToRad:arc4random_uniform(360)];
    [self addChild:stampNode];
    
    SKAction* fadeAction = [SKAction fadeOutWithDuration:5];
    [stampNode runAction:[SKAction sequence:@[[SKAction waitForDuration:5], fadeAction]] completion:^{
        [stampNode removeFromParent];
    }];
}

#pragma mark - Animations

- (void)celebration {
    NSString *confettiFilename = [[NSBundle mainBundle] pathForResource:self.scenery.particleFileName ofType:@"sks"];
    SKEmitterNode *confettiEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:confettiFilename];
    
    if (self.scenery.type == StageTypeSpace) {
        confettiEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    }
    else if (self.scenery.type == StageTypeWhale) {
        confettiEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 200);
    }
    else {
        confettiEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + 120);
    }
    
    confettiEmitter.zPosition = kLayerNumberMidground;
    [confettiEmitter advanceSimulationTime:23];
    
    [self addChild:confettiEmitter];
    [self runAction:[self.audioPlayer actionToPlaySoundWithType:AudioTypeYeah]];
}

#pragma mark - Transistions

- (void)transitionToTrainingStageWith:(Monster *)monster {
    [self save:monster];
    
    [self runAction:[SKAction waitForDuration:0] completion:^{
        TrainingStage *scene = [TrainingStage sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *transition = [SKTransition crossFadeWithDuration:0.6];
        _transitioning = NO;
        [self.view presentScene:scene transition:transition];
    }];
}


- (void)transitionToNextScenery {
    if (_readyToTransitionToNextScene) {
        [self resetDefaults];
        [self runAction:[SKAction waitForDuration:0.1] completion:^{
            DanceScene *scene = [DanceScene sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            scene.lastScenery = self.scenery;
            SKTransition *transition = [SKTransition fadeWithDuration:1.2];
            [self.view presentScene:scene transition:transition];
        }];
    } else {
        [self sceneTransitionAnimation:NO];
    }
}

- (SKAction*)spaceshipEntryAnimation {
    // Move Spaceship to Center
    SKAction* scaleSpaceshipAnimation = [SKAction scaleTo:1.5 duration:0.6];
    scaleSpaceshipAnimation.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* moveSpaceshipToCenterAnimation = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 200) duration:0.8];
    moveSpaceshipToCenterAnimation.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction* rotateSpaceshipActionLeft = [SKAction rotateToAngle:[self degToRad:-20] duration:0.5];
    SKAction* rotateSpaceshipActionRight = [SKAction rotateToAngle:[self degToRad:5] duration:0.3];
    SKAction* rotateSpaceshipActionMid = [SKAction rotateToAngle:[self degToRad:0] duration:0.1];
    SKAction* rotateSpaceshipSequence = [SKAction repeatAction:[SKAction sequence:@[rotateSpaceshipActionLeft,  rotateSpaceshipActionRight, rotateSpaceshipActionMid]] count:1];
    
    return [SKAction group:@[rotateSpaceshipSequence, scaleSpaceshipAnimation, moveSpaceshipToCenterAnimation]];
}

- (SKAction*)spaceshipExitAnimation {
    // Move away spaceship
    SKAction* scaleSpaceshipAnimation = [SKAction scaleTo:0.7 duration:0.6];
    scaleSpaceshipAnimation.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* moveSpaceshipToCenterAnimation = [SKAction moveTo:CGPointMake(CGRectGetMaxX(self.frame) + 300, self.frame.size.height) duration:0.6];
    moveSpaceshipToCenterAnimation.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* rotateSpaceshipAction = [SKAction rotateToAngle:[self degToRad:-45.0f] duration:0.3];
    rotateSpaceshipAction.timingMode = SKActionTimingEaseInEaseOut;
    
    return [SKAction sequence:@[[SKAction waitForDuration:0.2],[SKAction group:@[scaleSpaceshipAnimation, moveSpaceshipToCenterAnimation, rotateSpaceshipAction]]]];
}

- (SKAction*)monsterZappedUpAnimation {
    SKSpriteNode* spaceshipButton = (SKSpriteNode*)[self childNodeWithName:kSwitchButtonName];
    SKAction* moveAnimation = [SKAction moveTo:spaceshipButton.position duration:0.4];
    moveAnimation.timingMode = SKActionTimingEaseIn;
    return [SKAction sequence:@[[SKAction waitForDuration:0.5 withRange:0.3], [SKAction group:@[moveAnimation, [MonsterSpriteNode actionForMonsterDisappearing]]]]];
}

- (SKAction*)monsterZappedDownAnimation:(CGPoint)monsterPosition {
    SKAction* moveAnimation = [SKAction moveTo:monsterPosition duration:0.4];
    moveAnimation.timingMode = SKActionTimingEaseIn;
    return [SKAction sequence:@[[SKAction waitForDuration:0.5 withRange:0.3], [SKAction group:@[moveAnimation, [MonsterSpriteNode actionForMonsterAppearing]]]]];
}

- (void)sceneTransitionAnimation:(BOOL)isEntry {
    
    SKSpriteNode* spaceshipButton = (SKSpriteNode*)[self childNodeWithName:kSwitchButtonName];
    SKAction* spaceshipEntryAnimation = [self spaceshipEntryAnimation];
    
    [spaceshipButton runAction:spaceshipEntryAnimation completion:^{
        MonsterSpriteNode* monster1 = (MonsterSpriteNode*)[self findMonsterWithNumber:0].sprite;
        MonsterSpriteNode* monster2 = (MonsterSpriteNode*)[self findMonsterWithNumber:1].sprite;
        MonsterSpriteNode* monster3 = (MonsterSpriteNode*)[self findMonsterWithNumber:2].sprite;
        
        SKAction* monsterZappedAnimation1;
        SKAction* monsterZappedAnimation2;
        SKAction* monsterZappedAnimation3;
        
        if ( isEntry ) {
            CGPoint monster1EndPosition = monster1.position;
            CGPoint monster2EndPosition = monster2.position;
            CGPoint monster3EndPosition = monster3.position;
            
            monster1.position = spaceshipButton.position;
            monster2.position = spaceshipButton.position;
            monster3.position = spaceshipButton.position;
            
            monsterZappedAnimation1 = [self monsterZappedDownAnimation:monster1EndPosition];
            monsterZappedAnimation2 = [self monsterZappedDownAnimation:monster2EndPosition];
            monsterZappedAnimation3 = [self monsterZappedDownAnimation:monster3EndPosition];
        }
        else {
            monsterZappedAnimation1 = [self monsterZappedUpAnimation];
            monsterZappedAnimation2 = monsterZappedAnimation1;
            monsterZappedAnimation3 = monsterZappedAnimation1;
        }
        
        [monster1 runAction:monsterZappedAnimation1];
        [monster2 runAction:monsterZappedAnimation2];
        [monster3 runAction:monsterZappedAnimation3 completion:^{
            
            SKAction* spaceshipExitAnimation = [self spaceshipExitAnimation];
            [spaceshipButton runAction:spaceshipExitAnimation completion:^{
                
                [spaceshipButton removeFromParent];
                
                if (isEntry) {
                    if (monster1.monster.timeline.isFull && monster2.monster.timeline.isFull && monster3.monster.timeline.isFull)
                        [self initialiseSwitchButton];
                }
                else {
                    _readyToTransitionToNextScene = YES;
                    [self transitionToNextScenery];
                }
            }];
        }];
    }];
    
    
    if (!isEntry) {
        // Start clouding scene
        SKAction* fogParticleAction = [SKAction customActionWithDuration:7 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            self.fogEmitter.particleScaleSpeed = 10 + elapsedTime * 7;
            self.stageSprite.alpha = 1 - elapsedTime;
        }];
    
        [self.fogEmitter runAction:fogParticleAction];
    }
}

#pragma mark - Save

- (void)save:(Monster*)lastMonster {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedMonsters = [NSKeyedArchiver archivedDataWithRootObject:self.monsters];
    [defaults setObject:encodedMonsters forKey:@"monsters"];
    
    NSData *encodedLastMonster = [NSKeyedArchiver archivedDataWithRootObject:lastMonster];
    [defaults setObject:encodedLastMonster forKey:@"lastMonster"];
    
    NSData *encodedScenery = [NSKeyedArchiver archivedDataWithRootObject:self.scenery];
    [defaults setObject:encodedScenery forKey:@"scenery"];
    
    /*NSData *encodedLastScenery = [NSKeyedArchiver archivedDataWithRootObject:self.scenery];
    [defaults setObject:encodedLastScenery forKey:@"lastScenery"];*/
    
    [defaults synchronize];
}

- (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData* monsterData = [defaults objectForKey:@"monsters"];
    self.monsters = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:monsterData];
    
    NSData* sceneryData = [defaults objectForKey:@"scenery"];
    self.scenery = (Scenery*)[NSKeyedUnarchiver unarchiveObjectWithData:sceneryData];
    
    /*NSData* lastSceneryData = [defaults objectForKey:@"lastScenery"];
    self.lastScenery = (Scenery*)[NSKeyedUnarchiver unarchiveObjectWithData:lastSceneryData];*/
}


- (void)resetDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"monsters"];
    [defaults removeObjectForKey:@"lastMonster"];
    [defaults removeObjectForKey:@"scenery"];
    [defaults removeObjectForKey:@"lastScenery"];
    [defaults synchronize];
}

- (float)degToRad:(float) degree {
    return degree / 180.0f * M_PI;
}

@end
