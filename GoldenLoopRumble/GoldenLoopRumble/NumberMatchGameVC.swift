//
//  NumberMatchGameVC.swift
//  GoldenLoopRumble
//
//  Created by jin fu on 2024/12/21.
//


import UIKit

class NumberMatchGameVC: UIViewController {

    @IBOutlet weak var gridView: UIView! // Grid container
    @IBOutlet weak var targetLabel: UILabel! // Displays target number
    @IBOutlet weak var scoreLabel: UILabel! // Displays score
    @IBOutlet weak var messageLabel: UILabel! // Displays messages (win/loss)

    @IBOutlet var gridButtons: [UIButton]! // IBOutlet collection for grid buttons

    let gridSize = 5 // 5x5 grid
    var targetNumber: Int = 0 // Target number to match
    var score = 0 // Player's score
    var remainingTime = 60 // Time limit in seconds
    var timer: Timer? // Timer for the game

    override func viewDidLoad() {
        super.viewDidLoad()
        generateNewGrid()
        generateTargetNumber()
        startTimer()
    }

    // Setup the number grid using IBOutlet collection
    private func generateNewGrid() {
        guard gridButtons.count == gridSize * gridSize else {
            print("Error: Grid buttons count does not match grid size.")
            return
        }

        var targetCount = 0
        for (index, button) in gridButtons.enumerated() {
            var number: Int
            if targetCount < gridSize { // Ensure at least `gridSize` target numbers are in the grid
                number = targetNumber
                targetCount += 1
            } else {
                repeat {
                    number = Int.random(in: 1...9)
                } while number == targetNumber
            }
            button.setTitle("\(number)", for: .normal)
            button.backgroundColor = .black
            button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            button.setTitleColor(.blue, for: .normal)
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
            button.isEnabled = true
            button.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
        }
    }

    // Generate a new target number
    private func generateTargetNumber() {
        targetNumber = Int.random(in: 1...9)
        targetLabel.text = "Target: \(targetNumber)"
        messageLabel.text = "Find all \(targetNumber)s!"
    }

    // Handle number button tap
    @objc private func numberTapped(_ sender: UIButton) {
        guard let numberText = sender.title(for: .normal), let number = Int(numberText) else { return }

        if number == targetNumber {
            sender.backgroundColor = .green
            sender.isEnabled = false // Disable button after correct match
            score += 10
            scoreLabel.text = "Score: \(score)"

            // Check if all target numbers are found
            if checkWinCondition() {
                messageLabel.text = "All \(targetNumber)s found!"
                generateNewGrid()
                generateTargetNumber()
            }
        } else {
            sender.backgroundColor = .red
            messageLabel.text = "Wrong number! Try again."
            score -= 5
            scoreLabel.text = "Score: \(score)"
        }
    }

    // Check if all target numbers are found
    private func checkWinCondition() -> Bool {
        for button in gridButtons {
            if let numberText = button.title(for: .normal), let number = Int(numberText), number == targetNumber {
                if button.isEnabled {
                    return false // If any target number button is still enabled, the game is not yet won
                }
            }
        }
        return true // All target numbers are found
    }

    // Start the game timer
    private func startTimer() {
        remainingTime = 60
        score = 0
        scoreLabel.text = "Score: \(score)"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func updateTimer() {
        remainingTime -= 1
        messageLabel.text = "Time Remaining: \(remainingTime)s"

        if remainingTime <= 0 {
            timer?.invalidate()
            showGameOverAlert()
        }
    }

    // Show game over alert
    private func showGameOverAlert() {
        let alert = UIAlertController(title: "Time's Up!", message: "Your final score is \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { [weak self] _ in
            self?.restartGame()
        }))
        present(alert, animated: true, completion: nil)
    }

    // Restart the game
    private func restartGame() {
        generateNewGrid()
        generateTargetNumber()
        startTimer()
    }
}