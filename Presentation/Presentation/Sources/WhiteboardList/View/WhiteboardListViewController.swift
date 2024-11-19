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
        static let buttonSize: CGFloat = 26
        static let upperComponentTopMargin: CGFloat = 70
        static let mainTitleLabelWidth: CGFloat = 199
        static let mainTitleLabelHeight: CGFloat = 43
        static let groupHeight: CGFloat = 130
        static let itemVerticalMargin: CGFloat = 8
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

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var dataSource: UICollectionViewDiffableDataSource<Int, WhiteboardCellModel>?
    private let viewModel: WhiteboardListViewModel
    private var cancellables = Set<AnyCancellable>()

    private var whiteboardCellModels: [WhiteboardCellModel] = [
        WhiteboardCellModel(
            id: UUID(),
            title: "쪼이의 보드",
            icons: [
                ProfileIcon
                    .profileIcons[0],
                ProfileIcon
                    .profileIcons[1]
            ]
        ),
        WhiteboardCellModel(
            id: UUID(),
            title: "다우니의 보드",
            icons: [
                ProfileIcon
                    .profileIcons[0],
                ProfileIcon
                    .profileIcons[1],
                ProfileIcon
                    .profileIcons[2]
            ]
        ),
        WhiteboardCellModel(
            id: UUID(),
            title: "딴의 보드",
            icons: [
                ProfileIcon
                    .profileIcons[2]
            ]
        ),
        WhiteboardCellModel(
            id: UUID(),
            title: "딩동의 보드",
            icons: [
                ProfileIcon
                    .profileIcons[0],
                ProfileIcon
                    .profileIcons[1],
                ProfileIcon
                    .profileIcons[2]
            ]
        )
    ]

    public init(viewModel: WhiteboardListViewModel) {
        self.viewModel = viewModel
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

    private func configureAttribute() {
        view.backgroundColor = .systemBackground

        let createWhiteboardAction = UIAction { [weak self] _ in
            self?.viewModel.action(input: .createWhiteboard)
        }
        createWhiteboardButton.addAction(createWhiteboardAction, for: .touchUpInside)

        configureCollectionView()
        configureDataSource()
        applySnapshot()
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
            .trailing(equalTo: configureProfileButton.leadingAnchor, inset: 29)

        collectionView
            .addToSuperview(view)
            .top(equalTo: mainTitleLabel.bottomAnchor, inset: .zero)
            .horizontalEdges(equalTo: view)
            .bottom(equalTo: view.bottomAnchor, inset: .zero)
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.register(WhiteboardCell.self, forCellWithReuseIdentifier: WhiteboardCell.reuseIdentifier)
    }

    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.5))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(
            top: WhiteboardListLayoutConstant.itemVerticalMargin,
            leading: .zero,
            bottom: WhiteboardListLayoutConstant.itemVerticalMargin,
            trailing: .zero)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(WhiteboardListLayoutConstant.groupHeight))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: .zero,
            leading: horizontalMargin,
            bottom: .zero,
            trailing: horizontalMargin)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, WhiteboardCellModel>(
            collectionView: collectionView,
            cellProvider: {
                [weak self] collectionView, indexPath, board in
                return self?.configureCell(
                    collectionView: collectionView,
                    indexPath: indexPath,
                    board: board)})
    }

    private func configureCell(collectionView: UICollectionView, indexPath: IndexPath, board: WhiteboardCellModel) -> UICollectionViewCell? {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WhiteboardCell.reuseIdentifier,
                for: indexPath) as? WhiteboardCell
        else { return nil }
        cell.configure(with: board)
        return cell
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, WhiteboardCellModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(whiteboardCellModels, toSection: 0)
        guard let dataSource = dataSource else { return }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func bind() {
        viewModel.output.whiteboardPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // TODO: 화이트보드 추가
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDelegate
extension WhiteboardListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = whiteboardCellModels[indexPath.row]
        // TODO: - Whiteboard Cell 선택 시 입장 처리
    }
}
