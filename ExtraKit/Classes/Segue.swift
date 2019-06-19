import UIKit

public extension UIStoryboardSegue {

	@objc @discardableResult func perform(action: Any?) -> Bool {
		guard let action = action as? SegueAction  else {
			return false
		}
		action.block(self)
		return true
	}
}

open class SegueAction {
	var block: (UIStoryboardSegue)->Void

	public init(_ block: @escaping (UIStoryboardSegue)->Void) {
		self.block = block
	}
}

public extension UIViewController {
	
	@objc class func swizzlePrepareForSegueAction() {
		swizzle(#selector(prepare(for:sender:)), newSelector: #selector(prepareForSegueAction(_:sender:)))
	}
	
	@objc func prepareForSegueAction(_ segue: UIStoryboardSegue, sender: AnyObject?) {
		prepareForSegueAction(segue, sender: sender)
		segue.perform(action: sender)
	}
}

public extension UIViewController {

	@IBAction func previousViewController(segue: UIStoryboardSegue) {
	}
}

class RootNavigationControllerSegue: UIStoryboardSegue {

	override func perform() {
		source.navigationController?.viewControllers = [destination]
	}
}

class ModalWithNavigationControllerSegue: UIStoryboardSegue {

	override func perform() {
		source.present(UINavigationController(rootViewController: destination), animated: true, completion: nil)
	}
}

class PushReplaceSegue : UIStoryboardSegue {

	override func perform() {
		if let nvc = source.navigationController {
			let n = nvc.viewControllers.count-1
			CATransaction.begin()
			nvc.pushViewController(destination, animated: true)
			CATransaction.setCompletionBlock {
				nvc.viewControllers.remove(at: n)
			}
			CATransaction.commit()
		}
	}
}
