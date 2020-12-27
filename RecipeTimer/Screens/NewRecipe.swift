//
//  NewRecipe.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 5/7/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit
import CoreData

protocol NewRecipeDelegate: class {
    func updateData(recipe1: Recipe, updateType: recipesArrayUpdate)
}

enum recipeEditType {
    case new
    case edit
}

class NewRecipe: UIViewController {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    public var recipe1: Recipe = Recipe(image: images.selectImage, title: "New Recipe", ingredients: [Ingredient](), prepSteps: [PrepStep](), cookingSteps: [CookingStep](), id: "", dateCreated: "")
    var ingredient: Ingredient = Ingredient(title: "", qnty: "")
    let cellSpacingHeight: CGFloat = 5
    weak var delegate: NewRecipeDelegate!
    var pageType: recipeEditType!
    var addIngredient = AddIngredientPopUp()
    var addPrepStep = AddPrepStepPopUp()
    var addCookingStep = AddCookingStepPopUp()
    var editTitle = EditTitlePopUp()
    var imagePicker = ImagePicker()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(type: recipeEditType){
        self.init()
        switch type {
        case .edit:
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
            barButtonItem.tintColor = UIColor.red
            navigationItem.rightBarButtonItem = barButtonItem
            pageType = .edit
        case .new:
            pageType = .new
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func deleteButtonTapped() {
        PersistenceService.deleteRecipe(recipeID: recipe1.id)
        delegate.updateData(recipe1: recipe1, updateType: .remove)
        self.dismiss(animated: true)
    }
    
    func configure() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        view.backgroundColor = .systemBackground
        
        configureTableView()
        title = recipe1.title
    }
    
    func setUpTableViewConstraints(){
        let width = DeviceType.isiPad || DeviceType.isiPadPro ? ScreenSize.width * 0.7 : ScreenSize.width
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: ScreenSize.height * 0.9).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.pin(to: view)
        setTableViewDelegate()
        tableView.register(IngredientCell.self, forCellReuseIdentifier: Cells.ingredientCell)
        tableView.register(PrepStepCell.self, forCellReuseIdentifier: Cells.prepStepCell)
        tableView.register(CookingStepCell.self, forCellReuseIdentifier: Cells.cookingStepCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Cells.imageCell)
        tableView.register(TitleCell.self, forCellReuseIdentifier: Cells.titleCell)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: Cells.buttonCell)
    }
    
    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func chooseImage(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = view
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func saveNewRecipe(){
        let managedObjectContext = PersistenceService.context
        let entityRecipe = NSEntityDescription.entity(forEntityName: "Recipes", in: managedObjectContext)!
        
        let title = recipe1.title
        let image = recipe1.image.toData
        let id = UUID().uuidString
        
        var ingredientsArray: [IngredientData] = []
        var prepStepsArray: [PrepStepData] = []
        var cookingStepsArray: [CookingStepData] = []
        
        for ing in recipe1.ingredients{
            let newIngredient = IngredientData(title: ing.title, qnty: ing.qnty, notes: ing.notes)
            ingredientsArray.append(newIngredient)
        }
        
        for prep in recipe1.prepSteps{
            let newPrepStep = PrepStepData(title: prep.title, notes: prep.notes)
            prepStepsArray.append(newPrepStep)
        }
        
        for cook in recipe1.cookingSteps{
            let newCookingStep = CookingStepData(title: cook.title, timeUltimatum: cook.timeUltimatum)
            cookingStepsArray.append(newCookingStep)
        }
        
        let recipe = NSManagedObject(entity: entityRecipe, insertInto: managedObjectContext) as! Recipes
        let mIngredients = IngredientsData(ingredients: ingredientsArray)
        let mPrepSteps = PrepStepsData(prepsteps: prepStepsArray)
        let mCookingSteps = CookingStepsData(cookingsteps: cookingStepsArray)
        
        recipe.setValue(mIngredients, forKeyPath: "ingredients")
        recipe.setValue(mPrepSteps, forKeyPath: "prepsteps")
        recipe.setValue(mCookingSteps, forKeyPath: "cookingsteps")
        
        recipe.setValue(title, forKeyPath: "title")
        recipe.setValue(image, forKeyPath: "image")
        recipe.setValue(id, forKey: "id")
        
        PersistenceService.saveContext()
    }
}

extension NewRecipe: UITableViewDelegate, UITableViewDataSource, ButtonCellDelegate{
    func didPressButton(cell: ButtonCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            if indexPath[0] == recipe1.ingredients.count + 3{
                addIngredient = AddIngredientPopUp()
                view.addSubview(addIngredient)
                addIngredient.ingredientDelegate = self
                
            }else if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + 5{
                addPrepStep = AddPrepStepPopUp()
                view.addSubview(addPrepStep)
                addPrepStep.addPrepStepDelegate = self
            }else if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7{
                addCookingStep = AddCookingStepPopUp()
                view.addSubview(addCookingStep)
                addCookingStep.cookingStepDelegate = self
            }else if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 8{
                
                switch pageType {
                case .edit:
                    PersistenceService.updateRecipe(recipe1: recipe1)
                case .new:
                    PersistenceService.saveNewRecipe(recipe1: recipe1)
                case .none:
                    return
                }
                
                delegate.updateData(recipe1: recipe1, updateType: .update)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print( recipe1.ingredients.count + recipe1.prepSteps.count)
        return recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 9
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            editTitle = EditTitlePopUp()
            view.addSubview(editTitle)
            editTitle.editTitleDelegate = self
        }
        if indexPath.section == 1{
            chooseImage()
        }
        if indexPath[0] == recipe1.ingredients.count + 3{
            addIngredient = AddIngredientPopUp()
            view.addSubview(addIngredient)
            addIngredient.ingredientDelegate = self
            
        }
        if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + 5{
            addPrepStep = AddPrepStepPopUp()
            view.addSubview(addPrepStep)
            addPrepStep.addPrepStepDelegate = self
        }
        if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7{
            addCookingStep = AddCookingStepPopUp()
            view.addSubview(addCookingStep)
            addCookingStep.cookingStepDelegate = self
        }
        if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 8{
            
            switch pageType {
            case .edit:
                PersistenceService.updateRecipe(recipe1: recipe1)
            case .new:
                PersistenceService.saveNewRecipe(recipe1: recipe1)
            case .none:
                return
            }
            
            let dateCreated = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let dateCreatedString = dateFormatter.string(from: dateCreated)
            recipe1.dateCreated = dateCreatedString
            
            delegate.updateData(recipe1: recipe1, updateType: .update)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.section)
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
                cell.title = recipe1.title + " 🔧"
                cell.fontSize = 36
                return cell
            }
        
            if indexPath.section == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.imageCell) as! ImageCell
                cell.img = recipe1.image
                return cell
            }
        
            if indexPath.section == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
                cell.title = "Ingredients"
                return cell
            }
        
            if indexPath.section > 2 && indexPath.section < (recipe1.ingredients.count + 3){
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.ingredientCell) as! IngredientCell
                let ingredient = recipe1.ingredients[indexPath.section - 3]
                cell.ingredient = ingredient
                return cell
            }
        
            if indexPath.section == recipe1.ingredients.count + 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.buttonCell)   as! ButtonCell
                cell.title = "Add Ingredient"
                cell.buttonDelegate = self
                return cell
            }
        
            if indexPath.section == recipe1.ingredients.count + 4{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
                cell.title = "Prep Steps"
                return cell
            }
        
            if indexPath.section > recipe1.ingredients.count + 4 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + 5{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.prepStepCell) as! PrepStepCell
                let prepStep = recipe1.prepSteps[indexPath.section - recipe1.ingredients.count - 5]
                cell.prepStep = prepStep
                return cell
            }
        
            if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + 5{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.buttonCell)   as! ButtonCell
                cell.title = "Add Prep Step"
                cell.buttonDelegate = self
                return cell
            }
        
            if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + 6{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
                cell.title = "Cooking Steps"
                return cell
            }
        
            if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7{
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.buttonCell)   as! ButtonCell
                cell.title = "Add Cooking Step"
                cell.buttonDelegate = self
                return cell
            }
        
            if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 8{
                
                let cell = ButtonCell(style: .default, reuseIdentifier: Cells.buttonCell, color: UIColor(named: "background")!)
                var buttonTitle = ""
                
                switch pageType {
                case .edit:
                    buttonTitle = "Save Recipe"
                case .new:
                    buttonTitle = "Create Recipe"
                case .none:
                    buttonTitle = "Create Recipe"
                }
                
                cell.title = buttonTitle
                cell.buttonDelegate = self
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.cookingStepCell) as! CookingStepCell
            let cookingStep = recipe1.cookingSteps[indexPath.section - recipe1.prepSteps.count - recipe1.ingredients.count - 7]
            
            cell.cookingStep = cookingStep
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var result: CGFloat = 0
        if indexPath.section == 0 {
            if recipe1.title.count < 15 { return 60 }
            else { return 100 }
        }
        
        if indexPath.section == 2 || indexPath.section == recipe1.ingredients.count + 4 || indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + 6{
            return 60
        }
        
        if indexPath.section == 1 {
            return 250
        }
        
        if indexPath.section == recipe1.ingredients.count + 3 || indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + 5 || indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7 || indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 8{
            return 90
        }
        
        if indexPath.section > 2 && indexPath.section < (recipe1.ingredients.count + 3){
            let ingredient = recipe1.ingredients[indexPath.section - 3]
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
        
        if indexPath.section > recipe1.ingredients.count + 4 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + 5{
            let prepstep = recipe1.prepSteps[indexPath.section - recipe1.ingredients.count - 5]
        
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
        
        if indexPath.section > recipe1.ingredients.count + recipe1.prepSteps.count + 6 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7{
            let cookingstep = recipe1.cookingSteps[indexPath.section - recipe1.prepSteps.count - recipe1.ingredients.count - 7]
            result = 40
            if cookingstep.timeUltimatum != ""{
                result += 20
            }
        }
        return result
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        if indexPath.section > 2 && indexPath.section < (recipe1.ingredients.count + 3){
            let ingredient = recipe1.ingredients[indexPath.section - 3]
            if let x = recipe1.ingredients.firstIndex(where: {$0.title == ingredient.title}){
                recipe1.ingredients.remove(at: x)
            }
        }
        
        if indexPath.section > recipe1.ingredients.count + 4 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + 5{
            let prepStep = recipe1.prepSteps[indexPath.section - recipe1.ingredients.count - 5]
            if let x = recipe1.prepSteps.firstIndex(where: {$0.title == prepStep.title}){
                recipe1.prepSteps.remove(at: x)
            }
        }
        
        if indexPath.section > recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 6{
            let cookingStep = recipe1.cookingSteps[indexPath.section - recipe1.prepSteps.count - recipe1.ingredients.count - 7]
            if let x = recipe1.cookingSteps.firstIndex(where: {$0.title == cookingStep.title}){
                recipe1.cookingSteps.remove(at: x)
            }
        }
        
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section > 2 && indexPath.section < (recipe1.ingredients.count + 3) || (indexPath.section > recipe1.ingredients.count + 4 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + 5) || (indexPath.section > recipe1.ingredients.count + recipe1.prepSteps.count + 6 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7){
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
}

extension NewRecipe: AddIngredientDelegate, AddPrepStepDelegate, AddCookingStepDelegate, EditTitleDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        recipe1.image = image
        tableView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func buttonTapped3() {
        let title = editTitle.title!
        if title == ""{
            return
        }
        recipe1.title = title
        tableView.reloadData()
    }
    
    func buttonTapped2() {
        let cooking = addCookingStep.cookingStep!
        if cooking.title == "" {
            return
        }
        recipe1.cookingSteps.append(cooking)
        tableView.reloadData()
    }
    
    func buttonTapped1() {
        var prep = addPrepStep.prepStep!
        if prep.title == "" {
            return
        }
        if prep.notes == "Notes (Optional)" {
            prep.notes = nil
        }
        recipe1.prepSteps.append(prep)
        tableView.reloadData()
    }
    
    func buttonTapped() {
        var ing = addIngredient.ingredient!
        if ing.title == "" {
            return
        }
        if ing.notes == "Notes (Optional)" {
            ing.notes = nil
        }
        recipe1.ingredients.append(ing)
        tableView.reloadData()
    }
}
