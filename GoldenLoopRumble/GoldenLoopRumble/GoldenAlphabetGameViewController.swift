//
//  AlphabetGameVC.swift
//  GoldenLoopRumble
//
//  Created by jin fu on 2024/12/21.
//


import UIKit

class GoldenAlphabetGameViewController: UIViewController {

    @IBOutlet weak var gridView: UIView! // Grid container
    @IBOutlet weak var targetView: UIView! // Target selection view
    @IBOutlet weak var messageLabel: UILabel! // Displays messages (win/loss)
    @IBOutlet weak var timerLabel: UILabel!

    // IBOutlets for target panel buttons
    @IBOutlet weak var buttonW: UIButton!
    @IBOutlet weak var buttonF: UIButton!
    @IBOutlet weak var buttonH: UIButton!
    @IBOutlet weak var buttonS: UIButton!

    @IBOutlet var gridButtons: [UIButton]! // IBOutlet collection for grid buttons

    let gridSize = 6 // 6x6 grid
    var selectedColor: UIColor? // Color selected by user
    var targetMapping: [String: UIColor] = [
        "W": .blue,
        "F": .yellow,
        "H": .green,
        "S": .red
    ]

    var timer: Timer? // Timer for the game
    var remainingTime = 60 // Time limit in seconds

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargetPanel()
        setupGrid()
        startTimer()
    }

    // Setup the target panel for color selection using IBOutlets
    private func setupTargetPanel() {
        let targetButtons = [
            (buttonW, "W", UIColor.blue),
            (buttonF, "F", UIColor.yellow),
            (buttonH, "H", UIColor.green),
            (buttonS, "S", UIColor.red)
        ]

        targetButtons.forEach { (button, letter, color) in
            button?.setTitle(letter, for: .normal)
            button?.backgroundColor = color
            button?.setTitleColor(.black, for: .normal)
            button?.layer.cornerRadius = 8
            button?.layer.borderWidth = 1
            button?.layer.borderColor = UIColor.black.cgColor
            button?.addTarget(self, action: #selector(targetSelected(_:)), for: .touchUpInside)
        }
    }

    // Setup the grid using IBOutlet collection
    private func setupGrid() {
        guard gridButtons.count == gridSize * gridSize else {
            print("Error: Grid buttons count does not match grid size.")
            return
        }

        for (index, button) in gridButtons.enumerated() {
            let row = index / gridSize
            let col = index % gridSize
            let letter = cycleTargetLetter(row: row, col: col)
            button.setTitle(letter, for: .normal)
            button.backgroundColor = .white
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
            button.isEnabled = true
            button.addTarget(self, action: #selector(gridTapped(_:)), for: .touchUpInside)
        }
    }

    // Handle target color selection
    @objc private func targetSelected(_ sender: UIButton) {
        selectedColor = sender.backgroundColor
        messageLabel.text = "Selected: \(sender.title(for: .normal) ?? "")"
    }

    // Handle grid cell tap
    @objc private func gridTapped(_ sender: UIButton) {
        guard let selectedColor = selectedColor else {
            messageLabel.text = "Select a target first!"
            return
        }
        let letter = sender.title(for: .normal)
        if targetMapping[letter ?? ""] == selectedColor {
            sender.backgroundColor = selectedColor
            sender.isEnabled = false // Disable after filling
        } else {
            messageLabel.text = "Wrong color! Try again."
        }
        checkWinCondition()
    }

    // Check if all grid cells are filled correctly
    private func checkWinCondition() {
        for button in gridButtons {
            let letter = button.title(for: .normal)
            if button.backgroundColor != targetMapping[letter ?? ""] {
                return // If any button is incorrect, the game is not won yet
            }
        }
        messageLabel.text = "🎉 You Win! 🎉"
        timer?.invalidate() // Stop the timer
        showRestartAlert(win: true)
    }

    // Ensure all letters from the target mapping appear in the grid evenly
    private func cycleTargetLetter(row: Int, col: Int) -> String {
        let allKeys = Array(targetMapping.keys)
        let index = (row * gridSize + col) % allKeys.count
        return allKeys[index]
    }

    // Start the game timer
    private func startTimer() {
        remainingTime = 60
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func updateTimer() {
        remainingTime -= 1
        timerLabel.text = "Time Remaining: \(remainingTime)s"

        if remainingTime <= 0 {
            timer?.invalidate()
            timerLabel.text = "⏰ Time's Up! You Lose."
            showRestartAlert(win: false)
        }
    }

    // Show restart alert
    private func showRestartAlert(win: Bool) {
        let title = win ? "You Win!" : "Game Over"
        let message = win ? "Congratulations, you filled the grid correctly!" : "Time's up! Try again."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { [weak self] _ in
            self?.restartGame()
        }))
        present(alert, animated: true, completion: nil)
    }

    // Restart the game
    private func restartGame() {
        // Shuffle targetMapping colors
        let shuffledColors = targetMapping.values.shuffled()
        let shuffledKeys = Array(targetMapping.keys)
        for (index, key) in shuffledKeys.enumerated() {
            targetMapping[key] = shuffledColors[index]
        }

        // Reset grid and timer
        setupTargetPanel()
        setupGrid()
        startTimer()
        messageLabel.text = "Game Restarted!"
    }
}
