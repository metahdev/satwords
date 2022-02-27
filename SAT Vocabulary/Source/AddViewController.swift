//
//  AddViewController.swift
//  SAT Vocabulary
//
//  Created by Askar Almukhamet on 27.02.2022.
//

import UIKit

class AddViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet private weak var wordTF: UITextField!
    @IBOutlet private weak var definitionTF: UITextField!
    @IBOutlet private weak var doneButton: UIButton!
    

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        wordTF.delegate = self
        definitionTF.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wordTF.resignFirstResponder()
        definitionTF.resignFirstResponder()
    }
    
    
    // MARK: - Actions
    @IBAction private func editedWord(_ sender: Any) {
        toggleDoneButton()
    }
    
    @IBAction private func editedDefinition(_ sender: Any) {
        toggleDoneButton()
    }
    
    
    @IBAction private func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func doneIsPressed(_ sender: Any) {
        Storage.words.append((wordTF.text ?? "").lowercased())
        Storage.definitions.append((definitionTF.text ?? "").lowercased())
        
        self.closeView(self)
    }
    
    
    // MARK: - Events
    private func toggleDoneButton() {
        doneButton.isEnabled = !(wordTF.text?.isEmpty ?? true) && !(definitionTF.text?.isEmpty ?? true)
    }
}


extension AddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toggleDoneButton()
        textField.resignFirstResponder()
        return true
    }
}
