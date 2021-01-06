//
//  Recipe.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/15/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Recipe{
    var image: UIImage
    var title: String
    var ingredients: [Ingredient]
    var prepSteps: [PrepStep]
    var cookingSteps: [CookingStep]
    var id: String
    var dateCreated: String
    
    func convertToObject() -> RecipeData{
        var ings: [IngredientData] = []
        var preps: [PrepStepData] = []
        var cooks: [CookingStepData] = []
        for ing in ingredients {
            ings.append(ing.convertToObject())
        }
        for prep in prepSteps {
            preps.append(prep.convertToObject())
        }
        for cook in cookingSteps {
            cooks.append(cook.convertToObject())
        }
        return RecipeData(title: self.title, image: image.toData!, ingredients: ings, prepSteps: preps, cookingSteps: cooks, id: self.id, dateCreated: self.dateCreated)
    }
}

struct Ingredient {
    var title: String
    var qnty: String?
    var notes: String?
    
    func convertToObject() -> IngredientData{
        return IngredientData(title: title, qnty: qnty, notes: notes)
    }
}

struct PrepStep {
    var title: String
    var notes: String?
    
    func convertToObject() -> PrepStepData{
        return PrepStepData(title: title, notes: notes)
    }
}

struct CookingStep {
    var title: String
    var timeUltimatum: String?
    
    func convertToObject() -> CookingStepData{
        return CookingStepData(title: title, timeUltimatum: timeUltimatum)
    }
}

public class RecipeData: NSObject, NSCoding, Codable {
    
    public var title: String = ""
    public var image: Data = Data()
    public var ingredients: [IngredientData] = []
    public var prepSteps: [PrepStepData] = []
    public var cookingSteps: [CookingStepData] = []
    public var id: String = ""
    public var dateCreated: String = ""
    
    enum Key:String {
        case title = "title"
        case image = "image"
        case ingredients = "ingredients"
        case prepsteps = "prepsteps"
        case cookingsteps = "cookingsteps"
        case id = "id"
        case dateCreated = "dateCreated"
    }
    
    init(title: String, image: Data, ingredients: [IngredientData], prepSteps: [PrepStepData], cookingSteps: [CookingStepData], id: String, dateCreated: String){
        self.title = title
        self.image = image
        self.ingredients = ingredients
        self.prepSteps = prepSteps
        self.cookingSteps = cookingSteps
        self.id = id
        self.dateCreated = dateCreated
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Key.title.rawValue)
        aCoder.encode(image, forKey: Key.image.rawValue)
        aCoder.encode(ingredients, forKey: Key.ingredients.rawValue)
        aCoder.encode(prepSteps, forKey: Key.prepsteps.rawValue)
        aCoder.encode(cookingSteps, forKey: Key.cookingsteps.rawValue)
        aCoder.encode(id, forKey: Key.id.rawValue)
        aCoder.encode(dateCreated, forKey: Key.dateCreated.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mTitle = aDecoder.decodeObject(forKey: Key.title.rawValue) as! String
        let mImage = aDecoder.decodeObject(forKey: Key.image.rawValue) as! Data
        let mIngredients = aDecoder.decodeObject(forKey: Key.ingredients.rawValue) as! [IngredientData]
        let mPrepSteps = aDecoder.decodeObject(forKey: Key.prepsteps.rawValue) as! [PrepStepData]
        let mCookingSteps = aDecoder.decodeObject(forKey: Key.cookingsteps.rawValue) as! [CookingStepData]
        let mId = aDecoder.decodeObject(forKey: Key.id.rawValue) as! String
        let mDateCreated = aDecoder.decodeObject(forKey: Key.dateCreated.rawValue) as! String
        
        self.init(title: mTitle, image: mImage, ingredients: mIngredients, prepSteps: mPrepSteps, cookingSteps: mCookingSteps, id: mId, dateCreated: mDateCreated)
    }
    
    func convertToStruct() -> Recipe{
        var ings: [Ingredient] = []
        var preps: [PrepStep] = []
        var cooks: [CookingStep] = []
        for ing in self.ingredients {
            ings.append(ing.convertToStruct())
        }
        for prep in self.prepSteps {
            preps.append(prep.convertToStruct())
        }
        for cook in self.cookingSteps {
            cooks.append(cook.convertToStruct())
        }
        return Recipe(image: UIImage(data: image)!, title: self.title, ingredients: ings, prepSteps: preps, cookingSteps: cooks, id: self.id, dateCreated: self.dateCreated)
    }
}

public class IngredientData: NSObject, NSSecureCoding, Codable{
    public static var supportsSecureCoding: Bool = true
    
    public var title: String = ""
    public var qnty: String?
    public var notes: String?
    
    enum Key:String {
        case title = "title"
        case qnty = "qnty"
        case notes = "notes"
    }
    
    init(title: String, qnty: String?, notes: String?){
        self.title = title
        self.qnty = qnty
        self.notes = notes
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Key.title.rawValue)
        aCoder.encode(qnty, forKey: Key.qnty.rawValue)
        aCoder.encode(notes, forKey: Key.notes.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mTitle = aDecoder.decodeObject(forKey: Key.title.rawValue) as! String
        let mQnty = aDecoder.decodeObject(forKey: Key.qnty.rawValue) as? String
        let mNotes = aDecoder.decodeObject(forKey: Key.notes.rawValue) as? String
        
        self.init(title: mTitle, qnty: mQnty, notes: mNotes)
    }
    
    func convertToStruct() -> Ingredient{
        return Ingredient(title: self.title, qnty: self.qnty, notes: self.notes)
    }
}

public class IngredientsData: NSObject, NSSecureCoding, Codable{
    public static var supportsSecureCoding: Bool = true
    
    public var ingredients: [IngredientData] = []
    
    enum Key:String{
        case ingredients = "ingredients"
    }
    
    init(ingredients: [IngredientData]) {
        self.ingredients = ingredients
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(ingredients, forKey: Key.ingredients.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mIngredients = aDecoder.decodeObject(of: [NSArray.self, IngredientData.self], forKey: Key.ingredients.rawValue) as! [IngredientData]? ?? []
        
        self.init(ingredients: mIngredients)
    }
}

public class PrepStepData: NSObject, NSSecureCoding, Codable{
    public static var supportsSecureCoding: Bool = true
    
    public var title: String = ""
    public var notes: String?
    
    enum Key:String {
        case title = "title"
        case notes = "notes"
    }
    
    init(title: String, notes: String?){
        self.title = title
        self.notes = notes
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Key.title.rawValue)
        aCoder.encode(notes, forKey: Key.notes.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mTitle = aDecoder.decodeObject(forKey: Key.title.rawValue) as! String
        let mNotes = aDecoder.decodeObject(forKey: Key.notes.rawValue) as? String
        
        self.init(title: mTitle, notes: mNotes)
    }
    
    func convertToStruct() -> PrepStep{
        return PrepStep(title: self.title, notes: self.notes)
    }
}

public class PrepStepsData: NSObject, NSSecureCoding, Codable{
    public static var supportsSecureCoding: Bool = true
    
    public var prepsteps: [PrepStepData] = []
    
    enum Key:String{
        case prepsteps = "prepsteps"
    }
    
    init(prepsteps: [PrepStepData]) {
        self.prepsteps = prepsteps
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(prepsteps, forKey: Key.prepsteps.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mPrepSteps = aDecoder.decodeObject(of: [NSArray.self, PrepStepData.self], forKey: Key.prepsteps.rawValue) as! [PrepStepData]? ?? []
        
        self.init(prepsteps: mPrepSteps)
    }
}

@objc(CookingStepData)
public class CookingStepData: NSObject, NSSecureCoding, Codable{
    public static var supportsSecureCoding: Bool = true
    
    public var title: String = ""
    public var timeUltimatum: String?
    
    enum Key:String {
        case title = "title"
        case timeUltimatum = "timeUltimatum"
    }
    
    init(title: String, timeUltimatum: String?){
        self.title = title
        self.timeUltimatum = timeUltimatum
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Key.title.rawValue)
        aCoder.encode(timeUltimatum, forKey: Key.timeUltimatum.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mTitle = aDecoder.decodeObject(forKey: Key.title.rawValue) as! String
        let mTimeUltimatum = aDecoder.decodeObject(forKey: Key.timeUltimatum.rawValue) as? String
        
        self.init(title: mTitle, timeUltimatum: mTimeUltimatum)
    }
    
    func convertToStruct() -> CookingStep{
        return CookingStep(title: self.title, timeUltimatum: self.timeUltimatum)
    }
}

@objc(CookingStepsData)
public class CookingStepsData: NSObject, NSSecureCoding, Codable {
    
    public static var supportsSecureCoding: Bool = true
    
    
    public var cookingsteps: [CookingStepData] = []
    
    enum Key:String{
        case cookingsteps = "cookingsteps"
    }
    
    init(cookingsteps: [CookingStepData]) {
        self.cookingsteps = cookingsteps
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(cookingsteps, forKey: Key.cookingsteps.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mCookingStep = aDecoder.decodeObject(of: [NSArray.self, CookingStepData.self], forKey: Key.cookingsteps.rawValue) as! [CookingStepData]? ?? []
        
        self.init(cookingsteps: mCookingStep)
    }
}

@objc(IngredientsDataValueTransformer)
final class IngredientsDataValueTransformer: NSSecureUnarchiveFromDataTransformer {

    // The name of the transformer. This is what we will use to register the transformer `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: IngredientsData.self))

    // Our class `Test` should in the allowed class list. (This is what the unarchiver uses to check for the right class)
    override static var allowedTopLevelClasses: [AnyClass] {
        return [IngredientsData.self]
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = IngredientsDataValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

@objc(PrepStepsDataValueTransformer)
final class PrepStepsDataValueTransformer: NSSecureUnarchiveFromDataTransformer {

    // The name of the transformer. This is what we will use to register the transformer `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: PrepStepsData.self))

    // Our class `Test` should in the allowed class list. (This is what the unarchiver uses to check for the right class)
    override static var allowedTopLevelClasses: [AnyClass] {
        return [PrepStepsData.self]
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = PrepStepsDataValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

@objc(CookingStepsDataValueTransformer)
final class CookingStepsDataValueTransformer: NSSecureUnarchiveFromDataTransformer {

    // The name of the transformer. This is what we will use to register the transformer `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: CookingStepsData.self))

    // Our class `Test` should in the allowed class list. (This is what the unarchiver uses to check for the right class)
    override static var allowedTopLevelClasses: [AnyClass] {
        return [CookingStepsData.self]
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = CookingStepsDataValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

