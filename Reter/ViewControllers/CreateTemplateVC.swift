//
//  CreateTemplateVC.swift
//  Reter
//
//  Created by apple on 2/5/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class CreateTemplateVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    var templatePurpose:ViewControllerScreenOptions = .View
    var editTemplate: Template?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        EnableEditOption()
        LoadTemplate()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        LoadTemplate()
    }

    @IBAction func clickBtnSave(_ sender: Any) {
        if templatePurpose == .Add {
            SaveTemplate()
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
        if templatePurpose == .View {
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
        } else if templatePurpose == .Add {
            txtTitle.isUserInteractionEnabled = true
            txtDescription.isUserInteractionEnabled = true
        } else if templatePurpose == .Edit {
            txtTitle.isUserInteractionEnabled = true
            txtDescription.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem = nil
            let rightButtonItem = UIBarButtonItem.init(
                title: "Save",
                style: .done,
                target: self,
                action: #selector(updateTemplate(sender:))
            )
            rightButtonItem.setTitleTextAttributes( [NSAttributedStringKey.font : UIFont(name: "AvenirNext-Regular", size: 17) ,NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
            self.navigationItem.rightBarButtonItem = rightButtonItem
            setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
        }
    }
    
    func LoadTemplate() {
        if templatePurpose == .View || templatePurpose == .Edit {
            txtTitle.text = editTemplate?.templateName
            txtDescription.text = editTemplate?.templateDescription
        }
    }
    
    func SaveTemplate() {
        if txtDescription.text! == "" || txtDescription.text! == "Text Message . . ." {
            showAlert(title: "Alert", message: "Please Enter Description")
        } else if txtTitle.text! == "" {
            showAlert(title: "Alert", message: "Please Enter Template Title")
        } else {
            if appMode == "Offline" {
                addNewTemplatesToLocalDatabase(templateId: "")
            } else if appMode == "Online" {
                if isDeviceOnline {
                    SaveNewTemplateAPICall()
                } else {
                    showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            } else {
                if isDeviceOnline {
                    SaveNewTemplateAPICall()
                } else {
                   addNewTemplatesToLocalDatabase(templateId: "")
                }
            }
        }
    }

    
    func SaveNewTemplateAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"add_template"
        let parameters: Parameters = [
            "userId": userid,
            "templateName": txtTitle.text!,
            "templateDescription": txtDescription.text!,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseNewTemplateResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseNewTemplateResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let tempID =  jsonOutput["templateId"] as? String ?? ""
                self.addNewTemplatesToLocalDatabase(templateId: tempID)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    @objc func clickButtonEdit(sender: UIBarButtonItem) {
        templatePurpose = .Edit
        EnableEditOption()
    }
    
    @objc func updateTemplate(sender: UIBarButtonItem) {
        if txtDescription.text! == "" || txtDescription.text! == "Text Message . . ." {
            showAlert(title: "Alert", message: "Please Enter Description")
        } else if txtTitle.text! == "" {
            showAlert(title: "Alert", message: "Please Enter Template Title")
        } else {
            if appMode == "Offline" {
                updateTemplateToLocalDatabase(isUpdatedOffline: true)
            } else if appMode == "Online" {
                if isDeviceOnline {
                    updateTemplateAPICall()
                } else {
                    showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            } else {
                if isDeviceOnline {
                    updateTemplateAPICall()
                } else {
                    updateTemplateToLocalDatabase(isUpdatedOffline: true)
                }
            }
        }
    }
    
    func updateTemplateAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"update_template_details"//?contactId=\(editContact!.contactId)&contactName=\(textName.text!)&contactNumber=\(txtPhoneNumber.text!)&contactEmail=\(txtEmailId.text!)&userId=\(userid)"
        let parameters: Parameters = [
            "tempId": editTemplate!.templateId,
            "templateName": txtTitle.text!,
            "templateDescription": txtDescription.text!,
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: URLEncoding.httpBody, headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseUpdateTemplateResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseUpdateTemplateResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
               updateTemplateToLocalDatabase(isUpdatedOffline: false)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    func addNewTemplatesToLocalDatabase(templateId:String) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let newTemp:Template = Template(templateId: templateId, templateName: txtTitle.text!, templateDescription: txtDescription.text!, lastUpdateDate: Date().convertToString(), addedByUser: userid, Status: false)
        DatabaseManager.shared.addNewTemplateOfUserId(userid: userid, addingTemplate: newTemp)
        hideActivityIndicator()
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateTemplateToLocalDatabase(isUpdatedOffline: Bool) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let updatedTemp:Template = Template(templateId: editTemplate!.templateId, templateName: txtTitle.text!, templateDescription: txtDescription.text!, lastUpdateDate: Date().convertToString(), addedByUser: userid, Status: false)
        DatabaseManager.shared.updateTemplateOfUserId(userid: userid, previousTemplateValue: editTemplate!, updatedTemplateValue: updatedTemp, isOfflineUpdated: isUpdatedOffline)
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
