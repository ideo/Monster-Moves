//
//  SpaceshipScene.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright © 2015 IDEO. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation
import GameController


struct ActorData {
    var name:String
    var pos:Int
    var lastActionName:String
    var sequence: [String]
    var hue:Float
    var isSequenceReady:Bool;
    var currentSequenceIndex:Int;
}

struct GlobalConstants {
    static let dropzoneScale : CGFloat = 0.9
    static let tileScale : CGFloat = 0.9
    static let scaledTileScale : CGFloat = 1.1
    static let currentMONSTER : String = "MONSTER"
    static let automateSelection : String = "automateSelection"
}


class SpaceshipScene: SKScene,JSONSpriteDelegate, ReactToMotionEvents {
    
    var backgroundArray : NSArray = ["Cowboy","Cumbia","Funk","Hiphop","Latin","Space"]
    var characters : NSArray = []
    private var tutorialplayer: AVPlayer!
    private var m_eggReady : Bool = false
    private var m_eggCrackSoundId : Int = -1
    private var m_circle : SKSpriteNode = SKSpriteNode()
    private var m_actor : JSONSprite = JSONSprite()
    private var m_currentBackground : Int = 0
    private var m_currentStamp : String = "space"
    private var m_previousActor : Int = 0
    
    private var tutorialvideo: SKVideoNode!
    
    private var tapSprite : SKSpriteNode?
    private var shakeSprite : SKSpriteNode?
    
    
    // MARK: - DanceAct
    private var minTileGenY : Float = 0
    private var m_dropzoneBodies : NSMutableArray = []
    
    /// All the tiles
    private var m_tiles : NSMutableArray = []
    
    ///Focused tile
    private var m_focusedTileIndex : Int = -1
    
    private var m_dancePreloadedCount : Int = 0
    private var m_readyToDance : Bool = false
    private var m_isPlaying : Bool = false
    private var m_pace : Int = 0
    private var m_currentSequenceIndex : Int = 0
    private var backgroundAudioPlayer: AVAudioPlayer = AVAudioPlayer();
    private var m_danceLoopCount : Int = 0
    private var readyCountLabel : SKLabelNode?
    
    // ParticleEffect
    private var particleEmmiter : SKEmitterNode!
    
    
    
    
    
    
    override func didMoveToView(view: SKView) {
        
        /* Setup your scene here */
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        
        
        particleEmmiter = SKEmitterNode(fileNamed: "Snow.sks")
        particleEmmiter.position = CGPoint(x: 0, y: self.frame.size.height)
        particleEmmiter.particleBirthRate = 0
        
        
        
        
     //  backgroundArray = ["Space"]
        
        characters = ["Freds","Guac","LeBlob","Meep","Pom","Sausalito"]
     //   characters = ["Meep"]
        
        let center = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame))
        
        let background = SKSpriteNode(texture: getRandomBackground())
        background.name = "background"
        background.position = center
        background.zPosition = -2
        scene?.addChild(background)
        
        let backgroundSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(String(format: "sound/beats/01_Select/01_%@",backgroundArray[m_currentBackground] as! String), ofType: "mp3")!)
        do{
            backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL:backgroundSound)
            backgroundAudioPlayer.prepareToPlay()
            backgroundAudioPlayer.play()
            backgroundAudioPlayer.numberOfLoops = -1
        }catch {
            print("Error getting the audio file")
        }
        
        let tapgesture = UITapGestureRecognizer(target: self, action: "touchpadTapped")
        tapgesture.allowedPressTypes = [NSNumber (integer: UIPressType.Select.rawValue)]
        self.view?.addGestureRecognizer(tapgesture)
        
        let wait = SKAction.waitForDuration(0.3)
        let run = SKAction.runBlock {
            self.spaceshipFlyInAndDropEggs()
        }
        self.runAction(SKAction.sequence([wait,run,wait,]))
        
        
        
        readyCountLabel = SKLabelNode(text: "0")
        readyCountLabel?.position = CGPoint(x: 1600, y: 700)
        readyCountLabel?.color = UIColor.redColor()
        readyCountLabel?.fontColor = UIColor.redColor()
        readyCountLabel?.fontSize = 300
        readyCountLabel?.fontName = "SF UI Display Regular"
        readyCountLabel?.hidden = true
        addChild(readyCountLabel!)
            
        
        addChild(particleEmmiter)
    }
    
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for press in presses {
            switch press.type {
            case .Menu:
                print("Menu")
                break;
                
            default:
                break;
                
            }
        }
    }
    
    
    // MARK: - Interactions
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(m_readyToDance)
        {
            pickRandomTile()
        }
    }
    
    
    
    func addTutorialForTap()
    {
        let textureAtlas = SKTextureAtlas(named: "Tapgesture")
        let spritesArray : NSMutableArray = NSMutableArray()
        let numImages = textureAtlas.textureNames.count
        
        for var i=0; i < numImages ; i++
        {
            spritesArray.addObject(textureAtlas.textureNamed(String(format: "tap_%05d", i)))
        }
        
        tapSprite = SKSpriteNode(texture: spritesArray[0] as! SKTexture)
        tapSprite!.setScale(0.85)
        tapSprite!.alpha = 0.9
        tapSprite!.position = CGPoint(
            x: scene!.frame.size.width-100,
            y: 280)
        self.addChild(tapSprite!)
        let animateArray : NSArray = spritesArray
        tapSprite!.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(animateArray as! [SKTexture], timePerFrame: 1/15, resize: false, restore: false)))
    }
    
    func removeTapTutorial()
    {
        if(tapSprite?.parent != nil)
        {
            tapSprite?.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.5),SKAction.removeFromParent()]))
        }
    }
    
    func removeShakeTutorial()
    {
        if(shakeSprite?.parent != nil)
    {
        shakeSprite?.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.5),SKAction.removeFromParent()]))
        }
    }
    
    
    
    func addTutorialforShake()
    {
        let textureAtlas = SKTextureAtlas(named: "Shakegesture")
        let spritesArray : NSMutableArray = NSMutableArray()
        let numImages = textureAtlas.textureNames.count
        
        for var i=0; i < numImages ; i++
        {
            spritesArray.addObject(textureAtlas.textureNamed(String(format: "shake_%05d", i+27)))
        }
        shakeSprite = SKSpriteNode(texture: spritesArray[0] as! SKTexture)
        shakeSprite!.setScale(0.85)
        shakeSprite!.alpha = 0.9
        shakeSprite!.position = CGPoint(
            x: scene!.frame.size.width-100,
            y: 280)
        self.addChild(shakeSprite!)
        let animateArray : NSArray = spritesArray
        shakeSprite!.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(animateArray as! [SKTexture], timePerFrame: 1/15, resize: false, restore: false)))
    }
    
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event:
        UIEvent?) {
            if(m_isPlaying)
            {
                
                for touch in touches
                {
                    let location = touch.locationInNode(self)
                    addStamp(location)
                }
            }
    }
    
    
    
    /// Logic to crack Eggs and randomly put in Tiles on Touch Pad : Top
    func touchpadTapped()
    {
        
        if(m_eggReady)
        {
            var actor : JSONSprite
            actor = self.childNodeWithName(GlobalConstants.currentMONSTER) as! JSONSprite
            if(actor.m_currentActionName.isEmpty || actor.m_currentActionName == "eggIdle")
            {
                self.removeTapTutorial()
                actor.removeAllActions()
                playEggCrackSound()
                actor.playAction("eggCrack0")
            }
            else if(actor.m_currentActionName == "eggCrack0")
            {
                actor.removeAllActions()
                playEggCrackSound()
                actor.playAction("eggCrack1")
            }
            else if(actor.m_currentActionName == "eggCrack1")
            {
                actor.removeAllActions()
                actor.playAction("crackEntrance")
            }
        }
        else if(m_readyToDance)
        {
            if(m_focusedTileIndex > -1)
            {
                self.removeActionForKey(GlobalConstants.automateSelection)
                self.runAction(SKAction.sequence([SKAction.waitForDuration(10),SKAction.runBlock({self.putRandomTilesInDropZone()})]), withKey: GlobalConstants.automateSelection)
                self.putTileInDropZone(m_tiles[m_focusedTileIndex] as! TileSprite)
            }
        }
        else if(m_isPlaying)
        {
            addStamp(CGPointZero)
        }
        
    }
    
    func addStamp(point : CGPoint)
    {
        let Stamp : SKSpriteNode = SKSpriteNode(imageNamed: m_currentStamp)
        if(point == CGPointZero)
        {
            Stamp.position = CGPoint(x:Int(arc4random_uniform(UInt32(1920))) , y: Int(arc4random_uniform(UInt32(1080))))
        }
        else
        {
                            Stamp.position = point
        }
        Stamp.zPosition = 0
        Stamp.setScale(CGFloat((125.0 - Double(random() % 51)) / 100.0))
        Stamp.runAction(SKAction.rotateByAngle(CGFloat(Double(random()) % 6.28319), duration: 0))
        
        playStampSound();
        
        self.addChild(Stamp)
        Stamp.runAction(SKAction.sequence([SKAction.waitForDuration(0.5),SKAction.fadeOutWithDuration(0.8),SKAction.removeFromParent()]))
    }
    
    
    
    
    
    func playStampSound()
    {
        let i = random() % 3 + 1
        self.runAction(SKAction.playSoundFileNamed(String(format: "sound/common/Tap%d.wav",i), waitForCompletion: false))
    }
    
    
    func getRandomBackground() -> SKTexture
    {
        let randomBackgroundGenerator = randomSequenceGenerator(0, max: backgroundArray.count-1)
        var temp = randomBackgroundGenerator()
        if(temp == m_currentBackground)
        {
            temp = randomBackgroundGenerator()
        }
        m_currentBackground = temp
        return SKTexture(imageNamed: backgroundArray[m_currentBackground] as! String)
    }
    
    func setCurrentParticleEmitter()
    {
        // ["Cowboy","Cumbia","Funk","Hiphop","Latin","Space"]
        var stamps : NSArray = NSArray()
        
        switch(m_currentBackground)
        {
        case 0:
            stamps = ["Cowboy1","Cowboy2","Cowboy3"]
            m_currentStamp = stamps[Int(arc4random_uniform(UInt32(stamps.count)))] as! String
            particleEmmiter.particleTexture = SKTexture(imageNamed: "ParticleEffects/Cowboy")
            break;
            
        case 1:
            stamps = ["Cumbia1","Cumbia2","Cumbia3"]
            m_currentStamp = stamps[Int(arc4random_uniform(UInt32(stamps.count)))] as! String
            particleEmmiter.particleTexture = SKTexture(imageNamed: "ParticleEffects/Cumbia")
            break;
            
        case 2:
            stamps = ["Funk1","Funk2","Funk3","Funk4"]
            let particles : NSArray = NSArray(objects: "ParticleEffects/Funk1","ParticleEffects/Funk2")
            m_currentStamp = stamps[Int(arc4random_uniform(UInt32(stamps.count)))] as! String
            particleEmmiter.particleTexture = SKTexture(imageNamed: particles[Int(arc4random_uniform(UInt32(particles.count)))] as! String)
            break;
            
        case 3:
            stamps = ["Hiphop1","Hiphop2"]
            m_currentStamp = stamps[Int(arc4random_uniform(UInt32(stamps.count)))] as! String
            particleEmmiter.particleTexture = SKTexture(imageNamed: "ParticleEffects/Hiphop")
            break;
            
        case 4:
            stamps = ["Latin1","Latin2","Latin3","Latin4"]
            m_currentStamp = stamps[Int(arc4random_uniform(UInt32(stamps.count)))] as! String
            particleEmmiter.particleTexture = SKTexture(imageNamed: "ParticleEffects/Latin")
            break;
            
        case 5:
            stamps = ["Space1","Space2"]
            m_currentStamp = stamps[Int(arc4random_uniform(UInt32(stamps.count)))] as! String
            particleEmmiter.particleTexture = SKTexture(imageNamed: "ParticleEffects/Space")
            break;
            
            
        default:
            break;
            
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
        spaceship.zPosition = 5
        
        let group =  SKAction.group(
            [
                SKAction.scaleTo(1.0, duration: 0.3),
                SKAction.rotateToAngle(-0.349, duration: 0.6),
                SKAction.moveTo(CGPoint(x:CGRectGetMidX(scene!.frame), y: scene!.frame.size.height-160), duration: 0.6)
            ])
        
        self.runAction(SKAction.playSoundFileNamed("sound/common/FlyInAndDrop.mp3", waitForCompletion: false))
        spaceship.runAction(SKAction.sequence(
            [
                group
                ,
                
                SKAction.rotateByAngle(0.349, duration: 0.0),
                SKAction.sequence(
                    [
                        SKAction.moveToY(scene!.frame.size.height-260, duration: 1.5),
                        SKAction.waitForDuration(0.5),
                        SKAction.runBlock({self.dropEggs()}),
                        SKAction.waitForDuration(0.5)
                    ]),
                SKAction.group(
                    [
                        SKAction.rotateByAngle(0.349, duration: 0.6),
                        SKAction.moveTo(CGPoint(x: scene!.frame.size.width+350, y: scene!.frame.size.height+350), duration: 0.6),
                        SKAction.scaleTo(0.2, duration: 1.0),
                    ])
            ]
            ))
        
    }
    
    func spaceshipFlyInAndTakeAwayEggs()
    {
        m_isPlaying = false
        let spaceship = self.childNodeWithName("spaceship")
        if((spaceship) != nil)
        {
            self.runAction(SKAction.playSoundFileNamed("sound/common/FlyAway.mp3", waitForCompletion: false))
            
            let group =  SKAction.group(
                [
                    SKAction.scaleTo(1.0, duration: 0.3),
                    SKAction.rotateToAngle(-0.349, duration: 0.6),
                    SKAction.moveTo(CGPoint(x:CGRectGetMidX(scene!.frame), y: scene!.frame.size.height-260), duration: 0.6)
                ])
            
            self.runAction(SKAction.playSoundFileNamed("sound/common/FlyInAndDrop.mp3", waitForCompletion: false))
            
            spaceship!.runAction(SKAction.sequence(
                [
                    group
                    ,
                    
                    SKAction.rotateByAngle(0.349, duration: 0.0),
                    SKAction.group(
                        [
                            SKAction.moveToY(scene!.frame.size.height-160, duration: 2.0),
                            SKAction.runBlock({self.timeToTransitionToNextCharacter()})
                        ]),
                    SKAction.group(
                        [
                            SKAction.runBlock({self.dropEggs()}),
                            SKAction.waitForDuration(0.6),
                            SKAction.rotateByAngle(0.349, duration: 0.6),
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
        y: CGRectGetMidY(scene!.frame))
        
        
        let getRandomCharacter = randomSequenceGenerator(0, max: characters.count-1)
        var temp = getRandomCharacter()
        if(temp == m_previousActor)
        {
            temp = getRandomCharacter()
        }
        m_previousActor = temp
        
        let actor = JSONSprite.init(fileNamed: characters[m_previousActor] as! String)
        actor.m_delegate = self
        actor.position = center
        actor.name = GlobalConstants.currentMONSTER
        actor.setScale(1.20)
        actor.preloadActions(["eggCrack0", "eggCrack1", "crackEntrance","moveForward", "idle","exit"])
        addChild(actor)
        
        actor.runAction(SKAction.moveToY(CGRectGetMidY(scene!.frame)-200, duration: 0.3))
        self.eggsReady()
        self.m_eggReady = true
        
    }
    
    func eggsReady()
    {
        let actor = self.childNodeWithName(GlobalConstants.currentMONSTER) as! JSONSprite
        actor.playAction("eggIdle")
        //m_eggReady = true
        addTutorialForTap()
    }
    
    // MARK: - Dance Scene Methods
    
    func getReadyForDanceScene()
    {
        self.removeTapTutorial()
        self.setupPhysics()
        self.sizeAndGrow()
        self.setupCentralCircle()
        self.startIdle()
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(10),SKAction.runBlock({self.putRandomTilesInDropZone()})]), withKey: GlobalConstants.automateSelection)
    }

    
    
    /// Picks a random tile and focuses on it
    func pickRandomTile()
    {
        let randomMoves = randomSequenceGenerator(0, max: m_tiles.count-1)
        for var i = 0; i<m_tiles.count ; i++
        {
            let tileSprite : TileSprite = m_tiles[i] as! TileSprite
            if(tileSprite.xScale != 0)
            {
                tileSprite.runAction(SKAction.scaleTo(GlobalConstants.tileScale, duration: 0.1))
                tileSprite.removeCircle()
            }
        }
        
        m_focusedTileIndex = randomMoves()
        let tileSprite : TileSprite = m_tiles[m_focusedTileIndex] as! TileSprite
        if(tileSprite.xScale != 0)
        {
            tileSprite.runAction(SKAction.scaleTo(GlobalConstants.scaledTileScale, duration: 0.1))
            tileSprite.showCircle(m_actor.m_name)
             print("Tile highlighted should be ",m_focusedTileIndex)
        }
        
    }
    
    
    func putRandomTilesInDropZone()
    {
        self.removeActionForKey(GlobalConstants.automateSelection)
        for var i=0; i < m_dropzoneBodies.count ; i++
        {
            let dropzoneSprite = m_dropzoneBodies[i] as! DropzoneSprite
            if(dropzoneSprite.m_tile == nil)
            {
                let randomMoves = randomSequenceGenerator(0, max: m_tiles.count-1)
                putTileInDropZone(m_tiles[randomMoves()] as! TileSprite)
            }
        }
        m_actor.playAction("idle")
    }
    
    
    func putTileInDropZone(tile : TileSprite)
    {
        var index : Int = -1
        for var i=0; i < m_dropzoneBodies.count ; i++
        {
            let dropZoneSprite : DropzoneSprite = m_dropzoneBodies[i] as! DropzoneSprite
            if(dropZoneSprite.m_tile == nil)
            {
                index = i
                break;
            }
        }
        
        if(index != -1)
        {
            tile.removeCircle()
            m_actor.playAction(tile.m_actionName!)
            tile.setScale(GlobalConstants.tileScale)
            tile.position = m_dropzoneBodies[index].position
            tile.physicsBody = nil
            
            let dropZoneSprite : DropzoneSprite = m_dropzoneBodies[index] as! DropzoneSprite
            self.runAction(SKAction.playSoundFileNamed("sound/common/TileTap1.mp3", waitForCompletion: false))
            tile.runAction(SKAction.group([SKAction.scaleTo(GlobalConstants.tileScale, duration: 0.3),SKAction.moveTo(dropZoneSprite.position, duration: 0.3)]))
            
            tile.m_dropzoneIndex = index
            dropZoneSprite.m_tile = tile
            dropZoneSprite.showCircle(m_actor.m_name)
            
            m_tiles.removeObject(tile)
            pickRandomTile()
            addActionTile(tile.m_actionName!)
        }
        self.checkDropzonesToPlay()
    }
    
    
    
    func checkDropzonesToPlay()
    {
        if(self.dropzoneIsFull())
        {
            self.removeActionForKey(GlobalConstants.automateSelection)
            removeShakeTutorial()
            m_readyToDance = false
            removeFloatingTiles()
            
            let startSound : NSArray = NSArray(objects: "OnYourMark.mp3","ReadySet.mp3")
            let randomStart = randomSequenceGenerator(0, max: startSound.count-1)
        
        
        let waitReadyTimer : SKAction = SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({self.readyCountTimer()}),SKAction.waitForDuration(1.0)]), count: 4)
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(2),SKAction.group([waitReadyTimer,SKAction.playSoundFileNamed(startSound[randomStart()] as! String, waitForCompletion: true)]),SKAction.runBlock({self.prepareToPlay()})]))
        }
    }
    
    
    func removeFloatingTiles()
    {
        for var i=0;i<m_tiles.count;i++
        {
            let tile : TileSprite = m_tiles[i] as! TileSprite
            if(tile.m_dropzoneIndex<0)
            {
                tile.removeAllActions()
                tile.physicsBody = nil
                tile.runAction(SKAction.sequence([
                    SKAction.waitForDuration(0.05*Double(i)),
                    SKAction.scaleTo(0, duration: 0.05),
                    SKAction.runBlock({tile.removeFromParent()})
                    ]))
            }
        }
    }
    
    
    func readyCountTimer()
    {
        if(readyCountLabel?.text == "0")
    {
        readyCountLabel?.text = "3"
        readyCountLabel?.hidden = false
    }
        else if(readyCountLabel?.text == "3")
    {
        readyCountLabel?.text = "2"
    }
        else if(readyCountLabel?.text == "2")
    {
        readyCountLabel?.text = "1"
    }
        else
    {
        readyCountLabel?.hidden = true
        readyCountLabel?.text = "0"
        }
    }
    
    func timeToTransitionToNextCharacter()
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.motionDelegate = self
        
        
        let spaceship = self.childNodeWithName("spaceship")
        let background = self.childNodeWithName("background") as! SKSpriteNode
        background.runAction(SKAction.group([SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 1.0),SKAction.setTexture(getRandomBackground())]))
        
        
        m_actor.runAction(SKAction.sequence([SKAction.moveTo((spaceship?.position)!, duration: 0.5),SKAction.removeFromParent()]))
        
        self.removeAllActions()
        for sprites in m_dropzoneBodies
        {
            let temp : DropzoneSprite = sprites as! DropzoneSprite
            temp.m_tile?.runAction(SKAction.sequence([SKAction.scaleTo(0, duration: 0.5),SKAction.removeFromParent()]))
            sprites.runAction(SKAction.sequence([SKAction.scaleTo(0, duration: 0.5),SKAction.removeFromParent()]))
        }
        m_dropzoneBodies.removeAllObjects()
        
        for tiles in m_tiles
        {
            tiles.removeFromParent()
        }
        m_tiles.removeAllObjects()
        m_circle.runAction(SKAction.sequence([SKAction.scaleTo(0, duration: 0.5),SKAction.removeFromParent()]))
        
        m_eggReady = false
        m_readyToDance = false
        m_dancePreloadedCount=0
        particleEmmiter.particleBirthRate = 0
        backgroundAudioPlayer.stop()
        
        
        let backgroundSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(String(format: "sound/beats/01_Select/01_%@",backgroundArray[m_currentBackground] as! String), ofType: "mp3")!)
        do{
            backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL:backgroundSound)
            backgroundAudioPlayer.prepareToPlay()
            backgroundAudioPlayer.play()
            backgroundAudioPlayer.numberOfLoops = -1
        }catch {
            print("Error getting the audio file")
        }
        
    }
    
    func prepareToPlay()
    {
        readyCountLabel?.hidden = true
        m_currentSequenceIndex = 0;
        
        let backgroundSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(String(format: "sound/beats/03_Play/03_%@",backgroundArray[m_currentBackground] as! String), ofType: "mp3")!)
        do{
            backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL:backgroundSound)
            backgroundAudioPlayer.prepareToPlay()
            
            backgroundAudioPlayer.numberOfLoops = -1
            backgroundAudioPlayer.volume = 0.8
        }catch {
            print("Error getting the audio file")
        }
        
        m_pace = 0
        m_danceLoopCount = 0
        m_isPlaying = true
        setCurrentParticleEmitter()
        
        backgroundAudioPlayer.play()
        
        self.runAction(SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({self.playNextDance(0)}),SKAction.waitForDuration(2.509)]), count: 12))
        
        
    }
    
    
    func playNextDance(dt : Float)
    {
        
        
        print("current sequence index is ",m_currentSequenceIndex)
        let zone : DropzoneSprite = m_dropzoneBodies[m_currentSequenceIndex] as! DropzoneSprite
        let tile : TileSprite = zone.m_tile!
        //        if(m_danceLoopCount == 0)
        //        {
        //          //  m_actor.m_silenceMode = true;
        //
        //
        self.runAction(SKAction.playSoundFileNamed(String(format: "%@_act_%@.mp3", m_actor.m_name,tile.m_actionName!), waitForCompletion: false))
        //        }
        //        else
        //        {
        //            m_actor.m_silenceMode = false
        //        }
        zone.dropTile(tile)
        m_actor.removeAllActions()
        m_actor.playAction(tile.m_actionName!)
        zone.bounce()
        
        
        m_currentSequenceIndex++;
        if (m_currentSequenceIndex > 3) {
            m_currentSequenceIndex = 0;
            
            m_danceLoopCount++
            let encourageSound : NSArray = NSArray(objects: "Dance.mp3","Groove.mp3","LetsMove.mp3","OhYeah.mp3","ThatsRight.mp3","WereGroovin.mp3","Woo.mp3","Woohoo.mp3","WootWoot.mp3")
            let randomEncourage = randomSequenceGenerator(0, max: encourageSound.count-1)
            
            self.runAction(SKAction.playSoundFileNamed(encourageSound[randomEncourage()] as! String, waitForCompletion: false))
        }
        
        
        print("dance loop count is ",m_danceLoopCount)
        if(m_danceLoopCount == 3)
        {
            
            let endSound : NSArray = NSArray(objects: "Nice.mp3","WayToGo.mp3","Yah.mp3","YouDidIt.mp3","sound/common/Hooray_1.mp3","sound/common/Hooray_2.mp3")
            let endStart = randomSequenceGenerator(0, max: endSound.count-1)
            
            self.runAction(SKAction.sequence(
                [
                    SKAction.waitForDuration(3),
                    SKAction.runBlock({self.m_actor.playAction("exit")}),
                    
                    SKAction.playSoundFileNamed(endSound[endStart()] as! String, waitForCompletion: true),
                    SKAction.waitForDuration(2),
                    SKAction.runBlock({self.removeAllActions(); self.m_actor.removeAllActions(); self.spaceshipFlyInAndTakeAwayEggs()  }),
                ]))
            
        }
        
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
        m_circle = SKSpriteNode(imageNamed: String(format: "tiles-%@/bgCircle",m_actor.m_name))
        m_circle.alpha = 0.2
        m_circle.position = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame)+100)
        m_circle.zPosition = 0
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
        //        m_actor.removeAllActions()
        
        let backgroundSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(String(format: "sound/beats/02_Create/02_%@",backgroundArray[m_currentBackground] as! String), ofType: "mp3")!)
        do{
            backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL:backgroundSound)
            backgroundAudioPlayer.prepareToPlay()
            backgroundAudioPlayer.play()
            backgroundAudioPlayer.numberOfLoops = -1
        }catch {
            print("Error getting the audio file")
        }
        
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(0.5),SKAction.runBlock({self.setupDropZones()})]))
        
        
        
        switch(m_actor.m_name)
        {
        case "leblob":
            m_actor.preloadActions(["dance1","dance2","dance3","dance4","dance5","dance6","dance7"])
            break;
        case "meep":
            m_actor.preloadActions(["dance1","dance2","dance3","dance4","dance5","dance6","dance7","dance8"])

            break;
        case "pom":
            m_actor.preloadActions(["dance1","dance2","dance3","dance4","dance5","dance6","dance7","dance8"])
            break;
        case "guac":
            m_actor.preloadActions(["dance1","dance4","dance5","dance6","dance8"])
            break;
        case "sausalito":
            m_actor.preloadActions(["dance1","dance3","dance4","dance6","dance7"])
            break;
        case "freds":
            m_actor.preloadActions(["dance2","dance4","dance5","dance6","dance7"])

            
            
            break;
        default:
            break;
        }
        
        self.addTutorialforShake()
        
        
        
        
    }
    
    func sizeAndGrow()
    {
        m_actor = self.childNodeWithName(GlobalConstants.currentMONSTER) as! JSONSprite
        m_actor.runAction(SKAction.sequence([
            SKAction.group([SKAction.runBlock({self.m_actor.playAction("moveForward")}),SKAction.moveTo(CGPoint(
                x: CGRectGetMidX(scene!.frame),
                y: CGRectGetMidY(scene!.frame)+100), duration: 1.0),SKAction.scaleTo(1.5, duration: 1.0)]),SKAction.runBlock({self.m_actor.removeAllActions(); self.m_actor.playAction("idle")})]))
        
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
            dropzone.zPosition = 1
            addChild(dropzone)
            
            dropzone.runAction(SKAction.scaleTo(GlobalConstants.dropzoneScale, duration: 1.0))
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
        
        var leftCount : Int = 0
        var rightCount : Int = 0
        
        for temptile in m_tiles
        {
            if temptile.position.x < CGRectGetMidX(scene!.frame)
            {
                leftCount++
            }
            else
            {
                rightCount++
            }
        }
        
        let left : Bool
        if (leftCount == rightCount) {
            left = ((rand() % 10) <= 4);
        } else {
            left = (leftCount < rightCount);
        }
        
        let subbend : Float =  Float(tile.size.width)
        let randomF : Int = random() % Int(Float((scene?.frame.size.height)!) - minTileGenY - subbend)
        
        let frameWidth : Int = Int((scene?.frame.size.height)!) / 2
        let leftTile : Int = 380 + Int(tile.size.width) + 70
        let leftpoint : Int = random() % Int(frameWidth - leftTile)
        
        let tileY : Float
        tileY = minTileGenY + Float(tile.size.height / 2) + Float(randomF) + 90
        
        var p : CGPoint
        
        if(left)
        {
            if (type == TileType.TileTypeColorChange || m_dancePreloadedCount < 8) {
                p = CGPoint(x: Int(tile.size.width/2 + 70) + leftpoint, y: Int(tileY))
                //                print("left 1 %@",p)
            } else {
                p = CGPoint(x: Int(-30 - tile.size.width/2),y: Int(tileY));
                //                print("left 2 %@",p)
            }
        }
        else
        {
            let p1 : Int = 1340 + random() % Int(510 - tile.size.width)
            
            if (type == TileType.TileTypeColorChange || m_dancePreloadedCount < 8) {
                p = CGPoint(x: Int(Int(tile.size.width/2) + p1 ), y: Int(tileY))
                //                print("right 1 %@",p)
            } else {
                p = CGPoint(x: Int(0 + tile.size.width/2),y: Int(tileY));
                //                print("right 2 %@",p)
            }
        }
        
        tile.position = p
        tile.setScale(0)
        tile.zPosition = 2
        tile.physicsBody = tile.attachPhysics()
        self.addChild(tile)
        
        if(m_tiles.count == 3)
        {
            self.runAction(SKAction.sequence([SKAction.waitForDuration(2.0),SKAction.runBlock({self.pickRandomTile()})]))
        }
        
        tile.runAction(SKAction.scaleTo(GlobalConstants.tileScale, duration: 1.0))
        tile.physicsBody?.applyImpulse(CGVectorMake(150.0, -50.0))
        
        m_tiles.addObject(tile)
        
        
        
    }
    
    
    
    func dropzoneIsFull() -> Bool
    {
        var dropCount : Int = 0
        
        for sprite in m_dropzoneBodies
        {
            let dzone: DropzoneSprite = sprite as! DropzoneSprite
            if(dzone.m_tile != nil)
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
    
    
    func appWillResignActive()
    {
//                let introscene : IntroScene = IntroScene(size:CGSize(width: 1920, height: 1080))
//                /* Set the scale mode to scale to fit the window */
//                introscene.scaleMode = .AspectFill
//                view?.presentScene(introscene)
    }
    
    
    // MARK: - Delegate methods
    func actionPreloaded(actionName: String)
    {
        if(actionName.hasPrefix("dance"))
        {
            addActionTile(actionName);
            m_dancePreloadedCount++
        
            if(m_dancePreloadedCount==4)
            {
                m_readyToDance = true
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.motionDelegate = self
            }
        }
    }
    
    func actionStopped(sprite: JSONSprite)
    {
        if(sprite.m_currentActionName == "crackEntrance")
    {
        //            sprite.playAction("idle")
        
        m_eggReady = false
        m_actor.removeAllActions()
        self.getReadyForDanceScene()
        
        }
    }
    
    /// React motion method. Updates on acceleration
    func motionUpdate(motion: GCMotion) {
        
        //        print("x: \(motion.userAcceleration.x)   y: \(motion.userAcceleration.y) z: \(motion.userAcceleration.z)")
        let m = sqrt(pow(motion.userAcceleration.x, 2) + pow(motion.userAcceleration.y,2) + pow(motion.userAcceleration.z,2))
        // print("magnitude",m)
        if(m > 2)
        {
            print("Swing detected")
            if(!dropzoneIsFull() && m_readyToDance)
            {
                 putRandomTilesInDropZone()
            }
            if(m_isPlaying)
            {
                particleEmmiter.particleBirthRate = CGFloat(m*8)
            }
        }
    }
    
    
}
