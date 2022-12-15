//
//  HomeViewController.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 01/11/22.
//

import UIKit
import SwiftUI
import PulseUI

class HomeViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var quoteStackView: UIStackView!
    @IBOutlet weak var inspectorButton: UIButton!
    
    let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinders()
        setupNavigationBar()
        setupInspectorButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quoteStackView.isHidden = true
        viewModel.checkStoredEmail()
        viewModel.getQuote()
    }
    
    @IBAction func inspectorTapped() {
        let vcPulse = UIHostingController(rootView: PulseUI.MainView())
        navigationController?.pushViewController(vcPulse, animated: true)
    }
    
    func setupBinders() {
        viewModel.email.bind { [weak self] email in
            if let email = email {
                DispatchQueue.main.async {
                    self?.emailLabel.text = email
                }
            }
        }
        
        viewModel.isSignedOut.bind { [weak self] bool in
            if bool {
                DispatchQueue.main.async {
                    self?.pushLoginVC()
                }
            }
        }
        
        viewModel.quote.bind { [weak self] quote in
            DispatchQueue.main.async {
                guard let quote = quote else {
                    self?.setQuoteStackView(hidden: true)
                    return
                }
                self?.quoteLabel.text = "\"\(quote.content ?? "")\""
                self?.authorLabel.text = quote.author
                self?.setQuoteStackView(hidden: false)
            }
        }
    }
    
    func pushLoginVC() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutDidPressed))
    }
    
    func setupInspectorButton() {
        #if DEBUG
        inspectorButton.isHidden = false
        inspectorButton.layer.cornerRadius = 8
        #else
        inspectorButton.isHidden = true
        #endif
    }
    
    @objc private func signOutDidPressed() {
        viewModel.signingOut()
    }
    
    private func setQuoteStackView(hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.quoteStackView.isHidden = hidden
        })
    }

}
