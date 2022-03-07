//
//  MainViewController.swift
//  SAT Vocabulary
//
//  Created by Askar Almukhamet on 27.02.2022.
//

import UIKit

enum State {
    case ask
    case answering
}

class MainViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var wordAskLabel: UILabel!
    @IBOutlet weak var userInputTF: UITextField!
    @IBOutlet weak var nameRevealLabel: UILabel!
    @IBOutlet weak var definitionRevealLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var wordIV: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var wordsCountLabel: UILabel!
    
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
        if !nextButton.isEnabled {
            nextButton.isEnabled = words.count != 0
        }
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
        backgroundView.layer.shadowOffset = .zero
        backgroundView.layer.shadowRadius = 10
        backgroundView.layer.shadowOpacity = 0.3
        backgroundView.layer.shadowPath = UIBezierPath(rect: backgroundView.bounds).cgPath
        wordIV.layer.shadowOffset = CGSize(width: 10, height: 10)
        wordIV.layer.shadowRadius = 2
        wordIV.layer.shadowOpacity = 0.3
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
            self.userWords = userWordsData
        }
        
        let fetchedUserDefinitionsData = UserDefaults.standard.value(forKey: Constants.userDefinitionsID) as? [String]
        if let userDefinitionsData = fetchedUserDefinitionsData {
            self.userDefinitions = userDefinitionsData
        }
        
        self.words += userWords
        self.definitions += userDefinitions
    }
    
    private func modificateArrays() {
        for word in self.memorizedWords {
            if self.memorizedWords.contains(word) {
                let i = self.words.firstIndex(of: word)
                if i != nil {
                    self.words.remove(at: i!)
                    self.definitions.remove(at: i!)
                }
            }
        }
    }
    
    private func updateData() {
        index += 1
        guard self.words.count != 0 else {
            wordAskLabel.text = "Finished all. Congrats!"
            nextButton.isEnabled = false 
            return
        }
        word = words[index]
        wordAskLabel.text = word
        nameRevealLabel.text = definitions[index]

        wordIV.image = nil
        definitionRevealLabel.text = "Placeholder"
        exampleLabel.text = "Placeholder"
        
        wordsCountLabel.text = "Words left: \(words.count)"
        
        Service.getDefinitionAndSentence(of: word)
        Service.getImageURLString(of: word)
    }
    
    
    // MARK: - Actions
    @IBAction private func addAWord(_ sender: Any) {
        performSegue(withIdentifier: "showSegueID", sender: nil)
    }
    
    @IBAction private func nextWord(_ sender: Any) {
        if state == .ask {
            if definitions[index] == userInputTF.text {
                if userWords.contains(word) {
                    let i = userWords.firstIndex(of: word)
                    userWords.remove(at: i!)
                    userDefinitions.remove(at: i!)
                    UserDefaults.standard.removeObject(forKey: Constants.userWordsID)
                    UserDefaults.standard.set(self.userWords, forKey: Constants.userWordsID)
                    UserDefaults.standard.removeObject(forKey: Constants.userDefinitionsID)
                    UserDefaults.standard.set(self.userDefinitions, forKey: Constants.userDefinitionsID)
                } else {
                    self.memorizedWords.append(word)
                    UserDefaults.standard.removeObject(forKey: Constants.memorizedWordsID)
                    UserDefaults.standard.set(self.memorizedWords, forKey: Constants.memorizedWordsID)
                }
                let ind = self.words.firstIndex(of: word)
                self.words.remove(at: ind!)
                self.definitions.remove(at: ind!)
                    
                if self.index != 0 {
                    self.index -= 1
                }
                
                if self.index != self.words.count {
                    self.index -= 1
                    updateData()
                } else {
                    wordAskLabel.text = "Finished all. Congrats!"
                    nextButton.isEnabled = false
                }
                toggleState(hide: false)
            } else {
                state = .answering
                toggleState(hide: true)
            }
        } else {
            state = .ask
            if self.index != self.words.count - 1 {
                updateData()
            } else {
                wordAskLabel.text = "Finished all. Congrats!"
                checkAmount()
            }
            toggleState(hide: false)
        }
        userInputTF.text = ""
        userInputTF.resignFirstResponder()
    }
    
    
    // MARK: - Events
    private func toggleState(hide: Bool) {
        wordAskLabel.isHidden = hide
        backgroundView.isHidden = hide
        userInputTF.isHidden = hide
        definitionRevealLabel.isHidden = !hide
        nameRevealLabel.isHidden = !hide
        exampleLabel.isHidden = !hide
        wordIV.isHidden = !hide
    }
    
    private func checkAmount() {
        nextButton.isEnabled = index + 1 != words.count
    }
    
    
    // MARK: - Notifications
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height * 1.5, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -(keyboardSize.height * 1.5), right: 0)
        }
    }
}


extension MainViewController: ServiceDelegate {
    func definitionAndSentenceLoaded(definition: String, example: String) {
        DispatchQueue.main.async() { [weak self] in
            self?.definitionRevealLabel.text = definition
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
