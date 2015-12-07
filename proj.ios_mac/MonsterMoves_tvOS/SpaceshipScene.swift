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


class SpaceshipScene: SKScene,JSONSpriteDelegate {
    
    var backgroundArray : NSArray = []
    var characters : NSArray = []
    private var m_eggReady : Bool = false
    private var m_eggCrackSoundId : Int = -1
    private var m_circle : SKSpriteNode = SKSpriteNode()
    private var m_actor : JSONSprite = JSONSprite()
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        backgroundArray = ["Candy","Desert","Jungle","Space","Ocean","Yay"]
        
       // characters = ["Freds","Guac","LeBlob","Meep","Pom","Sausalito"]
         characters = ["LeBlob"]
        
        let getRandomBackground = randomSequenceGenerator(0, max: backgroundArray.count-1)
        
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
    
    func touchpadTapped()
    {
        if(m_eggReady)
        {
            var leblob : JSONSprite
            leblob = self.childNodeWithName("leblob") as! JSONSprite
            
            
//            var actor : JSONSprite = self.childNodeWithName("leblob") as! JSONSprite
            if(leblob.m_currentActionName.isEmpty || leblob.m_currentActionName == "eggIdle")
            {
                leblob.removeAllActions()
                playEggCrackSound()
                leblob.playAction("eggCrack0")
            }
            else if(leblob.m_currentActionName == "eggCrack0")
            {
                leblob.removeAllActions()
                playEggCrackSound()
                leblob.playAction("eggCrack1")
            }
            else if(leblob.m_currentActionName == "eggCrack1")
            {
                leblob.removeAllActions()
                leblob.playAction("crackEntrance")
                

            }
            else if(leblob.m_currentActionName == "crackEntrance")
            {
                leblob.removeAllActions()
                self.getReadyForDanceScene()
                
            }
           
        }
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
                SKAction.runBlock({self.dropEggs()}),
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
    
    // MARK: - Egg Methods
    
    func dropEggs()
    {
        let center = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame)-200)
        
        
        let getRandomCharacter = randomSequenceGenerator(0, max: characters.count-1)
        let actor = JSONSprite.init(fileNamed: characters[getRandomCharacter()] as! String)
        actor.m_delegate = self
        actor.position = center
        actor.name = "leblob"
        
        actor.preloadActions(["eggCrack0", "eggCrack1", "crackEntrance", "idle"])
        
        addChild(actor)
        self.eggsReady()

    }
    
    func eggsReady()
    {
        let actor = self.childNodeWithName("leblob") as! JSONSprite
        actor.playAction("eggIdle")
        m_eggReady = true
        
        let tapgesture = UITapGestureRecognizer(target: self, action: "touchpadTapped")
        tapgesture.allowedPressTypes = [NSNumber (integer: UIPressType.Select.rawValue)]
        self.view?.addGestureRecognizer(tapgesture)
        
    }
    
    func takeAwayEggs()
    {
        
    }
    
    // MARK: - Dance Scene Methods
    
    func getReadyForDanceScene()
    {
        
        self.setupPhysics()
        self.sizeAndGrow()
    
        self.startIdle()
        
        
    }
    
    func setupPhysics()
    {
        
    }
    
    func startIdle()
    {
        m_actor.playAction("idle")
        self.runAction(SKAction.sequence([SKAction.waitForDuration(5),SKAction.runBlock({self.setupDropZones()})]))
        m_actor.preloadActions(["dance1","dance2","dance3","dance4","dance5","dance6","dance7","dance8"])
    }
    
    func sizeAndGrow()
    {
        m_actor = self.childNodeWithName("leblob") as! JSONSprite
        m_actor.runAction(SKAction.moveTo(CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame)), duration: 1.0))
        m_actor.setScale(1.5)
        
    }
    
    func setupDropZones()
    {
        
    }
    
    func setupTiles()
    {
        var i : Double = 0;
        for var iter=0; iter <= m_actor.m_actions.count; iter++
        {
            let actionName : String = m_actor.m_actions.keys.first!
            let ad : ActionData = m_actor.m_actions[actionName]!
            if(ad.type == 1 )
            {
                self.runAction(SKAction.sequence([SKAction.waitForDuration(i * 0.3),SKAction.runBlock({self.addActionTile(ad.actionaName)})]))
                i=i+1
            }
            
        }
    }
    
    
    func addActionTile(actionName : String)
    {
        self.addTile(actionName,type : TileType.TileTypeNormal)
    }
    
    func addTile(actionName : String, type : TileType)
    {
//        if(dropzoneisFull() && )
    }
    
    
    
    func dropzoneIsFull() -> Bool
    {
//        var dropCount : Int = 4
//        let zone : DropzoneSprite = m_dropzoneBodies[i].getUserData()
//        if(zone.m_tile)
//        {
//            dropCount++ ;
//        }
//        return dropCount == 4
        return false
    }
    
    //Mark: - Sound Methods
    
    
    func playEggCrackSound()
    {
        var i : Int = random()%3+1
        while(i == m_eggCrackSoundId)
        {
            i = random()%3 + 1
        }
        m_eggCrackSoundId = i
        
        let soundFile = String(format: "sound/common/EggCrack_%d.mp3", m_eggCrackSoundId)
        self.runAction(SKAction.playSoundFileNamed(soundFile, waitForCompletion: false))
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
    
    
    
   
    func actionPreloaded(actionName: String) {
        
    }
    
    func actionStopped(sprite: JSONSprite) {
        
    }
    
    
}
