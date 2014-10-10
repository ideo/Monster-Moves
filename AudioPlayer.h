//
//  AudioPlayer.h
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/2/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface AudioPlayer : NSObject

typedef enum AudioType {
    AudioTypeTileTapped,
    AudioTypeSnapIntoPlace1,
    AudioTypeSnapIntoPlace2,
    AudioTypeSnapIntoPlace3,
    AudioTypeTickleMonster,
    AudioTypePlayButtonTapped,
    AudioTypeCloseButtonTapped,
    AudioTypeMusicBurningMan,
    AudioTypeMusicSpace,
    AudioTypeMusicCelebration,
    AudioTypeMusicBeach,
    AudioTypeMusicParty,
    AudioTypeMusicWhale
} AudioType;

- (SKAction*)actionToPlaySoundWithType:(AudioType)type;
- (SKAction*)actionToPlayRandomSnappedSound;
- (void)playMusicForType:(AudioType)type;
- (void)stopMusic;

@end
