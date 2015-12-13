//
//  GrownsUpController.swift
//  MonsterMove
//
//  Created by Poojan Jhaveri on 12/11/15.
//
//

import Foundation
import UIKit
import SpriteKit

class GrownsUpController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
      
        
        let scrollView : UIScrollView = UIScrollView()
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, 5000)
        scrollView.backgroundColor = UIColor.blueColor()
        self.view.addSubview(scrollView)
        
        
        let imageView : UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, 5000))
        imageView.image = UIImage.init(named: "grownupscroll")
        scrollView.addSubview(imageView)
        scrollView.panGestureRecognizer.allowedTouchTypes = [1]

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
}

