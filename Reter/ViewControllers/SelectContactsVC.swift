//
//  SelectContactsVC.swift
//  Reter
//
//  Created by apple on 1/23/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

protocol ContactsSelection {
    func selectionDone(selectedList:[Contact])
}

class SelectContactsVC: UIViewController {
    
    @IBOutlet weak var btnSelectAll: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    var contactList:[Contact] = []
    var selectedContactList:[Contact] = []
    var selectingForEmail:Bool = false
    var isSelectedAll:Bool = false
    var delegate: ContactsSelection?

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        loadData()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    
    }
    @IBAction func clickBtnSelectAll(_ sender: Any) {
        if isSelectedAll {
            for (index, value) in contactList.enumerated() {
                contactList[index].isSelected = false
            }
            isSelectedAll = false
            btnSelectAll.setImage(UIImage(named:"unchecked"), for: .normal)
            self.tableview.reloadData()
        } else {
            for (index, value) in contactList.enumerated() {
                contactList[index].isSelected = true
            }
            isSelectedAll = true
            btnSelectAll.setImage(UIImage(named:"checked"), for: .normal)
            self.tableview.reloadData()
        }
    }
    
    @IBAction func clickBtnDone(_ sender: Any) {
        if selectedContactList.count <= offlineSmsLimit {
            selectedContactList = contactList.filter({$0.isSelected == true})
            delegate?.selectionDone(selectedList: selectedContactList)
            self.navigationController?.popViewController(animated: true)
        } else {
            showAlert(title: "Error", message: "You cannot select more than \(offlineSmsLimit) contacts")
        }
    }
    
    func SetupUIElements() {
        tableview.register(UINib(nibName: "SelectContactsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "selectContactCell")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func loadData() {
        if appMode == "Offline" {
            getContactsFromLocalDatabase()
        } else if appMode == "Online" {
            if isDeviceOnline {
                getContactsAPICall()
            } else {
                showAlert(title: "No Internet", message: "Check your internet connection and try again")
            }
        } else {
            if isDeviceOnline {
                getContactsAPICall()
            } else {
                getContactsFromLocalDatabase()
            }
        }
    }
    
    func updateSelectedContactsToList() {
        for selCont in selectedContactList {
            if let index = contactList.index(where: { $0.phone == selCont.phone }) {
                if index < contactList.count {
                    contactList[index].isSelected = true
                }
            }
        }
        if selectedContactList.count == contactList.count {
            clickBtnSelectAll(btnSelectAll)
        }
        tableview.reloadData()
    }
    
    func getContactsFromLocalDatabase() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        contactList.removeAll()
        showActivityIndicator()
        contactList = DatabaseManager.shared.getContactsOfUserId(userid: userid)
        self.tableview.reloadData()
        updateSelectedContactsToList()
        hideActivityIndicator()
    }
    
    func getContactsAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"get_contact_list"
        let parameters: Parameters = [
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseGetContactsResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
        
    }
    
    func parseGetContactsResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let contactsArray = jsonOutput["cont_list"] as? [[String:Any]] ?? []
                contactList.removeAll()
                for contact in contactsArray {
                    let cont:Contact = Contact(contactId: contact["id"] as? String ?? "", name: contact["contactName"] as? String ?? "", countryCode: contact["country_code"] as? String ?? "", phone: contact["contactNumber"] as? String ?? "", email: contact["contactEmail"] as? String ?? "", imageData: nil , lastUpdateDate: "", addedByUser: contact["userId"] as? String ?? "", isActive: contact["status"] as? Bool ?? true, isSelected: false )
                    contactList.append(cont)
                    print("contID: \(cont.contactId)")
                }
                updateSelectedContactsToList()
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
            }
        }
        catch {
            print(error)
        }
        tableview.reloadData()
    }
    
}

extension SelectContactsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectContactCell", for: indexPath as IndexPath) as! SelectContactsTableCell
        cell.selectionStyle = .none
        cell.lblName.text = contactList[indexPath.row].name
        cell.lblPhone.text = contactList[indexPath.row].phone
        cell.lblEmail.text = contactList[indexPath.row].email
        if contactList[indexPath.row].isSelected {
            cell.btnSelect.setImage(UIImage(named:"checked"), for: .normal)
        } else {
            cell.btnSelect.setImage(UIImage(named:"unchecked"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:SelectContactsTableCell = tableView.cellForRow(at: indexPath) as! SelectContactsTableCell
        if contactList[indexPath.row].isSelected {
            cell.btnSelect.setImage(UIImage(named:"unchecked"), for: .normal)
            contactList[indexPath.row].isSelected = false
        } else {
            cell.btnSelect.setImage(UIImage(named:"checked"), for: .normal)
            contactList[indexPath.row].isSelected = true
        }
        tableview.beginUpdates()
        tableView.endUpdates()
    }
    
}
