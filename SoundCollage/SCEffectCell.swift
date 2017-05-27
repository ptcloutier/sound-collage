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
        

        self.effectLabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: 0, height: self.frame.height/5))
        effectLabel.frame.origin.x = self.contentView.center.x-(effectLabel.frame.width/2)
        effectLabel.text = title
        effectLabel.font = UIFont.init(name: "Futura", size: 20)
        effectLabel.textColor = UIColor.white
        effectLabel.textAlignment = NSTextAlignment.center

        self.contentView.addSubview(effectLabel)
        
    }
}
