//
//  SettingsViewController.swift
//  DotDot
//
//  Created by Lily Sai on 4/20/21.
//

import UIKit

struct SettingCellModel {
    let title: String
    let handler: (() -> Void)
}

final class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    private var data = [[SettingCellModel]]()

    override func viewDidLoad() {
        print("settings view")
        
        super.viewDidLoad()
        configureModels()

        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func didTapAddButton() {
        let vc = NFCViewController()
        vc.title = "DotDot Sequence"
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func configureModels() {
        data.append([
            SettingCellModel(title: "Personal Information") { [weak self] in
                self?.didTapPersonalInfo()
            },
            
            SettingCellModel(title: "Medical Details") { [weak self] in
                self?.didTapMedicalDetails()
            }
        ])
        
        data.append([
            SettingCellModel(title: "DotDot Sequence") { [weak self] in
                self?.didTapAddButton()
            },
        ])
        
        data.append([
            SettingCellModel(title: "Privacy Policy") {},
            
            SettingCellModel(title: "Terms of Service") {}
        ])
        
        data.append([
            SettingCellModel(title: "Sign out") { [weak self] in
                self?.didTapSignOut()
            }
        ])
    }
    
    private func didTapPersonalInfo() {
        let vc = PersonalInformationViewController()
        vc.title = "Edit Personal Information"
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    private func didTapMedicalDetails() {
        let vc = MedicalDetailsViewController()
        vc.title = "Edit Medical Details"
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    private func didTapSignOut() {
        let actionSheet = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Sign Out",
                                            style: .destructive,
                                            handler: { _ in
                                                AuthManager.shared.signoutUser(completion: { success in
                                                    DispatchQueue.main.async {
                                                        if success {
                                                            // present sign in
                                                            let signinVC = SignInViewController()
                                                            signinVC.modalPresentationStyle = .fullScreen
                                                            self.present(signinVC, animated: false) {
                                                                self.navigationController?.popToRootViewController(animated: false)
                                                                self.tabBarController?.selectedIndex = 0
                                                            }
                                                        } else {
                                                            // error occurred
                                                            fatalError("Could not sign out user")
                                                        }
                                                    }
                                                })
                                            }))
        
        
        actionSheet.popoverPresentationController?.sourceView = tableView
        actionSheet.popoverPresentationController?.sourceRect = tableView.bounds
        
        present(actionSheet, animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // handle cell selection
        data[indexPath.section][indexPath.row].handler()
    }
}
