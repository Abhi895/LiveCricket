# LiveCricket

A native macOS menu-bar-style app that polls a live cricket scores API and
renders the current match — teams, current innings score/overs, striker and
non-striker batsmen, and the bowler's figures — updating automatically every
10 seconds.

## How it works

- `ViewController` polls the API on a timer and updates team crests, scores,
  and the current over on the main thread.
- `CricketData` models the match-list response, handling a response shape
  that interleaves real matches with ad placements (`seriesMatches` /
  `adDetail`) via a custom `Decodable` implementation.
- `PlayerData` models the live mini-scorecard (striker/non-striker batsmen,
  current bowler).

## Stack

- AppKit (`NSViewController`), no third-party dependencies
- Live cricket data via a RapidAPI cricket scores endpoint

## Getting started

1. Copy `LiveCricket/Secrets.example.swift` to `LiveCricket/Secrets.swift`
   and add your own RapidAPI key (gitignored, not committed).
2. Open `LiveCricket.xcodeproj` in Xcode and run.

## Status

Personal project, built to track live matches without opening a browser.
