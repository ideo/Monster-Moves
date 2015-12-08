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
    
    
    //DanceScene
    private var minTileGenY : Float = 0
    private var m_dropzoneBodies : NSMutableArray = []
    private var m_tiles : NSMutableArray = []
    private var m_dancePreloadedCount : Int = 0;
    private var m_readyToDance : Bool = false
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        backgroundArray = ["Candy","Desert","Jungle","Space","Ocean","Yay"]
        
        //characters = ["Freds","Guac","LeBlob","Meep","Pom","Sausalito"]
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
        if(m_readyToDance)
        {

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
        self.setupCentralCircle()
        self.sizeAndGrow()
        self.startIdle()
        self.runAction(SKAction.sequence([SKAction.waitForDuration(5),SKAction.runBlock({self.putInDropZone()})]))
    }
    
    
    func putInDropZone()
    {
        for var i = 0; i<4; i++
        {
            
            let tileSprite : TileSprite = m_tiles[i] as! TileSprite
            tileSprite.position = m_dropzoneBodies[i].position
            tileSprite.physicsBody = nil
            let dropZoneSprite : DropzoneSprite = m_dropzoneBodies[i] as! DropzoneSprite
            dropZoneSprite.showCircle()
        }
        
        self.checkDropzonesToPlay()
//        for var i = 0; i<4; i++
//        {
//            tilePressed(m_tiles[i] as! TileSprite)
//        }
    }
    
    func checkDropzonesToPlay()
    {
        if(dropzoneIsFull())
        {
//            removeFloatingTiles()
        }
        self.runAction(SKAction.sequence([SKAction.waitForDuration(5),SKAction.runBlock({self.timeToTransitionToNextCharacter()})]))
        
    }
    
    func timeToTransitionToNextCharacter()
    {
        self.spaceshipFlyInAndTakeAwayEggs()
        for sprites in m_dropzoneBodies
        {
            sprites.removeFromParent()
        }
        m_dropzoneBodies.removeAllObjects()
        
        for tiles in m_tiles
        {
            tiles.removeFromParent()
        }
        m_tiles.removeAllObjects()
        m_circle.removeFromParent()
        m_actor.removeFromParent()

        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(5),SKAction.runBlock({self.spaceshipFlyInAndDropEggs()})]))
        
        
    }
    
    func prepareToPlay()
    {
        
    }
    
    
    func tilePressed(tile : TileSprite)
    {
        
        for var i = 0; i < 4; i++
        {
            let zone : DropzoneSprite = m_dropzoneBodies[i] as! DropzoneSprite;
            if (zone.m_tile == nil) {
                zone.dropTile(tile);
//                checkDropzonesToPlay();
                break;
            }
        }
    }
    
    func setupPhysics()
    {
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        let borderBody : SKPhysicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = borderBody
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.categoryBitMask = 0x0001
        self.physicsBody?.collisionBitMask = 0x0002
        
    }
    
    func setupCentralCircle()
    {
        m_circle = SKSpriteNode(imageNamed: "tiles-leblob/bgCircle")
        m_circle.position = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame)+100)
        m_circle.zPosition = 3
        addChild(m_circle)
        
        m_circle.physicsBody = SKPhysicsBody(circleOfRadius: 370)
        m_circle.physicsBody?.dynamic = false
        m_circle.physicsBody?.density = 1.0
        m_circle.physicsBody?.restitution = 1.0
        m_circle.physicsBody?.categoryBitMask = 0x0008
        m_circle.physicsBody?.collisionBitMask = 0x0002
        
        
    }
    
    func startIdle()
    {
        m_actor.playAction("idle")
        self.runAction(SKAction.sequence([SKAction.waitForDuration(0.5),SKAction.runBlock({self.setupDropZones()})]))
        m_actor.preloadActions(["dance1","dance2","dance3","dance4","dance5","dance6","dance7","dance8"])
    }
    
    func sizeAndGrow()
    {
        m_actor = self.childNodeWithName("leblob") as! JSONSprite
        m_actor.runAction(SKAction.moveTo(CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame)+100), duration: 1.0))
        m_actor.setScale(1.2)
        
    }
    
    func setupDropZones()
    {
        let dropzoneTotalWidth : Float = 876
        for var i = 0 ; i < 4; i++
        {
            let dropzone : DropzoneSprite = DropzoneSprite(imageNamed: "dropzone")
            
            // Expression too complex for swift to calculate so dividing it into subcalculations
            let f : Double = Double(i) * Double(dropzoneTotalWidth/3)
            let p = CGPoint(x: Double(-dropzoneTotalWidth/2) + f, y: Double(0))
            
            dropzone.position = CGPoint(x: Double(CGRectGetMidX(scene!.frame)) + Double(p.x), y: 150)
            dropzone.m_index = i
            dropzone.m_tileColor = m_actor.m_tileColor
            dropzone.setScale(0)
            addChild(dropzone)
            
            dropzone.runAction(SKAction.scaleTo(1.0, duration: 1.0))
            minTileGenY = Float(dropzone.position.y + dropzone.size.height/2)
            
            let dropBody : SKPhysicsBody = SKPhysicsBody(circleOfRadius: 132)
            dropBody.density = 1.0
            dropBody.dynamic = false
            dropBody.friction = 0.0
            dropBody.restitution = 1.0
            dropBody.categoryBitMask = 0x0004
            dropBody.collisionBitMask = 0x0002
            dropBody.allowsRotation = true
            dropzone.physicsBody = dropBody
            
            m_dropzoneBodies.addObject(dropzone)
            
        }
    }
    
    func setupTiles()
    {
        var i : Double = 0;
        for var iter=0; iter < m_actor.m_actions.count; iter++
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
        if(dropzoneIsFull() && type != TileType.TileTypeColorChange )
        {
            return
        }
        
        if(type == TileType.TileTypeColorChange && (self.childNodeWithName("COLOR_CHANGE_TILE_TAG") != nil))
        {
            return
        }else
        {
            
        }
        
        
        var filename : String = ""
        
        if(type == TileType.TileTypeColorChange)
        {
            
        }
        else
        {
            filename = String(format: "tiles-%@/%@",m_actor.m_name,actionName)
        }
        
        let tile : TileSprite = TileSprite(imageNamed: filename)
        tile.m_type = type
        tile.m_actionName = actionName
//        tile.m_delegate = self
        if(type == TileType.TileTypeColorChange)
        {
            tile.name = "COLOR_CHANGE_TILE_TAG"
        }
        
        var point : CGPoint
        var leftCount : Int = 0
        var rightCount : Int = 0
        
        let left : Bool
        if (leftCount == rightCount) {
            left = ((rand() % 10) <= 4);
        } else {
            left = (leftCount < rightCount);
        }
        
        let subbend : Float =  Float(tile.size.width) + 400.0
        let randomF : Int = random() % Int(Float((scene?.frame.size.height)!) - minTileGenY - subbend)
        
        let frameWidth : Int = Int((scene?.frame.size.height)!) / 2
        let leftTile : Int = 380 + Int(tile.size.width) + 70
        let leftpoint : Int = random() % Int(frameWidth - leftTile)
        
        let tileY : Float
        tileY = minTileGenY + Float(tile.size.height / 2) + Float(randomF)
        
        let p : CGPoint
        
        if(left)
        {
            if (type == TileType.TileTypeColorChange || m_dancePreloadedCount < 8) {
                p = CGPoint(x: Int(tile.size.width/2 + 70) + leftpoint, y: Int(tileY))
            } else {
                p = CGPoint(x: Int(-30 - tile.size.width/2),y: Int(tileY));
            }
        }
        else
        {
            let p1 : Int = 1340 + random() % Int(510 - tile.size.width)
            
            if (type == TileType.TileTypeColorChange || m_dancePreloadedCount < 8) {
                p = CGPoint(x: Int(Int(tile.size.width/2) + p1 ), y: Int(tileY))
            } else {
                p = CGPoint(x: Int(1950 + tile.size.width/2),y: Int(tileY));
            }
        }
        
        tile.position = p
        tile.setScale(0)
        tile.zPosition = 2
        self.addChild(tile)
        tile.physicsBody = tile.attachPhysics()
        
        tile.physicsBody?.applyImpulse(CGVectorMake(100.0, -20.0))
        tile.runAction(SKAction.scaleTo(1.0, duration: 1.0))
        m_tiles.addObject(tile)
        
    }
    
    
    
    func dropzoneIsFull() -> Bool
    {
        var dropCount : Int = 0
        
        for sprite in m_dropzoneBodies
        {
            let zone: DropzoneSprite = sprite as! DropzoneSprite
            if(zone.m_tile != nil)
            {
                dropCount++
            }
        }
        
        return dropCount == 4
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
    func randomSequenceGenerator(min: Int, max: Int) -> () -> Int
    {
        var numbers: [Int] = []
        return {
            if numbers.count == 0 {
                numbers = Array(min ... max)
            }
            
            let index = Int(arc4random_uniform(UInt32(numbers.count)))
            return numbers.removeAtIndex(index)
        }
    }
    
    
    
    // MARK: - Delegate methods
    func actionPreloaded(actionName: String)
    {
        if(actionName.hasPrefix("dance"))
        {
            addActionTile(actionName);
            m_dancePreloadedCount++
            if(m_dancePreloadedCount>=4)
            {
                m_readyToDance = true
            }
        }
    }
    
    func actionStopped(sprite: JSONSprite)
    {
        
    }
    
    
}
