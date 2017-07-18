//
//  SCBottomContainerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSecondContainerCell: UICollectionViewCell {
    
    var effectsVC: SCEffectsViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupEffects(){
        self.effectsVC = SCEffectsViewController(nibName: nil, bundle: nil)
        guard let effectsVC = self.effectsVC else { return }
        effectsVC.view.frame = contentView.bounds
        self.contentView.addSubview(effectsVC.view)
    }
}
