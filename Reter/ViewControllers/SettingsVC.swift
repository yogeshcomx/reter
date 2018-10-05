//
//  SettingsVC.swift
//  Reter
//
//  Created by apple on 1/24/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class SettingsVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    var syncSectionTitles:[String] = ["Contacts", "Templates", "Offers"]
    var importContactsSectionTitles:[String] = ["From File", "From Phone Contacts"]
    var offlineSMS:Int = 0
    var offlineContacts:Int = 0
    var appmode:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView(frame: CGRect.zero)
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    func addSaveButton() {
        if navigationItem.rightBarButtonItem == nil {
            let rightButtonItem = UIBarButtonItem.init(
                title: "Save",
                style: .done,
                target: self,
                action: #selector(updateUserAppSettingsToLocalDB(sender:))
            )
            rightButtonItem.setTitleTextAttributes( [NSAttributedStringKey.font : UIFont(name: "AvenirNext-Regular", size: 17) ,NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
            self.navigationItem.rightBarButtonItem = rightButtonItem
            setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
        }
    }
    
    @objc func updateUserAppSettingsToLocalDB(sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.showActivityIndicator()
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
                currentUser.setValue(appmode, forKey: "appMode")
                currentUser.setValue(offlineContacts, forKey: "offlineContactsLimit")
                currentUser.setValue(offlineSMS, forKey: "offlineSMSLimit")
                try context.save()
                UserDefaults.standard.set(appmode, forKey: "appMode")
                UserDefaults.standard.set(offlineSMS, forKey: "offlineSMSLimit")
                UserDefaults.standard.set(offlineContacts, forKey: "offlineContactsLimit")
                self.navigationItem.rightBarButtonItem = nil
                if isDeviceOnline {
                    self.UpdateUserDetailsAPICallIfOnline(user: currentUser)
                } else {
                    hideActivityIndicator()
                }
                appDelegate.UpdateAppSettingsVariables()
            }
        } catch {
            print("Failed")
            hideActivityIndicator()
        }
    }
    
    func UpdateUserDetailsAPICallIfOnline(user:NSManagedObject) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"update_user_profile"
        let parameters: Parameters = [
            "name": user.value(forKey: "name") as? String ?? "",
            "mobile": user.value(forKey: "phoneNumber") as? String ?? "" ,
            "address": "",
            "city" : user.value(forKey: "city") as? String ?? "",
            "userId": userid,
            "userAppMode": UserDefaults.standard.value(forKey: "appMode") as? String ?? "",
            "userOfflineSMSLimit": UserDefaults.standard.value(forKey: "offlineSMSLimit") as? Int ?? 1000,
            "userOfflineContactLimit": UserDefaults.standard.value(forKey: "offlineContactsLimit") as? Int ?? 10000,
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
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as! String)
            }
        }
        catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImportContactsFromPhoneFromSettings" {
            let destVC:ImportContactsFromPhoneVC = segue.destination as! ImportContactsFromPhoneVC
            destVC.isForImportPhoneContacts = true
        }
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Sync With Cloud"
        } else if section == 1 {
            return "Import Contacts"
        } else if section == 2 {
            return "Application Settings"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 {
            return 60
        } else {
            return 90
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1 {
            let cell: SettingsTableCell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableCell
            cell.selectionStyle = .none
            if indexPath.section == 0 {
                cell.lblTitle.text = syncSectionTitles[indexPath.row]
                let image:UIImage = UIImage(named: "sync")!
                cell.img.image = image
            } else if indexPath.section == 1 {
                cell.lblTitle.text = importContactsSectionTitles[indexPath.row]
                let image:UIImage = UIImage(named: "import")!
                cell.img.image = image
            }
            return cell
        } else if indexPath.section == 2 && indexPath.row == 0 {
            let cell: SettingsAppModeTableCell = tableView.dequeueReusableCell(withIdentifier: "settingsAppModeCell", for: indexPath) as! SettingsAppModeTableCell
            cell.selectionStyle = .none
            cell.lblTitle.text = "App Mode"
            cell.delegate = self
            appmode = UserDefaults.standard.value(forKey: "appMode") as? String ?? ""
            if appmode == "Offline" {
                cell.segmentMode.selectedSegmentIndex = 0
                cell.lblValue.text = appmode
                
            } else if appmode == "Online" {
                cell.segmentMode.selectedSegmentIndex = 1
                cell.lblValue.text = appmode
            } else if appmode == "Hybrid" {
                cell.segmentMode.selectedSegmentIndex = 2
                cell.lblValue.text = appmode
            } else {
                cell.segmentMode.selectedSegmentIndex = 2
                cell.lblValue.text = "Hybrid"
            }
            return cell
        } else if indexPath.section == 2 && (indexPath.row == 1 || indexPath.row == 2){
            let cell: SettingsSliderTableCell = tableView.dequeueReusableCell(withIdentifier: "settingsSliderCell", for: indexPath) as! SettingsSliderTableCell
            cell.selectionStyle = .none
            if indexPath.row == 1 {
                cell.lblTitle.text = "Offline Contacts Limit"
                cell.delegate = self
                cell.sliderValue.tag = 1
                cell.sliderValue.maximumValue = 10000
                cell.sliderValue.minimumValue = 500
                offlineContacts = UserDefaults.standard.value(forKey: "offlineContactsLimit") as? Int ?? 10000
                cell.sliderValue.value = Float(offlineContacts)
                cell.lblValue.text = "\(offlineContacts)"
            } else if indexPath.row == 2 {
                cell.lblTitle.text = "Offline Messages Limit"
                cell.delegate = self
                cell.sliderValue.tag = 9
                cell.sliderValue.maximumValue = 1000
                cell.sliderValue.minimumValue = 50
                offlineSMS = UserDefaults.standard.value(forKey: "offlineSMSLimit") as? Int ?? 1000
                cell.sliderValue.value = Float(offlineSMS)
                cell.lblValue.text = "\(offlineSMS)"
            }
            return cell
        }
        let cell = UITableViewCell()
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
        if indexPath.section == 0 && indexPath.row == 0 && appMode == "Hybrid" {
            let sync = SyncManager()
            sync.delegate = self
            DispatchQueue.main.async {
                if isDeviceOnline {
                    self.showActivityIndicator()
                    sync.syncContacts()
                } else {
                    self.showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            }
        } else if indexPath.section == 0 && indexPath.row == 1 && appMode == "Hybrid" {
            let sync = SyncManager()
            sync.delegate = self
            DispatchQueue.main.async {
                if isDeviceOnline {
                    self.showActivityIndicator()
                    sync.syncTemplates()
                } else {
                    self.showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            }
        } else if indexPath.section == 0 && indexPath.row == 2 && appMode == "Hybrid" {
            let sync = SyncManager()
            sync.delegate = self
            DispatchQueue.main.async {
                if isDeviceOnline {
                    self.showActivityIndicator()
                    sync.syncOffers()
                } else {
                    self.showAlert(title: "No Internet", message: "Check your internet connection and try again")
                }
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
          performSegue(withIdentifier: "toSelectCSVFileFromPhoneFromSettings", sender: self)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            performSegue(withIdentifier: "toImportContactsFromPhoneFromSettings", sender: self)
        }
    }
    
    func showNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet",
                                      message: "Check your internet connection and try again",
                                      preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.openURL(url)
            }
        })
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        alert.addAction(settings)
        present(alert, animated: true, completion: nil)
    }
    
}

extension SettingsVC: SyncManagerProtocol {
    func syncDone(status: Bool) {
        hideActivityIndicator()
    }
}

extension SettingsVC: settingsappModeProtocol {
    func appModeChanged(value: String) {
        appmode = value
        addSaveButton()
    }
}

extension SettingsVC: settingsOfflineLimitProtocol {
    func offlineLimitChanged(tag: Int, value: Int) {
        if tag == 1 {
            offlineContacts = value
        } else if tag == 9 {
            offlineSMS = value
        }
        addSaveButton()
    }
}
