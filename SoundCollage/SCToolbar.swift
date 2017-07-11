//
//  SCToolbar.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCToolbar: UIToolbar {

    let toolbarHeight = CGFloat(98.0)

    private func setupControls(){
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        self.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        self.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(transparentPixel, forToolbarPosition: .any)
        self.isTranslucent = true
        
        let buttonHeight = (toolbarHeight/3)*2
        let yPosition = self.center.y-buttonHeight/2
        
        self.recordBtn = UIButton.GradientColorStyle(height: buttonHeight, gradientColors: [UIColor.red, UIColor.magenta, UIColor.orange], secondaryColor: UIColor.white)
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress), for: .touchUpInside)
        recordBtn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let bankBtn = UIButton.FlatColorStyle(height: buttonHeight, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral, secondaryColor: UIColor.white)
        bankBtn.addTarget(self, action: #selector(SCSamplerViewController.bankBtnDidPress), for: .touchUpInside)
        
        
        let sequencerBtn = UIButton.FlatColorStyle(height: buttonHeight, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.lightBlueSky, secondaryColor: UIColor.white)
        sequencerBtn.addTarget(self, action: #selector(SCSamplerViewController.presentSequencer), for: .touchUpInside)
        
        let tempBtn2 = UIButton.FlatColorStyle(height: buttonHeight, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.rose, secondaryColor: UIColor.white)
        
        let tempBtn3 = UIButton.FlatColorStyle(height: buttonHeight, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue, secondaryColor: UIColor.white)
        
        let bankBarBtn = UIBarButtonItem.init(customView: bankBtn)
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        let sequencerBarBtn = UIBarButtonItem.init(customView: sequencerBtn)
        let tempBarBtn2 = UIBarButtonItem.init(customView: tempBtn2)
        let tempBarBtn3 = UIBarButtonItem.init(customView: tempBtn3)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolbar.items = [flexibleSpace, bankBarBtn, flexibleSpace, sequencerBarBtn, flexibleSpace,  recordBarBtn, flexibleSpace, tempBarBtn2, flexibleSpace, tempBarBtn3, flexibleSpace]
        self.view.addSubview(toolbar)
    }


}
