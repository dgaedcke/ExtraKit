 import UIKit

open class PickerInputView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate
{
	@objc var components = [[String]]()

	@objc weak var textField: UITextField?

	var selectedValues: [String?] {
		return (0..<components.count).map {
			selectedValue($0)
		}
	}
	
	@objc func selectedValue(_ component: Int = 0) -> String? {
		let selectedRow = self.selectedRow(inComponent: component)
		if selectedRow < 0 { return nil }
		return components[component][selectedRow]
	}

	open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return components[component][row]
	}
	
	open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return components[component].count
	}
	
	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return components.count
	}
	
	open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		textField?.text = selectedValues.compactMap{$0}.joined(separator: " ")
		NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
		textField?.sendActions(for: .editingChanged)
	}
}

public extension UITextField
{
	@objc var pickerView: PickerInputView? {
		return inputView as? PickerInputView
	}
	
	@objc @discardableResult func setPicker(components: [[String]]) -> PickerInputView {
		let pickerView = PickerInputView()
		pickerView.components = components
		pickerView.textField = self
		pickerView.dataSource = pickerView
		pickerView.delegate = pickerView
		inputView = pickerView
		
		return pickerView
	}
	
	@objc func select(row: Int, component: Int = 0, animated: Bool = false) {
		pickerView?.selectRow(row, inComponent: component, animated: true)
		text = pickerView?.components[component][row]
	}
	
	@objc func select(value: String, component: Int = 0, animated: Bool = false) {
		if let index = pickerView?.components[component].index(of: value) {
			pickerView?.selectRow(index, inComponent: component, animated: animated)
		}
		text = value
	}
}
