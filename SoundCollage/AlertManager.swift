//
//  AlertManager.swift
//  
//
//  Created by perrin cloutier on 4/12/17.
//
//

import Foundation
import UIKit

class AlertManager {
    class func ShowAlert(title: String, message: String?, requiredAction: UIAlertAction, optionalAction: UIAlertAction?, in vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(requiredAction)
        if optionalAction != nil {
            alertController.addAction(optionalAction!)
        }
        vc.present(alertController, animated: true, completion: nil)
    }
}
