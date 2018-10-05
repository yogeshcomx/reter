//
//  SelectTemplatesVC.swift
//  Reter
//
//  Created by apple on 2/22/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire

protocol TemplatesSelection {
    func selectionDone(selectedTemplate: Template)
}

class SelectTemplatesVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var templateList:[Template] = []
    var selectedTemplate:Template?
    var delegate: TemplatesSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        loadData()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }

    @IBAction func clickedBtnDone(_ sender: Any) {
        if let temp = selectedTemplate {
            delegate?.selectionDone(selectedTemplate: temp)
            self.navigationController?.popViewController(animated: true)
        } else {
            showAlert(title: "Error", message: "Please select the Template")
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
            getTemplatesFromLocalDatabase()
        } else if appMode == "Online" {
            if isDeviceOnline {
                getTemplatesAPICall()
            } else {
                showAlert(title: "No Internet", message: "Check your internet connection and try again")
            }
        } else {
            if isDeviceOnline {
                getTemplatesAPICall()
            } else {
                getTemplatesFromLocalDatabase()
            }
        }
    }
    
    
    func getTemplatesFromLocalDatabase() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        templateList.removeAll()
        showActivityIndicator()
        templateList = DatabaseManager.shared.getTemplatesOfUserId(userid: userid)
        self.tableview.reloadData()
        hideActivityIndicator()
    }
    
    func getTemplatesAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"get_template_list"
        let parameters: Parameters = [
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseGetTemplatesResponseData(JSONData: response.data!)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseGetTemplatesResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
            if jsonOutput["status"] as! Int == 1 {
                let templatesArray = jsonOutput["temp_list"] as? [[String:Any]] ?? []
                templateList.removeAll()
                for temp in templatesArray {
                    let template:Template = Template(templateId: temp["id"] as? String ?? "", templateName: temp["templateName"] as? String ?? "", templateDescription: temp["templateDescription"] as? String ?? "", lastUpdateDate: "", addedByUser: userid, Status: temp["id"] as? Bool ?? true)
                    templateList.append(template)
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

extension SelectTemplatesVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templateList.count
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
        cell.lblTemplateName.text = templateList[indexPath.row].templateName
        cell.lblTemplateDescription.text = templateList[indexPath.row].templateDescription
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTemplate = templateList[indexPath.row]
    }
    
}
