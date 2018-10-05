//
//  SignUpVC.swift
//  Reter
//
//  Created by apple on 1/15/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import UIDropDown

class SignUpVC: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmailId: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var dropDownCountry: UIDropDown!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var lblHaveAccount: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    var hideLoginOptions:Bool = false
    var countryCodeList:[Country] = []
    var selectedCountry: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpUIElements()
       // getCountryCodesAPICall()
        addCountryOffline()
    }
    
    
    @IBAction func clickBtnSignUp(_ sender: Any) {
        
        if !txtName.isValidName() {
            showAlert(title: "Alert", message: "Invalid Name")
        } else if !txtEmailId.isValidEmail() {
            showAlert(title: "Alert", message: "Invalid Email")
        } else if selectedCountry == nil {
            showAlert(title: "Alert", message: "Please select the country code")
        } else if !txtMobileNumber.isValidPhoneNumber() {
            showAlert(title: "Alert", message: "Invalid Phone Number")
        } else if !txtPassword.isValidPassword() {
            showAlert(title: "Alert", message: "Password Should be minimum 8 Characters")
        } else {
            if isDeviceOnline {
            //  postSignUpAPICall()
                SignUpUsingLocalDatabase()
            } else {
                SignUpUsingLocalDatabase()
            }
        }
    }
    
    @IBAction func clickBtnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickBtnLogin(_ sender: Any) {
        performSegue(withIdentifier: "toLoginFromSignUp", sender: self)
    }
    
    func SetUpUIElements() {
        txtName.setBottomBorder()
        txtEmailId.setBottomBorder()
        txtMobileNumber.setBottomBorder()
        txtPassword.setBottomBorder()
        btnSignup.roundAllCorners(radius: btnSignup.frame.height/2)
        btnSignup.setBorderWidthAndColor(width: 1.5, color: UIColor(hex: "4464C3").cgColor)
        if hideLoginOptions {
            btnLogin.isHidden = true
            lblHaveAccount.isHidden = true
            btnClose.isHidden = false
        }
    }
    
    func SignUpUsingLocalDatabase() {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        let userID = "\(year)\(month)\(day)\(hour)\(min)\(sec)"
        UserDefaults.standard.set(txtEmailId.text!, forKey: "userEmailId")
        UserDefaults.standard.set(userID, forKey: "userId")
        DatabaseManager.shared.createAllTablesForUser(userid: userID)
        self.saveSignUpLocalDatabse()
        performSegue(withIdentifier: "toPhoneVerificationFromSignUp", sender: self)
        
    }
    
    
    func saveSignUpLocalDatabse() {
        do {
            let password = try SecurityManager.encryptMessage(message: txtPassword.text!, encryptionKey: txtEmailId.text!)
            let emailId:String = UserDefaults.standard.value(forKey: "userEmailId") as? String ?? ""
            let userId:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "UserDetails", in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            newUser.setValue(txtName.text!, forKey: "name")
            newUser.setValue(txtEmailId.text!, forKey: "emailId")
            newUser.setValue(txtMobileNumber.text!, forKey: "phoneNumber")
            newUser.setValue(selectedCountry?.countryCode, forKey: "countryCode")
            newUser.setValue(password, forKey: "securedPassword")
            newUser.setValue(userId, forKey: "id")
            newUser.setValue(Date(), forKey: "lastUpdatedPasswordTimestamp")
            newUser.setValue("Offline", forKey: "appMode")
            newUser.setValue(1000, forKey: "offlineSMSLimit")
            newUser.setValue(10000, forKey: "offlineContactsLimit")
            try context.save()
            getUserAppInfoFromLocalDB()
            performSegue(withIdentifier: "toPhoneVerificationFromSignUp", sender: self)
        } catch {
            print(error)
        }
    }
    
    func postSignUpAPICall() {
        showActivityIndicator()
        let url = baseUrl+"register"
        let parameters: Parameters = [
            "email": txtEmailId.text!,
            "password": txtPassword.text!,
            "name" : txtName.text!,
            "mobile" : txtMobileNumber.text!,
            "country_code" : selectedCountry!.countryCode,
            "userAppMode": "Offline",
            "userOfflineSMSLimit": 1000,
            "userOfflineContactLimit": 10000,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseSignUpResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseSignUpResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let userid = jsonOutput["userId"] as! String
                UserDefaults.standard.set(txtEmailId.text!, forKey: "userEmailId")
                UserDefaults.standard.set(userid, forKey: "userId")
                DatabaseManager.shared.createAllTablesForUser(userid: userid)
                self.saveSignUpLocalDatabse()
                performSegue(withIdentifier: "toPhoneVerificationFromSignUp", sender: self)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
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
                let appmode:String = data[0].value(forKey: "appMode") as? String ?? "Hybrid"
                let offlinesmslimit:Int32 = data[0].value(forKey: "offlineSMSLimit") as? Int32 ?? 100
                let offlinecontactlimit:Int32 = data[0].value(forKey: "offlineContactsLimit") as? Int32 ?? 1000
                let countryCode:String = data[0].value(forKey: "countryCode") as? String ?? "0"
                UserDefaults.standard.set(appmode, forKey: "appMode")
                UserDefaults.standard.set(offlinesmslimit, forKey: "offlineSMSLimit")
                UserDefaults.standard.set(offlinecontactlimit, forKey: "offlineContactsLimit")
                UserDefaults.standard.set(countryCode, forKey: "userCountryCode")
                appDelegate.UpdateAppSettingsVariables()
            }
        } catch {
            print("Failed")
        }
    }
    
    
    func getCountryCodesAPICall() {
        showActivityIndicator()
        let url = baseUrl+"get_countries_list"
        let parameters: Parameters = [:]
        Alamofire.request(url, method: HTTPMethod.get , parameters: parameters, encoding: URLEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseCountryCodesResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseCountryCodesResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [[String: Any]]
                let countryCodesArray = jsonOutput
                countryCodeList.removeAll()
                for country in countryCodesArray {
                    let countryValue:Country = Country(countryId: country["code"] as? String ?? "", countryName: country["name"] as? String ?? "", countryCode: country["dial_code"] as? String ?? "", countryStatus: true)
                    countryCodeList.append(countryValue)
                }
                DatabaseManager.shared.addNewCountriesArray(addingCountryArray: countryCodeList)
                setUpContryDropDown()
        }
        catch {
            print(error)
        }
    }
    
    func addCountryOffline() {
        if let path = Bundle.main.path(forResource: "countriesCode", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                self.parseCountryCodesResponseData(JSONData: data)
            } catch {
            }
        }
    }
    
    func setUpContryDropDown() {
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
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLoginFromSignUp" {
            let destViewController: LoginVC = segue.destination as! LoginVC
            destViewController.hideLoginOptions = true
        }
    }
    
}
