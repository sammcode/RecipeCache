//
//  NewRecipe.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 5/7/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit
import CoreData
import PhotosUI

//Declares the protocol for NewRecipe and conforms it to class
protocol NewRecipeDelegate: class {
    func updateData(recipe1: Recipe, updateType: recipesArrayUpdate)
}

//Enum that helps differentiate the cases for which NewRecipe would be used. Either for creating a new recipe or editing one that has already been created.
enum recipeEditType {
    case new
    case edit
}

class NewRecipe: UIViewController {

    //Declares the main tableview that will display all the custom cells
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    //Declares local recipe variable to be assigned data
    public var recipe1: Recipe = Recipe(image: images.selectImage, title: "New Recipe", ingredients: [Ingredient](), prepSteps: [PrepStep](), cookingSteps: [CookingStep](), id: "", dateCreated: "")

    //Declares the height of the spacing between custom cells
    let cellSpacingHeight: CGFloat = 5

    //Declares the delegate that allows other viewcontroller to communicate with RecipeListVC
    weak var delegate: NewRecipeDelegate!

    //Declares the variable that stores the ViewController use case
    var pageType: recipeEditType!

    //Declares a variable to hold an instance of the AddIngredientPopUp view
    var addIngredient = AddIngredientPopUp()

    //Declares a variable to hold an instance of the AddPrepStepPopUp view
    var addPrepStep = AddPrepStepPopUp()

    //Declares a variable to hold an instance of the AddCookingStepPopUp view
    var addCookingStep = AddCookingStepPopUp()

    //Declares a variable to hold an instance of the EditTitlePopUp view
    var editTitle = EditTitlePopUp()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    //Takes a recipeEditType enum as a parameter, and initalizes the NewRecipeVC appropriately
    convenience init(type: recipeEditType){
        self.init()
        switch type {
        case .edit:
            //Declares a delete button that is only available on the editing version of this VC
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

    //Function that's called when the cancel button is tapped
    @objc func cancelButtonTapped() {
        //Dismisses itself
        self.dismiss(animated: true)
    }

    //Function that's called when the delete button is tapped
    @objc func deleteButtonTapped() {
        //Deletes the recipe from the CoreData stack
        PersistenceService.deleteRecipe(recipeID: recipe1.id)

        //Calls the updataData function via the delegate
        delegate.updateData(recipe1: recipe1, updateType: .remove)

        //Dismisses itself
        self.dismiss(animated: true)
    }

    //Configures some general properties of the ViewController
    func configure() {
        //Declares the cancel button for the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))

        //Sets the background color
        view.backgroundColor = .systemBackground

        //Configures the tableview
        configureTableView()

        //Sets the title for the VC to the title of the recipe
        title = recipe1.title
    }

    //Sets up the constraints for the tableview
    func setUpTableViewConstraints(){
        //Declares a constant for the width, based on whether or not the device type in use is an iPad
        let width = DeviceType.isiPad || DeviceType.isiPadPro ? ScreenSize.width * 0.7 : ScreenSize.width
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: ScreenSize.height * 0.9).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    //Configures properties for the tableview
    func configureTableView() {
        //Adds the tableview as a subview
        view.addSubview(tableView)
        //Pins it to the view
        tableView.pin(to: view)
        //Sets up the delegate and datasource
        setTableViewDelegate()
        //Registers all the resusable cells that the tableview will be using
        tableView.register(IngredientCell.self, forCellReuseIdentifier: Cells.ingredientCell)
        tableView.register(PrepStepCell.self, forCellReuseIdentifier: Cells.prepStepCell)
        tableView.register(CookingStepCell.self, forCellReuseIdentifier: Cells.cookingStepCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Cells.imageCell)
        tableView.register(TitleCell.self, forCellReuseIdentifier: Cells.titleCell)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: Cells.buttonCell)
    }

    //Sets up the tableview delegate and datasource
    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }

    //Presents old UIImagePicker for devices running IOS13 or lower
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

    //Uses the new PHPicker if device is updated to IOS14
    func chooseImageIOS14(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
}

//Conforms NewRecipe to UITableViewDelegate, UITableViewDataSource, and ButtonCellDelegate
extension NewRecipe: UITableViewDelegate, UITableViewDataSource{
    //Sets the number of sections in the tableview.
    func numberOfSections(in tableView: UITableView) -> Int {
        print( recipe1.ingredients.count + recipe1.prepSteps.count)
        return recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 9
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

    //Performs an action after a user selects a row, based on the indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If the row tapped was at the indexPath equal to 0, the EditTitlePopUp is is overlayed onto the view
        if indexPath.section == 0{
            editTitle = EditTitlePopUp()
            view.addSubview(editTitle)
            editTitle.editTitleDelegate = self
        }
        //If the row tapped was at the indexPath equal to 1, the appropriate function for choosing an image is called depending on the iOS version
        if indexPath.section == 1{
            if #available(iOS 14.0, *) {
                chooseImageIOS14()
            } else {
                chooseImage()
            }
        }
        //If the row tapped was at the indexPath equal to the number of ingredients in the recipe + 3, the AddIngredientPopUp is overlayed onto the view.
        if indexPath[0] == recipe1.ingredients.count + 3{
            addIngredient = AddIngredientPopUp()
            view.addSubview(addIngredient)
            addIngredient.ingredientDelegate = self
            
        }
        //If the row tapped was at the indexPath equal to the number of ingredients + the number prepsteps + 5, the AddPrepStepPopUp is overlayed onto the view.
        if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + 5{
            addPrepStep = AddPrepStepPopUp()
            view.addSubview(addPrepStep)
            addPrepStep.addPrepStepDelegate = self
        }
        //If the row tapped was at the indexPath equal to the number of ingredients + the number prepsteps + the number of cooking steps + 7, the AddCookingStepPopUp is overlayed onto the view.
        if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7{
            addCookingStep = AddCookingStepPopUp()
            view.addSubview(addCookingStep)
            addCookingStep.cookingStepDelegate = self
        }
        //If the row tapped was at the indexPath equal to the number of ingredients + the number prepsteps + the number of cooking steps + 8, depending on the pageType the recipe is either updated or created in the CoreData stack.
        if indexPath[0] == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 8{

            //Either updates or saves a new recipe to CoreData based on the pageType
            switch pageType {
            case .edit:
                PersistenceService.updateRecipe(recipe1: recipe1)
            case .new:
                PersistenceService.saveNewRecipe(recipe1: recipe1)
            case .none:
                return
            }

            //Declares a constant to represent the current date
            let dateCreated = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let dateCreatedString = dateFormatter.string(from: dateCreated)

            //Assigns the String constant representing the current date to the local recipe variable
            recipe1.dateCreated = dateCreatedString

            //Updates the data in the ViewController presenting NewRecipeVC
            delegate.updateData(recipe1: recipe1, updateType: .update)

            //Dismisses itself
            self.dismiss(animated: true, completion: nil)
        }
    }

    //Determines and sets the correct reusable cell based on the indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //Returns a title cell, and sets the title to the title of the recipe
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = recipe1.title + " 🔧"
            cell.fontSize = 36
            return cell
        }

        //Returns an image cell to display the image assigned to the recipe
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.imageCell) as! ImageCell
            cell.img = recipe1.image
            return cell
        }

        //Returns a title cell, and sets the title to "Ingredients"
        if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Ingredients"
            return cell
        }

        //Returns an Ingredient cell, and sets the ingredient data accordingly
        if indexPath.section > 2 && indexPath.section < (recipe1.ingredients.count + 3){
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.ingredientCell) as! IngredientCell
            let ingredient = recipe1.ingredients[indexPath.section - 3]
            cell.ingredient = ingredient
            return cell
        }

        //Returns a button cell and sets the title to "Add Ingredient"
        if indexPath.section == recipe1.ingredients.count + 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.buttonCell)   as! ButtonCell
            cell.title = "Add Ingredient"
            return cell
        }

        //Returns a title cell, and sets the title to "Prep Steps"
        if indexPath.section == recipe1.ingredients.count + 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Prep Steps"
            return cell
        }

        //Returns a Prep Step cell, and sets the prep step data accordingly
        if indexPath.section > recipe1.ingredients.count + 4 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.prepStepCell) as! PrepStepCell
            let prepStep = recipe1.prepSteps[indexPath.section - recipe1.ingredients.count - 5]
            cell.prepStep = prepStep
            return cell
        }

        //Returns a button cell and sets the title to "Add Prep Step"
        if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.buttonCell)   as! ButtonCell
            cell.title = "Add Prep Step"
            return cell
        }

        //Returns a title cell, and sets the title to "Cooking Steps"
        if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + 6{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.titleCell) as! TitleCell
            cell.title = "Cooking Steps"
            return cell
        }

        //Returns a button cell and sets the title to "Add Cooking Step"
        if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.buttonCell)   as! ButtonCell
            cell.title = "Add Cooking Step"
            return cell
        }

        //Returns a button cell and sets the title based on the pageType
        if indexPath.section == recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 8{

            //Declares a new ButtonCell
            let cell = ButtonCell(style: .default, reuseIdentifier: Cells.buttonCell, color: UIColor(named: "background")!)
            var buttonTitle = ""

            //Sets buttonTitle based on the pageType
            switch pageType {
            case .edit:
                buttonTitle = "Save Recipe"
            case .new:
                buttonTitle = "Create Recipe"
            case .none:
                buttonTitle = "Create Recipe"
            }

            //Assigns buttonTitle to the cell's title
            cell.title = buttonTitle

            return cell
        }

        //Returns a Cooking Step cell, and sets the cooking step data accordingly
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.cookingStepCell) as! CookingStepCell
        let cookingStep = recipe1.cookingSteps[indexPath.section - recipe1.prepSteps.count - recipe1.ingredients.count - 7]

        cell.cookingStep = cookingStep
        return cell
    }

    //Returns the appropriate row height based on the type of cell being displayed. This is determined based on specific sections in the index path.
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

    //Sets the editing style for a row based on it's indexPath
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section > 2 && indexPath.section < (recipe1.ingredients.count + 3) || (indexPath.section > recipe1.ingredients.count + 4 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + 5) || (indexPath.section > recipe1.ingredients.count + recipe1.prepSteps.count + 6 && indexPath.section < recipe1.ingredients.count + recipe1.prepSteps.count + recipe1.cookingSteps.count + 7){
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
}

//Conforms NewRecipe to AddIngredientDelegate, AddPrepStepDelegate, AddCookingStepDelegate, EditTitleDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, and PHPickerViewControllerDelegate
extension NewRecipe: AddIngredientDelegate, AddPrepStepDelegate, AddCookingStepDelegate, EditTitleDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate{

    //Called when a user is finished picking an image in a UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Declares a new image
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage

        //Updates the local recipe with the new selected image
        recipe1.image = image

        //Reloads the tableview data
        tableView.reloadData()

        //Dismisses the picker
        picker.dismiss(animated: true, completion: nil)
    }

    //Called when a user cancels an image picking session in a UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Dismisses the picker
        picker.dismiss(animated: true, completion: nil)
    }

    //Called when a user is finished picking an image in a PHPickerViewController
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        //Dismisses the picker
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        //Updates the local recipe with the new selected image, making sure it has the correct orientation
                        if let updatedImage = image.updateImageOrientionUpSide() {
                            self.recipe1.image = updatedImage
                        } else {
                            self.recipe1.image = image
                        }
                        //Reloads the tableview data
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }

    //Called when the edit title button is tapped
    func editTitleButtonTapped(){
        //Declares a new title constant with the data from the EditTitlePopUp
        let title = editTitle.title!
        //Checks if the title is an empty string, if so it exits the function
        if title == ""{
            return
        }
        //Updates the local recipe with the new title
        recipe1.title = title
        //Reloads the tableview data
        tableView.reloadData()
    }

    //Called when the add Ingredient button is tapped
    func addIngredientButtonTapped(){
        //Declares a new Ingredient from the AddIngredientPopUp
        var ing = addIngredient.ingredient!
        //Checks if the title is an empty string, if so it exits the function
        if ing.title == "" {
            return
        }
        //Checks if no notes were inputted, if so notes is set to nil on the new ingredient
        if ing.notes == "Notes (Optional)" {
            ing.notes = nil
        }
        //Appends the new Ingredient to the local recipe ingredients array
        recipe1.ingredients.append(ing)
        //Reloads the tableview data
        tableView.reloadData()
    }

    //Called when the add PrepStep button is tapped
    func addPrepStepButtonTapped(){
        //Declares a new PrepStep from the AddPrepStepPopUp
        var prep = addPrepStep.prepStep!
        //Checks if the title is an empty string, if so it exits the function
        if prep.title == "" {
            return
        }
        //Checks if no notes were inputted, if so notes is set to nil on the new prep step
        if prep.notes == "Notes (Optional)" {
            prep.notes = nil
        }
        //Appends the new PrepStep to the local recipe prepsteps array
        recipe1.prepSteps.append(prep)
        //Reloads the tableview data
        tableView.reloadData()
    }

    //Called when the add CookingStep button is tapped
    func addCookingStepButtonTapped(){
        //Declares a new CookingStep from the AddCookingStepPopUp
        let cooking = addCookingStep.cookingStep!
        //Checks if the title is an empty string, if so it exits the function
        if cooking.title == "" {
            return
        }
        //Appends the new CookingStep to the local recipe cookingsteps array
        recipe1.cookingSteps.append(cooking)
        //Reloads the tableview data
        tableView.reloadData()
    }
}
