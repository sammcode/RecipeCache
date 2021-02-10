//
//  HomeVC.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 5/3/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UIViewController {

    //Declare tableview used to display recipes
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        return tableView
    }()
    
    //Declare long press gesture recognizer, part of the sharing feature currently in development
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    
    //Declare variables to be used in scope of the class
    var recipes: [Recipe] = []
    var filteredRecipes: [Recipe] = []
    let cellSpacingHeight: CGFloat = 5
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //Override viewWillAppear to perform specifc actions before view appears on screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get recipes from CoreData and assign them to a local array
        recipes = PersistenceService.retrieveRecipes()
        
        //Organize the recipes accordingly
        recipes = organizeRecipes()
        
        //Retrieve saved user preferences/settings
        UserDefaultsService.retrieve()
        
        //Update the UI with the data
        updateUI()
    }
    
    //Updates the UI, a.k.a. the main tableview
    func updateUI() {
        //Checks if the local recipes array is empty, if so it displays the empty state view
        if recipes.isEmpty {
            let emptyStateView = RTEmptyStateView(message: ErrorMessages.noRecipes)
            emptyStateView.frame = view.bounds
            view.addSubview(emptyStateView)
        }else{
            //Otherwise, it reloads the tableview data, and brings the tableview to the front
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
    
    //Organizes the recipes based on user preferences, returns the organized recipes as a new array
    func organizeRecipes() -> [Recipe]{
        if Settings.organizeRecipes == "alphabetically" {
            //If set to "alphabetically", the function organizes alphabetically by the title of the recipe
            return recipes.sorted { $0.title < $1.title }
        }else if Settings.organizeRecipes == "mostRecent" {
            //If set to "mostRecent", the function organizes by most recently created recipes
            return recipes.sorted { $0.dateCreated.compare($1.dateCreated) == .orderedDescending}
        }else {
            return recipes
        }
    }
    
    //Configures some properties and calls all configure functions
    func configure() {
        //Set title
        title = "My Recipes"
        
        //Set background color to system background, allowing dark mode to be implemented
        view.backgroundColor = .systemBackground
        
        //Creates the "Add" button in the navigation bar allows the user to create a new recipe
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newRecipeButtonTapped))
        
        //Creates the "Settings" button in the navigation bar 0
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        
        //Calls configure functions
        configureTableView()
        configureSearchController()
    }
    
    //Configures the search controller used to search for specific recipes
    func configureSearchController(){
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a recipe"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    //Configures the properties for the main tableview
    func configureTableView(){
        //Adds the tableview as a subview
        view.addSubview(tableView)
        
        //Calls the function that sets the tablview delegate
        setTableViewDelegate()
        
        //Registers the custom reusable recipe cell used to display the recipes
        tableView.register(RecipeCell.self, forCellReuseIdentifier: Cells.recipeCell)
        
        //Pins the tableview to the view
        tableView.pin(to: view)
    }

    //Sets the tableview delegate and datasource to self
    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //Creates a NewRecipe ViewController, sets the delegate, and presents it as a root navigation controller
    @objc func newRecipeButtonTapped(){
        let newRecipe = NewRecipe(type: .new)
        newRecipe.delegate = self
        let navController = UINavigationController(rootViewController: newRecipe)
        self.present(navController, animated: true, completion: nil)
    }
    
    //Creates a SettingsVC ViewController, sets the delegate, and presents it as a root navigation controller
    @objc func settingsButtonTapped(){
        let settingsVC = SettingsVC()
        settingsVC.delegate = self
        let navController = UINavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    //Handles the long press gesture on a recipe cell, calling the share function. This is not currently used within the app
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if longPress.state == UIGestureRecognizer.State.began {
            let touchPoint = longPress.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                share(recipe: recipes[indexPath.count])
            }
        }
    }
    
    //Takes a Recipe struct as a parameter, presents a UIActivityViewController that enables user to share recipe.
    //Not currently implemented within the app.
    func share(recipe: Recipe) {
        //Creates a url by calling the PersistenceService exportToURL function
        guard
            let url = PersistenceService.exportToURL(recipe: recipe.convertToObject())
        else { return }
        
        //Declares the UIActivityViewController, sets the activity items
        let activity = UIActivityViewController(
            activityItems: ["Check out this recipe!", url],
            applicationActivities: nil
        )
        
        //Presents the UIActivityViewController
        present(activity, animated: true, completion: nil)
    }
}

//Extension that conforms HomeVC to UITableViewDelegate, UITableViewDataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    //Sets the number of sections in the tableview based on whether or not the user is currently searching
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? filteredRecipes.count : recipes.count
    }

    //Sets the number of rows in the section to 1
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Sets the height for header in a section to the cellSpacingHeight constant
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    //Creates a empty headerview for the header in a section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //Sets the type of cell to be used in the tableview, and the recipe data to be used within it
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.recipeCell) as! RecipeCell
        let activeArray = isSearching ? filteredRecipes : recipes
        let recipe = activeArray[indexPath.section]
        cell.recipe = recipe
        return cell
    }
    
    //Sets the row height based on the the length of the recipe title
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let activeArray = isSearching ? filteredRecipes : recipes
        if activeArray[indexPath.section].title.count >= 27 {
            return 390
        }else {
            return 370
        }
    }
    
    //Handles a tap on a recipe cell, creates an instance of RecipeListVC, sets the delegate and the recipe data, and pushes the new ViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipeListVC = RecipeListVC()
        let activeArray = isSearching ? filteredRecipes : recipes
        recipeListVC.recipe = activeArray[indexPath.section]
        recipeListVC.delegate = self
        self.navigationController?.pushViewController(recipeListVC, animated: true)
    }
}

//Conforms HomeVC to NewRecipeDelegate
extension HomeVC: NewRecipeDelegate {
    //Takes a Recipe struct and recipesArrayUpdate enum as parameters, appends the new recipe to the local array, and updates the UI
    func updateData(recipe1: Recipe, updateType: recipesArrayUpdate) {
        recipes.append(recipe1)
        updateUI()
    }
}

//Conforms HomeVC to SettingsVCDelegate
extension HomeVC: SettingsVCDelegate {
    //Sets the local array to a reorganized array of recipes, reloads the tableview data
    func updateData() {
        recipes = organizeRecipes()
        tableView.reloadData()
    }
}

//Conforms HomeVC to RecipeListVCDelegate
extension HomeVC: RecipeListVCDelegate {
    
    //Takes a Recipe struct and recipesArrayUpdate enum as parameters, updates or removes a recipe from local array based on input parameter, then reloads tableview data
    func updateRecipes(recipe: Recipe, updateType: recipesArrayUpdate) {
        switch updateType {
        case .update:
            if let x = recipes.firstIndex(where: {$0.id == recipe.id}){
                recipes[x] = recipe
            }
        case .remove:
            if let x = recipes.firstIndex(where: {$0.id == recipe.id}){
                recipes.remove(at: x)
            }
        }
        tableView.reloadData()
    }
}

//Conforms HomeVC to UISearchResultsUpdating
extension HomeVC: UISearchResultsUpdating {
    
    //Takes a UISearchController as a parameter and updates the results based on the searchbar text
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredRecipes.removeAll()
            tableView.reloadData()
            isSearching = false
            return
        }
        isSearching = true
        filteredRecipes = recipes.filter { $0.title.lowercased().contains(filter.lowercased())}
        tableView.reloadData()
    }
}
