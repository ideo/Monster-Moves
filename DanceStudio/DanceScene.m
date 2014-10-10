//
//  DanceScene.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 07/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "DanceScene.h"
#import "TrainingStage.h"
#import "Stage.h"
#import "Monster.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface DanceScene ()
@property (nonatomic) SKSpriteNode * stageSprite;
@property (nonatomic) NSArray* monsters;
@property (nonatomic) SKEmitterNode* fogEmitter;
@property (nonatomic) SKEmitterNode* confettiEmitter;
@end

@implementation DanceScene {
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
}

-(void)didMoveToView:(SKView *)view {
    [self load];
    
    self.backgroundColor = [SKColor colorWithRed:82/255.0 green:60/255.0 blue:102/255.0 alpha:1.0];
    [self initialiseStage];
    
    NSString *fogParticleName = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
    self.fogEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:fogParticleName];
    self.fogEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + 100);
    [self addChild:self.fogEmitter];
    
    Monster* monster1 = [self findMonsterWithNumber:0];
    Monster* monster2 = [self findMonsterWithNumber:1];
    Monster* monster3 = [self findMonsterWithNumber:2];
    
    monster1 = [self initialiseMonster:monster1 type:MonsterTypeLeBlob number:0];
    monster2 = [self initialiseMonster:monster2 type:MonsterTypeLeBlobOrange number:1];
    monster3 = [self initialiseMonster:monster3 type:MonsterTypeLeBlobBlue number:2];
    
    if (!self.monsters)
        self.monsters = @[monster1, monster2, monster3];
    
    NSString *firefliesFilename = [[NSBundle mainBundle] pathForResource:@"Fireflies" ofType:@"sks"];
    SKEmitterNode *firefliesEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:firefliesFilename];
    firefliesEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 250);
    [self addChild:firefliesEmitter];
    
    if (monster1.timeline.isFull && monster2.timeline.isFull && monster3.timeline.isFull) {
        [self celebration];
        [self initialiseAudio];
    }
    
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
    NSLog(@"Average input: %f Peak input: %f", [recorder averagePowerForChannel:0], peakInput);
    
    if (peakInput == 0.0) {
        [self runAction:[SKAction customActionWithDuration:2 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            self.confettiEmitter.particleBirthRate = 900.0;
        }] completion:^{
            self.confettiEmitter.particleBirthRate = 0.0;
        }];
    }
    
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
    Stage* stage = [[Stage alloc] initWithType:StageTypeBurningMan];
    self.stageSprite = stage.sprite;
    self.stageSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.stageSprite.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [self addChild:self.stageSprite];
}

- (Monster*)initialiseMonster:(Monster*)monster type:(MonsterType)type number:(int)number {
    if (!monster)
        monster = [[Monster alloc] initWithType:type number:number];
    
    MonsterSpriteNode* sprite = (MonsterSpriteNode*)monster.sprite;
    sprite.position = CGPointMake(300 + monster.number * 300, CGRectGetMidY(self.frame) + kMonsterYOffset);
    [self addChild:sprite];
    
    if (monster.timeline.isFull) {
        //[sprite removeAllActions];
        [sprite runAction:[sprite danceWithTile1:[monster.timeline tileAtSlot:0].type tile2:[monster.timeline tileAtSlot:1].type tile3:[monster.timeline tileAtSlot:2].type repeatForever:YES]];
    }
    
    return monster;
}

#pragma mark - Interaction

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch* eachTouch = touches.allObjects.firstObject;
    
    //for (UITouch *eachTouch in touches) {
        CGPoint eachTouchLocation = [eachTouch locationInNode:self];
        NSArray *nodes = [self nodesAtPoint:eachTouchLocation];
        
        for (MonsterSpriteNode *touchedMonster in nodes) {
            if ([touchedMonster isKindOfClass:[MonsterSpriteNode class]] == NO) continue;
            
            [touchedMonster tapped];
            
            for (Monster* monster in self.monsters) {
                if (![touchedMonster.monster isEqual:monster]) continue;
                
                if (monster.evolutionStage > MonsterEvolutionEggHatched) {
                    [self save:monster];
                    
                    [self runAction:[SKAction waitForDuration:0] completion:^{
                        TrainingStage *scene = [TrainingStage sceneWithSize:self.view.bounds.size];
                        scene.scaleMode = SKSceneScaleModeAspectFill;
                        SKTransition *transition = [SKTransition crossFadeWithDuration:0.6];
                        [self.view presentScene:scene transition:transition];
                    }];
                }
            }
        }
    //}
}

#pragma mark - Animations

- (void)celebration {
    NSString *confettiFilename = [[NSBundle mainBundle] pathForResource:@"CelebrationConfetti" ofType:@"sks"];
    SKEmitterNode *confettiEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:confettiFilename];
    confettiEmitter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
    [self addChild:confettiEmitter];
    
    self.confettiEmitter = confettiEmitter;
    self.confettiEmitter.particleBirthRate = 0.0;
}

#pragma mark - Save

- (void)save:(Monster*)lastMonster {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedMonsters = [NSKeyedArchiver archivedDataWithRootObject:self.monsters];
    [defaults setObject:encodedMonsters forKey:@"monsters"];
    
    NSData *encodedLastMonster = [NSKeyedArchiver archivedDataWithRootObject:lastMonster];
    [defaults setObject:encodedLastMonster forKey:@"lastMonster"];
    
    [defaults synchronize];
}

- (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData* monsterData = [defaults objectForKey:@"monsters"];
    self.monsters = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:monsterData];
}

@end
