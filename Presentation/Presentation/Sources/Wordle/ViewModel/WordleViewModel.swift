//
//  WordleViewModel.swift
//  Presentation
//
//  Created by 최정인 on 11/27/24.
//

import Combine
import Domain
import Foundation

final class WordleViewModel: ObservableObject {
    @Published var keyboard: [[WordleKeyboard]] = [
        [WordleKeyboard(alphabet: "Q", keyboardState: .unused),
         WordleKeyboard(alphabet: "W", keyboardState: .unused),
         WordleKeyboard(alphabet: "E", keyboardState: .unused),
         WordleKeyboard(alphabet: "R", keyboardState: .unused),
         WordleKeyboard(alphabet: "T", keyboardState: .unused),
         WordleKeyboard(alphabet: "Y", keyboardState: .unused),
         WordleKeyboard(alphabet: "U", keyboardState: .unused),
         WordleKeyboard(alphabet: "I", keyboardState: .unused),
         WordleKeyboard(alphabet: "O", keyboardState: .unused),
         WordleKeyboard(alphabet: "P", keyboardState: .unused)],

        [WordleKeyboard(alphabet: "A", keyboardState: .unused),
         WordleKeyboard(alphabet: "S", keyboardState: .unused),
         WordleKeyboard(alphabet: "D", keyboardState: .unused),
         WordleKeyboard(alphabet: "F", keyboardState: .unused),
         WordleKeyboard(alphabet: "G", keyboardState: .unused),
         WordleKeyboard(alphabet: "H", keyboardState: .unused),
         WordleKeyboard(alphabet: "J", keyboardState: .unused),
         WordleKeyboard(alphabet: "K", keyboardState: .unused),
         WordleKeyboard(alphabet: "L", keyboardState: .unused)],

        [WordleKeyboard(alphabet: nil, keyboardState: .enter),
         WordleKeyboard(alphabet: "Z", keyboardState: .unused),
         WordleKeyboard(alphabet: "X", keyboardState: .unused),
         WordleKeyboard(alphabet: "C", keyboardState: .unused),
         WordleKeyboard(alphabet: "V", keyboardState: .unused),
         WordleKeyboard(alphabet: "B", keyboardState: .unused),
         WordleKeyboard(alphabet: "N", keyboardState: .unused),
         WordleKeyboard(alphabet: "M", keyboardState: .unused),
         WordleKeyboard(alphabet: nil, keyboardState: .erase)]
    ]

    @Published var wordle: [[Wordle]] = Array(
        repeating: Array(repeating: .init(alphabet: nil, state: .empty), count: 5),
        count: 6)
    @Published private(set) var isGameOver = false
    @Published private(set) var canSubmitWordle = false

    private let gameRepository: GameRepositoryInterface
    let gameObject: GameObject
    private var triedWordleCount = 0
    let wordleWordCount = 5
    let wordleTryCount = 6

    enum Input {
        case typeKeyboard(keyboard: WordleKeyboard)
        case loadWordleHistory
        case saveWordleHistory
    }

    init(
        gameRepository: GameRepositoryInterface,
        gameObject: GameObject
    ) {
        self.gameRepository = gameRepository
        self.gameObject = gameObject
    }

    func action(input: Input) {
        switch input {
        case .typeKeyboard(let keyboard):
            typeWordleKeyboard(keyboard: keyboard)
        case .loadWordleHistory:
            loadWordleHistory()
        case .saveWordleHistory:
            saveWordleHistory()
        }
    }

    private func typeWordleKeyboard(keyboard: WordleKeyboard) {
        switch keyboard.keyboardState {
        case .enter:
            submitWordle()
        case .erase:
            eraseAlphabet()
        default:
            guard let alphabet = keyboard.alphabet else { return }
            typeWordleAlphabet(alphabet: alphabet)
        }
    }

    private func typeWordleAlphabet(alphabet: String) {
        guard
            let currentIndex = wordle[triedWordleCount].firstIndex(where: { $0.alphabet == nil }),
            currentIndex < wordleWordCount
        else { return }
        wordle[triedWordleCount][currentIndex].alphabet = alphabet
        wordle[triedWordleCount][currentIndex].state = .typing

        if currentIndex == wordleWordCount - 1 {
            let inputWord = wordle[triedWordleCount]
                .compactMap { $0.alphabet }
                .map { String($0) }
                .joined()

            guard gameRepository.containsWord(word: inputWord) else {
                canSubmitWordle = false
                for index in 0..<wordleWordCount {
                    wordle[triedWordleCount][index].state = .invalid
                }
                return
            }
            canSubmitWordle = true
        }
    }

    private func eraseAlphabet() {
        guard wordle[triedWordleCount].filter({ $0.alphabet == nil }).count < wordleWordCount
        else { return }

        var currentIndex = wordleWordCount
        if let index = wordle[triedWordleCount].firstIndex(where: { $0.alphabet == nil }) {
            currentIndex = index
        }
        wordle[triedWordleCount][currentIndex-1].alphabet = nil
        wordle[triedWordleCount][currentIndex-1].state = .empty

        if wordle[triedWordleCount].contains(where: { $0.state == .invalid }) {
            for index in 0..<currentIndex-1 {
                wordle[triedWordleCount][index].state = .typing
            }
        }
    }

    private func submitWordle() {
        guard
            !isGameOver,
            !wordle[triedWordleCount].contains(where: { $0.alphabet == nil })
        else { return }
        let submitWordle = wordle[triedWordleCount].compactMap { $0.alphabet }
        changeWordleState(submitWordle: submitWordle)
    }

    private func changeKeyboardState(alphabet: String, state: KeyboardState) {
        for index in 0..<3 {
            guard let keyboardIndex = keyboard[index].firstIndex(where: { $0.alphabet == alphabet}) else { continue }
            switch keyboard[index][keyboardIndex].keyboardState {
            case .correct:
                return
            case .misplaced:
                if state == .correct {
                    keyboard[index][keyboardIndex].keyboardState = state
                }
            default:
                keyboard[index][keyboardIndex].keyboardState = state
            }
        }
    }

    private func changeWordleState(submitWordle: [String]) {
        let answerWordle = Array(gameObject.gameAnswer.map { String($0) })
        for index in 0..<wordleWordCount {
            if submitWordle[index] == answerWordle[index] {
                wordle[triedWordleCount][index].state = .correct
                changeKeyboardState(alphabet: submitWordle[index], state: .correct)
            } else if answerWordle.contains(submitWordle[index]) {
                wordle[triedWordleCount][index].state = .misplaced
                changeKeyboardState(alphabet: submitWordle[index], state: .misplaced)
            } else {
                wordle[triedWordleCount][index].state = .wrong
                changeKeyboardState(alphabet: submitWordle[index], state: .wrong)
            }
        }
        triedWordleCount += 1

        guard gameObject.gameAnswer == submitWordle.joined() || triedWordleCount == 6  else { return }
        isGameOver = true
        canSubmitWordle = false
    }

    private func loadWordleHistory() {
        let wordleHistory = gameRepository.loadWordleHistory(gameID: gameObject.id)
        for word in wordleHistory {
            let wordArray = word.map { String($0) }
            for index in 0..<wordleWordCount {
                wordle[triedWordleCount][index].alphabet = wordArray[index]
            }
            changeWordleState(submitWordle: wordArray)
        }
    }

    private func saveWordleHistory() {
        var wordleHistory: [String] = []
        for word in wordle {
            guard
                word.filter({ $0.alphabet != nil }).count == 5,
                !word.contains(where: { $0.state == .typing })
            else {
                gameRepository.saveWordleHistory(gameID: gameObject.id, wordleHistory: wordleHistory)
                return
            }
            let wordString = word.compactMap { $0.alphabet }.joined()
            wordleHistory.append(wordString)
        }
        if isGameOver {
            gameRepository.saveWordleHistory(gameID: gameObject.id, wordleHistory: wordleHistory)
        }
    }
}
