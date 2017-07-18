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
        
        self.effectLabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2))
        effectLabel.text = effect 
        effectLabel.font = UIFont.init(name: "Futura", size: 15)
        effectLabel.textColor = UIColor.white
        effectLabel.lineBreakMode = .byCharWrapping
        effectLabel.textAlignment = NSTextAlignment.center
        effectLabel.frame.origin.x = self.contentView.center.x-(effectLabel.frame.width/2)
        effectLabel.frame.origin.y = self.contentView.center.y-effectLabel.frame.height/2
        self.addSubview(effectLabel)
        
    }
    
    func toggleEffectIsSelected(index: Int){
        
        //TODO: this method not DRY
        
      
        let selected = SCAudioManager.shared.effectControls[index]
        
        
        if selected.effectName == "pitch" {
            switch selected.isActive {
            case true:
                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selected.isActive = false
                print("\(selected.effectName) turned off.")
            case false:
                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selected.isActive = true
                print("\(selected.effectName) turned on.")
            }
        }
        if selected.effectName == "delay" {
            switch  selected.isActive  {
            case true:
                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selected.isActive = false
                print("\(selected.effectName) turned off.")
            case false:
                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selected.isActive  = true
                print("\(selected.effectName) turned on.")
            }
        }
        if selected.effectName == "reverb" {
            switch selected.isActive  {
            case true:
                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selected.isActive  = false
                print("\(selected.effectName) turned off.")
                
            case false:
                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selected.isActive  = true
                print("\(selected.effectName) turned on.")
            }
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
