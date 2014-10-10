//
//  Monster.h
//  DanceStudio
//
//  Created by Kevin Gaunt on 08/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateableTile.h"
#import "Timeline.h"

typedef enum MonsterType {
    MonsterTypeLeBlob = 0,
    MonsterTypeLeBlobOrange = 1,
    MonsterTypeLeBlobBlue = 2
} MonsterType;

typedef enum MonsterEvolutionStage {
    MonsterEvolutionEgg = 0,
    MonsterEvolutionEggCracked = 1,
    MonsterEvolutionEggCracked2 = 2,
    MonsterEvolutionEggHatched = 3,
    MonsterEvolutionEggDancing = 4,
} MonsterEvolutionStage;

@interface Monster : NSObject<NSCoding>

@property (nonatomic,readonly) MonsterType type;
@property (nonatomic,readonly) MonsterEvolutionStage evolutionStage;
@property (nonatomic,readonly) UpdateableTile* sprite;
@property (nonatomic,readonly) Timeline* timeline;
@property (nonatomic,readonly) NSUInteger number;
@property (nonatomic,readonly) NSArray* moves;
@property (nonatomic,readonly) NSString* name;

- (instancetype)initWithType:(MonsterType)type number:(NSUInteger)number;
- (MonsterEvolutionStage)evolve;
- (void)update;
- (void)resetTimeline;

@end
