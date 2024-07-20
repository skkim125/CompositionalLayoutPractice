//
//  ViewController.swift
//  CompositionalLayoutPractice
//
//  Created by 김상규 on 7/18/24.
//

import UIKit
import SnapKit

enum Setting: String, CaseIterable {
    case all = "전체 설정"
    case personal = "개인 설정"
    case etc = "기타"
    
    var details: [Detail] {
        switch self {
        case .all:
            [Detail(name: "공지사항"), Detail(name: "실험실"), Detail(name: "버전 정보")]
        case .personal:
            [Detail(name: "개인/보안"), Detail(name: "알림"), Detail(name: "채팅"), Detail(name: "멀티프로필")]
        case .etc:
            [Detail(name: "고객센터/도움말")]
        }
    }
}

struct Detail: Hashable, Identifiable {
    var id = UUID()
    var name: String
}

class SettingViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: setLayout())
        
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Setting, Detail>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureHierarchy()
        configureLayout()
        
        setDataSource()
        updateSnapshot()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "설정"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    private func setLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        configuration.showsSeparators = true
        configuration.backgroundColor = .black
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
    
    private func setDataSource() {
        var registration: UICollectionView.CellRegistration<UICollectionViewListCell, Detail>!
        
        registration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            
            content.text = "\(itemIdentifier.name)"
            content.textProperties.color = .lightGray
            content.textProperties.font = .boldSystemFont(ofSize: 16)
            
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .black
            
            cell.backgroundConfiguration = backgroundConfig
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Setting, Detail>()
        snapshot.appendSections(Setting.allCases)
        snapshot.appendItems(Setting.all.details, toSection: Setting.all)
        snapshot.appendItems(Setting.personal.details, toSection: Setting.personal)
        snapshot.appendItems(Setting.etc.details, toSection: Setting.etc)
        
        dataSource.apply(snapshot)
    }
}

