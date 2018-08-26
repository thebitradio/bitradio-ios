//
//  AddressCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class AddressCell : UIView {

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    var address: String? {
        return contentLabel.text
    }

    var didBeginEditing: (() -> Void)?
    var didReceivePaymentRequest: ((PaymentRequest) -> Void)?

    func setContent(_ content: String?) {
        contentLabel.text = content
        textField.text = content
    }

    var isEditable = false {
        didSet {
            gr.isEnabled = isEditable
        }
    }

    let textField = UITextField()
    let paste = ShadowButton(title: S.Send.pasteLabel, type: .primary)
    let scan = ShadowButton(title: S.Send.scanLabel, type: .primary)
	let qrImage = ShadowButton(title: S.QRImageReader.buttonLabel, type: .primary)

    fileprivate let contentLabel = UILabel(font: .customBody(size: 14.0), color: C.Colors.text)
    private let toLabel = UILabel(font: .customBody(size: 16.0))
    fileprivate let gr = UITapGestureRecognizer()
    fileprivate let tapView = UIView()
	fileprivate let underLineView = UIView()
    private let border = UIView(color: .clear)
    private var pasteWidthAnchor: NSLayoutConstraint?
    private var scanWidthAnchor: NSLayoutConstraint?
    
    func hideButtons() {
        pasteWidthAnchor?.isActive = true
        scanWidthAnchor?.isActive = true
        self.setNeedsLayout()
    }
    
    func showButtons() {
        pasteWidthAnchor?.isActive = false
        scanWidthAnchor?.isActive = false
        self.setNeedsLayout()
    }
    
    private func setupViews() {
        addSubviews()
        addConstraints()
        setInitialData()
    }

	override func didMoveToSuperview() {
		self.constrain([
			paste.widthAnchor.constraint(equalTo: scan.widthAnchor),
			scan.widthAnchor.constraint(equalTo: qrImage.widthAnchor),
			qrImage.widthAnchor.constraint(equalTo: paste.widthAnchor)
			])
	}

    private func addSubviews() {
        addSubview(toLabel)
        addSubview(contentLabel)
        addSubview(textField)
		addSubview(underLineView)
        addSubview(tapView)
        addSubview(border)
        addSubview(paste)
        addSubview(scan)
		addSubview(qrImage)
    }

    private func addConstraints() {
        toLabel.constrain([
            toLabel.constraint(.leading, toView: self, constant: 10.0),
            toLabel.constraint(.top, toView: self, constant: 10.0),
			toLabel.heightAnchor.constraint(equalToConstant: 20.0) ])
        contentLabel.constrain([
			contentLabel.constraint(.leading, toView: self, constant: 35.0),
			contentLabel.constraint(.trailing, toView: self, constant: -10.0),
			contentLabel.constraint(.top, toView: self, constant: 10.0),
			contentLabel.heightAnchor.constraint(equalToConstant: 20.0) ])
        textField.constrain([
			textField.constraint(.leading, toView: contentLabel),
			textField.constraint(.trailing, toView: contentLabel),
            textField.constraint(.top, toView: contentLabel),
            textField.constraint(.height, toView: contentLabel) ])
		underLineView.constrain([
			underLineView.constraint(.leading, toView: contentLabel),
			underLineView.constraint(.trailing, toView: contentLabel),
			underLineView.constraint(.bottom, toView: contentLabel, constant: 3.0),
			underLineView.heightAnchor.constraint(equalToConstant: 1.0) ])

        tapView.constrain([
            tapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tapView.topAnchor.constraint(equalTo: topAnchor),
            tapView.heightAnchor.constraint(equalToConstant: 45.0),
            tapView.trailingAnchor.constraint(equalTo: trailingAnchor) ])

		paste.constrain([
			paste.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[1]),
			paste.trailingAnchor.constraint(equalTo: scan.leadingAnchor, constant: -C.padding[1]),
			paste.constraint(.bottom, toView: self, constant: -C.padding[1])])

        scan.constrain([
			scan.trailingAnchor.constraint(equalTo: qrImage.leadingAnchor, constant: -C.padding[1]),
			scan.constraint(.bottom, toView: self, constant: -C.padding[1]) ])

		qrImage.constrain([
			qrImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[1]),
			qrImage.constraint(.bottom, toView: self, constant: -C.padding[1]) ])

        border.constrain([
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.bottomAnchor.constraint(equalTo: bottomAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1.0) ])

//		toLabel.textColor = UIColor.blue
//		contentLabel.textColor = UIColor.yellow
//		textField.backgroundColor = UIColor.red
//		contentLabel.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.4)
//		self.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
//		tapView.backgroundColor = UIColor(red: 1.0, green: 0.1, blue: 0.3, alpha: 0.2)
    }

    private func setInitialData() {
        backgroundColor = .clear
        toLabel.text = S.Send.toLabel
		toLabel.textColor = C.Colors.blueGrey

        textField.font = contentLabel.font
        textField.textColor = C.Colors.text
        textField.isHidden = true
        textField.returnKeyType = .done
        textField.delegate = self
        textField.clearButtonMode = .whileEditing

		underLineView.backgroundColor = C.Colors.lightGrey

        contentLabel.lineBreakMode = .byTruncatingMiddle

        textField.editingChanged = strongify(self) { myself in
            myself.contentLabel.text = myself.textField.text
        }

        //GR to start editing label
        gr.addTarget(self, action: #selector(didTap))
        tapView.addGestureRecognizer(gr)
    }

    @objc private func didTap() {
        textField.becomeFirstResponder()
        contentLabel.isHidden = true
        textField.isHidden = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddressCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing?()
        contentLabel.isHidden = true
        gr.isEnabled = false
        tapView.isUserInteractionEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        contentLabel.isHidden = false
        textField.isHidden = true
        gr.isEnabled = true
        tapView.isUserInteractionEnabled = true
        contentLabel.text = textField.text
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let request = PaymentRequest(string: string) {
            didReceivePaymentRequest?(request)
            return false
        } else {
            return true
        }
    }
}
