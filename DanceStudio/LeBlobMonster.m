//
//  LeBlobMonster.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "LeBlobMonster.h"

@implementation LeBlobMonster

- (NSString *)name {
    return @"LeBlob";
}

- (NSString *)shortName {
    return @"blob";
}

- (NSString *)eggName {
    return @"Egg1";
}

- (NSArray*)moves {
    return @[@"Egyptian", @"Spin", @"Twist", @"Rock", @"Wave", @"Blow", @"Jump", @"Roof", @"Screw", @"Search"];
}

- (NSString *)backButtonImageName {
    return [NSString stringWithFormat:@"%@BackButton", self.name];
}

- (UIColor *)color {
    return [SKColor colorWithRed:112/255.0 green:56/255.0 blue:162/255.0 alpha:1.0];
}

- (UIColor *)monsterColor {
    return [SKColor colorWithRed:199/255.0 green:130/255.0 blue:234/255.0 alpha:1.0];
}

- (UIColor *)backgroundColor {
    return [SKColor colorWithRed:89/255.0 green:45/255.0 blue:128/255.0 alpha:1.0];
}

@end
