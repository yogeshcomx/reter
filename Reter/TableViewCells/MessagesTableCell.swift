//
//  MessagesTableCell.swift
//  Reter
//
//  Created by apple on 1/22/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit

class MessagesTableCell: UITableViewCell {

    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var lblRecipients: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblSentTimestamp: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
