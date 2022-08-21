//
//  ViewController.swift
//  hackingwithswift2
//
//  Created by Aleksandr on 30.05.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0 {
        didSet {
            if score > highScore {
                highScore = score
                showNewHighScore()
                print("new hisc")
            }
        }
    }
    var highScore = 0 {
        didSet {
            save()
        }
    }
    var correctAnsewr = 0
    var round = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = UserDefaults.standard.data(forKey: "highScore") {
            do {
                highScore = try JSONDecoder().decode(Int.self, from: data)
            } catch {
                fatalError()
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showRownds))
        
        countries = ["estonia",
                     "france",
                     "germany",
                     "ireland",
                     "italy",
                     "monaco",
                     "nigeria",
                     "poland",
                     "spain",
                     "uk",
                     "us"]

        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestion()
    }
    
    @objc func showRownds() {
        let ac = UIAlertController(title: "Round number", message: "\(round)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }

    func save() {
        if let data = try? JSONEncoder().encode(highScore) {
            UserDefaults.standard.set(data, forKey: "highScore")
        }
        
    }

    func askQuestion() {
        round += 1
        correctAnsewr = Int.random(in: 0...2)
        countries.shuffle()
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "\(countries[correctAnsewr].uppercased()) Score: \(score)"
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.tag == correctAnsewr {
            score += 1
            title = "Correct"
        } else {
            score -= 1
            title = "Wrong, this is \(countries[sender.tag].uppercased())"
        }
        var ac = UIAlertController()
        if round == 10 {
            ac = UIAlertController(title: "This was final round", message: "Your final score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Start new game", style: .default) { _ in
                self.score = 0
                self.correctAnsewr = 0
                self.round = 0
                self.askQuestion()
            })
        } else {
            ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                self.askQuestion()
            })
        }
        present(ac, animated: true)
    }
    
    func showNewHighScore() {
        let ac = UIAlertController(title: "New high score!", message: "\(highScore)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default) {
            _ in
            self.askQuestion()
        })
        present(ac, animated: true)
    }
}

