//
//  CardList.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation
import SwiftyJSON
import Alamofire

public enum ListType: String {
    case All = "all"
    case Closed = "closed"
    case None = "none"
    case Open = "open"
}

class CardList{
    var id: String!
    var name: String!
    var boardId: String?
    var pos: Int?
    var subscribed: Bool?
    var closed: Bool?
    var cards = [Card]()
    var cardIDs = [String]()
    var members = [Member]()
    var actions = [Action]()

    init(_ json: JSON){
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        if json["idBoard"].null == nil{
            self.boardId = json["idboard"].stringValue
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
        
        trello.getActionsForCardlist(self.id, .Minimal,completion: {(result)->Void in
            self.actions = result.value!
        })
        
        trello.getCardsForList(id, completion: {(result)->Void in
            self.cards = result.value!
            for card in self.cards{
                self.cardIDs.append(card.id)
            }
        })
    }
    
    init(){
        self.name = ""
        self.id = ""
    }

}

// MARK: Lists
extension Trello {
    func getListsForBoardID(_ id: String, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
        Alamofire.request(Router.lists(boardId: id).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var lists = [CardList]()
            let data = JSON(json)
            for cardList in data.arrayValue{
                lists.append(CardList(cardList))
            }
            completion(.success(lists))
        }
        
        func getListsForBoard(_ board: Board, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
            getListsForBoardID(board.id, filter: filter, completion: completion)
        }
    }

    func getCardlistByID(_ ID: String, completion: @escaping (Result<CardList>) -> Void) {
        Alamofire.request(Router.ListByID(id: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            let list = CardList(JSON(json))
            completion(.success(list))
        }
        
        func getListsForBoard(_ board: Board, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
            getListsForBoardID(board.id, filter: filter, completion: completion)
        }
    }

    //Mark: List actions

    func updateList(_ list: CardList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": list.name as AnyObject] + ["closed": list.closed as AnyObject] + ["idBoard": list.boardId as AnyObject] + ["pos": list.pos as AnyObject] + ["subscribed": list.subscribed as AnyObject]
        do{
            try Alamofire.request(Router.List(Id: list.id).asURL(), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func renameList(_ list: CardList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": list.name as AnyObject]
        do{
            try Alamofire.request(Router.List(Id: list.id).asURL(), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func positionList(_ list: CardList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["pos": list.pos as AnyObject]
        do{
            try Alamofire.request(Router.List(Id: list.id).asURL(), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func archiveList(_ list: CardList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["value": list.closed! as AnyObject]
        do{
            try Alamofire.request(Router.ListArchive(ID: list.id).asURL(), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func addListToBoard(_ ID: String, newList: CardList, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": newList.name as AnyObject] + ["pos": "top" as AnyObject]
            Alamofire.request(Router.lists(boardId: ID).URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
    }
    
    func updateListOnBoard(_ ID: String, list: CardList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": list.name as AnyObject] + ["pos": "top" as AnyObject]
        do{
            try Alamofire.request(Router.lists(boardId: ID).asURL(), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func moveListToBoard(_ ID: String, list: CardList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["value": ID
            as AnyObject] + ["pos": "top" as AnyObject]
        do{
            try Alamofire.request(Router.lists(boardId: ID).asURL(), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func archiveListCards(_ list: CardList,  completion: @escaping () -> Void) {
        let parameters = self.authParameters
        do{
            try Alamofire.request(Router.ListArchiveCards(ID: list.id).asURL(), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func moveListCards(_ list: CardList, _ id: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["idBoard": id as AnyObject] + ["idList": list.id as AnyObject]
        do{
            try Alamofire.request(Router.ListMoveCards(ID: list.id).asURL(), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }

}

extension CardList:Equatable, Comparable{
    static func ==(lhs: CardList, rhs: CardList)->Bool{
        return lhs.id == rhs.id
    }
    static func <(lhs: CardList, rhs: CardList)->Bool{
        return Int(lhs.pos!) < Int(rhs.pos!)
    }

}
