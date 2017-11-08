//
//  Label.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation
import SwiftyJSON
import Alamofire

enum LabelColor:String{
    case Yellow = "yellow"
    case Purple = "purple"
    case Blue = "blue"
    case Red = "red"
    case green = "green"
    case orange = "orange"
    case black = "black"
    case Sky = "sky"
    case Pink = "pink"
    case Line = "lime"
    case Null = "null"
    
    var color:NSColor{
        switch self{
        case .Yellow: return NSColor.yellow
        case .Purple: return NSColor.purple
        case .Red: return NSColor.red
        case .green: return NSColor.green
        case .orange: return NSColor.orange
        case .black: return NSColor.black
        case .Sky: return NSColor.blue
        case .Pink: return NSColor.brown
        case .Line: return NSColor.clear
        case .Null: return NSColor.clear
        default: return NSColor.blue
        }
    }
}

class Label{
    var id: String!
    var name: String?
    var color: String!
    var boardId: String?
    var uses: Int?
    
    init(_ json: JSON){
        self.id = json["id"].stringValue
        if json["name"].null == nil{
            self.name = json["name"].stringValue
        }
        self.color = json["color"].stringValue
        if json["idBoard"].null == nil{
            self.boardId = json["idBoard"].stringValue
        }
        if json["uses"].null == nil{
            self.uses = json["uses"].intValue
        }
    }
    
}

extension Trello{

    func getLabelsForCardID(_ ID: String, completion: @escaping (Result<[Label]>) -> Void) {
        Alamofire.request(Router.Label(cardID: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var labels = [Label]()
            let data = JSON(json)
            for label in data.arrayValue{
                labels.append(Label(label))
            }
            completion(.success(labels))
        }
    }
    
    func getLabelsForCard(_ card: Card, completion: @escaping (Result<[Label]>) -> Void) {
        getLabelsForCardID(card.id, completion: completion)
    }

    func getLabelsForBoardID(_ ID: String, completion: @escaping (Result<[Label]>) -> Void) {
        Alamofire.request(Router.LabelFromBoard(boardID: ID).URLString, parameters: authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            var labels = [Label]()
            let data = JSON(json)
            for label in data.arrayValue{
                labels.append(Label(label))
            }
            completion(.success(labels))
        }
    }
    


    //Mark: Actions

    
    func addlabel(_ id: String, label: Label, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": label.name as AnyObject] + ["color": label.color as AnyObject] + ["idBoard": label.boardId as AnyObject]
            Alamofire.request(Router.Labels.URLString, method: .post
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
    }
    
    func addLabelToCard(_ id: String, label: Label, completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["color": label.color as AnyObject] + ["name": label.name as AnyObject]
        do{
            try Alamofire.request(Router.Label(cardID: id).asURL(), method: .post
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

    func updateLabel(_ label: Label, type: MemberType,completion: @escaping () -> Void) {
        let parameters = self.authParameters + ["name": label.name as AnyObject] + ["color": label.color as AnyObject]
        do{
            try Alamofire.request(Router.LabelUpdate(Id: label.id).asURL(), method: .put
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func deleteLabelFromCard(_ id: String, labelID: String, completion: @escaping () -> Void) {
        let parameters = self.authParameters
        do{
            try Alamofire.request(Router.LabelDelete(ID: labelID, cardID: id).asURL(), method: .delete
                , parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: {(response)->Void in
                    //print(response.response!)
                })
        }catch let error{
            print(error.localizedDescription)
        }
    }

}
