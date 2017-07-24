//
//  SCEffectsViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCEffectsViewController: UIViewController {

    var parameterView: UIView?
    var effectsContainerCV: UICollectionView?
    var effects: [String] = []
    let toolbarHeight: CGFloat = 125.0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupEffectsView()
        setupParameterView()
    }

    func setupEffectsView(){
        // effects
        let effectsFlowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 1)
        self.effectsContainerCV = UICollectionView.init(frame: .zero, collectionViewLayout: effectsFlowLayout)
        guard let effectsContainerCV = self.effectsContainerCV else {
            print("No effects container.")
            return
        }
        effectsContainerCV.isPagingEnabled = true
        effectsContainerCV.allowsMultipleSelection = true
        effectsContainerCV.delegate = self
        effectsContainerCV.dataSource = self
        effectsContainerCV.isScrollEnabled = true
        effectsContainerCV.register(SCEffectCell.self, forCellWithReuseIdentifier: "EffectCell")
        effectsContainerCV.backgroundColor = UIColor.clear
        self.view.addSubview(effectsContainerCV)
        
        effectsContainerCV.translatesAutoresizingMaskIntoConstraints = false
       
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.20, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
    
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
        
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .leading, relatedBy: .equal, toItem: effectsContainerCV, attribute: .trailing, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -toolbarHeight))
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(handleParameterGesture))
        parameterView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleParameterGesture))
        parameterView.addGestureRecognizer(tap)
    }
    
    
    
    //MARK: effects parameter
    
    func handleParameterGesture(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            let location =  gestureRecognizer.location(in: parameterView)
            
            let sampleIndex = SCAudioManager.shared.selectedSampleIndex
            SCAudioManager.shared.handleEffectsParameters(point: location, sampleIndex: sampleIndex)
        }
    }
}




extension SCEffectsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let effectsCellSize = CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height/5)
        return effectsCellSize
    }

    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SCAudioManager.shared.effectControls.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCell", for: indexPath) as! SCEffectCell
        cell.colors = SCGradientColors.getPsychedelicIceCreamShopColors()
        let effectControls = SCAudioManager.shared.effectControls[indexPath.row]
        if effectControls.effectName != nil {
            cell.effectName = SCAudioManager.shared.effectControls[indexPath.row].effectName!
        }
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10.0
        cell.contentView.backgroundColor = cell.colors[indexPath.row]
        cell.setupLabel()
        cell.setSelectedEffect(index: indexPath.row)
        return cell

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCEffectCell else {
            print("Wrong cell or no cell at indexPath.")
            return
        }
        cell.toggleEffectIsSelected(index: indexPath.row)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
