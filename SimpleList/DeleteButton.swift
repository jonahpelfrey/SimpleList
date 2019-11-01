//
//  DeleteButton.swift
//  SimpleList
//
//  Created by Jonah Pelfrey on 11/1/19.
//  Copyright © 2019 Jonah Pelfrey. All rights reserved.
//

import UIKit

class DeleteButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 90, height: 30)
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.height/2
        super.layoutSubviews()
    }
}
