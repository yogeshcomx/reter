//
//  ContactsVC.swift
//  Reter
//
//  Created by apple on 1/17/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class ContactsVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var btnAddContact: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    var contactList: [Contact] = []
    var contactOption:ViewControllerScreenOptions = .Add
    var contactToBeEdit:Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        loadData() 
    }
    
    @IBAction func clickBtnAddContact(_ sender: Any) {
        contactOption = .Add
        performSegue(withIdentifier: "toCreateContactFromContacts", sender: self)
    }
    
    func SetupUIElements() {
        btnAddContact.roundAllCorners(radius: 25.0)
        tableview.register(UINib(nibName: "ContactsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "contactCell")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
        tableview.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshContactsData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshContactsData(_ sender: Any) {
        loadData()
    }
    
    func loadData() {
        contactList.removeAll()
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
            self.refreshControl.endRefreshing()
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
                    let cont:Contact = Contact(contactId: contact["id"] as? String ?? "", name: contact["contactName"] as? String ?? "", countryCode: contact["country_code"] as? String ?? "" , phone: contact["contactNumber"] as? String ?? "", email: contact["contactEmail"] as? String ?? "", imageData: nil , lastUpdateDate: "", addedByUser: contact["userId"] as? String ?? "", isActive: contact["status"] as? Bool ?? true, isSelected: false )
                    contactList.append(cont)
                    print("contID: \(cont.contactId)")
                }
            } else {
                if jsonOutput["err_msg"] as? String != " Ops ! error occurred no data found" {
                    showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
                }
            }
        }
        catch {
            print(error)
        }
        tableview.reloadData()
    }
    
    
    func getContactsFromLocalDatabase() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        contactList.removeAll()
        showActivityIndicator()
        contactList = DatabaseManager.shared.getContactsOfUserId(userid: userid)
        self.tableview.reloadData()
        refreshControl.endRefreshing()
        hideActivityIndicator()
    }
    
    
    func DeleteContactAPICall(contactId:String) {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"delete_contact"
        let parameters: Parameters = [
            "id": contactId,
            "userId" : userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseDeleteContactResponseData(JSONData: response.data!, contID:contactId)
            }
            self.loadData()
            self.hideActivityIndicator()
        }
    }
    
    func parseDeleteContactResponseData(JSONData: Data, contID:String) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                DeleteContactFromLocalDaatabase(contid:contID, cont: nil)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
            }
        }
        catch {
            print(error)
        }
    }
    
    func DeleteContactFromLocalDaatabase(contid:String, cont:Contact?) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        DatabaseManager.shared.deleteContactWithContactId(userid: userid, deletingContactId: contid, deletingContact: cont)
        DispatchQueue.main.async {
            self.getContactsFromLocalDatabase()
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateContactFromContacts" {
            let destVC:CreateContactVC = segue.destination as! CreateContactVC
            destVC.contactPurpose = contactOption
            destVC.editContact = contactToBeEdit
        }
    }
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.contactList.count == 0 {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableview.bounds.size.width, height: tableview.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableview.backgroundView  = noDataLabel
            tableview.separatorStyle  = .none
        } else {
            tableview.backgroundView = nil
        }
        return self.contactList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath as IndexPath) as! ContactsTableCell
        cell.selectionStyle = .none
        cell.imgProfile.layer.cornerRadius = 30.0
        cell.imgProfile.layer.masksToBounds =  true
        cell.imgProfile.layer.borderWidth = 2.0
        cell.imgProfile.layer.borderColor = UIColor(hex: "4464C3").withAlphaComponent(0.65).cgColor
        cell.lblName.text = contactList[indexPath.row].name
        cell.lblPhoneNumber.text = contactList[indexPath.row].phone
        cell.lblEmailId.text = contactList[indexPath.row].email!
        if let imgData = contactList[indexPath.row].imageData {
            cell.imgProfile.image = imgData.convertToUIImage()
        } else {
            cell.imgProfile.image = UIImage(named:"defaultProfile")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.contactOption = .View
        self.contactToBeEdit = self.contactList[indexPath.row]
        self.performSegue(withIdentifier: "toCreateContactFromContacts", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if self.contactList[indexPath.row].contactId != "" && isDeviceOnline {
                self.DeleteContactAPICall(contactId: self.contactList[indexPath.row].contactId)
            }
            self.DeleteContactFromLocalDaatabase(contid: self.contactList[indexPath.row].contactId, cont: self.contactList[indexPath.row])
            
        }
        
        let share = UITableViewRowAction(style: .destructive, title: "Edit") { (action, indexPath) in
            self.contactOption = .Edit
            self.contactToBeEdit = self.contactList[indexPath.row]
            self.performSegue(withIdentifier: "toCreateContactFromContacts", sender: self)
        }
        delete.backgroundColor = UIColor.darkGray
        share.backgroundColor = UIColor.lightGray
        return [delete, share]
        
    }
}
