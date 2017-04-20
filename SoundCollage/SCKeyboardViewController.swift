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
    @IBOutlet weak var doubleManualViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var doubleManualViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var doubleManualViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var doubleManualViewTrailingConstraint: NSLayoutConstraint!
    
    var lowerWholeNoteButtons:[SCNoteButton]=[]
    var lowerHalfNoteButtons:[SCNoteButton]=[]
    var upperWholeNoteButtons:[SCNoteButton]=[]
    var upperHalfNoteButtons:[SCNoteButton]=[]
    var noteNumber:Int = 0
    
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createColorSets()
        createGradientLayer()
        changeColor()
        lowerWholeNoteButtons =
            
            setupNoteButtons(buttons: lowerWholeNoteButtons, quantity: 11, in: lowerWholeNotes)!
        lowerHalfNoteButtons = setupNoteButtons(buttons: lowerHalfNoteButtons, quantity: 10, in: lowerHalfNotes)!
        upperWholeNoteButtons = setupNoteButtons(buttons: upperWholeNoteButtons, quantity: 11, in: upperWholeNotes)!
        upperHalfNoteButtons = setupNoteButtons(buttons: upperHalfNoteButtons, quantity: 10, in: upperHalfNotes)!
        makeBlankNotes()
        
    }
    
    func addButtons(buttons: [SCNoteButton], in stackView: SCStackView) {
        for button in buttons {
            stackView.addArrangedSubview(button)
        }
    }
//
//
        
//        makeBlankNotes()
//        let spacer = setupSpacer()
        
//        wholeTonesColumn1 = StackView(arrangedSubviews:wholeTones)
//        halfTonesColumn1 = StackView(arrangedSubviews: [spacer])
//        for button in halfTones {
//            halfTonesColumn1.addArrangedSubview(button)
//        }
        
//        wholeTonesColumn2 = UIStackView(arrangedSubviews: wholeTones)
//        halfTonesColumn2 = UIStackView(arrangedSubviews: halfTones)
      
//        setupInnerStackView(stackView: wholeTonesColumn1, background: UIColor.purple)
//        keyboardView.addSubview(wholeTonesColumn1)
//        setupInnerStackView(stackView: halfTonesColumn1, background: UIColor.orange)
//        keyboardView.addSubview(halfTonesColumn1)
//        
//        
//        
//    }
//

//
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupNoteButtons(buttons: [SCNoteButton]!, quantity: Int, in stackView: SCStackView)-> [SCNoteButton]?{
        
        if var noteButtons = buttons {
            while noteButtons.count < quantity {
                let button = SCNoteButton.init(note: noteNumber)
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
            if button.note == 35 || button.note == 38  {
                button.alpha = 0
                button.isUserInteractionEnabled = false
            }
        }
        
    }
    //MARK: Gradient color
    private func createGradientLayer() { //TODO: make an extension for these gradient color methods
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = colorSets[currentColorSet]
        gradientLayer.locations = [0.0, 0.35]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//        view.layer.addSublayer(gradientLayer)
        view.layer.insertSublayer(gradientLayer, at: 0)
    
    }
    
    private func createColorSets() {
        colorSets.append([UIColor.darkGray.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor,UIColor.darkGray.cgColor, UIColor.blue.cgColor, UIColor.purple.cgColor])
        colorSets.append([UIColor.red.cgColor, UIColor.magenta.cgColor, UIColor.orange.cgColor, UIColor.lightGray.cgColor,UIColor.blue.cgColor, UIColor.yellow.cgColor])
        currentColorSet = 0
    }
    
    private func changeColor() {
        if currentColorSet < colorSets.count - 1 {
            currentColorSet! += 1
        } else {
            currentColorSet = 0
        }
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 3.0
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }
    
}

extension SCKeyboardViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return doubleManualView
    }
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / doubleManualView.bounds.width
        let heightScale = size.height / doubleManualView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(size: view.bounds.size)
    }

    
}

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



