//
//  JSONSprite.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/30/15.
//  Copyright © 2015 IDEO. All rights reserved.
//

import Foundation
import SpriteKit




struct ActionData
{
    var actionaName: String
    var realName: String
    var filePrefix: String
    var frameStart: Int
    var frameEnd: Int
    var frameRate: Float
    var repeatagain: Int
    var type: Int
    var soundEffect: String
    var followedAction: String
}

class JSONSprite: SKSpriteNode {
    
    private var TILE_INNER_ACTOR_TAG : NSString = "9527"
    
    private var introFrame: SKSpriteNode!
    
    internal
        var m_delegate: JSONSpriteDelegate?
        var m_name: String = ""
        var m_selectedEffect : String = ""
        var m_currentActionName : String = ""
        var m_backgroundSound : String = ""
        var m_touchArea : CGRect = CGRectZero
        var m_touchArea2 : CGRect = CGRectZero
        var m_feetOffset : Float = 0
    
        var m_backgroundColor : UIColor = UIColor.blackColor()
        var m_circleColor : CGColorRef = UIColor.blackColor().CGColor

    
    
    var m_tileColor: CGColorRef = UIColor.blackColor().CGColor;
    
    var m_starColor:CGColorRef = UIColor.blackColor().CGColor;
    
    var m_hue: Float = 0;
    
    
    var m_actions = Dictionary<String,ActionData>()
    var m_actorHolders = Dictionary<String,SKSpriteNode>()
    
    var m_currentActorHolder = SKSpriteNode()
    var m_nextActionHolder = SKSpriteNode()
    
    var m_pixelFormat: SKTexture = SKTexture();
    
    var m_silenceMode: Bool = false;
    
    var m_cancelLoading: Bool = false;
    
    var m_soundId: Int = 0;
    
    var m_lastPlayTime: Double = 0;
    
    var m_preloadActions: NSMutableArray = NSMutableArray()
    
    var m_stopped : Bool = false;
    
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    

    internal convenience init(fileNamed name: String)
    {
        self.init()
        self.initWithConfigFile(name)
    }
    
    
    internal convenience init(fileNamed name:String,defaultAction:String)
    {
        self.init()
        self.initWithConfigFile(name, defaultAction: defaultAction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initWithConfigFile(fileName: String) -> Bool
    {
        return initWithConfigFile(fileName, defaultAction: "")
    }
    
    func initWithConfigFile(fileName: String,defaultAction: String) -> Bool{
        
            m_lastPlayTime = 0
            m_hue = 0
            m_silenceMode = false
        
            do {
                let data = try NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(fileName, ofType: "json")!, options: .DataReadingMappedIfSafe)
                let parsedDoc = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                m_name = parsedDoc["name"] as! String
                print(m_name)
                
                let basePath = "actors/" + m_name + "/"
                var loadAction = defaultAction
                if(loadAction.isEmpty && parsedDoc["defaultAction"] != nil)
                {
                    loadAction = parsedDoc["defaultAction"] as! String
                }
                
                
                if (parsedDoc["backgroundSound"] != nil)
                {
                    m_backgroundSound = parsedDoc["backgroundSound"] as! String
                }
                
                if (parsedDoc["selectedEffect"] != nil)
                {
                    m_selectedEffect = parsedDoc["selectedEffect"] as! String
                }
                
//                if (parsedDoc["backgroundColor"] != nil)
//                {
//                    let backgroundColor = parsedDoc["backgroundColor"];
//                    m_backgroundColor = UIColor(red: backgroundColor["r"], green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
//                    
//                    m_backgroundColor.r = backgroundColor["r"].GetInt();
//                    m_backgroundColor.g = backgroundColor["g"].GetInt();
//                    m_backgroundColor.b = backgroundColor["b"].GetInt();
//                    m_backgroundColor.a = backgroundColor["a"].GetInt();
//                }
                
//                if (doc.HasMember("circleColor"))
//                {
//                    rapidjson::Value &color = doc["circleColor"];
//                    m_circleColor.r = color["r"].GetInt();
//                    m_circleColor.g = color["g"].GetInt();
//                    m_circleColor.b = color["b"].GetInt();
//                    m_circleColor.a = color["a"].GetInt();
//                }
//                
//                if (doc.HasMember("tileColor"))
//                {
//                    rapidjson::Value &color = doc["tileColor"];
//                    m_tileColor.r = color["r"].GetInt();
//                    m_tileColor.g = color["g"].GetInt();
//                    m_tileColor.b = color["b"].GetInt();
//                    m_tileColor.a = color["a"].GetInt();
//                }
//                
//                if (doc.HasMember("starColor"))
//                {
//                    rapidjson::Value &color = doc["starColor"];
//                    m_starColor.r = color["r"].GetInt();
//                    m_starColor.g = color["g"].GetInt();
//                    m_starColor.b = color["b"].GetInt();
//                    m_starColor.a = color["a"].GetInt();
//                }
                
                
                if(parsedDoc["feetOffset"] != nil)
                {
                    m_feetOffset = parsedDoc["feetOffset"] as! Float
                }
                else
                
                {
                    m_feetOffset = 0
                }
                
                if(parsedDoc["actions"] != nil)
                {
                    var actionDocArray : NSArray = parsedDoc["actions"] as! NSArray
                    for var j=0; j < actionDocArray.count; j++
                    {
                        var actionDoc = actionDocArray[j] as! NSDictionary
                        var ad: ActionData = ActionData(actionaName: "", realName: "", filePrefix: "" , frameStart: 0, frameEnd: 0, frameRate: 0, repeatagain: 0, type: 0, soundEffect: "", followedAction: "")
                        ad.actionaName = actionDoc["name"] as! String
                        
                        
                        if(actionDoc["realName"] != nil)
                        {
                            ad.realName = actionDoc["realName"] as! String
                        }
                        else
                        {
                            ad.realName = ad.actionaName
                        }
                        
                        if(actionDoc["filePrefix"] != nil)
                        {
                            ad.filePrefix = actionDoc["filePrefix"] as! String
                        }
                        else
                        {
                            ad.filePrefix = m_name
                        }
                        
                        
                        ad.frameStart = actionDoc["frameStart"] as! Int
                        ad.frameEnd = actionDoc["frameEnd"] as! Int
                        ad.repeatagain = actionDoc["repeat"] as! Int
                        
                        if(actionDoc["frameRate"] != nil)
                        {
                            ad.frameRate = actionDoc["framerate"] as! Float
                        }
                        else
                        {
                            ad.frameRate = 20
                        }
                        
                        if(actionDoc["soundEffect"] != nil)
                        {
                            ad.soundEffect = actionDoc["soundEffect"] as! String
                            SKAction.playSoundFileNamed(ad.soundEffect, waitForCompletion: false)
                        }
                        
                        if(actionDoc["type"] != nil)
                        {
                            ad.type = actionDoc["type"] as! Int
                        }
                        else
                        {
                            ad.type = 0
                        }
                        
                        if(actionDoc["followedAction"] != nil)
                        {
                            ad.followedAction = actionDoc["followedAction"] as! String
                        }
                    
                        
                        
                        m_actions[ad.actionaName] = ad
                        if(ad.actionaName == loadAction)
                        {
                            m_currentActorHolder = addBatchNode(m_name, actionName: loadAction, start: ad.frameStart, end: ad.frameEnd)
                            m_actorHolders[loadAction]?.hidden = false
                        }
                    }
                }
                
                
            }
            catch {
                print("error serializing JSON: \(error)")
            }
            
            
            return true
        }
    
    
    func playAction(actionName : String)
    {
        playActionWithDirection(actionName,reverse: false)
    }
    
    func playActionReverse(actionName : String)
    {
        playActionWithDirection(actionName,reverse: true)
    }
    
    func playActionWithDirection(actionName : String, reverse : Bool)
    {
        var action: ActionData = m_actions[actionName]!
        m_nextActionHolder = m_actorHolders[actionName]!
        
        if(m_actorHolders[actionName] == nil)
        {
            m_nextActionHolder = addBatchNode(m_name,actionName: actionName,start: action.frameStart,end: action.frameEnd)
      
        }
        else
        {
//            let textureFile = String(format: "images/iPhone/actors/%@/%@.png",m_name,actionName )
//            var texture : SKTexture = SKTexture(imageNamed: textureFile)
        }
        
        var currentInnerActor : SKSpriteNode
        currentInnerActor = (m_currentActorHolder.childNodeWithName(TILE_INNER_ACTOR_TAG as String)) as! SKSpriteNode
        
        if((currentInnerActor.parent) != nil)
        {
            currentInnerActor.removeAllActions()
        }
        
        
        var innerActor : SKSpriteNode = m_nextActionHolder.childNodeWithName(TILE_INNER_ACTOR_TAG as String) as! SKSpriteNode
        
        var filename : String
        
        filename = String(format: "%@%04d.png",m_name,action.frameStart)
        
        if((innerActor.parent) != nil)
        {
            innerActor.removeAllActions()
            innerActor.texture = SKTexture(imageNamed: filename)
        }
        else
        {
            innerActor = SKSpriteNode(imageNamed: filename)
            innerActor.blendMode = .Alpha
            innerActor.position = CGPointZero
            innerActor.name = TILE_INNER_ACTOR_TAG as String
        }
        
        if(m_currentActorHolder != m_nextActionHolder)
        {
            m_currentActorHolder.zPosition = 0
            m_nextActionHolder.zPosition = 1
            m_nextActionHolder.hidden = false
            m_currentActorHolder.hidden = true
            m_currentActorHolder = m_nextActionHolder
            currentInnerActor.removeFromParent()
        }
        
        m_currentActionName = actionName
        var spriteFrames : NSMutableArray = NSMutableArray()
        if(reverse)
        {
            for var i=action.frameEnd; i>=action.frameStart; i--
            {
                filename = String(format: "%@%04d",m_name,i)
                let texture : SKTexture = SKTexture(imageNamed: filename)
                spriteFrames.addObject(texture)
            }
        }
        else
        {
            for var i=action.frameStart; i<=action.frameEnd; i++
            {
                filename = String(format: "%@%04d",m_name,i)
                let texture : SKTexture = SKTexture(imageNamed: filename)
                spriteFrames.addObject(texture)
            }
        }
        

        
        let animation = SKAction.animateWithTextures(spriteFrames as NSArray as! [SKTexture], timePerFrame: 1/15)
        
        
        if(action.repeatagain <= 0)
        {
            innerActor.runAction(SKAction.repeatActionForever(animation))
        }
        else if(action.repeatagain == 1)
        {
            innerActor.runAction(SKAction.sequence([animation,SKAction.runBlock({self.actionStopped()})]))
        }
        else
        {
            innerActor.runAction(SKAction.repeatAction(animation, count: action.repeatagain))
        }
        
        
        
        if(!m_silenceMode && !action.soundEffect.isEmpty)
        {
            if(m_soundId == 1)
            {
                SKAction.stop()
            }
            self.runAction(SKAction.playSoundFileNamed(action.soundEffect, waitForCompletion: false))
            m_soundId = 1
        }
    }
    
    
    func actionStopped()
    {
        let ad : ActionData = m_actions[m_currentActionName]!
        if(!ad.followedAction.isEmpty)
        {
            self.playAction(ad.followedAction)
        }
        
        if((m_delegate) != nil)
        {
            if(!m_stopped)
            {
                m_delegate?.actionStopped(self)
            }
        }
    }
    
    func preloadActions(actions : NSArray)
    {
        m_preloadActions.removeAllObjects()
        m_preloadActions = NSMutableArray(array: actions)
        for var i=0; i < m_preloadActions.count; i++
        {
            var actionName = m_preloadActions[i] as! NSString
            let n = String(format: "actors/%@/%@.png", m_name,actionName)
            self.imageLoaded(SKTexture(imageNamed: n))
        }
    }
    
    func imageLoaded(texture: SKTexture)
    {
        if(m_cancelLoading)
        {
            return;

        }
        for var i=0; i < m_preloadActions.count; i++
        {
            let actionName : String = m_preloadActions[i] as! String
            var actorHolder : SKSpriteNode
            if(m_actorHolders[actionName] == nil)
            {
                let ad : ActionData = m_actions[actionName]!
                self.addBatchNode(m_name, actionName: actionName, start: ad.frameStart, end: ad.frameEnd)
                if(m_delegate != nil)
                {
                    m_delegate!.actionPreloaded(actionName)
                }
            }
            else
            {
                 actorHolder = m_actorHolders[actionName]!
            }
        }
        
    }
    
    func addBatchNode(actorName : String,actionName : String,start: Int, end: Int)-> SKSpriteNode
    {
        let fileName : String = String(format: "actors/%@/%@.png",actorName,actionName)
        let texture : SKTexture = SKTexture(imageNamed: fileName)
        let image : String = String(format: "%@%04d.png",actorName,start)
        
        var actorHolder : SKSpriteNode
      //  actorHolder = SKSpriteNode(texture: texture)
        actorHolder = SKSpriteNode()
      
        let actor : SKSpriteNode = SKSpriteNode(imageNamed: image)
        actor.position = CGPoint(x: 0, y: 0)
        actor.name = TILE_INNER_ACTOR_TAG as String
        
        actorHolder.addChild(actor)
        actorHolder.hidden=true
        actorHolder.position = CGPoint(x: 0, y: 0)
        
        addChild(actorHolder)
        
        m_actorHolders[actionName] = actorHolder
        return actorHolder
    }
    
    
    
    
}

protocol JSONSpriteDelegate
{
    func actionStopped(sprite: JSONSprite)
    
    func actionPreloaded(actionName : String)
    
}

