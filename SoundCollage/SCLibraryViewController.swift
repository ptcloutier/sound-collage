//
//  SCLibraryViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/1/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import MessageUI

class SCLibraryViewController: UIViewController {

    
    var libraryCV: UICollectionView?
    let toolbarHeight: CGFloat = 98.0
    var toolbar = SCToolbar()
    let inset: CGFloat = 2.0
    var indexForAudioSharing: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupControls()
        
    }

    
    
    func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        libraryCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let libraryCV = self.libraryCV else { return }
        libraryCV.delegate = self
        libraryCV.dataSource = self
        libraryCV.allowsMultipleSelection = false
        libraryCV.isUserInteractionEnabled = true
        libraryCV.isScrollEnabled = true
        libraryCV.register(SCLibraryCell.self, forCellWithReuseIdentifier: "SCLibraryCell")
        self.view.addSubview(libraryCV)
        libraryCV.backgroundColor = SCColor.Custom.Gray.dark
        libraryCV.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: libraryCV, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: libraryCV, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: libraryCV, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: libraryCV, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
    
    
    
    private func setupControls(){
        
        toolbar.transparentToolbar(view: view, toolbarHeight: toolbarHeight)
        
        let backBtn = UIButton()
        backBtn.addTarget(self, action: #selector(SCLibraryViewController.backBtnDidPress), for: .touchUpInside)
        backBtn.setImage(UIImage.init(named: "back"), for: .normal)
        let backBarBtn = setupToolbarButton(btn: backBtn)
        
        let shareBtn = UIButton()
        shareBtn.addTarget(self, action: #selector(SCLibraryViewController.shareBtnDidPress), for: .touchUpInside)
        shareBtn.setImage(UIImage.init(named: "share"), for: .normal)
        let shareBarBtn = setupToolbarButton(btn: shareBtn)

        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [flexibleSpace, backBarBtn, flexibleSpace, shareBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
   
    
    
    
    func setupToolbarButton(btn: UIButton)-> UIBarButtonItem {
        
        let buttonHeight = toolbarHeight
        let yPosition = toolbar.center.y-buttonHeight/2
        
        btn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        
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
        
        SCAudioManager.shared.audioController?.stopSong()

        
        guard let currentSB = SCDataManager.shared.currentSampleBank else {
            print("No sample bank chosen")
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionCrossDissolve], animations:{
                self.presentSampleBanks()
                
            })
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionCrossDissolve], animations:{
            
            guard let audioManagerIsSetup = SCAudioManager.shared.isSetup else { return }
            
            switch  audioManagerIsSetup {
            case true:
                self.presentSampler()
                print("Current sample bank #\(currentSB)")
            case false:
                self.presentSampleBanks()
            }
        })
    }
    
    
    

    
    
    func presentSampler(){
        
        SCAudioManager.shared.audioController?.stopSong()

        let vc: SCContainerViewController = SCContainerViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    
    
    func presentSampleBanks(){
        
        SCAudioManager.shared.audioController?.stopSong()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController else {
            print("SampleBank vc not found.")
            return
        }
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    func shareBtnDidPress(){
        
        SCAudioManager.shared.audioController?.stopSong()
        
        if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            
            //Set the subject and message of the email
            mailComposer.setSubject("Sound Collage Experiment")
            mailComposer.setMessageBody("Hi, I made this for you!", isHTML: false)
            mailComposer.setToRecipients(["cloutier.perrin@gmail.com"])
            
//            let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
                let fm = FileManager.default
                let fileName = SCDataManager.shared.user?.soundCollages[indexForAudioSharing!]
                let filecontent = fm.contents(atPath: fileName!)//(docsDir + "/" + fileName)
            
                mailComposer.addAttachmentData(filecontent!, mimeType: "audio/aac", fileName: fileName!)
            
            
            self.present(mailComposer, animated: true, completion: nil)
        }
        
    }
}



extension SCLibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let result = SCDataManager.shared.user?.soundCollages.count else {
            return 0
        }
        return result
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCLibraryCell", for: indexPath) as! SCLibraryCell
       
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SCLibraryViewController.tap(gestureRecognizer:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        cell.addGestureRecognizer(tapGestureRecognizer)
        
        cell.setupLabel()
        cell.setupImageView()
        cell.backgroundColor = SCColor.Custom.Gray.dark
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("selected song at \(indexPath.row)")
        SCAudioManager.shared.audioController?.playSoundCollage(index: indexPath.row)
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
        let libraryCellSize = CGSize.init(width: width, height: collectionView.frame.size.height)
        return libraryCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 60.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0,0,0,0)
    }
}




extension SCLibraryViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let cv = self.libraryCV {
            scrollView.snapToNearestCell(scrollView: scrollView, collectionView: cv)
            indexForAudioSharing = cv.indexPathsForVisibleItems.first?.row
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let cv = libraryCV {
            scrollView.snapToNearestCell(scrollView: scrollView, collectionView: cv)
        }
    }
}





extension SCLibraryViewController: UIGestureRecognizerDelegate {
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    func tap(gestureRecognizer: UITapGestureRecognizer) {
        
        
        let tapLocation = gestureRecognizer.location(in: self.libraryCV)
        
        guard let indexPath = self.libraryCV?.indexPathForItem(at: tapLocation) else {
            print("IndexPath not found.")
            return
        }
        
        guard let cell = self.libraryCV?.cellForItem(at: indexPath) else {
            print("Cell not found.")
            return
        }
        
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        
        print("selected cell at \(indexPath.row)")
        self.collectionView(libraryCV!, didSelectItemAt: indexPath)
    }
}




