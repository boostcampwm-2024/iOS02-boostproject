//
//  WordleViewModel.swift
//  Presentation
//
//  Created by 최정인 on 11/27/24.
//

import Combine
import Foundation

final class WordleViewModel: ObservableObject {
    @Published var keyboard: [[WordleKeyboard]] = [
        [WordleKeyboard(alphabet: "Q", wordleState: .unused),
         WordleKeyboard(alphabet: "W", wordleState: .unused),
         WordleKeyboard(alphabet: "E", wordleState: .unused),
         WordleKeyboard(alphabet: "R", wordleState: .unused),
         WordleKeyboard(alphabet: "T", wordleState: .unused),
         WordleKeyboard(alphabet: "Y", wordleState: .unused),
         WordleKeyboard(alphabet: "U", wordleState: .unused),
         WordleKeyboard(alphabet: "I", wordleState: .unused),
         WordleKeyboard(alphabet: "O", wordleState: .unused),
         WordleKeyboard(alphabet: "P", wordleState: .unused)],

        [WordleKeyboard(alphabet: "A", wordleState: .unused),
         WordleKeyboard(alphabet: "S", wordleState: .unused),
         WordleKeyboard(alphabet: "D", wordleState: .unused),
         WordleKeyboard(alphabet: "F", wordleState: .unused),
         WordleKeyboard(alphabet: "G", wordleState: .unused),
         WordleKeyboard(alphabet: "H", wordleState: .unused),
         WordleKeyboard(alphabet: "J", wordleState: .unused),
         WordleKeyboard(alphabet: "K", wordleState: .unused),
         WordleKeyboard(alphabet: "L", wordleState: .unused)],

        [WordleKeyboard(alphabet: nil, wordleState: .enter),
         WordleKeyboard(alphabet: "Z", wordleState: .unused),
         WordleKeyboard(alphabet: "X", wordleState: .unused),
         WordleKeyboard(alphabet: "C", wordleState: .unused),
         WordleKeyboard(alphabet: "V", wordleState: .unused),
         WordleKeyboard(alphabet: "B", wordleState: .unused),
         WordleKeyboard(alphabet: "N", wordleState: .unused),
         WordleKeyboard(alphabet: "M", wordleState: .unused),
         WordleKeyboard(alphabet: nil, wordleState: .erase)]
    ]

    @Published var wordle: [[Wordle]] = Array(
        repeating: Array(repeating: .init(alphabet: nil, state: .empty), count: 5),
        count: 6)
    @Published private(set) var isGameOver = false
    @Published private(set) var canSubmitWordle = false

    let wordleWordCount = 5
    let wordleTryCount = 6
    private var triedWordleCount = 0

    // TODO: Persistance에서 정답 꺼내오기
    let answerWord = "MONEY"

    enum Input {
        case typeKeyboard(keyboard: WordleKeyboard)
    }

    func action(input: Input) {
        switch input {
        case .typeKeyboard(let keyboard):
            typeWordleKeyboard(keyboard: keyboard)
        }
    }

    private func typeWordleKeyboard(keyboard: WordleKeyboard) {
        switch keyboard.wordleState {
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
            let inputWord = wordle[triedWordleCount].compactMap { $0.alphabet }.map { String($0) }.joined()
            guard !words.contains(inputWord) else {
                canSubmitWordle = true
                return
            }
            for index in 0..<wordleWordCount {
                wordle[triedWordleCount][index].state = .invalid
            }
            canSubmitWordle = false
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
        guard !isGameOver,
              !wordle[triedWordleCount].contains(where: { $0.alphabet == nil })
        else { return }
        let submitWordle = wordle[triedWordleCount].compactMap { $0.alphabet }
        let answerWordle = Array(answerWord.map { String($0) })

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

        if answerWord == submitWordle.joined() || triedWordleCount == 6 {
            isGameOver = true
            canSubmitWordle = false
        }
    }

    private func changeKeyboardState(alphabet: String, state: KeyboardState) {
        for index in 0..<3 {
            guard let keyboardIndex = keyboard[index].firstIndex(where: { $0.alphabet == alphabet}) else { continue }
            switch keyboard[index][keyboardIndex].wordleState {
            case .correct:
                return
            case .misplaced:
                if state == .correct {
                    keyboard[index][keyboardIndex].wordleState = state
                }
            default:
                keyboard[index][keyboardIndex].wordleState = state
            }
        }
    }
}

// TODO: Persistance 영역에 저장해놓기
let words: [String] = [
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
