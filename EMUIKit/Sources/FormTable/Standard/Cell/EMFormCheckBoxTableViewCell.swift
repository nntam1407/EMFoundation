//
//  FormCheckBoxTableViewCell.swift
//  ezSafe
//
//  Created by Tam Nguyen on 14/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import Combine
import SnapKit
import EMFoundation

public class EMFormCheckBoxTableViewCell: UITableViewCell {

    var viewModel: EMFormCheckBoxCellViewModelProtocol?

    private var bindingSubscriptions = Set<AnyCancellable>()

    private lazy var checkBoxImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.isHidden = true

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.isHidden = true


        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 4

        return stackView
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

        contentView.addSubview(contentStackView)
        contentView.addSubview(checkBoxImageView)

        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)
        ])

        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(10).priority(.high)
        }

        checkBoxImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.leading.equalTo(contentStackView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
}

extension EMFormCheckBoxTableViewCell: EMFormTableCellBindableProtocol {
    public func unbindViewModel() {
        bindingSubscriptions.removeAll()
        viewModel = nil
    }
    
    public func bindViewModel(viewModel: Any) {
        guard let viewModel = viewModel as? EMFormCheckBoxCellViewModelProtocol else {
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

        viewModel.viewState.$titleFont.sink { [weak self] value in
            self?.titleLabel.font = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$titleTextColor.sink { [weak self] value in
            self?.titleLabel.textColor = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$subtitleFont.sink { [weak self] value in
            self?.subtitleLabel.font = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$subtitleTextColor.sink { [weak self] value in
            self?.subtitleLabel.textColor = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$checkedIconTintColor.sink { [weak self] value in
            self?.checkBoxImageView.tintColor = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$checkedIconImage.sink { [weak self] value in
            self?.checkBoxImageView.image = value
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$subtitle.sink { [weak self] value in
            self?.subtitleLabel.text = value
            self?.subtitleLabel.isHidden = value.isNilOrEmpty
        }.store(in: &bindingSubscriptions)

        viewModel.viewState.$selected.sink { [weak self] selected in
            self?.checkBoxImageView.isHidden = !selected
        }.store(in: &bindingSubscriptions)
    }
}

#endif
