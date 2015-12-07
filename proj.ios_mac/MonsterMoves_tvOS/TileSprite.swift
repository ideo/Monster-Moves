//
//  TileSprite.swift
//  MonsterMove
//
//  Created by Poojan Jhaveri on 12/7/15.
//
//

import Foundation
import SpriteKit

enum TileType {
    case TileTypeNormal
    case TileTypeColorChange
}

enum TileMode {
    case TileModeNormal
    case TileModeEnter
    case TileModeLeaving
    case TileModeReenter
}



class TileSprite: SKSpriteNode {
    
    internal
        var m_actionName : String?
        var m_delegate : TileSpriteDelegate?
        var m_dropzoneIndex : Int = -1
        var m_type : TileType?
        var m_dropping : Bool = false
        var m_world : SKPhysicsWorld?
        var m_mode : TileMode?
    
    
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    
    internal convenience init(fileNamed name: String)
    {
        self.init()
        self.initWithConfigFile(name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initWithConfigFile(fileName: String) -> Bool{
        return true
    }

    
    
    
}

protocol TileSpriteDelegate
{
    func tilePressed(tile : TileSprite)
}



