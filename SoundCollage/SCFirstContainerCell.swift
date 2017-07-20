//
//  SCTopContainerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCFirstContainerCell: UICollectionViewCell {
    
    
    var samplerVC: SCSamplerViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
   func setupSampler(){
        self.samplerVC = SCSamplerViewController(nibName: nil, bundle: nil)
        guard let samplerVC = self.samplerVC else { return }
        samplerVC.view.frame = contentView.bounds
        self.contentView.addSubview(samplerVC.view)
    }
}
