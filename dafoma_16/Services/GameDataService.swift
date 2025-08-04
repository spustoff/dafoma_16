import Foundation
import SwiftUI

class GameDataService: ObservableObject {
    static let shared = GameDataService()
    
    @Published var ingredients: [Ingredient] = []
    @Published var recipes: [Recipe] = []
    @Published var dailyQuests: [DailyQuest] = []
    @Published var achievements: [Achievement] = []
    
    private init() {
        loadGameData()
    }
    
    func loadGameData() {
        loadIngredients()
        loadRecipes()
        loadDailyQuests()
        loadAchievements()
    }
    
    // MARK: - Ingredients Data
    private func loadIngredients() {
        ingredients = [
            // Vegetables
            Ingredient(name: "tomato", category: .vegetable, cuisineTypes: [.italian, .mediterranean, .mexican], rarity: .common, nutritionalInfo: NutritionalInfo(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, vitamins: ["Vitamin C", "Vitamin K"]), funFact: "Tomatoes are technically fruits, not vegetables!"),
            Ingredient(name: "onion", category: .vegetable, cuisineTypes: [.french, .italian, .indian, .american], rarity: .common, nutritionalInfo: nil, funFact: "Onions can make you cry because they release sulfuric compounds when cut."),
            Ingredient(name: "garlic", category: .vegetable, cuisineTypes: [.italian, .french, .chinese, .mediterranean], rarity: .common, nutritionalInfo: nil, funFact: "Garlic has been used medicinally for over 5,000 years."),
            Ingredient(name: "bell pepper", category: .vegetable, cuisineTypes: [.mexican, .mediterranean, .american], rarity: .common, nutritionalInfo: nil, funFact: "Red bell peppers have more vitamin C than oranges!"),
            Ingredient(name: "mushroom", category: .vegetable, cuisineTypes: [.french, .italian, .japanese], rarity: .uncommon, nutritionalInfo: nil, funFact: "Mushrooms are neither plants nor animals - they're fungi!"),
            Ingredient(name: "truffle", category: .vegetable, cuisineTypes: [.french, .italian], rarity: .legendary, nutritionalInfo: nil, funFact: "Truffles can cost thousands of dollars per pound!"),
            
            // Proteins
            Ingredient(name: "chicken", category: .protein, cuisineTypes: [.american, .french, .chinese, .indian], rarity: .common, nutritionalInfo: nil, funFact: "Chicken is the most consumed protein in the world."),
            Ingredient(name: "salmon", category: .protein, cuisineTypes: [.japanese, .american, .french], rarity: .uncommon, nutritionalInfo: nil, funFact: "Salmon can jump up to 12 feet high!"),
            Ingredient(name: "wagyu beef", category: .protein, cuisineTypes: [.japanese], rarity: .legendary, nutritionalInfo: nil, funFact: "Wagyu cattle are massaged and fed beer for tender meat!"),
            Ingredient(name: "tofu", category: .protein, cuisineTypes: [.chinese, .japanese], rarity: .common, nutritionalInfo: nil, funFact: "Tofu was invented in China over 2,000 years ago."),
            
            // Spices and Herbs
            Ingredient(name: "basil", category: .herb, cuisineTypes: [.italian, .mediterranean], rarity: .common, nutritionalInfo: nil, funFact: "Fresh basil has over 40 different flavor compounds!"),
            Ingredient(name: "cilantro", category: .herb, cuisineTypes: [.mexican, .indian, .chinese], rarity: .common, nutritionalInfo: nil, funFact: "Some people genetically taste cilantro as soap!"),
            Ingredient(name: "saffron", category: .spice, cuisineTypes: [.french, .indian, .mediterranean], rarity: .legendary, nutritionalInfo: nil, funFact: "Saffron is worth more than gold by weight!"),
            Ingredient(name: "cardamom", category: .spice, cuisineTypes: [.indian], rarity: .rare, nutritionalInfo: nil, funFact: "Cardamom is known as the 'Queen of Spices' in India."),
            
            // Grains
            Ingredient(name: "rice", category: .grain, cuisineTypes: [.chinese, .japanese, .indian], rarity: .common, nutritionalInfo: nil, funFact: "Rice feeds more than half of the world's population!"),
            Ingredient(name: "quinoa", category: .grain, cuisineTypes: [.american], rarity: .uncommon, nutritionalInfo: nil, funFact: "Quinoa was considered sacred by the Incas."),
            
            // Dairy
            Ingredient(name: "parmesan cheese", category: .dairy, cuisineTypes: [.italian], rarity: .uncommon, nutritionalInfo: nil, funFact: "Real Parmigiano-Reggiano is aged for at least 12 months."),
            Ingredient(name: "mozzarella", category: .dairy, cuisineTypes: [.italian], rarity: .common, nutritionalInfo: nil, funFact: "Traditional mozzarella is made from water buffalo milk!"),
            
            // Fruits
            Ingredient(name: "lemon", category: .fruit, cuisineTypes: [.mediterranean, .french, .italian], rarity: .common, nutritionalInfo: nil, funFact: "Lemons were once more valuable than gold in ancient Rome."),
            Ingredient(name: "avocado", category: .fruit, cuisineTypes: [.mexican, .american], rarity: .common, nutritionalInfo: nil, funFact: "Avocados are technically berries!"),
            
            // Oils and Sweeteners
            Ingredient(name: "olive oil", category: .oil, cuisineTypes: [.mediterranean, .italian, .french], rarity: .common, nutritionalInfo: nil, funFact: "Extra virgin olive oil must be pressed without heat."),
            Ingredient(name: "honey", category: .sweetener, cuisineTypes: [.mediterranean, .american], rarity: .common, nutritionalInfo: nil, funFact: "Honey never spoils - archaeologists found edible honey in Egyptian tombs!")
        ]
    }
    
    // MARK: - Recipes Data
    private func loadRecipes() {
        let tomato = ingredients.first { $0.name == "tomato" }!
        let basil = ingredients.first { $0.name == "basil" }!
        let mozzarella = ingredients.first { $0.name == "mozzarella" }!
        let onion = ingredients.first { $0.name == "onion" }!
        let garlic = ingredients.first { $0.name == "garlic" }!
        let chicken = ingredients.first { $0.name == "chicken" }!
        
        recipes = [
            Recipe(
                name: "Margherita Pizza",
                ingredients: [tomato, basil, mozzarella],
                cuisineType: .italian,
                difficulty: .easy,
                cookingTime: 900, // 15 minutes
                description: "A classic Italian pizza with fresh tomatoes, mozzarella, and basil",
                instructions: [
                    "Prepare pizza dough",
                    "Spread tomato sauce",
                    "Add fresh mozzarella",
                    "Bake at 450°F for 12-15 minutes",
                    "Top with fresh basil leaves"
                ]
            ),
            Recipe(
                name: "Chicken Stir Fry",
                ingredients: [chicken, onion, garlic],
                cuisineType: .chinese,
                difficulty: .medium,
                cookingTime: 1200, // 20 minutes
                description: "Quick and healthy chicken stir fry with vegetables",
                instructions: [
                    "Cut chicken into bite-sized pieces",
                    "Heat oil in wok",
                    "Stir fry chicken until cooked",
                    "Add vegetables and garlic",
                    "Serve over rice"
                ]
            )
        ]
    }
    
    // MARK: - Daily Quests
    private func loadDailyQuests() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        dailyQuests = [
            DailyQuest(
                title: "Ingredient Explorer",
                description: "Discover 5 new ingredients",
                questType: .identifyIngredients,
                requirement: QuestRequirement(target: 5, criteria: "ingredients"),
                reward: QuestReward(points: 100, ingredients: [], recipes: [], title: "Explorer"),
                expiresAt: tomorrow,
                isCompleted: false,
                completedAt: nil
            ),
            DailyQuest(
                title: "Speed Chef",
                description: "Complete a recipe in under 30 seconds",
                questType: .speedChallenge,
                requirement: QuestRequirement(target: 1, criteria: "speed"),
                reward: QuestReward(points: 200, ingredients: [], recipes: [], title: "Speed Demon"),
                expiresAt: tomorrow,
                isCompleted: false,
                completedAt: nil
            )
        ]
    }
    
    // MARK: - Achievements
    private func loadAchievements() {
        achievements = [
            Achievement(
                title: "First Steps",
                description: "Play your first game",
                icon: "play.circle",
                points: 50,
                isUnlocked: false,
                unlockedAt: nil,
                requirement: .gamesPlayed(1)
            ),
            Achievement(
                title: "Ingredient Master",
                description: "Discover 50 ingredients",
                icon: "leaf",
                points: 500,
                isUnlocked: false,
                unlockedAt: nil,
                requirement: .ingredientsDiscovered(50)
            ),
            Achievement(
                title: "Speed Demon",
                description: "Complete a game in under 30 seconds",
                icon: "bolt",
                points: 300,
                isUnlocked: false,
                unlockedAt: nil,
                requirement: .timeRecord(30)
            ),
            Achievement(
                title: "High Scorer",
                description: "Reach a total score of 10,000 points",
                icon: "star",
                points: 1000,
                isUnlocked: false,
                unlockedAt: nil,
                requirement: .totalScore(10000)
            )
        ]
    }
    
    // MARK: - Random Data Generation
    func getRandomIngredients(count: Int, excludeRarity: [IngredientRarity] = []) -> [Ingredient] {
        let availableIngredients = ingredients.filter { !excludeRarity.contains($0.rarity) }
        return Array(availableIngredients.shuffled().prefix(count))
    }
    
    func getRandomRecipe() -> Recipe {
        return recipes.randomElement() ?? recipes[0]
    }
    
    func getIngredientsForCuisine(_ cuisine: CuisineType) -> [Ingredient] {
        return ingredients.filter { $0.cuisineTypes.contains(cuisine) }
    }
    
    func searchIngredients(query: String) -> [Ingredient] {
        guard !query.isEmpty else { return ingredients }
        return ingredients.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    func getRecipesForDifficulty(_ difficulty: GameDifficulty) -> [Recipe] {
        return recipes.filter { $0.difficulty == difficulty }
    }
} 