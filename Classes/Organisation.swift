//
//  Organisation.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 15/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Alamofire

class Organisation{
    var id: String!
    var desc:String?
    var displayName:String?
    var website:String?
var idBoards = [String]()
    var boards = [Board]()
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        if json["desc"].null == nil{
            self.desc = json["desc"].stringValue
        }
        if json["displayName"].null == nil{
            self.displayName = json["displayName"].stringValue
        }
        if json["website"].null == nil{
            self.website = json["website"].stringValue
        }
        if json["idBoards"].null == nil{
            for board in json["idBoards"].arrayValue{
                idBoards.append(board.stringValue)
            }
        }
        
        trello.getBoardsForTeam(self.id, completion: {(result)->Void in
            if result.value != nil{
                self.boards = result.value!
            }
            manager.teamDict[self.displayName!] = self
        })

    }
    
}


extension Trello{

    func getAllTeams(_ completion: @escaping (Result<[Organisation]>) -> Void) {
        Alamofire.request(Router.AllTeams, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var teams = [Organisation]()
            let data = JSON(json)
            for team in data.arrayValue{
                teams.append(Organisation(team))
            }
            completion(.success(teams))
        }
    }

    
    func createTeam(organisation: Organisation, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["displayName": organisation.displayName as AnyObject] + ["desc": organisation.desc as AnyObject] + ["website": organisation.website as AnyObject]
        do{
            try Alamofire.request(Router.allBoards.asURL(), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
 
    func deleteTeam(organisation: Organisation, completion: @escaping () -> Void) {
        let parameters = self.authParameters
        do{
            try Alamofire.request(Router.allBoards.asURL(), method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
}
