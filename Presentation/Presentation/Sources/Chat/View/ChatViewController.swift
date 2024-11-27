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
        static let textFieldBottomPadding: CGFloat = 9
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

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSetUpObserver()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configureTearDownObserver()
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
            .bottom(equalTo: view.safeAreaLayoutGuide.bottomAnchor, inset: ChatLayoutConstant.textFieldBottomPadding)

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
    }

    private func configureSetUpObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardUp),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDown),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    private func configureTearDownObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    private func bind() {
        viewModel.output.chatMessageListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chatMessageList in
                self?.applySnapshot(chatMessageList: chatMessageList)
            }
            .store(in: &cancellables)
    }

    private func applySnapshot(chatMessageList: [ChatMessageCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionViewSection, ChatMessageCellModel>()
        snapshot.appendSections([.chat])
        snapshot.appendItems(chatMessageList)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    @objc private func keyboardUp(notification: NSNotification) {
        guard let keyboardFrame: NSValue = notification
            .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.transform = CGAffineTransform(
                translationX: 0,
                y: -keyboardRectangle.height)
        }
    }

    @objc private func keyboardDown() {
        view.transform = .identity
    }
}
