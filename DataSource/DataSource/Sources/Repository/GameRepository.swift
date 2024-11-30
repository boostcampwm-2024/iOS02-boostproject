//
//  GameRepository.swift
//  DataSource
//
//  Created by 최정인 on 11/27/24.
//

import Domain
import Foundation

public final class GameRepository: GameRepositoryInterface {
    private let persistenceService: PersistenceInterface
    private let wordleAnswerKey = "AirplainWordle"
    private let wordleHistoryKey = "AirplainWordleHistory"

    public init(persistenceService: PersistenceInterface) {
        self.persistenceService = persistenceService
    }

    public func randomGameAnswer() -> String {
        guard
            let wordleSet: [String] = persistenceService.load(forKey: wordleAnswerKey),
            let wordleAnswer = wordleSet.randomElement()
        else {
            saveWordleAnswerSet(wordleAnswerSet: gameWords)
            return gameWords.randomElement() ?? "KOREA"
        }

        return wordleAnswer
    }

    public func saveWordleAnswerSet(wordleAnswerSet: [String]) {
        persistenceService.save(data: wordleAnswerSet, forKey: wordleAnswerKey)
    }

    public func containsWord(word: String) -> Bool {
        guard
            let wordleSet: [String] = persistenceService.load(forKey: wordleAnswerKey),
            wordleSet.contains(word)
        else { return false }

        return true
    }

    public func loadWordleHistory(gameID: UUID) -> [String] {
        guard
            let wordleHistory: [UUID: [String]] = persistenceService.load(forKey: wordleHistoryKey),
            let gameHistory = wordleHistory[gameID]
        else { return [] }
        return gameHistory
    }

    public func saveWordleHistory(gameID: UUID, wordleHistory: [String]) {
        let gameHistory: [UUID: [String]] = [gameID: wordleHistory]
        persistenceService.save(data: gameHistory, forKey: wordleHistoryKey)
    }
}

fileprivate let gameWords: [String] = [
    "APPLE", "BRAVE", "CHARM", "DRINK", "EAGER",
    "FABLE", "GLOBE", "HABIT", "IDEAL", "JOKER",
    "KNEEL", "LUNCH", "MAGIC", "NOBLE", "OCEAN",
    "PEACE", "QUEST", "RAVEN", "SPIKE", "TRUST",
    "URBAN", "VIVID", "WITTY", "XENON", "YOUTH",
    "ZEBRA", "ANGEL", "BEACH", "CHESS", "DOUGH",
    "EXILE", "FLOCK", "GRACE", "HOVER", "IVORY",
    "JOINT", "KNEES", "LIGHT", "MOTTO", "NOVEL",
    "OLIVE", "PLACE", "QUIET", "REACT", "SALTY",
    "THICK", "UPPER", "VALVE", "WHITE", "YIELD",
    "ZESTY", "ARISE", "BLEND", "CRANE", "DAISY",
    "EQUIP", "FEAST", "GROVE", "HEART", "INPUT",
    "JOLLY", "KITTY", "LUCKY", "MINER", "NIFTY",
    "OASIS", "PIANO", "QUILT", "RELAX", "SHORE",
    "TOAST", "UMBRA", "VIGOR", "WHEAT", "XYLEM",
    "ABIDE", "BLAME", "CROWN", "DANCE", "EAGLE",
    "FIBER", "GRAPE", "HONEY", "INDEX", "JUMPY",
    "KNIFE", "LOYAL", "MANGO", "NEEDY", "OVERT",
    "PLAZA", "QUAKE", "RUMOR", "STONE", "TABLE",
    "UPSET", "VOCAL", "WHIRL", "AMBER", "BIRTH",
    "CABLE", "DONUT", "ELBOW", "FENCE", "GLIDE",
    "HINGE", "INNER", "JEWEL", "LUNAR", "MEDAL",
    "NURSE", "PENNY", "QUEEN", "RAZOR", "SHELL",
    "TIGER", "UNDER", "VAPOR", "WHALE", "ARENA",
    "BACON", "CHARM", "DOUBT", "EJECT", "FLOOD",
    "GHOST", "HATCH", "IRONY", "JOLLY", "KNOCK",
    "LEMON", "MERRY", "NORTH", "ORBIT", "PRIDE",
    "QUARK", "ADORE", "BLOOM", "CRISP", "DEALT",
    "EVENT", "FLAME", "GRAIN", "HARPY", "INPUT",
    "JAZZY", "KARMA", "LODGE", "MIRTH", "ONION",
    "PETTY", "QUICK", "RANCH", "STARK", "TIMID",
    "UNITY", "WHISK", "ZONAL", "ACORN", "BREAD",
    "CLIFF", "DWELL", "EXACT", "FLOAT", "GLOVE",
    "HAPPY", "IDEAL", "JUICE", "KNACK", "LEAFY",
    "MOTEL", "NAVEL", "OUTER", "PAINT", "QUIRK",
    "REACT", "SPLIT", "TWIST", "UNITE", "VALUE",
    "WASTE", "XERIC", "ZONED", "ALIVE", "BRISK",
    "CRUSH", "DRILL", "EVERY", "FLARE", "GUEST",
    "HOTEL", "IVORY", "JOKER", "KNELT", "LATCH",
    "METAL", "NORTH", "OUTDO", "PLUMB", "QUERY",
    "RHYME", "SPEAR", "TREND", "VAULT", "KOREA",
    "MONTH", "ROUTE", "READY", "MONEY", "PEARL"
]
