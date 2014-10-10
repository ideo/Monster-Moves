//
//  DraggableShapeNode.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 06/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "DraggableShapeNode.h"

@interface EPPZDraggableShapeNode : SKSpriteNode
@property (nonatomic) CGPoint touchOffset;
@end

@implementation DraggableShapeNode {
    BOOL _isFrozen;
}

-(BOOL)isDragged {
    return (self.touch != nil);
}

-(BOOL)isFrozen {
    return _isFrozen;
}

-(void)bindTouch:(UITouch*) touch {
    if (self.isFrozen) return;
    
    self.touch = touch; // Reference
    
    // Physics, and coordinate works moved here.
    CGPoint touchLocation = [self.touch locationInNode:self.scene];
    self.touchOffset = [self subtractVectorPoints:touchLocation other:self.touchOffset];
    self.physicsBody.affectedByGravity = NO;
}

-(void)drag {
    // If any touch bound.
    if (self.isDragged == NO) return;
    
    // Coordinate works moved here.
    CGPoint touchLocation = [self.touch locationInNode:self.scene];
    self.position = touchLocation;
    //[self subtractVectorPoints:touchLocation other:self.touchOffset];
}

-(void)unbindTouch:(UITouch*) touch {
    // Unbind only if bound.
    if (self.touch != touch) return;
    
    // Physics work moved here.
    self.touch = nil;
    self.physicsBody.dynamic = NO;
    //self.physicsBody.affectedByGravity = YES;
}

- (SKAction*)moveToPosition:(CGPoint)position touch:(UITouch*)touch {
    // Unbind only if bound.
    if (self.touch != touch) return nil;
    
    _isFrozen = YES;
    
    SKAction* moveAction = [SKAction moveTo:position duration:0.5];
    moveAction.timingMode = SKActionTimingEaseInEaseOut;
    return moveAction;
}


- (CGPoint)addVectorPoints:(CGPoint)one other:(CGPoint)other {
    return CGPointMake(one.x + other.x, one.y + other.y);
}

- (CGPoint)subtractVectorPoints:(CGPoint)one other:(CGPoint)other {
    return CGPointMake(one.x - other.x, one.y - other.y);
}

@end
