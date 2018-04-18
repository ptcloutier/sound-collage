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
    var playIcon = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        makeImageCircular()
    }
    
    
    func setupPlayIcon(){
        
        let frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width/4, height: self.contentView.frame.height/4)
        
        playIcon = UIImageView.init(frame: frame)
        playIcon.center = self.contentView.center
        playIcon.image = UIImage.init(named: "play_filled")
        contentView.addSubview(playIcon)
    }
    
    private func makeImageCircular() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius  = CGFloat(roundf(Float(imageView.frame.size.width/2.0)))
    }
    
    
    func setupLabel(){
        
        titleLabel.addGlow(color: SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet)
        titleLabel.isUserInteractionEnabled = false
        titleLabel.frame = CGRect(x: 0, y: 60.0, width: 200.0, height: 50.0)
        titleLabel.textAlignment = NSTextAlignment.center
        
        titleLabel.frame.origin.x = (self.contentView.frame.maxX/2.0)-(titleLabel.frame.width/2.0)
        titleLabel.font = UIFont.init(name: "Futura", size: 40.0)
        titleLabel.textColor = SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet
        contentView.addSubview(titleLabel)
    }
    
    
    func setupImageView(){
       
        imageView.frame = CGRect(x:0, y: self.contentView.frame.maxY*0.25, width: self.contentView.frame.width, height: self.contentView.frame.width)
        imageView.image = UIImage.init(named: "l1")
        contentView.addSubview(imageView)
    }
    
}
