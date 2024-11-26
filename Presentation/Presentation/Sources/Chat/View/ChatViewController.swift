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
    private lazy var someChat = [
        ChatMessage(message: "아웃풋하고오겠습니다.", sender: Profile(nickname: "딩동", profileIcon: .angel)),
        ChatMessage(message: "조심히 다녀오세요", sender: viewModel.output.myProfile),
        ChatMessage(message: "조이랑 다우니", sender: Profile(nickname: "딴", profileIcon: .cold)),
        ChatMessage(message: "싸우지 마세요", sender: Profile(nickname: "딴", profileIcon: .cold)),
        ChatMessage(message: "저희 싸우는 거 아니에요ㅎㅎ", sender: Profile(nickname: "다우니", profileIcon: .angel)),
        ChatMessage(message: "알아서좀할게요알아서좀할게요알아서좀할게요알아서좀할게요알아서좀할게요", sender: Profile(nickname: "조이", profileIcon: .devil))
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
        let myMessageCellRegistration = UICollectionView
            .CellRegistration<MyMessageCell, ChatMessage> { (cell, _, chatMessage) in
                cell.update(with: chatMessage)
            }
        let peerMessageCellRegistration = UICollectionView
            .CellRegistration<PeerMessageCell, ChatMessage> { (cell, _, chatMessage) in
                cell.update(with: chatMessage)
            }

        dataSource = UICollectionViewDiffableDataSource<CollectionViewSection, ChatMessage>(
            collectionView: chatListView,
            cellProvider: { [weak self] collectionView, indexPath, chatMessage in
                let cell = chatMessage.sender == self?.viewModel.output.myProfile ?
                collectionView.dequeueConfiguredReusableCell(
                    using: myMessageCellRegistration,
                    for: indexPath,
                    item: chatMessage):
                collectionView.dequeueConfiguredReusableCell(
                    using: peerMessageCellRegistration,
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
