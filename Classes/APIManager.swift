//
//  APIManager.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 7/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let trelloAPIKey = "your_API_Key"
let trelloToken = "your_Token"

func isoDate() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    
    return dateFormatter
}

let calendar = Calendar.current

func compareDates(current: Date, to: Date)->String{
    let timeTo = calendar.dateComponents([.day, .hour], from: current, to: to)
    let day = timeTo.day!
    let hour = timeTo.hour!
    var dayText = ""
    var hourText = ""
    var andText = "and "
    if abs(day) > 1{
        dayText = "\(abs(day)) days "
    }else if abs(day) == 1{
        dayText = "\(abs(day)) day "
    }else{
        andText = ""
    }
    if abs(hour) > 1{
        hourText = "\(abs(hour)) hours "
    }else if abs(hour) == 1{
        hourText = "\(abs(hour)) hour "
    }else{
        andText = ""
    }
    if day < 0 || hour < 0{
        return "\(dayText)\(andText)\(hourText)ago"
    }else if abs(day) == 0 && abs(hour) == 0{
        return "now"
    }else{
        return "in \(dayText)\(andText)\(hourText)"
    }
}

func getCalendarCollection(_ date: Date, _ index: Int)->([String], Int, Int){
    let reference = calendar.dateComponents([.year, .month, .day], from: date)
    var dateComponent = DateComponents()
    dateComponent.day = 1
    var newMonth = reference.month! + index
    dateComponent.year = reference.year!
    if newMonth < 0{
        newMonth = 12
        dateComponent.year = dateComponent.year! - 1
    }else if newMonth > 12{
        newMonth = 1
        dateComponent.year = dateComponent.year! + 1
    }
    dateComponent.month = newMonth

    let newDate = Calendar.current.date(from: dateComponent)
    let weekDay = calendar.dateComponents([.weekday, .month], from:
newDate!).weekday
    let monthRange = Calendar.current.range(of: .day, in: .month, for: newDate!)
    var result = [String]()
    for _ in 1...weekDay! - 1 {
        result.append("")
    }
    for i in 1...monthRange!.count{
        result.append(String(i))
    }
    for _ in 1...(35%result.count){
        result.append("")
    }
    return (result, newMonth, dateComponent.year!)
}


class APIManager{
    var teamDict = [String: Organisation]()
    var memberDict = [String: Member]()
    var actionsDict = [String: Action]()
    var functionDict = [Int: (ActionType, Action)->()]()
    var me:Member!
    var currentTeam:String?
    var currentTeamID:String?
    
    var batch:[String{
        didSet{
            if batch.count == 10{
                print("ok")
            }
        }
    }

    init(){
        functionDict[-1] = voidFunction(_:action:)
        functionDict[1] = createItem(_:action:)
        functionDict[2] = deleteItem(_:action:)
        functionDict[3] = moveItem(_:action:)
        functionDict[4] = updateItem(_:action:)
        batch = [String]()
    }
    
    func initiatePushNotificationSequence(token: String, first: Bool = false){
        trello.getMe(completion: {(result)->Void in
            self.me = result.value!
            trello.postToken(token, member: self.me.id, first: first)
        })
    }
    
    func updateModel(_ payload: [String: Any]){
        let json = JSON(payload["aps"]!)
        let parameters = ["payload": json["alert"].stringValue as String]
        Alamofire.request(trello.updateURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(response)->Void in
            guard let json = response.result.value else {
                print(response.error)
                return
            }
            let model = JSON(json)
            let action = Action(model["action"])
            let actionType = ActionType(rawValue: model["action"]["type"].stringValue)!
            print(actionType.attributes)
manager.functionDict[actionType.attributes.key]!(actionType, action)
        })

        
        }
    
    func batchGETProcesses(_ urls:[String]){
        
        
    }
    
}
let manager = APIManager()
