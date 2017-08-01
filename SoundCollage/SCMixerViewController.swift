//
//  SCMixerViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCMixerViewController: UIViewController {
    
    var mixerCV: UICollectionView?
    let toolbarHeight: CGFloat = 125.0
    var selectedMixerPanel: Int = 0
    var selectedSamplePad: Int = 0

    
    
    //MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMixerCV()
        NotificationCenter.default.addObserver(self, selector: #selector(SCMixerViewController.selectedSamplePadDidChange), name: Notification.Name.init("selectedSamplePadDidChangeNotification"), object: nil)
        

     
    }
    
    
        
    func setupMixerCV(){
        
        
        let mixerFlowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        self.mixerCV = UICollectionView.init(frame: .zero, collectionViewLayout: mixerFlowLayout)
        guard let mixerCV = self.mixerCV else {
            print("No effects container.")
            return
        }
        mixerCV.isPagingEnabled = true
        mixerCV.allowsMultipleSelection = true
        mixerCV.delegate = self
        mixerCV.dataSource = self
        mixerCV.isScrollEnabled = true
        mixerCV.register(SCMixerPanelCell.self, forCellWithReuseIdentifier: "MixerPanelCell")
     
        mixerCV.backgroundColor = UIColor.clear
        self.view.addSubview(mixerCV)
        
        mixerCV.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -toolbarHeight))

    }
    
   
    
    
    
    
    func setSelectedMixerPanelIndex(index: Int){
        
        SCDataManager.shared.setSelectedMixerPanelIndex(index: index)
        self.mixerCV?.reloadData()
    }
    
    
    
    
    
    func getSelectedMixerPanelIndex() -> Int {
        
        let index = SCDataManager.shared.getSelectedMixerPanelIndex()
        return index
    }
    
    
    
    
    func selectedSamplePadDidChange(){
        
        self.selectedSamplePad = SCAudioManager.shared.selectedSampleIndex
        self.mixerCV?.reloadData()
    }
    
    
    
    func reloadCV(){
        
        guard let cv = self.mixerCV else { return }
        cv.reloadData()
    }
}




extension SCMixerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return SCAudioManager.shared.mixerPanels.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MixerPanelCell", for: indexPath) as! SCMixerPanelCell
        
        cell.mixerPanelIdx = indexPath.row
        cell.setupFaderDelegate(delegate: self)
        let xPos = cell.contentView.frame.width/12.0
        cell.sliderXPositions = [xPos, xPos*2.5, xPos*6.0, xPos*9.5, xPos*13.0 ]
        cell.sliders = [cell.slider1,  cell.slider2,  cell.slider3,  cell.slider4,  cell.slider5 ]
        cell.parameterLabels = [ cell.pLabel1, cell.pLabel2, cell.pLabel3, cell.pLabel4, cell.pLabel5 ]
        let keys: [String] = Array(SCAudioManager.shared.mixerPanels.keys)
        let vals: [[String]] = Array(SCAudioManager.shared.mixerPanels.values)
        
        for (index, slider) in cell.sliders.enumerated() {
            slider.idx = cell.sliders.index(of: slider)!
            cell.setupSlider(slider: slider)
            slider.xPos = cell.sliderXPositions[index]
            slider.updateSlider(slider: slider, view: cell.contentView)
            cell.setupParameterLabel(parameterLabel: cell.parameterLabels[index], slider: slider, name: vals[indexPath.row][index])
            cell.verticalLabel(label: cell.parameterLabels[index])
        }
        
        cell.showSlidersAndLabels()
        
        for (index, slider) in cell.sliders.enumerated() {
            
            cell.adjustLabel(label: cell.parameterLabels[index], slider: slider)
           let effectControls = SCAudioManager.shared.effectControls[cell.mixerPanelIdx]
            let parameters = effectControls[index].parameter
            let parameter = parameters[SCAudioManager.shared.selectedSampleIndex]
            slider.value = parameter
        }
        
        
        
        //TODO: should scroll to last selected mixer panel
        self.selectedMixerPanel = getSelectedMixerPanelIndex()
        
        cell.setupNameLabel()
        cell.nameLabel.text = keys[indexPath.row]
        cell.setupSelectedCellLabel(number: SCAudioManager.shared.selectedSampleIndex)
        
        return cell
        
    }
    
    
    
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
        
        let mixerCellSize = CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        return mixerCellSize
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
        
        
        let tapLocation = gestureRecognizer.location(in: self.mixerCV)
        
        guard let indexPath = self.mixerCV?.indexPathForItem(at: tapLocation) else {
            print("IndexPath not found.")
            return
        }
        
        guard let cell = self.mixerCV?.cellForItem(at: indexPath) else {
            print("Cell not found.")
            return
        }
        
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        
        self.collectionView(mixerCV!, didSelectItemAt: indexPath)
    }
}






extension SCMixerViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       
        guard let cv = self.mixerCV else {
            print("Error getting mixerCV")
            return
        }
        let indexPaths = cv.indexPathsForVisibleItems
        let idx = (indexPaths.last?.last)!
        print("scrollview did end decelerating, index - \(idx)")
        self.selectedMixerPanel = idx
        setSelectedMixerPanelIndex(index: idx)
        
        scrollView.snapToNearestCell(scrollView: scrollView, collectionView: cv)
        cv.reloadData()
    }
}








extension SCMixerViewController: SCFaderDelegate {
    
    func faderValueDidChange(sender: SCSlider){
        print("fader value changed - \(sender.value)")
    }
}



