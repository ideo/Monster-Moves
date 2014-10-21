//
//  SausalitoMonster.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 10/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "SausalitoMonster.h"

@implementation SausalitoMonster

- (NSString *)name {
    return @"Sausalito";
}

- (NSString *)shortName {
    return @"sausalito";
}

- (NSString *)eggName {
    return @"Egg5";
}

- (NSArray*)moves {
    return @[@"Eye", @"Flip", @"Puffer", @"Spin", @"Stretch", @"Wave"];
}

- (NSString *)backButtonImageName {
    return [NSString stringWithFormat:@"%@BackButton", self.name];
}

- (UIColor *)color {
    return [SKColor colorWithRed:229/255.0 green:91/255.0 blue:91/255.0 alpha:1.0];
}

- (UIColor *)monsterColor {
    return [SKColor colorWithRed:255/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
}

- (UIColor *)backgroundColor {
    return [SKColor colorWithRed:204/255.0 green:74/255.0 blue:74/255.0 alpha:1.0];
}

@end
