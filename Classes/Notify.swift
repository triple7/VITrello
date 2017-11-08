//
//  Notification.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 15/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Alamofire

class Notify{
    var id: String!
    //var data:Data?
    var date:Date?
    var IDMemberCreator:String?
    var type:String?
    var unread:Bool?
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        if json["idMemberCreator"].null == nil{
            self.IDMemberCreator = json["idMemberCreator"].stringValue
        }
        if json["type"].null == nil{
            self.type = json["type"].stringValue
        }
        if json["unread"].null == nil{
            self.unread = json["unread"].boolValue
        }
    }
    
}
