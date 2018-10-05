//
//  ImportContactsFromCSVFileVC.swift
//  Reter
//
//  Created by apple on 2/28/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit
import UIDropDown



class ImportContactsFromCSVFileVC: UIViewController {
    
    @IBOutlet weak var dropDownCSVFile: UIDropDown!
    @IBOutlet weak var btnImport: UIButton!
    
    var csvUrls: [URL] = []
    var csvNames: [String] = []
    var selectedCSVUrl:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUIElements()
        fetchCSVFilesFromPhone()
        setBackButton(navigationController: navigationController!, willShowViewController: self, animated: true)
    }
    
    @IBAction func clickedBtnImport(_ sender: Any) {
        if selectedCSVUrl != nil {
            performSegue(withIdentifier: "toImportContactsFromSelectCSVFile", sender: self)
        } else {
            showAlert(title: "Alert", message: "Please select csv file to import")
        }
    }
    
    func SetupUIElements() {
        btnImport.roundAllCorners(radius: btnImport.frame.height/2)
        btnImport.setBorderWidthAndColor(width: 1.5, color: UIColor(hex: "4464C3").cgColor)
    }
    
    func setUpCSVFileDropDown() {
        dropDownCSVFile.borderWidth = 0.0
        dropDownCSVFile.tableHeight = 180.0
        dropDownCSVFile.extraWidth = 0.0
        dropDownCSVFile.tableWillAppear {
            self.view.bringSubview(toFront: self.dropDownCSVFile)
        }
        dropDownCSVFile.textAlignment = .center
        dropDownCSVFile.textColor = UIColor.black
        dropDownCSVFile.placeholder = ""
        dropDownCSVFile.layer.zPosition = 10
        dropDownCSVFile.options = csvNames
        dropDownCSVFile.didSelect { (option, index) in
            self.selectedCSVUrl = self.csvUrls[index]
            self.dropDownCSVFile.resign()
        }
        self.view.addSubview(dropDownCSVFile)
    }
    
    func fetchCSVFilesFromPhone() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentsUrl.appendingPathComponent("/Inbox")
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            csvUrls = directoryContents.filter{ $0.pathExtension == "csv" }
            print("csv Urls:",csvUrls)
            csvNames = csvUrls.map{ $0.deletingPathExtension().lastPathComponent }
            print("csv Names:", csvNames)
        } catch {
            print(error.localizedDescription)
        }
        setUpCSVFileDropDown()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImportContactsFromSelectCSVFile" {
            let destVC:ImportContactsFromPhoneVC = segue.destination as! ImportContactsFromPhoneVC
            destVC.isForImportPhoneContacts = false
            destVC.selectedCSVFileUrl = selectedCSVUrl
        }
    }
    
    
}
