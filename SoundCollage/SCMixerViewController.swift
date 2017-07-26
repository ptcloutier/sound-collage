//
//  SCMixerViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCMixerViewController: UIViewController {
    
    var parameterView: UIView?
    var effectsCV: UICollectionView?
    var effects: [String] = []
    let toolbarHeight: CGFloat = 125.0
    var sliders: [SCSlider] = []
    var selectedEffectIndex: Int = 0
    
    //MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEffectsCV()
        setupParameterView()
        initializeSliders()
        setupSliders()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCMixerViewController.selectedSamplePadDidChange), name: Notification.Name.init("selectedSamplePadDidChangeNotification"), object: nil)

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        for slider in sliders {
            if self.parameterView != nil {
                slider.isHidden = false
                self.parameterView!.addSubview(slider)
            }
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        
        var xPosition = 30.0
        
        for (index, slider) in sliders.enumerated() {
            slider.updateSlider(slider: slider, xPosition: CGFloat(xPosition), view: view)
            xPosition+=35.0
            slider.idx = index
        }
    }
    
    
    
    //MARK: UISlider
    
    
    
    
    func initializeSliders(){
        
        while sliders.count < 10 {
            let slider = SCSlider.init(frame: .zero)
            let frame = slider.trackRect(forBounds: view.frame)
            slider.frame = frame 
            // make vertical
            slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
            slider.isContinuous = false
            slider.isHidden = true
            sliders.append(slider)
        }
    }
    
    
    func setupSliders(){
        
        for slider in sliders {
            addSliderTarget(slider: slider)
            slider.minimumTrackTintColor = UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral
            slider.maximumTrackTintColor = UIColor.Custom.PsychedelicIceCreamShoppe.lightViolet
            let image = UIImage.imageWithImage(image: UIImage.init(named: "rectPink")!, newSize: CGSize(width: 10.0, height: 30.0))
            slider.setThumbImage(image, for: .normal)
        }
    }
    
    
    func addSliderTarget(slider: SCSlider){
        slider.addTarget(self, action: #selector(SCMixerViewController.sliderChanged(sender:)), for: .valueChanged)
    }
    
    
    func sliderChanged(sender: SCSlider) {
        //Use the value from the slider for something
        switch sender.idx {
        case 0:
            print("index - \(sender.idx), value - \(sender.value)")
        case 1:
            print("index - \(sender.idx), value - \(sender.value)")

        case 2:
            print("index - \(sender.idx), value - \(sender.value)")

        case 3:
            print("index - \(sender.idx), value - \(sender.value)")

        case 4:
            print("index - \(sender.idx), value - \(sender.value)")

        case 5:
            print("index - \(sender.idx), value - \(sender.value)")

        case 6:
            print("index - \(sender.idx), value - \(sender.value)")

        case 7:
            print("index - \(sender.idx), value - \(sender.value)")

        case 8:
            print("index - \(sender.idx), value - \(sender.value)")

        case 9:
            print("index - \(sender.idx), value - \(sender.value)")
        default:
            print("nada")
        }
    }
    
    
    
    func setupEffectsCV(){
        
        let mixerFlowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        self.effectsCV = UICollectionView.init(frame: .zero, collectionViewLayout: mixerFlowLayout)
        guard let effectsCV = self.effectsCV else {
            print("No effects container.")
            return
        }
        effectsCV.isPagingEnabled = true
        effectsCV.allowsMultipleSelection = true
        effectsCV.delegate = self
        effectsCV.dataSource = self
        effectsCV.isScrollEnabled = false
        effectsCV.register(SCEffectPickerCell.self, forCellWithReuseIdentifier: "EffectPickerCell")
     
        effectsCV.backgroundColor = UIColor.clear
        self.view.addSubview(effectsCV)
        
        effectsCV.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsCV, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.1, constant: 0))
    }
    
    
    //MARK: main mixer sliders
    
    func setupParameterView(){
        
        parameterView = UIView.init(frame: .zero)
        guard let parameterView = self.parameterView else {
            print("No parameter view.")
            return
        }
        
        parameterView.isUserInteractionEnabled = true
        parameterView.isMultipleTouchEnabled = false
        parameterView.layer.masksToBounds = true
        parameterView.layer.cornerRadius = 15.0
        parameterView.layer.borderWidth = 3
        parameterView.layer.borderColor = UIColor.purple.cgColor
        parameterView.backgroundColor = UIColor.Custom.VintageSeaStyle.brightVintageRed
        self.view.addSubview(parameterView)
        
        parameterView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .top, relatedBy: .equal, toItem: self.effectsCV, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -toolbarHeight))
        
        
    }
    
    
    
  
    
    //MARK: selected sample pad
    
    func selectedSamplePadDidChange(){
       
        self.effectsCV?.reloadData()
    }
    
    
    
    
    func setSelectedEffectIndex(index: Int){
        
        SCDataManager.shared.setSelectedEffectIndex(index: index)
        self.effectsCV?.reloadData()
    }
    
    
    
    
    
    func getSelectedEffectIndex(){
        
        selectedEffectIndex = SCDataManager.shared.getSelectedEffectIndex()
    }

    
    
    
    func findColorIndex(indexPath: IndexPath, colors: [UIColor])-> Int{
        
        var colorIdx: Int
        if indexPath.row > colors.count-1 {
            colorIdx = indexPath.row-colors.count
            if colorIdx > colors.count-1 {
                colorIdx -= colors.count
            }
        } else {
            colorIdx = indexPath.row
        }
        return colorIdx
    }
 
}




extension SCMixerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let c = (SCDataManager.shared.user?.currentSampleBank?.effectSettings.count)!
        return c
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectPickerCell", for: indexPath) as! SCEffectPickerCell
        cell.colors = SCGradientColors.getPsychedelicIceCreamShopColors()
        if indexPath.row == self.selectedEffectIndex {
            cell.contentView.backgroundColor = UIColor.purple
            cell.effectLabel.textColor = UIColor.white
        } else {
            cell.effectLabel.textColor = UIColor.black
            let idx = findColorIndex(indexPath: indexPath, colors: cell.colors)
            cell.contentView.backgroundColor = cell.colors[idx]
        }
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        setSelectedEffectIndex(index: indexPath.row)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            }
        }
        return true
    }

}


extension SCMixerViewController:  UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let mixerCellSize = CGSize.init(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
        return mixerCellSize
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}



extension SCMixerViewController: UIGestureRecognizerDelegate {
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    func tap(gestureRecognizer: UIGestureRecognizer) {
        
        if SCAudioManager.shared.isRecording == true {
            print("Recording in progress")
            return
        }
        
        
        let tapLocation = gestureRecognizer.location(in: self.effectsCV)
        
        guard let indexPath = self.effectsCV?.indexPathForItem(at: tapLocation) else {
            print("IndexPath not found.")
            return
        }
        
        guard let cell = self.effectsCV?.cellForItem(at: indexPath) else {
            print("Cell not found.")
            return
        }
        
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        
        self.collectionView(effectsCV!, didSelectItemAt: indexPath)
    }
}






