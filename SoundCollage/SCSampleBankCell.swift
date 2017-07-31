//
//  SCSamplerBankCollectionViewCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/23/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSampleBankCell: UICollectionViewCell {
 
    let imageView = UIImageView()
    let titleTextField = UITextField()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupTextField()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        makeImageCircular()
    }
    
    
    
    private func setupImageView(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        self.addSubview(imageView)
        
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -20))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -20))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self.contentView, attribute: .width, multiplier: 0.75, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 0.75, constant: 0))
    }
    
    
    
    private func makeImageCircular() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius  = CGFloat(roundf(Float(imageView.frame.size.width/2.0)))
    }
    
    
    
    private func setupTextField(){
    
//        titleTextField.text = "Untitled"
        titleTextField.font = UIFont.init(name: "Futura", size: 20)
        titleTextField.textColor = UIColor.white//SCColor.Custom.VintageSeaStyle.darkAqua
        titleTextField.textAlignment = NSTextAlignment.center
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleTextField)
        
        self.addConstraint(NSLayoutConstraint(item: titleTextField, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleTextField, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: 16.0))
    }
}
   
