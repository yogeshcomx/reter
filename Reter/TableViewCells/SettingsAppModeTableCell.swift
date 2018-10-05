//
//  SettingsAppModeTableCell.swift
//  Reter
//
//  Created by apple on 2/8/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit

protocol settingsappModeProtocol {
    func appModeChanged(value:String)
}

class SettingsAppModeTableCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    var delegate:settingsappModeProtocol?
    @IBOutlet weak var segmentMode: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func clickSegmentMode(_ sender: Any) {
       // lblValue.text = "\(segmentMode.titleForSegment(at: segmentMode.selectedSegmentIndex)!)"
       // delegate?.appModeChanged(value: lblValue.text!)
        let index = segmentMode.selectedSegmentIndex
        
        lblValue.text = "\(segmentMode.titleForSegment(at: 0)!)"
        delegate?.appModeChanged(value: "Offline")
        segmentMode.selectedSegmentIndex = 0
        
        if index != 0 {
            let alert = UIAlertController(title: "Coming Soon", message:"Right now we are supporting only Offline SMS. Online SMS will be released soon", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
}
