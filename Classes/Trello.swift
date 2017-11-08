//
//  Trello.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

public enum Result<T> {
    case failure(Error)
    case success(T)
    
    public var value: T? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public enum TrelloError: Error {
    case networkError(error: Error?)
    case jsonError(error: Error?)
}

 class Trello {
    let authParameters: [String: AnyObject]
    var headers:HTTPHeaders = ["Content-Type": "application/json"]
let callbackURL = "http://takeout.oseyeris.com/webhook/webhook.php"
    private let tokenURL = "http://takeout.oseyeris.com/webhook/memberToToken.php"
        let updateURL = "http://takeout.oseyeris.com/webhook/updateModel.php"
    fileprivate var dbParams = ["user": "oseyeris_Vlack" as String, "password": "GeN7NoLo2017" as String, "db": "oseyeris_Vlack" as String]
    
     init(apiKey: String, authToken: String) {
        self.authParameters = ["key": apiKey as AnyObject, "token": authToken as AnyObject]
    }
    
    func postToken(_ deviceToken: String, member: String, first: Bool = false){
        var query:String
        if first{
            query = "INSERT INTO members VALUES('\(member)', '\(deviceToken)');"
        }else{
            query = "UPDATE members SET token = '\(deviceToken)' WHERE memberID = '\(member)'"
        }
        let parameters = dbParams + ["query": query as String]
                Alamofire.request(tokenURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseString(completionHandler: {(response)->Void in
                    guard let json = response.result.value else {
                        print(response.error)
                        return
                    }
                })
    }
    
    
    
}

extension Trello{
    
     internal enum AvatarSize: Int {
        case small = 30
        case large = 170
    }
}

internal enum Router: URLConvertible {
    static let baseURLString = "https://api.trello.com/1/"
    
    case ME
    case search
    case AllTeams
    case allBoards
    case CreateBoard
    case board(boardId: String)
    case boardByID(boardId: String)
    case boardForTeam(teamID: String)
    case ListNew
    case List(Id: String)
    case lists(boardId: String)
    case Card(cardID: String)
    case Cards
    case cardsForList(listId: String)
    case member(id: String)
    case membersForCard(cardId: String)
    case MembershipsForBoard(ID: String)
    case AllActions
    case ActionsForTeam(ID: String)
    case ActionsForBoard(ID: String)
    case ActionsForCardlist(ID: String)
    case ActionsForCard(ID: String)
    case memberToBoard(id: String, boardID: String)
    case MembersForBoard(ID: String)
    case memberToCard(cardID: String)
    case MemberDelete(ID: String, cardID: String)
    case ListToBoard(id: String, boardID: String)
        case ListByID(id: String)
    case ListArchive(ID: String)
    case ListArchiveCards(ID: String)
    case ListMoveCards(ID: String)
    case Comment(cardID: String, actionID: String)
    case AddComment(cardID: String)
    case CommentToCard(ID: String, cardID: String)
        case ChecklistByID(ID: String)
    case Checklist(cardID: String)
    case ChecklistToCard(ID: String, cardID: String)
    case CheckListDeleteCard(ID: String, cardID: String)
    case CheckListDelete(ID: String)
    case ChecklistItems(ID: String)
        case CheckItemToChecklist(ID: String)
    case UpdateCheckItemToCard(ID: String, cardID: String)
    case deleteCheckItem(ID: String, checklistID: String)
    case Labels
    case Label(cardID: String)
    case LabelFromBoard(boardID: String)
    case LabelToCard(ID: String, cardID: String)
    case LabelDelete(ID: String, cardID: String)
    case LabelUpdate(Id: String)
    case Attachments(ID: String)
    case AttachmentByID(ID: String, cardID: String)
    case Webhook(token: String)
    case AllWebhooks(token: String)
    case WebhookDelete(token: String, ID: String)
    case WebhookByID(token: String, ID: String)

    
    var URLString: String {
        switch self {
        case .ME:
            return Router.baseURLString + "members/me"
        case .search:
            return Router.baseURLString + "search/"
        case .AllTeams:
            return Router.baseURLString + "members/me/organizations/"
        case .allBoards:
            return Router.baseURLString + "members/me/boards/"
        case .CreateBoard:
            return Router.baseURLString + "boards/"
        case .board(let boardId):
            return Router.baseURLString + "boards/\(boardId)/"
        case .boardByID(let boardId):
            return Router.baseURLString + "boards/\(boardId)"
        case .boardForTeam(teamID: let teamID):
            return Router.baseURLString + "organizations/" + teamID + "/boards"
        case .ListNew:
            return Router.baseURLString + "lists"
        case .List(let ID):
            return Router.baseURLString + "lists/" + ID
        case .lists(let boardId):
            return Router.baseURLString + "boards/\(boardId)/lists/"
        case .Card(let cardID):
            return Router.baseURLString + "cards/" + cardID
        case .Cards:
            return Router.baseURLString + "cards"
        case .cardsForList(let listId):
            return Router.baseURLString + "lists/\(listId)/cards/"
        case .member(let memberId):
            return Router.baseURLString + "members/\(memberId)/"
        case .membersForCard(let cardId):
            return Router.baseURLString + "cards/\(cardId)/members/"
        case .memberToBoard(let ID, let boardID):
            return Router.baseURLString + boardID + "/members/" + ID
        case .MembersForBoard(let ID):
            return Router.baseURLString + "boards/" + ID + "/members"
        case .memberToCard(let cardID):
            return Router.baseURLString + "cards/" + cardID + "/idMembers"
        case .MembershipsForBoard(let ID):
            return Router.baseURLString + "boards/" + ID + "/memberships"
            case .ListToBoard(id: let ID, boardID: let boardID):
return Router.baseURLString + boardID + "/lists/" + ID
        case .ListByID(let ID):
            return Router.baseURLString + "lists/" + ID
        case .ListArchive(let ID):
            return Router.baseURLString + "lists/" + ID + "/closed"
        case .ListArchiveCards(let ID):
            return Router.baseURLString + "lists/" + ID + "/archiveAllCards"
        case .ListMoveCards(let ID):
            return Router.baseURLString + "lists/" + ID + "/moveAllCards"
        case .Comment(let cardID, let actionID):
                        return Router.baseURLString + "cards/" + cardID + "/actions/" + actionID + "/comments"
        case .AddComment(let cardID):
            return Router.baseURLString + "cards/" + cardID + "/actions/comments"
        case .CommentToCard(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/actions/comments/" + ID
        case .Checklist(let cardID):
            return Router.baseURLString + "cards/" + cardID + "/checklists"
        case .ChecklistByID(let ID):
            return Router.baseURLString + "checklists/" + ID
        case .ChecklistToCard(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/actions/checklists/" + ID
        case .CheckListDelete(let ID):
            return Router.baseURLString + "checklists/" + ID
        case .CheckListDeleteCard(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/checklists/" + ID
        case .ChecklistItems(let ID):
            return Router.baseURLString + "checklists/" + ID + "/checkItems"
        case .UpdateCheckItemToCard(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/checkItem/" + ID
        case .deleteCheckItem(let ID, let checklistID):
            return Router.baseURLString + "checklists/" + checklistID + "/checkItems/" + ID
        case .CheckItemToChecklist(let ID):
            return Router.baseURLString + "checklists/" + ID + "/checkItems"
        case .Labels:
            return Router.baseURLString + "labels"
        case .Label(let cardID):
            return Router.baseURLString + "cards/" + cardID + "/labels"
        case .LabelFromBoard(let boardID):
            return Router.baseURLString + "boards/" + boardID + "/labels"
        case .LabelToCard(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/actions/checklists/" + ID
        case .LabelDelete(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/idLabels/" + ID
        case .MemberDelete(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/idMembers/" + ID
        case .LabelUpdate(let ID):
            return Router.baseURLString + "labels" + ID
        case .AllActions:
            return Router.baseURLString + "members/me/actions/"
        case .ActionsForTeam(let ID):
            return Router.baseURLString + "organizations/" + ID + "/actions"
        case .ActionsForBoard(let ID):
            return Router.baseURLString + "boards/" + ID + "/actions"
        case .ActionsForCard(let ID):
                        return Router.baseURLString + "cards/" + ID + "/actions"
        case .ActionsForCardlist(let ID):
                        return Router.baseURLString + "lists/" + ID + "/actions"
        case .Attachments(let ID):
            return Router.baseURLString + "cards/" + ID + "/attachments"
        case .AttachmentByID(let ID, let cardID):
            return Router.baseURLString + "cards/" + cardID + "/attachments/" + ID
        case .Webhook(let token):
            return Router.baseURLString + "tokens/" + token + "/webhooks"
        case .AllWebhooks(let token):
            return Router.baseURLString + "tokens/" + token + "/webhooks"
        case .WebhookDelete(let token, let ID):
            return Router.baseURLString + "tokens/" + token + "/webhooks/" + ID
        case .WebhookByID(let token, let ID):
            return Router.baseURLString + "tokens/" + token + "/webhooks/" + ID
        }
    }

    func asURL() throws -> URL {
        return URL(string: self.URLString)!
    }
}

// MARK: Dictionary Operator Overloading
// http://stackoverflow.com/questions/24051904/how-do-you-add-a-dictionary-of-items-into-another-dictionary/
func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

func +<K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    var newDict: [K: V] = [:]
    for (k, v) in left {
        newDict[k] = v
    }
    for (k, v) in right {
        newDict[k] = v
    }
    
    return newDict
}

let trello = Trello(apiKey: trelloAPIKey, authToken: trelloToken)
