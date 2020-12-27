//
//  PlayRecipeVC.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 5/9/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

protocol PlayRecipeVCDelegate : class {
    func startCountDown(time: String)
}

class PlayRecipeVC: UIViewController {
    
    var recipe: Recipe = Recipe(image: images.lasagna, title: "", ingredients: [Ingredient](), prepSteps: [PrepStep](), cookingSteps: [CookingStep](), id: "", dateCreated: "")
    
    var cardViewData: [WalkthroughCardView] = []
    
    var multiplier: String?
    
    var delegate: WalkthroughCardViewDelegate!
    
    var cardView: SwipeableCardViewContainer = {
        let cardview = SwipeableCardViewContainer()
        cardview.translatesAutoresizingMaskIntoConstraints = false
        return cardview
    }()
    
    private var tapView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private var exitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Exit", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.black
        return button
    }()
    
    private var nextButton: StyleButton = {
        let button = StyleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var prevButton: StyleButton = {
        let button = StyleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Previous", for: .normal)
        return button
    }()
    
    var progressBar: UIStackView = {
        let progress = UIStackView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.axis = .horizontal
        progress.distribution = .fillEqually
        progress.spacing = 5
        return progress
    }()
    
    private var ingredientProgressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressViewStyle = .bar
        return progress
    }()
    
    private var prepstepProgressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressViewStyle = .bar
        return progress
    }()
    
    private var cookingstepProgressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressViewStyle = .bar
        return progress
    }()
    
    private var playPauseView: PlayPauseIndicatorView = {
        let ppview = PlayPauseIndicatorView(image: UIImage(systemName: "playpause.fill")!)
        ppview.translatesAutoresizingMaskIntoConstraints = false
        ppview.layer.cornerRadius = 20
        return ppview
    }()
    
    var ingredientProgress = Progress()
    var prepstepProgress = Progress()
    var cookingstepProgress = Progress()
    
    weak var timer1: Timer!
    
    private var current = 0
    private var ingredient = true
    private var prepstep = false
    private var cookingstep = false
    private var currentlyCounting = false
    private var progressCount = 0
    private var isPaused = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func fillCardViewData() {
        var ingCount = 1
        var prepCount = 1
        var cookCount = 1
        for ing in recipe.ingredients {
            let quantity: String!
            if multiplier != nil {
                quantity = HelpfulFunctions.applyMultiplier(quantity: ing.qnty!, multiplier: multiplier!)
            }else{
                quantity = ing.qnty
            }
            cardViewData.append(WalkthroughCardView(backview: "Ingredient \(ingCount)", title: ing.title, timer: quantity ?? "", notes: ing.notes ?? "", backviewColor: UIColor(named: "ingredient")!, backviewTitleColor: UIColor(named: "ingredient3")!, delegate: self))
            ingCount += 1
        }
        for prep in recipe.prepSteps {
            cardViewData.append(WalkthroughCardView(backview: "Prep Step \(prepCount)", title: prep.title, timer: "", notes: prep.notes ?? "", backviewColor: UIColor(named: "prepstep")!, backviewTitleColor: UIColor(named: "prepstep3")!, delegate: self))
            prepCount += 1
        }
        for cook in recipe.cookingSteps {
            cardViewData.append(WalkthroughCardView(backview: "Cooking Step \(cookCount)", title: cook.title, timer: cook.timeUltimatum ?? "", notes: "", backviewColor:  UIColor(named: "cookingstep")!, backviewTitleColor: UIColor(named: "cookingstep3")!, delegate: self))
            cookCount += 1
        }
    }
    
    func configure() {
        fillCardViewData()
        setUpElements()
        addActionToButton()
        
        if multiplier != nil {
            title = recipe.title + " x " + multiplier!
        }else{
            title = recipe.title
        }
        view.backgroundColor = .systemBackground
        self.delegate = self
    }
    
    func setUpElements(){
        if recipe.ingredients.count + recipe.prepSteps.count + recipe.cookingSteps.count > 1 { setUpNextButtonConstraints() }
        setUpCardViewConstraints()
        setUpProgressBarConstraints()
        setUpProgressBars()
        setUpProgressBarValue()
        setUpPlayPauseIndicatorViewConstraints()
        setUpTapViewConstraints()
    }
    
    func setUpTapViewConstraints() {
        view.addSubview(tapView)
        tapView.backgroundColor = UIColor.clear
        
        let height: CGFloat!
        
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
        
        NSLayoutConstraint.activate([
            tapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tapView.widthAnchor.constraint(equalToConstant: ScreenSize.width),
            tapView.heightAnchor.constraint(equalToConstant: height)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        tapView.addGestureRecognizer(tap)
    }
    
    func setUpPlayPauseIndicatorViewConstraints(){
        view.addSubview(playPauseView)
        NSLayoutConstraint.activate([
            playPauseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playPauseView.widthAnchor.constraint(equalToConstant: 160),
            playPauseView.heightAnchor.constraint(equalToConstant: 160)
        ])
        playPauseView.isHidden = true
    }
    
    func setUpProgressBarConstraints() {
        view.addSubview(progressBar)
        if recipe.ingredients.count != 0 { progressBar.addArrangedSubview(ingredientProgressBar) }
        if recipe.prepSteps.count != 0 { progressBar.addArrangedSubview(prepstepProgressBar) }
        if recipe.cookingSteps.count != 0 { progressBar.addArrangedSubview(cookingstepProgressBar) }
        
        let constant: CGFloat!
        if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            constant = ScreenSize.height * 0.22
        }else if DeviceType.isiPhoneSE {
            constant = ScreenSize.height * 0.16
        }else{
            constant = ScreenSize.height * 0.19
        }
        
        NSLayoutConstraint.activate([
            progressBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant),
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 20),
            progressBar.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.9)
        ])
    }
    
    func setUpProgressBars(){
        ingredientProgress = Progress(totalUnitCount: Int64(recipe.ingredients.count))
        prepstepProgress = Progress(totalUnitCount: Int64(recipe.prepSteps.count))
        cookingstepProgress = Progress(totalUnitCount: Int64(recipe.cookingSteps.count))
        
        ingredientProgressBar.tintColor = UIColor(named: "ingredient")
        prepstepProgressBar.tintColor = UIColor(named: "prepstep")
        cookingstepProgressBar.tintColor = UIColor(named: "cookingstep")
    }
    
    func setUpCardViewConstraints(){
        view.addSubview(cardView)
        cardView.dataSource = self
        cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setUpNextButtonConstraints(){
        view.addSubview(nextButton)
        let height: CGFloat = (DeviceType.isiPad || DeviceType.isiPad7thGen || DeviceType.isiPadAir || DeviceType.isiPad11inch || DeviceType.isiPadPro) ? ScreenSize.width * 0.1 : ScreenSize.width * 0.2
        let constant: CGFloat!
        
        if DeviceType.isiPhoneSE {
            constant = -view.bounds.width/16
        }else {
            constant = -view.bounds.width/15
        }
        
        nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.3).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setUpPrevButtonConstraints(){
        view.addSubview(prevButton)
        let height: CGFloat = (DeviceType.isiPad || DeviceType.isiPad7thGen || DeviceType.isiPadAir || DeviceType.isiPad11inch || DeviceType.isiPadPro) ? ScreenSize.width * 0.1 : ScreenSize.width * 0.2
        let constant: CGFloat!
        if DeviceType.isiPhoneSE {
            constant = -view.bounds.width/16
        }else {
            constant = -view.bounds.width/15
        }
        addActiontoPrevButton()
        prevButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
        prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -constant).isActive = true
        prevButton.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.3).isActive = true
        prevButton.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    @objc func nextButtonTapped() {
        if timer1 != nil { timer1.invalidate() }
        currentlyCounting = false
        
        if progressCount == recipe.ingredients.count + recipe.prepSteps.count + recipe.cookingSteps.count - 1 {
            return
        }else if ingredient && current == 0{
            setUpPrevButtonConstraints()
        }else if cookingstep && current == recipe.cookingSteps.count - 2 {
            nextButton.removeFromSuperview()
        }
        
        nextButton.pulsate()
        
        cardView.nextCard(onCard: cardViewData[progressCount])
        
        
        progressCount += 1
        
        checkStepStatus(direction: .forwards)
        updateProgress(direction: .forwards)
        
        if cookingstep && recipe.cookingSteps[current].timeUltimatum != nil && Settings.timerStartsAutomatically{
            delegate.startCountDown(card: cardViewData[progressCount])
        }
    }
    
    @objc func prevButtonTapped() {
        if timer1 != nil { timer1.invalidate() }
        
        currentlyCounting = false
        if ingredient && current == 0{
            return
        }else if ingredient && current == 1{
            prevButton.removeFromSuperview()
        }else if cookingstep && current == recipe.cookingSteps.count - 1 {
            setUpNextButtonConstraints()
        }
        
        prevButton.pulsate()
        
        if progressCount >= cardViewData.count - 2 {
            cardView.previousCardWithoutRemoving()
        }else{
            cardView.previousCard(onCard: cardViewData[progressCount + 2])
        }
        
        progressCount -= 1
        
        checkStepStatus(direction: .backwards)
        updateProgress(direction: .backwards)
        
        if cookingstep && recipe.cookingSteps[current].timeUltimatum != ""{
            delegate.startCountDown(card: cardViewData[progressCount])
        }
    }
    
    func setUpProgressBarValue() {
        if recipe.ingredients.count == 0 {
            if recipe.prepSteps.count == 0 {
                ingredient = false
                prepstep = false
                cookingstep = true
                
                cookingstepProgress.completedUnitCount = Int64(1)
                let x = Float(cookingstepProgress.fractionCompleted)
                cookingstepProgressBar.setProgress(x, animated: true)
                
                return
            }
            ingredient = false
            prepstep = true
            
            prepstepProgress.completedUnitCount = Int64(1)
            let x = Float(prepstepProgress.fractionCompleted)
            prepstepProgressBar.setProgress(x, animated: true)
            
            return
        }
        ingredientProgress.completedUnitCount = Int64(1)
        let x = Float(ingredientProgress.fractionCompleted)
        ingredientProgressBar.setProgress(x, animated: true)
    }
    
    func updateProgress(direction: Direction){
        print(current)
        
        switch direction {
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
    
    func checkStepStatus(direction: Direction){
        switch direction {
        case .forwards:
            if progressCount >= recipe.ingredients.count {
                if progressCount == recipe.ingredients.count {
                    ingredient = false
                    prepstep = true
                    current = 0
                    if progressCount == recipe.ingredients.count + recipe.prepSteps.count {
                        ingredient = false
                        prepstep = false
                        cookingstep = true
                        current = 0
                        return
                    }
                }
                if progressCount == recipe.ingredients.count + recipe.prepSteps.count {
                    ingredient = false
                    prepstep = false
                    cookingstep = true
                    current = 0
                    return
                }
            }
            current += 1
        case .backwards:
            if progressCount == recipe.ingredients.count - 1 {
                ingredient = true
                prepstep = false
                cookingstep = false
                current = recipe.ingredients.count - 1
                if progressCount == recipe.ingredients.count + recipe.prepSteps.count - 1 {
                    prepstep = true
                    cookingstep = false
                    current = recipe.ingredients.count - 1
                    return
                }
                return
            }
            if progressCount == recipe.ingredients.count + recipe.prepSteps.count - 1 {
                prepstep = true
                cookingstep = false
                current = recipe.prepSteps.count - 1
                return
            }
            current -= 1
            
        }
    }
    
    func addActionToButton(){
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    func addActiontoPrevButton(){
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
    }
    
    @objc func doubleTapped(){
        if cookingstep && recipe.cookingSteps[current].timeUltimatum != nil {
            isPaused = !isPaused
            if !isPaused {
                delegate.startCountDown(card: cardViewData[progressCount])
            }
            UIView.transition(with: playPauseView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    self.playPauseView.isHidden = false
                }
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.transition(with: self.playPauseView, duration: 0.8, options: .transitionCrossDissolve, animations: {
                        self.playPauseView.isHidden = true
                    }
                )
            }
        }
        return
    }
}

extension PlayRecipeVC: WalkthroughCardViewDataSource {
    func numberOfCards() -> Int {
        cardViewData.count
    }
    
    func card(forItemAtIndex index: Int) -> WalkthroughCardView {
        let card = cardViewData[index]
        return card
    }
    
    func viewForEmptyCards() -> UIView? {
        return nil
    }
}

extension PlayRecipeVC: WalkthroughCardViewDelegate {

    func startCountDown(card: WalkthroughCardView) {
        
        if isPaused {
            return
        }
        
        currentlyCounting = true
        let time = card.timerLabel.text ?? ""
        if time == "" {
            return
        }
        
        let start = time.index(time.startIndex, offsetBy: 0)
        let end = time.index(time.startIndex, offsetBy: 2)
        let hourRange = start..<end
        var hours: Int = Int(time[hourRange]) ?? 1
        
        let start1 = time.index(time.startIndex, offsetBy: 3)
        let end1 = time.index(time.startIndex, offsetBy: 5)
        let minutesRange = start1..<end1
        var minutes: Int = Int(time[minutesRange]) ?? 1
        
        let start2 = time.index(time.startIndex, offsetBy: 6)
        let end2 = time.index(time.startIndex, offsetBy: 7)
        let secondsRange = start2...end2
        var seconds: Int = Int(time[secondsRange]) ?? 1
        
        var realHours = ""
        var realMinutes = ""
        var realSeconds = ""
        
        timer1 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats:true) { timer in
            
            if minutes != 0 && seconds == 0{
                seconds = 59
                minutes -= 1
            }else if hours != 0 && minutes == 0{
                minutes = 59
                hours -= 1
            }else if hours == 0 && minutes == 0 && seconds == 0{
                timer.invalidate()
                if Settings.timerStartsAutomatically {
                    let delay = Double(Settings.timerDelay)
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                        self.nextButtonTapped()
                    }
                }
            }else if seconds == 0{
                seconds = 59
            }else{
                seconds -= 1
                if hours == 0 && minutes == 0 && seconds <= 5{
                    pulsate(view: card.timerLabel)
                }
            }
            
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
            if self.isPaused {
                timer.invalidate()
                return
            }
            DispatchQueue.main.async {
                card.timerLabel.text = realHours + ":" + realMinutes + ":" + realSeconds
            }
        }
    }
}