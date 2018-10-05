//
//  ImportContactsFromPhoneVC.swift
//  Reter
//
//  Created by apple on 2/27/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import ContactsUI
import CSV
import Alamofire

class ImportContactsFromPhoneVC: UIViewController, CNContactPickerDelegate {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var btnSelectAll: UIButton!
    
    var contactsListFromPhone  = [CNContact]()
    var contactList: [Contact] = []
    var selectedContactList: [Contact] = []
    var isSelectedAll:Bool = false
    var isForImportPhoneContacts:Bool = false
    var selectedCSVFileUrl: URL?
    let myGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        loadData()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    @IBAction func clickedBtnAdd(_ sender: Any) {
        selectedContactList = contactList.filter({$0.isSelected == true})
        if selectedContactList.count > 0 {
           addImportedContacts()
        } else {
            showAlert(title: "Alert", message: "Please select contacts to add")
        }
        
    }
    
    @IBAction func clickedBtnSelectAll(_ sender: Any) {
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
    
    func SetupUIElements() {
        tableview.register(UINib(nibName: "SelectContactsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "selectContactCell")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func loadData() {
        if isForImportPhoneContacts {
            getContactsFromPhone()
        } else {
            getContactsFromCSVFile()
        }
    }
    
    func addImportedContacts() {
        if appMode == "Offline" {
            addContactsArrayToLocalData()
        } else if appMode == "Online" {
            if isDeviceOnline {
                addContactsArrayToServer()
            } else {
                showAlert(title: "No Internet", message: "Check your internet connection and try again")
            }
        } else {
            if isDeviceOnline {
                addContactsArrayToServer()
            } else {
                addContactsArrayToLocalData()
            }
        }
    }
    
    func getContactsFromCSVFile() {
        do {
            showActivityIndicator()
            var csvString:String = ""
            if selectedCSVFileUrl != nil {
                csvString = try String(contentsOf: selectedCSVFileUrl!, encoding: .utf8)
            }
            let csv = try! CSVReader(string: csvString,
                                     hasHeaderRow: true)
            let headerRow = csv.headerRow!
            print("\(headerRow)")
            let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
            while let row = csv.next() {
                let row:Contact = Contact(contactId: "", name: String(row[1]) ?? "", countryCode: String(row[2]) ?? "", phone: String(row[3]) ?? "", email: String(row[4]) ?? "", imageData: nil, lastUpdateDate: Date().convertToString(), addedByUser: userid, isActive: true, isSelected: false)
                contactList.append(row)
            }
            DispatchQueue.main.async {
                self.self.tableview.reloadData()
                self.hideActivityIndicator()
            }
        }
        catch {
            print(error)
            DispatchQueue.main.async {
                self.hideActivityIndicator()
            }
        }
    }
    
    func getContactsFromPhone() {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            self.retrieveContactsWithStore(store: store)
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                self.retrieveContactsWithStore(store: store)
            }
        default:
            print("Not handled")
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey,CNContactImageDataKey, CNContactEmailAddressesKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        var cnContacts = [CNContact]()
        do {
            try store.enumerateContacts(with: request){
                (contact, cursor) -> Void in
                if (!contact.phoneNumbers.isEmpty) {
                }
                if contact.isKeyAvailable(CNContactImageDataKey) {
                    if let contactImageData = contact.imageData {
                    }
                } else {
                    // No Image available
                }
                if (!contact.emailAddresses.isEmpty) {
                }
                cnContacts.append(contact)
                self.contactsListFromPhone = cnContacts
            }
        } catch let error {
            NSLog("Fetch contact error: \(error)")
        }
        
        NSLog(">>>> Contact list:")
        for contact in cnContacts {
            let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
            NSLog("\(fullName): \(contact.phoneNumbers.description)")
        }
        convertCNContactsFromPhoneToContactArray()
    }
    
    func convertCNContactsFromPhoneToContactArray() {
        contactList.removeAll()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        for contactPhone in contactsListFromPhone {
            let name = contactPhone.givenName
            let countryCode = userCountryCode
            var phoneNumber = ""
            if contactPhone.phoneNumbers.count > 0 {
                let phone = "\(contactPhone.phoneNumbers[0].value.stringValue)"
                phoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            }
            var email = ""
            if contactPhone.emailAddresses.count > 0 {
                email = contactPhone.emailAddresses[0].value as String
            }
            let contact:Contact = Contact(contactId: "", name: name, countryCode: countryCode, phone: phoneNumber, email: email as? String ?? "", imageData: nil, lastUpdateDate: Date().convertToString(), addedByUser: userid, isActive: true, isSelected: false)
            contactList.append(contact)
        }
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    
    func addContactsArrayToLocalData() {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        DatabaseManager.shared.addNewContactsArrayOfUserId(userid: userid, addingContactArray: selectedContactList)
        hideActivityIndicator()
    }
    
    func addContactsArrayToServer() {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        for cont in selectedContactList {
            self.myGroup.enter()
            let mySubGroup = DispatchGroup()
            mySubGroup.enter()
            let contactid = self.addContactToServer(contact: cont, group:mySubGroup)
            mySubGroup.notify(queue: .main) {
                if contactid != "" {
                  DatabaseManager.shared.addNewContactOfUserIdAndContactId(userid: userid, contid: contactid, addingContact: cont)
                }
                
            }
        }
        self.myGroup.notify(queue: .main) {
            if appMode == "Hybrid" {
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
             }
        else {
            self.hideActivityIndicator()
        }
        }
           
    }
    
    
    func addContactToServer(contact: Contact, group:DispatchGroup) -> String {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"add_contact"
        var savedcontactid:String = ""
        let parameters: Parameters = [
            "userId": userid,
            "contactName": contact.name,
            "contactNumber": contact.phone,
            "contactEmail": contact.email as? String ?? "" ,
            "country_code" : contact.countryCode,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                savedcontactid =  self.parseNewContactResponseData(JSONData: response.data!)
            }
            print("done")
            group.leave()
            self.myGroup.leave()
        }
        return savedcontactid
    }
    
    func parseNewContactResponseData(JSONData: Data) -> String {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let contId = jsonOutput["contactId"] as? String ?? ""
                return contId
            } else {
            }
        }
        catch {
            print(error)
        }
        return ""
    }
}

extension ImportContactsFromPhoneVC : UITableViewDelegate, UITableViewDataSource {
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
extension ImportContactsFromPhoneVC: SyncManagerProtocol {
    func syncDone(status: Bool) {
        hideActivityIndicator()
    }
}

