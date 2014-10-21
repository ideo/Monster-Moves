//
//  Timeline.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 07/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "Timeline.h"

@interface Timeline ()
@property NSMutableDictionary* timelineDictionary;
@end

@implementation Timeline

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timelineDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return self;
}

- (BOOL)isFull {
    return self.timelineDictionary.count >= 4;
}

- (NSNumber*)nextAvailableSlot {
    if (self.isFull) return nil;
    return [NSNumber numberWithInt:(int)self.timelineDictionary.count];
}

- (CGPoint)positionForSlot:(int)slot {
    int defaultOffsetX = 281;
    int defaultOffsetY = 90;
    
    int calculatedOffsetX = defaultOffsetX + (161*slot);
    
    return CGPointMake(calculatedOffsetX, defaultOffsetY);
}

- (NSNumber*)addTile:(Tile *)tile {
    if (self.isFull) return nil;
    NSNumber* nextSlot = self.nextAvailableSlot;
    [self.timelineDictionary setObject:tile forKey:[NSString stringWithFormat:@"Slot%@", nextSlot.stringValue]];
    return nextSlot;
}

- (void)removeTile:(Tile *)tile {
    if (self.timelineDictionary.count == 0) return;
    [self.timelineDictionary delete:tile];
}

- (Tile *)tileAtSlot:(int)slot {
    return [self.timelineDictionary objectForKey:[NSString stringWithFormat:@"Slot%@", @(slot).stringValue]];
}

- (BOOL)contains:(Tile *)tile {
    return [self.timelineDictionary.allValues containsObject:tile];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.timelineDictionary = [decoder decodeObjectForKey:@"timelineDictionary"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.timelineDictionary forKey:@"timelineDictionary"];
}


@end
