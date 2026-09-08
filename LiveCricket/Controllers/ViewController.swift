//
//  ViewController.swift
//  LiveCricket
//
//  Created by Abhi Reddy on 11/03/2023.
//

import Cocoa
import Foundation

class ViewController: NSViewController {
    
    @IBOutlet weak var teamOne: NSImageView!
    @IBOutlet weak var teamTwo: NSImageView!
    @IBOutlet weak var vs: NSTextField!
    @IBOutlet weak var teamOneOversLabel: NSTextField!
    @IBOutlet weak var teamOneRunsLabel: NSTextField!
    @IBOutlet weak var seriesLabel: NSTextField!
    @IBOutlet weak var teamTwoOversLabel: NSTextField!
    @IBOutlet weak var teamTwoRunsLabel: NSTextField!
    @IBOutlet weak var teamOneImage: NSImageView!
    @IBOutlet weak var teamTwoImage: NSImageView!
    @IBOutlet weak var batsmanOneImage: NSImageView!
    @IBOutlet weak var batsmanOneName: NSTextField!
    @IBOutlet weak var batsmanOneScore: NSTextField!
    
    @IBOutlet weak var batsmanTwoScore: NSTextField!
    @IBOutlet weak var batsmanTwoName: NSTextField!
    
    @IBOutlet weak var bowlerName: NSTextField!
    @IBOutlet weak var bowlerFigures: NSTextField!
    
    @IBOutlet weak var currOverView: NSStackView!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    var teamOneImageSet = false
    var finishedRequest: Bool {
        get {
            return false
        }
        set {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.performRequest(query: "getMatch")
            }
        }
    }
    
    var image: NSImage? {
        get {
            return nil
        }
        
        set {
            DispatchQueue.main.async {
                if !self.teamOneImageSet {
                    self.teamOneImage.image = newValue
                    print("ONE")
                    self.teamOneImageSet = true
                } else {
                    print("TWO")
                    self.teamTwoImage.image = newValue
                }
                
            }
            
        }
        
    }
    
    var mainMatchID: Int  = -1
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performRequest(query: "getMatch")
        
        teamOne.roundCorners(radius: 7, borderColor: NSColor.controlAccentColor)
        teamTwo.roundCorners(radius: 7, borderColor: NSColor.controlAccentColor)
        vs.roundCorners(radius: 12, borderColor: NSColor(white: 1.0, alpha: 0))
        
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    static func newInstance() -> ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ViewController")
        
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Unable to instantiate ViewController in Main.storyboard")
        }
        return viewcontroller
    }
    
    func performRequest(query: String, matchId: Int? = nil) {
        var parameter = ""
        
        if query == "getMatch" {
            parameter = "list?matchState=live"
        } else {
            parameter = "get-overs?matchId=\(matchId!)"
        }
        
        let headers = [
            "X-RapidAPI-Key": Secrets.rapidAPIKey,
            "X-RapidAPI-Host": "unofficial-cricbuzz.p.rapidapi.com"
        ]
        
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://unofficial-cricbuzz.p.rapidapi.com/matches/\(parameter)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                //                DispatchQueue.main.async {
                //                    self.statusLabel.stringValue = "Error while retrieving data. Please retry"
                //                }
                self.performRequest(query: query, matchId: matchId)
            } else {
                guard let safeData = data else {
                    fatalError("Could not retrieve data")
                }
                
                if query == "getMatch" {
                    print(String(data: safeData, encoding: .utf8)!)
                    self.parseScoreJSON(data: safeData)
                } else {
                    self.parsePlayerJSON(data: safeData)
                }
            }
        })
        dataTask.resume()
        
    }
    
    func parseScoreJSON(data: Data) {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CricketData.self, from: data)
            
            if mainMatchID == -1 {
                mainMatchID = decodedData.typeMatches[offset].seriesAdWrapper[offset].get().matches[offset].matchInfo.matchId
                while decodedData.typeMatches[offset].seriesAdWrapper[offset].get().matches[0].matchInfo.state
                        == "Complete" {
                    mainMatchID = decodedData.typeMatches[offset].seriesAdWrapper[offset].get().matches[offset].matchInfo.matchId
                    offset += 1
                }
            }
            let liveMatch = decodedData.typeMatches[offset].seriesAdWrapper[offset].get().matches[0]
            let seriesName = decodedData.typeMatches[offset].seriesAdWrapper[offset].get().seriesName
            
            let teamOne = liveMatch.matchInfo.team1
            let teamTwo = liveMatch.matchInfo.team2
            
            var teamRuns = ["Yet to bat", "Yet to bat"]
            var teamWickets = ["", ""]
            var teamOvers = [0.0, 0.0]
            
            //            if self.mainMatchID == -1 {
            //                self.mainMatchID = matchID
            //            } else {
            //                matchID = self.mainMatchID
            //            }
            var totalOvers: String {
                switch liveMatch.matchInfo.matchFormat {
                case "T20":
                    return "/20.0"
                case "ODI":
                    return "/50.0"
                default:
                    return ""
                }
            }
            
            if let matchScore = liveMatch.matchScore {
                DispatchQueue.main.async {
                    self.teamOneRunsLabel.font = NSFont(name: "Chakra Petch Bold", size: 26)
                }
                
                let teamOneScore = matchScore.team1Score.inngs1!
                teamOvers[0] = teamOneScore.overs
                
                if let score = matchScore.team2Score?.inngs1 {
                    DispatchQueue.main.async {
                        self.teamTwoRunsLabel.font = NSFont(name: "Chakra Petch Bold", size: 26)
                        
                    }
                    
                    teamOvers[1] = score.overs
                    teamRuns[1] = score.runs != nil ? String(score.runs!):"0"
                    teamWickets[1] = score.wickets != nil ? "/\(score.wickets!)":"/0"
                    
                }
                
                teamRuns[0] = teamOneScore.runs != nil ? String(teamOneScore.runs!):"0"
                teamWickets[0] = teamOneScore.wickets != nil ? "/\(teamOneScore.wickets!)":"\0"
                print(teamWickets)
                
                teamOvers = checkIfAllOversUsed(overs: teamOvers)
                teamWickets = checkIfAllOut(wickets: teamWickets)
                
                performRequest(query: "getPlayerScores", matchId: mainMatchID)
            }
            
            DispatchQueue.main.async {
                self.teamOneImage.image = NSImage(named: "flags/\(teamOne.teamSName)")
                self.teamTwoImage.image = NSImage(named: "flags/\(teamTwo.teamSName)")
                
                self.teamOneRunsLabel.stringValue = "\(teamRuns[0])\(teamWickets[0])"
                self.teamTwoRunsLabel.stringValue = "\(teamRuns[1])\(teamWickets[1])"
                self.teamOneOversLabel.stringValue = "(\(teamOvers[0])\(totalOvers))"
                self.teamTwoOversLabel.stringValue = "(\(teamOvers[1])\(totalOvers))"
                self.seriesLabel.stringValue = "\(seriesName) | \(teamOne.teamSName) vs \(teamTwo.teamSName)"
                if let status = liveMatch.matchInfo.status {
                    self.statusLabel.stringValue = status
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    
    func parsePlayerJSON(data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PlayerData.self, from: data)
            var striker = 0
            print(decodedData)
            
            var batsmen = [Batsman()]
            if let score = decodedData.miniscore {
                
                let bowler = score.bowlerStriker
                
                DispatchQueue.main.async {
                    
                    if self.batsmanOneName.stringValue != score.batsmanStriker.name! {
                        batsmen = [score.batsmanNonStriker, score.batsmanStriker]
                        striker = 1
                    } else {
                        batsmen = [score.batsmanStriker, score.batsmanNonStriker]
                    }
                    
                    var runs = ["0", "0"]
                    var balls = ["(0)", "(0)"]
                    
                    for i in 0..<batsmen.count    {
                        runs[i] = batsmen[i].runs != nil ? String(batsmen[i].runs!):"0"
                        balls[i] = batsmen[i].balls != nil ? "(\(batsmen[i].balls!))":"(0)"
                    }
                    
                    
                    self.batsmanOneName.stringValue = batsmen[0].name ?? "..."
                    self.batsmanOneScore.stringValue = "\(runs[0]) \(balls[0])"
                    self.batsmanTwoName.stringValue = batsmen[1].name ?? "..."
                    self.batsmanTwoScore.stringValue = "\(runs[1]) \(balls[1])"
                    self.bowlerName.stringValue = bowler.name
                    let bowlerWckts = bowler.wickets != nil ? String(bowler.wickets!):"0"
                    let bowlerRuns = bowler.runs != nil ? String(bowler.runs!):"0"
                    self.bowlerFigures.stringValue = "\(bowlerWckts)-\(bowlerRuns) (\(bowler.overs))"
                    
                    (striker == 0) ? (self.batsmanOneName.stringValue += "○") : (self.batsmanTwoName.stringValue += " ○")
                    
                    if let overStats = score.curOvsStats {
                        var stats = Array(overStats.components(separatedBy: " ")[(overStats.components(separatedBy: " ").lastIndex(of: "|") ?? 0)...])
                        stats.remove(at: 0)
                                                
                                                
                        var newOverStats = ["", "", "", "", "", "" , "" ,"", "", "", "", ""]
                        for i in 0..<stats.count {
                            newOverStats[i] = stats[i]
                        }
                    
                        
                        
                        for (index, stat) in newOverStats.enumerated() {
                            let view = self.currOverView.arrangedSubviews[index] as! NSTextField
                            var newStat = stat
                            
                            if stat == "0" {
                                newStat = "."
                            } else if stat.contains("L") || stat.contains("N") {
                                newStat = String(stat[stat.startIndex]) + "b" + String(stat[stat.utf16.index(stat.startIndex, offsetBy: 1)...])
                            }
                            
                            
                            view.stringValue = newStat
                            view.drawsBackground = true
                            
                            if stat == "4" || stat == "6" {
                                view.backgroundColor = NSColor(red: 0, green: 0.737, blue: 0.831, alpha: 1.0)
                                view.textColor = .white
                                
                            } else {
                                view.backgroundColor = .white
                                view.textColor = NSColor(red: 0, green: 0.737, blue: 0.831, alpha: 1.0)
                                
                            }
                        }
                        
                    }
                    
                }
                
                self.finishedRequest = true
            }
            
        } catch {
            print(error)
        }
    }
    
    
    func checkIfAllOversUsed(overs: [Double]) -> [Double] {
        var newOvers: [Double] = []
        
        for over in overs {
            if String(over).last == "6" {
                newOvers.append(Double(Int(over)+1))
            } else {
                newOvers.append(over)
            }
        }
        
        return newOvers
        
    }
    
    func checkIfAllOut(wickets: [String]) -> [String] {
        var newWickets: [String] = []
        
        for wicket in wickets {
            if wicket.contains("10") {
                newWickets.append("")
            } else {
                newWickets.append(wicket)
            }
        }
        
        return newWickets
    }
    
    
}

extension NSView {
    func roundCorners(radius: CGFloat, borderColor: NSColor) {
        self.wantsLayer = true
        self.layer?.borderWidth = 1.3
        self.layer?.borderColor = borderColor.cgColor
        self.layer?.cornerRadius = radius
        self.layer?.masksToBounds = true
    }
}
