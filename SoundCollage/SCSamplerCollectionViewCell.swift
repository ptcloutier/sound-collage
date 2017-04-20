//
//  SamplerCollectionViewCell.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation

class SCSamplerCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate {
    
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var audioPlayer: AVAudioPlayer!
    let imageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        audioPlayer = AVAudioPlayer()
        createColorSets()
        createGradientLayer()
        changeColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Gradient Color
    private func createGradientLayer() {
        let gradientView = UIView()
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colorSets[currentColorSet]
        gradientLayer.locations = [0.0, 0.35]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        self.addSubview(gradientView)
    }
    
    private func createColorSets() {
        colorSets.append([UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.white.cgColor,UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor])
        colorSets.append([UIColor.red.cgColor, UIColor.magenta.cgColor, UIColor.orange.cgColor, UIColor.lightGray.cgColor,UIColor.blue.cgColor, UIColor.yellow.cgColor])
        currentColorSet = 0
    }
    
    func changeColor() {
        if currentColorSet < colorSets.count - 1 {
            currentColorSet! += 1
        }
        else {
            currentColorSet = 0
        }
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 0.1
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }
    
    private func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
            changeColor()
        }
    }
    
    func playSound(url: URL){
        
        
    }

}
