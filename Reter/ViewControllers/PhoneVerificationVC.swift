//
//  PhoneVerificationVC.swift
//  Reter
//
//  Created by apple on 8/10/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class PhoneVerificationVC: UIViewController {

    @IBOutlet weak var txtOtp: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnResend: UIButton!
    
    var phonenumber:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserDetailsFromLocalAndUpdate()
    }
    
   
    @IBAction func clickBtnSubmit(_ sender: Any) {
        verifyPhoneNumberOTPFromFirebase()
    }
    
    @IBAction func clickBtnResend(_ sender: Any) {
        let phone:String = ""
        getUserDetailsFromLocalAndUpdate()
    }
    
    func getUserDetailsFromLocalAndUpdate() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetails")
        request.predicate = NSPredicate(format: "id = %@", userid)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            let data = result as! [NSManagedObject]
            if data.count > 0 {
                let mobile = data[0].value(forKey: "phoneNumber") as? String
                let countrycode = data[0].value(forKey: "countryCode") as? String
                phonenumber = (countrycode ?? "") + (mobile ?? "")
                sendOTPFromFirebase(phoneNumber: phonenumber)
            }
        } catch {
            self.showAlert(title: "Error", message: "Not able to fetch phone number details")
        }
    }
    
    func sendOTPFromFirebase(phoneNumber:String) {
        showActivityIndicator()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            self.hideActivityIndicator()
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "firebaseAuthVerificationID")
        }
    }
    
    
    
    func verifyPhoneNumberOTPFromFirebase() {
        showActivityIndicator()
        let verificationID = UserDefaults.standard.string(forKey: "firebaseAuthVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID ?? "",
            verificationCode: txtOtp.text!)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                self.hideActivityIndicator()
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "toHomeTabControllerFromPhoneVerification", sender: self)
        }
    }

}
