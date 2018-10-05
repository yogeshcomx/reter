//
//  CreateNewMailVC.swift
//  Reter
//
//  Created by apple on 1/25/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import MessageUI

class CreateNewMailVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var txtRecipients: UITextField!
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var viewRecipients: UIView!
    @IBOutlet weak var viewSubject: UIView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnTemplates: UIButton!
    @IBOutlet weak var btnOffers: UIButton!
    
    var recipientsList:[String] = []
    var messagePurpose:ViewControllerScreenOptions = .View
    var editMessage: Message?
    var bulkEnabled:Bool = false
    var BulkRecipientsList:[String] = []
    var recipientsForDatabaseValue:[String] = []
    var TotalBulkCycle: Int = 0
    var currentBulkCycle: Int = 0
    var numberOfRecipientsInBatch:Int = 0
    var recipientsContactList:[Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    @IBAction func clickBtnContacts(_ sender: Any) {
        performSegue(withIdentifier: "toSelectContactsFromCreateNewMail", sender: self)
    }
    
    @IBAction func clickBtnTemplates(_ sender: Any) {
        performSegue(withIdentifier: "toSelectTemplateFromCreateNewMail", sender: self)
    }
    
    @IBAction func clickBtnOffers(_ sender: Any) {
        performSegue(withIdentifier: "toSelectOfferFromCreateNewMail", sender: self)
    }
    
    @IBAction func clickBtnSend(_ sender: Any) {
        if self.recipientsList.count > 50 {
            self.bulkEnabled = true
            self.recipientsForDatabaseValue = self.recipientsList
            self.BulkRecipientsList = self.recipientsList
            let divideValue = self.recipientsList.count / 50
            if self.recipientsList.count % 50 == 0 {
                self.TotalBulkCycle = divideValue
            } else {
                self.TotalBulkCycle = divideValue + 1
            }
            self.currentBulkCycle = 1
            self.numberOfRecipientsInBatch = self.recipientsList.count / self.TotalBulkCycle
            self.recipientsList = []
            self.recipientsList = Array(self.BulkRecipientsList.dropFirst(self.numberOfRecipientsInBatch))
            sendEmail()
        } else {
            sendEmail()
        }
        
    }
    
    func SetupUIElements() {
        txtMessage.delegate = self
        txtRecipients.setBottomBorder()
        txtSubject.setBottomBorder()
        viewRecipients.roundAllCorners(radius: 5.0)
        viewRecipients.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        viewSubject.roundAllCorners(radius: 5.0)
        viewSubject.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        viewMessage.roundAllCorners(radius: 5.0)
        viewMessage.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        btnTemplates.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        btnTemplates.roundAllCorners(radius: btnTemplates.frame.size.height/2)
        btnOffers.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        btnOffers.roundAllCorners(radius: btnOffers.frame.size.height/2)
    }
    
    func SaveNewMailToLocalDatabase(mailId: String) {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let newMail:Mail = Mail(mailId: mailId, recipients: recipientsList, subject: txtSubject.text!, message: txtMessage.text, sentTimestamp: Date().convertToString(), sentByUsrID: userid, isSelected: false)
        DatabaseManager.shared.addNewMailOfUserId(userid: userid, addingMail: newMail)
        hideActivityIndicator()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectContactsFromCreateNewMail" {
            let destVC:SelectContactsVC = segue.destination as! SelectContactsVC
            destVC.selectingForEmail = true
            destVC.delegate = self
        }  else if segue.identifier == "toSelectTemplateFromCreateNewMail" {
            let destVC:SelectTemplatesVC = segue.destination as! SelectTemplatesVC
            destVC.delegate = self
        } else if segue.identifier == "toSelectOfferFromCreateNewMail" {
            let destVC:SelectOffersVC = segue.destination as! SelectOffersVC
            destVC.delegate = self
        }
    }

}

extension CreateNewMailVC : MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(recipientsList)
            mail.setSubject(txtSubject.text!)
            mail.setMessageBody("<p>\(txtMessage.text!)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent :
            controller.dismiss(animated: true, completion: nil)
            if !bulkEnabled {
                controller.dismiss(animated: true, completion: nil)
                showAlert(title: "Success", message: "Mail sent successfully")
                SaveNewMailToLocalDatabase(mailId: "")
            } else if bulkEnabled && self.BulkRecipientsList.isEmpty {
                showAlert(title: "Success", message: "Mail sent successfully")
                recipientsList = recipientsForDatabaseValue
                SaveNewMailToLocalDatabase(mailId: "")
                self.hideActivityIndicator()
            } else if bulkEnabled && !self.BulkRecipientsList.isEmpty {
                self.currentBulkCycle = self.currentBulkCycle+1
                if BulkRecipientsList.count > numberOfRecipientsInBatch {
                    self.recipientsList = []
                    self.recipientsList = Array(self.BulkRecipientsList.dropFirst(numberOfRecipientsInBatch))
                    sendEmail()
                } else {
                    self.recipientsList = []
                    self.recipientsList = self.BulkRecipientsList
                    sendEmail()
                    self.BulkRecipientsList = []
                }
            }
        case .failed:
            controller.dismiss(animated: true, completion: nil)
            showAlert(title: "Error", message: "Mail not sent")
        case .cancelled:
            controller.dismiss(animated: false, completion: nil)
            showAlert(title: "Error", message: "Mail not sent")
        case .saved:
            print("Saved")
        }
    }
}


extension CreateNewMailVC: ContactsSelection {
    func selectionDone(selectedList:[Contact]) {
        recipientsList.removeAll()
        recipientsList = selectedList.map{$0.email!}
        txtRecipients.text =  recipientsList.joined(separator: ",")
    }
}

extension CreateNewMailVC: TemplatesSelection {
    func selectionDone(selectedTemplate: Template) {
        txtMessage.text = selectedTemplate.templateDescription
    }
}

extension CreateNewMailVC: OffersSelection {
    func selectionDone(selectedOffer: Offer) {
        txtMessage.text = selectedOffer.offerDescription
    }
}
