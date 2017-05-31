//
//  SCEffectCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 5/27/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCEffectCell: UICollectionViewCell {
    
    var effectLabel = UILabel()
    var effect = String()
    var colors: [UIColor] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setupLabel(){
        

        self.effectLabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/3))
        effectLabel.text = effect 
        effectLabel.font = UIFont.init(name: "Futura", size: 15)
        effectLabel.textColor = UIColor.purple
        effectLabel.textAlignment = NSTextAlignment.center
        effectLabel.frame.origin.x = self.contentView.center.x-(effectLabel.frame.width/2)
        effectLabel.frame.origin.y = self.contentView.center.y - effectLabel.frame.height/2

        self.contentView.addSubview(effectLabel)
        
    }
    
    func toggleEffectIsSelected(index: Int){
        
        
        switch  SCAudioManager.shared.effectIsSelected {
        case true:
            SCAudioManager.shared.effectIsSelected = false
            self.effectLabel.textColor = UIColor.purple

            // disable observe cell touch parameters
            
            self.contentView.backgroundColor = colors[index]
        case false:
            SCAudioManager.shared.effectIsSelected = true
            //  when selected, activate observe effect cell touch parameters
//            SCAudioManager.shared.activateEffect(index: index)
            
            self.contentView.backgroundColor = UIColor.purple
            self.effectLabel.textColor = UIColor.white
        }
    }
    
    
    
   /*  
     
     func activateTouchEffectParameters(){
     
     }
     
     func deactivateTouchEffectParameters(){
     
     }
     
     
     func effectParameters(){
     
        print("tuoch point x : \() , y: \()")
     
     }
     
 
 */
}
