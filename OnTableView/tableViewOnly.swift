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
class oneTableViewController : UITableViewController {
    var contArray = [CONTACTS]()
    var reminderstoto : [EKReminder]?
    var Seguesty : String = ""
    var url: NSURL!
    let eventStore : EKEventStore = EKEventStore()
    lazy var reminder : EKReminder = EKReminder(eventStore: eventStore)
    var events: [EKEvent]?
    var calendars: [EKCalendar]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        prepareToLoadReminders()
        prepareToLoadCalendar()
    }
    func prepareToLoadReminders(){
        let predict = eventStore.predicateForReminders(in: calendars)
        eventStore.fetchReminders(matching: predict) { (reminders) in
            self .reminderstoto = reminders
        }}
    func prepareToLoadCalendar()  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.calendars = eventStore.calendars(for: EKEntityType.event)
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = dateFormatter.date(from: "2019/03/15 04:00")
        let endDate = dateFormatter.date(from: "2019/03/17 20:00")
        let prediacte = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: calendars!)
        self.events = eventStore.events(matching: prediacte)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
        print(contArray.count)
            return contArray.count}
        else if Seguesty == "reminderSegue"{
         print(reminderstoto?.count ?? 0)
            return (reminderstoto?.count ?? 0)
        }else if Seguesty == "eventSegue"{
            return (events?.count)!
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oneCell", for: indexPath)
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{

        cell.textLabel?.text = contArray[indexPath.row].fullname
        }else if Seguesty == "reminderSegue"{
            cell.textLabel?.text = reminderstoto?[indexPath.row].title
        }else if Seguesty == "eventSegue"{
            cell.textLabel?.text = events?[indexPath.row].title
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Seguesty == "eventSegue"{
             gotoAppleCalendar(date: events?[indexPath.row].startDate as! NSDate)
        }else{
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)}
    }
    func gotoAppleCalendar(date: NSDate) {
        let interval = date.timeIntervalSinceReferenceDate
        let url = NSURL(string: "calshow:\(interval)")!
        UIApplication.shared.openURL(url as URL)
    }
}
