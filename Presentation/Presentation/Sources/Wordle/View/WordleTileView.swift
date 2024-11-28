//
//  WordleTileView.swift
//  Presentation
//
//  Created by 최정인 on 11/26/24.
//

import SwiftUI

struct WordleTileView: View {
    @Binding var wordleTile: Wordle
    let size: CGFloat

    // 타일 색상
    private var wordleTileColor: Color {
        switch wordleTile.state {
        case .empty, .typing, .invalid:
                .white
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
                .gray400
        case .typing, .invalid:
                .gray900
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
