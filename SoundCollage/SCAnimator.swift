//
//  SCAnimator.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import UIKit 

class SCAnimator {
    
    class func FadeIn(fromVC: UIViewController, toVC: UIViewController?){
        
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations:{
            
            [weak fromVC] in
            guard let strongFromVC = fromVC else { return }

            let transition = CATransition() //TODO: use this transition when reloading samplerbankvc
            transition.duration = 1.0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFade
            strongFromVC.view.window!.layer.add(transition, forKey: kCATransition)
            guard let to = toVC else {
                return
            }
            strongFromVC.present(to, animated: true, completion: nil)
        
        }, completion: nil
        )

    }
}

/*extension UIView {
func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
    UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
        self.alpha = 1.0
    }, completion: completion)  }

func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
    UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
        self.alpha = 0.0
    }, completion: completion)
}
}*/
