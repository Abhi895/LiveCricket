//
//  PlayerData.swift
//  LiveCricket
//
//  Created by Abhi Reddy on 03/04/2023.
//

import Foundation

struct PlayerData: Decodable {
    var miniscore: Miniscore?
}

struct Miniscore: Decodable {
    var batsmanStriker: Batsman
    var batsmanNonStriker: Batsman
    var bowlerStriker: Bowler
    var curOvsStats: String?
}

struct Batsman: Decodable {
    var id: Int?
    var balls: Int?
    var runs: Int?
    var name: String?
}

struct Bowler: Decodable {
    var name: String
    var id: Int
    var overs: String
    var runs: Int?
    var wickets: Int?
    
}
