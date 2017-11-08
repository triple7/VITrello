//
//  CheckList.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 12/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class CheckList{
    var id: String!
    var name: String!
    var boardId: String?
    var pos: Int?
    var subscribed: Bool?
    var closed: Bool?
    var checkItems = [CheckItem]()
    var actions = [Action]()
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        if json["idBoard"].null == nil{
            self.boardId = json["idBoard"].stringValue
        }
        if json["pos"].null == nil{
            self.pos = json["pos"].intValue
        }
        if json["subscribed"].null == nil{
            self.subscribed = json["subscribed"].boolValue
        }
        if json["closed"].null == nil{
            self.closed = json["closed"].boolValue
        }
        if json["checkItems"].null == nil{
            for checkItem in json["checkItems"].arrayValue{
                self.checkItems.append(CheckItem(checkItem))
            }
        }
}
    
    init(){
        self.name = ""
        self.id = ""
    }

    func getState()->String{
        var text = ""
        if closed != nil{
        if closed!{
            text = "closed"
        }else{
            text = "open"
        }
        }
        return text
    }

}

// MARK: CheckList API
extension Trello {
    func getChecklistForCardID(_ ID: String, filter: CardType = .All, completion: @escaping (Result<[CheckList]>) -> Void) {
        Alamofire.request(Router.Checklist(cardID: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var lists = [CheckList]()
            let data = JSON(json)
            for checkList in data.arrayValue{
                lists.append(CheckList(checkList))
            }
            completion(.success(lists))
        }
    }
    
    func getChecklistForCard(_ card: Card, filter: CardType = .All, completion: @escaping (Result<[CheckList]>) -> Void) {
        getChecklistForCardID(card.id, filter: filter, completion: completion)
    }

    func getChecklistByID(_ ID: String, completion: @escaping (Result<CheckList>) -> Void) {
        let parameters = authParameters + ["cards": "all" as AnyObject]
        Alamofire.request(Router.ChecklistByID(ID: ID).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            let list = CheckList(JSON(json))
            completion(.success(list))
        }
    }

    //Mark: List actions
    
    func addChecklistToCard(_ ID: String, checklist: CheckList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": checklist.name as AnyObject]
        do{
            try Alamofire.request(Router.Checklist(cardID: ID).asURL(), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func updateChecklist(_ checklist: CheckList, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": checklist.name as AnyObject] + ["pos": checklist.pos as AnyObject]
            Alamofire.request(Router.CheckListDelete(ID: checklist.id), method: .put
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
    }

    func deleteChecklistFromCard(_ id: String, checklistID: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters
        do{
            try Alamofire.request(Router.CheckListDeleteCard(ID: checklistID, cardID: id).asURL(), method: .delete
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func deleteChecklist(_ checklistID: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters
        do{
            try Alamofire.request(Router.CheckListDelete(ID: checklistID).asURL(), method: .delete
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    }

extension CheckList:Equatable, Comparable{
    static func ==(lhs: CheckList, rhs: CheckList)->Bool{
        return lhs.id == rhs.id
    }
    
    static func <(lhs: CheckList, rhs: CheckList)->Bool{
        return Int(lhs.pos!) < Int(rhs.pos!)
    }

}
