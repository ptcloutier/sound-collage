//
//  SCPadNumberCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCPadNumberCell: UICollectionViewCell {
    
    var selectedPadLabel = UILabel()
    var colors: [UIColor] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setupLabel(title: String){
        
        self.selectedPadLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2)
        selectedPadLabel.text = title
        selectedPadLabel.font = UIFont.init(name: "Futura", size: 15)
        selectedPadLabel.textColor = UIColor.black
        selectedPadLabel.lineBreakMode = .byCharWrapping
        selectedPadLabel.textAlignment = NSTextAlignment.center
        selectedPadLabel.frame.origin.x = self.contentView.center.x-(selectedPadLabel.frame.width/2)
        selectedPadLabel.frame.origin.y = self.contentView.center.y-selectedPadLabel.frame.height/2
        self.addSubview(selectedPadLabel)
    }
}
