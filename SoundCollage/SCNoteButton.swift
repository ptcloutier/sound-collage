//
//  NoteButton.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/16/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCNoteButton: UIButton {
    
    var note: Int = 0
    
    required init(note: Int ) {
        // set myValue before super.init is called
        
        self.note = note
        
        super.init(frame: .zero)
        
        // set other operations after super.init, if required
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playNote(){
        
        self.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }, completion: nil)
        print(note)
    }
        
    func setupButton(){
        
//        self.contentMode = .scaleToFill
        self.isUserInteractionEnabled = true
//        self.translatesAutoresizingMaskIntoConstraints = false
        self.addTarget(self, action: #selector(SCNoteButton.playNote), for: .touchUpInside)
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.setImage(UIImage.init(named: "dot"), for: .normal)
    }
}
