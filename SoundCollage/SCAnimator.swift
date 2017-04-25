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
    
    class func fadeIn(in view: UIView){
    let transition = CATransition()
    transition.duration = 0.5
    transition.type = kCATransitionPush
    transition.subtype = kCATransitionFade
    view.window!.layer.add(transition, forKey: kCATransition)
//    present(vc, animated: true, completion: nil)
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
