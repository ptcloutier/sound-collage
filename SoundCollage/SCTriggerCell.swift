//
//  SCSequencerInnerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCTriggerCell: UICollectionViewCell {
    
    var sequencerIdx: Int = 0
    var idx: Int = 0
    var isPlaybackEnabled: Bool = false
    let padLabel = UILabel()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
     
    func setupLabel(){
        
        padLabel.isUserInteractionEnabled = false
        padLabel.frame = .zero
        padLabel.textColor = UIColor.white 
        padLabel.textAlignment = NSTextAlignment.center
        padLabel.font = UIFont.init(name: "Futura", size: 16.0)
        contentView.addSubview(padLabel)
        padLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 0.75, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        let centerY = ((contentView.frame.height/4)*3)/6
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: centerY))
    }
    
    
    
    func circularCell(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.contentView.frame.width*0.5
    }
    
    func diamondCell(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.contentView.frame.width*1.0
    }
  }
