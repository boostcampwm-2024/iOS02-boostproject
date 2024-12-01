//
//  GameObjectView.swift
//  Presentation
//
//  Created by 최정인 on 11/27/24.
//

import Domain
import UIKit

public final class GameObjectView: WhiteboardObjectView {
    private enum GameObjectViewLayoutConstant {
        static let backgroundCornerRadius: CGFloat = 15
        static let wordleLabelTopMargin: CGFloat = 7
        static let labelBottomMargin: CGFloat = 9
        static let medalLabelTrailingMargin: CGFloat = 7
    }

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray100
        view.layer.cornerRadius = GameObjectViewLayoutConstant.backgroundCornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private let wordleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎮 Wordle"
        label.font = AirplainFont.Subtitle3
        label.textColor = .black
        return label
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Double-tap to Play!"
        label.font = AirplainFont.Body6
        label.textColor = .gray600
        return label
    }()

    private let winnersLabel: UILabel = {
        let label = UILabel()
        label.font = AirplainFont.Body5
        label.textColor = .gray800
        label.numberOfLines = 3
        return label
    }()

    private let medalLabel: UILabel = {
        let label = UILabel()
        label.text = "🎖️"
        return label
    }()

    private let rankings = ["1st", "2nd", "3rd"]
    private var doubleTapGestureRecognizer: UITapGestureRecognizer?
    private var gameObject: GameObject?
    weak var gameObjectDelegate: GameObjectDelegate?

    init(gameObject: GameObject, gameObjectDelegate: GameObjectDelegate?) {
        self.gameObject = gameObject
        self.gameObjectDelegate = gameObjectDelegate
        super.init(whiteboardObject: gameObject)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configureAttribute() {
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))

        guard let doubleTapGestureRecognizer else { return }
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer)
    }

    override func configureLayout() {
        backgroundView
            .addToSuperview(self)
            .edges(equalTo: self)

        wordleLabel
            .addToSuperview(backgroundView)
            .top(equalTo: backgroundView.topAnchor, constant: GameObjectViewLayoutConstant.wordleLabelTopMargin)
            .centerX(equalTo: backgroundView.centerXAnchor)

        placeholderLabel
            .addToSuperview(backgroundView)
            .bottom(equalTo: backgroundView.bottomAnchor, inset: GameObjectViewLayoutConstant.labelBottomMargin)
            .centerX(equalTo: backgroundView.centerXAnchor)

        medalLabel
            .addToSuperview(backgroundView)
            .top(equalTo: backgroundView.topAnchor, constant: .zero)
            .trailing(
                equalTo: backgroundView.trailingAnchor,
                inset: GameObjectViewLayoutConstant.medalLabelTrailingMargin)

        winnersLabel
            .addToSuperview(backgroundView)
            .centerX(equalTo: backgroundView.centerXAnchor)
            .bottom(equalTo: backgroundView.bottomAnchor, constant: GameObjectViewLayoutConstant.labelBottomMargin)

        medalLabel.isHidden = true
        winnersLabel.isHidden = true
        super.configureLayout()
    }

    override func configureEditable(isEditable: Bool) {
        super.configureEditable(isEditable: isEditable)
        doubleTapGestureRecognizer?.isEnabled = true
    }

    func updateWinners(with gameWinners: [GameWinner]) {
        let maxWinnerCount = 3
        let maxTryCount = 6

        var winnerText = ""
        for index in 0..<min(maxWinnerCount, gameWinners.count) {
            winnerText += "\(rankings[index]) \(gameWinners[index].nickname) \(gameWinners[index].triedCount)/\(maxTryCount) 🔥\n"
        }
        winnerText.removeLast()
        winnersLabel.text = winnerText
    }

    @objc private func didDoubleTap() {
        guard let gameObject else { return }
        gameObjectDelegate?.gameObjectDelegateDidDoubleTap(self, gameObject: gameObject)
    }
}

public protocol GameObjectDelegate: AnyObject {
    /// 게임 오브젝트 뷰가 더블 탭 되었을 때 호출됩니다.
    /// - Parameters:
    ///   - gameObject: 생성된 게임 오브젝트
    func gameObjectDelegateDidDoubleTap(_ sender: GameObjectView, gameObject: GameObject)
}

extension GameObjectView {
    public override func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return gestureRecognizer != doubleTapGestureRecognizer
    }
}
