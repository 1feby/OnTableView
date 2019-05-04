//
//  tableViewOnly.swift
//  OnTableView
//
//  Created by phoebeezzat on 4/28/19.
//  Copyright © 2019 phoebe. All rights reserved.
//

import UIKit
import Contacts
import EventKit
import CoreData
protocol soso: class{
    func alarmWasToggled(sender: AlarmTableViewCell, ison : Bool)
}

class oneTableViewController : UITableViewController ,soso{
    var del = ViewController()
    func alarmWasToggled(sender: AlarmTableViewCell, ison: Bool) {
        let indexPath = self.tableView.indexPath(for: sender)
        del.toggleEnabled(index: indexPath!.row)
    }
    let context = (UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    var alarmo = [Alarm]()
    var smstext2 : String = ""
    var contArray = [CONTACTS]()
    var reminderstoto = [EKReminder]()
    var Seguesty : String = ""
    var url: NSURL!
    let eventStore : EKEventStore = EKEventStore()
    lazy var reminder : EKReminder = EKReminder(eventStore: eventStore)
    var events: [EKEvent]?
    var calendars: [EKCalendar]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        LoadAlarm()
        prepareToLoadReminders()
        prepareToLoadCalendar()
    }
    func prepareToLoadReminders(){
        let predict = eventStore.predicateForReminders(in: calendars)
        eventStore.fetchReminders(matching: predict) { (reminders) in
            self .reminderstoto = reminders!
        }}
    func prepareToLoadCalendar()  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.calendars = eventStore.calendars(for: EKEntityType.event)
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = dateFormatter.date(from: "2019/05/04 04:00")
        let endDate = dateFormatter.date(from: "2019/05/05 20:00")
        let prediacte = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: calendars!)
        self.events = eventStore.events(matching: prediacte)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
        print(contArray.count)
            return contArray.count}
        else if Seguesty == "reminderSegue"{
            print(reminderstoto.count ?? 0)
            return (reminderstoto.count ?? 0)
        }else if Seguesty == "eventSegue"{
            print(events?.count)
            return (events?.count)!
        }else if Seguesty == "alarmSegue"{
            return alarmo.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "oneCell", for: indexPath) as! AlarmTableViewCell
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{

        cell.nameLabel!.text = contArray[indexPath.row].fullname
        cell.timeLabel!.text = contArray[indexPath.row].number
        cell.alarmSwitch.isHidden = true
        }else if Seguesty == "reminderSegue"{
            var datecomp = reminderstoto[indexPath.row].dueDateComponents
            cell.nameLabel!.text = reminderstoto[indexPath.row].title
            print("\(datecomp?.year ?? 0)")
           cell.timeLabel!.text = "\(datecomp?.year ?? 0)/\(datecomp?.month ?? 0)/\(datecomp?.day ?? 0)          \(datecomp?.hour ?? 0):\(datecomp?.minute ?? 0)"
            cell.alarmSwitch.isHidden = true
        }else if Seguesty == "eventSegue"{
            cell.nameLabel!.text = events?[indexPath.row].title
            cell.timeLabel!.text = "\(events?[indexPath.row].endDate ?? Date())"
            cell.alarmSwitch.isHidden = true
        }else if Seguesty == "alarmSegue"{
            
            cell.nameLabel!.text = alarmo[indexPath.row].name
            cell.timeLabel!.text = alarmo[indexPath.row].stringofDate
            cell.alarmSwitch.isOn = alarmo[indexPath.row].enabled
            cell.delegatess = self
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Seguesty == "eventSegue"{
             gotoAppleCalendar(date: events?[indexPath.row].startDate as! NSDate)
        }else if Seguesty == "callSegue"{
           contArray[indexPath.row].number = contArray[indexPath.row].number.replacingOccurrences(of: " ", with: "")
            url = URL(string: "telprompt://\(contArray[indexPath.row].number)")! as NSURL
             UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)}
    else if Seguesty == "smsSegue"{
    contArray[indexPath.row].number = contArray[indexPath.row].number.replacingOccurrences(of: " ", with: "")
    url = URL(string: "sms://\(contArray[indexPath.row].number)&body=\(smstext2)")! as NSURL
    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    }
    func gotoAppleCalendar(date: NSDate) {
        let interval = date.timeIntervalSinceReferenceDate
        let url = NSURL(string: "calshow:\(interval)")!
        UIApplication.shared.openURL(url as URL)
    }
    func LoadAlarm(){
        let request : NSFetchRequest<Alarm>=Alarm.fetchRequest()
        do{
            alarmo = try context.fetch(request)
        }catch {
            print("Error fetching")
        }
    }
}
