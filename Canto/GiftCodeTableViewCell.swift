//
//  GiftCodeTableViewCell.swift
//  Canto
//
//  Created by Whotan on 2/21/19.
//  Copyright © 2019 WhoTan. All rights reserved.
//

import UIKit

protocol GiftCodeTVCellDelegate {
	func didTapApply(code: String)
}


class GiftCodeTableViewCell: UITableViewCell {
	@IBOutlet weak var textFieldBackground: UIView!
	
	@IBOutlet weak var applyButton: UIButton!
	
	@IBOutlet weak var errorLabel: UILabel!
	
	@IBOutlet weak var codeTextField: UITextField!
	@IBOutlet weak var warningImage: UIImageView!
	var delegate : GiftCodeTVCellDelegate!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func setup(){
		textFieldBackground.layer.cornerRadius = 10
		applyButton.layer.cornerRadius = 10
		codeTextField.attributedPlaceholder = NSAttributedString(string: "در این قسمت وارد کنید",
																   attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
		codeTextField.text = ""
		errorLabel.isHidden = true
		errorLabel.text = ""
		warningImage.isHidden = true
		codeTextField.addTarget(self, action: "textFieldDidChange:", for: UIControlEvents.editingChanged)
	}
	
	@objc func textFieldDidChange(_ textField: UITextField) {
		errorLabel.isHidden = true
		errorLabel.text = ""
		warningImage.isHidden = true
	}
	
	func resignResponder(){
		codeTextField.resignFirstResponder()
	}
	
	func setError(error: String){
		errorLabel.text = error
		warningImage.isHidden = false
		errorLabel.isHidden = false
		errorLabel.shake()
	}
	
	
	@IBAction func applyTapped(_ sender: Any) {
		if let code = codeTextField.text{
			if code.isEmpty{
				codeTextField.shake()
				setError(error: "لطفا کد هدیه را وارد کنید.")
				return
			}else{
				delegate.didTapApply(code: code)
			}
		}
	}
	
}
