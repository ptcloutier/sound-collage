//
//  SCInterfaceCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/20/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCMusicInterfaceCell: UICollectionViewCell {
    
    var samplerVC: SCSamplerViewController?
    var sequencerVC: SCScoreViewController?
    var mixerVC: SCMixerViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setupSampler(){
        self.samplerVC = SCSamplerViewController(nibName: nil, bundle: nil)
        guard let samplerVC = self.samplerVC else { return }
        samplerVC.doWaveAnimation = true 
        samplerVC.view.frame = contentView.bounds
        self.contentView.addSubview(samplerVC.view)
    }
    
    
    func setupSequencer(){
        self.sequencerVC = SCScoreViewController(nibName: nil, bundle: nil)
        guard let sequencerVC = self.sequencerVC else { return }
        sequencerVC.view.frame = contentView.bounds
        self.contentView.addSubview(sequencerVC.view)
    }
    
    
        
    func setupMixer(){
        self.mixerVC = SCMixerViewController(nibName: nil, bundle: nil)
        guard let mixerVC = self.mixerVC else { return }
        mixerVC.view.frame = contentView.bounds
        self.contentView.addSubview(mixerVC.view)
    }


}
