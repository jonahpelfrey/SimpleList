//
//  SimpleListExample.swift
//  SimpleList
//
//  Created by Jonah Pelfrey on 11/1/19.
//  Copyright © 2019 Jonah Pelfrey. All rights reserved.
//

import UIKit
import Combine

/* Example Data */
struct ExampleData: Hashable {
    let color: UIColor
    let id = UUID()
}

/* Example Cell */
class ExampleListCell: CompatibleCell {
    
    static var reuseIdentifier: String = "example_reuse_identifier"
    static var height: CGFloat = 300
    static var spacing: CGFloat = 10
    static var contentInsets: NSDirectionalEdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        return label
    }()
    
    lazy var button: DeleteButton = {
        let button = DeleteButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitle("Remove", for: .normal)
        return button
    }()

    func setData(_ data: ExampleData, _ indexPath: IndexPath) {
        valueLabel.text = data.color.toString()
        button.setTitleColor(data.color, for: .normal)
        button.tag = data.id.hashValue
        backgroundColor = data.color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        contentView.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = 8
    }
}

/* Example View Model */
class ExampleListViewModel {
    var subject = CurrentValueSubject<[ExampleData], Never>([])
    
    var data: [ExampleData] = [
        ExampleData(color: .systemRed),
        ExampleData(color: .systemOrange),
        ExampleData(color: .systemYellow),
        ExampleData(color: .systemGreen),
        ExampleData(color: .systemBlue),
        ExampleData(color: .systemPurple),
        ExampleData(color: .systemPink)
    ]
    
    init() {
        subject.send(data)
    }
    
    func removeItem(withIdentifier id: Int) {
        data = data.filter { $0.id.hashValue != id }
        subject.send(data)
    }
}

/* Example Controller */
class ExampleListController: SimpleListController<ExampleListCell> {
    
    var subscription: AnyCancellable?
    var viewModel = ExampleListViewModel()
    
    override func setup() {
        super.setup()
        
        configureDataSource { [weak self] (cell, indexPath) in
            cell.button.addTarget(self, action: #selector(self?.removeCellTapped(_:)), for: .touchUpInside)
        }
        
        configureSubscription()
    }
    
    private func configureSubscription() {
        subscription = viewModel.subject
        .receive(on: RunLoop.main)
        .sink(receiveValue: { [weak self] values in
            self?.updateDataSource(values)
        })
    }
    
    @objc func removeCellTapped(_ sender: UIButton) {
        viewModel.removeItem(withIdentifier: sender.tag)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Did select item at: \(indexPath.row)")
    }
}
