//
//  Action.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 19/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Alamofire


class Action{
    var id: String!
    var data:JSON?
    var idMemberCreator:String?
    var type:String?
    var date:Date?

    private var isoDateFormatter: DateFormatter!

    init(_ json: JSON){
        isoDateFormatter = isoDate()
        self.id = json["id"].stringValue
        if json["data"].null == nil{
            self.data = json["data"]
        }
        if json["idMemberCreator"].null == nil{
            self.idMemberCreator = json["idMemberCreator"].stringValue
        }
        if json["type"].null == nil{
            self.type = json["type"].stringValue
        }
        if json["date"].null == nil{
                        self.date = isoDateFormatter.date(from: json["date"].stringValue)
        }
    }
    
}


extension Trello{
    
    func getAllActions(_ completion: @escaping (Result<[Action]>) -> Void) {
        Alamofire.request(Router.AllActions, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var actions = [Action]()
            let data = JSON(json)
            for action in data.arrayValue{
                actions.append(Action(action))
            }
            completion(.success(actions))
        }
    }

    func getActionsForTeam(_ ID: String, _ fields: ActionField = .Minimal, completion: @escaping (Result<[Action]>) -> Void) {
        let parameters = authParameters + fields.getFields()
        Alamofire.request(Router.ActionsForTeam(ID: ID).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var actions = [Action]()
            let data = JSON(json)
            for action in data.arrayValue{
                actions.append(Action(action))
            }
            completion(.success(actions))
        }
    }
    
    func getActionsForBoard(_ ID: String, _ fields: ActionField = .Minimal,  completion: @escaping (Result<[Action]>) -> Void) {
        let parameters = authParameters + fields.getFields()
        Alamofire.request(Router.ActionsForBoard(ID: ID).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var actions = [Action]()
            let data = JSON(json)
            for action in data.arrayValue{
                actions.append(Action(action))
            }
            completion(.success(actions))
        }
    }

    func getActionsForCardlist(_ ID: String, _ fields: ActionField = .Minimal, completion: @escaping (Result<[Action]>) -> Void) {
        let parameters = authParameters + fields.getFields()
        Alamofire.request(Router.ActionsForCardlist(ID: ID).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var actions = [Action]()
            let data = JSON(json)
            for action in data.arrayValue{
                actions.append(Action(action))
            }
            completion(.success(actions))
        }
    }
    
    func getActionsForCard(_ ID: String, _ fields: ActionField = .Minimal, completion: @escaping (Result<[Action]>) -> Void) {
        let parameters = authParameters + fields.getFields()
        Alamofire.request(Router.ActionsForCard(ID: ID).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var actions = [Action]()
            let data = JSON(json)
            for action in data.arrayValue{
                actions.append(Action(action))
            }
            completion(.success(actions))
        }
    }
    
}

internal enum ActionField{
    case All
    case Minimal
    
    func getFields()->[String: AnyObject ]{
        switch self{
        case .All: return ["fields": ["data", "date", "idMemberCreator", "type"] as AnyObject]
        case .Minimal: return ["fields": ["date", "idMemberCreator", "type"] as AnyObject]
        }
    }
}

internal enum ActionType:String{
    case AddAdminToBoard  = "addAdminToBoard"
    case AddAdminToOrganization = "addAdminToOrganization"
    case AddAttachmentToCard = "addAttachmentToCard"
    case AddBoardsPinnedToMember = "addBoardsPinnedToMember"
    case AddChecklistToCard = "addChecklistToCard"
    case AddLabelToCard = "addLabelToCard"
    case AddMemberToBoard = "addMemberToBoard"
    case AddMemberToCard = "addMemberToCard"
    case AddMemberToOrganization = "addMemberToOrganization"
    case AddToOrganizationBoard = "addToOrganizationBoard"
    case CommentCard = "commentCard"
    case ConvertToCardFromCheckItem = "convertToCardFromCheckItem"
    case CopyBoard = "copyBoard"
    case CopyCard = "copyCard"
    case CopyChecklist = "copyChecklist"
    case CreateLabel = "createLabel"
    case CopyCommentCard = "copyCommentCard"
    case CreateBoard = "createBoard"
    case CreateBoardInvitation = "createBoardInvitation"
    case CreateBoardPreference = "createBoardPreference"
    case CreateCard = "createCard"
    case CreateChecklist = "createChecklist"
    case CreateList = "createList"
    case CreateOrganization = "createOrganization"
    case CreateOrganizationInvitation = "createOrganizationInvitation"
    case DeleteAttachmentFromCard = "deleteAttachmentFromCard"
    case DeleteBoardInvitation = "deleteBoardInvitation"
    case DeleteCard = "deleteCard"
    case DeleteCheckItem = "deleteCheckItem"
    case DeleteLabel = "deleteLabel"
    case DeleteOrganizationInvitation = "deleteOrganizationInvitation"
    case DisablePlugin = "disablePlugin"
    case DisablePowerUp = "disablePowerUp"
    case EmailCard = "emailCard"
    case EnablePlugin = "enablePlugin"
    case EnablePowerUp = "enablePowerUp"
    case MakeAdminOfBoard = "makeAdminOfBoard"
    case MakeAdminOfOrganization = "makeAdminOfOrganization"
    case MakeNormalMemberOfBoard = "makeNormalMemberOfBoard"
    case MakeNormalMemberOfOrganization = "makeNormalMemberOfOrganization"
    case MakeObserverOfBoard = "makeObserverOfBoard"
    case MemberJoinedTrello = "memberJoinedTrello"
    case MoveCardFromBoard = "moveCardFromBoard"
    case MoveCardToBoard = "moveCardToBoard"
    case MoveListFromBoard = "moveListFromBoard"
    case MoveListToBoard = "moveListToBoard"
    case RemoveAdminFromBoard = "removeAdminFromBoard"
    case RemoveAdminFromOrganization = "removeAdminFromOrganization"
    case RemoveBoardsPinnedFromMember = "removeBoardsPinnedFromMember"
    case RemoveChecklistFromCard = "removeChecklistFromCard"
    case RemoveFromOrganizationBoard = "removeFromOrganizationBoard"
    case RemoveLabelFromCard = "removeLabelFromCard"
    case RemoveMemberFromBoard = "removeMemberFromBoard"
    case RemoveMemberFromCard = "removeMemberFromCard"
    case RemoveMemberFromOrganization = "removeMemberFromOrganization"
    case UnconfirmedBoardInvitation = "unconfirmedBoardInvitation"
    case UnconfirmedOrganizationInvitation = "unconfirmedOrganizationInvitation"
    case UpdateBoard = "updateBoard"
    case UpdateCard = "updateCard"
    case UpdateCheckItem = "updateCheckItem"
    case UpdateCheckItemStateOnCard = "updateCheckItemStateOnCard"
    case UpdateChecklist = "updateChecklist"
    case UpdateLabel = "updateLabel"
    case UpdateList = "updateList"
    case UpdateMember = "updateMember"
    case UpdateOrganization = "updateOrganization"
    case VoteOnCard = "voteOnCard"
    
    var attributes:(key: Int, type: String){
        switch self{
        case .AddAdminToBoard : return (-1, "admin")
        case .AddAdminToOrganization: return (-1, "admin")
        case .AddAttachmentToCard: return (-1, "card")
        case .AddBoardsPinnedToMember: return (-1, "admin")
        case .AddChecklistToCard: return (1, "checklist")
        case .AddLabelToCard: return (-1, "label-card")
        case .AddMemberToBoard: return (-1, "member-board")
        case .AddMemberToCard: return (-1, "member-card")
        case .AddMemberToOrganization: return (-1, "member-organisation")
        case .AddToOrganizationBoard: return (-1, "admin")
        case .CommentCard: return (-1, "comment-card")
        case .ConvertToCardFromCheckItem: return (-1, "admin")
        case .CopyBoard: return (-1, "board")
        case .CopyCard: return (-1, "card")
        case .CopyChecklist: return (-1, "checklist")
        case .CreateLabel: return (1, "label")
        case .CopyCommentCard: return (-1, "comment")
        case .CreateBoard: return (1, "board")
        case .CreateBoardInvitation: return (-1, "admin")
        case .CreateBoardPreference: return (-1, "admin")
        case .CreateCard: return (1, "card")
        case .CreateChecklist: return (1, "checklist")
        case .CreateList: return (1, "list")
        case .CreateOrganization: return (1, "organisation")
        case .CreateOrganizationInvitation: return (1, "invitation-organisation")
        case .DeleteAttachmentFromCard: return (2, "attachment-card")
        case .DeleteBoardInvitation: return (-1, "admin")
        case .DeleteCard: return (2, "card")
        case .DeleteCheckItem: return (2, "checkItem")
        case .DeleteLabel: return (2, "label")
        case .DeleteOrganizationInvitation: return (2, "invitation-organisation")
        case .DisablePlugin: return (-1, "admin")
        case .DisablePowerUp: return (-1, "admin")
        case .EmailCard: return (-1, "admin")
        case .EnablePlugin: return (-1, "admin")
        case .EnablePowerUp: return (-1, "admin")
        case .MakeAdminOfBoard: return (-1, "admin")
        case .MakeAdminOfOrganization: return (-1, "admin")
        case .MakeNormalMemberOfBoard: return (-1, "admim")
        case .MakeNormalMemberOfOrganization: return (-1, "admin")
        case .MakeObserverOfBoard: return (-1, "admin")
        case .MemberJoinedTrello: return (-1, "admin")
        case .MoveCardFromBoard: return (3, "board-card")
        case .MoveCardToBoard: return (3, "card-board")
        case .MoveListFromBoard: return (3, "board-cardlist")
        case .MoveListToBoard: return (3, "list-board")
        case .RemoveAdminFromBoard: return (-1, "admin")
        case .RemoveAdminFromOrganization: return (-1, "admin")
        case .RemoveBoardsPinnedFromMember: return (-1, "admin")
        case .RemoveChecklistFromCard: return (2, "checklist")
        case .RemoveFromOrganizationBoard: return (-1, "admin")
        case .RemoveLabelFromCard: return (2, "label-card")
        case .RemoveMemberFromBoard: return (2, "board-member")
        case .RemoveMemberFromCard: return (2, "card-member")
        case .RemoveMemberFromOrganization: return (2, "organisation-member")
        case .UnconfirmedBoardInvitation: return (-1, "admin")
        case .UnconfirmedOrganizationInvitation: return (-1, "admin")
        case .UpdateBoard: return (4, "board")
        case .UpdateCard: return (4, "card")
        case .UpdateCheckItem: return (4, "checkItem")
        case .UpdateCheckItemStateOnCard: return (4, "checkItem-card")
        case .UpdateChecklist: return (4, "checklist")
        case .UpdateLabel: return (4, "label")
        case .UpdateList: return (4, "list")
        case .UpdateMember: return (4, "member")
        case .UpdateOrganization: return (4, "organisation")
        case .VoteOnCard: return (-1, "vote")
        }
    }
    
    }
