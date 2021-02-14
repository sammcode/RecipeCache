//
//  PlayRecipeVC.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 5/9/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

//Declares the protocol for PlayRecipeVC and conforms it to class
//Creates
protocol PlayRecipeVCDelegate : class {
    func startCountDown(time: String)
}

class PlayRecipeVC: UIViewController {
    
    //Declares local recipe variable to be assigned data
    var recipe: Recipe = Recipe(image: images.lasagna, title: "", ingredients: [Ingredient](), prepSteps: [PrepStep](), cookingSteps: [CookingStep](), id: "", dateCreated: "")
    
    //Declares array that stores the walkthrough card views
    var cardViewData: [WalkthroughCardView] = []
    
    //Declares optional string that stores a multiplier if the user sets one in the previous view
    var multiplier: String?
    
    //Declares the delegate that communicates with the walkthrough card views
    var delegate: WalkthroughCardViewDelegate!
    
    //Declares the card view contrainer that actually displays the walkthough views
    var cardView: SwipeableCardViewContainer = {
        let cardview = SwipeableCardViewContainer()
        cardview.translatesAutoresizingMaskIntoConstraints = false
        return cardview
    }()
    
    //Declares the view that will overlay the card view container and recognize taps
    private var tapView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    //Declares the button that transitions to the next card view
    private var nextButton: StyleButton = {
        let button = StyleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Declares the button that transitions to the previous card view
    private var prevButton: StyleButton = {
        let button = StyleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Previous", for: .normal)
        return button
    }()
    
    //Declares the stackview that holds the different progress views together
    var progressBar: UIStackView = {
        let progress = UIStackView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.axis = .horizontal
        progress.distribution = .fillEqually
        progress.spacing = 5
        return progress
    }()
    
    //Declares the progress view that represents the amount of ingredients in the recipe
    private var ingredientProgressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressViewStyle = .bar
        return progress
    }()
    
    //Declares the progress view that represents the amount of prep steps in the recipe
    private var prepstepProgressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressViewStyle = .bar
        return progress
    }()
    
    //Declares the progress view that represents the amount of cooking steps in the recipe
    private var cookingstepProgressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressViewStyle = .bar
        return progress
    }()
    
    //Declares the overlay that indicates when a user had paused/played a recipe
    private var playPauseView: PlayPauseIndicatorView = {
        let ppview = PlayPauseIndicatorView(image: UIImage(systemName: "playpause.fill")!)
        ppview.translatesAutoresizingMaskIntoConstraints = false
        ppview.layer.cornerRadius = 20
        return ppview
    }()
    
    //Declares the progress objects for ingredients, prep steps, and cooking steps
    var ingredientProgress = Progress()
    var prepstepProgress = Progress()
    var cookingstepProgress = Progress()
    
    //Declares the timer to be used for cooking steps
    weak var timer1: Timer!
    
    //Declares variables to be used in determining the current state of the view controller (e.g. which type of card view is being presented, whether or not a timer is active, etc.)
    private var current = 0
    private var ingredient = true
    private var prepstep = false
    private var cookingstep = false
    private var currentlyCounting = false
    private var progressCount = 0
    private var isPaused = !Settings.timerStartsAutomatically
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //Creates card views for the recipe's ingredients, prep steps, and cooking steps, and adds them to cardViewData array
    func fillCardViewData() {
        //Declare default amount of recipe steps
        var ingCount = 1
        var prepCount = 1
        var cookCount = 1
        //Iterate through ingredients in recipe
        for ing in recipe.ingredients {
            //Declare quantity variable
            let quantity: String!
            //Check if multiplier has a value, if so apply it to the ingredient's quantity
            if multiplier != nil {
                quantity = HelpfulFunctions.applyMultiplier(quantity: ing.qnty!, multiplier: multiplier!)
            }else{
                quantity = ing.qnty
            }
            //Create a card view for the ingredient and append it to the cardViewData array
            cardViewData.append(WalkthroughCardView(backview: "Ingredient \(ingCount)", title: ing.title, timer: quantity ?? "", notes: ing.notes ?? "", backviewColor: HelpfulFunctions.colorWithGradient(frame: view.bounds, colors: [UIColor(named: "ingredient")!, UIColor(named: "ingredient2")!]), backviewTitleColor: UIColor(named: "ingredient3")!, delegate: self))
            //Increment the number of ingredients by 1
            ingCount += 1
        }
        //Iterate through prep steps in recipe
        for prep in recipe.prepSteps {
            //Create a card view for the prep step and append it to the cardViewData array
            cardViewData.append(WalkthroughCardView(backview: "Prep Step \(prepCount)", title: prep.title, timer: "", notes: prep.notes ?? "", backviewColor: HelpfulFunctions.colorWithGradient(frame: view.bounds, colors: [UIColor(named: "prepstep")!, UIColor(named: "prepstep2")!]), backviewTitleColor: UIColor(named: "prepstep3")!, delegate: self))
            //Increment the number of cooking steps by 1
            prepCount += 1
        }
        //Iterate through cooking steps in recipe
        for cook in recipe.cookingSteps {
            //Create a card view for the cooking step and append it to the cardViewData array
            cardViewData.append(WalkthroughCardView(backview: "Cooking Step \(cookCount)", title: cook.title, timer: cook.timeUltimatum ?? "", notes: "", backviewColor: HelpfulFunctions.colorWithGradient(frame: view.bounds, colors: [UIColor(named: "cookingstep")!, UIColor(named: "cookingstep2")!]), backviewTitleColor: UIColor(named: "cookingstep3")!, delegate: self))
            //Increment the number of cooking steps by 1
            cookCount += 1
        }
    }
    
    //Calls functions that help set up the view, sets some basic properties
    func configure() {
        //Fills cardViewData array
        fillCardViewData()
        
        //Sets up the UI elements
        setUpElements()
        
        //Adds and action to the "Next" button
        addActionToButton()
        
        //Checks if the multiplier has a value, if so it incorporates it into the title
        if multiplier != nil {
            title = recipe.title + " x " + multiplier!
        }else{
            title = recipe.title
        }
        
        //Sets the background color for the view
        view.backgroundColor = .systemBackground
        
        //Sets the WalkthroughCardView delegate to self
        self.delegate = self
    }
    
    //Calls the functions that set up constraints for all the UI elements for the view
    func setUpElements(){
        setUpNextButtonConstraints()
        setUpCardViewConstraints()
        setUpProgressBarConstraints()
        setUpProgressBars()
        setUpProgressBarValue()
        setUpPlayPauseIndicatorViewConstraints()
        setUpTapViewConstraints()
    }
    
    //Sets up the constraints for the tap view
    func setUpTapViewConstraints() {
        //Adds it to the view as a subview
        view.addSubview(tapView)
        //Sets background color
        tapView.backgroundColor = UIColor.clear
        
        //Declares a constant that will represent the height of the view
        let height: CGFloat!
        
        //Sets the height constant based on the current device type
        if DeviceType.isiPadPro {
            height = ScreenSize.width * 0.8
        }else if DeviceType.isiPad11inch {
            height = ScreenSize.width * 0.8
        }else if DeviceType.isiPadAir {
            height = ScreenSize.width * 0.8
        }else if DeviceType.isiPad7thGen {
            height = ScreenSize.width * 0.8
        }else if DeviceType.isiPad {
            height = ScreenSize.width * 0.8
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            height = ScreenSize.width * 0.9
        }else {
            height = ScreenSize.width * 1.25
        }
        
        //Activates the constraints
        NSLayoutConstraint.activate([
            tapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tapView.widthAnchor.constraint(equalToConstant: ScreenSize.width),
            tapView.heightAnchor.constraint(equalToConstant: height)
        ])
        
        //Declares a tap gesture recognizer that triggers an action if the user taps on the view twice
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        tapView.addGestureRecognizer(tap)
    }
    
    //Sets up the constraints for the play/pause overlay
    func setUpPlayPauseIndicatorViewConstraints(){
        //Adds it to the view as a subview
        view.addSubview(playPauseView)
        //Activates the constraints
        NSLayoutConstraint.activate([
            playPauseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playPauseView.widthAnchor.constraint(equalToConstant: 160),
            playPauseView.heightAnchor.constraint(equalToConstant: 160)
        ])
        //Sets the isHidden property to true, this is toggled when the user double taps on the screen
        playPauseView.isHidden = true
    }
    
    //Sets up the constraints for the progress bar stack view
    func setUpProgressBarConstraints() {
        //Adds it to the view as a subview
        view.addSubview(progressBar)
        //Makes sure the recipe has ingredients, prep steps, or cooking steps before adding the corresponding progress bars to the stack view
        if recipe.ingredients.count != 0 { progressBar.addArrangedSubview(ingredientProgressBar) }
        if recipe.prepSteps.count != 0 { progressBar.addArrangedSubview(prepstepProgressBar) }
        if recipe.cookingSteps.count != 0 { progressBar.addArrangedSubview(cookingstepProgressBar) }
        
        //Declares a constant representing the offset from the bottom of the screen
        let constant: CGFloat!
        
        //Sets the constant based on the type of device
        if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            constant = ScreenSize.height * 0.22
        }else if DeviceType.isiPhoneSE {
            constant = ScreenSize.height * 0.16
        }else{
            constant = ScreenSize.height * 0.19
        }
        
        //Activates the constraints
        NSLayoutConstraint.activate([
            progressBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant),
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 20),
            progressBar.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.9)
        ])
    }
    
    //Sets up the total unit counts and tint colors for the progress bars
    func setUpProgressBars(){
        ingredientProgress = Progress(totalUnitCount: Int64(recipe.ingredients.count))
        prepstepProgress = Progress(totalUnitCount: Int64(recipe.prepSteps.count))
        cookingstepProgress = Progress(totalUnitCount: Int64(recipe.cookingSteps.count))
        
        ingredientProgressBar.tintColor = UIColor(named: "ingredient")
        prepstepProgressBar.tintColor = UIColor(named: "prepstep")
        cookingstepProgressBar.tintColor = UIColor(named: "cookingstep")
    }
    
    //Sets up the card view constraints
    func setUpCardViewConstraints(){
        //Adds it to the view as a subview
        view.addSubview(cardView)
        
        //Sets the datasource for the card view
        cardView.dataSource = self
        
        //Constrains the cardView to the center of the view
        cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    //Sets up the next button constraints
    func setUpNextButtonConstraints(){
        //Adds it to the view as a subview
        view.addSubview(nextButton)
        
        //Declares the constant that represents the height of the button, sets it based on the current device type
        let height: CGFloat = (DeviceType.isiPad || DeviceType.isiPad7thGen || DeviceType.isiPadAir || DeviceType.isiPad11inch || DeviceType.isiPadPro) ? ScreenSize.width * 0.1 : ScreenSize.width * 0.2
        
        //Declares the constant that represents the offset from the bottom of the screen
        let constant: CGFloat!
        
        //Sets the constant based on whether or not the current device is an iPhone SE 1st Gen
        if DeviceType.isiPhoneSE {
            constant = -view.bounds.width/16
        }else {
            constant = -view.bounds.width/15
        }
        
        //Activates the constraints
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant),
            nextButton.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.3),
            nextButton.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    //Sets up the constraints for the previous button
    func setUpPrevButtonConstraints(){
        //Adds it to the view as a subview
        view.addSubview(prevButton)
        
        //Declares the constant that represents the height of the button, sets it based on the current device type
        let height: CGFloat = (DeviceType.isiPad || DeviceType.isiPad7thGen || DeviceType.isiPadAir || DeviceType.isiPad11inch || DeviceType.isiPadPro) ? ScreenSize.width * 0.1 : ScreenSize.width * 0.2
        
        //Declares the constant that represents the offset from the bottom of the screen
        let constant: CGFloat!
        
        //Sets the constant based on whether or not the current device is an iPhone SE 1st Gen
        if DeviceType.isiPhoneSE {
            constant = -view.bounds.width/16
        }else {
            constant = -view.bounds.width/15
        }
        
        //Adds the action to the button that is triggered on a button tap
        addActiontoPrevButton()
        
        //Activates the constraints
        NSLayoutConstraint.activate([
            prevButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant),
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -constant),
            prevButton.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.3),
            prevButton.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    //Function that's called when the next button is tapped
    @objc func nextButtonTapped() {
        //Checks if a timer is currently active, if so it is deactivated
        if timer1 != nil { timer1.invalidate() }
        
        //Sets the currentlyCounting, which is representative of whether or not a timer is active, to false
        currentlyCounting = false
        
        //Checks if already on the last recipe step, if so it returns
        if progressCount == recipe.ingredients.count + recipe.prepSteps.count + recipe.cookingSteps.count - 1 {
            return
        }else if ingredient && current == 0{ //Checks if current step is an ingredient, and if it is the first step. If so it sets up the previous button as it can now be used to traverse backwards from the second step to the first step.
            setUpPrevButtonConstraints()
        }else if cookingstep && current == recipe.cookingSteps.count - 2 {//Checks if the next step is the last one, in which case the next button is removed as it is no longer needed.
            nextButton.removeFromSuperview()
        }
        
        //Animates the next button
        nextButton.pulsate()
        
        //Displays the next card view in the cardViewData array
        cardView.nextCard(onCard: cardViewData[progressCount])
        
        //Increments the overall progress through the recipes steps by 1
        progressCount += 1
        
        //Updates the current type of recipe step based on a direction (ingredient, prep step, or cooking step)
        checkStepStatus(direction: .forwards)
        
        //Updates the overall progress of the recipe walkthough, based on a direction
        updateProgress(direction: .forwards)
        
        //Checks if the current recipe step type is cooking step and if there is a timer set, if so it starts the count down
        if cookingstep && recipe.cookingSteps[current].timeUltimatum != nil && Settings.timerStartsAutomatically{
            delegate.startCountDown(card: cardViewData[progressCount])
        }
    }
    
    //Function thats called when the previous button is tapped
    @objc func prevButtonTapped() {
        //Checks if a timer is currently active, if so it is deactivated
        if timer1 != nil { timer1.invalidate() }
        
        //Sets the currentlyCounting, which is representative of whether or not a timer is active, to false
        currentlyCounting = false
        
        //Checks if current step is an ingredient, and if it is the first step. If so it returns.
        if ingredient && current == 0{
            return
        }else if ingredient && current == 1{//Checks if current step is an ingredient, and if it is the the second step. If so, it removes the previous button from the superview as it is no longer needed.
            prevButton.removeFromSuperview()
        }else if cookingstep && current == recipe.cookingSteps.count - 1 { //Checks if current step is the last step, if so it sets up the next button as it can now be used to traverse from the second to last step to the last step.
            setUpNextButtonConstraints()
        }
        
        //Animates the button
        prevButton.pulsate()
        
        //Checks if the overall progress of the recipe as made it to the last two steps, if so it doesn't remove the recipe step in the back from the super view, so that there is three steps stack on top of each other.
        if progressCount >= cardViewData.count - 2 {
            cardView.previousCardWithoutRemoving()
        }else{//Otherwise, it goes to the previous step and removes the step in the back from the superview
            cardView.previousCard(onCard: cardViewData[progressCount + 2])
        }
        
        //Decreases the progress count of the recipe by 1
        progressCount -= 1
        
        //Updates the current type of recipe step based on a direction (ingredient, prep step, or cooking step)
        checkStepStatus(direction: .backwards)
        
        //Updates the overall progress of the recipe walkthough, based on a direction
        updateProgress(direction: .backwards)
        
        //Checks if the previous recipe step type is cooking step and if there is a timer set, if so it starts the count down.
        if cookingstep && recipe.cookingSteps[current].timeUltimatum != ""{
            delegate.startCountDown(card: cardViewData[progressCount])
        }
    }
    
    //Sets up the progress values for the three progress bars
    func setUpProgressBarValue() {
        //Checks if there are no ingredients in the recipe
        if recipe.ingredients.count == 0 {
            //If so, checks if there are no prep steps in the recipe
            if recipe.prepSteps.count == 0 {
                //Sets ingredient and prep step to false as there are none in the recipe
                ingredient = false
                prepstep = false
                
                //Sets cooking step to true as there must be atleast 1 cooking step
                cookingstep = true
                
                //Sets the completed unit count for cooking steps to 1, updates the progress bar
                cookingstepProgress.completedUnitCount = Int64(1)
                let x = Float(cookingstepProgress.fractionCompleted)
                cookingstepProgressBar.setProgress(x, animated: true)
                
                //Exits the function
                return
            }
            //Otherwise sets ingredient to false, prep step to true as there is atleast one prep step
            ingredient = false
            prepstep = true
            
            //Sets the completed unit count for cooking steps to 1, updates the progress bar
            prepstepProgress.completedUnitCount = Int64(1)
            let x = Float(prepstepProgress.fractionCompleted)
            prepstepProgressBar.setProgress(x, animated: true)
            
            //Exits the function
            return
        }
        //Otherwise, sets the completed unit count for cooking steps to 1, updates the progress bar
        ingredientProgress.completedUnitCount = Int64(1)
        let x = Float(ingredientProgress.fractionCompleted)
        ingredientProgressBar.setProgress(x, animated: true)
    }
    
    //Takes a direction(backwards or forwards) as a parameter, and increments/decreases the appropriate progress bar
    func updateProgress(direction: Direction){
        switch direction {
        //If the direction is forwards, it increments the current progress by 1
        case .forwards:
            if ingredient {
                ingredientProgress.completedUnitCount = Int64(current + 1)
                let x = Float(ingredientProgress.fractionCompleted)
                ingredientProgressBar.setProgress(x, animated: true)
            } else if prepstep {
                prepstepProgress.completedUnitCount = Int64(current + 1)
                let x = Float(prepstepProgress.fractionCompleted)
                prepstepProgressBar.setProgress(x, animated: true)
            } else if cookingstep {
                cookingstepProgress.completedUnitCount = Int64(current + 1)
                let x = Float(cookingstepProgress.fractionCompleted)
                cookingstepProgressBar.setProgress(x, animated: true)
            }
        //If the direction is backwards, it decreases the current progress by 1
        case .backwards:
            if ingredient {
                ingredientProgress.completedUnitCount = Int64(current + 1)
                let x = Float(ingredientProgress.fractionCompleted)
                ingredientProgressBar.setProgress(x, animated: true)
                
                prepstepProgress.completedUnitCount = Int64(0)
                let y = Float(prepstepProgress.fractionCompleted)
                prepstepProgressBar.setProgress(y, animated: true)
                
                cookingstepProgress.completedUnitCount = Int64(0)
                let z = Float(cookingstepProgress.fractionCompleted)
                cookingstepProgressBar.setProgress(z, animated: true)
                
            } else if prepstep {
                prepstepProgress.completedUnitCount = Int64(current + 1)
                let x = Float(prepstepProgress.fractionCompleted)
                prepstepProgressBar.setProgress(x, animated: true)
                cookingstepProgress.completedUnitCount = Int64(0)
                let y = Float(cookingstepProgress.fractionCompleted)
                cookingstepProgressBar.setProgress(y, animated: true)
            } else if cookingstep {
                cookingstepProgress.completedUnitCount = Int64(current + 1)
                let x = Float(cookingstepProgress.fractionCompleted)
                cookingstepProgressBar.setProgress(x, animated: true)
            }
        }
    }
    
    //Takes a direction(backwards or forwards) as a parameter, and updates the current type of recipe step accordingly
    func checkStepStatus(direction: Direction){
        switch direction {
        case .forwards:
            //Checks if the overall progress count is greater than or equal to the amount of ingredients
            if progressCount >= recipe.ingredients.count {
                //Checks if it is equal to the amount of ingredients
                if progressCount == recipe.ingredients.count {
                    //Sets ingredient to false, and prep step to true
                    ingredient = false
                    prepstep = true
                    //Sets current to 0, as the current step is the first prep step. So it's index value in the prep steps array would be 0.
                    current = 0
                    //Exits the function
                    return
                }
                //Checks if the overall progress count is greater than or equal to the amount of ingredients + the amount of prep steps
                if progressCount == recipe.ingredients.count + recipe.prepSteps.count {
                    //Sets ingredient and prep step to false
                    ingredient = false
                    prepstep = false
                    //Sets cooking step to true
                    cookingstep = true
                    //Sets current to 0, as the current step is the first cooking step. So it's index value in the cooking steps array would be 0.
                    current = 0
                    //Exits the function
                    return
                }
            }
            //Otherwise, current is incremented by 1, as the next step is of the same type as the previous
            current += 1
        case .backwards:
            //Checks if the overall progress count is equal to the index value of the last ingredient in the ingredients array
            if progressCount == recipe.ingredients.count - 1 {
                //Sets ingredient to true, as the previous step is of type ingredient
                ingredient = true
                //Sets prep step and cooking step to false
                prepstep = false
                cookingstep = false
                //Sets current to the index value of the last ingredient in the ingredients array
                current = recipe.ingredients.count - 1
                //Exits the function
                return
            }
            //Checks if the overall progress count is equal to the last prep step
            if progressCount == recipe.ingredients.count + recipe.prepSteps.count - 1 {
                //Sets prep step to true, as the previous step is of type prep step
                prepstep = true
                //Sets cooking step to false
                cookingstep = false
                //Sets current to the index value of the last prep step in the prep steps array
                current = recipe.prepSteps.count - 1
                //Exits the function
                return
            }
            //Otherwise, current is incremented by 1, as the previous step is of the same type as the one ahead of it
            current -= 1
        }
    }
    
    //Adds an action to the "Next" button
    func addActionToButton(){
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    //Adds an action to the "Previous" button
    func addActiontoPrevButton(){
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
    }
    
    //Function that's called when the user double taps on a view card
    @objc func doubleTapped(){
        //Checks that that the current recipe step is a cooking step and there is a timer set
        if cookingstep && recipe.cookingSteps[current].timeUltimatum != nil {
            //Toggles the isPaused boolean to either pause or play the timer
            isPaused = !isPaused
            
            //Checks if isPaused is equal to false, if so, it starts the count down of the timer on the current card view
            if !isPaused {
                delegate.startCountDown(card: cardViewData[progressCount])
            }
            
            //Transitions the play/pause overlay onto the view to indicate the user has interacted with the timer
            UIView.transition(with: playPauseView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    //Sets isHidden to false
                    self.playPauseView.isHidden = false
                }
            )
            //After 0.5 seconds have elapsed, it transitions the pause/play overlay off the view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.transition(with: self.playPauseView, duration: 0.8, options: .transitionCrossDissolve, animations: {
                        //Sets isHidden to true
                        self.playPauseView.isHidden = true
                    }
                )
            }
        }
        //Otherwise, it exits the function
        return
    }
}

//Conforms PlayRecipeVC to WalkthoughCardViewDataSource
extension PlayRecipeVC: WalkthroughCardViewDataSource {
    //Returns the number of cards in the cardViewData array
    func numberOfCards() -> Int {
        cardViewData.count
    }
    
    //Takes an index as a paramter and returns the card at that specified index in the cardViewData array
    func card(forItemAtIndex index: Int) -> WalkthroughCardView {
        let card = cardViewData[index]
        return card
    }
}

//Conforms PlayRecipeVC to WalkthroughCardViewDelegate
extension PlayRecipeVC: WalkthroughCardViewDelegate {
    //Takes a WalkThroughCardView as a parameter,
    func startCountDown(card: WalkthroughCardView) {
        
        //Checks if the isPaused boolean is set to true, if so the function exits
        if isPaused {
            return
        }
        
        //Sets currentlyCounting to true, as the timer is active
        currentlyCounting = true
        
        //Declares a string equal to the timerLabel text
        let time = card.timerLabel.text ?? ""
        
        //Checks if time is set to an empty string, if so the function exits
        if time == "" {
            return
        }
        
        //Isolates the number of hours in the string, creates an Int that to represent the value
        let start = time.index(time.startIndex, offsetBy: 0)
        let end = time.index(time.startIndex, offsetBy: 2)
        let hourRange = start..<end
        var hours: Int = Int(time[hourRange]) ?? 1
        
        //Isolates the number of minutes in the string, creates an Int that to represent the value
        let start1 = time.index(time.startIndex, offsetBy: 3)
        let end1 = time.index(time.startIndex, offsetBy: 5)
        let minutesRange = start1..<end1
        var minutes: Int = Int(time[minutesRange]) ?? 1
        
        //Isolates the number of seconds in the string, creates an Int that to represent the value
        let start2 = time.index(time.startIndex, offsetBy: 6)
        let end2 = time.index(time.startIndex, offsetBy: 7)
        let secondsRange = start2...end2
        var seconds: Int = Int(time[secondsRange]) ?? 1
        
        //Declare variables for the string representation of the values for hours, minutes, and seconds
        var realHours = ""
        var realMinutes = ""
        var realSeconds = ""
        
        //Sets timer1 to a scheduled timer with an interval on 1 second that repeats.
        //This creates a timer that counts down by 1 second, until told otherwise.
        timer1 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats:true) { timer in
            //Checks if minutes is not zero, and if seconds is zero. If so, the amount of minutes is decreased by 1, and seconds is set to 59.
            if minutes != 0 && seconds == 0{
                seconds = 59
                minutes -= 1
            }else if hours != 0 && minutes == 0{ //Checks if hours is not zero, and if minutes is zero. If so, the amount of hours is decreased by 1, and minutes is set to 59.
                minutes = 59
                hours -= 1
            }else if hours == 0 && minutes == 0 && seconds == 0{ //Checks if the timer has reached zero with all values. If so it invalidates.
                timer.invalidate()
                //Checks if timerStartsAutomatically is set to true, if so it traverses the to the next step
                if Settings.timerStartsAutomatically {
                    self.nextButtonTapped()
                }
            }else{ //Decreases the value of seconds by 1
                seconds -= 1
                //Checks if timer is in the last five seconds, if so it pulsates
                if hours == 0 && minutes == 0 && seconds <= 5{
                    pulsate(view: card.timerLabel)
                }
            }
            
            //Following conditionals convert the values for hours, minutes, and seconds to string values, based on whether or not they are made of 1 or 2 digits.
            if hours < 10 {
                realHours = "0\(hours)"
            }else{
                realHours = "\(hours)"
            }
            if minutes < 10 {
                realMinutes = "0\(minutes)"
            }else{
                realMinutes = "\(minutes)"
            }
            if seconds < 10 {
                realSeconds = "0\(seconds)"
            }else{
                realSeconds = "\(seconds)"
            }
            
            //Checks if the isPaused boolean is true, if so the timer invalidates as the user has indicated they want to pause the timer.
            if self.isPaused {
                timer.invalidate()
                return
            }
            
            //Updates the timerLabel on the current WalkthroughCardView (on the main thread) with the string representations of hours, minutes, and seconds
            DispatchQueue.main.async {
                card.timerLabel.text = realHours + ":" + realMinutes + ":" + realSeconds
            }
        }
    }
}
