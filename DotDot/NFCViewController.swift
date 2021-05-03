//
//  NFCViewController.swift
//  DotDot
//
//  Created by Lily Sai on 4/20/21.
//

import SwiftUI
import SafariServices
import UIKit
import CoreNFC

final class NFCViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    
    var session: NFCNDEFReaderSession?
    var url = ""
    
    struct Constants {
        static let cornerRadius: CGFloat = 8.0
        static let buttonHeight: CGFloat = 52
    }
    
    private let phoneNumberField: UITextField = {
        let field = UITextField()
        field.placeholder = "+0 (000) 000-0000"
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let messageField: UITextView = {
        let field = UITextView()
        field.frame = CGRect(x: 0, y: 0, width: 10, height: 0)
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let activateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Synchronize", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        view.addSubview(phoneNumberField)
        phoneNumberField.delegate = self
        
        view.addSubview(messageField)
        messageField.delegate = self
        messageField.text = "Message..."
        messageField.textColor = .lightGray
        
        view.addSubview(activateButton)
        activateButton.addTarget(self,
                               action: #selector(didTapActivateButton),
                               for: .touchUpInside)
        
        configureNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        phoneNumberField.frame = CGRect(
            x: 20,
            y: view.height / 3.0,
            width: view.width - 40,
            height: Constants.buttonHeight
        )
        
        messageField.frame = CGRect(
            x: 20,
            y: phoneNumberField.bottom + 10,
            width: view.width - 40,
            height: Constants.buttonHeight * 3
        )
        
        activateButton.frame = CGRect(
            x: 20,
            y: messageField.bottom + 10,
            width: view.width - 40,
            height: Constants.buttonHeight
        )
    }
    
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Preview",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapPreviewButton))

    }
    
    @objc private func didTapPreviewButton() {
        let vc = SFSafariViewController(url: URL(string: "https://lilys2001.github.io/smstest/")!)
        vc.modalPresentationStyle = .popover
        present(vc, animated: true)
    }
    
    @objc private func didTapActivateButton() {
        print("nfc")
        
        url = "https://lilys2001.github.io/smstest/" // URLTextField.text!
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Tap your DotDot device against your phone"
        session?.begin()
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        let str: String = url
        
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than one tag present. Please remove them and try again"
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        let tag = tags.first
        session.connect(to: tag as! NFCNDEFTag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag"
                session.invalidate()
                return
            }

            tag?.queryNDEFStatus(completionHandler: { (ndefstatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query NDEF status of tag"
                    session.invalidate()
                    return
                }

                switch ndefstatus {
                    case .notSupported:
                        session.alertMessage = "Tag is not NDEF compliant"
                        session.invalidate()
                    case .readOnly:
                        session.alertMessage = "Tag is locked (read only)"
                        session.invalidate()
                    case .readWrite:
                        tag?.writeNDEF(.init(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: str)!]), completionHandler: { (error: Error?) in
                            if nil != error {
                                session.alertMessage = "Write NDEF message error"
                            } else {
                                session.alertMessage = "This tag has been activated"
                                print("activated")
                            }
                            session.invalidate()
                        })
                    @unknown default:
                        session.alertMessage = "Unknown error occurred"
                        session.invalidate()
                }
            })
        })
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead) && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                DispatchQueue.main.async {
                    print("Session was unsuccessful")
                }
            }
        }
    }
}

extension NFCViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = format(with: "+X (XXX) XXX-XXXX", phone: newString)
        return false
    }
}

extension NFCViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Message..." && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }

    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Message..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
}
