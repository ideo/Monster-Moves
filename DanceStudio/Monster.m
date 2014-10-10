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

- (instancetype)initWithType:(MonsterType)type number:(NSUInteger)number {
    
    self = [super init];
    if (self) {
        _type = type;
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
    switch (self.type) {
        case MonsterTypeLeBlob:
            return @"LeBlob";
            
        case MonsterTypeLeBlobBlue:
            return @"LeBlobBlue";
            
        case MonsterTypeLeBlobOrange:
            return @"LeBlobOrange";
            
        default:
            return @"Anonymous";
    }}

- (NSArray*)moves {
    switch (self.type) {
        case MonsterTypeLeBlob:
            return @[@"Egyptian", @"Spin", @"Twist", @"Rockstar", @"Wave", @"Buldge", @"Jump", @"Roof"];
            
        case MonsterTypeLeBlobBlue:
            return @[@"Egyptian", @"Spin", @"Twist", @"Rockstar", @"Wave", @"Buldge", @"Jump", @"Roof"];
            
        case MonsterTypeLeBlobOrange:
            return @[@"Egyptian", @"Spin", @"Twist", @"Rockstar", @"Wave", @"Buldge", @"Jump", @"Roof"];
            
        default:
            return @[];
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _type = [decoder decodeIntForKey:@"type"];
    _evolutionStage = [decoder decodeIntForKey:@"evolutionStage"];
    _sprite = [[MonsterSpriteNode alloc] initWithMonster:self]; // recreate the sprite
    _timeline = [decoder decodeObjectForKey:@"timeline"];
    _number = [decoder decodeIntForKey:@"number"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_type forKey:@"type"];
    [encoder encodeInt:_evolutionStage forKey:@"evolutionStage"];
    [encoder encodeObject:_timeline forKey:@"timeline"];
    [encoder encodeInt:_number forKey:@"number"];
}


@end
