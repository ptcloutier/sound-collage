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
        
        let sampleIndex = SCAudioManager.shared.selectedSampleIndex
        guard let settings = SCDataManager.shared.user?.currentSampleBank?.effectSettings[index] else {
            print("Error accessing settings.")
            return
        }
        
            switch settings.isPadEnabled[sampleIndex] {
            case true:
                self.effectLabel.textColor = UIColor.white
                self.contentView.backgroundColor = colors[index]
                SCDataManager.shared.user?.currentSampleBank?.effectSettings[index].isPadEnabled[sampleIndex] = false
            case false:
                self.contentView.backgroundColor = UIColor.purple
                self.effectLabel.textColor = UIColor.white
               SCDataManager.shared.user?.currentSampleBank?.effectSettings[index].isPadEnabled[sampleIndex] = true
        }
    }
    
    
    func setSelectedEffect(index: Int){
        
        let sampleIndex = SCAudioManager.shared.selectedSampleIndex
        guard let settings = SCDataManager.shared.user?.currentSampleBank?.effectSettings[index] else {
            print("Error accessing settings.")
            return
        }
        
        switch settings.isPadEnabled[sampleIndex] {
        case true:
            self.contentView.backgroundColor = UIColor.purple
            self.effectLabel.textColor = UIColor.white
            settings.isPadEnabled[sampleIndex] = true
        case false:
            self.effectLabel.textColor = UIColor.white
            self.contentView.backgroundColor = colors[index]
            settings.isPadEnabled[sampleIndex] = false
        }
    }
}
