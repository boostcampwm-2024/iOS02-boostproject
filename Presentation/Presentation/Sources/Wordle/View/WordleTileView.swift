//
//  WordleTileView.swift
//  Presentation
//
//  Created by 최정인 on 11/26/24.
//

import SwiftUI

struct WordleTileView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Binding var wordleTile: Wordle
    let size: CGFloat

    // 타일 색상
    private var wordleTileColor: Color {
        switch wordleTile.state {
        case .empty, .typing, .invalid:
                .clear
        case .wrong:
                .gray500
        case .correct:
                .airplainBlue
        case .misplaced:
                .wordleYellow
        }
    }

    // Text 색상
    private var wordleTextColor: Color {
        switch wordleTile.state {
        case .typing:
                .airplainBlack
        case .invalid:
                .wordleRed
        default:
                .white
        }
    }

    // Border 색상
    private var wordleBorderColor: Color {
        switch wordleTile.state {
        case .empty:
            colorScheme == .light ? .gray400 : .gray900
        case .typing, .invalid:
            colorScheme == .light ? .gray900 : .gray400
        case .correct:
                .airplainBlue
        case .wrong:
                .gray500
        case .misplaced:
                .wordleYellow
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(wordleTileColor)
                .border(wordleBorderColor, width: 2)
                .frame(width: size, height: size)

            Text(wordleTile.alphabet ?? " ")
                .font(Font(AirplainFont.Heading2))
                .foregroundStyle(wordleTextColor)
        }
    }
}
