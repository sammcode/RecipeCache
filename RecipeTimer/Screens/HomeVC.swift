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

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        return tableView
    }()
    
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    let press = UIGestureRecognizer(target: self, action: #selector(handleLongPress))
    
    var recipes: [Recipe] = []
    var filteredRecipes: [Recipe] = []
    let cellSpacingHeight: CGFloat = 5
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recipes = PersistenceService.retrieveRecipes()
        recipes = organizeRecipes()
        
        UserDefaultsService.retrieve()
        
        updateUI()
    }
    
    func updateUI() {
        if recipes.isEmpty {
            let emptyStateView = RTEmptyStateView(message: "No recipes?\nAdd one by tapping the plus button.")
            emptyStateView.frame = view.bounds
            view.addSubview(emptyStateView)
        }else{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
    
    func organizeRecipes() -> [Recipe]{
        if Settings.organizeRecipes == "alphabetically" {
            return recipes.sorted { $0.title < $1.title }
        }else if Settings.organizeRecipes == "mostRecent" {
            return recipes.sorted { $0.dateCreated.compare($1.dateCreated) == .orderedDescending}
        }else {
            return recipes
        }
    }
    
    func configure() {
        title = "My Recipes"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newRecipeButtonTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        
        configureTableView()
        configureSearchController()
    }
    
    func configureSearchController(){
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a recipe"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        setTableViewDelegate()
        tableView.register(RecipeCell.self, forCellReuseIdentifier: Cells.recipeCell)
        
        
        //tableView.addGestureRecognizer(press)
        
        tableView.pin(to: view)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func newRecipeButtonTapped(){
        let newRecipe = NewRecipe(type: .new)
        newRecipe.delegate = self
        let navController = UINavigationController(rootViewController: newRecipe)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func settingsButtonTapped(){
        let settingsVC = SettingsVC()
        settingsVC.delegate = self
        let navController = UINavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        print("BLEHH")
        if longPress.state == UIGestureRecognizer.State.began {
            let touchPoint = longPress.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                share(recipe: recipes[indexPath.count])
            }
        }
    }
    
    func share(recipe: Recipe) {
      // Get latest changes
      //saveBook()
      
      // 1
        
    print("GOT HERE")
      guard
        let url = PersistenceService.exportToURL(recipe: recipe.convertToObject())
        else { return }
      
      // 2
      let activity = UIActivityViewController(
        activityItems: ["Check out this recipe!", url],
        applicationActivities: nil
      )
      //activity.popoverPresentationController?.barButtonItem = s

      // 3
      present(activity, animated: true, completion: nil)
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? filteredRecipes.count : recipes.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.recipeCell) as! RecipeCell
        let activeArray = isSearching ? filteredRecipes : recipes
        let recipe = activeArray[indexPath.section]
        cell.recipe = recipe
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 370
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let recipeListVC = RecipeListVC()
        let activeArray = isSearching ? filteredRecipes : recipes
        
        //share(recipe: activeArray[indexPath.section])
        
        recipeListVC.recipe = activeArray[indexPath.section]
        recipeListVC.delegate = self
        self.navigationController?.pushViewController(recipeListVC, animated: true)
        
    }
}

extension HomeVC: NewRecipeDelegate {
    func updateData(recipe1: Recipe, updateType: recipesArrayUpdate) {
        recipes.append(recipe1)
        updateUI()
    }
}

extension HomeVC: SettingsVCDelegate {
    func updateData() {
        recipes = organizeRecipes()
        tableView.reloadData()
    }
}

extension HomeVC: RecipeListVCDelegate {
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

extension HomeVC: UISearchResultsUpdating {
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
