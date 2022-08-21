//
//  ViewController.swift
//  UIKit_Learn
//
//  Created by Aleksandr on 01.05.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startButton: UIButton!
    
    var timer: Timer?
    var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        player = AVAudioPlayer()
        timeLable.text = ""
        datePicker.minimumDate = Date(timeIntervalSinceNow: 60)

    }

    @IBAction func startButtonAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "Start" {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: datePicker.date)
            
            guard let pickedDate = Calendar.current.date(from: components) else { return }

            if pickedDate >= Date() {
                startTimer(to: pickedDate)
                sender.setTitle("Stop", for: .normal)
            } else {
                datePicker.minimumDate = Date(timeIntervalSinceNow: 60)
                let alertController = UIAlertController(title: "Error", message: "Choose date that is not earlier than current date", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alertController, animated: true)
            }
        } else {
            stopTimer()
        }
    }
    
    func startTimer(to date: Date) {
        
        var timeInterval = DateInterval(start: Date(), end: date).duration

        if Int(timeInterval) == 0 {
            playSound()
            return
        }
        timeLable.text = String(Int(timeInterval))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            timeInterval -= 1
     
            if Int(timeInterval) == 0 {
                self?.stopTimer()
                self?.playSound()
            } else {
                self?.timeLable.text = String(Int(timeInterval))
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timeLable.text = ""
        startButton.setTitle("Start", for: .normal)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Glass", withExtension: "aiff") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Sound not found")
        }
        player.play()
    }
    
}
    
