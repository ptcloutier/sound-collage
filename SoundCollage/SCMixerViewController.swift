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
    
    //MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMixerCV()
     
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
}




extension SCMixerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return SCAudioManager.shared.mixerPanels.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MixerPanelCell", for: indexPath) as! SCMixerPanelCell
        
        cell.mixerPanelIdx = indexPath.row
        cell.initializeSliders()
        cell.setupSliders()
        cell.slidersWillAppear()
        cell.viewWillLayoutSliders()

        //TODO: should scroll to last selected mixer panel
        self.selectedMixerPanel = getSelectedMixerPanelIndex()

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
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       
        guard let cv = self.mixerCV else {
            print("Error getting mixerCV")
            return
        }
        let indexPaths = cv.indexPathsForVisibleItems
        let idx = (indexPaths.last?.last)!
        print("scrollview did end dragging, index - \(idx)")
        self.selectedMixerPanel = idx
        setSelectedMixerPanelIndex(index: idx)
    }
}




