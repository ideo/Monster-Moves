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

typedef enum MonsterEvolutionStage {
    MonsterEvolutionEgg = 0,
    MonsterEvolutionEggCracked = 1,
    MonsterEvolutionEggCracked2 = 2,
    MonsterEvolutionEggHatched = 3,
    MonsterEvolutionEggDancing = 4,
} MonsterEvolutionStage;

@interface Monster : NSObject<NSCoding>

@property (nonatomic,readonly) MonsterEvolutionStage evolutionStage;
@property (nonatomic,readonly) UpdateableTile* sprite;
@property (nonatomic,readonly) Timeline* timeline;
@property (nonatomic,readonly) NSUInteger number;
@property (nonatomic,readonly) NSArray* moves;
@property (nonatomic,readonly) NSString* name;
@property (nonatomic,readonly) NSString* eggName;
@property (nonatomic,readonly) NSString* shortName;
@property (nonatomic,readonly) NSString* backButtonImageName;
@property (nonatomic,readonly) SKColor* color;
@property (nonatomic,readonly) SKColor* monsterColor;
@property (nonatomic,readonly) SKColor* backgroundColor;

- (instancetype)initWithNumber:(NSUInteger)number;
- (MonsterEvolutionStage)evolve;
- (void)update;
- (void)resetTimeline;

@end
