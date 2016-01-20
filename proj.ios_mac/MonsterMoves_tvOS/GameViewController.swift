//
//  GameViewController.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright (c) 2015 IDEO. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    private var introscene : IntroScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        introscene = IntroScene(size:CGSize(width: 1920, height: 1080))
        introscene?.name = "Home"
        // Configure the view.
        let skView = self.view as! SKView
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        introscene!.scaleMode = .AspectFill
        
        skView.presentScene(introscene)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
//    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
//        // Detect a remote button press
//        
//        if presses.first?.type == .Menu { // Detect the menu button
//            print("Menu button pressed")
//        }
//        else { // Pass it to 'super' to allow it to do what it's supposed to do if it's not a menu press
//            super.pressesBegan(presses, withEvent: event)
//        }
//    }

    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
//        for press in presses {
//            switch press.type {
//            case .Menu:
//                if("hi"==="hi")
//                {
//                    //intro
//                    super.pressesEnded(presses, withEvent: event)
//                }
//                else
//                {
//                    let gameScene = SpaceshipScene(size:CGSize(width: 1920, height: 1080))
//                    let skView = self.view as! SKView
//                    skView.presentScene(gameScene)
//                    //play
//                }
//                print("Menu pressed")
//                break;
//            default:
                 introscene?.pressesEnded(presses, withEvent: event)
//            }
//        }
       
    }
    
    
    
    
}
