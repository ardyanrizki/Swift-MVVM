//
//  LoginViewController.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 01/11/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private let viewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.isUserTokenStored() {
            presentHomeVC(animated: false)
        }
        setupUI()
        setupBinders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.email.value = nil
        viewModel.error.value = nil
    }
    
    private func setupUI() {
        errorLabel.isHidden = true
        
        passwordTextField.isSecureTextEntry = true
        
        loginButton.isEnabled = true
        loginButton.tintColor = .white
        loginButton.backgroundColor = .black
        loginButton.layer.cornerRadius = 8
    }
    
    private func setupBinders() {
        viewModel.error.bind { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.setupLoadingState(false)
                    self?.setupErrorLabel(text: error)
                }
            }
        }
        
        viewModel.email.bind { [weak self] email in
            if email != nil {
                DispatchQueue.main.async {
                    self?.setupLoadingState(false)
                    self?.presentHomeVC()
                }
            }
        }
    }
    
    private func setupErrorLabel(text: String?) {
        self.errorLabel.isHidden = text != nil ? false : true
        self.errorLabel.text = text
    }
    
    private func setupLoadingState(_ isLoading: Bool) {
        loginButton.setTitle(isLoading ? "Loading..." : "Sign In", for: .normal)
        
        loginButton.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
    }
    
    @IBAction func loginButtonDidPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        setupErrorLabel(text: nil)
        setupLoadingState(true)
        let credential = UserCredential(email: email, password: password)
        viewModel.login(credential: credential)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func presentHomeVC(animated: Bool = true) {
        let vc = HomeViewController()
        vc.viewModel.email.value = viewModel.email.value
        navigationController?.pushViewController(vc, animated: animated)
    }

}
