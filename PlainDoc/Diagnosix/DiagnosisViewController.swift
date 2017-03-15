//
//  DiagnosisViewController.swift
//  Diagnosix
//
//  Created by Aron Gates on 10/22/16.
//  Copyright © 2016 Aron Gates. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PopupDialog
import MapKit
import CoreLocation
import SideMenu
import JTAppleCalendar
import Font_Awesome_Swift

class DiagnosisViewController: MenuItem, CLLocationManagerDelegate {
    
    // footer view with its buttons
    @IBOutlet weak var footerView: UIView!
    
    // our header image
    @IBOutlet weak var funImage: UIImageView!
    
    // lets us figure out the proximity of the nearest doctors
    let locationManager = CLLocationManager()
    
    // action buttons
    @IBOutlet weak var findSpecialistsButton: UIButton!
    @IBOutlet weak var showCalendarButton: UIButton!
    
    // manually set by segues
    var comeFromHome : Bool! = false
    var appointmentID : Int!
    
    // info set from https request
    var swiftyJsonVar : JSON!
    
    // our info boxes
    @IBOutlet weak var textHeaderView: UIView!
    @IBOutlet weak var textInfoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameName: UILabel!
    @IBOutlet weak var profName: UILabel!
    @IBOutlet weak var descriptionBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.hideCancelsScheduledSpinners = true
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        textInfoView.layer.masksToBounds = false
        textInfoView.layer.shadowRadius = 2.0
        textInfoView.layer.shadowColor = UIColor.gray.cgColor
        textInfoView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textInfoView.layer.shadowOpacity = 0.75
        
        textHeaderView.layer.masksToBounds = false
        textHeaderView.layer.shadowRadius = 2.0
        textHeaderView.layer.shadowColor = UIColor.gray.cgColor
        textHeaderView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textHeaderView.layer.shadowOpacity = 0.75
        
        navigationItem.titleView?.alpha = 0
        self.titleLabel.alpha = 0
        self.nameName.alpha = 0
        self.profName.alpha = 0
        self.descriptionBox.alpha = 0
        self.findSpecialistsButton.alpha = 0
        self.showCalendarButton.alpha = 0
        self.funImage.alpha = 0
        for subview in self.footerView.subviews {
            subview.alpha = 0
        }
        
        let search = UIImage(icon: .FASearchPlus, size: CGSize(width: 40, height: 40), textColor: UIColor(hex: "FC4A1A"), backgroundColor: .clear)
        findSpecialistsButton.setImage(search, for: .normal)
        
        let calendar = UIImage(icon: .FACalendarCheckO, size: CGSize(width: 40, height: 40), textColor: UIColor(hex: "FC4A1A"), backgroundColor: .clear)
        showCalendarButton.setImage(calendar, for: .normal)
        
        // hard code magic bc constrains fucking SUCK
        if self.view.frame.width == 320.0 {
            footerView.subviews[1].frame.origin.x = 94
            footerView.subviews[2].frame.origin.x = 174
            footerView.subviews[3].frame.origin.x = 254
            footerView.subviews[5].frame.origin.x = footerView.subviews[1].frame.origin.x - 5
            footerView.subviews[6].frame.origin.x = footerView.subviews[2].frame.origin.x - 6
            footerView.subviews[7].frame.origin.x = footerView.subviews[3].frame.origin.x - 12
        }
    }
    
    func fadeInCollection() {
        
        self.navigationItem.titleView?.fadeIn()
        self.titleLabel.fadeIn()
        self.nameName.fadeIn()
        self.profName.fadeIn()
        self.descriptionBox.fadeIn()
        self.findSpecialistsButton.fadeIn()
        self.showCalendarButton.fadeIn()
        self.funImage.fadeIn()
        for subview in self.footerView.subviews {
            subview.fadeIn()
        }
        
    }
    
    var locValue:CLLocationCoordinate2D? = nil
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate
    }
    
    fileprivate func findValue(names: JSON, contains: String) -> Bool {
        for (_, value) in names
        {
            for (_, name) in value
            {
                for (question, _) in name
                {
                    if question == contains
                    {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(!comeFromHome)
        {
            SwiftSpinner.show(progress: 0.0, title: "Getting stored results...")   // 0% through the process
        }
        else
        {
            let when = DispatchTime.now()
            let increment = 0.45
            
            SwiftSpinner.show(progress: 0.0, title: "Analyzing Unstructured Data...")   // 0% through the process
            
            DispatchQueue.main.asyncAfter(deadline: when + 1*increment) {
                SwiftSpinner.show(progress: 0.2, title: "Structuring Data...")          // 20% through the process
            }
            DispatchQueue.main.asyncAfter(deadline: when + 2*increment) {
                SwiftSpinner.show(progress: 0.4, title: "Applying Algorithms...")       // 40% through the process
            }
            DispatchQueue.main.asyncAfter(deadline: when + 3*increment) {
                SwiftSpinner.show(progress: 0.6, title: "Searching for Literacy...")    // 60% through the process
            }
            DispatchQueue.main.asyncAfter(deadline: when + 4*increment) {
                SwiftSpinner.show(progress: 0.8, title: "Receiving Structured Data...") // 80% through the process
            }
            DispatchQueue.main.asyncAfter(deadline: when + 5*increment) {
                SwiftSpinner.show(progress: 1.0, title: "Success!")                     // 100% through the process
            }
            DispatchQueue.main.asyncAfter(deadline: when + 6*increment) {
                SwiftSpinner.hide()
                
                self.fadeInCollection()
            }
        }
        
        let when = DispatchTime.now()
        let increment = 0.35
        (navigationItem.titleView?.subviews[0] as! UIImageView).image = UIImage(named: "stethoscope.png")
        
        let parameters: Parameters = [
            "ID": self.appointmentID!.description,
            "user_id": self.userID!
        ]
        Alamofire.request("https://geczy.tech/plaindoc/endpoint/get_diagnosis.php", method: .post, parameters: parameters, encoding: JSONEncoding(options: [])).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                self.swiftyJsonVar = JSON(responseData.result.value!)
                self.titleLabel.text = "Transcript"
                self.nameName.text = self.swiftyJsonVar["Problems"][0].stringValue
                self.profName.text = self.swiftyJsonVar["Problems"][1].stringValue
                self.descriptionBox.text = self.swiftyJsonVar["Transcript"].stringValue
                if(!self.comeFromHome)
                {
                    DispatchQueue.main.asyncAfter(deadline: when + 2*increment) {
                        SwiftSpinner.show(progress: 1.0, title: "Got it!")          // 100% through the process
                    }
                    DispatchQueue.main.asyncAfter(deadline: when + 2.5*increment) {
                        SwiftSpinner.hide()
                        
                        if self.swiftyJsonVar["Events"].isEmpty {
                            self.showCalendarButton.isEnabled = false
                            let calendar = UIImage(icon: .FACalendarTimesO, size: CGSize(width: 40, height: 40), textColor: .gray, backgroundColor: .clear)
                            self.showCalendarButton.setImage(calendar, for: .normal)
                        }
                        
                        self.fadeInCollection()
                    }
                }
            }
            else
            {
                SwiftSpinner.show("Failed! Check your internet connection.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    SwiftSpinner.hide()
                    self.performSegue(withIdentifier: "toRecord", sender: self)
                }
            }
        }
        
    }
    
    @IBAction func displayCalendar() {
        
        // Create a custom view controller
        let calendarVC = CalendarViewController(nibName: "CalendarView", bundle: nil)
        calendarVC.events = self.swiftyJsonVar["Events"]
        calendarVC.location = self.swiftyJsonVar["Location"].stringValue
        
        // Create first button
        let buttonOne = CancelButton(title: "BACK") {
            
        }
        
        // Button to add event to calendar
        let addCalendarButton = DefaultButton(title: "ADD TO REMINDERS", height: 60, dismissOnTap: false) {
            let selectedDate = calendarVC.calendarView.selectedDates[0]
            let reminderHelper = AppleReminderHelper(title: "PlainDoc Reminder", notes: calendarVC.eventLabel.text!, dueDate: selectedDate)
            if reminderHelper.checkPermission() != 1 {
                if reminderHelper.requestAccessToReminders() == 1 {
                    reminderHelper.addAppleReminders()
                    calendarVC.showSuccessAlert()
                }
                else {
                    return
                }
            }
            else {
                reminderHelper.addAppleReminders()
                calendarVC.showSuccessAlert()
            }
        }
        
        // Add reference to button in calendar VC
        calendarVC.addCalendarButton = addCalendarButton
        
        // Create the dialog
        let popup = PopupDialog(viewController: calendarVC, buttonAlignment: .vertical, transitionStyle: .bounceUp, gestureDismissal: true)
        
        // Add buttons to dialog
        popup.addButtons([addCalendarButton, buttonOne])
        
        // Loader animation
        SwiftSpinner.show("Loading calendar...")
        
        // Present dialog
        present(popup, animated: true) {
            SwiftSpinner.hide()
        }
    }
    
    @IBAction func findDoctors()
    {
        SwiftSpinner.show("Finding Doctors...")
        let title = "The top nearest doctors for " + profName.text!
        let message = "Here, you can choose and call the top Doctors - in YOUR area - for your specfic medical condition."
        let popup = PopupDialog(title: title, message: message)
        let cancel = CancelButton(title: "CANCEL"){
            
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer agates10@kent.edu:4Gy54wodlr8+r0HksBaxmg==",
            ]
        let medicalCondition = nameName.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)    
        
        if CLLocationManager.locationServicesEnabled()
        {
            let latitude = locValue!.latitude.description
            let longitude = locValue!.longitude.description
            
            Alamofire.request("https://api.betterdoctor.com/2016-03-01/doctors?query=\(medicalCondition)&location=\(latitude)%2C\(longitude)%2C100&user_location=\(latitude)%2C\(longitude)&sort=distance-asc&skip=0&limit=5&user_key=af2e13525d118fd842cfec5de0c9ce2b", method: .get, headers: headers).responseJSON {
                response in
                if(response.result.value != nil)
                {
                    let tokenResult = JSON(response.result.value!)
                    
                    var names : JSON = [:]
                    var index = 0
                    for (_, data) in tokenResult["data"]
                    {
                        for (_, practice) in data["practices"]
                        {
                            let name = practice["name"].stringValue
                            let milesAway = practice["distance"].intValue
                            let tel = practice["phones"][0]["number"].stringValue
                            if(practice["within_search_area"] == true && !self.findValue(names: names, contains: name))
                            {
                                names.appendIfDictionary(key: index, json: [String(milesAway) : [name : tel]])
                                index += 1
                            }
                        }
                    }
                    
                    let namesDic = names.dictionaryValue
                    let namesDicSorted = namesDic.sorted { Int(($0.value.dictionary?.keys.first)!)! < Int(($1.value.dictionary?.keys.first)!)! }
                    
                    index = 0
                    for (_, value) in namesDicSorted
                    {
                        if (index == 5)
                        {
                            break
                        }
                        let distance = value.dictionaryValue.first!.key
                        let name = value.dictionaryValue.first!.value.dictionaryValue.first!.key
                        let tel = value.dictionaryValue.first!.value.dictionaryValue.first!.value.stringValue
                        let button = DefaultButton(title: name + "\nDistance: " + distance + " miles away") {
                            let findDoctor : NSURL = NSURL(string: "tel://" + tel)!
                            UIApplication.shared.open(findDoctor as URL)
                        }
                        button.titleLabel!.numberOfLines = 2
                        button.titleLabel!.textAlignment = NSTextAlignment.center
                        popup.addButton(button)
                        index += 1
                    }
                    popup.addButton(cancel)
                    
                    // Present dialog
                    self.present(popup, animated: true) {
                        SwiftSpinner.hide()
                    }
                }
                else
                {
                    SwiftSpinner.show("Failed! Check your internet connection.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        popup.dismiss()
                        SwiftSpinner.hide()
                    }
                }
            }
        }
        else
        {
            SwiftSpinner.hide()
        }
    }

    @IBAction func chooseButton(sender button:UIButton)
    {
        self.descriptionBox.text = ""
        if (button.title(for: .normal) == "Transcript")
        {
            self.descriptionBox.text = self.swiftyJsonVar["Transcript"].stringValue
            self.titleLabel.text = "Transcript"
        }
        else if (button.title(for: .normal) == "TLDR")
        {
            self.descriptionBox.text = self.swiftyJsonVar["HealthAPI"]["DescriptionShort"].description
            self.titleLabel.text = "Summary"
        }
        else if (button.title(for: .normal) == "Symptoms")
        {
            for symptom in self.swiftyJsonVar["Symptoms"] {
                self.descriptionBox.text = self.descriptionBox.text + symptom.1.stringValue + ", "
            }
            if self.descriptionBox.text == "" {
                self.descriptionBox.text = "None found in transcript"
            }
            else {
                let endIndex = self.descriptionBox.text.index(self.descriptionBox.text.endIndex, offsetBy: -2)
                self.descriptionBox.text = self.descriptionBox.text.substring(to: endIndex)
            }
            self.titleLabel.text = "Symptoms"
        }
        else if (button.title(for: .normal) == "Prescriptions")
        {
            for symptom in self.swiftyJsonVar["Drugs"] {
                self.descriptionBox.text = self.descriptionBox.text + symptom.1.stringValue + ", "
            }
            if self.descriptionBox.text == "" {
                self.descriptionBox.text = "None found in transcript"
            }
            else {
                let endIndex = self.descriptionBox.text.index(self.descriptionBox.text.endIndex, offsetBy: -2)
                self.descriptionBox.text = self.descriptionBox.text.substring(to: endIndex)
            }
            self.titleLabel.text = "Prescriptions"
        }
        else if (button.title(for: .normal) == "Treatment")
        {
            for symptom in self.swiftyJsonVar["Plans"] {
                self.descriptionBox.text = self.descriptionBox.text + symptom.1.stringValue + ", "
            }
            if self.descriptionBox.text == "" {
                self.descriptionBox.text = "None found in transcript"
            }
            else {
                let endIndex = self.descriptionBox.text.index(self.descriptionBox.text.endIndex, offsetBy: -2)
                self.descriptionBox.text = self.descriptionBox.text.substring(to: endIndex)
            }
            self.titleLabel.text = "Treatment"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

