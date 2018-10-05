//
//  CreateContactVC.swift
//  Reter
//
//  Created by apple on 1/20/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import UIDropDown

class CreateContactVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

   
    @IBOutlet weak var imgContactPic: UIImageView!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmailId: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var switchContactStatus: UISwitch!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var dropDownCountry: UIDropDown!
    
    
    var contactPurpose:ViewControllerScreenOptions = .View
    var editContact: Contact?
    var selectedCountry:Country?
    var countryCodeList:[Country] = []
    
    
    let imagePicker: UIImagePickerController?=UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker?.delegate = self
        SetupUIElements()
        setUpContryDropDown()
        LoadContact()
        EnableEditOption()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    @IBAction func clickSwitchStatus(_ sender: Any) {
        
    }
    
    @IBAction func clickBtnEdit(_ sender: Any) {
        contactPurpose = .Edit
        EnableEditOption()
    }
    
   
    @IBAction func clickBtnSave(_ sender: Any) {
        if !textName.isValidName() {
            showAlert(title: "Alert", message: "Invalid Name")
        } else if !txtPhoneNumber.isValidPhoneNumber() {
            showAlert(title: "Alert", message: "Invalid Phone Number")
        } else if !txtEmailId.isValidEmail() {
            showAlert(title: "Alert", message: "Invalid Email")
        } else if selectedCountry == nil {
            showAlert(title: "Alert", message: "Please select country code")
        } else {
            if appMode == "Offline" {
                if contactPurpose == .Add {
                    SaveNewContactToLocalDatabase(contactId: "")
                } else if contactPurpose == .Edit{
                    UpdateContactToLocalDatabase(contactId: editContact!.contactId, isOfflineUpdate: true)
                }
            } else if appMode == "Online" {
                if isDeviceOnline {
                    if contactPurpose == .Add {
                        SaveNewContactAPICall()
                    } else if contactPurpose == .Edit{
                        UpdateContactAPICall()
                    }
                } else {
                    showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            } else {
                if isDeviceOnline {
                    if contactPurpose == .Add {
                        SaveNewContactAPICall()
                    } else if contactPurpose == .Edit{
                        UpdateContactAPICall()
                    }
                } else {
                    if contactPurpose == .Add {
                        SaveNewContactToLocalDatabase(contactId: "")
                    } else if contactPurpose == .Edit{
                        UpdateContactToLocalDatabase(contactId: editContact!.contactId, isOfflineUpdate: true)
                    }
                }
            }
        }
    }
    
    func SetupUIElements() {
        btnSave.roundAllCorners(radius: btnSave.frame.size.height/2)
        btnSave.setBorderWidthAndColor(width: 1.5, color: UIColor(hex: "4464C3").cgColor)
        textName.setBottomBorder()
        txtPhoneNumber.setBottomBorder()
        txtEmailId.setBottomBorder()
        imgContactPic.setBorderWidthAndColor(width: 2.0, color: UIColor(hex: "4464C3").cgColor)
        imgContactPic.roundAllCorners(radius: imgContactPic.frame.size.height/2)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openCameraLibrary(sender:)))
        tap.delegate = self
        imgContactPic.addGestureRecognizer(tap)
    }
    
    func setUpContryDropDown() {
        countryCodeList.removeAll()
        countryCodeList = DatabaseManager.shared.getCountries()
        dropDownCountry.borderWidth = 0.0
        dropDownCountry.tableHeight = 150.0
        dropDownCountry.tableWillAppear {
            self.view.bringSubview(toFront: self.dropDownCountry)
        }
        let countryCodeNames = countryCodeList.map{"\($0.countryName)  \($0.countryCode)"}
        dropDownCountry.textAlignment = .center
        dropDownCountry.textColor = UIColor.black
        dropDownCountry.placeholder = ""
        dropDownCountry.layer.zPosition = 10
        dropDownCountry.options = countryCodeNames
        dropDownCountry.didSelect { (option, index) in
            self.selectedCountry = self.countryCodeList[index]
            self.dropDownCountry.title.text = self.selectedCountry?.countryCode
            self.dropDownCountry.resign()
        }
        self.view.addSubview(dropDownCountry)
    }
    
    func EnableEditOption() {
        if contactPurpose == .View {
            btnSave.isHidden = true
            imgContactPic.isUserInteractionEnabled = false
            textName.isUserInteractionEnabled = false
            txtEmailId.isUserInteractionEnabled = false
            txtPhoneNumber.isUserInteractionEnabled = false
            switchContactStatus.isUserInteractionEnabled = false
            dropDownCountry.isUserInteractionEnabled = false
        } else if contactPurpose == .Add {
            self.navigationItem.rightBarButtonItem = nil
            btnSave.isHidden = false
            imgContactPic.isUserInteractionEnabled = true
            textName.isUserInteractionEnabled = true
            txtEmailId.isUserInteractionEnabled = true
            txtPhoneNumber.isUserInteractionEnabled = true
            switchContactStatus.isUserInteractionEnabled = true
            dropDownCountry.isUserInteractionEnabled = true
        } else if contactPurpose == .Edit {
            btnSave.isHidden = false
            imgContactPic.isUserInteractionEnabled = true
            textName.isUserInteractionEnabled = true
            txtEmailId.isUserInteractionEnabled = true
            txtPhoneNumber.isUserInteractionEnabled = true
            switchContactStatus.isUserInteractionEnabled = true
            dropDownCountry.isUserInteractionEnabled = true
        }
    }
    
    func LoadContact() {
        if contactPurpose == .View || contactPurpose == .Edit {
            textName.text = editContact?.name
            txtEmailId.text = editContact?.email
            txtPhoneNumber.text = editContact?.phone
            imgContactPic.image = editContact?.imageData?.convertToUIImage()
            switchContactStatus.isOn = (editContact?.isActive) ?? true
            if let index = countryCodeList.index(where: { $0.countryCode == editContact!.countryCode }) {
                if index < countryCodeList.count {
                    selectedCountry = countryCodeList[index]
                    dropDownCountry.title.text = selectedCountry?.countryCode
                }
            }
            dropDownCountry.title.text = selectedCountry?.countryCode
        }
    }
    
    @objc func openCameraLibrary(sender: UITapGestureRecognizer? = nil) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker!.allowsEditing = true
            imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            present(imagePicker!, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgContactPic.contentMode = .scaleAspectFill
        imgContactPic.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func SaveNewContactAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"add_contact"
        let parameters: Parameters = [
            "userId": userid,
            "contactName": textName.text!,
            "contactNumber": txtPhoneNumber.text!,
            "contactEmail": txtEmailId.text!,
            "country_code": selectedCountry?.countryCode ?? ""
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseNewContactResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseNewContactResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let addedContactId = jsonOutput["contactId"] as! String
                SaveNewContactToLocalDatabase(contactId: addedContactId)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    func UpdateContactAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"update_contact_details"
        let parameters: Parameters = [
            "contId": editContact!.contactId,
            "contactName": textName.text!,
            "contactNumber": txtPhoneNumber.text!,
            "contactEmail" : txtEmailId.text!,
            "country_code": selectedCountry?.countryCode ?? "",
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: URLEncoding.httpBody, headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseUpdateContactResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseUpdateContactResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                UpdateContactToLocalDatabase(contactId: editContact!.contactId, isOfflineUpdate: false)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    func SaveNewContactToLocalDatabase(contactId:String) -> Bool {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        if DatabaseManager.shared.getContactsCount(userid: userid) >= offlineContactsLimit {
            showAlert(title: "Alert", message: "Your offline contact limit exceeds. You cannot store more than \(offlineContactsLimit) contacts in offline.\nGo to App settings to customize the App as per your need")
            return false
        }
        showActivityIndicator()
        var imageString:String?
        if imgContactPic.image == UIImage(named: "defaultProfile") {
            imageString = nil
        } else {
            imageString = imgContactPic.image?.convertToBase64String()
        }
        let newContact:Contact = Contact(contactId: contactId, name: textName.text!, countryCode: selectedCountry?.countryCode ?? "", phone: txtPhoneNumber.text!, email: txtEmailId.text!, imageData: imageString, lastUpdateDate: Date().convertToString(), addedByUser: userid, isActive: switchContactStatus.isOn, isSelected: false)
        let addedStatus = DatabaseManager.shared.addNewContactOfUserId(userid: userid, addingContact: newContact)
        hideActivityIndicator()
        if addedStatus {
            self.navigationController?.popViewController(animated: true)
        } else {
            showAlert(title: "Error", message: "Error in adding Contact. Please check for Duplicate Values")
        }
        return true
    }
    
    func UpdateContactToLocalDatabase(contactId:String, isOfflineUpdate:Bool) {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        var imageString:String?
        if imgContactPic.image == UIImage(named: "defaultProfile") {
            imageString = nil
        } else {
            imageString = imgContactPic.image?.convertToBase64String()
        }
        let updatedContact:Contact = Contact(contactId: contactId, name: textName.text!, countryCode: selectedCountry?.countryCode ?? "", phone: txtPhoneNumber.text!, email: txtEmailId.text!, imageData: imageString, lastUpdateDate: Date().convertToString(), addedByUser: userid, isActive: switchContactStatus.isOn, isSelected: false)
        let updateStatus = DatabaseManager.shared.updateContactOfUserId(userid: userid, previousContactValue: editContact!, updatedContactValue: updatedContact, isOfflineUpdated: isOfflineUpdate)
        hideActivityIndicator()
        if updateStatus {
           self.navigationController?.popViewController(animated: true)
        } else {
            showAlert(title: "Error", message: "Error in Updating Contact. Please check for Duplicate Values")
        }
    }
    
}
