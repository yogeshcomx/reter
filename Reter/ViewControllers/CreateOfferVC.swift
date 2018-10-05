//
//  CreateOfferVC.swift
//  Reter
//
//  Created by apple on 3/2/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire

class CreateOfferVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!

    var offerPurpose: ViewControllerScreenOptions = .View
    var editOffer: Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        EnableEditOption()
        LoadOffer()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LoadOffer()
    }
    
    @IBAction func clickedBtnSave(_ sender: Any) {
        if offerPurpose == .Add {
            SaveOffer()
        }
    }
    
    func SetupUIElements() {
        txtDescription.delegate = self
        txtTitle.setBottomBorder()
        viewTitle.roundAllCorners(radius: 5.0)
        viewTitle.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
        viewDescription.roundAllCorners(radius: 5.0)
        viewDescription.setBorderWidthAndColor(width: 1.0, color: UIColor(hex: "4464C3").cgColor)
    }
    
    func EnableEditOption() {
        if offerPurpose == .View {
            txtTitle.isUserInteractionEnabled = false
            txtDescription.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem = nil
            let rightButtonItem = UIBarButtonItem.init(
                title: "Edit",
                style: .done,
                target: self,
                action: #selector(clickButtonEdit(sender:))
            )
            rightButtonItem.setTitleTextAttributes( [NSAttributedStringKey.font : UIFont(name: "AvenirNext-Regular", size: 17) ,NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
            self.navigationItem.rightBarButtonItem = rightButtonItem
            setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
        } else if offerPurpose == .Add {
            txtTitle.isUserInteractionEnabled = true
            txtDescription.isUserInteractionEnabled = true
        } else if offerPurpose == .Edit {
            txtTitle.isUserInteractionEnabled = true
            txtDescription.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem = nil
            let rightButtonItem = UIBarButtonItem.init(
                title: "Save",
                style: .done,
                target: self,
                action: #selector(updateOffer(sender:))
            )
            rightButtonItem.setTitleTextAttributes( [NSAttributedStringKey.font : UIFont(name: "AvenirNext-Regular", size: 17) ,NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
            self.navigationItem.rightBarButtonItem = rightButtonItem
            setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
        }
    }
    
    func LoadOffer() {
        if offerPurpose == .View || offerPurpose == .Edit {
            txtTitle.text = editOffer?.offerName
            txtDescription.text = editOffer?.offerDescription
        }
    }
    
    func SaveOffer() {
        if txtDescription.text! == "" || txtDescription.text! == "Text Message . . ." {
            showAlert(title: "Alert", message: "Please Enter Description")
        } else if txtTitle.text! == "" {
            showAlert(title: "Alert", message: "Please Enter Offer Title")
        } else {
            if appMode == "Offline" {
                addNewOfferToLocalDatabase(offerId: "")
            } else if appMode == "Online" {
                if isDeviceOnline {
                    SaveNewOfferAPICall()
                } else {
                    showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            } else {
                if isDeviceOnline {
                    SaveNewOfferAPICall()
                } else {
                    addNewOfferToLocalDatabase(offerId: "")
                }
            }
        }
    }
    
    
    func SaveNewOfferAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"add_offer"
        let parameters: Parameters = [
            "userId": userid,
            "offerName": txtTitle.text!,
            "offerDescription": txtDescription.text!,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseNewOfferResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseNewOfferResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let offerID =  jsonOutput["offerId"] as? String ?? ""
                self.addNewOfferToLocalDatabase(offerId: offerID)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    @objc func clickButtonEdit(sender: UIBarButtonItem) {
        offerPurpose = .Edit
        EnableEditOption()
    }
    
    @objc func updateOffer(sender: UIBarButtonItem) {
        if txtDescription.text! == "" || txtDescription.text! == "Text Message . . ." {
            showAlert(title: "Alert", message: "Please Enter Description")
        } else if txtTitle.text! == "" {
            showAlert(title: "Alert", message: "Please Enter Offer Title")
        } else {
            if appMode == "Offline" {
                updateOfferToLocalDatabase(isUpdatedOffline: true)
            } else if appMode == "Online" {
                if isDeviceOnline {
                    updateOfferAPICall()
                } else {
                    showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            } else {
                if isDeviceOnline {
                    updateOfferAPICall()
                } else {
                    updateOfferToLocalDatabase(isUpdatedOffline: true)
                }
            }
        }
    }
    
    func updateOfferAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"update_offer_details"
        let parameters: Parameters = [
            "offerId": editOffer!.offerId,
            "offerName": txtTitle.text!,
            "offerDescription": txtDescription.text!,
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: URLEncoding.httpBody, headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseUpdateOfferResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseUpdateOfferResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                updateOfferToLocalDatabase(isUpdatedOffline: false)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    func addNewOfferToLocalDatabase(offerId:String) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let newOffer:Offer = Offer(offerId: offerId, offerName: txtTitle.text!, offerDescription: txtDescription.text!, lastUpdateDate: Date().convertToString(), addedByUser: userid, Status: false)
        DatabaseManager.shared.addNewOfferOfUserId(userid: userid, addingOffer: newOffer)
        hideActivityIndicator()
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateOfferToLocalDatabase(isUpdatedOffline: Bool) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let updatedOffer:Offer = Offer(offerId: editOffer!.offerId, offerName: txtTitle.text!, offerDescription: txtDescription.text!, lastUpdateDate: Date().convertToString(), addedByUser: userid, Status: false)
        DatabaseManager.shared.updateOfferOfUserId(userid: userid, previousOfferValue: editOffer!, updatedOfferValue: updatedOffer, isOfflineUpdated: isUpdatedOffline)
        hideActivityIndicator()
        self.navigationController?.popViewController(animated: true)
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
}

