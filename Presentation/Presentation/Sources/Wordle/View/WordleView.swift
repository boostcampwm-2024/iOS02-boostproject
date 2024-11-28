//
//  WordleView.swift
//  Presentation
//
//  Created by 최정인 on 11/27/24.
//

import SwiftUI

struct WordleView: View {
    @StateObject var viewModel: WordleViewModel
    @State private var isShowingGuideView: Bool = false

    private enum WordleViewLayoutConstant {
        static let wordleAnswerCornerRadius: CGFloat = 10
        static let wordleAnswerWidth: CGFloat = 90
        static let wordleAnswerHeight: CGFloat = 30
        static let wordleSpacing: CGFloat = 10
        static let keyboardHorizontalMargin: CGFloat = 12
        static let keyboardSpacing: CGFloat = 8
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    HStack {
                        Spacer()
                        VStack {
                            if viewModel.isGameOver {
                                wordleAnswerView
                            }
                            Spacer()
                            wordleWordView(geo: geometry)
                            Spacer()
                            wordleKeyboardView(geo: geometry)
                            Spacer()
                        }
                        Spacer()
                    }

                    if isShowingGuideView {
                        WordleGuideView(isShowingGuideView: $isShowingGuideView)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // TODO: Dismiss
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.airplainBlack)
                    }
                    .disabled(isShowingGuideView)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingGuideView.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.airplainBlue)
                    }
                    .disabled(isShowingGuideView)
                }
            }
        }
    }

    // wordle 정답
    private var wordleAnswerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: WordleViewLayoutConstant.wordleAnswerCornerRadius)
                .fill(.airplainBlack)
                .frame(
                    width: WordleViewLayoutConstant.wordleAnswerWidth,
                    height: WordleViewLayoutConstant.wordleAnswerHeight)

            Text(viewModel.answerWord)
                .foregroundStyle(.white)
                .font(Font(AirplainFont.Subtitle2))
        }
    }

    // wordle 타일
    private func wordleWordView(geo: GeometryProxy) -> some View {
        let wordleWordCount: CGFloat = 5
        let totalHorizontalMargin = horizontalMargin * 2
        let wordleSpacing = WordleViewLayoutConstant.wordleSpacing * 4.0

        let wordleSizeByWidth = (geo.size.width - totalHorizontalMargin - wordleSpacing) / wordleWordCount
        let wordleSizeByHeight = ((geo.size.height * 0.5) - wordleSpacing) / wordleWordCount
        let wordleSize = min(wordleSizeByWidth, wordleSizeByHeight)

        return ForEach(0..<viewModel.wordleTryCount, id: \.self) { row in
            HStack {
                ForEach(0..<viewModel.wordleWordCount, id: \.self) { col in
                    WordleTileView(
                        wordleTile: $viewModel.wordle[row][col],
                        size: wordleSize)
                }
            }
        }
    }

    // 키보드
    private func wordleKeyboardView(geo: GeometryProxy) -> some View {
        let totalHorizontalMargin = WordleViewLayoutConstant.keyboardHorizontalMargin * 2
        let keyboardSpacing = WordleViewLayoutConstant.keyboardSpacing * 9

        let keyboardWidth = (geo.size.width - totalHorizontalMargin - keyboardSpacing) / 10
        let keyboardHeight = geo.size.height * 0.063
        let enterKeyboardWidth = keyboardWidth * 1.8

        return VStack {
            ForEach(0..<viewModel.keyboard.count, id: \.self) { row in
                HStack {
                    ForEach(0..<viewModel.keyboard[row].count, id: \.self) { col in
                        KeyboardTileView(
                            wordleKeyboard: $viewModel.keyboard[row][col],
                            keyboardWidth:
                                viewModel.keyboard[row][col].alphabet == nil ? enterKeyboardWidth : keyboardWidth,
                            keyboardHeight: keyboardHeight) {
                                viewModel.action(input: .typeKeyboard(keyboard: viewModel.keyboard[row][col]))
                            }
                            .disabled(
                                viewModel.keyboard[row][col].keyboardState == .enter ?
                                !viewModel.canSubmitWordle : viewModel.isGameOver)
                    }
                }
            }
        }
    }
}
