//
//  GameScene.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 9/24/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "TrainingStage.h"
#import "Tile.h"
#import "Scenery.h"
#import "AudioPlayer.h"
#import "DraggableShapeNode.h"
#import "Timeline.h"
#import "DanceScene.h"
#import "MonsterSpriteNode.h"

static NSString * const kDropZoneNodeName = @"dropzone";
static NSString * const kPlayButtonName = @"play";
static NSString * const kReturnButtonName = @"return";
static NSString * const kLightConeName = @"lightCone";
static const uint32_t edgeCategory =  0x1 << 1;

@interface TrainingStage ()
@property (nonatomic) SKSpriteNode * selectedNode;
@property (nonatomic) SKColor* defaultDropZoneColor;
@property (nonatomic) AudioPlayer* audioPlayer;
@property (nonatomic) BOOL showingDanceScene;
@property (nonatomic) CGPoint originalMonsterPosition;

@end

@implementation TrainingStage {
    BOOL _transitioning;
    BOOL _playing;
}

-(void)didMoveToView:(SKView *)view {
    
    [self load];
    
    // Setting the scene
    self.backgroundColor =  self.monster.color;
    self.defaultDropZoneColor = [SKColor colorWithWhite:0.4 alpha:0.2];
    self.audioPlayer = [[AudioPlayer alloc] init];
    self.showingDanceScene = NO;
    
    [self initialiseLight];
    
    [self initialiseScreenEdges];
    [self initialiseMonster];
    
    // Adding the dropzones
    [self initialiseDropZoneForPosition:0];
    [self initialiseDropZoneForPosition:1];
    [self initialiseDropZoneForPosition:2];
    [self initialiseDropZoneForPosition:3];
    
    //[self initialiseNodes];
    [self initialisePlayButton];
    [self initialiseReturnButton];
    
    [self.audioPlayer playMusicForType:AudioTypeDrumLoop];
    
    SKNode* light = [self childNodeWithName:kLightConeName];
    [light runAction:[self showLight]];
}

- (void)initialiseLight {
    SKShapeNode* lightCone = [SKShapeNode shapeNodeWithCircleOfRadius:450];
    lightCone.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 40);
    lightCone.name = kLightConeName;
    lightCone.alpha = 1;
    lightCone.fillColor = self.monster.backgroundColor;
    lightCone.xScale = 0.00001;
    lightCone.yScale = lightCone.xScale;
    lightCone.lineWidth = 0;
    
    [self addChild:lightCone];
}

- (void)initialiseMonster {
    MonsterSpriteNode* sprite = (MonsterSpriteNode*)self.monster.sprite;
    
    if (self.monster.number == 1) {
        self.originalMonsterPosition = CGPointMake(CGRectGetMidX(self.frame) + 30, CGRectGetMidY(self.frame) + kMonsterYOffset);
    }
    else {
        self.originalMonsterPosition = CGPointMake(300 + self.monster.number * 300, CGRectGetMidY(self.frame) + kMonsterYOffset);
    }
    
    sprite.position = self.originalMonsterPosition;
    sprite.zPosition = 2;
    
    if (self.monster.number == 1)
        sprite.position = CGPointMake(CGRectGetMidX(self.frame) + 30, CGRectGetMidY(self.frame) + kMonsterYOffset);
    
    [self addChild:sprite];
    [self moveMonsterToCenter:sprite];
}

-(SKSpriteNode*)initialiseDropZoneForPosition:(int)position {
    SKSpriteNode* dz = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"EmptyDropZone%i", position+1]];
    dz.xScale = 0.55;
    dz.yScale = 0.55;
    dz.name = [NSString stringWithFormat:@"%@%i", kDropZoneNodeName, position];
    dz.position = [self.monster.timeline positionForSlot:position];
    dz.color = [SKColor yellowColor];
    [self addChild:dz];
    return dz;
}

- (void)initialiseScreenEdges {
    SKSpriteNode* bottomEdge = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.size.width, 1)];
    bottomEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width, 1)];
    bottomEdge.position = CGPointMake(self.size.width/2, -40);
    bottomEdge.physicsBody.dynamic = NO;
    bottomEdge.physicsBody.categoryBitMask = edgeCategory;
    bottomEdge.physicsBody.contactTestBitMask = tileCategory;
    [self addChild:bottomEdge];
    
    SKSpriteNode* topEdge = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.size.width, 1)];
    topEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width, 1)];
    topEdge.position = CGPointMake(self.size.width/2, self.size.height + 10);
    topEdge.physicsBody.dynamic = NO;
    topEdge.physicsBody.categoryBitMask = edgeCategory;
    topEdge.physicsBody.contactTestBitMask = tileCategory;
    [self addChild:topEdge];
    
    SKSpriteNode* leftEdge = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(1, self.size.height)];
    leftEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.size.height)];
    leftEdge.position = CGPointMake(-10, self.size.height/2.0);
    leftEdge.physicsBody.dynamic = NO;
    leftEdge.physicsBody.categoryBitMask = edgeCategory;
    leftEdge.physicsBody.contactTestBitMask = tileCategory;
    [self addChild:leftEdge];
    
    SKSpriteNode* rightEdge = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(1, self.size.height)];
    rightEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.size.height)];
    rightEdge.position = CGPointMake(self.size.width + 20, self.size.height/2.0);
    rightEdge.physicsBody.dynamic = NO;
    rightEdge.physicsBody.categoryBitMask = edgeCategory;
    rightEdge.physicsBody.contactTestBitMask = tileCategory;
    [self addChild:rightEdge];
    
}

- (void)initialisePlayButton {
    SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithImageNamed:@"Play"];
    playButton.xScale = 0.8;
    playButton.yScale = 0.8;
    playButton.alpha = 0;
    playButton.zPosition = 4;
    playButton.name = kPlayButtonName;
    playButton.position = CGPointMake(self.frame.size.width - (playButton.frame.size.width/2.0 + 10), self.frame.size.height - (playButton.frame.size.width / 2.0 + 20));
    
    [self addChild:playButton];
}


- (void)initialiseReturnButton {
    SKSpriteNode* button = [SKSpriteNode spriteNodeWithImageNamed:self.monster.backButtonImageName];
    button.xScale = 0.5;
    button.yScale = 0.5;
    button.alpha = 0;
    button.zPosition = 4;
    button.name = kReturnButtonName;
    button.position = CGPointMake(button.frame.size.width / 2.0 + 20, self.frame.size.height - (button.frame.size.height / 2.0 + 20));
    
    [self addChild:button];
}

- (void)initialiseNodes {
    
    for (int counter = 0; counter < 1; counter++) {
        for (NSString* moveName in self.monster.moves) {
         
            Tile* tile = [[Tile alloc] initWithMove:moveName monsterName:self.monster.name monsterShortName:self.monster.shortName];
            SKSpriteNode* tileNode = tile.sprite;
            tileNode.userData = [[NSMutableDictionary alloc] initWithDictionary: @{@"tile" : tile}];
            tileNode.position = [self pointAtRandomForTile:tileNode];
            
            [self addChild:tileNode];
            
            // Animate in
            SKAction* waitAction = [SKAction waitForDuration:0.2 withRange:0.2];
            SKAction* scaleAction = [SKAction scaleTo:kTileScaleFactor duration:0.2];
            SKAction* fadeAction = [SKAction fadeInWithDuration:0.2];
            SKAction* group = [SKAction group:@[scaleAction, fadeAction]];
            [tileNode runAction:[SKAction sequence:@[waitAction, group]]];
        }
    }
}

- (CGPoint)pointAtRandomForTile:(SKSpriteNode*)tile {
    CGRect fullFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect monsterFrame = self.monster.sprite.frame;
    CGRect controlFrame = CGRectMake(120, 0, 790, 180);
    CGPoint p;
    do {
        p = CGPointMake(fullFrame.origin.x + arc4random_uniform(fullFrame.size.width),
                        fullFrame.origin.y + arc4random_uniform(fullFrame.size.height));
    } while (CGRectContainsPoint(monsterFrame, p) || CGRectContainsPoint(controlFrame, p));
    
    /*
    SKShapeNode* shape1 = [SKShapeNode shapeNodeWithRect:monsterFrame];
    shape1.fillColor = [SKColor redColor];
    [self addChild:shape1];

    SKShapeNode* shape2 = [SKShapeNode shapeNodeWithRect:controlFrame];
    shape2.fillColor = [SKColor greenColor];
    [self addChild:shape2];
    */
    
    return p;
}

- (CGPoint)pointFloatingAtRandomForTile:(SKSpriteNode*)tile {
    // Determine where to spawn the tile along the Y axis
    int minY = self.frame.size.height + tile.size.height;
    int maxY = self.frame.size.height * 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    int actualX = 0;
    do {
        // Determine where to spawn the tile along the X axis
        actualX = (arc4random_uniform(@(self.view.frame.size.width).intValue));
        //} while (actualX > minCircleX && actualX < maxCircleX);
    } while (false);
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    return CGPointMake(actualX, actualY);
}

#pragma mark - Touch handling

- (void)returnButtonTapped {
    _transitioning = YES;
    [self runAction:[self.audioPlayer actionToPlaySoundWithType:AudioTypeCloseButtonTapped]];
    [self removeAllTilesIgnoringSelected:NO];
    [self removeAllDropZones];
    [self.monster.sprite runAction:[self moveMonsterToOriginalPosition] completion:^{
        [self transitionToDanceScene];
    }];
}

- (void)playButtonTapped {
    _playing = YES;
    SKNode* playButton = [self childNodeWithName:kPlayButtonName];
    playButton.alpha = 0.0;
    
    SKNode* light = [self childNodeWithName:kLightConeName];
    [light runAction:[self enlargeLight]];
    
    [self updateAnimationLoop];
}

- (void)tileTappedAt:(UITouch *)eachTouch eachTouchedNode:(DraggableShapeNode *)eachTouchedNode {
    
    [eachTouchedNode bindTouch:eachTouch];
    Tile* tile = (Tile*)eachTouchedNode.userData[@"tile"];
    MonsterSpriteNode* monsterSprite = (MonsterSpriteNode*)self.monster.sprite;
    
    [monsterSprite removeAllActions];
    _playing = NO;
    
    if (self.monster.timeline.isFull) {
        SKSpriteNode* returnButton = (SKSpriteNode*)[self childNodeWithName:kReturnButtonName];
        if (returnButton.alpha == 0)
            [returnButton runAction:[self showReturnButton]];
    
        SKSpriteNode* playButton = (SKSpriteNode*)[self childNodeWithName:kPlayButtonName];
        if (playButton.alpha == 0)
            playButton.alpha = 1.0;
    }
    
    [self runAction:[self.audioPlayer actionToPlaySoundWithType:AudioTypeTileTapped]];
    
    SKAction* dancePreview = [monsterSprite animateMonsterWithTile:tile repeatForever:NO];
    SKAction* danceSoundEffect = [Tile actionForSound:tile.soundEffectName];
    SKAction* danceAndSoundGroup = [SKAction group:@[dancePreview, danceSoundEffect]];
    
    [monsterSprite runAction:danceAndSoundGroup completion:^{
        NSLog(@"Dance move completed");
        [monsterSprite runAction:[monsterSprite idleAnimation]];
    }];
}

-(void)touchesBegan:(NSSet*) touches withEvent:(UIEvent*) event {
    
    if (_transitioning) return;
    
    UITouch* eachTouch = touches.allObjects.firstObject;
    
    //for (UITouch *eachTouch in touches) {
        CGPoint eachTouchLocation = [eachTouch locationInNode:self];
        NSArray *nodes = [self nodesAtPoint:eachTouchLocation];
        for (DraggableShapeNode *eachTouchedNode in nodes) {
            
            if ([eachTouchedNode.name isEqualToString:kReturnButtonName] && self.monster.timeline.isFull) {
                [self returnButtonTapped];
            }
            
            
            if ([eachTouchedNode.name isEqualToString:kPlayButtonName] && self.monster.timeline.isFull) {
                if (!_playing) [self playButtonTapped];
            }
            
            
            if (([eachTouchedNode isKindOfClass:[DraggableShapeNode class]] == NO) || (eachTouchedNode.isDragged)) continue;
            
            [self tileTappedAt:eachTouch eachTouchedNode:eachTouchedNode];
        }
    //}
}

-(void)touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event {
    
    UITouch* eachTouch = touches.allObjects.firstObject;
    
    //for (UITouch *eachTouch in touches) {
        for (DraggableShapeNode *eachTouchedNode in self.children) {
            if ([eachTouchedNode isKindOfClass:[DraggableShapeNode class]] == NO) continue;
            
            if (eachTouchedNode.touch == eachTouch) {
                //[self runAction:[self.audioPlayer actionToPlayRandomSnappedSound]];
                [self addNode:eachTouchedNode touch:eachTouch toTimeline:self.monster.timeline];
            }
            
            [eachTouchedNode unbindTouch:eachTouch];
        }
    //}
}

#pragma mark - Logic

- (void)addNode:(DraggableShapeNode*)touchedNode touch:(UITouch*)touchPoint toTimeline:(Timeline*)timeline {
    Tile* tile = (Tile*)touchedNode.userData[@"tile"];
    NSNumber* slot = [timeline addTile:tile];
    if (slot) {
        CGPoint dropzonePosition = [timeline positionForSlot:slot.intValue];
        SKSpriteNode* dropZoneSprite;
        for (SKNode* node in [self nodesAtPoint:dropzonePosition]) {
            if ([node.name containsString:kDropZoneNodeName]) {
                dropZoneSprite = (SKSpriteNode*)node;
            }
        }
        
        SKAction* moveAction = [touchedNode moveToPosition:[timeline positionForSlot:slot.intValue] touch:touchPoint];
        [touchedNode runAction:moveAction completion:^{
            dropZoneSprite.texture = [SKTexture textureWithImageNamed:@"WhiteDropZone1"];
            dropZoneSprite.color = self.monster.monsterColor;
            dropZoneSprite.colorBlendFactor = 1.0;
            dropZoneSprite.alpha = 1;
            if (self.monster.timeline.isFull) {
                [self filledUpTimeline];
            }
        }];
    }
}

- (void)filledUpTimeline {
    SKSpriteNode* playButton = (SKSpriteNode*)[self childNodeWithName:kPlayButtonName];
    playButton.alpha = 1.0;
    [self removeAllTilesIgnoringSelected:YES];
}

- (void)transitionToDanceScene {
    
    [self save];
    
    [self runAction:[SKAction waitForDuration:0.1] completion:^{
        DanceScene *scene = [DanceScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *transition = [SKTransition crossFadeWithDuration:1.2];
        [self.view presentScene:scene transition:transition];
        _transitioning = NO;
    }];
}

#pragma mark - Update Frames

-(void)update:(NSTimeInterval)currentTime{
    
    // At every update make sure that the dragged nodes are being updated
    for (DraggableShapeNode *eachTouchedNode in self.children) {
        if ([eachTouchedNode isKindOfClass:[DraggableShapeNode class]] == NO) continue; // Checks
        [eachTouchedNode drag];
    }
}

#pragma mark - Animations

- (void)moveMonsterToCenter:(MonsterSpriteNode*)sprite {
    
    CGPoint centerPosition;
    
    if (self.monster.number == 1) {
        centerPosition = CGPointMake(CGRectGetMidX(self.frame), sprite.position.y + 260);
    }
    else {
        centerPosition = CGPointMake(CGRectGetMidX(self.frame) + 120, sprite.position.y + 240);
    }
    
    SKAction* scaleMonsterAction = [SKAction scaleTo:1.20 duration:0.5];
    scaleMonsterAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* moveMonsterAction = [SKAction moveTo:centerPosition duration:0.5];
    moveMonsterAction.timingMode = SKActionTimingEaseInEaseOut;
    
    [sprite runAction:[SKAction group:@[moveMonsterAction, scaleMonsterAction]] completion:^{
        [self initialiseNodes];
    }];
}

- (SKAction*)moveMonsterToOriginalPosition {
    
    SKNode* light = [self childNodeWithName:kLightConeName];
    [light runAction:[self hideLight]];
    
    SKAction* scaleMonsterAction = [SKAction scaleTo:kMonsterScaleFactor duration:0.5];
    scaleMonsterAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* moveMonsterAction = [SKAction moveTo:self.originalMonsterPosition duration:0.5];
    moveMonsterAction.timingMode = SKActionTimingEaseInEaseOut;
    
    return[SKAction group:@[moveMonsterAction, scaleMonsterAction]];
}

- (void)removeAllTilesIgnoringSelected:(BOOL)ignoreSelected {
    for (SKSpriteNode* tileNode in self.children) {
        if (![tileNode.name isEqualToString:kTileNodeName]) continue;
        
        Tile* tile = (Tile*)tileNode.userData[@"tile"];
        if([self.monster.timeline contains:tile] && ignoreSelected) continue;
        
        SKAction* waitAction = [SKAction waitForDuration:0.2 withRange:0.1];
        SKAction* scaleAction = [SKAction scaleTo:0.01 duration:0.25];
        scaleAction.timingMode = SKActionTimingEaseInEaseOut;
        SKAction* fadeAction = [SKAction fadeOutWithDuration:0.25];
        fadeAction.timingMode = SKActionTimingEaseInEaseOut;
        
        [tileNode runAction:[SKAction sequence:@[waitAction,[SKAction group:@[scaleAction, fadeAction]]]] completion:^{
            [tileNode removeFromParent];
        }];
    }
}

- (void)removeAllDropZones {
    for (SKSpriteNode* tileNode in self.children) {
        if (![tileNode.name containsString:kDropZoneNodeName]) continue;
        
        SKAction* waitAction = [SKAction waitForDuration:0.01 withRange:0.2];
        SKAction* scaleAction = [SKAction scaleTo:0.01 duration:0.25];
        scaleAction.timingMode = SKActionTimingEaseInEaseOut;
        SKAction* fadeAction = [SKAction fadeOutWithDuration:0.25];
        fadeAction.timingMode = SKActionTimingEaseInEaseOut;
        
        [tileNode runAction:[SKAction sequence:@[waitAction,[SKAction group:@[scaleAction, fadeAction]]]] completion:^{
            [tileNode removeFromParent];
        }];
    }
}

- (SKAction*)showLight {
    SKAction* scaleAction = [SKAction scaleTo:0.48 duration:0.4];
    scaleAction.timingMode = SKActionTimingEaseIn;
    
    SKAction* fadeAction = [SKAction fadeAlphaTo:1 duration:0.4];
    scaleAction.timingMode = SKActionTimingEaseIn;
    
    return [SKAction group:@[scaleAction, fadeAction]];
}

- (SKAction*)hideLight {
    SKAction* scaleAction = [SKAction scaleTo:0.0001 duration:0.4];
    scaleAction.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction* fadeAction = [SKAction fadeOutWithDuration:0.2];
    scaleAction.timingMode = SKActionTimingEaseInEaseOut;
    
    return [SKAction group:@[scaleAction, fadeAction]];
}


- (SKAction*)enlargeLight {
    SKAction* scaleAction = [SKAction scaleTo:1.1 duration:0.3];
    scaleAction.timingMode = SKActionTimingEaseInEaseOut;
    return [SKAction group:@[scaleAction]];
}

- (SKAction*)dimLight {
    SKAction* scaleAction = [SKAction scaleTo:0.52 duration:0.3];
    scaleAction.timingMode = SKActionTimingEaseInEaseOut;
    return [SKAction group:@[scaleAction]];
}

- (SKAction*)showReturnButton {
    SKAction* scaleAction = [SKAction scaleTo:0.5 duration:0.15];
    scaleAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* fadeAction = [SKAction fadeAlphaTo:1.0 duration:0.15];
    fadeAction.timingMode = SKActionTimingEaseInEaseOut;
    return [SKAction group:@[scaleAction, fadeAction]];
}

- (SKAction*)hideReturnButton {
    SKAction* scaleAction = [SKAction scaleTo:0.0001 duration:0.15];
    scaleAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* fadeAction = [SKAction fadeAlphaTo:0.0 duration:0.15];
    fadeAction.timingMode = SKActionTimingEaseInEaseOut;
    return [SKAction group:@[scaleAction, fadeAction]];
}

- (void)updateAnimationLoop {
    
    [self hideReturnButton];
    
    // Get tiles from timeline
    Tile* tile1 = [self.monster.timeline tileAtSlot:0];
    Tile* tile2 = [self.monster.timeline tileAtSlot:1];
    Tile* tile3 = [self.monster.timeline tileAtSlot:2];
    Tile* tile4 = [self.monster.timeline tileAtSlot:3];
    
    // Get tiles from timeline
    SKSpriteNode* tile1Node = tile1.sprite;
    SKSpriteNode* tile2Node = tile2.sprite;
    SKSpriteNode* tile3Node = tile3.sprite;
    SKSpriteNode* tile4Node = tile4.sprite;
    
    SKAction* tile1SoundEffect = [Tile actionForSound:tile1.soundEffectName];
    SKAction* tile2SoundEffect = [Tile actionForSound:tile2.soundEffectName];
    SKAction* tile3SoundEffect = [Tile actionForSound:tile3.soundEffectName];
    SKAction* tile4SoundEffect = [Tile actionForSound:tile4.soundEffectName];
    
    
    MonsterSpriteNode* monsterSprite = (MonsterSpriteNode*)self.monster.sprite;
    SKAction* step1 = [SKAction group:@[tile1SoundEffect, [monsterSprite animateMonsterWithTile:tile1 repeatForever:NO]]];
    SKAction* step2 = [SKAction group:@[tile2SoundEffect, [monsterSprite animateMonsterWithTile:tile2 repeatForever:NO]]];
    SKAction* step3 = [SKAction group:@[tile3SoundEffect, [monsterSprite animateMonsterWithTile:tile3 repeatForever:NO]]];
    SKAction* step4 = [SKAction group:@[tile4SoundEffect, [monsterSprite animateMonsterWithTile:tile4 repeatForever:NO]]];
    
    SKSpriteNode* dz1 = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%i", kDropZoneNodeName, 0]];
    SKSpriteNode* dz2 = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%i", kDropZoneNodeName, 1]];
    SKSpriteNode* dz3 = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%i", kDropZoneNodeName, 2]];
    SKSpriteNode* dz4 = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%i", kDropZoneNodeName, 3]];
    
    
    
    SKAction* pre1dz = [SKAction runBlock:^{[dz1 runAction:[Tile actionForHighlight]
                                              completion:^{[dz1 removeAllActions];}];}];
    SKAction* pre1tile = [SKAction runBlock:^{[tile1Node runAction:[Tile actionForPlay]
                                              completion:^{[tile1Node removeAllActions];}];}];
    SKAction* pre1 = [SKAction group:@[pre1dz, pre1tile]];
    
    SKAction* post1dz = [SKAction runBlock:^{[dz1 runAction:[Tile actionForResting]
                                               completion:^{[dz1 removeAllActions];}];}];
    SKAction* post1 = [SKAction group:@[post1dz]];
    
    
    
    SKAction* pre2dz = [SKAction runBlock:^{[dz2 runAction:[Tile actionForHighlight]
                                                completion:^{[dz2 removeAllActions];}];}];
    SKAction* pre2tile = [SKAction runBlock:^{[tile2Node runAction:[Tile actionForPlay]
                                                        completion:^{[tile2Node removeAllActions];}];}];
    SKAction* pre2 = [SKAction group:@[pre2dz, pre2tile]];
    
    SKAction* post2dz = [SKAction runBlock:^{[dz2 runAction:[Tile actionForResting]
                                                 completion:^{[dz2 removeAllActions];}];}];
    SKAction* post2 = [SKAction group:@[post2dz]];
    
    
    
    SKAction* pre3dz = [SKAction runBlock:^{[dz3 runAction:[Tile actionForHighlight]
                                                completion:^{[dz3 removeAllActions];}];}];
    SKAction* pre3tile = [SKAction runBlock:^{[tile3Node runAction:[Tile actionForPlay]
                                                        completion:^{[tile3Node removeAllActions];}];}];
    SKAction* pre3 = [SKAction group:@[pre3dz, pre3tile]];
    
    SKAction* post3dz = [SKAction runBlock:^{[dz3 runAction:[Tile actionForResting]
                                                 completion:^{[dz3 removeAllActions];}];}];
    SKAction* post3 = [SKAction group:@[post3dz]];
    
    
    
    
    SKAction* pre4dz = [SKAction runBlock:^{[dz4 runAction:[Tile actionForHighlight]
                                                completion:^{[dz4 removeAllActions];}];}];
    SKAction* pre4tile = [SKAction runBlock:^{[tile4Node runAction:[Tile actionForPlay]
                                                        completion:^{[tile4Node removeAllActions];}];}];
    SKAction* pre4 = [SKAction group:@[pre4dz, pre4tile]];
    
    SKAction* post4dz = [SKAction runBlock:^{[dz4 runAction:[Tile actionForResting]
                                                 completion:^{[dz4 removeAllActions];}];}];
    SKAction* post4 = [SKAction group:@[post4dz]];
    
    
    
    SKAction* danceSequence = [SKAction sequence:@[pre1, step1, post1,
                                                   pre2, step2, post2,
                                                   pre3, step3, post3,
                                                   pre4, step4, post4]];
    
    SKAction* showReturnButton = [SKAction customActionWithDuration:0.15 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        SKSpriteNode* returnButton = (SKSpriteNode*)[self childNodeWithName:kReturnButtonName];
        [returnButton runAction:[self showReturnButton]];
    }];
    
    // Clear existing animations first
    [monsterSprite removeAllActions];
    
    // Add new animations
    [monsterSprite runAction:[SKAction sequence:@[danceSequence, showReturnButton, [SKAction repeatActionForever:danceSequence]]]];
    
    /*  [monsterSprite runAction:[SKAction sequence:@[danceSequence, showReturnButton, [SKAction repeatActionForever:danceSequence]]] completion:^{
     SKNode* playButton = [self childNodeWithName:kPlayButtonName];
     playButton.alpha = 1.0;
     SKNode* light = [self childNodeWithName:kLightConeName];
     [light runAction:[self dimLight]];
     _playing = NO;
     }];*/
}

#pragma mark - Save

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* monsterData = [defaults objectForKey:@"monsters"];
    NSArray* monsters = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:monsterData];
    NSMutableArray* newMonsters = [[NSMutableArray alloc] init];
    for (Monster* monster in monsters) {
        NSLog(@"%lu", (unsigned long)monster.number);
        if (self.monster.number == monster.number) {
            [newMonsters addObject:self.monster];
        } else
            [newMonsters addObject:monster];
    }
    
    NSData *encodedMonsters = [NSKeyedArchiver archivedDataWithRootObject:newMonsters];
    [defaults setObject:encodedMonsters forKey:@"monsters"];
    
    NSData *encodedMonster = [NSKeyedArchiver archivedDataWithRootObject:self.monster];
    [defaults setObject:encodedMonster forKey:@"lastMonster"];
    
    [defaults synchronize];
}

- (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData* monsterData = [defaults objectForKey:@"lastMonster"];
    self.monster = (Monster*)[NSKeyedUnarchiver unarchiveObjectWithData:monsterData];
    
    // make sure we get a new timeline
    [self.monster resetTimeline];
}

#pragma - Helper Methods

- (float)degToRad:(float) degree {
    return degree / 180.0f * M_PI;
}

@end
