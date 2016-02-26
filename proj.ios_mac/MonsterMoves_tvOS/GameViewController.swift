//
//  GameViewController.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright (c) 2015 IDEO. All rights reserved.
//
// This is the main controller. Entry point for the game.

import UIKit
import SpriteKit
import GameController

class GameViewController: GCEventViewController {
    
    private var introscene : IntroScene?
    internal var m_isHomeScreen : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To keep track of navigation around the game.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "transitionedToView:", name: GlobalConstants.transitionNotification, object: nil)
        self.view.backgroundColor = UIColor.whiteColor()
        
        let splashImageView : UIImageView = UIImageView(image: UIImage(named: "LaunchImage"))
        splashImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.view.addSubview(splashImageView)
        splashImageView.backgroundColor = UIColor.clearColor()
        
        UIView.animateWithDuration(0.5, delay: 0.1, options: [], animations: { () -> Void in
            
            splashImageView.alpha = 0;
            
            
            }) { (finished) -> Void in
                if(finished)
                {
                    self.introscene = IntroScene(size:CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))
                    self.introscene?.name = "Home"
                    
                    // Configure the view.
                    let skView = self.view as! SKView
                    
                    /* Sprite Kit applies additional optimizations to improve rendering performance */
                    skView.ignoresSiblingOrder = true
                    
                    /* Set the scale mode to scale to fit the window */
                    self.introscene!.scaleMode = .AspectFill
                      skView.presentScene(self.introscene)
                    
                    splashImageView.removeFromSuperview()
                }
        }
        controllerUserInteractionEnabled = true
    }

    
    /**
     It keeps track of what scene the game is currently on.
      
     This method is triggered through notification when different scenes/controllers are presented.
      
     :param: notification NSNotification containing scenename and scene

     */
    func transitionedToView(notification : NSNotification)
    {
        
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            // Check if value present before using it
            if let scenename = info["scenename"] {
                print(scenename)
                if(scenename as! String == "Spaceship")
                                {
                                    m_isHomeScreen = false
                                    print("Spaceship scene. Controller user interaction enabled - false")
                                    controllerUserInteractionEnabled = false
                                }
                                else if(scenename as! String == "Intro")
                                {
                                    m_isHomeScreen = true
                                    print("Intro scene. Controller user interaction enabled - true")
                                    controllerUserInteractionEnabled = true
                                }
                                else if(scenename as! String == "Grownup")
                {
                    let grownup :GrownsUpController = GrownsUpController()
                    self.presentViewController(grownup, animated: true, completion: nil)
                    Flurry.logEvent("In GrownUp Section")
                }
            }
            else {
                print("no value for key\n")
            }
        }
        else {
            print("wrong userInfo type")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    deinit {
        // perform the deinitialization
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for press in presses {
            switch press.type {
            case .Menu:
                if(!m_isHomeScreen)
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("needToGoToHome", object: nil)
                }else
                {
                    super.pressesEnded(presses, withEvent: event)
                }
                break;
                
            default:
                introscene!.pressesEnded(presses, withEvent: event)
            }
        }
    }
    
    
    
}
