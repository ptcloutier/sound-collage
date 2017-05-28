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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setupLabel(title: String){
        
        self.contentView.backgroundColor = UIColor.purple

        self.effectLabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/3))
                effectLabel.text = title
        effectLabel.font = UIFont.init(name: "Futura", size: 15)
        effectLabel.textColor = UIColor.white
        effectLabel.textAlignment = NSTextAlignment.center
        effectLabel.frame.origin.x = self.contentView.center.x-(effectLabel.frame.width/2)
        effectLabel.frame.origin.y = self.contentView.center.y - effectLabel.frame.height

        self.contentView.addSubview(effectLabel)
        
    }
    
    func toggleEffect(){
        
        switch  SCAudioManager.shared.effectIsSelected {
        case true:
             SCAudioManager.shared.effectIsSelected = false
             self.contentView.backgroundColor = UIColor.purple
        case false:
             SCAudioManager.shared.effectIsSelected = true
             self.contentView.backgroundColor = UIColor.init(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        }
        
        
    }
}
