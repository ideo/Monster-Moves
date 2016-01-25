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

import GameController

class GrownsUpController: UIViewController{
    
    var scrollView : UIScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
      
        
        
        scrollView.frame = view.bounds
        scrollView.backgroundColor = UIColor.blueColor()
        scrollView.panGestureRecognizer.allowedTouchTypes = [0,1]
        self.view.addSubview(scrollView)
        
        
        let imageView : UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, 5000))
        imageView.image = UIImage.init(named: "grownupscroll")
        scrollView.addSubview(imageView)
        

        
        
        scrollView.contentSize = imageView.bounds.size

    }
    
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override weak var preferredFocusedView: UIView? { return self.scrollView }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    deinit {
        // perform the deinitialization
    }
    
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for press in presses {
            switch press.type {
            case .Menu:
                self.dismissViewControllerAnimated(true, completion: nil)
                break;
                default:
                    break;
            }
        }
    }
    
}

extension UIScrollView {
    public override func canBecomeFocused() -> Bool {
        return true
    }
}

