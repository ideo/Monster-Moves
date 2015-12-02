//
//  SpaceshipScene.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright © 2015 IDEO. All rights reserved.
//

import Foundation
import SpriteKit

struct ActorData {
    var name:String
    var pos:Int
    var lastActionName:String
    var sequence: [String]
    var hue:Float
    var isSequenceReady:Bool;
    var currentSequenceIndex:Int;
}


class SpaceshipScene: SKScene {
    
    var backgroundArray : NSArray = []
    var characters : NSArray = []
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        backgroundArray = ["Candy","Desert","Jungle","Space","Ocean","Yay"]
        characters = ["Freds","Guac","LeBlob","Meep","Pom","Sausalito"]
        
        let getRandomBackground = randomSequenceGenerator(0, max: backgroundArray.count-1)
        let getRandomCharacter = randomSequenceGenerator(0, max: characters.count-1)
        
        let center = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame))
        
        let background = SKSpriteNode(imageNamed: backgroundArray[getRandomBackground()] as! String)
        background.position = center
        background.zPosition = -1
        scene?.addChild(background)
        
        let wait = SKAction.waitForDuration(0.3)
        let run = SKAction.runBlock {
            self.spaceshipFlyInAndDropEggs()
        }
        self.runAction(SKAction.sequence([wait,run,wait,]))
    }
 
    
    // MARK: - Spaceship Methods
    
    func spaceshipFlyInAndDropEggs()
    {
        let spaceship = SKSpriteNode(imageNamed: "Spaceship")
        spaceship.setScale(0.2)
        spaceship.name = "spaceship"
        spaceship.position = CGPoint(
            x: 150,
            y: scene!.frame.size.height-200)
        self.addChild(spaceship)
        
        let group =  SKAction.group(
            [
                SKAction.scaleTo(1.0, duration: 0.3),
//                SKAction.rotateToAngle(-20, duration: 0.6),
                SKAction.moveTo(CGPoint(x:CGRectGetMidX(scene!.frame), y: scene!.frame.size.height-160), duration: 0.6)
            ])
        
        self.runAction(SKAction.playSoundFileNamed("sound/common/FlyInAndDrop.mp3", waitForCompletion: false))
        
        spaceship.runAction(SKAction.sequence(
            [
                group
               ,
                
//                SKAction.rotateByAngle(20, duration: 0.0),
                SKAction.runBlock({self.dropEgg()}),
                SKAction.group(
                    [
                        SKAction.moveToY(scene!.frame.size.height-260, duration: 2.0)
                    ]),
                SKAction.group(
                    [
//                        SKAction.rotateByAngle(53, duration: 0.6),
                        SKAction.moveTo(CGPoint(x: scene!.frame.size.width+350, y: scene!.frame.size.height+350), duration: 0.6),
                        SKAction.scaleTo(0.2, duration: 1.0)
                    ])
            ]
            ))
        
    }
    
    func spaceshipFlyInAndTakeAwayEggs()
    {
        let spaceship = self.childNodeWithName("spaceship")
        if((spaceship) != nil)
        {
             self.runAction(SKAction.playSoundFileNamed("sound/common/FlyAway.mp3", waitForCompletion: false))
            
            let group =  SKAction.group(
                [
                    SKAction.scaleTo(1.0, duration: 0.3),
                    //                SKAction.rotateToAngle(-20, duration: 0.6),
                    SKAction.moveTo(CGPoint(x:CGRectGetMidX(scene!.frame), y: scene!.frame.size.height-160), duration: 0.6)
                ])
            
            self.runAction(SKAction.playSoundFileNamed("sound/common/FlyInAndDrop.mp3", waitForCompletion: false))
            
            spaceship!.runAction(SKAction.sequence(
                [
                    group
                    ,
                    
                    //                SKAction.rotateByAngle(20, duration: 0.0),
                    SKAction.runBlock({self.takeAwayEggs()}),
                    SKAction.group(
                        [
                            SKAction.moveToY(scene!.frame.size.height-260, duration: 2.0)
                        ]),
                    SKAction.group(
                        [
                            //                        SKAction.rotateByAngle(53, duration: 0.6),
                            SKAction.moveTo(CGPoint(x: scene!.frame.size.width+350, y: scene!.frame.size.height+350), duration: 0.6),
                            SKAction.scaleTo(0.2, duration: 1.0)
                        ])
                ]
                ))
        }
    }
    
    func dropEgg()
    {
//        ActorData m_currentActor = self.characters[getran]
        
//        let atlas = SKTextureAtlas.init(named: "eggIdle")
//        print(atlas.textureNames.count)
//        
//        let egg = SKSpriteNode(texture: atlas.textureNamed("Freds0000.png"))
//        
//        egg.position = CGPoint(
//            x: CGRectGetMidX(scene!.frame),
//            y: CGRectGetMidY(scene!.frame))
//        
//        self.addChild(egg)

    }
    
    func takeAwayEggs()
    {
        
    }
    
    // MARK: - Other methods

    func randomSequenceGenerator(min: Int, max: Int) -> () -> Int {
        var numbers: [Int] = []
        return {
            if numbers.count == 0 {
                numbers = Array(min ... max)
            }
            
            let index = Int(arc4random_uniform(UInt32(numbers.count)))
            return numbers.removeAtIndex(index)
        }
    }
    
    
    
}
