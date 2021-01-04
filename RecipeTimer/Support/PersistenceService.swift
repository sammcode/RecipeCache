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
    
    private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
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
    
    static func retrieveRecipes() -> [Recipe] {
        var recipes: [Recipe] = []
        let managedContext = PersistenceService.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        
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
                
                let mIngredients = data.value(forKey: "ingredients") as? IngredientsData
                var ingredients: [Ingredient] = []
                if mIngredients != nil {
                    for ing in mIngredients!.ingredients {
                        ingredients.append(ing.convertToStruct())
                    }
                }
                
                let mPrepSteps = data.value(forKey: "prepsteps") as? PrepStepsData
                var prepsteps: [PrepStep] = []
                
                if mPrepSteps != nil {
                    for prep in mPrepSteps!.prepsteps {
                        prepsteps.append(prep.convertToStruct())
                    }
                }
                
                let mCookingSteps = data.value(forKey: "cookingsteps") as? CookingStepsData
                var cookingsteps: [CookingStep] = []
                
                if mCookingSteps != nil {
                    for cook in mCookingSteps!.cookingsteps {
                        cookingsteps.append(cook.convertToStruct())
                    }
                }
                
                recipes.append(Recipe(image: image, title: title, ingredients: ingredients, prepSteps: prepsteps, cookingSteps: cookingsteps, id: id, dateCreated: date))
                
            }
        } catch {
            print("failed")
        }
        return recipes
    }
    
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
    
    static func saveNewRecipe(recipe1: Recipe){
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
        
        let dateCreated = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateCreatedString = dateFormatter.string(from: dateCreated)
        
        recipe.setValue(mIngredients, forKeyPath: "ingredients")
        recipe.setValue(mPrepSteps, forKeyPath: "prepsteps")
        recipe.setValue(mCookingSteps, forKeyPath: "cookingsteps")
        
        recipe.setValue(title, forKeyPath: "title")
        recipe.setValue(image, forKeyPath: "image")
        recipe.setValue(id, forKey: "id")
        recipe.setValue(dateCreatedString, forKey: "dateCreated")
        
        PersistenceService.saveContext()
    }
    
    static func updateRecipe(recipe1: Recipe) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        fetchRequest.predicate = NSPredicate(format: "id = %@", recipe1.id)
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 { // Atleast one was returned
            
                // In my case, I only updated the first item in results
                let title = recipe1.title
                let image = recipe1.image.toData
                
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
                
                let mIngredients = IngredientsData(ingredients: ingredientsArray)
                let mPrepSteps = PrepStepsData(prepsteps: prepStepsArray)
                let mCookingSteps = CookingStepsData(cookingsteps: cookingStepsArray)
                
                let dateCreated = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                let dateCreatedString = dateFormatter.string(from: dateCreated)
                
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
        saveContext()
    }
    
    static func deleteRecipe(recipeID: String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Recipes")
        fetchRequest.predicate = NSPredicate(format: "id = %@", recipeID)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static func deleteAllRecipes(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Recipes")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static func importData(from url: URL) {
      // 1
      guard
        let data = try? Data(contentsOf: url),
        let recipe = try? JSONDecoder().decode(RecipeData.self, from: data)
        else { return }
      
      // 2
        print("ABOUT TO SAVE")
        saveNewRecipe(recipe1: recipe.convertToStruct())
      
      // 3
      try? FileManager.default.removeItem(at: url)
    }
    
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
