//
//  UIResponder.swift
//  ExtraKit
//
//  Created by rickb on 4/18/16.
//  Copyright © 2018 rickbdotcom LLC. All rights reserved.
//

import ObjectiveC
import UIKit

public extension UIResponder {
	
	@IBInspectable var showPreviousNextDoneInputAccessory: Bool {
		get { return associatedValue() ?? true }
		set { set(associatedValue: newValue) }
	}
	
	@IBOutlet weak var nextTextInputResponder: UIResponder? {
		get {
			return weakAssociatedValue()
		}
		set {
// don't know why I have to do this to avoid crashes when more than 2 textfields are hooked up
// started doing this when transitioned code to Swift
// just moved this line of code from the set function to here
//			set(weakAssociatedValue: newValue)
			associatedDictionary[associatedKey()] = WeakObjectRef(newValue)

			if newValue?.previousTextInputResponder != self {
				newValue?.previousTextInputResponder = self
			}
			if showPreviousNextDoneInputAccessory {
				createPreviousNextDoneInputAccessory()
				updatePreviousNextSegmentControlState()
			}
		}
	}
	
	@IBOutlet weak var previousTextInputResponder: UIResponder? {
		get {
			return weakAssociatedValue()
		}
		set {
//			set(weakAssociatedValue: newValue)
			associatedDictionary[associatedKey()] = WeakObjectRef(newValue)

			if newValue?.nextTextInputResponder != self {
				newValue?.nextTextInputResponder = self
			}
			if showPreviousNextDoneInputAccessory {
				createPreviousNextDoneInputAccessory()
				updatePreviousNextSegmentControlState()
			}
		}
	}

	var previousNextSegmentControl: UISegmentedControl? {
		return previousNextDoneInputAccessory?.items?.first?.customView as? UISegmentedControl
	}
	
	var previousNextDoneInputAccessory: UIToolbar? {
		guard self is UITextInputTraits  else { return nil }

		if let tf = self as? UITextField {
			return tf.inputAccessoryView as? UIToolbar
		} else if let tf = self as? UITextView {
			return tf.inputAccessoryView as? UIToolbar
		}else {
			return nil
		}
	}
	
	func createPreviousNextDoneInputAccessory() {
		guard let tf = self as? UITextInputTraits , previousNextDoneInputAccessory == nil else { return }

		let segmentControl = UISegmentedControl(items: ["⌃","⌄"])
		segmentControl.setTitleTextAttributes([
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40)
		], for: .normal)
		segmentControl.setContentOffset(CGSize(width:0, height: 9), forSegmentAt: 0)
		segmentControl.setContentOffset(CGSize(width:0, height: -9), forSegmentAt: 1)

		segmentControl.setWidth(50, forSegmentAt: 0)
		segmentControl.setWidth(50, forSegmentAt: 1)

		segmentControl.sizeToFit()
		segmentControl.isMomentary = true
		segmentControl.addTarget(self, action: #selector(prevNextResponder(_:)), for: .valueChanged)
		
		let toolbar = UIToolbar()
		toolbar.barStyle = tf.keyboardAppearance  == .dark ? .black : .default
		toolbar.sizeToFit()
		
		toolbar.items = [
			UIBarButtonItem(customView: segmentControl)
		,	UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		,	UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
		]

		if let tf = self as? UITextField {
			tf.inputAccessoryView = toolbar
		} else if let tf = self as? UITextView {
			tf.inputAccessoryView = toolbar
		}
		updatePreviousNextSegmentControlState()
	}
	
	func becomePreviousFirstResponder(_ sender: UIResponder) -> Bool {
		return becomeFirstResponder()
	}
	
	func becomeNextFirstResponder(_ sender: UIResponder) -> Bool {
		return becomeFirstResponder()
	}
	
	@discardableResult func becomePreviousInputResponder() -> Bool {
		return self.previousTextInputResponder?.becomePreviousFirstResponder(self) ?? false
	}
	
	@discardableResult func becomeNextInputResponder() -> Bool {
		return self.nextTextInputResponder?.becomeNextFirstResponder(self) ?? false
	}

	@objc func prevNextResponder(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			becomePreviousInputResponder()
		} else {
			becomeNextInputResponder()
		}
	}
	
	func updatePreviousNextSegmentControlState() {
		previousNextSegmentControl?.setEnabled(previousTextInputResponder != nil && previousTextInputResponder!.canBecomeFirstResponder, forSegmentAt: 0)
		previousNextSegmentControl?.setEnabled(nextTextInputResponder != nil && nextTextInputResponder!.canBecomeFirstResponder, forSegmentAt: 1)
	}
}

public extension UITextField {

	@discardableResult func becomeNextInputResponderOnReturn() -> Any? {
		return on(.editingDidEndOnExit) { (textField: UITextField) in
			textField.becomeNextInputResponder()
		} 
	}
}

public extension UIView {

	func findFirstResponder() -> UIView? {

		if isFirstResponder {
			return self
		}
		for subview in subviews {
			if let responder = subview.findFirstResponder() {
				return responder
			}
		}
		return nil
	}

	func textFieldBecomeFirstResponder() -> Bool {
		if let tf = self as? UITextField {
			return tf.becomeFirstResponder()
		}
		for sv in subviews {
			if sv.textFieldBecomeFirstResponder() {
				return true
			}
		}
		return false
	}
}
