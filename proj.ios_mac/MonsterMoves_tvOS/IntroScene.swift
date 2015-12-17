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
private var tutorialplayer: AVPlayer!
private var introFrame: SKSpriteNode!
private var playButton: SKSpriteNode!
private var grownUpButton: SKSpriteNode!
private var danceStamp: SKSpriteNode!
private var activateButtonIndex : Int = 0 // 0 for playButton 1 for grownUpButton
private var backgroundAudioPlayer: AVAudioPlayer = AVAudioPlayer();



class IntroScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //nextButtonPressed()
        
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
        
        
        let introSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sound/common/IntroFinalAssetwithextralooping", ofType: "mp3")!)
        do{
            backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL:introSound)
            backgroundAudioPlayer.numberOfLoops = -1
            backgroundAudioPlayer.prepareToPlay()
            backgroundAudioPlayer.play()
        }catch {
            print("Error getting the audio file")
        }

        playButton = SKSpriteNode(imageNamed: "YayButton")
        playButton.position = CGPoint(
            x: CGRectGetMidX(scene!.frame),
            y: CGRectGetMidY(scene!.frame)-200)
        playButton.name = "playButtonNode"
        playButton.hidden = true
        playButton.setScale(0.8)
        playButton.zPosition = 3
        scene?.addChild(playButton)
        playButton.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.scaleTo(1.1, duration: 1.0),
            SKAction.scaleTo(0.8, duration: 1.0)
            ])))
        
        grownUpButton = SKSpriteNode(imageNamed: "grownup")
        grownUpButton.hidden = true
        grownUpButton.position = CGPoint(x: scene!.frame.size.width-250, y: scene!.frame.size.height-100)
        self.addChild(grownUpButton)
        
        
        danceStamp = SKSpriteNode(imageNamed: "DanceStamp")
        danceStamp.position = CGPoint(
            x: CGRectGetMidX(scene!.frame)+35,
            y: CGRectGetMidY(scene!.frame)+90)
        danceStamp.name = "DanceStamp"
        danceStamp.setScale(10)
        danceStamp.hidden = true
        danceStamp.zPosition = 2
        scene?.addChild(danceStamp)
        
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "userSwipedUp")
        swipeUp.direction = .Up
        self.view?.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "userSwipedDown")
        swipeDown.direction = .Down
        self.view?.addGestureRecognizer(swipeDown)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEndedPlaying", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
    }
    
    func videoEndedPlaying(){
        
//        backgroundAudioPlayer.pause()
        danceStamp.runAction(SKAction.sequence([
            
            SKAction.group([SKAction.playSoundFileNamed("dancestamp.mp3", waitForCompletion: false),SKAction.scaleTo(1.7, duration: 0.1),SKAction.unhide()]),
            SKAction.waitForDuration(0.5),
            SKAction.scaleTo(2.0, duration: 0.2),
            SKAction.scaleTo(1.7, duration: 0.2)
            ]))
        playButton.hidden = false
        grownUpButton.hidden = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(object === player && keyPath! == "status")
        {
            if(player!.status == AVPlayerStatus.ReadyToPlay)
            {
                print("Ready to Play")
                video.play()
               // introFrame.hidden=true
            }
            else
            {
                
            }
        }
    }
    
    
    // MARK: Remote Interactions
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
                for press in presses {
                    switch press.type {
                    case .UpArrow:
                        userSwipedUp()
                    case .DownArrow:
                        userSwipedDown()
                    case .LeftArrow:
                        print("Left arrow")
                    case .RightArrow:
                        print("Right arrow")
                    case .Select:
                        buttonPressed()
                    case .Menu:
                        print("Menu")
                    case .PlayPause:
                        print("Play/Pause")
                    }
                }
    }
    
    func userSwipedUp()
    {
        playButton.removeAllActions()
        activateButtonIndex = 1
        grownUpButton.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.scaleTo(1.3, duration: 1.0),
            SKAction.scaleTo(1.0, duration: 1.0)
            ])))
    }
    
    func userSwipedDown()
    {
        
        print("User Swiped Down")
        grownUpButton.removeAllActions()
        activateButtonIndex = 0
        playButton.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.scaleTo(1.1, duration: 1.0),
            SKAction.scaleTo(0.8, duration: 1.0)
            ])))

    }
    
    // MARK: Button Interaction Methods
    func buttonPressed(){
        print("button pressed")
        switch(activateButtonIndex)
        {
        case 0:
            playButtonPressed()
            break
        case 1:
            grownUpButtonPressed()
            break
        default:
            playButtonPressed()
            break
        }
    }
    
    /// Play Button pressed - Start the Game
    func playButtonPressed()
    {
                self.runAction(SKAction.stop())
        
                if(backgroundAudioPlayer.playing)
                {
                    backgroundAudioPlayer.stop()
                }
        
                // Transition to Main game - Spaceship scene
                let spaceShipScene = SpaceshipScene(size: size)
                spaceShipScene.scaleMode = scaleMode
        
                let reveal = SKTransition.crossFadeWithDuration(0.5) // Transition with CrossFade - to avoid huge pixel change
                view?.presentScene(spaceShipScene, transition: reveal)
    }
    
    /// GrownUp Button pressed - Show Grownup Section
    func grownUpButtonPressed()
    {
        if(backgroundAudioPlayer.playing)
        {
            backgroundAudioPlayer.pause()
        }
        // Transition to GrownUp Section
        let grownup :GrownsUpController = GrownsUpController()
        
        let rootVC : UIViewController = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        rootVC.presentViewController(grownup, animated: true, completion: nil)
    }
    
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        player.removeObserver(self, forKeyPath: "status")
    }
    
    
    override func willMoveFromView(view: SKView) {
        if view.gestureRecognizers != nil {
            for gesture in view.gestureRecognizers! {
                if let recognizer = gesture as? UISwipeGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }

    
}
