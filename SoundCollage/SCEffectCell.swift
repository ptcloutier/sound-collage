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
    var effectName = String()
    var colors: [UIColor] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setupLabel(){
        
        self.effectLabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2))
        effectLabel.text = effectName 
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
        
      
        let selectedEffect = SCAudioManager.shared.effectControls[index]
        let selectedPad = SCAudioManager.shared.selectedSampleIndex
        
        if selectedEffect.effectName == "pitch" {
            switch selectedEffect.isPadEnabled[selectedPad] {
            case true:
//                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selectedEffect.isPadEnabled[selectedPad] = false
                print("\(String(describing: selectedEffect.effectName)) turned off.")
            case false:
//                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selectedEffect.isPadEnabled[selectedPad] = true
                print("\(String(describing: selectedEffect.effectName)) turned on.")
            }
        }
        if selectedEffect.effectName == "delay" {
            switch  selectedEffect.isPadEnabled[selectedPad]  {
            case true:
//                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selectedEffect.isPadEnabled[selectedPad] = false
                print("\(String(describing: selectedEffect.effectName)) turned off.")
            case false:
//                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selectedEffect.isPadEnabled[selectedPad] = true
                print("\(String(describing: selectedEffect.effectName)) turned on.")
            }
        }
        if selectedEffect.effectName == "reverb" {
            switch selectedEffect.isPadEnabled[selectedPad] {
            case true:
//                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selectedEffect.isPadEnabled[selectedPad] = false
                print("\(String(describing: selectedEffect.effectName)) turned off.")
                
            case false:
//                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selectedEffect.isPadEnabled[selectedPad] = true
                print("\(String(describing: selectedEffect.effectName)) turned on.")
            }
        }
        
        SCDataManager.shared.user?.currentSampleBank?.effectSettings = SCAudioManager.shared.effectControls
    }
    
    
    func setSelectedEffect(index: Int){ //TODO: This not DRY
        
        let controls = SCAudioManager.shared.effectControls
        
        let selectedEffect = controls[index]

        let selectedPad = SCAudioManager.shared.selectedSampleIndex
        
        
        
        if selectedEffect.effectName == "pitch" {
            switch selectedEffect.isPadEnabled[selectedPad] {
            case true:
//                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selectedEffect.isPadEnabled[selectedPad] = true
                print("\(String(describing: selectedEffect.effectName)) turned on.")
            case false:
//                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selectedEffect.isPadEnabled[selectedPad] = false
                print("\(String(describing: selectedEffect.effectName)) turned off.")
            }
        }
        if selectedEffect.effectName == "delay" {
            switch selectedEffect.isPadEnabled[selectedPad] {
            case true:
//                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selectedEffect.isPadEnabled[selectedPad] = true
                print("\(String(describing: selectedEffect.effectName)) turned on.")
            case false:
//                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selectedEffect.isPadEnabled[selectedPad] = false
                print("\(String(describing: selectedEffect.effectName)) turned off.")
            }
        }
        if selectedEffect.effectName == "reverb" {
            switch selectedEffect.isPadEnabled[selectedPad] {
            case true:
//                SCAudioManager.shared.effectIsSelected = true
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
                selectedEffect.isPadEnabled[selectedPad] = true
                print("\(String(describing: selectedEffect.effectName)) turned on.")
                
            case false:
//                SCAudioManager.shared.effectIsSelected = false
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                selectedEffect.isPadEnabled[selectedPad] = false
                print("\(String(describing: selectedEffect.effectName)) turned off.")
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
