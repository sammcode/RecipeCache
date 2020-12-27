//
//  RecipeListVC.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/15/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

protocol RecipeListVCDelegate : class {
    func updateRecipes(recipe: Recipe, updateType: recipesArrayUpdate)
}

enum recipesArrayUpdate {
    case remove
    case update
}

class RecipeListVC: UIViewController {
    
    fileprivate let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 10
        stack.backgroundColor = UIColor.lightGray
        return stack
    }()
    
    fileprivate let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var imageView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let recipeImageView = UIImageView()
        recipeImageView.layer.cornerRadius = 10
        recipeImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        recipeImageView.image = images.lasagna
        containerView.addSubview(recipeImageView)
        return containerView
    }()
    
    var recipe: Recipe = Recipe(image: images.lasagna, title: "", ingredients: [Ingredient](), prepSteps: [PrepStep](), cookingSteps: [CookingStep](), id: "", dateCreated: "")
    let cellSpacingHeight: CGFloat = 5
    weak var delegate: RecipeListVCDelegate!
    var multiplier: String?
    var addMultiplier = AddMultiplierPopUp()
    var addMultiplierIsOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @objc func buttonTapped(){
        let playRecipeVC = PlayRecipeVC()
        playRecipeVC.recipe = recipe
        playRecipeVC.multiplier = multiplier
        self.navigationController?.pushViewController(playRecipeVC, animated: true)
    }
    
    @objc func editButtonTapped(){
        let editRecipeVC = NewRecipe(type: .edit)
        editRecipeVC.recipe1 = recipe
        editRecipeVC.delegate = self
        let navController = UINavigationController(rootViewController: editRecipeVC)
        self.present(navController, animated: true)
    }
    
    @objc func multiplierButtonTapped(){
        if !addMultiplierIsOpen {
            addMultiplierIsOpen = true
            addMultiplier = AddMultiplierPopUp()
            view.addSubview(addMultiplier)
            addMultiplier.addMultiplierPopUpDelegate = self
        }
    }
    
    func configure() {
        title = recipe.title
        
        let item1 = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        let item2 = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(buttonTapped))
        let item3 = UIBarButtonItem(image: UIImage(systemName: "dial"), style: .plain, target: self, action: #selector(multiplierButtonTapped))
        
        navigationItem.rightBarButtonItems = [item3, item2, item1]
        
        configureTableView()
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        setTableViewDelegate()
        tableView.register(IngredientCell.self, forCellReuseIdentifier: Cells.ingredientCell)
        tableView.register(PrepStepCell.self, forCellReuseIdentifier: Cells.prepStepCell)
        tableView.register(CookingStepCell.self, forCellReuseIdentifier: Cells.cookingStepCell)
        tableView.register(TitleCell.self, forCellReuseIdentifier: Cells.titleCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Cells.imageCell)
        tableView.pin(to: view)
    }

    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension RecipeListVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print( recipe.ingredients.count + recipe.prepSteps.count)
        let x: Int = recipe.ingredients.isEmpty ? 0 : 1
        let y: Int = recipe.prepSteps.isEmpty ? 0 : 1
        let z: Int = recipe.cookingSteps.isEmpty ? 0 : 1
        return recipe.ingredients.count + recipe.prepSteps.count + recipe.cookingSteps.count + x + y + z + 1
    }

    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var x: Int = 2
        var y: Int = 3
        var z: Int = 4
        
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
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.imageCell) as! ImageCell
            cell.img = recipe.image
            return cell
        }
        
        if indexPath.section == 1 && !recipe.ingredients.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Ingredients"
            cell.fontSize = 30
            return cell
        }
        
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
        
        if indexPath.section == recipe.ingredients.count + x && !recipe.prepSteps.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Prep Steps"
            cell.fontSize = 30
            return cell
        }
        
        if indexPath.section > recipe.ingredients.count + x && indexPath.section < recipe.ingredients.count + recipe.prepSteps.count + y{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.prepStepCell) as! PrepStepCell
            let prepStep = recipe.prepSteps[indexPath.section - recipe.ingredients.count - y]
            cell.prepStep = prepStep
            return cell
        }
        
        if indexPath.section == recipe.ingredients.count + recipe.prepSteps.count + y && !recipe.cookingSteps.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Cooking Steps"
            cell.fontSize = 30
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.cookingStepCell) as! CookingStepCell
        print(indexPath.section - recipe.prepSteps.count - recipe.ingredients.count - z)
        let cookingStep = recipe.cookingSteps[indexPath.section - recipe.prepSteps.count - recipe.ingredients.count - z]
        cell.cookingStep = cookingStep
        
        return cell
    }
    
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

extension RecipeListVC: NewRecipeDelegate {
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

extension RecipeListVC: AddMultiplierPopUpDelegate {
    func buttonTapped4() {
        multiplier = addMultiplier.multiplier
        guard multiplier != nil else { return }
        title = recipe.title + " x " + addMultiplier.multiplier
        tableView.reloadData()
        addMultiplierIsOpen = false
    }
    
    func resetButtonTapped() {
        title = recipe.title
        multiplier = nil
        tableView.reloadData()
        addMultiplierIsOpen = false
    }
}
