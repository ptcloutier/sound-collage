//
//  KeyboardViewController.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/16/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCKeyboardViewController: UIViewController {
    
    @IBOutlet weak var lowerKeyboardView: UIView!
    @IBOutlet weak var lowerWholeNotes: SCStackView!
    @IBOutlet weak var lowerHalfNotes: SCStackView!
    @IBOutlet weak var upperKeyboardView: UIView!
    @IBOutlet weak var upperWholeNotes: SCStackView!
    @IBOutlet weak var upperHalfNotes: SCStackView!
    @IBOutlet weak var doubleManualView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    /* Scrollview zoom constraints */
    //    @IBOutlet weak var doubleManualViewBottomConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var doubleManualViewLeadingConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var doubleManualViewTopConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var doubleManualViewTrailingConstraint: NSLayoutConstraint!
//    var noteButtonDelegate : SCNoteButtonDelegate? = nil    
    var lowerWholeNoteButtons:[SCNoteButton]=[]
    var lowerHalfNoteButtons:[SCNoteButton]=[]
    var upperWholeNoteButtons:[SCNoteButton]=[]
    var upperHalfNoteButtons:[SCNoteButton]=[]
    var noteNumber = 0
    let quantity = 11
    var colorManager: SCColors?
    var colorSets = [[CGColor]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        createColorSets()
        colorManager = SCColors.init(colors: colorSets)
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 1.0, y: 1.0)
        colorManager?.configureGradientLayer(in: self.view, from: startPoint, to: endPoint)
        
        
        lowerWholeNoteButtons = setupNoteButtons(buttons: lowerWholeNoteButtons, quantity: quantity, in: lowerWholeNotes)!
        lowerHalfNoteButtons = setupNoteButtons(buttons: lowerHalfNoteButtons, quantity: quantity, in: lowerHalfNotes)!
        upperWholeNoteButtons = setupNoteButtons(buttons: upperWholeNoteButtons, quantity: quantity, in: upperWholeNotes)!
        upperHalfNoteButtons = setupNoteButtons(buttons: upperHalfNoteButtons, quantity: quantity, in: upperHalfNotes)!
        addButtons(buttons: lowerWholeNoteButtons, in: lowerWholeNotes)
        addButtons(buttons: lowerHalfNoteButtons, in: lowerHalfNotes)
        addButtons(buttons: upperWholeNoteButtons, in: upperWholeNotes)
        addButtons(buttons: upperHalfNoteButtons, in: upperHalfNotes)
        
        makeBlankNotes() // invalidates unnecessary notes in the half notes rows
    }
    
    func addButtons(buttons: [SCNoteButton], in stackView: SCStackView) {
        for button in buttons {
            stackView.addArrangedSubview(button)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNoteButtons(buttons: [SCNoteButton]!, quantity: Int, in stackView: SCStackView)-> [SCNoteButton]?{
        
        if var noteButtons = buttons {
            while noteButtons.count < quantity {
                let button = SCNoteButton.init(note: noteNumber, delegate: self)
                noteButtons.append(button)
                noteNumber+=1
            }
            for button in noteButtons {
                stackView.addArrangedSubview(button)
            }
            return noteButtons
        }else{
            return buttons
        }
    }
    
    
    func makeBlankNotes(){
        
        for button in lowerHalfNoteButtons {
            if button.note == 13 || button.note == 17 || button.note == 20  {
                button.alpha = 0
                button.isUserInteractionEnabled = false
            }
        }
        for button in upperHalfNoteButtons {
            if button.note == 36 || button.note == 39 || button.note == 43 {
                button.alpha = 0
                button.isUserInteractionEnabled = false
            }
        }
        
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
/*    TODO: Make an extended scrollview with an 88 value keyboard that can also zoom i/o */


//extension SCKeyboardViewController: UIScrollViewDelegate {
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return doubleManualView
//    }
//    private func updateMinZoomScaleForSize(size: CGSize) {
//        let widthScale = size.width / doubleManualView.bounds.width
//        let heightScale = size.height / doubleManualView.bounds.height
//        let minScale = min(widthScale, heightScale)
//
//        scrollView.minimumZoomScale = minScale
//
//        scrollView.zoomScale = minScale
//    }
//    override func viewDidLayoutSubviews(){
//        super.viewDidLayoutSubviews()
//
//        updateMinZoomScaleForSize(size: view.bounds.size)
//    }
//
//
//}

//    func setupInnerStackView(stackView: StackView, background: UIColor){
//
//        stackView.axis = .vertical
//        stackView.distribution = .
//        stackView.alignment = .fill
//        stackView.spacing = 6
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.isUserInteractionEnabled = true
//        stackView.backgroundColor = background
//    }
//
//    func setupKeyboardView(){
//
//        keyboardView.frame = CGRect(x: offset/2, y: offset/2, width: (view.bounds.width/2)-offset, height: view.bounds.height-offset)
//        keyboardView.backgroundColor = UIColor.gray
//        view.addSubview(keyboardView)
//    }
//
//    func setupSpacer() -> UIView {
//        let stretchingView = UIView()
//        stretchingView.setContentHuggingPriority(1, for : .vertical)
//        stretchingView.backgroundColor = .clear
//        stretchingView.translatesAutoresizingMaskIntoConstraints = false
//        return stretchingView
//    }

/* Programmatic creation of the inner stack views with keyboards */
//        let spacer = setupSpacer()
//
//        wholeTonesColumn1 = StackView(arrangedSubviews:wholeTones)
//        halfTonesColumn1 = StackView(arrangedSubviews: [spacer])
//        for button in halfTones {
//            halfTonesColumn1.addArrangedSubview(button)
//        }
//
//        wholeTonesColumn2 = UIStackView(arrangedSubviews: wholeTones)
//        halfTonesColumn2 = UIStackView(arrangedSubviews: halfTones)
//
//        setupInnerStackView(stackView: wholeTonesColumn1, background: UIColor.purple)
//        keyboardView.addSubview(wholeTonesColumn1)
//        setupInnerStackView(stackView: halfTonesColumn1, background: UIColor.orange)
//        keyboardView.addSubview(halfTonesColumn1)
//}


