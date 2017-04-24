//
//  SCSamplerBankCollectionViewCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/23/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSampleBankCell: UICollectionViewCell {
 
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupImageView()
        
    }
    func setupImageView(){
        
        if SCDataManager.shared.sampleBanks.count > 0 {
            imageView.image = UIImage.init(named: "sample.png")
            
        } else {
            imageView.image = UIImage.init(named: "plus.png")
        }
    }
}
