//
//  KeyboardViewController.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/16/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCKeyboardViewController: UIViewController {


    var colorManager: SCColors?
    var colorSets = [[CGColor]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createColorSets()
        colorManager = SCColors.init(colors: colorSets)
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 1.0, y: 1.0)
        colorManager?.configureGradientLayer(in: self.view, from: startPoint, to: endPoint)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func createColorSets() {
        colorSets.append([UIColor.darkGray.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor,UIColor.darkGray.cgColor, UIColor.blue.cgColor, UIColor.purple.cgColor])
        colorSets.append([UIColor.red.cgColor, UIColor.magenta.cgColor, UIColor.orange.cgColor, UIColor.lightGray.cgColor,UIColor.blue.cgColor, UIColor.yellow.cgColor])
    }
    
}


extension SCKeyboardViewController: SCNoteButtonDelegate  {
    
    func noteButtonDidPress(sender: SCNoteButton){
        colorManager?.morphColors()
    }

}

