//
//  TravelTalkViewController.swift
//  CompositionalLayoutPractice
//
//  Created by 김상규 on 7/20/24.
//

import UIKit
import SnapKit

final class TravelTalkViewController: UIViewController {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: setCollectionViewLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, ChatRoom>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureHierarchy()
        configureLayout()
        configureView()
        
        setDataSource()
        setSnapShot()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Travel Talk"
    }
    
    private func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .white
    }
    
    private func setCollectionViewLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        layout.configuration.scrollDirection = .vertical
        
        return layout
    }
    
    private func setSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChatRoom>()
        let list = mockChatList.map({ $0.chatroomId })
        snapshot.appendSections(list)
        for i in 0...mockChatList.count-1 {
            let list = mockChatList[i]
            snapshot.appendItems(mockChatList, toSection: list.chatroomId)
        }
        
        dataSource.apply(snapshot)
    }
    
    private func setDataSource() {
        var registration: UICollectionView.CellRegistration<UICollectionViewListCell, ChatRoom>!
        
        registration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.subtitleCell() // vertical direction of text & secondaryText
            
            guard let lastChat = itemIdentifier.chats.last else { return }
            let date = Date.convertDate(date: lastChat.date)
            
            content.text = itemIdentifier.chatroomName
            content.textProperties.color = .black
            content.textProperties.font = .boldSystemFont(ofSize: 16)
            content.textProperties.alignment = .justified
            
            let text = lastChat.message + " " + date
            let result = NSMutableAttributedString(string: text)
            let range = (text as NSString).range(of: date)
            result.addAttribute(.foregroundColor, value: UIColor.darkGray, range: range)
            result.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: range)
            
            content.secondaryAttributedText = result
            content.secondaryTextProperties.font = .systemFont(ofSize: 14)
            content.textToSecondaryTextVerticalPadding = 10
            
            content.image = UIImage(named: itemIdentifier.chatroomImage.last ?? "")
            content.imageProperties.reservedLayoutSize = CGSize(width: 25, height: 25)
            content.imageToTextPadding = 20
            
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .white
            
            cell.backgroundConfiguration = backgroundConfig
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
    }
}


extension Date {
    static func convertDate(date: String) -> String {
        let dateStr = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let convertDate = dateFormatter.date(from: dateStr)
        
        let timeDateFormatter = DateFormatter()
        timeDateFormatter.dateFormat = "yy.MM.dd"
        timeDateFormatter.locale = Locale(identifier: "ko_KR")
        
        return timeDateFormatter.string(from: convertDate!)
        
    }
}
