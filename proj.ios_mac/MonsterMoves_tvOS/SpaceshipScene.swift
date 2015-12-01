//
//  SpaceshipScene.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright © 2015 IDEO. All rights reserved.
//

import Foundation
import SpriteKit
class SpaceshipScene: SKScene {
    
    override func didMoveToView(view: SKView) {
    /* Setup your scene here */
    
    let center = CGPoint(
        x: CGRectGetMidX(scene!.frame),
        y: CGRectGetMidY(scene!.frame))
    
    let background = SKSpriteNode(imageNamed: "Space")
    background.position = center
    background.zPosition = -1
    scene?.addChild(background)
    
        
        
    let wait = SKAction.waitForDuration(0.3)
    let run = SKAction.runBlock {
        self.spaceshipFlyInAndDropEggs()
    }
    self.runAction(SKAction.sequence([wait,run]))
    
    }
    
    
    func spaceshipFlyInAndDropEggs()
    {
        let spaceship = SKSpriteNode(imageNamed: "Spaceship")
        spaceship.setScale(0.2)
        spaceship.position = CGPoint(
            x: 150,
            y: scene!.frame.size.height-200)
        self.addChild(spaceship)
        
        let group =  SKAction.group(
            [
                SKAction.scaleTo(1.0, duration: 1.0),
//                SKAction.rotateToAngle(-20, duration: 0.6),
                SKAction.moveTo(CGPoint(x:CGRectGetMidX(scene!.frame), y: scene!.frame.size.height-160), duration: 0.6)
            ])
        
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
    
    func dropEgg()
    {
        
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
}
