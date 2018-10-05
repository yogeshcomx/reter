//
//  ContactsTableCell.swift
//  Reter
//
//  Created by apple on 1/17/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit

class ContactsTableCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var lblProfileImage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
