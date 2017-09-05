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
    
    class func FadeIn(duration: TimeInterval, fromVC: UIViewController, toVC: UIViewController?){
        
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations:{
            
            [weak fromVC] in
            guard let strongFromVC = fromVC else { return }
            let transition = CATransition() //TODO: use this transition when reloading samplerbankvc
            transition.duration = 1.0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFade
            strongFromVC.view.window!.layer.add(transition, forKey: kCATransition)
            guard let to = toVC else { return }
            strongFromVC.present(to, animated: true, completion: nil)
        })

    }
    
    class func RotateLayer(layer: CALayer, completion: (Bool) -> Void) {
        let rotation = CABasicAnimation.init(keyPath: "transform.rotation")
        rotation.fromValue = Float(0)
        rotation.toValue = Float(2*Double.pi)
        rotation.duration = 10.0
        rotation.repeatCount = 10
        layer.removeAllAnimations()
        layer.add(rotation, forKey: "Spin")
        completion(true)
    }
    
    
    class func FadeAlphaIn(duration: TimeInterval, view: UIView){
       
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations:{
            view.alpha = 1.0
        })
    }
    
    
    
    class func FadeAlphaOut(duration: TimeInterval, view: UIView){
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations:{
            view.alpha = 0.1
        })
    }
}

