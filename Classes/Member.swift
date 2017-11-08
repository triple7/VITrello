//
//  Member.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Alamofire

public enum MemberType: String {
    case Admins = "admins"
    case All = "all"
    case None = "none"
    case Normal = "normal"
    case Owners = "owners"
    case Observer = "observer"
}

class Member{
    var id: String!
    var avatarHash: String?
    var bio: String?
    var confirmed: Bool?
    var fullName: String?
    var initials: String?
    var username: String?
    var email: String?
    var idBoards = [String]()
    var idOrganisations = [String]()
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        if json["avatarHash"].null == nil{
            self.avatarHash = json["avatarHash"].stringValue
        }
        if json["bio"].null == nil{
            self.bio = json["bio"].stringValue
        }
        if json["confirmed"].null == nil{
            self.confirmed = json["confirmed"].boolValue
        }
        if json["fullName"].null == nil{
            self.fullName = json["fullName"].stringValue
        }
        if json["initials"].null == nil{
            self.initials = json["initials"].stringValue
        }
        if json["username"].null == nil{
            self.username = json["username"].stringValue
        }
        if json["email"].null == nil{
            self.email = json["email"].stringValue
        }
        if json["idBoards"].null == nil{
            for board in json["idBoards"].arrayValue{
self.idBoards.append(board.stringValue)            }
        }
        if json["idOrganizations"].null == nil{
            for organisation in json["idOrganizations"].arrayValue{
self.idOrganisations.append(organisation.stringValue)            }
        }
        manager.memberDict[self.id] = self
    }
    
}

// Member API
extension Trello {

    func getMe(completion: @escaping (Result<Member>) -> Void) {
        let parameters = self.authParameters
        Alamofire.request(Router.ME.URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            let member = Member(JSON(json))
            completion(.success(member))
        }
    }
    
    func getMember(_ id: String, completion: @escaping (Result<Member>) -> Void) {
        let parameters = self.authParameters
        Alamofire.request(Router.member(id: id).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            let member = Member(JSON(json))
            completion(.success(member))
        }
    }

    func getMembershipsForBoard(_ ID: String, filter: String = "all", completion: @escaping (Result<JSON>) -> Void) {
        let parameters = self.authParameters + ["filter": filter as AnyObject]
        Alamofire.request(Router.MembershipsForBoard(ID: ID).URLString, parameters: parameters).responseJSON { (response) in
            guard let data = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            let json = JSON(data)
            completion(.success(json))
        }
    }
    

    func getMembersForBoard(_ ID: String, completion: @escaping (Result<[Member]>) -> Void) {
        let parameters = self.authParameters
         Alamofire.request(Router.MembersForBoard(ID: ID).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            var members = [Member]()
            let data = JSON(json)
            for member in data.arrayValue{
                members.append(Member(member))
            }
            completion(.success(members))
        }
    }
    
    func getMembersForCard(_ cardId: String, completion: @escaping (Result<[Member]>) -> Void) {
        let parameters = self.authParameters
        Alamofire.request(Router.member(id: cardId).URLString, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var members = [Member]()
            let data = JSON(json)
            for member in data.arrayValue{
                members.append(Member(member))
            }
            completion(.success(members))
        }
    }
    
    func getAvatarImage(_ avatarHash: String, size: AvatarSize, completion: @escaping (Result<Image>) -> Void) {
        Alamofire.request("https://trello-avatars.s3.amazonaws.com/\(avatarHash)/\(size.rawValue).png").responseImage { response in
            guard let image = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            completion(.success(image))
        }
}
    
    //Mark: Member based actions
    
    func addmemberToBoard(_ id: String, member: Member, type: MemberType,completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["email": member.email as AnyObject]
            let headers:HTTPHeaders = ["Content-Type": "application/json", "type": type.rawValue]
        do{
            try Alamofire.request(Router.board(boardId: id).asURL(), method: .put
                , parameters: parameters, encoding: JSONEncoding.default, headers: headers).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func updatememberToBoard(_ id: String, memberID: String, type: MemberType,completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["type": type.rawValue as AnyObject]
        do{
            try Alamofire.request(Router.memberToBoard(id: memberID, boardID: id).asURL(), method: .put
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func addmemberToCard(_ id: String, member: Member, type: MemberType,completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["value": member.id as AnyObject]
        do{
            try Alamofire.request(Router.memberToCard(cardID: id).asURL(), method: .post
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func deleteMemberFromBoard(_ id: String, memberID: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters
        do{
            try Alamofire.request(Router.memberToBoard(id: memberID, boardID: id).asURL(), method: .delete
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    
}
