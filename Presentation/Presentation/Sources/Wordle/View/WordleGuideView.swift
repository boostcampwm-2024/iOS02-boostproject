//
//  WordleGuideView.swift
//  Presentation
//
//  Created by 최정인 on 11/27/24.
//

import SwiftUI

struct WordleGuideView: View {
    @Binding var isShowingGuideView: Bool

    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .topTrailing) {
                Image(.wordleGuide)
                    .resizable()
                    .scaledToFit()

                Button {
                    isShowingGuideView.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.airplainBlack)
                }
                .padding(horizontalMargin)
            }
            .padding(horizontalMargin)
            Spacer()
        }
        .background(Color.airplainBlack.opacity(0.5))
        .ignoresSafeArea()
    }
}
