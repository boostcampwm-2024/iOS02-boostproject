//
//  ChatViewController.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import Combine
import Domain
import UIKit

public final class ChatViewController: UIViewController {
    private enum ChatLayoutConstant {
        static let textFieldHeight: CGFloat = 41
    }

    private enum CollectionViewSection: Hashable {
        case chat
    }

    private let chatTextFieldView = ChatTextFieldView(frame: .zero)
    private let chatListView: UICollectionView = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        let collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)

        return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()

    private var dataSource: UICollectionViewDiffableDataSource<CollectionViewSection, ChatMessage>?
    private let viewModel: ChatViewModel
    private var cancellables: Set<AnyCancellable>

    // TODO: 테스트 코드
    private var someChat = [
        ChatMessage(message: "안녕하세요, 딴입니다.", sender: Profile(nickname: "Ddan", profileIcon: .angel)),
        ChatMessage(message: "안녕하세요. 안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요", sender: Profile(nickname: "Ddan", profileIcon: .angel)),
        ChatMessage(message: "안녕하세요, 딴입니다.안녕하세요, 딴입니다.안녕하세요, 딴입니다.안녕하세요, 딴입니다.안녕하세요, 딴입니다.", sender: Profile(nickname: "Ddan", profileIcon: .angel)),
        ChatMessage(message: "라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라라", sender: Profile(nickname: "Ddan", profileIcon: .angel))
    ]

    public init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        cancellables = []
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("ChatViewController 초기화 오류")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
        configureDataSource()
        bind()
    }

    private func configureAttribute() {
        view.backgroundColor = .systemBackground
    }

    private func configureLayout() {
        chatTextFieldView
            .addToSuperview(view)
            .height(equalTo: ChatLayoutConstant.textFieldHeight)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)
            .bottom(equalTo: view.safeAreaLayoutGuide.bottomAnchor, inset: 9)

        chatListView
            .addToSuperview(view)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)
            .top(equalTo: view.safeAreaLayoutGuide.topAnchor, inset: 0)
            .bottom(equalTo: chatTextFieldView.topAnchor, inset: 0)
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<MyMessageCell, ChatMessage> { (cell, _, chatMessage) in
                cell.update(with: chatMessage)
            }

        dataSource = UICollectionViewDiffableDataSource<CollectionViewSection, ChatMessage>(
            collectionView: chatListView,
            cellProvider: { [weak self] collectionView, indexPath, chatMessage in
                let cell = chatMessage.sender == self?.viewModel.output.myProfile ?
                collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: chatMessage):
                collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: chatMessage)
                return cell
            })

        var snapshot = NSDiffableDataSourceSnapshot<CollectionViewSection, ChatMessage>()
        snapshot.appendSections([.chat])
        snapshot.appendItems(someChat)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func bind() {
        viewModel.output.chatMessageListPublisher
            .receive(on: DispatchQueue.main)
            .sink { chatMessageList in
                print(chatMessageList)
            }
            .store(in: &cancellables)
    }
}
