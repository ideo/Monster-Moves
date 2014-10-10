//
//  GameScene.m
//  DanceStudio
//
//  Created by Kevin Gaunt on 9/24/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "TrainingStage.h"
#import "Tile.h"
#import "Stage.h"
#import "AudioPlayer.h"
#import "DraggableShapeNode.h"
#import "Timeline.h"
#import "DanceScene.h"
#import "MonsterSpriteNode.h"

static NSString * const kDropZoneNodeName = @"dropzone";
static BOOL const kNumberOfTiles = 12;

static const uint32_t edgeCategory =  0x1 << 1;

@interface TrainingStage ()
@property (nonatomic) SKSpriteNode * selectedNode;
@property (nonatomic) SKColor* defaultDropZoneColor;
@property (nonatomic) AudioPlayer* audioPlayer;
@property (nonatomic) BOOL showingDanceScene;

@end

@implementation TrainingStage

-(void)didMoveToView:(SKView *)view {
    
    [self load];
    
    // Setting the scene
    self.backgroundColor = [SKColor colorWithRed:82/255.0 green:60/255.0 blue:102/255.0 alpha:1.0];
    self.defaultDropZoneColor = [SKColor colorWithWhite:0.4 alpha:0.2];
    self.audioPlayer = [[AudioPlayer alloc] init];
    self.showingDanceScene = NO;
    
    [self initialiseScreenEdges];
    [self initialiseMonster];
    
    // Adding the dropzones
    [self initialiseDropZoneForPosition:0];
    [self initialiseDropZoneForPosition:1];
    [self initialiseDropZoneForPosition:2];
    
    [self initialiseNodes];
}

- (void)initialiseMonster {
    MonsterSpriteNode* sprite = (MonsterSpriteNode*)self.monster.sprite;
    sprite.position = CGPointMake(300 + self.monster.number * 300, CGRectGetMidY(self.frame) + kMonsterYOffset);
    [self addChild:sprite];
}

-(SKSpriteNode*)initialiseDropZoneForPosition:(int)position {
    SKSpriteNode* dz = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyDropZone1"];
    dz.xScale = 0.55;
    dz.yScale = 0.55;
    dz.name = [NSString stringWithFormat:@"%@%i", kDropZoneNodeName, position];
    dz.zRotation = degToRad(arc4random_uniform(350));
    dz.position = [self.monster.timeline positionForSlot:position];
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

- (void)initialiseNodes {
    for (int i = 0; i < kNumberOfTiles; i++) {
        [self addTileAnimated];
    }
}

- (SKSpriteNode*)tileNodeAtRandom {
    Tile* tile = [[Tile alloc] initWithType:[Tile tileTypeAtRandom]];
    SKSpriteNode* tileNode = tile.sprite;
    tileNode.userData = [[NSMutableDictionary alloc] initWithDictionary: @{@"tile" : tile}];
    tileNode.position = [self pointAtRandomForTile:tileNode];
    
    return tileNode;
}

- (CGPoint)pointAtRandomForTile:(SKSpriteNode*)tile {
    CGRect fullFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect monsterFrame = self.monster.sprite.frame;
    CGRect controlFrame = CGRectMake(240, 510, 530, 180);
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

-(void)touchesBegan:(NSSet*) touches withEvent:(UIEvent*) event {
    
    UITouch* eachTouch = touches.allObjects.firstObject;
    
    //for (UITouch *eachTouch in touches) {
        CGPoint eachTouchLocation = [eachTouch locationInNode:self];
        NSArray *nodes = [self nodesAtPoint:eachTouchLocation];
        for (DraggableShapeNode *eachTouchedNode in nodes) {
            if ([eachTouchedNode isKindOfClass:[DraggableShapeNode class]] == NO) continue;
            if (eachTouchedNode.isDragged) continue;
            [eachTouchedNode bindTouch:eachTouch];
            
            Tile* tile = (Tile*)eachTouchedNode.userData[@"tile"];
            MonsterSpriteNode* monsterSprite = (MonsterSpriteNode*)self.monster.sprite;
            SKAction* dancePreview = [monsterSprite animateMonsterWithTileType:tile.type repeatForever:NO];
            [monsterSprite removeAllActions];
            [monsterSprite runAction:dancePreview completion:^{
                NSLog(@"Dance move completed");
                if (self.monster.timeline.isFull) {
                    [self runAction:[SKAction waitForDuration:0] completion:^{
                        [self transitionToDanceScene];
                    }];
                }
            }];
        }
    //}
}

-(void)touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event {
    
    UITouch* eachTouch = touches.allObjects.firstObject;
    
    //for (UITouch *eachTouch in touches) {
        for (DraggableShapeNode *eachTouchedNode in self.children) {
            if ([eachTouchedNode isKindOfClass:[DraggableShapeNode class]] == NO) continue;
            
            if (eachTouchedNode.touch == eachTouch) {
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
        SKAction* moveAction = [touchedNode moveToPosition:[timeline positionForSlot:slot.intValue] touch:touchPoint];
        [touchedNode runAction:moveAction];
    }
}

- (void)transitionToDanceScene {
    [self save];
    
    DanceScene *scene = [DanceScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *transition = [SKTransition crossFadeWithDuration:0.6];
    [self.view presentScene:scene transition:transition];
}

#pragma mark - Update Frames

-(void)update:(NSTimeInterval)currentTime{
    
    // At every update make sure that the dragged nodes are being updated
    for (DraggableShapeNode *eachTouchedNode in self.children) {
        if ([eachTouchedNode isKindOfClass:[DraggableShapeNode class]] == NO) continue; // Checks
        [eachTouchedNode drag];
    }
}

#pragma mark - AnimationLoop

- (void)updateAnimationLoop {
    
    // Get tiles from timeline
    Tile* tile1 = [self.monster.timeline tileAtSlot:0];
    Tile* tile2 = [self.monster.timeline tileAtSlot:1];
    Tile* tile3 = [self.monster.timeline tileAtSlot:2];
    
    TileType tile1Type = tile1 ? tile1.type : TileTypeIdle;
    TileType tile2Type = tile2 ? tile2.type : TileTypeIdle;
    TileType tile3Type = tile3 ? tile3.type : TileTypeIdle;
    
    MonsterSpriteNode* monsterSprite = (MonsterSpriteNode*)self.monster.sprite;
    SKAction* step1 = [monsterSprite animateMonsterWithTileType:tile1Type repeatForever:NO];
    SKAction* step2 = [monsterSprite animateMonsterWithTileType:tile2Type repeatForever:NO];
    SKAction* step3 = [monsterSprite animateMonsterWithTileType:tile3Type repeatForever:NO];
    
    SKSpriteNode* dz1 = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%i", kDropZoneNodeName, 0]];
    SKSpriteNode* dz2 = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%i", kDropZoneNodeName, 1]];
    SKSpriteNode* dz3 = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%i", kDropZoneNodeName, 2]];
    
    SKAction* pre1 = [SKAction runBlock:^{[dz1 runAction:[Tile actionForHighlight]
                                              completion:^{[dz1 removeAllActions];}];}];
    SKAction* post1 = [SKAction runBlock:^{[dz1 runAction:[Tile actionForResting]
                                               completion:^{[dz1 removeAllActions];}];}];
    
    SKAction* pre2 = [SKAction runBlock:^{[dz2 runAction:[Tile actionForHighlight]
                                              completion:^{[dz2 removeAllActions];}];}];
    SKAction* post2 = [SKAction runBlock:^{[dz2 runAction:[Tile actionForResting]
                                               completion:^{[dz2 removeAllActions];}];}];
    
    SKAction* pre3 = [SKAction runBlock:^{[dz3 runAction:[Tile actionForHighlight]
                                              completion:^{[dz3 removeAllActions];}];}];
    SKAction* post3 = [SKAction runBlock:^{[dz3 runAction:[Tile actionForResting]
                                               completion:^{[dz3 removeAllActions];}];}];
    
    SKAction* danceSequence = [SKAction sequence:@[pre1, step1, post1,
                                                   pre2, step2, post2,
                                                   pre3, step3, post3]];
    
    // Clear existing animations first
    [monsterSprite removeAllActions];
    
    // Add new animations
    [monsterSprite runAction:[SKAction repeatActionForever:danceSequence]];
}

- (void)addTileAnimated {
    SKSpriteNode* tile = [self tileNodeAtRandom];
    [self addChild:tile];
    
    SKAction* waitAction = [SKAction waitForDuration:0.2 withRange:0.2];
    SKAction* scaleAction = [SKAction scaleTo:kTileScaleFactor duration:0.2];
    SKAction* fadeAction = [SKAction fadeInWithDuration:0.2];
    SKAction* group = [SKAction group:@[scaleAction, fadeAction]];
    [tile runAction:[SKAction sequence:@[waitAction, group]]];
}

#pragma mark - Save

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* monsterData = [defaults objectForKey:@"monsters"];
    NSArray* monsters = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:monsterData];
    NSMutableArray* newMonsters = [[NSMutableArray alloc] init];
    for (Monster* monster in monsters) {
        NSLog(@"%i", monster.number);
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

float degToRad(float degree) {
    return degree / 180.0f * M_PI;
}

@end
