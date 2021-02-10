//
//  SettingsVC.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 8/5/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit
import QuickTableViewController
import SafariServices

protocol SettingsVCDelegate: class {
    func updateData()
}

class SettingsVC: QuickTableViewController {
    
    weak var delegate: SettingsVCDelegate!

    @objc func doneButtonTapped() {
        delegate.updateData()
        self.dismiss(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaultsService.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        title = "Settings"

      tableContents = [
        Section(title: "In-App Timer", rows: [
            SwitchRow(text: "Timer Starts Automatically", switchValue: Settings.timerStartsAutomatically, action:  updateInAppTimer()),
        ], footer: "To start and pause the timer, double-tap on the Recipe step card."),
        
        RadioSection(title: "Timer Delay", options: [
            OptionRow(text: "0s", isSelected: (Settings.timerDelay == 0), action: updateTimerDelay(value: 0)),
            OptionRow(text: "5s", isSelected: (Settings.timerDelay == 5), action: updateTimerDelay(value: 5)),
            OptionRow(text: "15s", isSelected: (Settings.timerDelay == 15), action: updateTimerDelay(value: 15)),
            OptionRow(text: "30s", isSelected: (Settings.timerDelay == 30), action: updateTimerDelay(value: 30)),
            OptionRow(text: "60s", isSelected: (Settings.timerDelay == 60), action: updateTimerDelay(value: 60)),
        ], footer: "Choose the delay you would like before the timer in the next step begins. Only applicable if timer is set to start automatically."),
        

        RadioSection(title: "Organize Recipes", options: [
            OptionRow(text: "Alpabetically", isSelected: (Settings.organizeRecipes == "alphabetically"), action: updateOrganizeRecipes(value: "alphabetically")),
            OptionRow(text: "Most Recently Created", isSelected: (Settings.organizeRecipes == "mostRecent"), action: updateOrganizeRecipes(value: "mostRecent")),
        ]),
        
        Section(title: "Developer", rows: [
          TapActionRow(text: "Developer Twitter", action: openDevTwitter()),
          TapActionRow(text: "Developer Website", action: openDevWebsite()),
        ])
      ]
    }

    private func showAlert(_ sender: Row) {}
    
    private func openDevWebsite() -> (Row) -> Void  {
        return { [weak self] row in
            guard let url = URL(string: "http://sammcgarry.dev") else {
                return
            }
            let safariVC = SFSafariViewController(url: url)
            self!.present(safariVC, animated: true)
        }
    }
    
    private func openDevTwitter() -> (Row) -> Void {
        return { [weak self] row in
            guard let url = URL(string: "https://twitter.com/sammcode") else {
                return
            }
            let safariVC = SFSafariViewController(url: url)
            self!.present(safariVC, animated: true)
        }
    }

    private func updateInAppTimer() -> (Row) -> Void {
        return { row in
            Settings.timerStartsAutomatically = !Settings.timerStartsAutomatically
        }
    }
    
    private func updateTimerDelay(value: Int) -> (Row) -> Void {
        return { row in
            Settings.timerDelay = value
        }
    }
    
    private func updateOrganizeRecipes(value: String) -> (Row) -> Void {
        return { row in
            Settings.organizeRecipes = value
        }
    }
    
    private func didToggleSelection() -> (Row) -> Void {
      return { row in }
    }
}
