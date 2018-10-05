//
//  SyncManager.swift
//  Reter
//
//  Created by apple on 1/25/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire

protocol SyncManagerProtocol {
    func syncDone(status:Bool)
}

public class SyncManager {
    var LocalContacts:[Contact] = []
    var ServerContacts:[Contact] = []
    var LocalMessages:[Message] = []
    var ServerMessages:[Message] = []
    let myGroup = DispatchGroup()
    var delegate:SyncManagerProtocol?
    
    
    public func syncContacts() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let contactsAddToServer:[Contact] = DatabaseManager.shared.getContactsOfUserIdwhichDontHaveContactId(userid: userid)
        let contactsUpdateToServer:[Contact] = DatabaseManager.shared.getContactsOfUserIdWhichUpdatedLocallyAndNeedsServerUpdate(userid: userid)
        if contactsAddToServer.count == 0 && contactsUpdateToServer.count == 0 {
            DatabaseManager.shared.deleteAllContactsOfUserId(userid: userid)
            self.getContactsFromServerAndUpdateToLocal()
        }
        
        for cont in contactsAddToServer {
            self.myGroup.enter()
            let mySubGroup = DispatchGroup()
            mySubGroup.enter()
            let contactId = self.addContactToServer(contact: cont, group:mySubGroup)
            mySubGroup.notify(queue: .main) {
                DatabaseManager.shared.updateContactOfUserIdWithContactId(userid: userid, previousContactValue: cont, updatedContactId: contactId)
            }
        }
        
        for cont in contactsUpdateToServer {
            self.myGroup.enter()
            let mySubGroup = DispatchGroup()
            mySubGroup.enter()
            let contactId = self.UpdateContactToServer(contact: cont, group:mySubGroup)
            mySubGroup.notify(queue: .main) {
                DatabaseManager.shared.updateContactOfUserIdWithContactId(userid: userid, previousContactValue: cont, updatedContactId: contactId)
            }
        }
        
        self.myGroup.notify(queue: .main) {
            if contactsAddToServer.count != 0 || contactsUpdateToServer.count != 0{
                DatabaseManager.shared.deleteAllContactsOfUserId(userid: userid)
                self.getContactsFromServerAndUpdateToLocal()
            }
        }
    }
    
    
    func addContactToServer(contact: Contact, group:DispatchGroup) -> String {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"add_contact"
        var savedcontactid:String = ""
        let parameters: Parameters = [
            "userId": contact.addedByUser,
            "contactName": contact.name,
            "contactNumber": contact.phone,
            "contactEmail": contact.email,
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
    
    
    func UpdateContactToServer(contact: Contact, group:DispatchGroup) -> String {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"update_contact_details"
        var updatedcontactid:String = ""
        let parameters: Parameters = [
            "contId": contact.contactId,
            "contactName": contact.name,
            "contactNumber": contact.phone,
            "contactEmail" : contact.email ?? "",
            "country_code" : contact.countryCode,
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: URLEncoding.httpBody, headers: [:]).responseJSON { response in
            if response.data != nil {
               updatedcontactid = self.parseUpdateContactResponseData(JSONData: response.data!)
            }
            print("done")
            group.leave()
            self.myGroup.leave()
        }
        return updatedcontactid
    }
    
    func parseUpdateContactResponseData(JSONData: Data) -> String {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let contId = jsonOutput["contId"] as? String ?? ""
                return contId
            } else {
            }
        }
        catch {
            print(error)
        }
        return ""
    }
    
    func getContactsFromServerAndUpdateToLocal() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"get_contact_list"
        let parameters: Parameters = [
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseGetContactsResponseData(JSONData: response.data!)
            }
            self.delegate?.syncDone(status: true)
        }
    }
    
    func parseGetContactsResponseData(JSONData: Data) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let contactsArray = jsonOutput["cont_list"] as? [[String:Any]] ?? []
                var contactList: [Contact] = []
                for contact in contactsArray {
                    let cont:Contact = Contact(contactId: contact["id"] as? String ?? "", name: contact["contactName"] as? String ?? "", countryCode: contact["country_code"] as? String ?? "", phone: contact["contactNumber"] as? String ?? "", email: contact["contactEmail"] as? String ?? "", imageData: nil , lastUpdateDate: "", addedByUser: contact["userId"] as? String ?? "", isActive: contact["status"] as? Bool ?? true, isSelected: false )
                    contactList.append(cont)
                }
                DatabaseManager.shared.addNewContactsArrayOfUserId(userid: userid, addingContactArray: contactList)
            } else {
            }
        }
        catch {
            print(error)
        }
    }
    
    
    
//    public func syncMessages() {
//        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
//        let messagesAddToServer:[Message] = DatabaseManager.shared.getMessagesOfUserIdwhichDontHaveMessageId(userid: userid)
//        if messagesAddToServer.count == 0 {
//            DatabaseManager.shared.deleteAllMessagesOfUserId(userid: userid)
//            self.getMessageFromServerAndUpdateToLocal()
//        }
//
//        for msg in messagesAddToServer {
//            self.myGroup.enter()
//            let mySubGroup = DispatchGroup()
//            mySubGroup.enter()
//            let msgId = self.addMessageToServer(msg: msg, group:mySubGroup)
//            mySubGroup.notify(queue: .main) {
//                DatabaseManager.shared.updateMessageOfUserIdWithMessageId(userid: userid, previousMessageValue: msg, updatedMessageId: msgId)
//            }
//        }
//
//
//        self.myGroup.notify(queue: .main) {
//            if messagesAddToServer.count != 0 {
//                DatabaseManager.shared.deleteAllMessagesOfUserId(userid: userid)
//                self.getMessageFromServerAndUpdateToLocal()
//            }
//        }
//
//    }
//
//    func addMessageToServer(msg: Message,  group:DispatchGroup) -> String {
//        return ""
//    }
//
//    func getMessageFromServerAndUpdateToLocal() {
//        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
//        let url = baseUrl+"get_sent_message_list"
//        let parameters: Parameters = [
//            "userId": userid,
//            ]
//        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
//            if response.data != nil {
//                self.parseGetMessagesResponseData(JSONData: response.data!)
//            }
//            self.delegate?.syncDone(status: true)
//        }
//
//    }
//
//    func parseGetMessagesResponseData(JSONData: Data) {
//        do {
//             let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
//            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
//            if jsonOutput["status"] as! Int == 1 {
//                let messagesArray = jsonOutput["off_list"] as? [[String:Any]] ?? []
//                var messageList: [Message] = []
//                messageList.removeAll()
//                for message in messagesArray {
//                    let recipientsArray:[String] = (message["mobile"] as? String ?? "").components(separatedBy: ",")
//                    let sentTimestamp:String = "\(message["sentDate"] as? String ?? "") \(message["senttime"] as? String ?? "")"
//                    let msg:Message = Message(messageId: message["id"] as? String ?? "", recipients: recipientsArray, message: message["message"] as? String ?? "", sentTimestamp: sentTimestamp, sentByUsrID: message["userId"] as? String ?? "", isSelected: false)
//                    messageList.append(msg)
//                }
//                DatabaseManager.shared.addNewMessagessArrayOfUserId(userid: userid, addingMessageArray: messageList)
//            } else {
//
//            }
//        }
//        catch {
//            print(error)
//        }
//    }
    
    
    
    
    
    
    public func syncTemplates() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let templatesAddToServer:[Template] = DatabaseManager.shared.getTemplatesOfUserIdwhichDontHaveTemplateId(userid: userid)
        let templatesUpdateToServer:[Template] = DatabaseManager.shared.getTemplatesOfUserIdWhichUpdatedLocallyAndNeedsServerUpdate(userid: userid)
        if templatesAddToServer.count == 0 && templatesUpdateToServer.count == 0 {
            DatabaseManager.shared.deleteAllTemplatesOfUserId(userid: userid)
            self.getTemplatesFromServerAndUpdateToLocal()
        }
        for temp in templatesAddToServer {
            self.myGroup.enter()
            let mySubGroup = DispatchGroup()
            mySubGroup.enter()
            let templateid = self.addTemplateToServer(template: temp, group: mySubGroup)
            mySubGroup.notify(queue: .main) {
                DatabaseManager.shared.updateTemplateOfUserIdWithTemplateId(userid: userid, previousTemplateValue: temp, updatedTemplateId: templateid)
            }
        }
        
        for temp in templatesUpdateToServer {
            self.myGroup.enter()
            let mySubGroup = DispatchGroup()
            mySubGroup.enter()
            let templateId = self.updateTemplateToServer(template: temp, group: mySubGroup)
            mySubGroup.notify(queue: .main) {
                DatabaseManager.shared.updateTemplateOfUserIdWithTemplateId(userid: userid, previousTemplateValue: temp, updatedTemplateId: templateId)
            }
        }
        
        self.myGroup.notify(queue: .main) {
            if templatesAddToServer.count != 0 || templatesUpdateToServer.count != 0 {
                DatabaseManager.shared.deleteAllTemplatesOfUserId(userid: userid)
                self.getTemplatesFromServerAndUpdateToLocal()
            }
        }
   
    }
    
    func addTemplateToServer(template: Template, group:DispatchGroup) -> String {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"add_template"
        var savedtemplateid:String = ""
        let parameters: Parameters = [
            "userId": userid,
            "templateName": template.templateName,
            "templateDescription": template.templateDescription,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                savedtemplateid =  self.parseNewTemplateResponseData(JSONData: response.data!)
            }
            print("done")
            group.leave()
            self.myGroup.leave()
        }
        return savedtemplateid
    }
    
    func parseNewTemplateResponseData(JSONData: Data) -> String {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let tempId = jsonOutput["templateId"] as? String ?? ""
                return tempId
            } else {
            }
        }
        catch {
            print(error)
        }
        return ""
    }
    
    
    func updateTemplateToServer(template: Template, group:DispatchGroup) -> String {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"update_template_details"
        var updatedtemplateid:String = ""
        let parameters: Parameters = [
            "tempId": template.templateId,
            "templateName": template.templateName,
            "templateDescription": template.templateDescription,
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: URLEncoding.httpBody, headers: [:]).responseJSON { response in
            if response.data != nil {
                updatedtemplateid =  self.parseUpdateTemplateResponseData(JSONData: response.data!)
            }
            print("done")
            group.leave()
            self.myGroup.leave()
        }
        return updatedtemplateid
    }
    
    func parseUpdateTemplateResponseData(JSONData: Data) -> String {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let tempId = jsonOutput["templateId"] as? String ?? ""
                return tempId
            } else {
            }
        }
        catch {
            print(error)
        }
        return ""
    }
    
    func getTemplatesFromServerAndUpdateToLocal() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"get_template_list"
        let parameters: Parameters = [
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseGetTemplatesResponseData(JSONData: response.data!)
            }
            self.delegate?.syncDone(status: true)
        }
    }
    
    func parseGetTemplatesResponseData(JSONData: Data) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let templatesArray = jsonOutput["temp_list"] as? [[String:Any]] ?? []
                var templateList: [Template] = []
                templateList.removeAll()
                for temp in templatesArray {
                    let template:Template = Template(templateId: temp["id"] as? String ?? "", templateName: temp["templateName"] as? String ?? "", templateDescription: temp["templateDescription"] as? String ?? "", lastUpdateDate: "", addedByUser: userid, Status: temp["id"] as? Bool ?? true)
                    templateList.append(template)
                }
                DatabaseManager.shared.addNewTemplatesArrayOfUserId(userid: userid, addingTemplateArray: templateList)
            } else {
            }
        }
        catch {
            print(error)
        }
    }
    
    
    
  
    
    public func syncOffers() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let offersAddToServer:[Offer] = DatabaseManager.shared.getOffersOfUserIdwhichDontHaveOfferId(userid: userid)
        let offersUpdateToServer:[Offer] = DatabaseManager.shared.getOffersOfUserIdWhichUpdatedLocallyAndNeedsServerUpdate(userid: userid)
        if offersAddToServer.count == 0 && offersAddToServer.count == 0 {
            DatabaseManager.shared.deleteAllOffersOfUserId(userid: userid)
            self.getOffersFromServerAndUpdateToLocal()
        }
        for off in offersAddToServer {
            self.myGroup.enter()
            let mySubGroup = DispatchGroup()
            mySubGroup.enter()
            let offerid = self.addOfferToServer(offer: off, group: mySubGroup)
            mySubGroup.notify(queue: .main) {
                DatabaseManager.shared.updateOfferOfUserIdWithOfferId(userid: userid, previousOfferValue: off, updatedOfferId: offerid)
            }
        }
        
        for off in offersAddToServer {
            self.myGroup.enter()
            let mySubGroup = DispatchGroup()
            mySubGroup.enter()
            let offerid = self.updateOfferToServer(offer: off, group: mySubGroup)
            mySubGroup.notify(queue: .main) {
                DatabaseManager.shared.updateOfferOfUserIdWithOfferId(userid: userid, previousOfferValue: off, updatedOfferId: offerid)
            }
        }
        
        self.myGroup.notify(queue: .main) {
            if offersAddToServer.count != 0 || offersAddToServer.count != 0 {
                DatabaseManager.shared.deleteAllOffersOfUserId(userid: userid)
                self.getOffersFromServerAndUpdateToLocal()
            }
        }
        
    }
    
    func addOfferToServer(offer: Offer, group:DispatchGroup) -> String {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"add_offer"
        var savedofferid:String = ""
        let parameters: Parameters = [
            "userId": userid,
            "offerName": offer.offerName,
            "offerDescription": offer.offerDescription,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                savedofferid =  self.parseNewOfferResponseData(JSONData: response.data!)
            }
            print("done")
            group.leave()
            self.myGroup.leave()
        }
        return savedofferid
    }
    
    func parseNewOfferResponseData(JSONData: Data) -> String {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let offId = jsonOutput["offerId"] as? String ?? ""
                return offId
            } else {
            }
        }
        catch {
            print(error)
        }
        return ""
    }
    
    
    func updateOfferToServer(offer: Offer, group:DispatchGroup) -> String {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"update_offer_details"
        var updatedofferid:String = ""
        let parameters: Parameters = [
            "offerId": offer.offerId,
            "offerName": offer.offerName,
            "offerDescription": offer.offerDescription,
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.put , parameters: parameters, encoding: URLEncoding.httpBody, headers: [:]).responseJSON { response in
            if response.data != nil {
                updatedofferid =  self.parseUpdateOfferResponseData(JSONData: response.data!)
            }
            print("done")
            group.leave()
            self.myGroup.leave()
        }
        return updatedofferid
    }
    
    func parseUpdateOfferResponseData(JSONData: Data) -> String {
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let offId = jsonOutput["offerId"] as? String ?? ""
                return offId
            } else {
            }
        }
        catch {
            print(error)
        }
        return ""
    }
    
    func getOffersFromServerAndUpdateToLocal() {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let url = baseUrl+"get_offer_list"
        let parameters: Parameters = [
            "userId": userid,
            ]
        Alamofire.request(url, method: HTTPMethod.post , parameters: parameters, encoding: JSONEncoding.default , headers: [:]).responseJSON { response in
            if response.data != nil {
                self.parseGetOffersResponseData(JSONData: response.data!)
            }
            self.delegate?.syncDone(status: true)
        }
    }
    
    func parseGetOffersResponseData(JSONData: Data) {
        let userid:String = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! [String: Any]
            if jsonOutput["status"] as! Int == 1 {
                let offersArray = jsonOutput["off_list"] as? [[String:Any]] ?? []
                var offerList: [Offer] = []
                offerList.removeAll()
                for off in offersArray {
                    let offer:Offer = Offer(offerId: off["id"] as? String ?? "", offerName: off["offerName"] as? String ?? "", offerDescription: off["offerDescription"] as? String ?? "", lastUpdateDate: "", addedByUser: userid, Status: off["status"] as? Bool ?? true)
                    offerList.append(offer)
                }
                DatabaseManager.shared.addNewOfferArrayOfUserId(userid: userid, addingOfferArray: offerList)
            } else {
            }
        }
        catch {
            print(error)
        }
    }
    
}
