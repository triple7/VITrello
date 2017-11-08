//
//  Attachment.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 24/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Attachment{
    var id: String!
    var name: String!
    var bytes:Int?
    var pos: Int?
    var date:Date?
    var edgeColor:String?
    var idMember:String?
    var isUpload:Bool?
    var mimeType:String?
    var previews:JSON?
    var URL:String?

    private var isoDateFormatter: DateFormatter!

    init(_ json: JSON){
        isoDateFormatter = isoDate()
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        if json["pos"].null == nil{
            self.pos = json["pos"].intValue
        }
        if json["bytes"].null == nil{
            self.bytes = json["bytes"].intValue
        }
        if json["edgeColor"].null == nil{
            self.edgeColor = json["edgeColor"].stringValue
        }
        if json["date"].null == nil{
            self.date = isoDateFormatter.date(from: json["date"].stringValue)
        }
        if json["idMember"].null == nil{
            self.idMember = json["idMember"].stringValue
        }
        if json["isUpload"].null == nil{
            self.isUpload = json["isUpload"].boolValue
        }
        if json["mimeType"].null == nil{
            self.mimeType = json["mimeType"].stringValue
        }
        if json["previews"].null == nil{
            self.previews = json["previews"]
        }
        if json["url"].null == nil{
            self.URL = json["url"].stringValue
        }
    }
    
    init(){
        self.name = ""
        self.id = ""
    }
    
}

// MARK: Attachment API
extension Trello {
    
    func getAttachmentsForCardID(_ ID: String, completion: @escaping (Result<[Attachment]>) -> Void) {
        Alamofire.request(Router.Attachments(ID: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var attachments = [Attachment]()
            let data = JSON(json)
            for attachment in data.arrayValue{
                attachments.append(Attachment(attachment))
            }
            completion(.success(attachments))
        }
    }

    func getAttachmentByID(_ ID: String, attachmentID: String, completion: @escaping (Result<Attachment>) -> Void) {
        Alamofire.request(Router.AttachmentByID(ID: attachmentID, cardID: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            let attachment = Attachment(JSON(json))
            completion(.success(attachment))
        }
    }
    
    func getAttachmentForCard(_ card: Card, completion: @escaping (Result<[Attachment]>) -> Void) {
        getAttachmentsForCardID(card.id, completion: completion)
    }
    
    //Mark: checkItem actions
    
    func addAttachmentToCard(_ ID: String, url: Bool, attachment: Attachment, completion: @escaping () -> Void) {
        var parameters = self.authParameters + ["name": attachment.name as AnyObject] + ["mimeType": attachment.mimeType as AnyObject]
        if url{
            parameters = parameters + ["url": attachment.URL as AnyObject]
        }else{
            
        }
        Alamofire.request(Router.Attachments(ID: ID).URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
            print(response.response!)
        })
    }
    
    func deleteAttachment(_ ID: String, attachmentID: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters
        Alamofire.request(Router.AttachmentByID(ID: attachmentID, cardID: ID), method: .delete
            , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                //print(response.response!)
            })
    }
    
}

extension Attachment:Equatable, Comparable{
    static func ==(lhs: Attachment, rhs: Attachment)->Bool{
        return lhs.id == rhs.id
    }
    
    static func <(lhs: Attachment, rhs: Attachment)->Bool{
        return Int(lhs.pos!) < Int(rhs.pos!)
    }
    
}
