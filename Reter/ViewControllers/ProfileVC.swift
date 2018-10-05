//
//  ProfileVC.swift
//  Reter
//
//  Created by apple on 1/18/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmailId: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var txtCity: UITextField!
    
    var offerSectiontitles:[String] = ["Offers", "Templates"]
    var accountSectionTitles:[String] = ["Logout", "Delete"]
    
    
    let imagePicker: UIImagePickerController?=UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker?.delegate = self
        SetUpUIElements()
        if isDeviceOnline {
            getUserProfileDetailsAPICall()
            getUserDetailsFromLocalAndUpdate()
        } else {
            getUserDetailsFromLocalAndUpdate()
        }
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    
    @IBAction func clickBtnEdit(_ sender: Any) {
        imgProfilePic.isUserInteractionEnabled = true
        txtName.isUserInteractionEnabled = true
        txtCity.isUserInteractionEnabled = true
        let rightButtonItem = UIBarButtonItem.init(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(updateProfile(sender:))
        )
        rightButtonItem.setTitleTextAttributes( [NSAttributedStringKey.font : UIFont(name: "AvenirNext-Regular", size: 17) ,NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal) 
        self.navigationItem.rightBarButtonItem = rightButtonItem
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    
    func SetUpUIElements() {
        imgProfilePic.roundAllCorners(radius: imgProfilePic.frame.size.height/2)
        imgProfilePic.setBorderWidthAndColor(width: 2.5, color: UIColor(hex: "ffffff").withAlphaComponent(0.9).cgColor)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openPhotoLibrary(sender:)))
        tap.delegate = self
        imgProfilePic.addGestureRecognizer(tap)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @objc func updateProfile(sender: UIBarButtonItem) {
        imgProfilePic.isUserInteractionEnabled = false
        txtName.isUserInteractionEnabled = false
        txtCity.isUserInteractionEnabled = false
       UpdateUserDetailsAPICall()
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
                txtName.text = data[0].value(forKey: "name") as? String
                txtPhone.text = data[0].value(forKey: "phoneNumber") as? String
                txtEmailId.text = data[0].value(forKey: "emailId") as? String
                txtCity.text = data[0].value(forKey: "city") as? String
                if let imageData:Data = data[0].value(forKey: "profileImage") as? Data {
                    imgProfilePic.image = UIImage(data: imageData)
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    func updateUserDetailsToLocalDatabase() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        DispatchQueue.main.async {
            let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetails")
            request.predicate = NSPredicate(format: "id = %@", userid)
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                let data = result as! [NSManagedObject]
                if data.count > 0 {
                    let currentUser = data[0]
                        if let img = self.imgProfilePic.image {
                            if let data:Data = UIImagePNGRepresentation(img) {
                                currentUser.setValue(data, forKey: "profileImage")
                            } else if let data:Data = UIImageJPEGRepresentation(img, 1.0) {
                                currentUser.setValue(data, forKey: "profileImage")
                            }
                        }
                        currentUser.setValue(self.txtName.text!, forKey: "name")
                        currentUser.setValue(self.txtPhone.text!, forKey: "phoneNumber")
                        currentUser.setValue(self.txtCity.text!, forKey: "city")
                    try context.save()
                }
            } catch {
                print("Failed")
            }
        }
    }
    
    func getUserProfileDetailsAPICall() {
        showActivityIndicator()
        let userId:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"get_user_profile?userId=\(userId)"
        Alamofire.request(url, method: HTTPMethod.get , parameters: nil, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseUserProfileDetailsResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseUserProfileDetailsResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let user = jsonOutput["user_profile"] as! [String:Any]
                txtName.text = user["name"] as? String
                txtPhone.text = "\(user["country_code"] as? String ?? "") \(user["mobile"] as? String ?? "")"
                txtEmailId.text = user["email"] as? String
            }
        }
        catch {
            print(error)
        }
    }
    
    func UpdateUserDetailsAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"update_user_profile"
        let parameters: Parameters = [
            "name": txtName.text!,
            "mobile": txtPhone.text!,
            "address": "",
            "city" : txtCity.text!,
            "userId": userid,
            "userAppMode": UserDefaults.standard.value(forKey: "appMode") as? String ?? "",
            "userOfflineSMSLimit": UserDefaults.standard.value(forKey: "offlineSMSLimit") as? Int ?? 100,
            "userOfflineContactLimit": UserDefaults.standard.value(forKey: "offlineContactsLimit") as? Int ?? 1000,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: URLEncoding.httpBody, headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseUpdateUserDetailsResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseUpdateUserDetailsResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                print("profile updated")
                self.navigationItem.rightBarButtonItem = nil
                updateUserDetailsToLocalDatabase()
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    @objc func openTemplates(sender: UITapGestureRecognizer? = nil) {
        performSegue(withIdentifier: "toTemplatesFromProfile", sender: self)
    }
    
    @objc func openOffers(sender: UITapGestureRecognizer? = nil) {
        performSegue(withIdentifier: "toOffersFromProfile", sender: self)
    }
    
    
    @objc func openPhotoLibrary(sender: UITapGestureRecognizer? = nil) {
        imagePicker!.allowsEditing = true
        imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker!, animated: true, completion: nil)
    }
    
    func LogoutAccount() {
        let alert = UIAlertController(title: "Logout",
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .alert)
        let submit = UIAlertAction(title: "YES", style: .default, handler: { (action) -> Void in
            UserDefaults.standard.set("", forKey: "userEmailId")
            UserDefaults.standard.set("", forKey: "userId")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginController")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        })
        let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        alert.addAction(submit)
        present(alert, animated: true, completion: nil)
    }
    
    func DeleteAccount() {
        let alert = UIAlertController(title: "Delete",
                                      message: "Are you sure you want to delete the account?\nAll the Contacts, Messages and Templates will be deleted.",
                                      preferredStyle: .alert)
        let submit = UIAlertAction(title: "YES", style: .default, handler: { (action) -> Void in
            let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
            DatabaseManager.shared.deleteTablesOfUser(userid: userid)
            UserDefaults.standard.set("", forKey: "userEmailId")
            UserDefaults.standard.set("", forKey: "userId")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginController")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        })
        let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        alert.addAction(submit)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgProfilePic.contentMode = .scaleAspectFill
        imgProfilePic.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else if section == 1 {
            return "Account"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileTableCell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.lblTitle.text = offerSectiontitles[indexPath.row]
            let image:UIImage = (indexPath.row == 0 ? UIImage(named: "offers") : UIImage(named: "templates"))!
            cell.imgLogo.image = image
            cell.imgSecondary.image = UIImage(named:"rightArrow")
        } else if indexPath.section == 1 {
            cell.lblTitle.text = accountSectionTitles[indexPath.row]
            let image:UIImage = (indexPath.row == 0 ? UIImage(named: "exit") : UIImage(named: "delete"))!
            cell.imgLogo.image = image
            cell.imgSecondary.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.darkGray
        header.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            openOffers()
        } else if indexPath.section == 0 && indexPath.row == 1 {
            openTemplates()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            DispatchQueue.main.async {
                self.LogoutAccount()
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            DispatchQueue.main.async {
                self.DeleteAccount()
            }
        }
        
    }
    
}
