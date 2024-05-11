//
//  FormTextFieldTableViewCell.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 26/06/2021.
//  Copyright © 2021 Logi. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation
import Combine

public class EMFormTextFieldTableViewCell: UITableViewCell {

    private(set) var viewModel: EMFormTextFieldCellViewModelProtocol?

    var titleLabel: UILabel!
    var contentTextField: EMUtilityTextField!

    private var bindingSubscriptions = Set<AnyCancellable>()

    var isEditable = false {
        didSet {
            contentTextField.isEnabled = isEditable
            contentTextField.enableToolbar = isEditable
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
        setupConstraints()
        registerObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        unbindViewModel()
    }

    // MARK: Private

    private func setupView() {
        accessoryType = .none
        selectionStyle = .none

        titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)

        contentTextField = EMUtilityTextField(frame: .zero)
        contentTextField.isEnabled = isEditable
        contentTextField.textAlignment = .left
        contentTextField.enableToolbar = isEditable
        contentView.addSubview(contentTextField)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0)
        ])
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        contentTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            contentTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            contentTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.0),
            contentTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationTextDidChanged(notification:)), name: UITextField.textDidChangeNotification, object: nil)
    }

    // MARK: Events

    @objc func notificationTextDidChanged(notification: Notification?) {
        guard let textField = notification?.object as? UITextField, textField === contentTextField else {
            return
        }

        // Should notify text changed here, or update viewModel
        viewModel?.viewState.content = contentTextField.text
    }
}

extension EMFormTextFieldTableViewCell: EMFormTableCellBindableProtocol {
    public func unbindViewModel() {
        bindingSubscriptions.removeAll()
        viewModel = nil
    }
    
    public func bindViewModel(viewModel: Any) {
        guard let viewModel = viewModel as? EMFormTextFieldCellViewModelProtocol else {
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

        viewModel.viewState.$textFont.sink { [weak self] value in
            self?.contentTextField.font = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$textColor.sink { [weak self] value in
            self?.contentTextField.textColor = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$doneButtonTitle.sink { [weak self] value in
            self?.contentTextField.doneBarItem?.title = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$content.sink { [weak self] content in
            guard let self = self, self.contentTextField.text != content else {
                return
            }

            self.contentTextField.text = content
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$contentInputPlaceholder.sink { [weak self] placeholder in
            self?.contentTextField.placeholder = placeholder
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$isEditable.sink { [weak self] isEditable in
            self?.isEditable = isEditable
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$keyboardType.sink { [weak self] keyboardType in
            self?.contentTextField.keyboardType = keyboardType
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$autocapitalizationType.sink { [weak self] type in
            self?.contentTextField.autocapitalizationType = type
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$isSecureTextEntry.sink { [weak self] secured in
            self?.contentTextField.isSecureTextEntry = secured
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.becomeFirstResponder.sink { [weak self] in
            self?.contentTextField.becomeFirstResponder()
        }.store(in: &bindingSubscriptions)
    }
}

#endif
