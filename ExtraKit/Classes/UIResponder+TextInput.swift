import ObjectiveC
import UIKit

private let prevAssociatedValueKey = "com.rickb.extrakit.UIResponder.previousTextInputResponder"
private let nextAssociatedValueKey = "com.rickb.extrakit.UIResponder.nextTextInputResponder"

public extension UIResponder {

	@IBOutlet weak var nextTextInputResponder: UIResponder? {
		get {
			return weakAssociatedValue(forKey: nextAssociatedValueKey)
		}
		set {
// don't know why I have to do this to avoid crashes when more than 2 textfields are hooked up
// started doing this when transitioned code to Swift
// just moved this line of code from the set function to here
//			set(weakAssociatedValue: newValue, forKey: nextAssociatedValueKey)
			associatedDictionary[nextAssociatedValueKey] = WeakObjectRef(newValue)

			if newValue?.previousTextInputResponder != self {
				newValue?.previousTextInputResponder = self
			}
			createPreviousNextDoneInputAccessory()
			updatePreviousNextSegmentControlState()
		}
	}
	
	@IBOutlet weak var previousTextInputResponder: UIResponder? {
		get {
			return weakAssociatedValue(forKey: prevAssociatedValueKey)
		}
		set {
//			set(weakAssociatedValue: newValue, forKey: prevAssociatedValueKey)
			associatedDictionary[prevAssociatedValueKey] = WeakObjectRef(newValue)

			if newValue?.nextTextInputResponder != self {
				newValue?.nextTextInputResponder = self
			}
			createPreviousNextDoneInputAccessory()
			updatePreviousNextSegmentControlState()
		}
	}

	@objc var previousNextSegmentControl: UISegmentedControl? {
		return previousNextDoneInputAccessory?.items?.first?.customView as? UISegmentedControl
	}
	
	@objc var previousNextDoneInputAccessory: UIToolbar? {
		guard self is UITextInputTraits  else { return nil }

		if let tf = self as? UITextField {
			return tf.inputAccessoryView as? UIToolbar
		} else if let tf = self as? UITextView {
			return tf.inputAccessoryView as? UIToolbar
		}else {
			return nil
		}
	}
	
	@objc func createPreviousNextDoneInputAccessory() {
		guard let tf = self as? UITextInputTraits , previousNextDoneInputAccessory == nil else { return }

		let segmentControl = UISegmentedControl(items: ["Prev".localized,"Next".localized])
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
	
	@objc func becomePreviousFirstResponder(_ sender: UIResponder) -> Bool {
		return becomeFirstResponder()
	}
	
	@objc func becomeNextFirstResponder(_ sender: UIResponder) -> Bool {
		return becomeFirstResponder()
	}
	
	@objc @discardableResult func becomePreviousInputResponder() -> Bool {
		return self.previousTextInputResponder?.becomePreviousFirstResponder(self) ?? false
	}
	
	@objc @discardableResult func becomeNextInputResponder() -> Bool {
		return self.nextTextInputResponder?.becomeNextFirstResponder(self) ?? false
	}

	@objc func prevNextResponder(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			becomePreviousInputResponder()
		} else {
			becomeNextInputResponder()
		}
	}
	
	@objc func updatePreviousNextSegmentControlState() {
		previousNextSegmentControl?.setEnabled(previousTextInputResponder != nil && previousTextInputResponder!.canBecomeFirstResponder, forSegmentAt: 0)
		previousNextSegmentControl?.setEnabled(nextTextInputResponder != nil && nextTextInputResponder!.canBecomeFirstResponder, forSegmentAt: 1)
	}
}
