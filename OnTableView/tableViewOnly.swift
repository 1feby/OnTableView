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
import MediaPlayer
import SwiftyJSON
import Alamofire
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
    var wikititle = [String]()
    var wikidesc = [String]()
    var wikiimage = [UIImage]()
    var datawiki = [JSON]()
    var viewcont = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       LoadAlarm()
        prepareToLoadReminders()
        prepareToLoadCalendar()
       // loadPlaylists()
   
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
        }else if Seguesty == "wikiSegue"{
            print("mggm : \(wikititle.count)")
            print("mggf : \(wikidesc.count)")
            print("mggm : \(wikiimage.count)")
            return (datawiki.count)
            
        }
        /*else if Seguesty == "MusicSegue"{
        return viewcont.playlistTitle.count        }*/
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "oneCell", for: indexPath) as! AlarmTableViewCell
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{

        cell.nameLabel!.text = contArray[indexPath.row].fullname
        cell.timeLabel!.text = contArray[indexPath.row].number
        cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "reminderSegue"{
            var datecomp = reminderstoto[indexPath.row].dueDateComponents
            cell.nameLabel!.text = reminderstoto[indexPath.row].title
            print("\(datecomp?.year ?? 0)")
           cell.timeLabel!.text = "\(datecomp?.year ?? 0)/\(datecomp?.month ?? 0)/\(datecomp?.day ?? 0)          \(datecomp?.hour ?? 0):\(datecomp?.minute ?? 0)"
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "eventSegue"{
            cell.nameLabel!.text = events?[indexPath.row].title
            cell.timeLabel!.text = "\(events?[indexPath.row].endDate ?? Date())"
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "alarmSegue"{
            
            cell.nameLabel!.text = alarmo[indexPath.row].name
            cell.timeLabel!.text = alarmo[indexPath.row].stringofDate
            cell.alarmSwitch.isOn = alarmo[indexPath.row].enabled
            cell.wikiImage.isHidden = true
            cell.delegatess = self
        }else if Seguesty == "wikiSegue" {
            print("iddi")
            cell.nameLabel!.text = wikititle[indexPath.row]
            cell.timeLabel!.text = wikidesc[indexPath.row]
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.image = wikiimage[indexPath.row]
        }
        /*else if Seguesty == "MusicSegue"{
            cell.nameLabel.text = viewcont.playlistTitle[indexPath.row]
            cell.timeLabel.text = "\(viewcont.numberOfSongs[indexPath.row]) songs"
            cell.alarmSwitch.isHidden = true
        }*/
        
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
        }else if Seguesty == "wikiSegue"{
            print("\(wikititle[indexPath.row])")
            var wikiSearch = wikititle[indexPath.row].replacingOccurrences(of: " ", with: "_")
            let url = NSURL(string: "https://en.wikipedia.org/wiki/\(wikiSearch)")
             UIApplication.shared.openURL(url! as URL)
        }
        /*else if Seguesty == "MusicSegue"{
            viewcont.myMediaPlayer.setQueue(with: viewcont.playlists![indexPath.row])
            // Start playing from the beginning of the queue
            viewcont.myMediaPlayer.play()
        }*/
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
