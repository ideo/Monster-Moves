//
//  DropzoneSprite.swift
//  MonsterMove
//
//  Created by Poojan Jhaveri on 12/7/15.
//
//

import Foundation
import SpriteKit

extension CGPoint {
    
    /**
     Calculates a distance to the given point.
     
     :param: point - the point to calculate a distance to
     
     :returns: distance between current and the given points
     */
    func distance(point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy);
    }
}


class DropzoneSprite: SKSpriteNode {
    
    internal
    var m_tile : TileSprite?
    var m_index : Int?
    var m_circle : SKSpriteNode?
    var m_tileColor : UIColor?
    
    private var m_frameTime : Float = 1/15
    private var m_totalDanceTime : Double = 1.9 // Derived from m_frameTime * 50 - 0.6
    private var scaleAdjust : Float = 1.0
    
    internal func dropTile(tile : TileSprite)
    {
        if(m_tile != nil)
        {
            if(m_tile != tile)
            {
                self.removeCurrentTile()
            }
        }
        m_tile = tile
        tile.m_dropzoneIndex = m_index!
        //warning : DropTime Error
        var dropTime : Float = Float((m_tile?.position.distance(self.position))!)/2000.0
        
        if(dropTime < 0.1)
        {
            dropTime = 0.1
        }
        
        m_tile?.m_dropping = true
        tile.runAction(SKAction.sequence(
            [
            SKAction.moveTo(self.position, duration: Double(dropTime)),
            SKAction.runBlock({self.showCircle("leblob")})
            ]))
    }
    
    
    internal func bounce()
    {
        removeAllActions()
        self.runAction(SKAction.sequence([
            SKAction.scaleTo(1.2, duration:m_totalDanceTime/6.0),
            SKAction.waitForDuration(m_totalDanceTime/6.0*7.0),
            SKAction.scaleTo(1.0, duration: Double(m_totalDanceTime)/6.0)
            
            ]))
      //  m_tile?.runAction(SKAction.rotateByAngle(360, duration: m_totalDanceTime/2.0))
    }
    
    
    
    func removeCurrentTile()
    {
//        if(m_tile == nil){ return }
//        let dx : Double = Double(200 - random() % 400)
//        let dy : Double = Double(300 - random() % 50)
//        m_tile?.runAction(SKAction.sequence(
//            [
//                SKAction.group([
//                    SKAction.moveBy(CGVector(dx: dx, dy: dy), duration: 0.5),
//                    SKAction.scaleTo(0.0, duration: 0.5)
//                    ]),
//                SKAction.runBlock({self.m_tile?.removeFromParent()})
//            ]))
//        m_tile = nil
    }
    
    
    func removeCircle()
    {
        if(m_circle != nil)
        {
            m_circle?.removeAllActions()
            m_circle?.removeFromParent()
            m_circle = nil
        }
    }
    
    func showCircle(actorName : String)
    {
        if(m_circle == nil)
        {
            m_circle = SKSpriteNode(imageNamed: String(format: "tiles-%@/tileCircle",actorName))
            m_circle?.alpha = 0
            self.addChild(m_circle!)
            m_circle?.runAction(SKAction.fadeInWithDuration(0.1))
        }
    }
    
    
    
    
    
    
}