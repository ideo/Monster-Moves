//
//  Timeline.h
//  DanceStudio
//
//  Created by Kevin Gaunt on 07/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spritekit/SpriteKit.h>
#import "Tile.h"

@interface Timeline : NSObject<NSCoding>

-(BOOL)isFull;
-(NSNumber*)nextAvailableSlot;
-(CGPoint)positionForSlot:(int)slot;
-(NSNumber*)addTile:(Tile*)tile;
-(void)removeTile:(Tile*)tile;
-(Tile*)tileAtSlot:(int)slot;
-(BOOL)contains:(Tile*)tile;

@end
