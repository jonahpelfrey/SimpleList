//
//  SimpleList.swift
//  SimpleList
//
//  Created by Jonah Pelfrey on 11/1/19.
//  Copyright © 2019 Jonah Pelfrey. All rights reserved.
//

import UIKit
import Combine

/* Controller View */
class ControllerView: UIView {
    
    required public init(controller: UIViewController) {
        super.init(frame: .zero)
        
        controller.view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: controller.view.topAnchor),
            self.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor)
        ])
        
        configureSubviews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {}
}

/* Controller */
class Controller<View: ControllerView>: UIViewController {
    var childView: View!
    
    override func loadView() {
        super.loadView()
        self.childView = View(controller: self)
        setup()
    }
    
    func setup() {}
}

/* Simple List Cell Compatible */
public protocol SimpleListCellCompatible: class {
    associatedtype DataObjectType: Hashable
    func setData(_ data: DataObjectType, _ indexPath: IndexPath)
    
    static var reuseIdentifier: String { get }
    static var height: CGFloat { get }
    static var spacing: CGFloat { get }
    static var contentInsets: NSDirectionalEdgeInsets { get }
}

public typealias CompatibleCell = UICollectionViewCell & SimpleListCellCompatible

/* Simple List View */
class SimpleListView<Cell: CompatibleCell>: ControllerView {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
       
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let columns = 1
            let spacing = Cell.spacing
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(Cell.height))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Cell.spacing
            section.contentInsets = Cell.contentInsets

            return section
        }
        return layout
    }
       
    override func configureSubviews() {
        super.configureSubviews()
           
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
       
    override open func layoutSubviews() {
        if traitCollection.userInterfaceStyle == .light {
            backgroundColor = .secondarySystemBackground
        } else {
            backgroundColor = .systemBackground
        }
        
        super.layoutSubviews()
    }
}

class SimpleListController<Cell: CompatibleCell>: Controller<SimpleListView<Cell>>, UICollectionViewDelegate {
    
    public enum Section: CaseIterable {
        case main
    }
    
    public typealias CellPropertyConfigurator = (Cell, IndexPath) -> ()
    
    public var dataSource: UICollectionViewDiffableDataSource<Section, Cell.DataObjectType>!
    
    override func setup() {
        super.setup()
        configureDelegates()
    }
    
    private func configureDelegates() {
        childView.collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        childView.collectionView.delegate = self
    }
    
    public func configureDataSource(completion: CellPropertyConfigurator?) {
        dataSource = UICollectionViewDiffableDataSource<Section, Cell.DataObjectType>(collectionView: childView.collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
                fatalError("Cell type \(Cell.self) has not been registered")
            }
            
            cell.setData(item, indexPath)
            completion?(cell, indexPath)
            return cell
        })
    }
    
    public func updateDataSource(_ data: [Cell.DataObjectType]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Cell.DataObjectType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
