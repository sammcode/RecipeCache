//
//  PersistenceService.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 6/15/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersistenceService {
    
    init() {}
    
    //Creates the context variable, using the persistentContainers
    //viewContext. Drawback is that viewContext is on main thread by
    //default, so might block main thread if saving a lot of recipes at once.
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //Creates the persistent container used in accessing the xcdatamodel
    static var persistentContainer: NSPersistentContainer = {
        IngredientsDataValueTransformer.register()
        PrepStepsDataValueTransformer.register()
        CookingStepsDataValueTransformer.register()
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //Saves the context if it has changes
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //Fetches all recipes from the CoreData stack, and returns them as an array of Recipe structs
    static func retrieveRecipes() -> [Recipe] {
        //Declare array that will be returned
        var recipes: [Recipe] = []
        
        //Declare constants used in the fetch request
        let managedContext = PersistenceService.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        
        //Ensures that the class names are set to the correct string, otherwise NSKeyedUnarchiver has an error. I had to do this after changing the name of the app
        NSKeyedUnarchiver.setClass(IngredientsData.self, forClassName: "RecipeTimer.IngredientsData")
        NSKeyedUnarchiver.setClass(PrepStepsData.self, forClassName: "RecipeTimer.PrepStepsData")
        NSKeyedUnarchiver.setClass(CookingStepsData.self, forClassName: "RecipeTimer.CookingStepsData")
        
        do {
            
            //Tries to the fetch request through managed context
            let result = try managedContext.fetch(fetchRequest)
            
            //Iterates through the results, setting key values from the NSManagedObject to constants
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as? String  ?? "No title"
                let imageData = data.value(forKey: "image") as? Data
                let id = data.value(forKey: "id") as? String ?? ""
                let date = data.value(forKey: "dateCreated") as? String ?? ""
                var image = images.lasagna
                
                if imageData != nil{
                    image = UIImage(data: imageData!) ?? images.chickensoup
                }
                
                //Sets transformable data to constant as IngredientsData Object, then coverts it to an array of Ingredient Structs
                let mIngredients = data.value(forKey: "ingredients") as? IngredientsData
                var ingredients: [Ingredient] = []
                if mIngredients != nil {
                    for ing in mIngredients!.ingredients {
                        ingredients.append(ing.convertToStruct())
                    }
                }
                
                //Sets transformable data to constant as PrepStepsData Object, then coverts it to an array of PrepStep Structs
                let mPrepSteps = data.value(forKey: "prepsteps") as? PrepStepsData
                var prepsteps: [PrepStep] = []
                
                if mPrepSteps != nil {
                    for prep in mPrepSteps!.prepsteps {
                        prepsteps.append(prep.convertToStruct())
                    }
                }
                
                //Sets transformable data to constant as CookingStepsData Object, then coverts it to an array of CookingStep Structs
                let mCookingSteps = data.value(forKey: "cookingsteps") as? CookingStepsData
                var cookingsteps: [CookingStep] = []
                
                if mCookingSteps != nil {
                    for cook in mCookingSteps!.cookingsteps {
                        cookingsteps.append(cook.convertToStruct())
                    }
                }
                
                //Creates a new Recipe struct with all the converted data from above, and appends it to the recipes array
                recipes.append(Recipe(image: image, title: title, ingredients: ingredients, prepSteps: prepsteps, cookingSteps: cookingsteps, id: id, dateCreated: date))
                
            }
        } catch {
            print("failed")
        }
        return recipes
    }
    
    //Retrieves a specific recipe from the Core Data stack and returns it as a Recipe struct.
    //Not actually used in the app right now, but may prove to be useful in the future.
    static func retrieveRecipe(recipeID: String) -> Recipe {
        var recipe: Recipe!
        let managedContext = PersistenceService.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        fetchRequest.predicate = NSPredicate(format: "id = %@", recipeID)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as? String  ?? "No title"
                let imageData = data.value(forKey: "image") as? Data
                let id = data.value(forKey: "id") as? String ?? ""
                let date = data.value(forKey: "dateCreated") as? String ?? ""
                var image = images.lasagna
                
                if imageData != nil{
                    image = UIImage(data: imageData!) ?? images.chickensoup
                }
                
                let mIngredients = data.value(forKey: "ingredients") as! IngredientsData
                var ingredients: [Ingredient] = []
                for ing in mIngredients.ingredients {
                    ingredients.append(ing.convertToStruct())
                }
            
                let mPrepSteps = data.value(forKey: "prepsteps") as! PrepStepsData
                var prepsteps: [PrepStep] = []
                for prep in mPrepSteps.prepsteps {
                    prepsteps.append(prep.convertToStruct())
                }
                
                let mCookingSteps = data.value(forKey: "cookingsteps") as! CookingStepsData
                var cookingsteps: [CookingStep] = []
                for cook in mCookingSteps.cookingsteps {
                    cookingsteps.append(cook.convertToStruct())
                }
                
                recipe = Recipe(image: image, title: title, ingredients: ingredients, prepSteps: prepsteps, cookingSteps: cookingsteps, id: id, dateCreated: date)
            }
        } catch {
            print("failed")
        }
        return recipe
    }
    
    //Takes a Recipe struct as a parameter, and saves it to the Core Data stack
    static func saveNewRecipe(recipe1: Recipe) {
        
        //Ensures that the class names are set to the correct string, otherwise NSKeyedArchiver has an error. I had to do this after changing the name of the app
        NSKeyedArchiver.setClassName("RecipeTimer.IngredientsData", for: IngredientsData.self)
        NSKeyedArchiver.setClassName("RecipeTimer.PrepStepsData", for: PrepStepsData.self)
        NSKeyedArchiver.setClassName("CookingStepsData", for: CookingStepsData.self)
        
        //Declares constants used to save the recipe to Core Data
        let managedObjectContext = PersistenceService.context
        let entityRecipe = NSEntityDescription.entity(forEntityName: "Recipes", in: managedObjectContext)!
        
        let title = recipe1.title
        let image = recipe1.image.toData
        let id = UUID().uuidString
        
        var ingredientsArray: [IngredientData] = []
        var prepStepsArray: [PrepStepData] = []
        var cookingStepsArray: [CookingStepData] = []
        
        //Converts the array of Ingredient structs to IngredientData objects
        for ing in recipe1.ingredients{
            let newIngredient = IngredientData(title: ing.title, qnty: ing.qnty, notes: ing.notes)
            ingredientsArray.append(newIngredient)
        }
        
        //Converts the array of PrepStep structs to PrepStepData objects
        for prep in recipe1.prepSteps{
            let newPrepStep = PrepStepData(title: prep.title, notes: prep.notes)
            prepStepsArray.append(newPrepStep)
        }
        
        //Converts the array of CookingStep structs to CookingStepData objects
        for cook in recipe1.cookingSteps{
            let newCookingStep = CookingStepData(title: cook.title, timeUltimatum: cook.timeUltimatum)
            cookingStepsArray.append(newCookingStep)
        }
        
        //Declares recipe as Recipes object, which conforms to NSManagedObject
        let recipe = NSManagedObject(entity: entityRecipe, insertInto: managedObjectContext) as! Recipes
        
        //Converts arrays of Recipe steps data to IngredientsData, PrepStepsData, and CookingStepsData objects. This allows me to save each of these arrays as Transformable data types under the Recipes entity in CoreData.
        let mIngredients = IngredientsData(ingredients: ingredientsArray)
        let mPrepSteps = PrepStepsData(prepsteps: prepStepsArray)
        let mCookingSteps = CookingStepsData(cookingsteps: cookingStepsArray)
        
        //Declares a constant for the current date
        let dateCreated = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateCreatedString = dateFormatter.string(from: dateCreated)
        
        //Sets all the key values to the constants declared above for the recipe NSManagedObject
        recipe.setValue(mIngredients, forKeyPath: "ingredients")
        recipe.setValue(mPrepSteps, forKeyPath: "prepsteps")
        recipe.setValue(mCookingSteps, forKeyPath: "cookingsteps")
        
        recipe.setValue(title, forKeyPath: "title")
        recipe.setValue(image, forKeyPath: "image")
        recipe.setValue(id, forKey: "id")
        recipe.setValue(dateCreatedString, forKey: "dateCreated")
        
        //Saves the context, storing the newly created recipe in CoreData
        PersistenceService.saveContext()
    }
    
    //Takes a Recipe struct as a parameter and updates it in the CoreData stack accordingly
    static func updateRecipe(recipe1: Recipe) {
        
        //Declares the fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        
        //Declares the fetch request predicate to be the "id" key, and sets it to the id of the inputted Recipe struct
        fetchRequest.predicate = NSPredicate(format: "id = %@", recipe1.id)
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            
            //Checks atleast one recipe was returned
            if results?.count != 0 { 
            
                //Declares constants used to save the recipe to Core Data
                let title = recipe1.title
                let image = recipe1.image.toData
                
                var ingredientsArray: [IngredientData] = []
                var prepStepsArray: [PrepStepData] = []
                var cookingStepsArray: [CookingStepData] = []
                
                //Converts the array of Ingredient structs to IngredientData objects
                for ing in recipe1.ingredients{
                    let newIngredient = IngredientData(title: ing.title, qnty: ing.qnty, notes: ing.notes)
                    ingredientsArray.append(newIngredient)
                }
                
                //Converts the array of PrepStep structs to PrepStepData objects
                for prep in recipe1.prepSteps{
                    let newPrepStep = PrepStepData(title: prep.title, notes: prep.notes)
                    prepStepsArray.append(newPrepStep)
                }
                
                //Converts the array of CookingStep structs to CookingStepData objects
                for cook in recipe1.cookingSteps{
                    let newCookingStep = CookingStepData(title: cook.title, timeUltimatum: cook.timeUltimatum)
                    cookingStepsArray.append(newCookingStep)
                }
                
                //Converts arrays of Recipe steps data to IngredientsData, PrepStepsData, and CookingStepsData objects. This allows me to save each of these arrays as Transformable data types under the Recipes entity in CoreData.
                let mIngredients = IngredientsData(ingredients: ingredientsArray)
                let mPrepSteps = PrepStepsData(prepsteps: prepStepsArray)
                let mCookingSteps = CookingStepsData(cookingsteps: cookingStepsArray)
                
                //Declares a constant for the current date
                let dateCreated = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                let dateCreatedString = dateFormatter.string(from: dateCreated)
                
                //Updates the key values with all the constants from above
                results![0].setValue(mIngredients, forKeyPath: "ingredients")
                results![0].setValue(mPrepSteps, forKeyPath: "prepsteps")
                results![0].setValue(mCookingSteps, forKeyPath: "cookingsteps")
                
                results![0].setValue(title, forKeyPath: "title")
                results![0].setValue(image, forKeyPath: "image")
                results![0].setValue(dateCreatedString, forKey: "dateCreated")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        //Saves the context, updating the recipe to CoreData
        saveContext()
    }
    
    //Takes a recipe's id as a parameter, and effectively deletes it from the Core Data stack
    static func deleteRecipe(recipeID: String){
        
        //Declares the fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Recipes")
        
        //Declares the fetch request predicate to be the "id" key, and sets it to the id of the inputted Recipe struct
        fetchRequest.predicate = NSPredicate(format: "id = %@", recipeID)
        
        //Declares the delete request
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        //Tries to execute the delete request, and then saves the context
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //Deletes all the recipes stored in CoreData
    //Not used within the app, but very useful for testing purposes
    static func deleteAllRecipes(){
        //Declares the fetch request for all Recipes entities
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Recipes")
        
        //Declares the delete request
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        //Attempts to execute the delete request, and the saves the context
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //Takes a URL as a parameter, decodes the JSON, and saves the recipe to CoreData
    //Not currently used within the app, part of a sharing feature currently in development
    static func importData(from url: URL) {
      // 1
      guard
        let data = try? Data(contentsOf: url),
        let recipe = try? JSONDecoder().decode(RecipeData.self, from: data)
        else { return }
      
      // 2
        saveNewRecipe(recipe1: recipe.convertToStruct())
      
      // 3
      try? FileManager.default.removeItem(at: url)
    }
    
    //Takes a RecipeData object as a parameter, converts the object to JSON, attempts to write it to a URL, and then returns that URL
    //Not currently used within the app, part of a sharing feature currently in development
    static func exportToURL(recipe: RecipeData) -> URL? {
      // 1
      guard let encoded = try? JSONEncoder().encode(recipe) else { return nil }
      
      // 2
      let documents = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
      ).first
        
        guard let path = documents?.appendingPathComponent("/\(recipe.title).rcp") else {
        return nil
      }
      
      // 3
      do {
        try encoded.write(to: path, options: .atomicWrite)
        return path
      } catch {
        print(error.localizedDescription)
        return nil
      }
    }
}
