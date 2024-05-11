//
//  FormSwitchTableViewCell.swift
//  ezSafe
//
//  Created by Tam Nguyen on 14/02/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import Combine

public class EMFormSwitchTableViewCell: UITableViewCell {

    var viewModel: EMFormSwitchCellViewModelProtocol?

    private var bindingSubscriptions = Set<AnyCancellable>()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 2
        return titleLabel
    }()

    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(switcherValueDidChange(switcher:)), for: .valueChanged)

        return switcher
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        unbindViewModel()
    }

    private func setupViews() {
        accessoryType = .none
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(switcher)

        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(equalTo: switcher.leadingAnchor, constant: 10.0),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        switcher.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @objc private func switcherValueDidChange(switcher: UISwitch) {
        viewModel?.viewState.value = switcher.isOn
    }
}

extension EMFormSwitchTableViewCell: EMFormTableCellBindableProtocol {
    public func unbindViewModel() {
        bindingSubscriptions.removeAll()
        viewModel = nil
    }
    
    public func bindViewModel(viewModel: Any) {
        guard let viewModel = viewModel as? EMFormSwitchCellViewModelProtocol else {
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

        viewModel.viewState.$titleFont.sink { [weak self] value in
            self?.titleLabel.font = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$titleTextColor.sink { [weak self] value in
            self?.titleLabel.textColor = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$value.sink { [weak self] value in
            guard let self, self.switcher.isOn != value else { return }
            self.switcher.setOn(value, animated: true)
        }.store(in: &bindingSubscriptions)
    }
}

#endif
