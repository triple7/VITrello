//
//  Comment.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 12/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Comment{
    var text:String!
    var idmemberCreator:String!
    
    init(_ json: JSON){
        print(json["idMemberCreator"])
                print(json["text"])
self.text = json["text"].stringValue
        self.idmemberCreator = json["idMemberCreator"].stringValue
    }

    init(_ text: String, _ memberID: String){
        self.text = text
        self.idmemberCreator = memberID
    }
    
}

// MARK: Comment API
extension Trello {
    
    func getCommentsForCardID(_ ID: String, completion: @escaping (Result<[Comment]>) -> Void) {
        var comments = [Comment]()
        trello.getActionsForCard(ID, .All
            , completion: {(result)->Void in
            for action in result.value!{
                if action.type! == "commentCard"{
                let comment = Comment(action.data!)
                    print(action.idMemberCreator)
                    comment.idmemberCreator = action.idMemberCreator!
                comments.append(comment)
            }
            }
            completion(.success(comments))
        })
    }
    
    func getCommentForCard(_ card: Card, filter: CardType = .All, completion: @escaping (Result<[Comment]>) -> Void) {
        getCommentsForCardID(card.id, completion: completion)
    }
    
    //Mark: List actions
    
    func addCommentToCard(_ ID: String, comment: Comment,  completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["text": comment.text! as AnyObject]
        do{
            try Alamofire.request(Router.AddComment(cardID: ID).URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
}
