//
//  SelectContactsTableCell.swift
//  Reter
//
//  Created by apple on 1/23/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit

class SelectContactsTableCell: UITableViewCell {

    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
