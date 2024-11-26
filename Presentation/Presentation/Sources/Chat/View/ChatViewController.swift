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

    private var dataSource: UICollectionViewDiffableDataSource<CollectionViewSection, ChatMessageCellModel>?
    private let viewModel: ChatViewModel
    private var cancellables: Set<AnyCancellable>

    // TODO: 테스트 코드
    private lazy var someChat = [
        ChatMessageCellModel(chatMessage: ChatMessage(message: "오늘 점심 뭐먹을까요??", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "슬쩍 국밥 제시해보겠습니다하하하하하하하하하하ㅏㅎ하ㅏㅎ하ㅏ하하하하하.", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "아니면 햄버거도 괜찮습니다...", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "돈까스는 어떠신지.", sender: Profile(nickname: "조이", profileIcon: .devil)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "저는 쭈꾸미 추천해보겠습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "햄버거도 좋습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "다 좋긴해요", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "룰렛 돌리시죠..", sender: viewModel.output.myProfile), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "오늘 점심 뭐먹을까요??", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "슬쩍 국밥 제시해보겠습니다하하하하하하하하하하ㅏㅎ하ㅏㅎ하ㅏ하하하하하.", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "아니면 햄버거도 괜찮습니다...", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "돈까스는 어떠신지.", sender: Profile(nickname: "조이", profileIcon: .devil)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "저는 쭈꾸미 추천해보겠습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "햄버거도 좋습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "다 좋긴해요", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "룰렛 돌리시죠..", sender: viewModel.output.myProfile), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "오늘 점심 뭐먹을까요??", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "슬쩍 국밥 제시해보겠습니다하하하하하하하하하하ㅏㅎ하ㅏㅎ하ㅏ하하하하하.", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "아니면 햄버거도 괜찮습니다...", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "돈까스는 어떠신지.", sender: Profile(nickname: "조이", profileIcon: .devil)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "저는 쭈꾸미 추천해보겠습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "햄버거도 좋습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "다 좋긴해요", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "룰렛 돌리시죠..", sender: viewModel.output.myProfile), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "오늘 점심 뭐먹을까요??", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "슬쩍 국밥 제시해보겠습니다하하하하하하하하하하ㅏㅎ하ㅏㅎ하ㅏ하하하하하.", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "아니면 햄버거도 괜찮습니다...", sender: Profile(nickname: "딩동", profileIcon: .angel)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "돈까스는 어떠신지.", sender: Profile(nickname: "조이", profileIcon: .devil)), chatMessageType: .single),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "저는 쭈꾸미 추천해보겠습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "햄버거도 좋습니다.", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "다 좋긴해요", sender: Profile(nickname: "다우니", profileIcon: .cold)), chatMessageType: .last),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .first),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "음.. 전 고민좀해보겠습니다..", sender: viewModel.output.myProfile), chatMessageType: .between),
        ChatMessageCellModel(chatMessage: ChatMessage(message: "룰렛 돌리시죠..", sender: viewModel.output.myProfile), chatMessageType: .last)
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
        chatListView.showsVerticalScrollIndicator = false
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
            .CellRegistration<MyMessageCell, ChatMessageCellModel> { (cell, _, chatMessageCellModel) in
                cell.update(with: chatMessageCellModel)
            }
        let peerMessageCellRegistration = UICollectionView
            .CellRegistration<PeerMessageCell, ChatMessageCellModel> { (cell, _, chatMessageCellModel) in
                cell.update(with: chatMessageCellModel)
            }

        dataSource = UICollectionViewDiffableDataSource<CollectionViewSection, ChatMessageCellModel>(
            collectionView: chatListView,
            cellProvider: { [weak self] collectionView, indexPath, chatMessageCellModel in
                let cell = chatMessageCellModel.chatMessage.sender == self?.viewModel.output.myProfile ?
                collectionView.dequeueConfiguredReusableCell(
                    using: myMessageCellRegistration,
                    for: indexPath,
                    item: chatMessageCellModel):
                collectionView.dequeueConfiguredReusableCell(
                    using: peerMessageCellRegistration,
                    for: indexPath,
                    item: chatMessageCellModel)
                return cell
            })

        var snapshot = NSDiffableDataSourceSnapshot<CollectionViewSection, ChatMessageCellModel>()
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
