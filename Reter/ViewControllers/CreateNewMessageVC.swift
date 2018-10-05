//
//  CreateNewMessageVC.swift
//  Reter
//
//  Created by apple on 1/19/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import MessageUI
import CoreData
import Alamofire

class CreateNewMessageVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var viewRecipients: UIView!
    @IBOutlet weak var txtRecipients: UITextField!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var btnTemplates: UIButton!
    @IBOutlet weak var btnSend: UIBarButtonItem!
    @IBOutlet weak var btnOffers: UIButton!
    
    let controller = MFMessageComposeViewController()
    var recipientsList:[String] = []
    var bulkEnabled:Bool = false
    var BulkRecipientsList:[String] = []
    var recipientsForDatabaseValue:[String] = []
    var TotalBulkCycle: Int = 0
    var currentBulkCycle: Int = 0
    var numberOfRecipientsInBatch:Int = 0
    var recipientsContactList:[Contact] = []
    var i:Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    @IBAction func clickBtnSend(_ sender: Any) {
        if txtMessage.text! == "" || txtMessage.text! == "Text Message . . ." {
            showAlert(title: "Alert", message: "Please Enter the Text")
        } else if txtRecipients.text! == "" {
            showAlert(title: "Alert", message: "Please select Recipients")
        } else {
            if appMode == "Offline" {
                let alert = UIAlertController(title: "Alert", message: "Message charges will apply as per your network operator", preferredStyle: .alert)
                let submit = UIAlertAction(title: "Continue", style: .default, handler: { (action) -> Void in
                    self.showActivityIndicator()
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
                        self.sendBulkMessageOfflineUsingNetworkOperator()
                    } else {
                        self.sendMessageOfflineUsingNetworkOperator()
                    }
                })
                let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in })
                alert.addAction(cancel)
                alert.addAction(submit)
                present(alert, animated: true, completion: nil)
            } else if appMode == "Online" && isDeviceOnline {
                sendSMSOnlineAPICall()
            } else if appMode == "Online" && !isDeviceOnline {
                showAlert(title: "No Internet", message: "Check your internet connection and try again")
            } else if appMode == "Hybrid" && isDeviceOnline {
                sendSMSOnlineAPICall()
            } else if appMode == "Hybrid" && !isDeviceOnline {
                let alert = UIAlertController(title: "Alert", message: "Message charges will apply as per your network operator", preferredStyle: .alert)
                let submit = UIAlertAction(title: "Continue", style: .default, handler: { (action) -> Void in
                    self.showActivityIndicator()
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
                        self.sendBulkMessageOfflineUsingNetworkOperator()
                    } else {
                        self.sendMessageOfflineUsingNetworkOperator()
                    }
                    
                })
                let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in })
                alert.addAction(cancel)
                alert.addAction(submit)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clickBtnContacts(_ sender: Any) {
        performSegue(withIdentifier: "toSelectContactsFromCreateNewMessage", sender: self)
    }
    @IBAction func clickBtnTemplates(_ sender: Any) {
        performSegue(withIdentifier: "toSelectTemplateFromCreateNewMessage", sender: self)
    }
    
    @IBAction func clickBtnOffers(_ sender: Any) {
        performSegue(withIdentifier: "toSelectOfferFromCreateNewMessage", sender: self)
    }
    
    func SetupUIElements() {
        txtMessage.delegate = self
        txtRecipients.setBottomBorder()
        viewRecipients.roundAllCorners(radius: 5.0)
        viewRecipients.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        viewMessage.roundAllCorners(radius: 5.0)
        viewMessage.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        btnTemplates.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        btnTemplates.roundAllCorners(radius: btnTemplates.frame.size.height/2)
        btnOffers.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        btnOffers.roundAllCorners(radius: btnOffers.frame.size.height/2)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Text Message . . ." {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Text Message . . ."
        }
    }
    
    func sendSMSOnlineAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"sendSMStoContact"
        let recipientsString = recipientsList.joined(separator: ",")
        let parameters: Parameters = [
            "userId": userid,
            "mobile": recipientsString,
            "message": txtMessage.text!,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseSendSMSOnlineResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
        
    }
    
    func parseSendSMSOnlineResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                showAlert(title: "Success", message: "Message sent successfully")
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
            }
        }
        catch {
            print(error)
        }
    }
    
    
    func SaveNewMessageToLocalDatabase(messageId: String) {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let newMsg:Message = Message(messageId: messageId, recipients: recipientsList, message: txtMessage.text!, sentTimestamp: Date().convertToString(), sentByUsrID: userid, isSelected: false)
        DatabaseManager.shared.addNewMessageOfUserId(userid: userid, addingMessage: newMsg)
        hideActivityIndicator()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectContactsFromCreateNewMessage" {
            let destVC:SelectContactsVC = segue.destination as! SelectContactsVC
            destVC.selectingForEmail = false
            destVC.selectedContactList = recipientsContactList
            destVC.delegate = self
        } else if segue.identifier == "toSelectTemplateFromCreateNewMessage" {
            let destVC:SelectTemplatesVC = segue.destination as! SelectTemplatesVC
            destVC.delegate = self
        } else if segue.identifier == "toSelectOfferFromCreateNewMessage" {
            let destVC:SelectOffersVC = segue.destination as! SelectOffersVC
            destVC.delegate = self
        }
    }
    
}

extension CreateNewMessageVC: MFMessageComposeViewControllerDelegate {
    
    func sendMessageOfflineUsingNetworkOperator() {
        if (MFMessageComposeViewController.canSendText()) {
            self.controller.body = txtMessage.text!
            self.controller.subject = ""
            self.controller.recipients = recipientsList
            self.controller.messageComposeDelegate = self
            self.present(self.controller, animated: true, completion: nil)
        }
    }
    
    func sendBulkMessageOfflineUsingNetworkOperator() {
        if (MFMessageComposeViewController.canSendText()) {
            
            self.controller.body = txtMessage.text!
            self.controller.subject = ""
            self.controller.recipients = recipientsList
            self.controller.messageComposeDelegate = self
            self.present(self.controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent :
            controller.dismiss(animated: true, completion: nil)
            if !bulkEnabled {
                showAlert(title: "Success", message: "Message sent successfully")
                SaveNewMessageToLocalDatabase(messageId: "")
                hideActivityIndicator()
            } else if bulkEnabled && self.BulkRecipientsList.isEmpty {
                showAlert(title: "Success", message: "Message sent successfully")
                recipientsList = recipientsForDatabaseValue
                SaveNewMessageToLocalDatabase(messageId: "")
                hideActivityIndicator()
            } else if bulkEnabled && !self.BulkRecipientsList.isEmpty {
                self.currentBulkCycle = self.currentBulkCycle+1
                if BulkRecipientsList.count > numberOfRecipientsInBatch {
                    self.recipientsList = []
                    self.recipientsList = Array(self.BulkRecipientsList.dropFirst(numberOfRecipientsInBatch))
                    sendBulkMessageOfflineUsingNetworkOperator()
                } else {
                    self.recipientsList = []
                    self.recipientsList = self.BulkRecipientsList
                    sendBulkMessageOfflineUsingNetworkOperator()
                    self.BulkRecipientsList = []
                }
                
            }
        case .failed:
            controller.dismiss(animated: true, completion: nil)
            showAlert(title: "Error", message: "Message not sent")
            hideActivityIndicator()
        case .cancelled:
            controller.dismiss(animated: false, completion: nil)
            showAlert(title: "Error", message: "Message not sent")
            hideActivityIndicator()
        }
    }
}

extension CreateNewMessageVC: ContactsSelection {
    func selectionDone(selectedList:[Contact]) {
        recipientsList.removeAll()
        recipientsContactList.removeAll()
        recipientsContactList = selectedList
        recipientsList = selectedList.map{$0.phone}
        txtRecipients.text =  recipientsList.joined(separator: ",")
    }
}

extension CreateNewMessageVC: TemplatesSelection {
    func selectionDone(selectedTemplate: Template) {
        txtMessage.text = selectedTemplate.templateDescription
    }
}

extension CreateNewMessageVC: OffersSelection {
    func selectionDone(selectedOffer: Offer) {
        txtMessage.text = selectedOffer.offerDescription
    }
}
