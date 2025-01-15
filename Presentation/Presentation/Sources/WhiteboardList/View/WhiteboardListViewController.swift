//
//  WhiteboardListViewController.swift
//  Presentation
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Domain
import UIKit

public final class WhiteboardListViewController: UIViewController {
    private enum WhiteboardListLayoutConstant {
        static let buttonSize: CGFloat = 44
        static let upperComponentTopMargin: CGFloat = 70
        static let mainTitleLabelWidth: CGFloat = 199
        static let mainTitleLabelHeight: CGFloat = 43
        static let itemHeight: CGFloat = 65
        static let itemVerticalMargin: CGFloat = 8
        static let labelLineSpacing: CGFloat = 10
        static let createButtonTrailingMargin: CGFloat = 29
        static let collectionViewTopMargin: CGFloat = 10
        static let itemSpacing: CGFloat = 5
    }

    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "AirplaIN"
        label.textColor = .airplainBlack
        label.font = AirplainFont.Heading1
        return label
    }()

    private let createWhiteboardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .airplainBlue
        return button
    }()

    private let configureProfileButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .airplainBlue
        return button
    }()

    private let emptyListLabel: UILabel = {
        let label = UILabel()
        label.text = "주변에 생성된 화이트보드가 없습니다.\n\n먼저 만들어보는건 어떤가요?"
        label.textColor = .gray500
        label.font = AirplainFont.Body2
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

    private var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = UIRefreshControl()
    private var dataSource: UICollectionViewDiffableDataSource<Int, Whiteboard>?
    private let viewModel: WhiteboardListViewModel
    private var cancellables = Set<AnyCancellable>()

    private let whiteboardObjectViewFactory: WhiteboardObjectViewFactoryable
    private let profileViewModel: ProfileViewModel
    private let profileRepository: ProfileRepositoryInterface
    private let whiteboardUseCase: WhiteboardListUseCaseInterface
    private let photoUseCase: PhotoUseCaseInterface
    private let drawObjectUseCase: DrawObjectUseCaseInterface
    private let textObjectUseCase: TextObjectUseCaseInterface
    private let chatUseCase: ChatUseCaseInterface
    private let gameRepository: GameRepositoryInterface
    private let gameObjectUseCase: GameObjectUseCaseInterface
    private let manageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface
    private let manageWhiteboardObjectUseCase: WhiteboardUseCaseInterface

    public init(
        viewModel: WhiteboardListViewModel,
        whiteboardObjectViewFactory: WhiteboardObjectViewFactoryable,
        profileViewModel: ProfileViewModel,
        profileRepository: ProfileRepositoryInterface,
        whiteboardUseCase: WhiteboardListUseCaseInterface,
        photoUseCase: PhotoUseCaseInterface,
        drawObjectUseCase: DrawObjectUseCaseInterface,
        textObjectUseCase: TextObjectUseCaseInterface,
        chatUseCase: ChatUseCaseInterface,
        gameRepository: GameRepositoryInterface,
        gameObjectUseCase: GameObjectUseCaseInterface,
        manageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface,
        manageWhiteboardObjectUseCase: WhiteboardUseCaseInterface
    ) {
        self.viewModel = viewModel
        self.whiteboardObjectViewFactory = whiteboardObjectViewFactory
        self.profileViewModel = profileViewModel
        self.profileRepository = profileRepository
        self.whiteboardUseCase = whiteboardUseCase
        self.photoUseCase = photoUseCase
        self.drawObjectUseCase = drawObjectUseCase
        self.textObjectUseCase = textObjectUseCase
        self.chatUseCase = chatUseCase
        self.gameRepository = gameRepository
        self.gameObjectUseCase = gameObjectUseCase
        self.manageWhiteboardToolUseCase = manageWhiteboardToolUseCase
        self.manageWhiteboardObjectUseCase = manageWhiteboardObjectUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
        bind()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.action(input: .disconnectWhiteboard)
        viewModel.action(input: .startSearchingWhiteboards)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.action(input: .stopSearchingWhiteboard)
    }

    private func configureAttribute() {
        view.backgroundColor = .systemBackground

        let createWhiteboardAction = UIAction { [weak self] _ in
            self?.viewModel.action(input: .createWhiteboard)

            guard
                let whiteboardObjectViewFactory = self?.whiteboardObjectViewFactory,
                let profileRepository = self?.profileRepository,
                let whiteboardUseCase = self?.whiteboardUseCase,
                let photoUseCase = self?.photoUseCase,
                let drawObjectUseCase = self?.drawObjectUseCase,
                let textObjectUseCase = self?.textObjectUseCase,
                let chatUseCase = self?.chatUseCase,
                let gameRepository = self?.gameRepository,
                let gameObjectUseCase = self?.gameObjectUseCase,
                let manageWhiteboardToolUseCase = self?.manageWhiteboardToolUseCase,
                let manageWhiteboardObjectUseCase = self?.manageWhiteboardObjectUseCase
            else { return }

            let whiteboardViewModel = WhiteboardViewModel(
                whiteboardUseCase: whiteboardUseCase,
                photoUseCase: photoUseCase,
                drawObjectUseCase: drawObjectUseCase,
                textObjectUseCase: textObjectUseCase,
                chatUseCase: chatUseCase,
                gameObjectUseCase: gameObjectUseCase,
                manageWhiteboardToolUseCase: manageWhiteboardToolUseCase,
                manageWhiteboardObjectUseCase: manageWhiteboardObjectUseCase)
            let whiteboardViewController = WhiteboardViewController(
                viewModel: whiteboardViewModel,
                objectViewFactory: whiteboardObjectViewFactory,
                profileRepository: profileRepository,
                chatUseCase: chatUseCase,
                gameRepository: gameRepository)
            self?.navigationController?.isNavigationBarHidden = false
            self?.navigationController?.pushViewController(whiteboardViewController, animated: true)
        }
        createWhiteboardButton.addAction(createWhiteboardAction, for: .touchUpInside)

        // TODO: - Profile View 이동 주입 시점
        let showProfileViewController = UIAction { [weak self] _ in
            guard let profileViewModel = self?.profileViewModel else { return }
            let profileViewController = UINavigationController(
                rootViewController: ProfileViewController(viewModel: profileViewModel))
            profileViewController.modalPresentationStyle = .fullScreen
            self?.present(profileViewController, animated: true)
        }
        configureProfileButton.addAction(showProfileViewController, for: .touchUpInside)

        configureCollectionView()
        configureDataSource()
    }

    private func configureLayout() {
        mainTitleLabel
            .addToSuperview(view)
            .size(width: WhiteboardListLayoutConstant.mainTitleLabelWidth,
                  height: WhiteboardListLayoutConstant.mainTitleLabelHeight)
            .top(equalTo: view.topAnchor,
                 inset: WhiteboardListLayoutConstant.upperComponentTopMargin)
            .leading(equalTo: view.leadingAnchor, inset: horizontalMargin)

        configureProfileButton
            .addToSuperview(view)
            .size(width: WhiteboardListLayoutConstant.buttonSize,
                  height: WhiteboardListLayoutConstant.buttonSize)
            .top(equalTo: view.topAnchor,
                 inset: WhiteboardListLayoutConstant.upperComponentTopMargin)
            .trailing(equalTo: view.trailingAnchor, inset: horizontalMargin)

        createWhiteboardButton
            .addToSuperview(view)
            .size(width: WhiteboardListLayoutConstant.buttonSize,
                  height: WhiteboardListLayoutConstant.buttonSize)
            .top(equalTo: view.topAnchor,
                 inset: WhiteboardListLayoutConstant.upperComponentTopMargin)
            .trailing(equalTo: configureProfileButton.leadingAnchor,
                      inset: WhiteboardListLayoutConstant.createButtonTrailingMargin)

        collectionView
            .addToSuperview(view)
            .top(equalTo: mainTitleLabel.bottomAnchor,
                 constant: WhiteboardListLayoutConstant.collectionViewTopMargin)
            .horizontalEdges(equalTo: view)
            .bottom(equalTo: view.bottomAnchor, inset: .zero)

        emptyListLabel
            .addToSuperview(view)
            .center(in: view)

        loadingIndicator
            .addToSuperview(view)
            .center(in: view)
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.backgroundColor = .systemBackground
        collectionView.register(WhiteboardCell.self, forCellWithReuseIdentifier: WhiteboardCell.reuseIdentifier)

        let refreshAction = UIAction { [weak self] _ in
            self?.refreshWhiteboardList()
        }
        refreshControl.addAction(refreshAction, for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(WhiteboardListLayoutConstant.itemHeight))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(
            top: WhiteboardListLayoutConstant.itemVerticalMargin,
            leading: .zero,
            bottom: WhiteboardListLayoutConstant.itemVerticalMargin,
            trailing: .zero)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))

        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(WhiteboardListLayoutConstant.itemSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: .zero,
            leading: horizontalMargin,
            bottom: .zero,
            trailing: horizontalMargin)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Whiteboard>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, board in
                return self?.configureCell(
                    collectionView: collectionView,
                    indexPath: indexPath,
                    board: board)
            })
    }

    private func configureCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        board: Whiteboard
    ) -> UICollectionViewCell? {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WhiteboardCell.reuseIdentifier,
                for: indexPath) as? WhiteboardCell
        else { return nil }
        cell.configure(with: board)
        return cell
    }

    private func applySnapshot(whiteboards: [Whiteboard]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Whiteboard>()
        snapshot.appendSections([0])
        snapshot.appendItems(whiteboards, toSection: 0)
        guard let dataSource = dataSource else { return }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func moveToWhiteboard() {
        let whiteboardViewModel = WhiteboardViewModel(
            whiteboardUseCase: whiteboardUseCase,
            photoUseCase: photoUseCase,
            drawObjectUseCase: drawObjectUseCase,
            textObjectUseCase: textObjectUseCase,
            chatUseCase: chatUseCase,
            gameObjectUseCase: gameObjectUseCase,
            manageWhiteboardToolUseCase: manageWhiteboardToolUseCase,
            manageWhiteboardObjectUseCase: manageWhiteboardObjectUseCase)
        let whiteboardViewController = WhiteboardViewController(
            viewModel: whiteboardViewModel,
            objectViewFactory: whiteboardObjectViewFactory,
            profileRepository: profileRepository,
            chatUseCase: chatUseCase,
            gameRepository: gameRepository)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(whiteboardViewController, animated: true)
    }

    private func showFailAlert() {
        let alertController = UIAlertController(
            title: "연결에 실패했습니다",
            message: "화이트보드에 연결할 수 없습니다. 다시 시도해주세요.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    private func bind() {
        viewModel.output.whiteboardListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] whiteboards in
                self?.emptyListLabel.isHidden = !whiteboards.isEmpty
                self?.applySnapshot(whiteboards: whiteboards)
            }
            .store(in: &cancellables)

        viewModel.output.connectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.stopLoading()
                if isConnected {
                    self?.moveToWhiteboard()
                } else {
                    self?.showFailAlert()
                    self?.viewModel.action(input: .disconnectWhiteboard)
                }
            }
            .store(in: &cancellables)
    }

    private func refreshWhiteboardList() {
        viewModel.action(input: .startSearchingWhiteboards)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    private func startLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func stopLoading() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

// MARK: - UICollectionViewDelegate
extension WhiteboardListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedWhiteboard = dataSource?.itemIdentifier(for: indexPath) else { return }
        viewModel.action(input: .joinWhiteboard(whiteboard: selectedWhiteboard))
        startLoading()
    }
}
