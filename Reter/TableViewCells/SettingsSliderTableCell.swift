//
//  SettingsSliderTableCell.swift
//  Reter
//
//  Created by apple on 2/8/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit

protocol settingsOfflineLimitProtocol {
    func offlineLimitChanged(tag:Int, value:Int)
}

class SettingsSliderTableCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var sliderValue: UISlider!
    
    var delegate:settingsOfflineLimitProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func clickedSliderValue(_ sender: Any) {
        let roundedValue = round(sliderValue.value / 10) * 10
        sliderValue.value = roundedValue
        lblValue.text = "\(Int(sliderValue.value))"
        delegate?.offlineLimitChanged(tag: sliderValue.tag,  value: Int(sliderValue.value))
    }
}
