//
//  Progress.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-10-25.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit
import MessageUI

class Progress: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var ShareButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: Actions
    @IBAction func ShareClicked(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients(["sample@someEmail.com"])
            mail.setMessageBody("<p>Here's my progress!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            print("Email configuration not setup")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
