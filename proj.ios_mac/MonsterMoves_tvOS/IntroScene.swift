//
//  GameScene.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright (c) 2015 IDEO. All rights reserved.
//

import SpriteKit
import AVFoundation

private var video: SKVideoNode!
private var player: AVPlayer!
private var introFrame: SKSpriteNode!
private var playButton: SKSpriteNode!



class IntroScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
      //  nextButtonPressed()
        
        let center = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame))
        
        
        let fileUrl = NSBundle.mainBundle().URLForResource("splash16x9",
            withExtension: "mp4")!
        player = AVPlayer(URL: fileUrl)
        video = SKVideoNode(AVPlayer: player)
        video.size = scene!.size
        video.position = center
        video.zPosition = 0
        scene!.addChild(video)
        player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        
        introFrame = SKSpriteNode(imageNamed: "Intro")
        introFrame.position = center
        introFrame.zPosition = -1
        scene?.addChild(introFrame)
        
        
        let introsound = SKAction.playSoundFileNamed("sound/common/IntroFinalAssetwithextralooping.mp3", waitForCompletion: false);
        self.runAction(introsound);
        
        playButton = SKSpriteNode(imageNamed: "YayButton")
        playButton.position = center
        playButton.name = "playButtonNode"
        playButton.hidden = true
        playButton.zPosition = 2
        scene?.addChild(playButton)
        
        
        let tapgesture = UITapGestureRecognizer(target: self, action: "nextButtonPressed")
        tapgesture.allowedPressTypes = [NSNumber (integer: UIPressType.Select.rawValue)]
        self.view?.addGestureRecognizer(tapgesture)
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEndedPlaying", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
        
        
    }
    
    func videoEndedPlaying(){
        
        playButton.hidden = false
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(object === player && keyPath! == "status")
        {
            if(player!.status == AVPlayerStatus.ReadyToPlay)
            {
                print("Ready to Play")
                video.play()
                introFrame.hidden=true
            }
            else
            {

            }
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
       // nextButtonPressed()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func nextButtonPressed(){
        print("touched Button Pressed")
        let spaceShipScene = SpaceshipScene(size: size)
        spaceShipScene.scaleMode = scaleMode
        // 2
        let reveal = SKTransition.crossFadeWithDuration(0.5)       // 3
        view?.presentScene(spaceShipScene, transition: reveal)
    }
    
    deinit {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            player.removeObserver(self, forKeyPath: "status")
    }
    
}
