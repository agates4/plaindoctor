//
//  AppleCalendarHelper.swift
//
//  Created by Aron Gates on 11/27/16.
//  Copyright © 2016 Aron Gates. All rights reserved.
//

//  dont forget to add "Privacy - Calendars Usage Description" to info.plist
//  dont forget to add "Privacy - Reminders Usage Description" to info.plist

import EventKit
import UIKit

class AppleEventHelper
{
    private let appleEventStore = EKEventStore()
    private var givenTitle:String!
    private var givenNotes:String!
    private var givenStartDate:Date!
    private var givenEndDate:Date!
    private var isRule:Bool! = false
    
    init(title:String, notes:String, startDate:Date, endDate:Date, rule:Bool = false) {
        givenTitle = title
        givenNotes = notes
        givenStartDate = startDate
        givenEndDate = endDate
        isRule = rule
    }

    // 2 is not yet decided, 1 is yes, 0 is no
    func checkPermission() -> Int
    {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status)
        {
        case EKAuthorizationStatus.notDetermined:
            return 2
        case EKAuthorizationStatus.authorized:
            return 1
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            return 0
        }
    }
    func requestAccessToCalendars() {
        appleEventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                DispatchQueue.main.async {
                    print("User has access to event")
                }
            } else {
                DispatchQueue.main.async{
                    print("User has to change settings...goto settings to view access")
                }
            }
        }
    }
    func addAppleEvents()
    {
        let event:EKEvent = EKEvent(eventStore: appleEventStore)
        event.title = givenTitle
        event.startDate = givenStartDate
        event.endDate = givenEndDate
        event.notes = givenNotes
        
        if(isRule == true)
        {
            let rule = EKRecurrenceRule(recurrenceWith: .weekly,
                                        interval: 1,
                                        daysOfTheWeek: [EKRecurrenceDayOfWeek(.monday)],
                                        daysOfTheMonth: nil,
                                        monthsOfTheYear: nil,
                                        weeksOfTheYear: nil,
                                        daysOfTheYear: nil,
                                        setPositions: nil,
                                        end: nil)
            
            event.addRecurrenceRule(rule)
        }

        event.calendar = appleEventStore.defaultCalendarForNewEvents
        
        do {
            try appleEventStore.save(event, span: .thisEvent)
            print("events added with dates:")
        } catch let e as NSError {
            print(e.description)
            return
        }
        print("Saved Event")
    }
}

class AppleReminderHelper
{
    private let appleEventStore = EKEventStore()
    private let reminder:EKReminder!
    
    init(title:String, notes:String, dueDate:Date, rule:Bool = false) {
        reminder = EKReminder(eventStore: appleEventStore)
        reminder.title = title
        reminder.notes = notes
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.ReferenceType.local
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: dueDate)
        reminder.dueDateComponents = dateComponents
        
        if(rule == true)
        {
            let rule = EKRecurrenceRule(recurrenceWith: .weekly,
                                        interval: 1,
                                        daysOfTheWeek: [EKRecurrenceDayOfWeek(.monday)],
                                        daysOfTheMonth: nil,
                                        monthsOfTheYear: nil,
                                        weeksOfTheYear: nil,
                                        daysOfTheYear: nil,
                                        setPositions: nil,
                                        end: nil)
            reminder.addRecurrenceRule(rule)
        }
        reminder.calendar = appleEventStore.defaultCalendarForNewReminders()
    }
    
    // 2 is not yet decided, 1 is yes, 0 is no
    func checkPermission() -> Int
    {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        switch (status)
        {
        case EKAuthorizationStatus.notDetermined:
            return 2
        case EKAuthorizationStatus.authorized:
            return 1
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            return 0
        }
    }
    func requestAccessToReminders() -> Int {
        appleEventStore.requestAccess(to: .reminder) { (granted, error) in
            if (granted) && (error == nil) {
                DispatchQueue.main.async {
                    print("User has access to reminder")
                }
            } else {
                DispatchQueue.main.async{
                    print("User has to change settings...goto settings to view access")
                }
            }
        }
        return checkPermission()
    }
    func addAppleReminders()
    {
        do {
            try self.appleEventStore.save(reminder, commit: true)
        }catch{
            print("Error creating and saving new reminder : \(error)")
        }
        print("Saved Reminder")
    }
    
    func doesExist(result: @escaping (Bool) -> Void) {
        
        let fetchCalendarEvent = appleEventStore.predicateForReminders(in: [appleEventStore.defaultCalendarForNewReminders()])
        appleEventStore.fetchReminders(matching: fetchCalendarEvent) { oldReminders in
            
            for oldReminder in oldReminders! {
                if oldReminder.title == self.reminder.title && oldReminder.dueDateComponents!.date! == self.reminder.dueDateComponents!.date! && oldReminder.notes! == self.reminder.notes! {
                    result(true)
                    return
                }
            }
            result(false)
        }
        
    }
}

