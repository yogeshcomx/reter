//
//  ProfileTableCell.swift
//  Reter
//
//  Created by apple on 2/6/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit

class ProfileTableCell: UITableViewCell {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgSecondary: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
