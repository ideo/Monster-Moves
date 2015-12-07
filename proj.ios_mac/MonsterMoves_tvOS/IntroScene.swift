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
private var backgroundAudioPlayer: AVAudioPlayer = AVAudioPlayer();



class IntroScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
      //  nextButtonPressed()
        
        let center = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame))
        
        
        let fileUrl = NSBundle.mainBundle().URLForResource("IntroMovie",
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
        
        
        let coinSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sound/common/IntroFinalAssetwithextralooping", ofType: "mp3")!)
        do{
            backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL:coinSound)
            backgroundAudioPlayer.prepareToPlay()
            backgroundAudioPlayer.play()
        }catch {
            print("Error getting the audio file")
        }
        
        
        
        
//        let introsound = SKAction.playSoundFileNamed(, waitForCompletion: false);
//        self.runAction(introsound);
        
        playButton = SKSpriteNode(imageNamed: "YayButton")
        playButton.position = center
        playButton.name = "playButtonNode"
        playButton.hidden = true
        playButton.zPosition = 2
        scene?.addChild(playButton)
        playButton.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.scaleTo(1.5, duration: 2.0),
            SKAction.scaleTo(1.0, duration: 2.0)
            
            ])))
        
        
        let tapgesture = UITapGestureRecognizer(target: self, action: "nextButtonPressed")
        tapgesture.allowedPressTypes = [NSNumber (integer: UIPressType.Select.rawValue)]
        self.view?.addGestureRecognizer(tapgesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEndedPlaying", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
       // nextButtonPressed()
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
        
        self.runAction(SKAction.stop())
        backgroundAudioPlayer.stop()
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
