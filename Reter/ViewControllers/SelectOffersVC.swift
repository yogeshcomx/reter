//
//  SelectOffersVC.swift
//  Reter
//
//  Created by apple on 3/6/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire

protocol OffersSelection {
    func selectionDone(selectedOffer: Offer)
}

class SelectOffersVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var offerList:[Offer] = []
    var selectedOffer:Offer?
    var delegate: OffersSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        loadData()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }

    @IBAction func clickedBtnDone(_ sender: Any) {
        if let off = selectedOffer {
            delegate?.selectionDone(selectedOffer: off)
            self.navigationController?.popViewController(animated: true)
        } else {
            showAlert(title: "Error", message: "Please select the Offer")
        }
    }


    func SetupUIElements() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "TemplatesTableCell", bundle: Bundle.main), forCellReuseIdentifier: "templateCell")
        tableview.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func loadData() {
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
    }
    
    
    func getOffersFromLocalDatabase() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        offerList.removeAll()
        showActivityIndicator()
        offerList = DatabaseManager.shared.getOffersOfUserId(userid: userid)
        self.tableview.reloadData()
        hideActivityIndicator()
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
                showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
            }
        }
        catch {
            print(error)
        }
    }
}

extension SelectOffersVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 90
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell", for: indexPath as IndexPath) as! TemplatesTableCell
        cell.selectionStyle = .gray
        cell.viewOutline.setBorderWidthAndColor(width: 1.5, color: UIColor(hex: "4464C3").cgColor)
        cell.viewOutline.roundAllCorners(radius: 5.0)
        cell.lblTemplateName.text = offerList[indexPath.row].offerName
        cell.lblTemplateDescription.text = offerList[indexPath.row].offerDescription
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOffer = offerList[indexPath.row]
    }
    
}

