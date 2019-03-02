//
//  ViewController.swift
//  Project-5
//
//  Created by henry on 28/02/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: add new answer word
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        //TODO: start new game
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(startNewGame))
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
            if let startWords = try? String(contentsOf: startWordURL){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty{
            allWords = ["henry"]
        }
        startGame()
    }
    
    func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    //
    @objc func promptForAnswer(){
        let alert = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
            alert.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] action in
            guard let answer = alert?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        alert.addAction(submitAction)
        present(alert, animated: true)
    }
    //
    @objc func startNewGame(){
        startGame()
    }
    //MARK: Check user's input and insert a new row
    func submit(_ answer: String){
        let lowerAnswer = answer.lowercased()
        //TODO: check error message
        if showErrorMessage(lowerAnswer) {
            usedWords.insert(lowerAnswer, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func isPossible(word: String) -> Bool{
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            }else{
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool{
        return !usedWords.contains(word)
    }
    //MARK: Check whether identical with start word
    func isTitle(word: String) -> Bool{
        guard let checkTitle = title else { return false }
        return (word == checkTitle) ? false : true
    }
    
    func isReal(word: String) -> Bool{
        //TODO: check whether user's input is shorter than 3 letters
        if word.utf16.count < 3 {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    //MARK: Check user's input error
    func showErrorMessage(_ answer : String) -> Bool{
        let lowerAnswer = answer.lowercased()
        
        let errorTitle : String
        let errorMessage : String
        
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    if isTitle(word: lowerAnswer){
                        return true
                    } else {
                        errorTitle = "The start word!"
                        errorMessage = "This word is the start word"
                    }
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "This word is not real"
                }
            } else {
                errorTitle = "Word is used already"
                errorMessage = "Be more original!"
            }
        } else {
            guard let title = title?.lowercased() else { return false}
            errorTitle = "Word not possible"
            errorMessage = "Yot cannot make that word from  \"\(title)\""
        }
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        return false
    }
}

