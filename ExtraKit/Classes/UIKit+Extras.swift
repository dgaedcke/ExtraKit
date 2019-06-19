import UIKit

public extension UIAlertController {

	@objc class func alert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert) -> UIAlertController {
		return UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
	}
	
	@objc @discardableResult func ok(_ style: UIAlertAction.Style = .default, action inAction: (()->Void)? = nil) -> UIAlertController {
		return action(title: "OK".localized, style: style, action: inAction)
	}

	@objc @discardableResult func cancel(_ style: UIAlertAction.Style = .cancel, inAction: (()->Void)? = nil) -> UIAlertController {
		return action(title: "Cancel".localized, style: style, action: inAction)
	}
	
	@objc @discardableResult func action(title: String?, style: UIAlertAction.Style = .default, action: (()->Void)? = nil) -> UIAlertController {
		addAction(UIAlertAction(title: title, style: style) { _ in
			action?()
		})
		return self
	}
	
	@objc @discardableResult func show(_ viewController: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> UIAlertController {
		(viewController ?? UIApplication.visibleViewController())?.present(self, animated: animated, completion: completion)
			return self
	}
}

public extension UIApplication {

	@objc class func visibleViewController() -> UIViewController? {
		return shared.delegate?.window??.visibleViewController
	}
}

public extension UIWindow {

    @objc var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    @objc class func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

public extension Notification {

	var keyboardFrameEnd: CGRect?
	{
        if let info = (self as NSNotification).userInfo, let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return value.cgRectValue
        } else {
            return nil
        }
    }
}

public extension UIView {

	@objc func findFirstResponder() -> UIView? {

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
}

public extension UIView {

	@objc @discardableResult func add(to view: UIView) -> Self {
		view.addSubview(self)
		return self
	}

	@objc @discardableResult func addArranged(to view: UIStackView) -> Self {
		view.addArrangedSubview(self)
		return self
	}

	@objc @discardableResult func insertArranged(in view: UIStackView, at index: Int) -> Self {
		view.insertArrangedSubview(view, at: index)
		return self
	}
	
	@objc @discardableResult func insert(in view: UIView, below: UIView) -> Self {
		view.insertSubview(self, belowSubview: below)
		return self
	}

	@objc @discardableResult func insert(in view: UIView, above: UIView) -> Self {
		view.insertSubview(self, aboveSubview: above)
		return self
	}
	
	@objc @discardableResult func insert(in view: UIView, atIndex index: Int) -> Self {
		view.insertSubview(self, at: index)
		return self
	}
}

public extension UIFont {

	@objc class func printFontNames() {
		familyNames.forEach {
			fontNames(forFamilyName: $0).forEach {
				print($0)
			}
		}
	}
}

public extension UIViewController {

	@objc func dismissPresentedViewControllers() {
		presentedViewController?.dismiss(animated: false){
			self.dismissPresentedViewControllers()
		}
	}
}


public extension UIView {

	@objc func textFieldBecomeFirstResponder() -> Bool {
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

public extension UIViewController {

	func typedParentViewController<T>() -> T? {
		return self as? T ?? parent?.typedParentViewController()
	}
	
	func typedChildViewController<T>() -> T? {
		return children.first(where: { $0 is T }) as? T
	}
}

public extension UIView {

	func typedSuperview<T>() -> T? {
		return self as? T ?? superview?.typedSuperview()
	}

	func typedParentViewController<T>() -> T? {
		return self as? T ?? parentViewController?.typedParentViewController()
	}
	
	func typedSubview<T>() -> T? {
		return subviews.first(where: { $0 is T }) as? T
	}

    @objc var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

public extension UIViewController {
	
	@objc func withNavigationController(_ navbarHidden: Bool = false) -> UINavigationController {
		return UINavigationController(rootViewController: self).configure {
			$0.isNavigationBarHidden = navbarHidden
		}
	}
}
