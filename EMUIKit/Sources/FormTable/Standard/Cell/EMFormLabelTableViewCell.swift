//
//  FormLabelTableViewCell.swift
//  ezSafe
//
//  Created by Tam Nguyen on 15/02/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import Combine
import SnapKit

public class EMFormLabelTableViewCell: UITableViewCell {

    private enum Constants {
        static let trailingInsetNormal = 20.0
        static let trailingInsetNextIconVisible = 6.0
    }

    var viewModel: EMFormLabelCellViewModelProtocol?

    private var bindingSubscriptions = Set<AnyCancellable>()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black

        return label
    }()

    public lazy var secondaryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.isHidden = true

        return label
    }()

    private lazy var trailingIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            secondaryLabel,
            trailingIconImageView
        ])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center

        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16).priority(.low)
        }
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        trailingIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16).priority(.low)
        }
        trailingIconImageView.setContentHuggingPriority(.required, for: .horizontal)
        trailingIconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        return stackView
    }()

    private var containerStackViewTrailingConstraint: Constraint?

    var iconImage: UIImage? {
        didSet {
            iconImageView.image = iconImage
            iconImageView.isHidden = iconImage == nil
        }
    }

    var trailingIconImage: UIImage? {
        didSet {
            trailingIconImageView.image = trailingIconImage
            trailingIconImageView.isHidden = trailingIconImage == nil
        }
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var secondaryText: String? {
        didSet {
            secondaryLabel.text = secondaryText
            secondaryLabel.isHidden = secondaryText.isNilOrEmpty
        }
    }

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
        contentView.addSubview(containerStackView)

        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)
        ])

        containerStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            containerStackViewTrailingConstraint = make.trailing.equalToSuperview().inset(Constants.trailingInsetNormal).constraint
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10).priority(.low)
        }
    }

    private func setShowNextIcon(show: Bool) {
        if show {
            accessoryType = .disclosureIndicator
            containerStackViewTrailingConstraint?.update(inset: Constants.trailingInsetNextIconVisible)
        } else {
            accessoryType = .none
            containerStackViewTrailingConstraint?.update(inset: Constants.trailingInsetNormal)
        }
    }
}

extension EMFormLabelTableViewCell: EMFormTableCellBindableProtocol {
    public func unbindViewModel() {
        bindingSubscriptions.removeAll()
        viewModel = nil
    }

    public func bindViewModel(viewModel: Any) {
        guard let viewModel = viewModel as? EMFormLabelCellViewModelProtocol else {
            assert(false, "Unsupported ViewModel")
            return
        }

        unbindViewModel()
        self.viewModel = viewModel

        viewModel.viewState.$backgroundColor
            .sink { [weak self] value in
                self?.backgroundColor = value
            }
            .store(in: &bindingSubscriptions)

        viewModel.viewState.$iconImage.sink { [weak self] image in
            self?.iconImage = image
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$titleTextColor.sink { [weak self] color in
            self?.titleLabel.textColor = color
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$titleAlignment.sink { [weak self] alignment in
            self?.titleLabel.textAlignment = alignment
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$titleFont.sink { [weak self] font in
            self?.titleLabel.font = font
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$secondaryText.sink { [weak self] text in
            self?.secondaryText = text
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$secondaryTextColor.sink { [weak self] color in
            self?.secondaryLabel.textColor = color
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$secondaryTextAlignment.sink { [weak self] alignment in
            self?.secondaryLabel.textAlignment = alignment
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$secondaryTextFont.sink { [weak self] font in
            self?.secondaryLabel.font = font
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$showNextIcon.sink { [weak self] show in
            self?.setShowNextIcon(show: show)
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$trailingIconImage.sink { [weak self] value in
            self?.trailingIconImage = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$selectionStyle.sink { [weak self] style in
            guard let self = self else { return }
            switch style {
            case .none:
                self.selectionStyle = .none
            case .gray:
                self.selectionStyle = .gray
            case .blue:
                self.selectionStyle = .blue
            }
        }.store(in: &bindingSubscriptions)
    }
}

#endif
