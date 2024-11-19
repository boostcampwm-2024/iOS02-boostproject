//
//  SelectProfileIconViewController.swift
//  Presentation
//
//  Created by 최정인 on 11/13/24.
//

import Domain
import UIKit

final class SelectProfileIconViewController: UIViewController {
    private enum SelectProfileIconLayoutConstant {
        static let divider: CGFloat = 16
        static let profileIconCountInRow: CGFloat = 3
        static let profileIconLineSpacing: CGFloat = 25
        static let profileIconVerticalMargin: CGFloat = 50
    }

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            ProfileIconCollectionViewCell.self,
            forCellWithReuseIdentifier: ProfileIconCollectionViewCell.reuseIdentifier)

        let profileIconSize = profileIconSize()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: profileIconSize, height: profileIconSize)
        layout.minimumInteritemSpacing = SelectProfileIconLayoutConstant.divider
        layout.minimumLineSpacing = SelectProfileIconLayoutConstant.profileIconLineSpacing
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    private func configureLayout() {
        collectionView
            .addToSuperview(view)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)
            .verticalEdges(equalTo: view, inset: SelectProfileIconLayoutConstant.profileIconVerticalMargin)
    }

    private func profileIconSize() -> CGFloat {
        let totalHorizontalMargin: CGFloat = 2 * (horizontalMargin)
        let profileIconSpacing: CGFloat = view.bounds.width / SelectProfileIconLayoutConstant.divider
        let totalSpacingMargin: CGFloat = 2 * profileIconSpacing
        let profileIconCountInRow = SelectProfileIconLayoutConstant.profileIconCountInRow
        let profileIconSize = (view.bounds.width - totalHorizontalMargin - totalSpacingMargin) / profileIconCountInRow
        return profileIconSize
    }
}

// MARK: - UICollectionViewDataSource
extension SelectProfileIconViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileIcon.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(
                withReuseIdentifier: ProfileIconCollectionViewCell.reuseIdentifier,
                for: indexPath) as? ProfileIconCollectionViewCell
        else { return UICollectionViewCell() }
        let profileIcon = ProfileIcon.allCases[indexPath.item]
        let profileIconSize = profileIconSize()
        cell.configure(profileIcon: profileIcon, profileIconSize: profileIconSize)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectProfileIconViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProfileIcon = ProfileIcon.allCases[indexPath.item]
        viewModel.action(input: .updateProfileIcon(profileIcon: selectedProfileIcon))
        dismiss(animated: true)
    }
}
