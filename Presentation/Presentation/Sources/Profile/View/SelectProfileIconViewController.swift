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

    private lazy var profileIconSpacing: CGFloat = {
        view.bounds.width / SelectProfileIconLayoutConstant.divider
    }()

    private lazy var profileIconSize: CGFloat = {
        (view.bounds.width - 2 * (horizontalMargin) - 2 * (profileIconSpacing)) / SelectProfileIconLayoutConstant.profileIconCountInRow
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: profileIconSize, height: profileIconSize)
        layout.minimumInteritemSpacing = SelectProfileIconLayoutConstant.divider
        layout.minimumLineSpacing = SelectProfileIconLayoutConstant.profileIconLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProfileIconCollectionViewCell.self, forCellWithReuseIdentifier: ProfileIconCollectionViewCell.reuseIdentifier)
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
    }

    private func configureLayout() {
        collectionView.addToSuperview(view)

        collectionView
            .horizontalEdges(equalTo: view, inset: horizontalMargin)
            .verticalEdges(equalTo: view, inset: SelectProfileIconLayoutConstant.profileIconVerticalMargin)
    }
}

// MARK: - UICollectionViewDataSource
extension SelectProfileIconViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileIcon.profileIcons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileIconCollectionViewCell.reuseIdentifier, for: indexPath) as? ProfileIconCollectionViewCell else {
            return UICollectionViewCell()
        }
        let profileIcon = ProfileIcon.profileIcons[indexPath.item]
        cell.configure(profileIcon: profileIcon, profileIconSize: profileIconSize)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectProfileIconViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProfileIcon = ProfileIcon.profileIcons[indexPath.item]
        let updatedProfile = Profile(nickname: viewModel.output.profile.value.nickname, profileIcon: selectedProfileIcon)
        viewModel.action(input: .updateProfile(profile: updatedProfile))
        dismiss(animated: true)
    }
}
