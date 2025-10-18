import UIKit

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topMostViewController()
        }

        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topMostViewController()
        }

        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topMostViewController()
        }

        return self
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.ok", value: "OK", comment: ""), style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    func showConfirmationAlert(title: String, message: String, confirmTitle: String = NSLocalizedString("alert.confirm", value: "Confirm", comment: ""), cancelTitle: String = NSLocalizedString("alert.cancel", value: "Cancel", comment: ""), onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
            onConfirm()
        })

        present(alert, animated: true)
    }

    func showTextInputAlert(title: String, message: String, placeholder: String = "", currentText: String = "", keyboardType: UIKeyboardType = .default, onConfirm: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = currentText
            textField.keyboardType = keyboardType
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", value: "Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.save", value: "Save", comment: ""), style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                onConfirm(text)
            }
        })

        present(alert, animated: true)
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}