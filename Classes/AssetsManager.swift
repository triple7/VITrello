//
//  AssetsManager.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 26/10/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Foundation
import AVFoundation

class AssetsManager{
    var player:AVAudioPlayer?

    let chalkBoard = Bundle.main.url(forResource: "board", withExtension: "mp3")!
        let shuffle = Bundle.main.url(forResource: "shuffle", withExtension: "mp3")!
    let deal = Bundle.main.url(forResource: "deal", withExtension: "mp3")!
        let stapler = Bundle.main.url(forResource: "stapler", withExtension: "mp3")!
        let envelope = Bundle.main.url(forResource: "envelope", withExtension: "mp3")!
            let board_create = Bundle.main.url(forResource: "board_create", withExtension: "mp3")!
            let list_create = Bundle.main.url(forResource: "list_create", withExtension: "mp3")!
                let card_create = Bundle.main.url(forResource: "card_create", withExtension: "mp3")!
                        let checklist_create = Bundle.main.url(forResource: "checklist_create", withExtension: "mp3")!
                    let checkItem_create = Bundle.main.url(forResource: "checkItem_create", withExtension: "mp3")!
            let trash = Bundle.main.url(forResource: "throw", withExtension: "mp3")!
    
    private var soundLib:[String: URL]
    
    init(){
soundLib = [
        "board": chalkBoard,
        "list": shuffle,
        "card": deal,
        "checklist": envelope,
        "checkItem": stapler,
        "board_create": board_create, "list_create": list_create,
        "card_create": card_create,
        "checklist_create": checklist_create,
        "checkItem_create": checkItem_create,
        "delete": trash
        ]
    }
    
    func play(_ type: String){
    do{
    player = try AVAudioPlayer(contentsOf: soundLib[type]!)
    player!.play()
    }catch{
    print("Couldn't open file")
    }
    }
    
}
let assets = AssetsManager()
