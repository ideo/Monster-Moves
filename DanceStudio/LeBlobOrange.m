//
//  LeBlobOrange.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "LeBlobOrange.h"

@implementation LeBlobOrange

- (NSString *)name {
    return @"LeBlobOrange";
}

- (NSString *)shortName {
    return @"blob";
}

- (NSString *)eggName {
    return @"Egg4";
}

- (NSArray*)moves {
    return @[@"Egyptian", @"Spin", @"Twist", @"Rock", @"Wave", @"Blow", @"Jump", @"Roof", @"Screw", @"Search"];
}

- (NSString *)backButtonImageName {
    return [NSString stringWithFormat:@"%@BackButton", self.name];
}

- (UIColor *)color {
    return [SKColor colorWithRed:255/255.0 green:132/255.0 blue:0/255.0 alpha:1.0];
}

- (UIColor *)monsterColor {
    return [SKColor colorWithRed:255/255.0 green:176/255.0 blue:90/255.0 alpha:1.0];
}

- (UIColor *)backgroundColor {
    return [SKColor colorWithRed:246/255.0 green:107/255.0 blue:5/255.0 alpha:1.0];
}

@end
