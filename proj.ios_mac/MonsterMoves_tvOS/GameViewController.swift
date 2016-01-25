//
//  GameViewController.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright (c) 2015 IDEO. All rights reserved.
//

import UIKit
import SpriteKit
import GameController

class GameViewController: GCEventViewController {
    
    private var introscene : IntroScene?
    internal var m_isHomeScreen : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "transitionedToView:", name: GlobalConstants.transitionNotification, object: nil)
        
        introscene = IntroScene(size:CGSize(width: 1920, height: 1080))
        introscene?.name = "Home"
        // Configure the view.
        let skView = self.view as! SKView
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        introscene!.scaleMode = .AspectFill

        controllerUserInteractionEnabled = true
        
        skView.presentScene(introscene)
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func transitionedToView(notification : NSNotification)
    {
        
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            // Check if value present before using it
            if let scene = info["scenename"] {
                print(scene)
                if(scene as! String == "Spaceship")
                                {
                                    m_isHomeScreen = false
                                    print("Spaceship scene. Controller user interaction enabled - false")
                                    controllerUserInteractionEnabled = false
                                }
                                else if(scene as! String == "Intro")
                                {
                                    m_isHomeScreen = true
                                    print("Intro scene. Controller user interaction enabled - true")
                                    controllerUserInteractionEnabled = true
                                }
                                else if(scene as! String == "Grownup")
                {
                    let grownup :GrownsUpController = GrownsUpController()
                  //  self.navigationController?.pushViewController(grownup, animated: true)
                    self.presentViewController(grownup, animated: true, completion: nil)
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
                }
                break;
            default:
                introscene!.pressesEnded(presses, withEvent: event)
            }
        }
    }
    
    
    
}
