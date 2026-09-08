//
//  CricketData.swift
//  LiveCricket
//
//  Created by Abhi Reddy on 28/03/2023.
//

import Foundation

struct CricketData: Decodable {
    let typeMatches: [MatchType]
    
}

struct MatchType: Codable {
    let matchType: String
    let seriesAdWrapper: [SeriesAdWrapper]
    
    enum SeriesAdWrapper: Codable {
        enum DecodingError: Error {
            case wrongJSON
        }
        case seriesMatches(SeriesMatches)
        case adDetail(AdDetail)
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case seriesMatches = "seriesMatches"
            case adDetail = "adDetail"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            switch container.allKeys.first {
            case .seriesMatches:
                let value = try container.decode(SeriesMatches.self, forKey: .seriesMatches)
                self = .seriesMatches(value)

            case .adDetail:
                let value = try container.decode(AdDetail.self, forKey: .adDetail)
                self = .adDetail(value)
            case .none:
                throw DecodingError.wrongJSON
            }
        }
        
        func get() -> SeriesMatches {
            switch self {
            case .seriesMatches(let series):
                return series
            case .adDetail(_):
                return SeriesMatches(seriesId: 0, seriesName: "", matches: [])
            }
        }
    }
}


struct AdDetail: Codable {
    let name: String
    let adLayout: String
    let position: Int
    
}

struct SeriesMatches: Codable {
    let seriesId: Int
    let seriesName: String
    let matches: [Match]
    
}


struct Match: Codable {
    let matchInfo: MatchInfo
    let matchScore: MatchScore?
}

struct MatchInfo: Codable {
    let matchId: Int
    let matchFormat: String
    let status: String?
    let state: String
    let team1: Team
    let team2: Team
}

struct Team: Codable {
    let teamId: Int
    let teamName: String
    let teamSName: String
    let imageId: Int
}


struct MatchScore: Codable {
    let team1Score: TeamScore
    let team2Score: TeamScore?
}

struct TeamScore: Codable {
    let inngs1: Inning?
}

struct Inning: Codable {
    let inningsId: Int
    let runs: Int?
    let wickets: Int?
    let overs: Double
}
