//
//  RecipeListVC.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/15/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

//Declares the protocol for RecipeListVC and conforms it to class
protocol RecipeListVCDelegate : class {
    func updateRecipes(recipe: Recipe, updateType: recipesArrayUpdate)
}

//Enum that helps differentiate the types of updates that can happen to the recipes array, either a recipe is being updated or it is being removed
enum recipesArrayUpdate {
    case remove
    case update
}

class RecipeListVC: UIViewController {
    
    //Declares the main tableview that will display all the custom cells
    fileprivate let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //Declares local recipe variable to be assigned data
    var recipe: Recipe = Recipe(image: images.lasagna, title: "", ingredients: [Ingredient](), prepSteps: [PrepStep](), cookingSteps: [CookingStep](), id: "", dateCreated: "")
    
    //Declares the height of the spacing between custom cells
    let cellSpacingHeight: CGFloat = 5
    
    //Declares the delegate that allows other viewcontrollers to communicate with RecipeListVC
    weak var delegate: RecipeListVCDelegate!
    
    //Declares optional string that stores a multiplier if the user sets one in the previous view
    var multiplier: String?
    
    //Declares a variable to hold an instance of the AddMultiplierPopUp view
    var addMultiplier: AddMultiplierPopUp!
    
    //Declares a variable to hold an instance of the AlertPopUp view
    var alertPopUp: AlertPopUp!
    
    //Declares a variable that indicates if the addMultiplier pop up is showing currently
    var addMultiplierIsOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //Function that's called when playButton is tapped
    @objc func playButtonTapped(){
        //Checks if the recipe doesn't have any ingredients or steps, if so it presents the alert popup
        if recipe.ingredients.isEmpty && recipe.prepSteps.isEmpty && recipe.cookingSteps.isEmpty {
            alertPopUp = AlertPopUp()
            view.addSubview(alertPopUp)
        } else { //Otherwise it creates an instance of PlayRecipeVC, sets the data variables and pushes it on to the navigation stack
            let playRecipeVC = PlayRecipeVC()
            playRecipeVC.recipe = recipe
            playRecipeVC.multiplier = multiplier
            self.navigationController?.pushViewController(playRecipeVC, animated: true)
        }
    }
    
    //Function that's called when the editButton is tapped
    //Creates an instance of NewRecipe of type edit, sets the data variables and the delegate, and presents it
    @objc func editButtonTapped(){
        let editRecipeVC = NewRecipe(type: .edit)
        editRecipeVC.recipe1 = recipe
        editRecipeVC.delegate = self
        let navController = UINavigationController(rootViewController: editRecipeVC)
        self.present(navController, animated: true)
    }
    
    //Function that's called when the multiplier button is tapped
    @objc func multiplierButtonTapped(){
        //Checks that the addMultiplier pop up isn't open already
        //If not, creates an instance of AddMultiplierPopUp and adds it to the subview
        if !addMultiplierIsOpen {
            addMultiplierIsOpen = true
            addMultiplier = AddMultiplierPopUp()
            view.addSubview(addMultiplier)
            addMultiplier.addMultiplierPopUpDelegate = self
        }
    }
    
    //Configures general properties of the viewcontroller
    func configure() {
        //Sets the title for the view to the title of the recipe
        title = recipe.title
        
        //Declares the navigation bar button items
        let item1 = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        let item2 = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playButtonTapped))
        let item3 = UIBarButtonItem(image: UIImage(systemName: "dial"), style: .plain, target: self, action: #selector(multiplierButtonTapped))
        
        //Assigns the navigation bar button items
        navigationItem.rightBarButtonItems = [item3, item2, item1]
        
        //Configures the table view
        configureTableView()
    }
    
    //Configures the properties of the main tableview
    func configureTableView(){
        //Adds tableview to the view as a subview
        view.addSubview(tableView)
        //Sets up the delegate and datasource
        setTableViewDelegate()
        //Registers all the resusable cells that the tableview will be using
        tableView.register(IngredientCell.self, forCellReuseIdentifier: Cells.ingredientCell)
        tableView.register(PrepStepCell.self, forCellReuseIdentifier: Cells.prepStepCell)
        tableView.register(CookingStepCell.self, forCellReuseIdentifier: Cells.cookingStepCell)
        tableView.register(TitleCell.self, forCellReuseIdentifier: Cells.titleCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Cells.imageCell)
        //Pins the tableview to the view
        tableView.pin(to: view)
    }
    
    //Sets up the tableview delegate and datasource
    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }

}

//Conforms RecipeListVC to UITableViewDelegate and UITableViewDataSource
extension RecipeListVC: UITableViewDelegate, UITableViewDataSource{
    
    //Sets the number of sections in the tableview.
    func numberOfSections(in tableView: UITableView) -> Int {
        let x: Int = recipe.ingredients.isEmpty ? 0 : 1
        let y: Int = recipe.prepSteps.isEmpty ? 0 : 1
        let z: Int = recipe.cookingSteps.isEmpty ? 0 : 1
        return recipe.ingredients.count + recipe.prepSteps.count + recipe.cookingSteps.count + x + y + z + 1
    }

    //There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    //Sets the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    //Sets the header view to a clear UIView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //Determines and sets the correct reusable cell based on the indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Declares variables that represent how many title cells/image cells are in the tableview in addition to ingredient and recipe step cells, at specific points
        var x: Int = 2
        var y: Int = 3
        var z: Int = 4
        
        //Sets x, y, z based on whether or not the recipe has ingreidents, prep steps, and cooking steps
        if recipe.ingredients.isEmpty {
            x = 1
            y = 2
            z = 3
            if recipe.prepSteps.isEmpty {
                y = 1
                z = 2
            }
            if recipe.cookingSteps.isEmpty {
                z = 1
            }
        }else if recipe.prepSteps.isEmpty {
            y = 2
            z = 3
            if recipe.cookingSteps.isEmpty {
                z = 2
            }
        }else if recipe.cookingSteps.isEmpty {
            z = 3
        }
        
        //Returns an image cell to display the image assigned to the recipe
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.imageCell) as! ImageCell
            cell.img = recipe.image
            return cell
        }
        
        //Returns a title cell, and sets the title to "Ingredients"
        if indexPath.section == 1 && !recipe.ingredients.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Ingredients"
            cell.fontSize = 30
            return cell
        }
        
        //Returns an Ingredient cell, and sets the ingredient data accordingly
        if indexPath.section < recipe.ingredients.count + x{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.ingredientCell) as! IngredientCell
            let ingredient = recipe.ingredients[indexPath.section - x]
            if multiplier != nil && ingredient.qnty != nil {
                let ing = Ingredient(title: ingredient.title, qnty: HelpfulFunctions.applyMultiplier(quantity: ingredient.qnty!, multiplier: multiplier!), notes: ingredient.notes)
                cell.ingredient = ing
                cell.ingredientQntyLabel.textColor = UIColor.systemRed
            }else{
                cell.ingredient = ingredient
                cell.ingredientQntyLabel.textColor = UIColor.white
            }
            return cell
        }
        
        //Returns a title cell, and sets the title to "Prep Steps"
        if indexPath.section == recipe.ingredients.count + x && !recipe.prepSteps.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Prep Steps"
            cell.fontSize = 30
            return cell
        }
        
        //Returns a Prep Step cell, and sets the prep step data accordingly
        if indexPath.section > recipe.ingredients.count + x && indexPath.section < recipe.ingredients.count + recipe.prepSteps.count + y{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.prepStepCell) as! PrepStepCell
            let prepStep = recipe.prepSteps[indexPath.section - recipe.ingredients.count - y]
            cell.prepStep = prepStep
            return cell
        }
        
        //Returns a title cell, and sets the title to "Cooking Steps"
        if indexPath.section == recipe.ingredients.count + recipe.prepSteps.count + y && !recipe.cookingSteps.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Cooking Steps"
            cell.fontSize = 30
            return cell
        }
        
        //Returns a Cooking Step cell, and sets the cooking step data accordingly
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.cookingStepCell) as! CookingStepCell
        print(indexPath.section - recipe.prepSteps.count - recipe.ingredients.count - z)
        let cookingStep = recipe.cookingSteps[indexPath.section - recipe.prepSteps.count - recipe.ingredients.count - z]
        cell.cookingStep = cookingStep
        return cell
    }

    //Returns the appropriate row height based on the type of cell being displayed. This is determined based on specific sections in the index path.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var result: CGFloat = 0
        if indexPath.section == 0 {
            return 250
        }
        
        if indexPath.section == 1 || indexPath.section == recipe.ingredients.count + 2 || indexPath.section == recipe.ingredients.count + recipe.prepSteps.count + 3{
            return 60
        }
        
        if indexPath.section < recipe.ingredients.count + 2{
            let ingredient = recipe.ingredients[indexPath.section - 2]
            result = 40
            if ingredient.qnty != nil{
                result += 20
            }
            if ingredient.notes != nil{
                if ingredient.notes!.count > 120{
                    result += 80
                }else if ingredient.notes!.count > 80{
                    result += 60
                }else if ingredient.notes!.count > 40{
                    result += 40
                }else{
                    result += 20
                }
            }
        }
        
        if indexPath.section > recipe.ingredients.count + 2 && indexPath.section < recipe.ingredients.count + recipe.prepSteps.count + 3{
            let prepstep = recipe.prepSteps[indexPath.section - recipe.ingredients.count - 3]
        
            if prepstep.notes == nil{
                result = 40
            }else if prepstep.notes!.count > 120{
                result = 120
            }else if prepstep.notes!.count > 80{
                result = 100
            }else if prepstep.notes!.count > 40{
                result = 80
            }else{
                result = 60
            }
            if prepstep.title.count > 30{
                result += 20
            }
        }
        
        if indexPath.section > recipe.ingredients.count + recipe.prepSteps.count + 3{
            let cookingstep = recipe.cookingSteps[indexPath.section - recipe.prepSteps.count - recipe.ingredients.count - 4]
            result = 40
            if cookingstep.timeUltimatum != ""{
                result += 20
            }
        }
        return result
    }
}

//Conforms RecipeListVC to NewRecipeDelegate
extension RecipeListVC: NewRecipeDelegate {
    //Takes a recipe and recipesArrayUpdate enum as parameters, sets the local recipe data to the inputted recipe, and either reloads the tableview data or pops to the HomeVC based on the inputted enum
    func updateData(recipe1: Recipe, updateType: recipesArrayUpdate) {
        recipe = recipe1
        delegate.updateRecipes(recipe: recipe1, updateType: updateType)
        switch updateType {
        case .update:
            tableView.reloadData()
            title = recipe.title
        case .remove:
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

//Conforms RecipeListVC to AddMultiplierPopUpDelegate
extension RecipeListVC: AddMultiplierPopUpDelegate {
    //Function that's called when the AddMultiplierPopUp button is tapped. If there is user-inputted multiplier, local data is updated accordingly as well as certain properties of the view
    func buttonTapped4() {
        multiplier = addMultiplier.multiplier
        guard multiplier != nil else { return }
        title = recipe.title + " x " + addMultiplier.multiplier
        tableView.reloadData()
        addMultiplierIsOpen = false
    }

    //Function that's called when the AddMultiplierPopUp is tapped. Sets the local multiplier variable to nil, reloads the tableview, and updates a few other properties.
    func resetButtonTapped() {
        title = recipe.title
        multiplier = nil
        tableView.reloadData()
        addMultiplierIsOpen = false
    }
}
