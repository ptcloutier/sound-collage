//
//  SCLibraryCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/1/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCLibraryCell: UICollectionViewCell {
    
    
    var imageView = UIImageView()
    var titleLabel = UILabel()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    
    func setupLabel(){
        
        self.contentView.backgroundColor = UIColor.blue
       
    }
    
    
    func setupImageView(){
        
    }
    
}
