//
//  MainViewController.swift
//  SAT Vocabulary
//
//  Created by Askar Almukhamet on 27.02.2022.
//

import UIKit

enum State {
    case ask
    case wrong
}

class MainViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var wordAskLabel: UILabel!
    @IBOutlet weak var userInputTF: UITextField!
    @IBOutlet weak var wordRevealLabel: UILabel!
    @IBOutlet weak var definitionRevealLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var wordIV: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    var state: State = .ask
    var index = -1
    var word = ""
    var words: [String] = []
    var definitions: [String] = []
    var userWords: [String] = []
    var userDefinitions: [String] = []
    var memorizedWords: [String] = []
        
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        setupDelegates()
        setupTextField()
        setupAppearance()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveData()
        updateData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userInputTF.resignFirstResponder()
    }
    
    private func setupDelegates() {
        Service.delegate = self
        userInputTF.delegate = self
    }
    
    private func setupTextField() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupAppearance() {
        backgroundView.layer.shadowOffset = CGSize(width: 10, height: 10)
        backgroundView.layer.shadowRadius = 5
        backgroundView.layer.shadowOpacity = 0.3
        wordIV.layer.borderWidth = 1
        wordIV.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func retrieveData() {
        index = -1 
        self.words = Storage.words
        self.definitions = Storage.definitions
        
        let retrievedData = UserDefaults.standard.value(forKey: Constants.memorizedWordsID) as? [String]
        if let savedData = retrievedData {
            self.memorizedWords = savedData
            modificateArrays()
        }
        
        let fetchedUserWordsData = UserDefaults.standard.value(forKey: Constants.userWordsID) as? [String]
        if let userWordsData = fetchedUserWordsData {
            self.userWords += userWordsData
        }
        
        let fetchedUserDefinitionsData = UserDefaults.standard.value(forKey: Constants.userWordsID) as? [String]
        if let userDefinitionsData = fetchedUserDefinitionsData {
            self.userDefinitions += userDefinitionsData
        }
    }
    
    private func modificateArrays() {
        var i = 0
        for word in self.memorizedWords {
            if self.memorizedWords.contains(word) {
                self.words.remove(at: i)
                self.definitions.remove(at: i)
            }
            i += 1
        }
    }
    
    private func updateData() {
        index += 1
        word = words[index]
        wordAskLabel.text = word
        definitionRevealLabel.text = definitions[index]

        Service.getDefinitionAndSentence(of: word)
        Service.getImageURLString(of: word)
        
        userInputTF.text = ""
    }
    
    
    // MARK: - Actions
    @IBAction private func addAWord(_ sender: Any) {
        performSegue(withIdentifier: "showSegueID", sender: nil)
    }
    
    @IBAction private func nextWord(_ sender: Any) {
        if state == .ask {
            state = .wrong
            if Storage.definitions[index] == userInputTF.text {
                self.memorizedWords.append(word)
                UserDefaults.standard.removeObject(forKey: Constants.memorizedWordsID)
                UserDefaults.standard.set(self.memorizedWords, forKey: Constants.memorizedWordsID)
                self.updateData()
            } else {
                if userWords.contains(word) {
                    let i = userWords.firstIndex(of: word)
                    userWords.remove(at: i!)
                    userDefinitions.remove(at: i!)
                    UserDefaults.standard.removeObject(forKey: Constants.memorizedWordsID)
                    UserDefaults.standard.set(self.memorizedWords, forKey: Constants.memorizedWordsID)
                }
                toggleState(hide: true)
            }
        } else {
            toggleState(hide: false)
            updateData()
            state = .ask
        }
        userInputTF.resignFirstResponder()
    }
    
    
    // MARK: - Events
    private func toggleState(hide: Bool) {
        wordAskLabel.isHidden = hide
        backgroundView.isHidden = hide
        userInputTF.isHidden = hide
        wordRevealLabel.isHidden = !hide
        definitionRevealLabel.isHidden = !hide
        exampleLabel.isHidden = !hide
        wordIV.isHidden = !hide
    }
    
    
    // MARK: - Notifications
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 2
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}


extension MainViewController: ServiceDelegate {
    func definitionAndSentenceLoaded(definition: String, example: String) {
        DispatchQueue.main.async() { [weak self] in
            self?.wordRevealLabel.text = definition
            self?.exampleLabel.text = example
        }
    }
    
    func linkLoaded(link: String) {
        wordIV.download(from: link)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userInputTF.resignFirstResponder()
        return true
    }
}
