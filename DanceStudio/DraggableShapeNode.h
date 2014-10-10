//
//  DraggableShapeNode.h
//  DanceStudio
//
//  Created by Kevin Gaunt on 06/10/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DraggableShapeNode : SKSpriteNode

@property (nonatomic) CGPoint touchOffset;
@property (nonatomic) UITouch *touch;
@property (nonatomic, readonly) BOOL isDragged;
@property (nonatomic, readonly) BOOL isFrozen;

-(void)bindTouch:(UITouch*)touch;
-(void)drag;
-(void)unbindTouch:(UITouch*)touch;
- (SKAction*)moveToPosition:(CGPoint)position touch:(UITouch*)touch;

@end
