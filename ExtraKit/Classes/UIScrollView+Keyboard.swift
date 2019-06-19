import UIKit

private let observerAssociatedValueKey = "com.rickb.extrakit.UIScrollView.KeyboardNotificationObserver"
private let revealViewAssociatedValueKey = "com.rickb.extrakit.UIScrollView.viewForKeyboardReveal"

public extension UIScrollView {
	@objc func adjustContentInsetForKeyboardFrame()
	{
		set(associatedValue: KeyboardNotificationObserver(scrollView: self), forKey: observerAssociatedValueKey)
	}
}

class KeyboardNotificationObserver: NSObject {
	@objc weak var scrollView: UIScrollView?
	var contentInset: UIEdgeInsets?
	
	@objc init(scrollView: UIScrollView) {
		super.init()

		self.scrollView = scrollView

		startObserving(UIResponder.keyboardWillChangeFrameNotification) { [weak self] note in
			if self?.contentInset == nil {
				self?.contentInset = scrollView.contentInset
			}
			scrollView.contentInset.bottom = self?.adjustedKeyboardFrameHeight(note) ?? 0
		}
		
		startObserving(UIResponder.keyboardWillHideNotification) { [weak self] note in
			if let contentInset = self?.contentInset {
				self?.scrollView?.contentInset = contentInset
				self?.contentInset = nil
			}
		}
	}
	
	@objc func adjustedKeyboardFrameHeight(_ note: Notification) -> CGFloat {
		guard let scrollView = scrollView, let keyboardFrame = note.keyboardFrameEnd else {
			return 0
		}
		
		var h = keyboardFrame.size.height
		if let responder = scrollView.findFirstResponder(), let revealView = responder.viewForKeyboardReveal {
			let responderY = scrollView.convert(responder.bounds, from: responder).maxY
			let revealY = scrollView.convert(revealView.bounds, from: revealView).maxY
			let dh = revealY - responderY
			if dh > 0 {
				h += dh
			}
		}
		let dh = UIScreen.main.bounds.size.height-scrollView.convert(scrollView.bounds, to: UIScreen.main.coordinateSpace).maxY
		if dh > 0 {
			h -= dh
		}
		if h < 0 {
			h = 0
		}
		return h
	}
}

public extension UIResponder {

	@IBOutlet public weak var viewForKeyboardReveal: UIView? {
		get {
			return weakAssociatedValue(forKey: observerAssociatedValueKey)
		}
		set {
			set(weakAssociatedValue: newValue, forKey: observerAssociatedValueKey)
		}
	}
}
