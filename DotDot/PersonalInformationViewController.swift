//
//  PersonalInformationViewController.swift
//  DotDot
//
//  Created by Lily Sai on 4/26/21.
//

import SwiftUI

struct PersonalEditFormModel {
    let label: String
    let placeholder: String
    var value: String?
}

final class PersonalInformationViewController: UIViewController, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(FormTableViewCell.self,
                           forCellReuseIdentifier: FormTableViewCell.identifier)
        
        return tableView
    }()
    
    private var models = [[PersonalEditFormModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureModels()

        tableView.tableHeaderView = createTableHeaderView()
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSave))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapCancel))
        
        view.backgroundColor = .systemBackground
    }
    
    private func configureModels() {
//        let section1Labels = ["First Name", "Last Name", "Phone #"]
//        var section1 = [PersonalEditFormModel]()
//        for label in section1Labels {
//            let model = PersonalEditFormModel(label: label, placeholder: "Enter \(label)", value: nil)
//            section1.append(model)
//        }
        
        var section1 = [PersonalEditFormModel]()
        section1.append(PersonalEditFormModel(label: "First Name", placeholder: "Enter First Name", value: "Lorem"))
        section1.append(PersonalEditFormModel(label: "Last Name", placeholder: "Enter Last Name", value: "Ipsum"))
        section1.append(PersonalEditFormModel(label: "Phone #", placeholder: "Enter Phone #", value: nil))
        models.append(section1)
        
        let section2Labels = ["Date of Birth", "Sex", "Blood Type", "Height", "Weight"]
        var section2 = [PersonalEditFormModel]()
        for label in section2Labels {
            let model = PersonalEditFormModel(label: label, placeholder: "Enter \(label)", value: nil)
            section2.append(model)
        }
        models.append(section2)
    }
    
    override func viewDidLayoutSubviews() {
        print("layout")
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    // MARK: - TableView
    
    private func createTableHeaderView() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height/5).integral)
        
        let size = header.height/1.5
        let profilePictureButton = UIButton(frame: CGRect(x: (view.width - size)/2, y: (header.height - size)/2, width: size, height: size))
        
        header.addSubview(profilePictureButton)
        profilePictureButton.layer.masksToBounds = true
        profilePictureButton.layer.cornerRadius = size/2.0
        profilePictureButton.tintColor = .label
        profilePictureButton.addTarget(self, action: #selector(didTapProfilePictureButton), for: .touchUpInside)
        
        profilePictureButton.setBackgroundImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        
        return header
    }
    
    @objc private func didTapProfilePictureButton() {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier, for: indexPath) as! FormTableViewCell
        cell.configure(with: model)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Basic Information"
        } else if section == 1 {
            return "Additional Details"
        }
        
        return nil
    }
    
    // MARK: - Action
    
    @objc private func didTapSave() {
        print("save")
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapChangeProfilePicture() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "Change profile picture",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        
        present(actionSheet, animated: true)
    }
}

extension PersonalInformationViewController: FormTableViewCellDelegate {
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: PersonalEditFormModel) {
        print(updatedModel.value ?? "nil")

    }
}
