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
        setupLabels()
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
        imageView.image = UIImage.init(named: "sample")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        self.addSubview(self.imageView)
        
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
    }
    
    private func makeImageCircular() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius  = CGFloat(roundf(Float(imageView.frame.size.width/2.0)))
    }
    
    
    private func setupLabels(){
        
        titleTextField.font = UIFont.init(name: "Futura", size: 12)
        titleTextField.textColor = UIColor.white
        titleTextField.textAlignment = NSTextAlignment.center
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleTextField)
        
        self.addConstraint(NSLayoutConstraint(item: titleTextField, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleTextField, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 8))
    }
}
   
