//
//  KeyboardTileView.swift
//  Presentation
//
//  Created by 최정인 on 11/26/24.
//

import SwiftUI

struct KeyboardTileView: View {
    @Binding var wordleKeyboard: WordleKeyboard
    let keyboardWidth: CGFloat
    let keyboardHeight: CGFloat
    let action: () -> Void

    private enum KeyboardTileViewLayoutConstant {
        static let keyboardCornerRadius: CGFloat = 10
        static let enterFontSize: CGFloat = 13
    }

    // 타일 색상
    private var keywordColor: Color {
        switch wordleKeyboard.keyboardState {
        case .unused, .enter, .erase:
                .gray200
        case .wrong:
                .gray600
        case .correct:
                .airplainBlue
        case .misplaced:
                .wordleYellow
        }
    }

    // Text 색상
    private var keyboardTextColor: Color {
        switch wordleKeyboard.keyboardState {
        case .unused, .enter, .erase:
                .black
        default:
                .white
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: KeyboardTileViewLayoutConstant.keyboardCornerRadius)
                    .fill(keywordColor)
                    .frame(width: keyboardWidth, height: keyboardHeight)

                if let alphabet = wordleKeyboard.alphabet {
                    Text(alphabet)
                        .font(Font(AirplainFont.Heading3))
                        .foregroundStyle(keyboardTextColor)
                } else if wordleKeyboard.keyboardState == .erase {
                    Text("⌫")
                        .font(Font(AirplainFont.Heading3))
                        .foregroundStyle(keyboardTextColor)
                } else if wordleKeyboard.keyboardState == .enter {
                    Text("ENTER")
                        .font(.system(size: KeyboardTileViewLayoutConstant.enterFontSize, weight: .bold))
                        .foregroundStyle(keyboardTextColor)
                }
            }
        }
    }
}
