//
//  TemplatesVC.swift
//  Reter
//
//  Created by apple on 2/5/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class TemplatesVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    
    var templatesList: [Template] = []
    var templateOption:ViewControllerScreenOptions = .Add
    var templateToBeEdit:Template?

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    @IBAction func clickBtnAdd(_ sender: Any) {
        templateOption = .Add
        performSegue(withIdentifier: "toCreateTemplateFromTemplates", sender: self)
    }
    
    func loadData() {
        templatesList.removeAll()
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
    
    func SetupUIElements() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "TemplatesTableCell", bundle: Bundle.main), forCellReuseIdentifier: "templateCell")
        tableview.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
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
                templatesList.removeAll()
                for temp in templatesArray {
                    let template:Template = Template(templateId: temp["id"] as? String ?? "", templateName: temp["templateName"] as? String ?? "", templateDescription: temp["templateDescription"] as? String ?? "", lastUpdateDate: "", addedByUser: userid, Status: temp["status"] as? Bool ?? true)
                    templatesList.append(template)
                }
                tableview.reloadData()
            } else {
                if jsonOutput["err_msg"] as? String != " Ops ! error occurred no data found" {
                    showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    func DeleteTemplateAPICall(templateId:String) {
        showActivityIndicator()
        let url = baseUrl+"delete_template"
        let parameters: Parameters = [
            "id": templateId,
            ]
        Alamofire.request(url, method: HTTPMethod.delete , parameters: parameters, encoding: URLEncoding.httpBody , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseDeleteTemplateResponseData(JSONData: response.data!, templateID:templateId)
            }
            self.loadData()
            self.hideActivityIndicator()
        }
    }
    
    func parseDeleteTemplateResponseData(JSONData: Data, templateID:String) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
               // DeleteTemplateFromLocalDaatabase(templateid:templateID)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
            }
        }
        catch {
            print(error)
        }
    }
    
    func getTemplatesFromLocalDatabase() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        templatesList.removeAll()
        templatesList = DatabaseManager.shared.getTemplatesOfUserId(userid: userid)
        tableview.reloadData()
        hideActivityIndicator()
    }
    
    func DeleteTemplateFromLocalDaatabase(templateid:String, delTemplate: Template?) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        DatabaseManager.shared.deleteTemplateWithTemplateId(userid: userid, deletingTemplateId: templateid, deletingTemplate: delTemplate)
        hideActivityIndicator()
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateTemplateFromTemplates" {
            let destVC:CreateTemplateVC = segue.destination as! CreateTemplateVC
            destVC.templatePurpose = templateOption
            destVC.editTemplate = templateToBeEdit
        }
    }
}

extension TemplatesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.templatesList.count == 0 {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableview.bounds.size.width, height: tableview.bounds.size.height))
            noDataLabel.text          = "No Templates available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableview.backgroundView  = noDataLabel
            tableview.separatorStyle  = .none
        } else {
            tableview.backgroundView = nil
        }
        return templatesList.count
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
        cell.lblTemplateName.text = templatesList[indexPath.row].templateName
        cell.lblTemplateDescription.text = templatesList[indexPath.row].templateDescription
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        templateOption = .View
        templateToBeEdit = templatesList[indexPath.row]
        performSegue(withIdentifier: "toCreateTemplateFromTemplates", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            if self.templatesList[indexPath.row].templateId != "" && isDeviceOnline {
                self.DeleteTemplateAPICall(templateId: self.templatesList[indexPath.row].templateId)
            }
            self.DeleteTemplateFromLocalDaatabase(templateid: self.templatesList[indexPath.row].templateId, delTemplate: self.templatesList[indexPath.row] )
        }
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.templateOption = .Edit
            self.templateToBeEdit = self.templatesList[indexPath.row]
            self.performSegue(withIdentifier: "toCreateTemplateFromTemplates", sender: self)
        }
        delete.backgroundColor = UIColor.lightGray
        edit.backgroundColor = UIColor.darkGray
        return [edit, delete]
    }
}

