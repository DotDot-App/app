//
//  SignInViewController.swift
//  DotDot
//
//  Created by Lily Sai on 4/20/21.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    struct Constants {
        static let cornerRadius: CGFloat = 8.0
        static let buttonHeight: CGFloat = 52
    }
    
    private let usernameEmailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username or email"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let signinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign in", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    private let createUserButton: UIButton = {
        let button = UIButton()
        button.setTitle("New user? Create an account", for: .normal)
        button.setTitleColor(.label, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signinButton.addTarget(self,
                               action: #selector(didTapSigninButton),
                               for: .touchUpInside)
        
        createUserButton.addTarget(self,
                               action: #selector(didTapCreateUserButton),
                               for: .touchUpInside)
        
        usernameEmailField.delegate = self
        passwordField.delegate = self
        
        addSubviews()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // assign frames
        
        usernameEmailField.frame = CGRect(
            x: 20,
            y: view.height / 3.0,
            width: view.width - 40,
            height: Constants.buttonHeight
        )
        
        passwordField.frame = CGRect(
            x: 20,
            y: usernameEmailField.bottom + 10,
            width: view.width - 40,
            height: Constants.buttonHeight
        )
        
        signinButton.frame = CGRect(
            x: 20,
            y: passwordField.bottom + 10,
            width: view.width - 40,
            height: Constants.buttonHeight
        )
        
        createUserButton.frame = CGRect(
            x: 20,
            y: signinButton.bottom + 10,
            width: view.width - 40,
            height: Constants.buttonHeight
        )
    }
    
    private func addSubviews() {
        view.addSubview(usernameEmailField)
        view.addSubview(passwordField)
        view.addSubview(signinButton)
        view.addSubview(createUserButton)
    }

    @objc private func didTapSigninButton() {
        usernameEmailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let usernameEmail = usernameEmailField.text, !usernameEmail.isEmpty,
            let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
                return
        }
        
        var username: String?
        var email: String?
        
        if usernameEmail.contains("@"), usernameEmail.contains(".") {
            // email (very basic email check)
            email = usernameEmail
        } else {
            // username
            username = usernameEmail
        }
        
        // signin functionality
        AuthManager.shared.signinUser(username: username, email: email, password: password) { success in
            DispatchQueue.main.async {
                if success {
                    // user logged in
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // error occurred
                    let alert = UIAlertController(title: "Sign in error",
                                                  message: "We were unable to sign you in.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
    
    @objc private func didTapCreateUserButton() {
        let vc = CreateAccountViewController()
        vc.title = "Create Account"
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameEmailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapSigninButton()
        }
        
        return true
    }
}
