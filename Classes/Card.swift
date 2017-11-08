//
//  Card.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation
import SwiftyJSON
import Alamofire


public enum CardType: String {
    case All = "all"
    case Closed = "closed"
    case None = "none"
    case Open = "open"
    case Visible = "visible"
}

class Card{
    var id: String!
    var name: String!
    var description: String?
    var closed: Bool?
    var position: Float?
    var dueDate: Date?
    var dueComplete:Bool?
    var listId: String?
    var memberIds = [String]()
    var boardId: String?
    var shortURL: String?
    var labels = [Label]()
    var checkLists = [CheckList]()
    var checklistIDs = [String]()
    var comments = [Comment]()
    var actions = [Action]()
    var attachments = [Attachment]()
    
    private var isoDateFormatter: DateFormatter!
    
    init(_ json: JSON){
        isoDateFormatter = isoDate()
self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        if json["desc"].null == nil{
            self.description = json["desc"].stringValue
        }
        if json["pos"].null == nil{
            self.position = json["pos"].floatValue
        }
        if json["closed"].null == nil{
            self.closed = json["closed"].boolValue
        }
        if json["idList"].null == nil{
            self.listId = json["idList"].stringValue
        }
        if json["due"].null == nil{
            self.dueDate = isoDateFormatter.date(from: json["due"].stringValue)
        }
        if json["dueComplete"].null == nil{
            self.dueComplete = json["dueComplete"].boolValue
        }
        if json["idMembers"].null == nil{
            for member in json["idmembers"].arrayValue{
                memberIds.append(member.stringValue)
            }
        }
        if json["idBoard"].null == nil{
            self.boardId = json["idBoard"].stringValue
        }
        if json["shortUrl"].null == nil{
            self.shortURL = json["shortUrl"].stringValue
        }
        if json["labels"].null == nil{
            for label in json["labels"].arrayValue{
                self.labels.append(Label(label))
            }
        }

        trello.getActionsForCard(self.id, .Minimal, completion: {(result)->Void in
            if result.value != nil{
                self.actions = result.value!
            }
            
            trello.getCommentsForCardID(self.id, completion: {(result)->Void in
                self.comments = result.value!
                NotificationCenter.default.post(name: refreshBoardsNotification, object:nil)
                
                trello.getLabelsForCardID(self.id, completion: {(result)->Void in
                    if result.value != nil{
                        self.labels += result.value!
                        NotificationCenter.default.post(name: refreshBoardsNotification, object:nil)
                    }
                })

            })
        })
        
        trello.getAttachmentsForCardID(id, completion: {(result)->Void in
            if result.value != nil{
                self.attachments += result.value!
                            NotificationCenter.default.post(name: refreshBoardsNotification, object:nil)
            }
        })

        trello.getChecklistForCardID(id, completion: {(result)->Void in
            if result.value != nil{
                self.checkLists += result.value!
                for checklist in self.checkLists{
                    self.checklistIDs.append(checklist.id)
                }
                            NotificationCenter.default.post(name: refreshBoardsNotification, object:nil)
            }

            })
    }

    init(){
        self.name = ""
        self.id = ""
    }
    
}

// MARK: Card API
extension Trello {
    
    func getCardsForList(_ id: String, withMembers: Bool = false, completion: @escaping (Result<[Card]>) -> Void) {
        Alamofire.request(Router.cardsForList(listId: id).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var cards = [Card]()
            let data = JSON(json)
            for card in data.arrayValue{
                cards.append(Card(card))
            }
            completion(.success(cards))
        }
    }

    func getCardByID(_ ID: String, completion: @escaping (Result<Card>) -> Void) {
        Alamofire.request(Router.Card(cardID: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
let card = Card(JSON(json))
            completion(.success(card))
        }
    }
    
    //mark: Card actions
    
    func updateCard(card: Card, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": card.name as AnyObject] + ["desc": card.description as AnyObject] + ["closed": card.closed as AnyObject] + ["idMembers": card.memberIds as AnyObject] + ["idList": card.listId as AnyObject] + ["pos": card.position as AnyObject] + ["dueComplete": card.dueComplete as AnyObject]
        do{
            try Alamofire.request(Router.Card(cardID: card.id).asURL(), method: .put
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func addCard(card: Card, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": card.name as AnyObject] + ["desc": card.description as AnyObject] + ["pos": "top" as AnyObject] + ["dueComplete": card.dueComplete as AnyObject] + ["idList": card.listId! as AnyObject]
        do{
            try Alamofire.request(Router.Cards.asURL(), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func deleteCard(_ ID: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters
        do{
            try Alamofire.request(Router.Card(cardID: ID).asURL(), method: .delete
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    

}

extension Card:Equatable, Comparable{
    static func ==(lhs: Card, rhs: Card)->Bool{
        return lhs.id == rhs.id
    }
    static func <(lhs: Card, rhs: Card)->Bool{
        return Int(lhs.position!) < Int(rhs.position!)
    }
}
