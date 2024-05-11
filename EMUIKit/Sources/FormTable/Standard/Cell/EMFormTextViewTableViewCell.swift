//
//  FormTextContentTableViewCell.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 08/05/2021.
//  Copyright © 2021 Logi. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import Combine

public protocol EMFormTextViewTableViewCellDelegate: AnyObject {
    func formTextViewTableViewCellNeedRefreshLayout(cell: EMFormTextViewTableViewCell)
}

extension EMFormTextViewTableViewCellDelegate {
    func formTextViewTableViewCellNeedRefreshLayout(cell: EMFormTextViewTableViewCell) {}
}

public class EMFormTextViewTableViewCell: UITableViewCell {

    private(set) var viewModel: EMFormTextViewCellViewModelProtocol?

    weak var delegate: EMFormTextViewTableViewCellDelegate?

    var titleLabel: UILabel!
    var contentTextView: EMUtilityTextView!

    var isEditable = false {
        didSet {
            contentTextView.isEditable = isEditable
            contentTextView.enableToolbar = isEditable
        }
    }

    private var currentTextViewSize = CGSize.zero

    private var bindingSubscriptions = Set<AnyCancellable>()

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

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Save currentTextViewSize for the first time after added to superview
        currentTextViewSize = contentTextView.sizeThatFits(CGSize(width: contentTextView.frame.width, height: 0))
    }

    // MARK: Private

    private func setupView() {
        accessoryType = .none
        selectionStyle = .none

        titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)

        contentTextView = EMUtilityTextView(frame: .zero)
        contentTextView.isEditable = isEditable
        contentTextView.dataDetectorTypes = [.all]
        contentTextView.textAlignment = .left
        contentTextView.isSelectable = true
        contentTextView.isScrollEnabled = false
        contentTextView.enableToolbar = isEditable
        contentView.addSubview(contentTextView)
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

        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12.0),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12.0),
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.0),
            contentTextView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationTextDidChanged(notification:)), name: UITextView.textDidChangeNotification, object: nil)
    }

    // MARK: Events

    @objc func notificationTextDidChanged(notification: Notification?) {
        guard let textView = notification?.object as? UITextView, textView === contentTextView else {
            return
        }

        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: 0))

        if Int(currentTextViewSize.height) != Int(size.height) {
            currentTextViewSize = size
            delegate?.formTextViewTableViewCellNeedRefreshLayout(cell: self)
        }

        // Should notify text changed here, or update viewModel
        viewModel?.viewState.content = contentTextView.text
    }
}

extension EMFormTextViewTableViewCell: EMFormTableCellBindableProtocol {
    public func unbindViewModel() {
        bindingSubscriptions.removeAll()
        viewModel = nil
    }

    public func bindViewModel(viewModel: Any) {
        guard let viewModel = viewModel as? EMFormTextViewCellViewModelProtocol else {
            assert(false, "Unsupport viewModel type")
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
            self?.contentTextView.font = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$textColor.sink { [weak self] value in
            self?.contentTextView.textColor = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$doneButtonTitle.sink { [weak self] value in
            self?.contentTextView.doneBarItem?.title = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$content.sink { [weak self] content in
            guard let self = self, self.contentTextView.text != content else {
                return
            }

            self.contentTextView.text = content
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$contentInputPlaceholder.sink { [weak self] placeholder in
            self?.contentTextView.placeholder = placeholder
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$isEditable.sink { [weak self] isEditable in
            self?.isEditable = isEditable
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.becomeFirstResponder.sink { [weak self] in
            self?.contentTextView.becomeFirstResponder()
        }.store(in: &bindingSubscriptions)
    }
}

#endif
