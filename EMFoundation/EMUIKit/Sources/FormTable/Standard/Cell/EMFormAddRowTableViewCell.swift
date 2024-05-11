//
//  FormAddRowTableViewCell.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 26/06/2021.
//  Copyright © 2021 Logi. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import Combine

class EMFormAddRowTableViewCell: UITableViewCell {

    var viewModel: EMFormAddRowCellViewModelProtocol?

    private var bindingSubscriptions = Set<AnyCancellable>()

    var titleLabel: UILabel!
    var iconImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        unbindViewModel()
    }

    // MARK: Private

    private func setupView() {
        accessoryType = .none

        titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)

        iconImageView = UIImageView(frame: .zero)
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)
        ])

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24.0),
            iconImageView.heightAnchor.constraint(equalToConstant: 24.0),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

extension EMFormAddRowTableViewCell: EMFormTableCellBindableProtocol {
    func unbindViewModel() {
        bindingSubscriptions.removeAll()
        viewModel = nil
    }
    
    func bindViewModel(viewModel: Any) {
        guard let viewModel = viewModel as? EMFormAddRowCellViewModelProtocol else {
            assert(false, "Unsupported viewModel")
            return
        }

        unbindViewModel()
        self.viewModel = viewModel

        viewModel.viewState.$backgroundColor
            .sink { [weak self] value in
                self?.backgroundColor = value
            }
            .store(in: &bindingSubscriptions)

        viewModel.viewState.$titleLabelFont.sink { [weak self] value in
            self?.titleLabel.font = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$titleTextColor.sink { [weak self] value in
            self?.titleLabel.textColor = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$iconImage.sink { [weak self] value in
            self?.iconImageView.image = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &bindingSubscriptions)
    }
}

#endif
