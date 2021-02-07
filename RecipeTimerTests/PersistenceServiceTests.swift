//
//  PersistenceServiceTests.swift
//  RecipeTimerTests
//
//  Created by Sam McGarry on 2/6/21.
//  Copyright © 2021 Sam McGarry. All rights reserved.
//

@testable import RecipeCache
import XCTest
import CoreData

class PersistenceServiceTests: XCTestCase {

    var mockRecipe: Recipe!
    var mockIngredient: Ingredient!
    var mockPrepStep: PrepStep!
    var mockCookingStep: CookingStep!
    
    override func setUp() {
        super.setUp()
        
        //Initialize mock recipe steps
        mockIngredient = Ingredient(title: "Tomatoes", qnty: "2", notes: "Use Plum Tomatoes")
        mockPrepStep = PrepStep(title: "Dice Tomatoes", notes: "Be careful, knife is sharp!")
        mockCookingStep = CookingStep(title: "Cook Tomatoes", timeUltimatum: "00:03:00")
        
        //Initialize mock recipe, with mock steps from above
        mockRecipe = Recipe(image: images.chickensoup, title: "Test Recipe", ingredients: [mockIngredient], prepSteps: [mockPrepStep], cookingSteps: [mockCookingStep], id: "01", dateCreated: "05/05/05")
    }
    
    override func tearDown() {
        //Set variables to nil for next round of testing
        mockIngredient = nil
        mockPrepStep = nil
        mockCookingStep = nil
        mockRecipe = nil
        super.tearDown()
    }
    
    // Tests if the "Retrieve" functions within the Persistence Service do not return nil
    func testDoesNotReturnNil(){
        XCTAssertNotNil(PersistenceService.retrieveRecipes())
    }
    
    // Tests functionality of both "Save" and "Retrieve" PersistenceService functions
    func testSaveAndRetrieveRecipes() {
        
        //Save mock recipe to CoreData stack
        PersistenceService.saveNewRecipe(recipe1: mockRecipe)
        
        //Retrieve recipes from CoreData stack
        let retrievedRecipes = PersistenceService.retrieveRecipes()
        
        //Assign first retrieved Recipe
        let retrievedRecipe = retrievedRecipes.first
        
        //Assert retrieved Recipe values are equal to mock Recipe values
        XCTAssertEqual(retrievedRecipe!.title, mockRecipe.title)
        XCTAssertEqual(retrievedRecipe!.image.pngData(), mockRecipe.image.pngData())
        
        //Check Ingredients
        XCTAssertEqual(retrievedRecipe!.ingredients.first?.title, mockRecipe.ingredients.first?.title)
        XCTAssertEqual(retrievedRecipe!.ingredients.first?.qnty, mockRecipe.ingredients.first?.qnty)
        XCTAssertEqual(retrievedRecipe!.ingredients.first?.notes, mockRecipe.ingredients.first?.notes)
        
        //Check Prep Steps
        XCTAssertEqual(retrievedRecipe!.prepSteps.first?.title, mockRecipe.prepSteps.first?.title)
        XCTAssertEqual(retrievedRecipe!.prepSteps.first?.notes, mockRecipe.prepSteps.first?.notes)
        
        //Check Cooking Steps
        XCTAssertEqual(retrievedRecipe!.cookingSteps.first?.title, mockRecipe.cookingSteps.first?.title)
        XCTAssertEqual(retrievedRecipe!.cookingSteps.first?.timeUltimatum, mockRecipe.cookingSteps.first?.timeUltimatum)
    }
    
    // Tests that the context is saved following the execution of saveNewRecipe
    func testContextIsSavedAfterSavingRecipe() {
        
        /* Creates an expectation that sends a signal to the test case when a notification
        that the context was saved is recieved from the Core Data stack */
        expectation(forNotification: .NSManagedObjectContextDidSave, object: PersistenceService.context) { _ in
            return true
        }
        
        //Saves the mock Recipe to the CoreData stack
        PersistenceService.saveNewRecipe(recipe1: mockRecipe)
        
        //Test waits for signal that the Recipe saved, fails otherwise
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testUpdateRecipe() {
        //Save mock recipe to CoreData stack
        PersistenceService.saveNewRecipe(recipe1: mockRecipe)
        
        /* **NOTE** The save recipe function assigns a UUID() to a recipe upon a save,
        in order to get the correct id to update it, I must retrieve it from the Core Data
        stack. This is a unique situation to testing, as in the actual app there wouldn't be a
        new recipe saving and an update occurring to it at the same time. */
        
        //Retrieve recipes from CoreData stack
        var retrievedRecipes = PersistenceService.retrieveRecipes()
        
        //Assign first retrieved Recipe
        var retrievedRecipe = retrievedRecipes.first
        
        //Create updated Recipe variable
        var updatedRecipe = retrievedRecipe
        
        //Create new Recipe steps
        let newIngredient = Ingredient(title: "Potatoes", qnty: "3", notes: "Use small ones")
        let newPrepStep = PrepStep(title: "Slice potatoes", notes: "Be careful")
        let newCookingStep = CookingStep(title: "Boil Potatoes", timeUltimatum: "00:08:00")
        
        //Assign new values to updated Recipe variable, except for the id
        updatedRecipe?.title = "New Title"
        updatedRecipe?.dateCreated = "06/06/06"
        updatedRecipe?.image = images.salmon
        updatedRecipe?.ingredients = [newIngredient]
        updatedRecipe?.prepSteps = [newPrepStep]
        updatedRecipe?.cookingSteps = [newCookingStep]
        
        //Update recipe to CoreData stack
        PersistenceService.updateRecipe(recipe1: updatedRecipe!)
        
        //Retrieve recipes from Core Data stack
        retrievedRecipes = PersistenceService.retrieveRecipes()
        
        //Assign first retrieved Recipe
        retrievedRecipe = retrievedRecipes.first
        
        //Assert retrieved Recipe values are equal to mock Recipe values
        XCTAssertEqual(retrievedRecipe?.title, updatedRecipe?.title)
        XCTAssertEqual(retrievedRecipe?.image.pngData(), updatedRecipe?.image.pngData())
        
        //Check Ingredients
        XCTAssertEqual(retrievedRecipe!.ingredients.first?.title, updatedRecipe?.ingredients.first?.title)
        XCTAssertEqual(retrievedRecipe!.ingredients.first?.qnty, updatedRecipe?.ingredients.first?.qnty)
        XCTAssertEqual(retrievedRecipe!.ingredients.first?.notes, updatedRecipe?.ingredients.first?.notes)
        
        //Check Prep Steps
        XCTAssertEqual(retrievedRecipe!.prepSteps.first?.title, updatedRecipe?.prepSteps.first?.title)
        XCTAssertEqual(retrievedRecipe!.prepSteps.first?.notes, updatedRecipe?.prepSteps.first?.notes)
        
        //Check Cooking Steps
        XCTAssertEqual(retrievedRecipe!.cookingSteps.first?.title, updatedRecipe?.cookingSteps.first?.title)
        XCTAssertEqual(retrievedRecipe!.cookingSteps.first?.timeUltimatum, updatedRecipe?.cookingSteps.first?.timeUltimatum)
    }
    
    func testDeleteRecipe(){
        //Make sure Core Data stack is clear before performing test
        PersistenceService.deleteAllRecipes()
        
        //Save mock recipe to CoreData stack
        PersistenceService.saveNewRecipe(recipe1: mockRecipe)
        
        //Retrieve recipes from CoreData stack
        var retrievedRecipes = PersistenceService.retrieveRecipes()
        
        //Check that there is one recipe in returned array
        XCTAssertTrue(retrievedRecipes.count == 1)
        
        //Assign first retrieved Recipe
        let retrievedRecipe = retrievedRecipes.first
        
        //Delete recipe from CoreData stack
        PersistenceService.deleteRecipe(recipeID: retrievedRecipe!.id)
        
        //Retrieve recipes from CoreData stack
        retrievedRecipes = PersistenceService.retrieveRecipes()
        
        //Check that returned array is now empty
        XCTAssertTrue(retrievedRecipes.isEmpty)
    }
}
