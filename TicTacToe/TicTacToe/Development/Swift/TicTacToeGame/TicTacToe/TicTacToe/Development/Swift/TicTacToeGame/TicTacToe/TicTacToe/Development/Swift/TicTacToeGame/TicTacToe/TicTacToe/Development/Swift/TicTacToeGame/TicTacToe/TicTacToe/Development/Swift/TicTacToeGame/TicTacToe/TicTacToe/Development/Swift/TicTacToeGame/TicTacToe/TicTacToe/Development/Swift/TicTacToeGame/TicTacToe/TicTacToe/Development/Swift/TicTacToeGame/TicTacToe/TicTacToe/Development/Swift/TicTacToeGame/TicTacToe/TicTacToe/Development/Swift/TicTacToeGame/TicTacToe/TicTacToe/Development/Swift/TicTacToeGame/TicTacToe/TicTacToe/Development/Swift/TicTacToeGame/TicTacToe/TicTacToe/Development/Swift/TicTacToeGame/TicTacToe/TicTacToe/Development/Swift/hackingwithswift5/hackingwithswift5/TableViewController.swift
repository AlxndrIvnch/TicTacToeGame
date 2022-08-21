//
//  ViewController.swift
//  hackingwithswift5
//
//  Created by Aleksandr on 02.06.2022.
//

import UIKit

class TableViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]() {
        didSet {
            saveAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if load(&allWords, key: "allWords") {
            if !load(&title, key: "title") || !load(&usedWords, key: "usedWords") {
                startGame()
            } else {
                tableView.reloadData()
            }
        } else {
            guard let url = Bundle.main.url(forResource: "start", withExtension: "txt") else { fatalError() }
            if let words = try? String(contentsOf: url) {
                allWords = words.components(separatedBy: "\n")
                startGame()
            }
        }
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))

    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll()
        usedWords.append(title!)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        var context = cell.defaultContentConfiguration()
        context.text = usedWords[indexPath.row]
        cell.contentConfiguration = context
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let action = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?.first?.text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        guard isPossible(word: lowerAnswer) else {
            let error = "Word is not possible"
            let errorMessage = "You can't spell that word from \(title!.lowercased())"
            showErrorMessage(errorMessage, in: error)
            return
        }
        
        guard isOriginal(word: lowerAnswer) else {
            let error = "Word used already"
            let errorMessage = "Be more original!"
            showErrorMessage(errorMessage, in: error)
            return
        }
        
        guard isReal(word: lowerAnswer) else {
            let error = "Word doesn't exist"
            let errorMessage = "You can't just make them up, you know!"
            showErrorMessage(errorMessage, in: error)
            return
        }
        usedWords.insert(lowerAnswer, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func showErrorMessage(_ errorMessage: String, in error: String) {
        let ac = UIAlertController(title: error, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word.lowercased())
    }
    
    func isReal(word: String) -> Bool {
        guard word.count >= 3 else { return false }
        let cheker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = cheker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en_EN")
        return misspelledRange.location == NSNotFound
    }
    
    func saveAll() {
        guard let title = title else { return }
        save(title, key: "title")
        save(usedWords, key: "usedWords")
        save(allWords, key: "allWords")
    }
    
    func save<T>(_ value: T, key: String) where T: Codable {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load<T>( _ value: inout T, key: String) -> Bool where T: Codable {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return false
            
        }
        do {
            value = try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError()
        }
        return true
    }
}

