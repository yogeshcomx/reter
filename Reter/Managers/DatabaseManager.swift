//
//  DatabaseManager.swift
//  Reter
//
//  Created by apple on 2/8/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation
import SQLite

class DatabaseManager {

    static let shared = DatabaseManager()

    private init() {
        
    }
    
    //Common Columns in Tables
    let id = Expression<Int64>("id")
    
    
    // Columns For Contacts Table
    let contactId = Expression<String>("contactId")
    let contactName = Expression<String>("contactName")
    let contactPhone = Expression<String>("contactPhone")
    let contactCountryCode = Expression<String>("contactCountryCode")
    let contactEmail = Expression<String>("contactEmail")
    let contactStatus = Expression<Bool>("contactStatus")
    let contactImage = Expression<String>("contactImage")
    let contactOfflineUpdated = Expression<Bool>("contactOfflineUpdated")
    let contactAddedByUserId = Expression<String>("contactAddedByUserId")
    let contactLastUpdateTimestamp = Expression<String>("contactLastUpdateTimestamp")
    
    // Columns For Messages Table
    let messageId = Expression<String>("messageId")
    let messageRecipients = Expression<String>("messageRecipients")
    let messageText = Expression<String>("messageText")
    let messageSentByUserId = Expression<String>("messageSentByUserId")
    let messageSentTimestamp = Expression<String>("messageSentTimestamp")
    
    // Columns For Mail Table
    let mailId = Expression<String>("mailId")
    let mailRecipients = Expression<String>("mailRecipients")
    let mailSubject = Expression<String>("mailSubject")
    let mailText = Expression<String>("mailText")
    let mailSentByUserId = Expression<String>("mailSentByUserId")
    let mailSentTimestamp = Expression<String>("mailSentTimestamp")
    
    // Columns For Templates Table
    let templateId = Expression<String>("templateId")
    let templateTitle = Expression<String>("templateTitle")
    let templateDescription = Expression<String>("templateDescription")
    let templateOfflineUpdated = Expression<Bool>("templateOfflineUpdated")
    let templateAddedByUserId = Expression<String>("templateAddedByUserId")
    let templateLastUpdateTimestamp = Expression<String>("templateLastUpdateTimestamp")
    
    // Columns For Offers Table
    let offerId = Expression<String>("offerId")
    let offerTitle = Expression<String>("offerTitle")
    let offerDescription = Expression<String>("offerDescription")
    let offerOfflineUpdated = Expression<Bool>("offerOfflineUpdated")
    let offerAddedByUserId = Expression<String>("offerAddedByUserId")
    let offerLastUpdateTimestamp = Expression<String>("offerLastUpdateTimestamp")
    
    // Columns For Contry Table
    let countryId = Expression<String>("countryId")
    let countryName = Expression<String>("countryName")
    let countryCode = Expression<String>("countryCode")
    let countryStatus = Expression<Bool>("countryStatus")
    
    
    // Required Tables creation for User
    func createAllTablesForUser(userid: String) {
        
        //Contact Table Creation
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            try db.run(contact.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(contactId)
                t.column(contactName)
                t.column(contactPhone, unique: true)
                t.column(contactEmail, unique: true)
                t.column(contactCountryCode)
                t.column(contactStatus)
                t.column(contactImage)
                t.column(contactOfflineUpdated)
                t.column(contactAddedByUserId)
                t.column(contactLastUpdateTimestamp)
            })
            
        } catch {
            print(error)
        }
        
        //Message Table Creation
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            try db.run(message.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(messageId)
                t.column(messageRecipients)
                t.column(messageText)
                t.column(messageSentByUserId)
                t.column(messageSentTimestamp)
            })
            
        } catch {
            print(error)
        }
        
        //Mail Table Creation
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Mails_\(userid)")
            try db.run(message.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(mailId)
                t.column(mailRecipients)
                t.column(mailSubject)
                t.column(mailText)
                t.column(mailSentByUserId)
                t.column(mailSentTimestamp)
            })
            
        } catch {
            print(error)
        }
        
        
        
        //Template Table Creation
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            try db.run(template.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(templateId)
                t.column(templateTitle)
                t.column(templateDescription)
                t.column(templateOfflineUpdated)
                t.column(templateAddedByUserId)
                t.column(templateLastUpdateTimestamp)
            })
            
        } catch {
            print(error)
        }
        
        //Offer Table Creation
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            try db.run(offer.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(offerId)
                t.column(offerTitle)
                t.column(offerDescription)
                t.column(offerOfflineUpdated)
                t.column(offerAddedByUserId)
                t.column(offerLastUpdateTimestamp)
            })
            
        } catch {
            print(error)
        }
        
    }

    
    
    //Country Table Creation
    func createCountriesTable() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let country = Table("Countries")
            try db.run(country.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(countryId, unique: true)
                t.column(countryName)
                t.column(countryCode)
                t.column(countryStatus)
            })
            
        } catch {
            print(error)
        }
    }
    
    
    //Delete All Tables of User
    func deleteTablesOfUser(userid:String) {
        let tableNames:[String] = ["Contacts_\(userid)", "Messages_\(userid)", "Mails_\(userid)", "Templates_\(userid)", "Offers_\(userid)"]
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            for table in  tableNames {
                let tab = Table(table)
                try db.run(tab.drop())
            }
        } catch {
            print(error)
        }
    }
    
    
    
    
    /*  <<< CONTACTS - Functions To handle Database Actions Related To Contacts >>> */
    
    //Getting Contacts Table Count based on User Id
    func getContactsCount(userid:String) -> Int {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            return try db.scalar(contact.count)
        } catch {
            print(error)
        }
        return 0
    }
    
    
    //Getting All Contacts based on User Id
    func getContactsOfUserId(userid:String) -> [Contact] {
        var contactList:[Contact] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            let contactQuery = contact.select([id,contactId,contactName,contactPhone,contactEmail,contactCountryCode,contactImage,contactStatus,contactAddedByUserId,contactLastUpdateTimestamp])
            for cont in try db.prepare(contactQuery) {
                let contactValue:Contact = Contact(contactId: cont[contactId], name: cont[contactName], countryCode: cont[contactCountryCode], phone: cont[contactPhone], email: cont[contactEmail], imageData: cont[contactImage], lastUpdateDate: "", addedByUser: cont[contactAddedByUserId], isActive: cont[contactStatus], isSelected: false)
                contactList.append(contactValue)
            }
        } catch {
            print(error)
        }
        return contactList
    }
    
    //Getting All Contacts which do not have contactId of on User Id
    func getContactsOfUserIdwhichDontHaveContactId(userid:String) -> [Contact] {
        var contactList:[Contact] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            let contactQuery = contact.select([id,contactId,contactName,contactPhone,contactEmail,contactImage,contactCountryCode,contactStatus,contactAddedByUserId,contactLastUpdateTimestamp]).filter(contactId == "")
            for cont in try db.prepare(contactQuery) {
                let contactValue:Contact = Contact(contactId: cont[contactId], name: cont[contactName], countryCode: cont[contactCountryCode], phone: cont[contactPhone], email: cont[contactEmail], imageData: cont[contactImage], lastUpdateDate: "", addedByUser: cont[contactAddedByUserId], isActive: cont[contactStatus], isSelected: false)
                contactList.append(contactValue)
            }
        } catch {
            print(error)
        }
        return contactList
    }
    
    //Getting All Contacts which updated locally and needs to update to server
    func getContactsOfUserIdWhichUpdatedLocallyAndNeedsServerUpdate(userid:String) -> [Contact] {
        var contactList:[Contact] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            let contactQuery = contact.select([id,contactId,contactName,contactPhone,contactEmail,contactCountryCode,contactImage,contactStatus,contactAddedByUserId,contactLastUpdateTimestamp]).filter(contactId != "").filter(contactOfflineUpdated == true)
            for cont in try db.prepare(contactQuery) {
                let contactValue:Contact = Contact(contactId: cont[contactId], name: cont[contactName],countryCode: cont[contactCountryCode], phone: cont[contactPhone], email: cont[contactEmail], imageData: cont[contactImage], lastUpdateDate: "", addedByUser: cont[contactAddedByUserId], isActive: cont[contactStatus], isSelected: false)
                contactList.append(contactValue)
            }
        } catch {
            print(error)
        }
        return contactList
    }
    
    
    //Add New Contact based on User Id
    func addNewContactOfUserId(userid: String, addingContact: Contact) -> Bool {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            try db.run(contact.insert(contactId <- addingContact.contactId, contactName <- addingContact.name, contactCountryCode <- addingContact.countryCode ,contactPhone <- addingContact.phone, contactEmail <- addingContact.email ?? "", contactStatus <- addingContact.isActive, contactImage <- addingContact.imageData ?? "", contactOfflineUpdated <- false, contactAddedByUserId <- userid, contactLastUpdateTimestamp <- addingContact.lastUpdateDate  ))
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    
    //Add Contact with Id from Import Contacts
    func addNewContactOfUserIdAndContactId(userid: String, contid: String, addingContact: Contact) -> Bool {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            try db.run(contact.insert(contactId <- contid, contactName <- addingContact.name, contactCountryCode <- addingContact.countryCode ,contactPhone <- addingContact.phone, contactEmail <- addingContact.email ?? "", contactStatus <- addingContact.isActive, contactImage <- addingContact.imageData ?? "", contactOfflineUpdated <- false, contactAddedByUserId <- userid, contactLastUpdateTimestamp <- addingContact.lastUpdateDate  ))
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    
    //Add New Contact Array based on User Id
    func addNewContactsArrayOfUserId(userid: String, addingContactArray: [Contact]) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            for addingContact in addingContactArray {
                try db.run(contact.insert(contactId <- addingContact.contactId, contactName <- addingContact.name, contactCountryCode <- addingContact.countryCode, contactPhone <- addingContact.phone, contactEmail <- addingContact.email ?? "", contactStatus <- addingContact.isActive, contactImage <- addingContact.imageData ?? "", contactOfflineUpdated <- false, contactAddedByUserId <- userid, contactLastUpdateTimestamp <- addingContact.lastUpdateDate  ))
            }
        } catch {
            print(error)
        }
    }
    
    
    //Delete Contact from Table
    func deleteContactWithContactId(userid: String, deletingContactId: String, deletingContact: Contact? ) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            if deletingContactId != "" {
                let deletingCont = contact.filter(contactId == deletingContactId)
                let delete = deletingCont.delete()
                try db.run(delete)
            } else if deletingContact != nil {
                let deletingCont = contact.filter(contactPhone == deletingContact!.phone).filter(contactEmail == deletingContact!.email!)
                let delete = deletingCont.delete()
                try db.run(delete)
            }
            
        } catch {
            print(error)
        }
    }
    
    
    //Delete All Contacts From Table
    func deleteAllContactsOfUserId(userid: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            let delete = contact.delete()
            try db.run(delete)
        } catch {
            print(error)
        }
    }
    
    
    //Update Contact With Contact Id
    func updateContactOfUserIdWithContactId(userid: String, previousContactValue:Contact, updatedContactId:String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            let updatingCont = contact.filter(contactPhone == previousContactValue.phone).filter(contactEmail == previousContactValue.email!)
            try db.run(updatingCont.update(contactId <- contactId.replace(previousContactValue.contactId, with: updatedContactId)))
        } catch {
            print(error)
        }
    }
    
    
    //Update Contact Of User Id
    func updateContactOfUserId(userid: String, previousContactValue:Contact, updatedContactValue:Contact, isOfflineUpdated:Bool = false) -> Bool {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let contact = Table("Contacts_\(userid)")
            let updatingCont = contact.filter(contactPhone == previousContactValue.phone).filter(contactEmail == previousContactValue.email!)
            try db.run(updatingCont.update(
                contactId <- updatedContactValue.contactId,
                contactName <- updatedContactValue.name,
                contactStatus <- updatedContactValue.isActive,
                contactEmail <- updatedContactValue.email!,
                contactPhone <- updatedContactValue.phone,
                contactCountryCode <- updatedContactValue.countryCode,
                contactImage <- updatedContactValue.imageData ?? "",
                contactOfflineUpdated <- isOfflineUpdated,
                contactAddedByUserId <- updatedContactValue.addedByUser,
                contactLastUpdateTimestamp <- updatedContactValue.lastUpdateDate))
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    
    /*  <<< MESSAGES - Functions To handle Database Actions Related To Messages >>> */
    
    //Getting Messages Table Count based on User Id
    func getMessagesCount(userid:String) -> Int {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            return try db.scalar(message.count)
        } catch {
            print(error)
        }
        return 0
    }
    
    //Getting All Messages based on User Id
    func getMessagesOfUserId(userid:String) -> [Message] {
        var messageList:[Message] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            let messageQuery = message.select([id,messageId,messageRecipients,messageText,messageSentByUserId,messageSentTimestamp])
            for msg in try db.prepare(messageQuery) {
                let recipientArray = msg[messageRecipients].components(separatedBy: ",")
                let messageValue:Message = Message(messageId: msg[messageId], recipients: recipientArray, message: msg[messageText], sentTimestamp: msg[messageSentTimestamp], sentByUsrID: msg[messageSentByUserId], isSelected: false)
                messageList.append(messageValue)
            }
        } catch {
            print(error)
        }
        return messageList
    }
    
    //Getting All Messages which do not have messageId of User Id
    func getMessagesOfUserIdwhichDontHaveMessageId(userid:String) -> [Message] {
        var messageList:[Message] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            let messageQuery = message.select([id,messageId,messageRecipients,messageText,messageSentByUserId,messageSentTimestamp]).filter(messageId == "")
            for msg in try db.prepare(messageQuery) {
                let recipientArray = msg[messageRecipients].components(separatedBy: ",")
                let messageValue:Message = Message(messageId: msg[messageId], recipients: recipientArray ,message: msg[messageText], sentTimestamp: "", sentByUsrID: msg[messageSentByUserId], isSelected: false)
                messageList.append(messageValue)
            }
        } catch {
            print(error)
        }
        return messageList
    }
    
    
    //Add New Message based on User Id
    func addNewMessageOfUserId(userid: String, addingMessage: Message) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            let recipientString = addingMessage.recipients.joined(separator: ",")
            try db.run(message.insert(messageId <- addingMessage.messageId, messageRecipients <- recipientString, messageText <- addingMessage.message, messageSentByUserId <- addingMessage.sentByUsrID, messageSentTimestamp <- addingMessage.sentTimestamp))
        } catch {
            print(error)
        }
    }
    
    //Add New Message Array based on User Id
    func addNewMessagessArrayOfUserId(userid: String, addingMessageArray: [Message]) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            for addingMessage in addingMessageArray {
                let recipientString = addingMessage.recipients.joined(separator: ",")
                try db.run(message.insert(messageId <- addingMessage.messageId, messageRecipients <- recipientString, messageText <- addingMessage.message, messageSentByUserId <- addingMessage.sentByUsrID, messageSentTimestamp <- addingMessage.sentTimestamp))
            }
        } catch {
            print(error)
        }
    }
    
    
    //Delete Message from Table
    func deleteMessageWithMessageId(userid: String, deletingMessageId: String, deletingMessage:Message?) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            if deletingMessageId != "" {
                let deletingMsg = message.filter(messageId == deletingMessageId)
                let delete = deletingMsg.delete()
                try db.run(delete)
            } else if deletingMessage != nil {
                let recipientString = deletingMessage!.recipients.joined(separator: ",")
                let deletingMsg = message.filter(messageRecipients == recipientString).filter(messageText == deletingMessage!.message).filter(messageSentTimestamp == deletingMessage!.sentTimestamp)
                let delete = deletingMsg.delete()
                try db.run(delete)
            }
        } catch {
            print(error)
        }
    }
    
    
    //Delete All Messages From Table
    func deleteAllMessagesOfUserId(userid: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            let delete = message.delete()
            try db.run(delete)
        } catch {
            print(error)
        }
    }
    
    
    //Update Message With Message Id
    func updateMessageOfUserIdWithMessageId(userid: String, previousMessageValue:Message, updatedMessageId:String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            let recipientString = previousMessageValue.recipients.joined(separator: ",")
            let updatingCont = message.filter(messageRecipients == recipientString).filter(messageText == previousMessageValue.message)
            try db.run(updatingCont.update(messageId <- contactId.replace(previousMessageValue.messageId, with: updatedMessageId)))
        } catch {
            print(error)
        }
    }
    
    
    //Update Message Of User Id
    func updateMessageOfUserId(userid: String, previousMessageValue:Message, updatedMessageValue:Message) -> Bool {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let message = Table("Messages_\(userid)")
            let recipientStringPrevious = previousMessageValue.recipients.joined(separator: ",")
            let recipientStringUpdated = updatedMessageValue.recipients.joined(separator: ",")
            let updatingCont = message.filter(messageRecipients == recipientStringPrevious).filter(messageText == previousMessageValue.message)
            try db.run(updatingCont.update(
                messageId <- updatedMessageValue.messageId,
                messageRecipients <- recipientStringUpdated,
                messageText <- updatedMessageValue.message,
                messageSentByUserId <- updatedMessageValue.sentByUsrID,
                messageSentTimestamp <- updatedMessageValue.sentTimestamp
            ))
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    
    /*  <<< MAILS - Functions To handle Database Actions Related To Mails >>> */
    
    //Getting Mail Table Count based on User Id
    func getMailsCount(userid:String) -> Int {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let mail = Table("Mails_\(userid)")
            return try db.scalar(mail.count)
        } catch {
            print(error)
        }
        return 0
    }
    
    //Getting All Mails based on User Id
    func getMailssOfUserId(userid:String) -> [Mail] {
        var mailList:[Mail] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let mail = Table("Mails_\(userid)")
            let mailQuery = mail.select([id,mailId,mailRecipients,mailText,mailSentByUserId,mailSentTimestamp])
            for email in try db.prepare(mailQuery) {
                let recipientArray = email[mailRecipients].components(separatedBy: ",")
                let mailValue:Mail = Mail(mailId: email[messageId], recipients: recipientArray, subject: email[mailSubject], message: email[mailText], sentTimestamp: email[mailSentTimestamp], sentByUsrID: email[mailSentByUserId], isSelected: false)
                mailList.append(mailValue)
            }
        } catch {
            print(error)
        }
        return mailList
    }
    
    
    
    //Add New Mail based on User Id
    func addNewMailOfUserId(userid: String, addingMail: Mail) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let mail = Table("Mails_\(userid)")
            let recipientString = addingMail.recipients.joined(separator: ",")
            try db.run(mail.insert(mailId <- addingMail.mailId, mailRecipients <- recipientString, mailSubject <- addingMail.subject, mailText <- addingMail.message, mailSentByUserId <- addingMail.sentByUsrID, mailSentTimestamp <- addingMail.sentTimestamp))
        } catch {
            print(error)
        }
    }
    
    //Add New MAil Array based on User Id
    func addNewMailsArrayOfUserId(userid: String, addingMailsArray: [Mail]) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let mail = Table("Mails_\(userid)")
            for addingMail in addingMailsArray {
                let recipientString = addingMail.recipients.joined(separator: ",")
                try db.run(mail.insert(mailId <- addingMail.mailId, mailRecipients <- recipientString, mailSubject <- addingMail.subject, mailText <- addingMail.message, mailSentByUserId <- addingMail.sentByUsrID, mailSentTimestamp <- addingMail.sentTimestamp))
            }
        } catch {
            print(error)
        }
    }
    
    
    //Delete Mail from Table
    func deleteMailWithMailId(userid: String, deletingMailId: String, deletingMail:Mail?) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let mail = Table("Mails_\(userid)")
            if deletingMailId != "" {
                let deletingEmail = mail.filter(mailId == deletingMailId)
                let delete = deletingEmail.delete()
                try db.run(delete)
            } else if deletingMailId != nil {
                let recipientString = deletingMail!.recipients.joined(separator: ",")
                let deletingEmail = mail.filter(mailRecipients == recipientString).filter(mailText == deletingMail!.message).filter(mailSentTimestamp == deletingMail!.sentTimestamp)
                let delete = deletingEmail.delete()
                try db.run(delete)
            }
        } catch {
            print(error)
        }
    }
    
    
    //Delete All Mails From Table
    func deleteAllMailsOfUserId(userid: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let mail = Table("Mails\(userid)")
            let delete = mail.delete()
            try db.run(delete)
        } catch {
            print(error)
        }
    }
    
    
    
    
    /*  <<< TEMPLATES - Functions To handle Database Actions Related To Templates >>> */
    
    //Getting Templates Table Count based on User Id
    func getTemplatesCount(userid:String) -> Int {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            return try db.scalar(template.count)
        } catch {
            print(error)
        }
        return 0
    }
    
    //Getting All Templates based on User Id
    func getTemplatesOfUserId(userid:String) -> [Template] {
        var templateList:[Template] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            let templateQuery = template.select([id,templateId,templateTitle,templateDescription,templateLastUpdateTimestamp,templateAddedByUserId])
            for temp in try db.prepare(templateQuery) {
                let templateValue:Template = Template(templateId: temp[templateId], templateName: temp[templateTitle], templateDescription: temp[templateDescription], lastUpdateDate: temp[templateLastUpdateTimestamp], addedByUser: temp[templateAddedByUserId], Status: false)
                templateList.append(templateValue)
            }
        } catch {
            print(error)
        }
        return templateList
    }
    
    //Getting All Templates which do not have templateId of User Id
    func getTemplatesOfUserIdwhichDontHaveTemplateId(userid:String) -> [Template] {
        var templateList:[Template] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            let templateQuery = template.select([id,templateId,templateTitle,templateDescription,templateLastUpdateTimestamp,templateAddedByUserId]).filter(templateId == "")
            for temp in try db.prepare(templateQuery) {
                let templateValue:Template = Template(templateId: temp[templateId], templateName: temp[templateTitle], templateDescription: temp[templateDescription], lastUpdateDate: temp[templateLastUpdateTimestamp], addedByUser: temp[templateAddedByUserId], Status: false)
                templateList.append(templateValue)
            }
        } catch {
            print(error)
        }
        return templateList
    }
    
    
    //Getting All Templates which updated locally and needs to update to server
    func getTemplatesOfUserIdWhichUpdatedLocallyAndNeedsServerUpdate(userid:String) -> [Template] {
        var templateList:[Template] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            let templateQuery = template.select([id,templateId,templateTitle,templateDescription,templateLastUpdateTimestamp,templateAddedByUserId]).filter(templateId != "").filter(templateOfflineUpdated == true)
            for temp in try db.prepare(templateQuery) {
                let templateValue:Template = Template(templateId: temp[templateId], templateName: temp[templateTitle], templateDescription: temp[templateDescription], lastUpdateDate: temp[templateLastUpdateTimestamp], addedByUser: temp[templateAddedByUserId], Status: false)
                templateList.append(templateValue)
            }
        } catch {
            print(error)
        }
        return templateList
    }
    
    
    //Add New Template based on User Id
    func addNewTemplateOfUserId(userid: String, addingTemplate: Template) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            try db.run(template.insert(templateId <- addingTemplate.templateId, templateTitle <- addingTemplate.templateName, templateDescription <- addingTemplate.templateDescription, templateLastUpdateTimestamp <- addingTemplate.lastUpdateDate, templateAddedByUserId <- addingTemplate.addedByUser, templateOfflineUpdated <- false))
        } catch {
            print(error)
        }
    }
    
    //Add New Template Array based on User Id
    func addNewTemplatesArrayOfUserId(userid: String, addingTemplateArray: [Template]) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            for addingTemplate in addingTemplateArray {
                try db.run(template.insert(templateId <- addingTemplate.templateId, templateTitle <- addingTemplate.templateName, templateDescription <- addingTemplate.templateDescription, templateLastUpdateTimestamp <- addingTemplate.lastUpdateDate, templateAddedByUserId <- addingTemplate.addedByUser, templateOfflineUpdated <- false))
            }
        } catch {
            print(error)
        }
    }
    
    
    //Delete Template from Table
    func deleteTemplateWithTemplateId(userid: String, deletingTemplateId: String, deletingTemplate: Template? ) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            if deletingTemplateId != "" {
                let deletingTemp = template.filter(templateId == deletingTemplateId)
                let delete = deletingTemp.delete()
                try db.run(delete)
            } else if deletingTemplate != nil {
                let deletingTemp = template.filter(templateTitle == deletingTemplate!.templateName).filter(templateDescription == deletingTemplate!.templateDescription).filter(templateLastUpdateTimestamp == deletingTemplate!.lastUpdateDate)
                let delete = deletingTemp.delete()
                try db.run(delete)
            }
            
        } catch {
            print(error)
        }
    }
    
    
    //Delete All Templates From Table
    func deleteAllTemplatesOfUserId(userid: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            let delete = template.delete()
            try db.run(delete)
        } catch {
            print(error)
        }
    }
    
    
    //Update Template With Template Id
    func updateTemplateOfUserIdWithTemplateId(userid: String, previousTemplateValue:Template, updatedTemplateId:String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            let updatingTemp = template.filter(templateTitle == previousTemplateValue.templateName).filter(templateDescription == previousTemplateValue.templateDescription)
            try db.run(updatingTemp.update(templateId <- templateId.replace(previousTemplateValue.templateId, with: updatedTemplateId)))
        } catch {
            print(error)
        }
    }
    
    
    //Update Template Of User Id
    func updateTemplateOfUserId(userid: String, previousTemplateValue:Template, updatedTemplateValue:Template, isOfflineUpdated:Bool = false) -> Bool {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let template = Table("Templates_\(userid)")
            let updatingTemp = template.filter(templateTitle == previousTemplateValue.templateName).filter(templateDescription == previousTemplateValue.templateDescription).filter(templateLastUpdateTimestamp == previousTemplateValue.lastUpdateDate)
            try db.run(updatingTemp.update(
                templateId <- updatedTemplateValue.templateId,
                templateTitle <- updatedTemplateValue.templateName,
                templateDescription <- updatedTemplateValue.templateDescription,
                templateOfflineUpdated <- isOfflineUpdated,
                templateLastUpdateTimestamp <- updatedTemplateValue.lastUpdateDate,
                templateAddedByUserId <- updatedTemplateValue.addedByUser
            ))
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    
    
    /*  <<< OFFERS - Functions To handle Database Actions Related To Offers >>> */
    
    //Getting Offers Table Count based on User Id
    func getOffersCount(userid:String) -> Int {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            return try db.scalar(offer.count)
        } catch {
            print(error)
        }
        return 0
    }
    
    //Getting All Offers based on User Id
    func getOffersOfUserId(userid:String) -> [Offer] {
        var offerList:[Offer] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            let offerQuery = offer.select([id,offerId,offerTitle,offerDescription,offerLastUpdateTimestamp,offerAddedByUserId])
            for offer in try db.prepare(offerQuery) {
                let offerValue:Offer = Offer(offerId: offer[offerId], offerName: offer[offerTitle], offerDescription: offer[offerDescription], lastUpdateDate: offer[offerLastUpdateTimestamp], addedByUser: offer[offerAddedByUserId], Status: false)
                offerList.append(offerValue)
            }
        } catch {
            print(error)
        }
        return offerList
    }
    
    //Getting All Offers which do not have offerId of User Id
    func getOffersOfUserIdwhichDontHaveOfferId(userid:String) -> [Offer] {
        var offerList:[Offer] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            let offerQuery = offer.select([id,offerId,offerTitle,offerDescription,offerLastUpdateTimestamp,offerAddedByUserId]).filter(offerId == "")
            for offer in try db.prepare(offerQuery) {
                let offerValue:Offer = Offer(offerId: offer[offerId], offerName: offer[offerTitle], offerDescription: offer[offerDescription], lastUpdateDate: offer[offerLastUpdateTimestamp], addedByUser: offer[offerAddedByUserId], Status: false)
                offerList.append(offerValue)
            }
        } catch {
            print(error)
        }
        return offerList
    }
    
    
    //Getting All Offers which updated locally and needs to update to server
    func getOffersOfUserIdWhichUpdatedLocallyAndNeedsServerUpdate(userid:String) -> [Offer] {
        var offerList:[Offer] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            let offerQuery = offer.select([id,offerId,offerTitle,offerDescription,offerLastUpdateTimestamp,offerAddedByUserId]).filter(offerId != "").filter(offerOfflineUpdated == true)
            for offer in try db.prepare(offerQuery) {
                let offerValue:Offer = Offer(offerId: offer[offerId], offerName: offer[offerTitle], offerDescription: offer[offerDescription], lastUpdateDate: offer[offerLastUpdateTimestamp], addedByUser: offer[offerAddedByUserId], Status: false)
                offerList.append(offerValue)
            }
        } catch {
            print(error)
        }
        return offerList
    }
    
    
    //Add New Offer based on User Id
    func addNewOfferOfUserId(userid: String, addingOffer: Offer) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            try db.run(offer.insert(offerId <- addingOffer.offerId, offerTitle <- addingOffer.offerName, offerDescription <- addingOffer.offerDescription, offerLastUpdateTimestamp <- addingOffer.lastUpdateDate, offerAddedByUserId <- addingOffer.addedByUser, offerOfflineUpdated <- false))
        } catch {
            print(error)
        }
    }
    
    //Add New Offer Array based on User Id
    func addNewOfferArrayOfUserId(userid: String, addingOfferArray: [Offer]) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            for addingOffer in addingOfferArray {
                try db.run(offer.insert(offerId <- addingOffer.offerId, offerTitle <- addingOffer.offerName, offerDescription <- addingOffer.offerDescription, offerLastUpdateTimestamp <- addingOffer.lastUpdateDate, offerAddedByUserId <- addingOffer.addedByUser, offerOfflineUpdated <- false))
            }
        } catch {
            print(error)
        }
    }
    
    
    //Delete Template from Table
    func deleteOfferWithOfferId(userid: String, deletingOfferId: String, deletingOffer: Offer? ) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            if deletingOfferId != "" {
                let deletingOffer = offer.filter(offerId == deletingOfferId)
                let delete = deletingOffer.delete()
                try db.run(delete)
            } else if deletingOffer != nil {
                let deletingOffer = offer.filter(offerTitle == deletingOffer!.offerName).filter(offerDescription == deletingOffer!.offerDescription).filter(offerLastUpdateTimestamp == deletingOffer!.lastUpdateDate)
                let delete = deletingOffer.delete()
                try db.run(delete)
            }
            
        } catch {
            print(error)
        }
    }
    
    
    //Delete All Offers From Table
    func deleteAllOffersOfUserId(userid: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            let delete = offer.delete()
            try db.run(delete)
        } catch {
            print(error)
        }
    }
    
    
    //Update Offer With Offer Id
    func updateOfferOfUserIdWithOfferId(userid: String, previousOfferValue:Offer, updatedOfferId:String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            let updatingOffer = offer.filter(offerTitle == previousOfferValue.offerName).filter(offerDescription == previousOfferValue.offerDescription)
            try db.run(updatingOffer.update(offerId <- offerId.replace(previousOfferValue.offerId, with: updatedOfferId)))
        } catch {
            print(error)
        }
    }
    
    
    //Update Offer Of User Id
    func updateOfferOfUserId(userid: String, previousOfferValue:Offer, updatedOfferValue:Offer, isOfflineUpdated:Bool = false) -> Bool {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let offer = Table("Offers_\(userid)")
            let updatingOffer = offer.filter(offerTitle == previousOfferValue.offerName).filter(offerDescription == previousOfferValue.offerDescription).filter(offerLastUpdateTimestamp == previousOfferValue.lastUpdateDate)
            try db.run(updatingOffer.update(
                offerId <- updatedOfferValue.offerId,
                offerTitle <- updatedOfferValue.offerName,
                offerDescription <- updatedOfferValue.offerDescription,
                offerOfflineUpdated <- isOfflineUpdated,
                offerLastUpdateTimestamp <- updatedOfferValue.lastUpdateDate,
                offerAddedByUserId <- updatedOfferValue.addedByUser
            ))
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    
    
    
    /*  <<< COUNTRIES - Functions To handle Database Actions Related To Countries >>> */
    
    //Getting All Contacts based on User Id
    func getCountries() -> [Country] {
        var countryList:[Country] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let country = Table("Countries")
            let countryQuery = country.select([id,countryId,countryName,countryCode,countryStatus])
            for count in try db.prepare(countryQuery) {
                let countryValue:Country = Country(countryId: count[countryId], countryName: count[countryName], countryCode: count[countryCode], countryStatus: count[countryStatus])
                countryList.append(countryValue)
            }
        } catch {
            print(error)
        }
        return countryList
    }
    
    //Add New Countries array
    func addNewCountriesArray(addingCountryArray: [Country]) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            let country = Table("Countries")
            for addingCountry in addingCountryArray {
                try db.run(country.insert(countryId <- addingCountry.countryId, countryName <- addingCountry.countryName, countryCode <- addingCountry.countryCode, countryStatus <- addingCountry.countryStatus))
            }
        } catch {
            print(error)
        }
    }
    
    
}



