//
//  AlarmTableViewCell.swift
//  CoreDataAlarm
//
//  Created by phoebe on 3/19/19.
//  Copyright © 2019 phoebe. All rights reserved.
//

import UIKit

class AlarmTableViewCell: UITableViewCell{
    var parentViewController: UIViewController?
    
   weak var delegatess: soso?
    
    var alarmo = [Alarm]()

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func alarmSwitched(_ sender: UISwitch) {
     
   self.delegatess?.alarmWasToggled(sender: self, ison: alarmSwitch.isOn)
    }
    
   
}

