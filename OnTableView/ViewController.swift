//
//  ViewController.swift
//  OnTableView
//
//  Created by phoebeezzat on 4/28/19.
//  Copyright © 2019 phoebe. All rights reserved.
//

import UIKit
import Contacts
import EventKit
import CoreData
import UserNotifications
protocol AlarmScheduler: class{
    func scheduleUserNotification(for alarm: Alarm)
    func cancelUserNotification(for alarm: Alarm)
}

class ViewController: UIViewController ,AlarmScheduler,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    lazy var evet : EKEvent = EKEvent(eventStore: eventStore);
    var events: [EKEvent]?
    var filterdItemsArray = [CONTACTS]()
    var fetcontacts : [CONTACTS] = []
    var contactdic : [String] = []
    let fileURL = "/Users/phoebeezzat/Desktop/test.txt"
    var arrayOfStrings : [String] = []
    var urls : NSURL!
    var smstext : String = "hello dora hhhjg  fghdrj"
    var searchGoogle : String = ""
    let eventStore : EKEventStore = EKEventStore()
    lazy var reminder : EKReminder = EKReminder(eventStore: eventStore)
    var remindersto = [EKReminder]()
    var calendars: [EKCalendar]?
    let context = (UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    var alarmo = [Alarm]()
    let formatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         fetchcontacts()
      LoadAlarm()
    }
    @IBAction func addAlarm(_ sender: UIButton) {
        formatter.dateFormat = "HH:mm"
        let DateTime = formatter.date(from: "11:11");
        create(name: "myAlarm", fireDate: DateTime!, enabled: true)
    }
    @IBAction func removeAlarm(_ sender:UIButton) {
        formatter.dateFormat = "HH:mm"
        let DateTime = formatter.date(from: "11:11");
        
        delete(date: DateTime!)
        
    }
    //done
    @IBAction func updateAlarm(_ sender: UIButton) {
        formatter.dateFormat = "HH:mm"
        let DateTime = formatter.date(from: "11:11");
        let NEWdate = formatter.date(from: "06:30");
        changeDate(newDate: NEWdate!, fireDate: DateTime!)
    }
    @IBAction func updateEnableAlarm(_ sender: UIButton) {
        formatter.dateFormat = "HH:mm"
        let DateTime = formatter.date(from: "06:30");
        changeenabled(enabled: false, fireDate: DateTime!)
    }
    func create(name: String, fireDate: Date, enabled: Bool){
        //initialize the alarm
        let alarm = Alarm(context: context)
        alarm.fireDate = fireDate
        alarm.name = name
        alarm.enabled = enabled
        alarm.uuid = UUID().uuidString
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        alarm.stringofDate =  formatter.string(from: fireDate)
        (UIApplication.shared.delegate as! AppDelegate ).saveContext()
        
        //to be added global
        //yratb al notification bta3t alarm
        scheduleUserNotification(for: alarm)
        
        
    }
    //fhmthaaa
    func changeDate(newDate: Date,  fireDate: Date) {
        
        var coun : Int = 0
        //cancelUserNotification(for: alarm)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        LoadAlarm()
        for alarm in alarmo{
            
            if alarm.stringofDate == formatter.string(from: fireDate){
                cancelUserNotification(for: alarm)
                alarm.fireDate = newDate
                scheduleUserNotification(for: alarm)
                alarm.stringofDate =  formatter.string(from: newDate)
                (UIApplication.shared.delegate as! AppDelegate ).saveContext()
                
            }else{
                coun += 1
            }
            if(coun == alarmo.count){
                let alert = UIAlertController(title: "alarm couldn't find", message: "no matched date", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        //  scheduleUserNotification(for: alarm)
    }
    func changeenabled(enabled: Bool,  fireDate: Date){
        var coun : Int = 0
        //cancelUserNotification(for: alarm)
        LoadAlarm()
        for alarm in alarmo{
            if alarm.fireDate == fireDate{
                cancelUserNotification(for: alarm)
                alarm.enabled = enabled
                if alarm.enabled{
                    scheduleUserNotification(for: alarm)
                }else{
                    cancelUserNotification(for: alarm)
                }
                
                (UIApplication.shared.delegate as! AppDelegate ).saveContext()
                
            }else{
                coun += 1
            }
            if(coun == alarmo.count){
                let alert = UIAlertController(title: "alarm couldn't find", message: "no matched date", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }}
    
    //fhmtha
    func delete(date: Date){
        var coun : Int = 0
        LoadAlarm()
        for alarm in alarmo{
            if alarm.fireDate == date{
                cancelUserNotification(for: alarm)
                context.delete(alarm)
                (UIApplication.shared.delegate as! AppDelegate ).saveContext()
                //saveToPersistentStore()
            }else{   coun += 1
            }
            if (coun == alarmo.count){
                let alert = UIAlertController(title: "alarm couldn't delete", message: "no matched date", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            (UIApplication.shared.delegate as! AppDelegate ).saveContext()
        }
        
        
        
    }
    //fhmtha
    func toggleEnabled(index: Int ){
        print("yes")
        LoadAlarm()
        alarmo[index].enabled = !alarmo[index].enabled
        if alarmo[index].enabled{
            scheduleUserNotification(for: alarmo[index])
        }else{
            cancelUserNotification(for: alarmo[index])
        }
        (UIApplication.shared.delegate as! AppDelegate ).saveContext()
        
    }
    func LoadAlarm(){
        let request : NSFetchRequest<Alarm>=Alarm.fetchRequest()
        do{
            alarmo = try context.fetch(request)
        }catch {
            print("Error fetching")
        }
        for alarm in alarmo{
            print(alarm.enabled)
        }
    }
    func fetchcontacts() {
        
        let ContactStore = CNContactStore()
        let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
        let fetchreq = CNContactFetchRequest.init(keysToFetch: keys as [CNKeyDescriptor] )
        do{
            try ContactStore.enumerateContacts(with: fetchreq) { (contact, end) in
                let datacontant = CONTACTS(NAME: "\(contact.givenName) \(contact.familyName)", phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "400")
                self.fetcontacts.append(datacontant)
                //    let dict = [ datacontant.fullname: datacontant.number]
                //    self.contactdic.append(dict)
                print(contact.givenName)
                print(contact.phoneNumbers.first?.value.stringValue ?? "")
            }}
        catch{
            print("failed to fetch")
        }
        
    }
    func filterContentForSearchText(searchText: String)  {
        filterdItemsArray = fetcontacts.filter { item in
            return item.fullname.lowercased().contains(searchText.lowercased())
        }
    }
    
    
    func searchForSimilarContacts(){
        do{
            /*let contents = try NSString(contentsOfFile: fileURL, encoding: String.Encoding.utf8.rawValue)
            let texttoread = contents as String
            arrayOfStrings = texttoread.components(separatedBy: " ");*/
            //print("bb \(arrayOfStrings.count)")
            filterContentForSearchText(searchText: /*arrayOfStrings[1]*/ "andrew")
            
            if filterdItemsArray.count == 2 {
                print(filterdItemsArray[0].fullname)
                print(filterdItemsArray[0].number)
            }
            
            //print(" the text is \(contents)")
        } catch  {
            print("An error took place: \(error)")
        }    }
    
   
    @IBAction func camera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage]as? UIImage{
    UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
            let alert = UIAlertController(title: "saved", message: "yourimage has been saved", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(okAction)
          present(alert,animated: true , completion: nil)
        }
    }
    @IBAction func Photos(_ sender: UIButton) {
        let url : NSURL = URL(string: "photos-redirect://")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    @IBAction func callCont(_ sender: Any) {
       
        searchForSimilarContacts()
        print(filterdItemsArray.count)
        if filterdItemsArray.count == 1{
            print("\(filterdItemsArray[0].number)")
          /*  if let phoneCallURL  = NSURL(string: "tel//:\(filterdItemsArray[0].number)") {
                UIApplication.shared.open(phoneCallURL as URL, options: [:], completionHandler: nil)*/
    filterdItemsArray[0].number = filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
              print("\(filterdItemsArray[0].number)")
            let url : NSURL = URL(string: "tel://\(filterdItemsArray[0].number)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "callSegue", sender: self)}
        else {
            createcontactAlert(title: "not found ", message: "no matched name of contact found")
        }
    }
    func createcontactAlert (title : String , message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func sendSMS(_ sender: Any) {
        searchForSimilarContacts()
        if filterdItemsArray.count == 1{
            filterdItemsArray[0].number = filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
            print(smstext)
            guard let escapedBody = smstext.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return
            }
            let url : NSURL = URL(string: "sms://\(filterdItemsArray[0].number)&body=\(escapedBody)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "smsSegue", sender: self)}
        else {
            createcontactAlert(title: "not found ", message: "no matched name of contact found")
        }
    }
    @IBAction func add_reminder(_ sender: UIButton) {
        eventStore.requestAccess(to: EKEntityType.reminder) { (granted, error) in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                let reminder:EKReminder = EKReminder(eventStore: self.eventStore)
                reminder.title = "Must do this!"
                reminder.priority = 2
                reminder.notes = "...this is a note"
               
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let DateTime = formatter.date(from: "2019/05/04 15:56");
                //   let alarmTime = Date().addingTimeInterval(3*60)
              reminder.dueDateComponents = DateComponents(year: 2019, month: 05, day: 02, hour: 01, minute: 30)
                let alarm = EKAlarm(absoluteDate: DateTime!)
                reminder.addAlarm(alarm)
                
                reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                
                do {
                    try self.eventStore.save(reminder, commit: true)
                    
                } catch {
                    let alert = UIAlertController(title: "Reminder could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                print("Reminder saved")
            }
        }
    }
    @IBAction func remove_reminder(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        //let DateTime = formatter.date(from: "2019/03/15 05:00");
       // let component = DateComponents(year: 2019, month: 3, day: 15, hour: 05, minute: 00)
       // print(component)
        let predict = eventStore.predicateForReminders(in: calendars)
        let text = "specialization"
       eventStore.fetchReminders(matching: predict) { (reminders) in
            for remind in reminders! {
                if remind.title.lowercased().contains(text.lowercased()){
                    do{
                       // remind.isCompleted = true
                       try self.eventStore.remove(remind, commit: true)
                       print("yes")
                    }catch{
                        let alert = UIAlertController(title: "Reminder could not find", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }else{
                    print("no")
                }
            }
        }
    }
    
    @IBAction func googleSearch(_ sender: UIButton) {
        searchGoogle = "install python"
        searchGoogle = searchGoogle.replacingOccurrences(of: " ", with: "+")
        let url = NSURL(string: "http://www.google.com/search?q=\(searchGoogle)")
        UIApplication.shared.openURL(url! as URL)
        //stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSString.CompareOptions.LiteralSearch, range: nil)
    }
    @IBAction func Add_event(_ sender: UIButton) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil ){
                print("granted\(granted)")
                
                self.evet.title = "Add event lololololoy"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let startDateTime = formatter.date(from: "2019/05/04 16:30");
                self.evet.startDate = startDateTime
                let endDateTime = formatter.date(from: "2019/05/04 19:00");
                self.evet.endDate = endDateTime
                // let alaram = EKAlarm(relativeOffset: 0)
                //  evet.alarms = [alaram]
                self.evet.addAlarm(.init(relativeOffset: -5*60))
                self.evet.notes = "This is note"
                self.evet.calendar = self.eventStore.defaultCalendarForNewEvents
                do{
                    try self.eventStore.save(self.evet, span: .thisEvent)
                }catch let error as NSError{
                    let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                print("Save Event")
            }else{
                print ("error is \(error)")
            }
        }
    }
    @IBAction func Remove_event(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.calendars = eventStore.calendars(for: EKEntityType.event)
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = dateFormatter.date(from: "2019/05/04 16:00")
        let endDate = dateFormatter.date(from: "2019/05/05 20:00")
        let prediacte = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: calendars!)
        self.events = eventStore.events(matching: prediacte)
        for i in events! {
            deleteevent(event: i)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! oneTableViewController
         destination.contArray = filterdItemsArray
        if segue.identifier == "callSegue"{
            destination.Seguesty = segue.identifier!
        }else if segue.identifier == "smsSegue"{
            guard let escapedBody = smstext.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return
            }
            destination.smstext2 = escapedBody
            destination.Seguesty = segue.identifier!
        }else if segue.identifier == "reminderSegue"{
            destination.Seguesty = segue.identifier!
            urls = URL(string: "x-apple-reminder://")! as NSURL
            destination.url = urls
        }else if segue.identifier == "eventSegue" || segue.identifier == "alarmSegue" {
            destination.Seguesty  = segue.identifier!
            
        }
    }
    func deleteevent(event : EKEvent){
        do{
            try eventStore.remove(event, span: EKSpan.thisEvent, commit: true)
            
        }catch{
            print("Error while deleting event: \(error.localizedDescription)")
        }
    }
}
extension AlarmScheduler{
    // to push notification
    func scheduleUserNotification(for alarm: Alarm){
        
        let content = UNMutableNotificationContent()
        content.title = "Time to get up"
        content.body = "Your alarm named \(alarm.name!) is going off!"
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: alarm.fireDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: alarm.uuid!, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error{
                print("Error scheduling local user notifications \(error.localizedDescription)  :  \(error)")
            }
        }
        
    }
    
    func cancelUserNotification(for alarm: Alarm){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.uuid!])
    }
}


