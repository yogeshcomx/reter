//
//  OffersVC.swift
//  Reter
//
//  Created by apple on 3/2/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire

class OffersVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    
    var offerList: [Offer] = []
    var offerOption:ViewControllerScreenOptions = .Add
    var offerToBeEdit:Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    @IBAction func clickedBtnAdd(_ sender: Any) {
        offerOption = .Add
        performSegue(withIdentifier: "toCreateOfferFromOffers", sender: self)
    }
    
    func loadData() {
        offerList.removeAll()
        if appMode == "Offline" {
            getOffersFromLocalDatabase()
        } else if appMode == "Online" {
            if isDeviceOnline {
                getOffersAPICall()
            } else {
                showAlert(title: "No Internet", message: "Check your internet connection and try again")
            }
        } else {
            if isDeviceOnline {
                getOffersAPICall()
            } else {
                getOffersFromLocalDatabase()
            }
        }
        tableview.reloadData()
    }
    
    func SetupUIElements() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "TemplatesTableCell", bundle: Bundle.main), forCellReuseIdentifier: "templateCell")
        tableview.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func getOffersAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"get_offer_list"
        let parameters: Parameters = [
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseGetOffersResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseGetOffersResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
            if jsonOutput["status"] as! Int == 1 {
                let offersArray = jsonOutput["off_list"] as? [[String:Any]] ?? []
                offerList.removeAll()
                for off in offersArray {
                    let offer:Offer = Offer(offerId: off["id"] as? String ?? "", offerName: off["offerName"] as? String ?? "", offerDescription: off["offerDescription"] as? String ?? "", lastUpdateDate: "", addedByUser: userid, Status: off["status"] as? Bool ?? true)
                    offerList.append(offer)
                }
                tableview.reloadData()
            } else {
                if jsonOutput["err_msg"] as? String != " Ops ! error occurred no data found" {
                    showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
                }
            }
            self.hideActivityIndicator()
        }
        catch {
            self.hideActivityIndicator()
            print(error)
        }
    }
    
    func DeleteOfferAPICall(offerId:String) {
        showActivityIndicator()
        let url = baseUrl+"delete_offer"
        let parameters: Parameters = [
            "id": offerId,
            ]
        Alamofire.request(url, method: HTTPMethod.delete , parameters: parameters, encoding: URLEncoding.httpBody , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseDeleteOfferResponseData(JSONData: response.data!, offerID: offerId)
            }
            self.loadData()
            self.hideActivityIndicator()
        }
    }
    
    func parseDeleteOfferResponseData(JSONData: Data, offerID:String) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
            }
            self.hideActivityIndicator()
        }
        catch {
            self.hideActivityIndicator()
            print(error)
        }
    }
    
    func getOffersFromLocalDatabase() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        offerList.removeAll()
        offerList = DatabaseManager.shared.getOffersOfUserId(userid: userid)
        tableview.reloadData()
        self.hideActivityIndicator()
    }
    
    func DeleteOfferFromLocalDaatabase(offerid:String, delTOffer: Offer?) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        DatabaseManager.shared.deleteOfferWithOfferId(userid: userid, deletingOfferId: offerid, deletingOffer: delTOffer)
        self.hideActivityIndicator()
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateOfferFromOffers" {
            let destVC:CreateOfferVC = segue.destination as! CreateOfferVC
            destVC.offerPurpose = offerOption
            destVC.editOffer = offerToBeEdit
        }
    }
}

extension OffersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.offerList.count == 0 {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableview.bounds.size.width, height: tableview.bounds.size.height))
            noDataLabel.text          = "No Offers available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableview.backgroundView  = noDataLabel
            tableview.separatorStyle  = .none
        } else {
            tableview.backgroundView = nil
        }
        return offerList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 90
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell", for: indexPath as IndexPath) as! TemplatesTableCell
        cell.selectionStyle = .none
        cell.viewOutline.setBorderWidthAndColor(width: 1.5, color: UIColor(hex: "4464C3").cgColor)
        cell.viewOutline.roundAllCorners(radius: 5.0)
        cell.lblTemplateName.text = offerList[indexPath.row].offerName
        cell.lblTemplateDescription.text = offerList[indexPath.row].offerDescription
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        offerOption = .View
        offerToBeEdit = offerList[indexPath.row]
        performSegue(withIdentifier: "toCreateOfferFromOffers", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            if self.offerList[indexPath.row].offerId != "" && isDeviceOnline {
               self.DeleteOfferAPICall(offerId: self.offerList[indexPath.row].offerId)
            }
            self.DeleteOfferFromLocalDaatabase(offerid: self.offerList[indexPath.row].offerId, delTOffer: self.offerList[indexPath.row] )
        }
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.offerOption = .Edit
            self.offerToBeEdit = self.offerList[indexPath.row]
            self.performSegue(withIdentifier: "toCreateOfferFromOffers", sender: self)
        }
        delete.backgroundColor = UIColor.lightGray
        edit.backgroundColor = UIColor.darkGray
        return [edit, delete]
    }
}
