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
        var userWords = [String]()
        var userDefinitions = [String]()
        
        userWords = UserDefaults.standard.value(forKey: Constants.userWordsID) as? [String] ?? []
        userDefinitions = UserDefaults.standard.value(forKey: Constants.userDefinitionsID) as? [String] ?? []
        
        userWords.append((wordTF.text ?? "").lowercased())
        userDefinitions.append((definitionTF.text ?? "").lowercased())
        
        UserDefaults.standard.removeObject(forKey: Constants.userWordsID)
        UserDefaults.standard.removeObject(forKey: Constants.userDefinitionsID)

        UserDefaults.standard.setValue(userWords, forKey: Constants.userWordsID)
        UserDefaults.standard.setValue(userDefinitions, forKey: Constants.userDefinitionsID)
        
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
