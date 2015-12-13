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
private var grownsUpButton: SKSpriteNode!
private var danceStamp: SKSpriteNode!
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
            backgroundAudioPlayer.numberOfLoops = -1
            backgroundAudioPlayer.prepareToPlay()
            backgroundAudioPlayer.play()
        }catch {
            print("Error getting the audio file")
        }
        
        
        
        
//        let introsound = SKAction.playSoundFileNamed(, waitForCompletion: false);
//        self.runAction(introsound);
        
        playButton = SKSpriteNode(imageNamed: "YayButton")
        playButton.position = CGPoint(
            x: CGRectGetMidX(scene!.frame)+400,
            y: CGRectGetMidY(scene!.frame))
        playButton.name = "playButtonNode"
        playButton.hidden = true
        playButton.setScale(0.8)
        playButton.zPosition = 3
        scene?.addChild(playButton)
        playButton.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.scaleTo(1.1, duration: 1.5),
            SKAction.scaleTo(0.8, duration: 1.5)
            
            ])))
        
        
        grownsUpButton = SKSpriteNode(imageNamed: "grownup")
        grownsUpButton.hidden = true
        grownsUpButton.position = CGPoint(x: scene!.frame.size.width-250, y: scene!.frame.size.height-100)
        self.addChild(grownsUpButton)
        
        
        danceStamp = SKSpriteNode(imageNamed: "DanceStamp")
        danceStamp.position = center
        danceStamp.name = "DanceStamp"
        danceStamp.setScale(10)
        danceStamp.hidden = true
        danceStamp.zPosition = 2
        scene?.addChild(danceStamp)
        
        
        
        
        
        let tapgesture = UITapGestureRecognizer(target: self, action: "nextButtonPressed")
        tapgesture.allowedPressTypes = [NSNumber (integer: UIPressType.Select.rawValue)]
        self.view?.addGestureRecognizer(tapgesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEndedPlaying", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
       // nextButtonPressed()
    }
    
    func videoEndedPlaying(){
        
       backgroundAudioPlayer.pause()
        
     //   self.runAction(SKAction.playSoundFileNamed("stamp.mp3", waitForCompletion: false))
        danceStamp.runAction(SKAction.group([SKAction.scaleTo(1.0, duration: 0.1),SKAction.unhide()]))
        playButton.hidden = false
        grownsUpButton.hidden = false
        
        
        
        
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
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        
        
        
        for press in presses {
            switch press.type {
            case .UpArrow:
                print("Up Arrow")
            case .DownArrow:
                print("Down arrow")
            case .LeftArrow:
                print("Left arrow")
            case .RightArrow:
                print("Right arrow")
            case .Select:
                print("Select")
            case .Menu:
                print("Menu")
            case .PlayPause:
                print("Play/Pause")
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
    
    
    func grownUpButtonPressed()
    {
        let grownup :GrownsUpController = GrownsUpController()
        
        let rootVC : UIViewController = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        rootVC.presentViewController(grownup, animated: true, completion: nil)
    }
    
    
    
    deinit {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            player.removeObserver(self, forKeyPath: "status")
    }
    
    
    
    
}
