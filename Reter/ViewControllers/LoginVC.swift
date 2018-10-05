//
//  ViewController.swift
//  Reter
//
//  Created by apple on 1/15/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmailPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblNewUser: UILabel!
    @IBOutlet weak var btnsignUp: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    var forgotPasswordEmailId:String = ""
    var hideLoginOptions:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
    }
    @IBAction func clickBtnLogin(_ sender: Any) {
        if txtEmailPhone.text!.count > 0 && txtPassword.text!.count > 0 {
            if isDeviceOnline {
              //  postLoginAPICall(emailPhone: txtEmailPhone.text!, password: txtPassword.text!)
                LoginWithLocalDatabse()
            } else {
                LoginWithLocalDatabse()
            }
        } else {
            txtEmailPhone.text!.count == 0 ? showAlert(title: "Alert", message: "Please Enter Email or Phone Number") : showAlert(title: "Alert", message: "Please Enter Password")
        }
    }
    
    @IBAction func clickBtnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func clickBtnForgotPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Forgot Password",
                                      message: "Enter your email Id",
                                      preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Enter your registered Email Id"
            textField.textColor = UIColor.black
        }
        let submit = UIAlertAction(title: "SUBMIT", style: .default, handler: { (action) -> Void in
            let emailId = alert.textFields![0]
            if emailId.text!.count > 0 {
                self.putForgotPasswordSubmitEmailAPICall(email: emailId.text!)
            }
        })
        let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        alert.addAction(submit)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clickBtnSignUp(_ sender: Any) {
        performSegue(withIdentifier: "toSignUpFromLogin", sender: self)
    }
    
    func SetupUIElements() {
        txtEmailPhone.setBottomBorder()
        txtPassword.setBottomBorder()
        btnLogin.roundAllCorners(radius: btnLogin.frame.height/2)
        btnLogin.setBorderWidthAndColor(width: 1.5, color: UIColor(hex: "4464C3").cgColor)
        if hideLoginOptions {
            btnsignUp.isHidden = true
            lblNewUser.isHidden = true
            btnClose.isHidden = false
        }
    }
    
    func postLoginAPICall(emailPhone: String, password: String) {
        showActivityIndicator()
        let url = baseUrl+"login"
        let parameters: Parameters = [
            "email": emailPhone,
            "password": password,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseLoginResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseLoginResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                UserDefaults.standard.set(txtEmailPhone.text!, forKey: "userEmailId")
                let userid = jsonOutput["userId"] as! String
                UserDefaults.standard.set(userid, forKey: "userId")
                getUserAppInfoFromLocalDB()
                DatabaseManager.shared.createAllTablesForUser(userid: userid)
                performSegue(withIdentifier: "toHomeTabControllerFromLogin", sender: self)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    func putForgotPasswordSubmitEmailAPICall(email: String) {
        showActivityIndicator()
        let url = baseUrl+"forgot_password_send_otp"
        forgotPasswordEmailId = email
        let parameters: Parameters = [
            "value": email,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseForgotPasswordSubmitEmailResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseForgotPasswordSubmitEmailResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Enter OTP",
                                                  message: "Enter OTP sent to your Registered Emaid Id ",
                                                  preferredStyle: .alert)
                    alert.addTextField { (textField: UITextField) in
                        textField.keyboardAppearance = .default
                        textField.keyboardType = .default
                        textField.autocorrectionType = .default
                        textField.placeholder = ""
                        textField.textColor = UIColor.black
                    }
                    let submit = UIAlertAction(title: "SUBMIT", style: .default, handler: { (action) -> Void in
                        let otp = alert.textFields![0]
                        if otp.text!.count > 0 {
                            self.getVerifyOTPForForgotPasswordAPICall(otp: otp.text!)
                        }
                    })
                    let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: { (action) -> Void in })
                    alert.addAction(cancel)
                    alert.addAction(submit)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                showAlert(title: "Error", message: "Please Enter Registered Email Id")
            }
        }
        catch {
            print(error)
        }
    }
    
    func getVerifyOTPForForgotPasswordAPICall(otp:String) {
        showActivityIndicator()
        let url = baseUrl+"forgot_password_verify?value=\(forgotPasswordEmailId)&otp_code=\(otp)"
        Alamofire.request(url, method: HTTPMethod.get , parameters: nil, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseVerifyOTPForForgotPasswordResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseVerifyOTPForForgotPasswordResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                performSegue(withIdentifier: "toResetPasswordFromLogin", sender: self)
            } else {
                showAlert(title: "Error", message: "Wrong OTP")
            }
        }
        catch {
            print(error)
        }
    }
    
    
    //    func parseTrollyData(JSONData: Data) {
    //        let jsonDecoder = JSONDecoder()
    //        trolly = try! jsonDecoder.decode(Array<Trolly>.self,
    //                                         from: JSONData)
    //        DispatchQueue.main.async {
    //            self.myControlUnitsTableView.reloadData()
    //        }
    //    }
    
    func LoginWithLocalDatabse() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetails")
        request.predicate = NSPredicate(format: "emailId = %@", txtEmailPhone.text!)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            let data = result as! [NSManagedObject]
            if data.count > 0 {
                let securedPassword:String = data[0].value(forKey: "securedPassword") as! String
                let userEmailId:String = data[0].value(forKey: "emailId") as! String
                let userId:String = data[0].value(forKey: "id") as! String
                let password:String = try SecurityManager.decryptMessage(encryptedMessage: securedPassword, encryptionKey: txtEmailPhone.text!)
                if password == txtPassword.text! && userEmailId == txtEmailPhone.text! {
                    UserDefaults.standard.set(userEmailId, forKey: "userEmailId")
                    UserDefaults.standard.set(userId, forKey: "userId")
                    getUserAppInfoFromLocalDB()
                    DatabaseManager.shared.createAllTablesForUser(userid: userId)
                    performSegue(withIdentifier: "toHomeTabControllerFromLogin", sender: self)
                } else {
                    showAlert(title: "Error", message: "Wrong Username and Password")
                }
            } else {
                showAlert(title: "Error", message: "User Not Found.\nPlease connect to internet and Login in Online mode")
            }
        } catch {
            print("Failed")
        }
    }
    
    func getUserAppInfoFromLocalDB() {
        let userId:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetails")
        request.predicate = NSPredicate(format: "id = %@", userId)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            let data = result as! [NSManagedObject]
            if data.count > 0 {
                let appmode:String = data[0].value(forKey: "appMode") as? String ?? ""
                let offlinesmslimit:Int32 = data[0].value(forKey: "offlineSMSLimit") as? Int32 ?? 0
                let offlinecontactlimit:Int32 = data[0].value(forKey: "offlineContactsLimit") as? Int32 ?? 0
                let countryCode:String = data[0].value(forKey: "countryCode") as? String ?? "0"
                UserDefaults.standard.set(appmode, forKey: "appMode")
                UserDefaults.standard.set(offlinesmslimit, forKey: "offlineSMSLimit")
                UserDefaults.standard.set(offlinecontactlimit, forKey: "offlineContactsLimit")
                UserDefaults.standard.set(countryCode, forKey: "userCountryCode")
                appDelegate.UpdateAppSettingsVariables()
            } else {
                getUserProfileDetailsAPICallAndAddToLocalDB()
            }
        } catch {
            print("Failed")
        }
    }
    
    func getUserProfileDetailsAPICallAndAddToLocalDB() {
        let userId:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"get_user_profile?userId=\(userId)"
        Alamofire.request(url, method: HTTPMethod.get , parameters: nil, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseUserProfileDetailsResponseData(JSONData: response.data!)
            }

        }
    }
    
    func parseUserProfileDetailsResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let user = jsonOutput["user_profile"] as! [String:Any]
                do {
                    let password = try SecurityManager.encryptMessage(message: txtPassword.text!, encryptionKey: txtEmailPhone.text!)
                    let emailId:String = UserDefaults.standard.value(forKey: "userEmailId") as? String ?? ""
                    let userId:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName: "UserDetails", in: context)
                    let newUser = NSManagedObject(entity: entity!, insertInto: context)
                    newUser.setValue(user["name"] as? String, forKey: "name")
                    newUser.setValue(txtEmailPhone.text!, forKey: "emailId")
                    newUser.setValue(user["mobile"] as? String ?? "", forKey: "phoneNumber")
                    newUser.setValue(user["country_code"] as? String ?? "0", forKey: "countryCode")
                    newUser.setValue(password, forKey: "securedPassword")
                    newUser.setValue(userId, forKey: "id")
                    newUser.setValue(Date(), forKey: "lastUpdatedPasswordTimestamp")
                    newUser.setValue(user["userAppMode"] as? String ?? "Hybrid", forKey: "appMode")
                    newUser.setValue(user["userOfflineSMSLimit"] as? Int ?? 100, forKey: "offlineSMSLimit")
                    newUser.setValue(user["userOfflineContactLimit"] as? Int ?? 1000, forKey: "offlineContactsLimit")
                    try context.save()
                    UserDefaults.standard.set(user["userAppMode"] as? String ?? "", forKey: "appMode")
                    UserDefaults.standard.set(user["userOfflineSMSLimit"] as? String ?? "", forKey: "offlineSMSLimit")
                    UserDefaults.standard.set(user["userOfflineContactLimit"] as? String ?? "", forKey: "offlineContactsLimit")
                    UserDefaults.standard.set(user["country_code"] as? String ?? "", forKey: "userCountryCode")
                    appMode = UserDefaults.standard.value(forKey: "appMode") as? String ?? "Hybrid"
                    offlineSmsLimit = UserDefaults.standard.value(forKey: "offlineSMSLimit") as? Int ?? 100
                    offlineContactsLimit = UserDefaults.standard.value(forKey: "offlineContactsLimit") as? Int ?? 1000
                    userCountryCode = UserDefaults.standard.value(forKey: "userCountryCode") as? String ?? "0"
                    print("Not working")
                } catch {
                    print(error)
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResetPasswordFromLogin" {
            let destViewController: ResetPasswordVC = segue.destination as! ResetPasswordVC
            destViewController.emailId = forgotPasswordEmailId
        } else if segue.identifier == "toSignUpFromLogin" {
            let destViewController: SignUpVC = segue.destination as! SignUpVC
            destViewController.hideLoginOptions = true
        }
    }
    
    
}

