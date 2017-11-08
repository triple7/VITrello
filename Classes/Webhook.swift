//
//  Webhook.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 24/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//


import Foundation
import SwiftyJSON
import Alamofire

class Webhook{
    var id: String!
    var description:String?
    var idModel:String?
    var callbackURL:String?
    var active:Bool?
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        if json["description"].null == nil{
            self.description = json["description"].stringValue
        }
        if json["idModel"].null == nil{
            self.idModel = json["idModel"].stringValue
        }
        if json["callbackURL"].null == nil{
            self.callbackURL = json["callbackURL"].stringValue
        }
        if json["active"].null == nil{
            self.active = json["active"].boolValue
        }
    }
    
    init(){
        self.id = ""
    }
    
}

// MARK: Webhook API
extension Trello {
    
    func getAllWebhooks(completion: @escaping (Result<[Webhook]>) -> Void) {
        Alamofire.request(Router.AllWebhooks(token: trelloToken).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var hooks = [Webhook]()
            let data = JSON(json)
            for hook in data.arrayValue{
                hooks.append(Webhook(hook))
            }
            completion(.success(hooks))
        }
        
        func getListsForBoard(_ board: Board, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
            getListsForBoardID(board.id, filter: filter, completion: completion)
        }
    }

    func getWebhook(_ webhookID: String, completion: @escaping (Result<Webhook>) -> Void) {
        Alamofire.request(Router.WebhookByID(token: trelloToken, ID: webhookID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            let webhook = Webhook(JSON(json))
            completion(.success(webhook))
        }
        
        func getListsForBoard(_ board: Board, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
            getListsForBoardID(board.id, filter: filter, completion: completion)
        }
    }
    
    func installWebhook(_ itemID: String, description: String, completion: @escaping () -> Void) {
        let parameters = ["key": trelloAPIKey as AnyObject] + ["description": description as AnyObject] + ["callbackURL": callbackURL as AnyObject] + ["idModel": itemID]
        do{
            try Alamofire.request(Router.Webhook(token: trelloToken).asURL(), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func deleteWebhook(_ webhookID: String, completion: @escaping () -> Void) {
        let parameters = authParameters
        do{
            try Alamofire.request(Router.WebhookDelete(token: trelloToken, ID: webhookID).asURL(), method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
}

extension Webhook:Equatable{
    static func ==(lhs: Webhook, rhs: Webhook
        )->Bool{
        return lhs.id == rhs.id
    }
    
}
