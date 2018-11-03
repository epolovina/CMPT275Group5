//
//  Progress.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-10-25.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit
import MessageUI

class Progress: UIViewController, MFMailComposeViewControllerDelegate {

    //MARK: Outlets
    @IBOutlet weak var ShareButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func ShareClicked(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            //mail.delegate = self
            mail.setToRecipients(["sample@someEmail.com"])
            mail.setMessageBody("<p>Here's my progress!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alertController = UIAlertController(title: "Error", message: "Email has not been configured", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            //and finally presenting our alert using this method
            present(alertController, animated: true, completion: nil)
            print("Email configuration not setup")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
