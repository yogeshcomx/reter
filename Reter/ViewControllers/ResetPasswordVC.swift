//
//  ResetPasswordVC.swift
//  Reter
//
//  Created by apple on 1/16/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    var emailId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
    }

    @IBAction func clickBtnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickBtnSubmit(_ sender: Any) {
        if txtPassword.text!.count > 0 && txtPassword.text! == txtConfirmPassword.text! {
            putResetPasswordAPICall()
        } else {
            showAlert(title: "Error", message: "Password did not match")
        }
        
    }
    
    func SetupUIElements() {
        txtConfirmPassword.setBottomBorder()
        txtPassword.setBottomBorder()
    }
    
    func putResetPasswordAPICall() {
        let url = baseUrl+"reset_password"
        
        let parameters: Parameters = [
            "value": emailId,
            "password": txtPassword.text!,
            "confirm_password": txtConfirmPassword.text!,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseResetPasswordResponseData(JSONData: response.data!)
            }
        }
    }
    
    func parseResetPasswordResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let alert = UIAlertController(title: "Success",
                                              message: "Succesfully Changed the Password",
                                              preferredStyle: .alert)
               
                let submit = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(submit)
                present(alert, animated: true, completion: nil)
                
            } else {
                showAlert(title: "Error", message: "Please Enter Registered Email Id")
            }
        }
        catch {
            print(error)
        }
    }
    
}
