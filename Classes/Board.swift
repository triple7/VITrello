//
//  Board.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation
import SwiftyJSON
import Alamofire

class Board{
    var id:String!
    var name:String!
    var description:String?
    var url:String?
    var closed:Bool?
    var organizationId:String?
    var pinned:Bool?
    var prefs:BoardPrefs?
    var lists = [CardList]()
    var listIDs = [String]()
    var members = [Member]()
    var labels = [Label]()
    var actions = [Action]()
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        if json["desc"].null == nil{
            self.description = json["desc"].stringValue
        }
        if json["url"].null == nil{
            self.url = json["url"].stringValue
        }
        if json["closed"].null == nil{
            self.closed = json["closed"].boolValue
        }
        if json["idOrganization"].null == nil{
            self.organizationId = json["idOrganization"].stringValue
        }
        if json["pinned"].null == nil{
            self.pinned = json["pinned"].boolValue
        }
        if json["prefs"].null == nil{
            self.prefs = BoardPrefs(json["prefs"])
        }
        
        trello.getMembersForBoard(self.id, completion: {(result)->Void in
            self.members = result.value!
        })

        trello.getActionsForBoard(self.id, .Minimal, completion: {(result)->Void in
        self.actions = result.value!
            for action in self.actions{
                manager.actionsDict[action.id] = action
            }
        })
        
        trello.getListsForBoardID(id, completion: {(result)->Void in
        self.lists = result.value!
            for list in self.lists{
                self.listIDs.append(list.id)
            }
        })
        
        trello.getLabelsForBoardID(id, completion: {(result)->Void in
            if result.value != nil{
                self.labels = result.value!
            }
        })
        }

    init(){
        self.name = ""
        self.id = ""
    }

    }

extension Trello {
    
    func getAllBoards(_ completion: @escaping (Result<[Board]>) -> Void) {
        Alamofire.request(Router.allBoards, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var boards = [Board]()
            let data = JSON(json)
            for board in data.arrayValue{
                boards.append(Board(board))
            }
            completion(.success(boards))
        }
        
        func getBoard(_ id: String, includingLists listType: ListType = .None, includingCards cardType: CardType = .None, includingMembers memberType: MemberType = .None, completion: @escaping (Result<Board>) -> Void) {
            let parameters = self.authParameters + ["cards": cardType.rawValue as AnyObject] + ["lists": listType.rawValue as AnyObject] + ["members": memberType.rawValue as AnyObject]
            Alamofire.request(Router.board(boardId: id).URLString, parameters: parameters).responseJSON { (response) in
                guard let json = response.result.value else {
                    completion(.failure(TrelloError.networkError(error: response.result.error)))
                    return
                }
                let board = Board(JSON(json))
                completion(.success(board))
            }
        }
    }

    func getBoardsForTeam(_ ID: String, filter: String = "all", completion: @escaping (Result<[Board]>) -> Void) {
        let params = authParameters + ["filter": filter as AnyObject]
        Alamofire.request(Router.boardForTeam(teamID: ID), parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var boards = [Board]()
            let data = JSON(json)
            for board in data.arrayValue{
                boards.append(Board(board))
            }
            completion(.success(boards))
        }
        
        func getBoard(_ id: String, includingLists listType: ListType = .None, includingCards cardType: CardType = .None, includingMembers memberType: MemberType = .None, completion: @escaping (Result<Board>) -> Void) {
            let parameters = self.authParameters + ["cards": cardType.rawValue as AnyObject] + ["lists": listType.rawValue as AnyObject] + ["members": memberType.rawValue as AnyObject]
            Alamofire.request(Router.board(boardId: id).URLString, parameters: parameters).responseJSON { (response) in
                guard let json = response.result.value else {
                    completion(.failure(TrelloError.networkError(error: response.result.error)))
                    return
                }
                let board = Board(JSON(json))
                completion(.success(board))
            }
        }
    }
    
    func getBoardByID(_ ID: String, completion: @escaping (Result<Board>) -> Void) {
        let params = authParameters
Alamofire.request(Router.boardByID(boardId: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            let board = Board(JSON(json))
            completion(.success(board))
        }
        
        func getBoard(_ id: String, includingLists listType: ListType = .None, includingCards cardType: CardType = .None, includingMembers memberType: MemberType = .None, completion: @escaping (Result<Board>) -> Void) {
            let parameters = self.authParameters + ["cards": cardType.rawValue as AnyObject] + ["lists": listType.rawValue as AnyObject] + ["members": memberType.rawValue as AnyObject]
            Alamofire.request(Router.board(boardId: id).URLString, parameters: parameters).responseJSON { (response) in
                guard let json = response.result.value else {
                    completion(.failure(TrelloError.networkError(error: response.result.error)))
                    return
                }
                let board = Board(JSON(json))
                completion(.success(board))
            }
        }
    }
    

    //Mark: Actions for boards
    
    func addBoard(board: Board, completion: @escaping () -> Void) {
        print("\(board.name) and \(board.organizationId)")
        let parameters = self.authParameters + ["name": board.name as AnyObject] /*+ ["desc": board.description! as AnyObject] */ + ["idOrganization": board.organizationId! as AnyObject]
            try Alamofire.request(Router.CreateBoard.URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                })
    }

    func addChecklistToBoard(_ id: String, name: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": name as AnyObject]
        do{
            try Alamofire.request(Router.board(boardId: id).asURL(), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    
    
}


extension Board:Equatable{
    static func ==(lhs: Board, rhs: Board)->Bool{
        return lhs.id == rhs.id
    }
}
