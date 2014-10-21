//
//  Monster.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 08/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "Monster.h"
#import "MonsterSpriteNode.h"

@implementation Monster

- (instancetype)initWithNumber:(NSUInteger)number {
    
    self = [super init];
    if (self) {
        _evolutionStage = MonsterEvolutionEgg;
        _sprite = [[MonsterSpriteNode alloc] initWithMonster:self];
        _timeline = [[Timeline alloc] init];
        _number = number;
        
        [self update];
    }
    return self;
}

- (MonsterEvolutionStage)evolve {
    if (_evolutionStage != MonsterEvolutionEggDancing) _evolutionStage++;
    [self update];
    return _evolutionStage;
}

- (void)update {
    [self.sprite update];
}

- (void)resetTimeline {
    _timeline = [[Timeline alloc] init];
}

- (NSString *)name {
    @throw [NSError errorWithDomain:@"Not implemented" code:100 userInfo:nil];
}

- (NSArray*)moves {
    @throw [NSError errorWithDomain:@"Not implemented" code:100 userInfo:nil];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _evolutionStage = [decoder decodeIntForKey:@"evolutionStage"];
    _sprite = [[MonsterSpriteNode alloc] initWithMonster:self]; // recreate the sprite
    _timeline = [decoder decodeObjectForKey:@"timeline"];
    _number = [decoder decodeIntForKey:@"number"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_evolutionStage forKey:@"evolutionStage"];
    [encoder encodeObject:_timeline forKey:@"timeline"];
    [encoder encodeInt:_number forKey:@"number"];
}


@end
