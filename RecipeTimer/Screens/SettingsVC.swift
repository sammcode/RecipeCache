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

//Declares the protocol for SettingsVC and conforms it to class
protocol SettingsVCDelegate: class {
    func updateData()
}

class SettingsVC: QuickTableViewController {

    //Declares the delegate that allows other viewcontrollers to communicate with SettingsVC
    weak var delegate: SettingsVCDelegate!

    //Called when the done button is tapped
    @objc func doneButtonTapped() {
        //Calls the delegate function to update the data in the HomeVC viewcontroller
        delegate.updateData()
        //Dismisses the VC
        self.dismiss(animated: true)
    }

    //Saves the current settings to UserDefaults before the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaultsService.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    //Configures general properties of the viewcontroller
    func configure(){
        //Declares the done button to be added to the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        //Sets the title for the viewcontroller to "Settings"
        title = "Settings"
        //Configures the contents of the QuickTableViewController
        configureTableContents()
    }

    //Configures the contents (settings) of the QuickTableViewController
    func configureTableContents(){
        tableContents = [
            //Declares a section for the In-App Timer
            Section(title: "In-App Timer", rows: [
                //Declares a switch row that toggles whether or not the timer starts automatically
                SwitchRow(text: "Timer Starts Automatically", switchValue: Settings.timerStartsAutomatically, action:  updateInAppTimer()),
            ], footer: "To start and pause the timer, double-tap on the Recipe step card."),

            //Declares a radio section for the Timer Delay
            RadioSection(title: "Timer Delay", options: [
                //Delcares an option row for all of the supported lengths of time (in seconds)
                OptionRow(text: "0s", isSelected: (Settings.timerDelay == 0), action: updateTimerDelay(value: 0)),
                OptionRow(text: "5s", isSelected: (Settings.timerDelay == 5), action: updateTimerDelay(value: 5)),
                OptionRow(text: "15s", isSelected: (Settings.timerDelay == 15), action: updateTimerDelay(value: 15)),
                OptionRow(text: "30s", isSelected: (Settings.timerDelay == 30), action: updateTimerDelay(value: 30)),
                OptionRow(text: "60s", isSelected: (Settings.timerDelay == 60), action: updateTimerDelay(value: 60)),
            ], footer: "Choose the delay you would like before the timer in the next step begins. Only applicable if timer is set to start automatically."),

            //Declares a radio section for the Organization of Recipes
            RadioSection(title: "Organize Recipes", options: [
                //Declares an option row for each supported method of organization
                OptionRow(text: "Alpabetically", isSelected: (Settings.organizeRecipes == "alphabetically"), action: updateOrganizeRecipes(value: "alphabetically")),
                OptionRow(text: "Most Recently Created", isSelected: (Settings.organizeRecipes == "mostRecent"), action: updateOrganizeRecipes(value: "mostRecent")),
            ]),

            //Declares a section for Developer resources/contact
            Section(title: "Developer", rows: [
                //Declares a tap action row for both the developer twitter and website
                TapActionRow(text: "Developer Twitter", action: openDevTwitter()),
                TapActionRow(text: "Developer Website", action: openDevWebsite()),
            ])
        ]
    }

    //Opens the developer website in a SFSafariViewController
    private func openDevWebsite() -> (Row) -> Void  {
        return { [weak self] row in
            guard let url = URL(string: "https://sammcgarry.dev") else {
                return
            }
            let safariVC = SFSafariViewController(url: url)
            self!.present(safariVC, animated: true)
        }
    }

    //Opens the developer twitter page in a SFSafariViewController
    private func openDevTwitter() -> (Row) -> Void {
        return { [weak self] row in
            guard let url = URL(string: "https://twitter.com/sammcode") else {
                return
            }
            let safariVC = SFSafariViewController(url: url)
            self!.present(safariVC, animated: true)
        }
    }

    //Toggles the value for timerStartsAutomatically in the Settings struct
    private func updateInAppTimer() -> (Row) -> Void {
        return { row in
            Settings.timerStartsAutomatically = !Settings.timerStartsAutomatically
        }
    }

    //Takes an Int value as a paramter, updates the value for timerDelay in the Settings struct with the inputted value
    private func updateTimerDelay(value: Int) -> (Row) -> Void {
        return { row in
            Settings.timerDelay = value
        }
    }

    //Takes a String value as a paramter, updates the value for organizeRecipes in the Settings struct
    private func updateOrganizeRecipes(value: String) -> (Row) -> Void {
        return { row in
            Settings.organizeRecipes = value
        }
    }
}
