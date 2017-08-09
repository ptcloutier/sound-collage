//
//  SCLibraryViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/1/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCLibraryViewController: UIViewController {

    //TODO: navigate from samplebanks or sampler 
    
    var libraryCV: UICollectionView?
    let toolbarHeight: CGFloat = 98.0
    var toolbar = UIToolbar()
    let inset: CGFloat = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupControls()
        
    }

    
    
    func setupCollectionView(){
        
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 1)
        let frame = CGRect(x: self.view.frame.width/3.0, y: 10.0, width: self.view.frame.width/3.0, height: self.view.frame.height)
        libraryCV = UICollectionView.init(frame: frame, collectionViewLayout: flowLayout)
        guard let libraryCV = self.libraryCV else { return }
        libraryCV.backgroundColor = SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet//UIColor.black
        libraryCV.delegate = self
        libraryCV.dataSource = self
        libraryCV.allowsMultipleSelection = false
        libraryCV.isUserInteractionEnabled = true
        libraryCV.isScrollEnabled = true
        libraryCV.register(SCLibraryCell.self, forCellWithReuseIdentifier: "LibraryCell")
        self.view.addSubview(libraryCV)
    }
    
    
    
    
    
    
    private func setupControls(){
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        let backBtn = UIButton()
        backBtn.addTarget(self, action: #selector(SCLibraryViewController.backBtnDidPress), for: .touchUpInside)
        
        let backBarBtn = setupToolbarButton(btn: backBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [flexibleSpace, backBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
    
    
    func setupToolbarButton(btn: UIButton)-> UIBarButtonItem {
        
        let buttonHeight = toolbarHeight
        let yPosition = toolbar.center.y-buttonHeight/2
        
        btn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        btn.setImage(UIImage.init(named: "back"), for: .normal)
        
        let backgroundView = UIView.init(frame: btn.frame)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.layer.cornerRadius = buttonHeight/2
        backgroundView.layer.masksToBounds = true
        btn.addSubview(backgroundView)
        btn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let barBtn = UIBarButtonItem.init(customView: btn)
        return barBtn
    }
    
    //MARK: Navigation
    
    func backBtnDidPress(){
        
        dissolve()
    }
    
    
    
    
    func dissolve(){
        
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionCrossDissolve], animations:{
          
        },
                       completion: { (finished: Bool) in
                        UIView.animate(withDuration: 0.1, delay: 0, options: [.transitionCrossDissolve], animations:{
                            self.presentSampleBanks()
                            
                        })
        })
    }
    
    
    

    
    
    func presentSampler(){
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations:{
            let vc: SCContainerViewController = SCContainerViewController(nibName: nil, bundle: nil)
            let transition = CATransition()
            transition.duration = 1.0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFade
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.present(vc, animated: true, completion: nil)
        }, completion: nil
        )
    }
    
    
    
    
    func presentSampleBanks(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController else {
            print("SampleBank vc not found.")
            return
        }
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
}



extension SCLibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SCDataManager.shared.user?.soundCollages.count ?? 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryCell", for: indexPath) as! SCLibraryCell
        cell.setupLabel()
        cell.setupImageView()
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("selected item")
        
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




extension SCLibraryViewController:  UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width-(inset*2.0)
        let libraryCellSize = CGSize.init(width: width, height: width)
        return libraryCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0,0,0,0)
    }
}

