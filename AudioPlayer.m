//
//  AudioPlayer.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/2/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "AudioPlayer.h"
@import AVFoundation;


@interface AudioPlayer ()
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) SKAction* actionSoundTapped;
@property (nonatomic) SKAction* actionSoundSnapIntoPlace1;
@property (nonatomic) SKAction* actionSoundSnapIntoPlace2;
@property (nonatomic) SKAction* actionSoundSnapIntoPlace3;
@property (nonatomic) SKAction* actionSoundTickleMonster;
@property (nonatomic) SKAction* actionSoundPlayButton;
@property (nonatomic) SKAction* actionSoundCloseButton;
@property (nonatomic) SKAction* actionSoundYeah;
@property (nonatomic) SKAction* actionSoundEgg;

@end

@implementation AudioPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actionSoundTapped = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypePlayButtonTapped] waitForCompletion:NO];
        self.actionSoundSnapIntoPlace1 = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypeSnapIntoPlace1] waitForCompletion:NO];
        self.actionSoundSnapIntoPlace2 = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypeSnapIntoPlace2] waitForCompletion:NO];
        self.actionSoundSnapIntoPlace3 = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypeSnapIntoPlace3] waitForCompletion:NO];
        self.actionSoundTickleMonster = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypeTickleMonster] waitForCompletion:NO];
        self.actionSoundPlayButton = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypePlayButtonTapped] waitForCompletion:NO];
        self.actionSoundCloseButton = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypeCloseButtonTapped] waitForCompletion:NO];
        self.actionSoundYeah = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypeYeah] waitForCompletion:NO];
        self.actionSoundEgg = [SKAction playSoundFileNamed:[self fileNameForType:AudioTypeEggTapped] waitForCompletion:NO];
    }
    return self;
}

- (NSString *)fileNameForType:(AudioType)type {
    
    switch (type) {
        case AudioTypeTileTapped:
            return @"Tap1.wav";
            
        case AudioTypeSnapIntoPlace1:
            return @"Snap1.WAV";
            
        case AudioTypeSnapIntoPlace2:
            return @"Snap2.WAV";
            
        case AudioTypeSnapIntoPlace3:
            return @"Snap3.mp3";
            
        case AudioTypeTickleMonster:
            return @"grunt.mp3";
            
        case AudioTypePlayButtonTapped:
            return @"Tap2.wav";
            
        case AudioTypeCloseButtonTapped:
            return @"Tap3.wav";
            
        case AudioTypeEggTapped:
            return @"eggshell-crack.wav";
            
        case AudioTypeYeah:
            return @"yeah.wav";
            
        default:
            return [self fileNameForType:AudioTypeTileTapped];
    }
}

- (NSURL*)urlForMusicType:(AudioType)type {
    
    switch (type) {
        case AudioTypeMusicBurningMan:
            return [[NSBundle mainBundle] URLForResource:@"BurningMan" withExtension:@"WAV"];
            
        case AudioTypeMusicCelebration:
            return [[NSBundle mainBundle] URLForResource:@"Celebration" withExtension:@"mp3"];
            
        case AudioTypeMusicParty:
            return [[NSBundle mainBundle] URLForResource:@"Party" withExtension:@"m4a"];
            
        case AudioTypeMusicSpace:
            return [[NSBundle mainBundle] URLForResource:@"Space" withExtension:@"m4a"];
            
        case AudioTypeMusicWhale:
            return [[NSBundle mainBundle] URLForResource:@"Whale" withExtension:@"m4a"];
            
        case AudioTypeDrumLoop:
            return [[NSBundle mainBundle] URLForResource:@"drumloop" withExtension:@"mp3"];
        
        default:
            return [[NSBundle mainBundle] URLForResource:@"Whale" withExtension:@"m4a"];
    }
}
//
//- (SKAction *)actionToPlaySoundWithType:(AudioType)type {
//    return [SKAction playSoundFileNamed:[self fileNameForType:type] waitForCompletion:NO];
//}


- (SKAction *)actionToPlaySoundWithType:(AudioType)type {
    switch (type) {
        case AudioTypeTileTapped:
            return self.actionSoundTapped;
            
        case AudioTypeSnapIntoPlace1:
            return self.actionSoundSnapIntoPlace1;
            
        case AudioTypeSnapIntoPlace2:
            return self.actionSoundSnapIntoPlace2;
            
        case AudioTypeSnapIntoPlace3:
            return self.actionSoundSnapIntoPlace3;
            
        case AudioTypeTickleMonster:
            return self.actionSoundTickleMonster;
            
        case AudioTypePlayButtonTapped:
            return self.actionSoundPlayButton;
            
        case AudioTypeCloseButtonTapped:
            return self.actionSoundCloseButton;
            
        case AudioTypeYeah:
            return self.actionSoundYeah;
            
        case AudioTypeEggTapped:
            return self.actionSoundEgg;
            
        default:
            return self.actionSoundTapped;
    }
}


- (AudioType)audioTypeForRandomSnappedSound {
    NSArray* types = @[@(AudioTypeSnapIntoPlace1), @(AudioTypeSnapIntoPlace2), @(AudioTypeSnapIntoPlace3)];
    uint32_t random = arc4random_uniform([types count]);
    NSNumber* randomType = [types objectAtIndex:random];
    AudioType at;
    
    if (randomType.intValue == 0) at = AudioTypeSnapIntoPlace1;
    else if (randomType.intValue == 1) at = AudioTypeSnapIntoPlace2;
    else at = AudioTypeSnapIntoPlace3;
    
    return at;
}

- (SKAction*)actionToPlayRandomSnappedSound {
    return [SKAction playSoundFileNamed:[self fileNameForType:[self audioTypeForRandomSnappedSound]] waitForCompletion:NO];
}

- (void)playMusicForType:(AudioType)type {
    if (self.backgroundMusicPlayer.playing) {
        [self.backgroundMusicPlayer stop];
    }
    
    NSError *error;
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self urlForMusicType:type] error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    //[self.backgroundMusicPlayer play];
}

- (void)stopMusic {
    [self.backgroundMusicPlayer stop];
}

@end
