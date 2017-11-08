//
//  BoardPrefs.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 30/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class BoardPrefs{
    var permissionLevel:String?
    var voting:String?
    var comments:String?
    var invitations:String?
    var selfJoin:Bool?
    var calendarFeedEnabled:Bool?
    var canBePublic:Bool?
    var canBeorg:Bool?
    var canBePrivate:Bool?
    var canInvite:Bool?
    
    init(_ json: JSON){
        if json["permissionlevel"].null == nil{
            self.permissionLevel = json["permissionLevel"].stringValue
        }
        if json["voting"].null == nil{
            self.voting = json["voting"].stringValue
        }
        if json["comments"].null == nil{
            self.comments = json["comments"].stringValue
        }
        if json["invitations"].null == nil{
            self.invitations = json["invitations"].stringValue
        }
        if json["selfJoin"].null == nil{
            self.selfJoin = json["selfJoin"].boolValue
        }
        if json["calendarFeedEnabled"].null == nil{
            self.calendarFeedEnabled = json["calendarFeedEnabled"].boolValue
        }
        if json["canInvite"].null == nil{
            self.canInvite = json["canInvite"].boolValue
        }
        if json["canBeOrg"].null == nil{
            self.canBeorg = json["canBeOrg"].boolValue
        }
        if json["canBePublic"].null == nil{
            self.canBePublic = json["canBePublic"].boolValue
        }
        if json["canBeprivate"].null == nil{
            self.canBePrivate = json["canBePrivate"].boolValue
        }
    }
    
}
