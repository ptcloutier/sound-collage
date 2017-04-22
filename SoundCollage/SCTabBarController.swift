//
//  SCTabBarController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/22/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCTabBarController: UITabBarController {

    var sizeForTabBar: CGSize?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupSize(){
        
        
        sizeForTabBar = super.sizeThatFits(
        
    }
}
