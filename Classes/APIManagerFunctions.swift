//
//  APIManagerFunctions.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 23/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation

extension APIManager{
    
    func voidFunction(_ actionType: ActionType, action: Action){
        return
    }
    
    func createItem(_ actionType: ActionType, action: Action){
        let json = action.data!
        let type = actionType.attributes.type
        switch type{
            case "organisation":
            let team = Organisation(json["data"])
            teamDict[team.id] = team
            case "board":
                print("creating new board")
                let boardID = json[type]["id"].stringValue
                trello.getBoardByID(boardID, completion: {(result)->Void in
                    let board = result.value!
                    NotificationCenter.default.post(name: itemCreatedNotification, object: board, userInfo: ["type": type])
                })
        case "list":
    let listID = json[type]["id"].stringValue
    let boardID = json["board"]["id"].stringValue
    print("getting new list")
    trello.getCardlistByID(listID, completion: {(result)->Void in
        let list = result.value!
        NotificationCenter.default.post(name: itemCreatedNotification, object: list, userInfo: ["type": type, "boardID": boardID])
    })
            case "card":
                let cardID = json[type]["id"].stringValue
                trello.getCardByID(cardID, completion: {(result)->Void in
                    let card = result.value!
                    NotificationCenter.default.post(name: itemCreatedNotification, object: card, userInfo: ["type": type])
                })
            case "checklist":
                let checklistID = json[type]["id"].stringValue
                let cardID = json["card"]["id"].stringValue
                let boardID = json["board"]["id"].stringValue
                trello.getChecklistByID(checklistID, completion: {(result)->Void in
                    let checklist = result.value!
                    NotificationCenter.default.post(name: itemCreatedNotification, object: checklist, userInfo: ["type": type, "card": cardID, "board": boardID]
                    )
                })
            case "checkItem": break
        default: break
        }
    }
    
    func deleteItem(_ actionType: ActionType, action: Action){
        let json = action.data!
        let type = actionType.attributes.type
            let ID = json[type]["id"].stringValue
        let boardID = json["board"]["id"].stringValue
                let listID = json["board"]["id"].stringValue
        print("\(boardID) and \(listID)")
            NotificationCenter.default.post(name: itemDeletedNotification, object: ID, userInfo: ["type": type, "boardID": boardID, "listID": listID])
    }
    
    func moveItem(_ actionType: ActionType, action: Action){
        return
    }

    func updateItem(_ actionType: ActionType, action: Action){
        let json = action.data!
        let type = actionType.attributes.type
        switch type{
        case "organisation":
            let team = Organisation(json["data"])
            teamDict[team.id] = team
        case "board":
            let boardID = json[type]["id"].stringValue
            trello.getBoardByID(boardID, completion: {(result)->Void in
                let board = result.value!
                NotificationCenter.default.post(name: itemUpdatedNotification, object: board, userInfo: ["type": type])
            })
        case "list":
            print("list to archive")
            let listID = json[type]["id"].stringValue
                        let boardID = json["board"]["id"].stringValue
            print(json[type]["value"].boolValue)
            if json[type]["value"].null != nil{
                            NotificationCenter.default.post(name: itemDeletedNotification, object: listID, userInfo: ["type": type, "boardID": boardID])
            }else{
                trello.getCardlistByID(listID, completion: {(result)->Void in
                    let list = result.value!
                    NotificationCenter.default.post(name: itemUpdatedNotification, object: list, userInfo: ["type": type])
                })
            }
        case "card":
            let cardID = json[type]["id"].stringValue
            trello.getCardByID(cardID, completion: {(result)->Void in
                let card = result.value!
                NotificationCenter.default.post(name: itemUpdatedNotification, object: card, userInfo: ["type": type])
            })
        case "checklist":
            let checklistID = json[type]["id"].stringValue
            let cardID = json["card"]["id"].stringValue
            let boardID = json["board"]["id"].stringValue
            trello.getChecklistByID(checklistID, completion: {(result)->Void in
                let checklist = result.value!
                NotificationCenter.default.post(name: itemUpdatedNotification, object: checklist, userInfo: ["type": type, "card": cardID, "board": boardID]
                )
            })
        case "checkItem": break
        default: break
        }
    }

}
