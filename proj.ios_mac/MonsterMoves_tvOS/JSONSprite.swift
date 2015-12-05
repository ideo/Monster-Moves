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
    var m_actorHolders = Dictionary<String,SKTextureAtlas>()
    
    var m_currentActorHolder = SKTextureAtlas()
    var m_nextActionHolder = SKTextureAtlas()
    
//    std::unordered_map<std::string, ActionData> m_actions;
//    
//    std::unordered_map<std::string, SpriteBatchNode*> m_actorHolders;
//    
//    SpriteBatchNode* m_currentActorHolder;
//    
//    SpriteBatchNode* m_nextActionHolder;
    
    var m_pixelFormat: SKTexture = SKTexture();
    
    var m_silenceMode: Bool = false;
    
    var m_cancelLoading: Bool = false;
    
    var m_soundId: Int = 0;
    
    var m_lastPlayTime: Double = 0;
    
    var m_preloadActions: NSMutableArray = NSMutableArray()
    
    
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
//       
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
                        
                        
                        
                        
                        m_actions[ad.actionaName] = ad
                        if(ad.actionaName == loadAction)
                        {
                            m_currentActorHolder = addBatchNode(m_name, actionName: loadAction, start: ad.frameStart, end: ad.frameEnd)
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
        
        
//        m_nextActionHolder = addBatchNode(m_name, actionName, action.frameStart, action.frameEnd);

        
        
        
        
    }
    
    func preloadActions(actions : NSArray)
    {
        m_preloadActions.removeAllObjects()
        m_preloadActions = NSMutableArray(array: actions)
        for var i=0; i < m_preloadActions.count; i++
        {
            var actionName = m_preloadActions[i] as! NSString
            let n = String(format: "actors/%@/%@.png", m_name,actionName)
           // self.imageLoaded(SKTexture(imageNamed: n))
            SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named: "LeBlobeggIdle")], withCompletionHandler: {})
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
            
            var actorHolder : SKTextureAtlas
            actorHolder = m_actorHolders[actionName]!
            let n = String(format: "actors/%@/%@.png", m_name,actionName)
            
            let ad : ActionData = m_actions[actionName]!
            self.addBatchNode(m_name, actionName: actionName, start: ad.frameStart, end: ad.frameEnd)
            if(m_delegate != nil)
            {
                m_delegate!.actionPreloaded(actionName)
            }
            
        }
        
    }
    
    func addBatchNode(actorName : String,actionName : String,start: Int, end: Int)-> SKTextureAtlas
    {
        var fileName : String = String(format: "actors/%@/%@.png",actorName,actionName)

        var texture : SKTexture = SKTexture(imageNamed: fileName)
        
        
      //  var image : String = String(format: "%s%04d.png",actorName,start)
        
        var image : String = String(format: "leblob0000",actorName,start)
        
        var actorHolder = SKTextureAtlas(named: "LeBlobeggIdle")
        
      
        var actor : SKSpriteNode = SKSpriteNode(imageNamed: image)
        actor.position = CGPoint(x: 0, y: 0)
        actor.name = "tiletag"
        
        m_actorHolders[actionName] = actorHolder
        
        return actorHolder
    }
    
    
    
    
}

protocol JSONSpriteDelegate
{
    func actionStopped(sprite: JSONSprite)
    
    func actionPreloaded(actionName : String)
    
}

