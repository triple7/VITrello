//
//  CheckItem.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 21/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class CheckItem{
    var id: String!
    var name: String!
    var pos: Int?
    var checked: Bool?
    var state:String?
    var idChecklist:String?
    var actions = [Action]()
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        if json["pos"].null == nil{
            self.pos = json["pos"].intValue
        }
        if json["checked"].null == nil{
            self.checked = json["checked"].boolValue
        }
        if json["idChecklist"].null == nil{
            self.idChecklist = json["idChecklist"].stringValue
        }
        if json["state"].null == nil{
            self.state = json["state"].stringValue
        }
}

    init(){
        self.name = ""
        self.id = ""
    }

    func getState()->String{
        if self.checked != nil{
        if self.checked!{
            return "complete"
        }else{
            return "incomplete"
        }
        }else{
            return "not defined"
        }
    }
    
}

// MARK: CheckItems API
extension Trello {
    
    func getCheckItemsForChecklistID(_ ID: String, completion: @escaping (Result<[CheckItem]>) -> Void) {
        Alamofire.request(Router.ChecklistItems(ID: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var items = [CheckItem]()
            let data = JSON(json)
            for item in data.arrayValue{
                items.append(CheckItem(item))
            }
            completion(.success(items))
        }
    }
    
    func getCheckItemsForChecklist(_ checklist: CheckList, completion: @escaping (Result<[CheckItem]>) -> Void) {
        getCheckItemsForChecklistID(checklist.id, completion: completion)
    }
    
    //Mark: checkItem actions
    
    func addCheckItemToChecklist(_ ID: String, checkItem: CheckItem,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": checkItem.name as AnyObject] + ["pos": "top" as AnyObject] + ["checked": false as AnyObject]
            Alamofire.request(Router.CheckItemToChecklist(ID: ID).URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
            })
    }
    
    func updateCheckItem(_ ID: String, checkItem: CheckItem,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": checkItem.name as AnyObject] + ["state": checkItem.state! as AnyObject] + ["idChecklist": checkItem.idChecklist! as AnyObject]
        Alamofire.request(Router.UpdateCheckItemToCard(ID: checkItem.id, cardID: ID), method: .put
            , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
    }
    
    func deleteCheckItem(_ id: String, checkItemID: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters
            Alamofire.request(Router.deleteCheckItem(ID: checkItemID, checklistID: id).URLString, method: .delete
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
    }
    
}

extension CheckItem:Equatable, Comparable{
    static func ==(lhs: CheckItem, rhs: CheckItem)->Bool{
        return lhs.id == rhs.id
    }
    
    static func <(lhs: CheckItem, rhs: CheckItem)->Bool{
        return Int(lhs.pos!) < Int(rhs.pos!)
    }

}
