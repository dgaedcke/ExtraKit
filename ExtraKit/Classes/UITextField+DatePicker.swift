import UIKit

open class DatePickerInputView: UIDatePicker
{
	@objc weak var textField: UITextField?
	@objc var dateFormatter: DateFormatter!
	@objc var dateString: String {
		return dateFormatter.string(from: date)
	}
	
	@objc func dateChanged() {
		textField?.text = dateString
		NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
		textField?.sendActions(for: .editingChanged)
	}
	
	@objc func setDate(text: String?) {
		if let text = text, let textDate = dateFormatter.date(from: text) {
			date = textDate
			textField?.text = text
		}
	}
}

public extension UITextField
{
	@objc var datePickerView: DatePickerInputView? {
		return inputView as? DatePickerInputView
	}
	
	@objc @discardableResult func set(datePickerMode mode:UIDatePicker.Mode, dateFormatter: DateFormatter) -> DatePickerInputView {

		let picker = DatePickerInputView()
		picker.dateFormatter = dateFormatter
		picker.datePickerMode = mode
		picker.textField = self
		if let text = text , !text.isEmpty {
			picker.date = dateFormatter.date(from: text) ?? Date()
		}
		picker.addTarget(picker, action: #selector(DatePickerInputView.dateChanged), for: .valueChanged)
		inputView = picker
		return picker
	}
	
	@objc var datePickerDate: Date? {
		get {
			return (text == datePickerView?.dateString) ? datePickerView?.date : nil
		}
		set {
			if let date = newValue {
				datePickerView?.date = date
				text = datePickerView?.dateString
			}else {
				text = nil
			}
		}
	}
}
