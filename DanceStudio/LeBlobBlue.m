//
//  LeBlobBlue.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "LeBlobBlue.h"

@implementation LeBlobBlue

- (NSString *)name {
    return @"LeBlobBlue";
}

- (NSString *)shortName {
    return @"blob";
}

- (NSString *)eggName {
    return @"Egg3";
}


- (NSArray*)moves {
    return @[@"Egyptian", @"Spin", @"Twist", @"Rock", @"Wave", @"Blow", @"Jump", @"Roof", @"Screw", @"Search"];
}

- (NSString *)backButtonImageName {
    return [NSString stringWithFormat:@"%@BackButton", self.name];
}

- (UIColor *)color {
    return [SKColor colorWithRed:23/255.0 green:121/255.0 blue:173/255.0 alpha:1.0];
}

- (UIColor *)monsterColor {
    return [SKColor colorWithRed:58/255.0 green:172/255.0 blue:242/255.0 alpha:1.0];
}

- (UIColor *)backgroundColor {
    return [SKColor colorWithRed:12/255.0 green:96/255.0 blue:140/255.0 alpha:1.0];
}

@end
