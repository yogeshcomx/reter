//
//  MessagesVC.swift
//  Reter
//
//  Created by apple on 1/18/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

enum SegmentMessages: String {
    case Messages
    case Mails
}

class MessagesVC: UIViewController {
    
    @IBOutlet weak var btnCreateMessage: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var segmentControlMsgMail: UISegmentedControl!
    
    var isShowingSmsAndMailButton:Bool = false
    var offlineMessageList:[Message] = []
    var onlineMessageList:[Message] = []
    var mailsList: [Mail] = []
    var currentSelectedSegmentValue: SegmentMessages = .Messages
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        SetupUIElements()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMessageData()
        loadMailData()
    }
    
    func SetupUIElements() {
        btnCreateMessage.roundAllCorners(radius: 25.0)
        tableview.register(UINib(nibName: "MessagesTableCell", bundle: Bundle.main), forCellReuseIdentifier: "messageCell")
        tableview.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
        tableview.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshContactsData(_:)), for: .valueChanged)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        HideSendMailAndMessageButtonsWithAnimation()
    }
    
    @IBAction func clickSegmentMsgMail(_ sender: Any) {
        if segmentControlMsgMail.selectedSegmentIndex == 0 {
            currentSelectedSegmentValue = .Messages
        } else if segmentControlMsgMail.selectedSegmentIndex == 1 {
            currentSelectedSegmentValue = .Mails
        }
        tableview.reloadData()
    }
    
    @IBAction func clickBtnCreateMessage(_ sender: Any) {
        if !isShowingSmsAndMailButton {
            if isDeviceOnline {
                CreateSendMailAndMessageButtonsWithAnimation()
            } else {
                performSegue(withIdentifier: "toCreateMessageFromMessage", sender: self)
            }
        } else {
            HideSendMailAndMessageButtonsWithAnimation()
        }
       // performSegue(withIdentifier: "toCreateMessageFromMessage", sender: self)
        
    }
    
    @objc private func refreshContactsData(_ sender: Any) {
        loadMessageData()
    }
    
    func loadMessageData() {
        if appMode == "Offline" {
            currentSelectedSegmentValue = .Messages
            getMessagesFromLocalDatabase()
        } else if appMode == "Online" {
            currentSelectedSegmentValue = .Messages
            if isDeviceOnline {
                getMessagesAPICall()
            } else {
                showAlert(title: "No Internet", message: "Check your internet connection and try again")
            }
        } else {
            if isDeviceOnline {
                currentSelectedSegmentValue = .Messages
                getMessagesAPICall()
                getMessagesFromLocalDatabase()
            } else {
                currentSelectedSegmentValue = .Messages
                getMessagesFromLocalDatabase()
            }
        }
        
    }
    
    func loadMailData() {
        
    }
    
    func CreateSendMailAndMessageButtonsWithAnimation() {
        self.view.viewWithTag(101)?.removeFromSuperview()
        self.view.viewWithTag(102)?.removeFromSuperview()
        let mailButton = UIButton(frame: CGRect(x: btnCreateMessage.frame.origin.x, y: btnCreateMessage.frame.origin.y, width: 56, height: 56))
        mailButton.alpha = 0.0
        mailButton.setImage(UIImage(named:"createmail"), for: .normal)
        mailButton.imageView?.tintColor = UIColor(hex: "4464C3")
        mailButton.addTarget(self, action: #selector(mailButtonAction(sender:)), for: .touchUpInside)
        mailButton.tag = 101
        self.view.addSubview(mailButton)
        self.view.bringSubview(toFront: mailButton)
        
        
        let messageButton = UIButton(frame: CGRect(x: btnCreateMessage.frame.origin.x, y: btnCreateMessage.frame.origin.y, width: 62, height: 62))
        messageButton.alpha = 0.0
        messageButton.setImage(UIImage(named:"createsms"), for: .normal)
        messageButton.imageView?.tintColor = UIColor(hex: "4464C3")
        messageButton.addTarget(self, action: #selector(messageButtonAction(sender:)), for: .touchUpInside)
        messageButton.tag = 102
        self.view.addSubview(messageButton)
        self.view.bringSubview(toFront: messageButton)
        
        UIView.animate(withDuration: 0.15, animations: {
            mailButton.frame.origin.x = self.btnCreateMessage.frame.minX - 10
            mailButton.frame.origin.y = self.btnCreateMessage.frame.minY - 65
            mailButton.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, animations: {
            messageButton.frame.origin.x = self.btnCreateMessage.frame.minX - 20
            messageButton.frame.origin.y = self.btnCreateMessage.frame.minY - 137
            messageButton.alpha = 1.0
        }, completion: nil)
        isShowingSmsAndMailButton = true
        
    }
    
    func HideSendMailAndMessageButtonsWithAnimation() {
        let mailView = self.view.viewWithTag(101)
        let messageView = self.view.viewWithTag(102)
        UIView.animate(withDuration: 0.15, animations: {
            mailView?.frame.origin.x = self.btnCreateMessage.frame.origin.x
            mailView?.frame.origin.y = self.btnCreateMessage.frame.origin.y
            mailView?.frame.size.width = 40.0
            mailView?.frame.size.height = 40.0
            messageView?.frame.origin.y = self.btnCreateMessage.frame.origin.x
            messageView?.frame.origin.y = self.btnCreateMessage.frame.origin.y
            messageView?.frame.size.width = 40.0
            messageView?.frame.size.height = 40.0
        }, completion: {
            (value: Bool) in
            mailView?.removeFromSuperview()
            messageView?.removeFromSuperview()
        })
        
        isShowingSmsAndMailButton = false
    }
    
    @objc fileprivate func mailButtonAction(sender: UIButton) {
        performSegue(withIdentifier: "toCreateMailFromMessage", sender: self)
    }
    
    @objc fileprivate func messageButtonAction(sender: UIButton) {
        performSegue(withIdentifier: "toCreateMessageFromMessage", sender: self)
    }
    
    func getMessagesAPICall() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        showActivityIndicator()
        let url = baseUrl+"get_sent_message_list"
        let parameters: Parameters = [
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseGetMessagesResponseData(JSONData: response.data!)
            }
            self.refreshControl.endRefreshing()
            self.hideActivityIndicator()
        }
        
    }
    
    func parseGetMessagesResponseData(JSONData: Data) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let messagesArray = jsonOutput["off_list"] as? [[String:Any]] ?? []
                onlineMessageList.removeAll()
                for message in messagesArray {
                    let recipientsArray:[String] = (message["mobile"] as? String ?? "").components(separatedBy: ",")
                    let sentTimestamp:String = "\(message["sentDate"] as? String ?? "") \(message["senttime"] as? String ?? "")"
                    let msg:Message = Message(messageId: message["id"] as? String ?? "", recipients: recipientsArray, message: message["message"] as? String ?? "", sentTimestamp: sentTimestamp, sentByUsrID: message["userId"] as? String ?? "", isSelected: false)
                    onlineMessageList.append(msg)
                    print("msgID: \(msg.messageId)")
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
    
    func DeleteMessageAPICall(msgId:String) {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"delete_sent_message"
        let parameters: Parameters = [
            "id": msgId,
            "userId" : userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseDeleteMessageResponseData(JSONData: response.data!, msgID:msgId)
            }
            self.hideActivityIndicator()
        }
    }
    
    func parseDeleteMessageResponseData(JSONData: Data, msgID:String) {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                DeleteMessageFromDatabase(messageId:msgID, msg:nil)
            } else {
                showAlert(title: "Error", message: jsonOutput["err_msg"] as? String ?? "Something went wrong")
            }
        }
        catch {
            print(error)
        }
    }
    
    func getMessagesFromLocalDatabase() {
        offlineMessageList.removeAll()
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        offlineMessageList = DatabaseManager.shared.getMessagesOfUserId(userid: userid)
        tableview.reloadData()
        refreshControl.endRefreshing()
        hideActivityIndicator()
    }
    
    func DeleteMessageFromDatabase(messageId:String, msg:Message?) {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        DatabaseManager.shared.deleteMessageWithMessageId(userid: userid, deletingMessageId: messageId, deletingMessage: msg)
        hideActivityIndicator()
        getMessagesFromLocalDatabase()
    }
    
    func getMailsFromLocalDatabase() {
        mailsList.removeAll()
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        mailsList = DatabaseManager.shared.getMailssOfUserId(userid: userid)
        tableview.reloadData()
        refreshControl.endRefreshing()
        hideActivityIndicator()
    }
    
    func DeleteMailFromDatabase(mailID:String, mail:Mail?) {
        showActivityIndicator()
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        DatabaseManager.shared.deleteMailWithMailId(userid: userid, deletingMailId: mailID, deletingMail: mail)
        hideActivityIndicator()
        getMessagesFromLocalDatabase()
    }
    
  
    
}

extension MessagesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSelectedSegmentValue == .Mails {
            if self.mailsList.count == 0 {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableview.bounds.size.width, height: tableview.bounds.size.height))
                noDataLabel.text          = "No Mails available"
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableview.backgroundView  = noDataLabel
                tableview.separatorStyle  = .none
            }  else {
                tableview.backgroundView = nil
            }
            return self.mailsList.count
        } else {
            if self.offlineMessageList.count == 0 {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableview.bounds.size.width, height: tableview.bounds.size.height))
                noDataLabel.text          = "No Messages available"
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableview.backgroundView  = noDataLabel
                tableview.separatorStyle  = .none
            } else {
                tableview.backgroundView = nil
            }
            return self.offlineMessageList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 120
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath as IndexPath) as! MessagesTableCell
        cell.selectionStyle = .none
        cell.viewBorder.setBorderWidthAndColor(width: 1.5, color: UIColor(hex: "4464C3").cgColor)
        cell.viewBorder.roundAllCorners(radius: 5.0)
//        if currentSelectedSegmentValue == .Online {
//            cell.lblRecipients.text = "To: " + onlineMessageList[0].recipients.joined(separator: ",")
//            cell.lblMessage.text = onlineMessageList[indexPath.row].message
//            cell.lblSentTimestamp.text = onlineMessageList[indexPath.row].sentTimestamp
//        } else {
//            cell.lblRecipients.text = "To: " + offlineMessageList[0].recipients.joined(separator: ",")
//            cell.lblMessage.text = offlineMessageList[indexPath.row].message
//            cell.lblSentTimestamp.text = offlineMessageList[indexPath.row].sentTimestamp
//        }
            if currentSelectedSegmentValue == .Mails {
                cell.lblRecipients.text = "To: " + mailsList[0].recipients.joined(separator: ",")
                cell.lblMessage.text = "\(mailsList[indexPath.row].subject)\n \(mailsList[indexPath.row].message)"
                cell.lblSentTimestamp.text = mailsList[indexPath.row].sentTimestamp
            } else {
                cell.lblRecipients.text = "To: " + offlineMessageList[0].recipients.joined(separator: ",")
                cell.lblMessage.text = offlineMessageList[indexPath.row].message
                cell.lblSentTimestamp.text = offlineMessageList[indexPath.row].sentTimestamp
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
//        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
//            if self.currentSelectedSegmentValue == .Online {
//                if self.onlineMessageList[indexPath.row].messageId != "" && isDeviceOnline {
//                    self.DeleteMessageAPICall(msgId: self.onlineMessageList[indexPath.row].messageId)
//                }
//                self.DeleteMessageFromDatabase(messageId: self.onlineMessageList[indexPath.row].messageId, msg: self.onlineMessageList[indexPath.row])
//            } else if self.currentSelectedSegmentValue == .Offline {
//                if self.offlineMessageList[indexPath.row].messageId != "" && isDeviceOnline {
//                    self.DeleteMessageAPICall(msgId: self.offlineMessageList[indexPath.row].messageId)
//                }
//                self.DeleteMessageFromDatabase(messageId: self.offlineMessageList[indexPath.row].messageId, msg: self.offlineMessageList[indexPath.row])
//            }
//
//        }
        
                let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
                    if self.currentSelectedSegmentValue == .Messages {
                        self.DeleteMessageFromDatabase(messageId: self.offlineMessageList[indexPath.row].messageId, msg: self.offlineMessageList[indexPath.row])
                    } else if self.currentSelectedSegmentValue == .Mails {
                        self.DeleteMailFromDatabase(mailID: self.mailsList[indexPath.row].mailId, mail: self.mailsList[indexPath.row])
                    }
        
                }

        
        let forward = UITableViewRowAction(style: .default, title: "Forward") { (action, indexPath) in
        }
        delete.backgroundColor = UIColor.darkGray
        forward.backgroundColor = UIColor.lightGray
        
        return [delete, forward]
        
    }
}

