//
//  GameRepository.swift
//  DataSource
//
//  Created by 최정인 on 11/27/24.
//

import Domain
import Foundation
import OSLog

public final class GameRepository: GameRepositoryInterface {
    private let persistenceService: PersistenceInterface
    private let wordleHistoryKey = "AirplainWordleHistory"
    private var wordleSet: Set<String> = []
    private let logger = Logger()

    public init(persistenceService: PersistenceInterface) {
        self.persistenceService = persistenceService
    }

    public func randomGameAnswer() -> String {
        guard
            !wordleSet.isEmpty,
            let wordleAnswer = wordleSet.randomElement()
        else {
            saveWordleAnswerSet()
            return wordleSet.randomElement() ?? "KOREA"
        }

        return wordleAnswer
    }

    public func saveWordleAnswerSet() {
        let moduleBundle = Bundle(for: GameRepository.self)
        guard let fileURL = moduleBundle.url(forResource: "words", withExtension: "txt") else {
            logger.log(level: .error, "File 불러오기 실패: word.txt 파일을 찾을 수 없습니다.")
            return
        }

        do {
            let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
            let words = fileContents
                .split(separator: "\n")
                .map { String($0).uppercased() }
            wordleSet = Set(words)
        } catch {
            logger.log(level: .error, "File 읽기 실패: word.txt 파일을 읽을 수 없습니다.")
            return
        }
    }

    public func containsWord(word: String) -> Bool {
        return wordleSet.contains(word)
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
