//
//  CalendarViewController.swift
//  Diagnosix
//
//  Created by Aron Gates on 11/24/16.
//  Copyright © 2016 Aron Gates. All rights reserved.
//

import UIKit
import SwiftyJSON
import JTAppleCalendar
import PopupDialog

class CalendarViewController: UIViewController {
    
    // the calendar itself
    @IBOutlet weak var calendarView : JTAppleCalendarView!
    
    // the desscription of the event
    @IBOutlet weak var eventLabel : UILabel!
    
    // the current month
    @IBOutlet weak var currentMonth : UILabel!
    
    // reference to popup add to calendar button
    weak var addCalendarButton: DefaultButton!
    
    // the location of the appointment
    var location : String!
    
    // formatting dates in yyyy/M/d
    let formatter = DateFormatter()
    
    // data passed from diagnosis controller
    var events : JSON! = nil
    
    // colors of calendar
    let eventColor = UIColor(hex: "FC3A00")
    let eventAddedColor = UIColor(hex: "3AD700")
    let selectedColor = UIColor(hex: "CEF7F9")
    let todaysDateColor = UIColor(hex: "FCCA3E")
    let selectedColorText = UIColor.blue
    let inMonthNotSelectedColorText = UIColor.black
    let outMonthNotSelectedColorText = UIColor.gray
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy/M/d"
        
        calendarView.center = self.view.center
        
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView")  // Registering your cell is manditory
        calendarView.cellInset = CGPoint(x: 0, y: 0)        // default is (3,3)
        
        let singleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTapCollectionView(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1           // add single tap
        calendarView.addGestureRecognizer(singleTapGesture)
        
        addCalendarButton.isEnabled = false
        addCalendarButton.defaultTitleColor = UIColor(hex: "aaaaaa")
        addCalendarButton.titleColor = self.addCalendarButton.defaultTitleColor
        addCalendarButton.separatorColor = self.addCalendarButton.defaultSeparatorColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Success!", message: "Your event has been added to your reminders.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        calendarView.selectDates(calendarView.selectedDates)
    }
    
    func findValue(json : JSON, key : String, value : String) -> Int {
        
        for (jsonKey, date) in json
        {
            if date[key].stringValue == value
            {
                return Int(jsonKey)!
            }
        }
        return -1
    }
    
    func didSingleTapCollectionView(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        let cellState = calendarView.cellStatus(at: point)
        calendarView.selectDates([cellState!.date])
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState) {
        
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected && cellState.dateBelongsTo == .thisMonth {
            myCustomCell.dayLabel.textColor = selectedColorText
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = inMonthNotSelectedColorText
            } else {
                myCustomCell.dayLabel.textColor = outMonthNotSelectedColorText
            }
        }
    }
    
    // Function to handle what cells will appear as what
    func handleCellDisplay(view: JTAppleDayCellView?, cellState: CellState) {
        
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        myCustomCell.selectedView.isHidden = true
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.dayLabel.textColor = inMonthNotSelectedColorText
        } else {
            myCustomCell.dayLabel.textColor = outMonthNotSelectedColorText
        }
        
        calendarView.deselectAllDates()
        
        if cellState.dateBelongsTo != .thisMonth {
            return
        }
        
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.isUserInteractionEnabled = true
        } else {
            myCustomCell.isUserInteractionEnabled = false
        }
        
        let currentDateString = formatter.string(from: Date())
        let cellStateDateString = formatter.string(from: cellState.date)
        
        if currentDateString == cellStateDateString {
            myCustomCell.selectedView.backgroundColor = todaysDateColor
            myCustomCell.selectedView.layer.cornerRadius = myCustomCell.selectedView.frame.size.width / 2
            myCustomCell.clipsToBounds = false
            myCustomCell.selectedView.isHidden = false
        }
        
        let eventKey = findValue(json: events, key: "Event_Date", value: cellStateDateString)
        if eventKey != -1 {
            myCustomCell.selectedView.layer.cornerRadius = myCustomCell.selectedView.frame.size.width / 2
            myCustomCell.clipsToBounds = false
            myCustomCell.selectedView.isHidden = false
            let sampleText = events[eventKey]["Event_Text"].stringValue + "\n" + location
            let reminderHelper = AppleReminderHelper(title: "PlainDoc Reminder", notes: sampleText, dueDate: cellState.date)
            reminderHelper.doesExist() { result in
                DispatchQueue.main.async {
                    if !result {
                        if !cellState.isSelected {
                            myCustomCell.selectedView.backgroundColor = self.eventColor
                        }
                    }
                    else {
                        if !cellState.isSelected {
                            myCustomCell.selectedView.backgroundColor = self.eventAddedColor
                        }
                    }
                }
            }
        }
    }
    
    // Function to handle the calendar deselction
    func handleCellDeselection(view: JTAppleDayCellView?, cellState: CellState) {
        
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        addCalendarButton.titleColor = self.addCalendarButton.defaultTitleColor
        addCalendarButton.separatorColor = self.addCalendarButton.defaultSeparatorColor
        addCalendarButton.isEnabled = false
        eventLabel.fadeOut()
        
        myCustomCell.selectedView.isHidden = true
        handleCellDisplay(view: view, cellState: cellState)
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
        
        if cellState.dateBelongsTo != .thisMonth {
            return
        }
        
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        let cellStateDateString = formatter.string(from: cellState.date)
        
        let eventKey = findValue(json: events, key: "Event_Date", value: cellStateDateString)
        if eventKey != -1 {
            let sampleText = events[eventKey]["Event_Text"].stringValue + "\n" + location
            let reminderHelper = AppleReminderHelper(title: "PlainDoc Reminder", notes: sampleText, dueDate: cellState.date)
            reminderHelper.doesExist() { result in
                DispatchQueue.main.async {
                    if !result {
                        self.addCalendarButton.titleColor = self.eventColor
                        self.addCalendarButton.separatorColor = self.eventColor
                        if !cellState.isSelected {
                            myCustomCell.selectedView.backgroundColor = self.eventColor
                        }
                        self.addCalendarButton.isEnabled = true
                        self.eventLabel.text = sampleText
                        self.eventLabel.fadeIn()
                    }
                    else {
                        self.addCalendarButton.titleColor = self.addCalendarButton.defaultTitleColor
                        self.addCalendarButton.separatorColor = self.addCalendarButton.defaultSeparatorColor
                        if !cellState.isSelected {
                            myCustomCell.selectedView.backgroundColor = self.eventAddedColor
                        }
                        self.addCalendarButton.isEnabled = false
                        self.eventLabel.text = sampleText + "\nReminder already added!"
                        self.eventLabel.fadeIn()
                    }
                }
            }
        }
        
        if cellState.isSelected {
            myCustomCell.selectedView.backgroundColor = selectedColor
            myCustomCell.selectedView.layer.cornerRadius = myCustomCell.selectedView.frame.size.width / 2
            myCustomCell.clipsToBounds = false
            myCustomCell.selectedView.isHidden = false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let month = Calendar.current.dateComponents([.month], from: visibleDates.monthDates[0]).month!
        currentMonth.text = switchMonth(month: month)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func switchMonth(month: Int) -> String {
        switch month {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return "oops"
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        let month = Calendar.current.dateComponents([.month], from: Date()).month!
        currentMonth.text = switchMonth(month: month)

        let startDate = Date()                              // You can use date generated from a formatter
        let endDate = formatter.date(from: "2100/2/1")!   // You can also use dates created from this function
        let calendar = Calendar.current                     // Make sure you set this up to your time zone. We'll just use default here
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: calendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        
        let myCustomCell = cell as! CellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellDisplay(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        
        handleCellDeselection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
}
