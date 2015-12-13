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

    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        introscene?.pressesEnded(presses, withEvent: event)
    }
    
    
    
    
}
