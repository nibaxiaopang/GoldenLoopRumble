//
//  SettingVC.swift
//  GoldenLoopRumble
//
//  Created by jin fu on 2024/12/21.
//


import UIKit

class GoldenSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func feedback(_ sender: Any) {
        // Create a UIAlertController with a preferred style of .actionSheet
        let alert = UIAlertController(title: "Feedback", message: "What's your feedback?", preferredStyle: .actionSheet)

        // Define feedback options and their corresponding actions
        let feedbackOptions: [(String, String)] = [
            ("👍 Excellent", "Thank you for your excellent feedback!"),
            ("👏 Well Done", "Thanks for the positive feedback!"),
            ("🤔 Suggestion", "We appreciate your suggestion!"),
            ("👎 Needs Improvement", "We'll work on improving. Thanks for letting us know!")
        ]

        // Add actions for each feedback option
        for (option, message) in feedbackOptions {
            let action = UIAlertAction(title: option, style: .default) { _ in
                self.showFeedbackAlert(message: message)
            }
            alert.addAction(action)
        }

        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        // Present the action sheet
        present(alert, animated: true, completion: nil)
    }

    // Function to display the feedback alert with a custom message
    func showFeedbackAlert(message: String) {
        let feedbackAlert = UIAlertController(title: "Feedback", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        feedbackAlert.addAction(okAction)
        present(feedbackAlert, animated: true, completion: nil)
    }

}
