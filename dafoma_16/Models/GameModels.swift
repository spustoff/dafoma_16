import SwiftUI
import Foundation

// MARK: - Game Difficulty
enum GameDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var timeLimit: TimeInterval {
        switch self {
        case .easy: return 60
        case .medium: return 45
        case .hard: return 30
        }
    }
    
    var pointMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
}

// MARK: - Cuisine Type
enum CuisineType: String, CaseIterable, Codable {
    case italian = "Italian"
    case chinese = "Chinese"
    case mexican = "Mexican"
    case french = "French"
    case japanese = "Japanese"
    case indian = "Indian"
    case mediterranean = "Mediterranean"
    case american = "American"
    
    var color: Color {
        switch self {
        case .italian: return .green
        case .chinese: return .red
        case .mexican: return .orange
        case .french: return .purple
        case .japanese: return .pink
        case .indian: return .yellow
        case .mediterranean: return .blue
        case .american: return .indigo
        }
    }
    
    var icon: String {
        switch self {
        case .italian: return "🍝"
        case .chinese: return "🥢"
        case .mexican: return "🌮"
        case .french: return "🥖"
        case .japanese: return "🍱"
        case .indian: return "🍛"
        case .mediterranean: return "🫒"
        case .american: return "🍔"
        }
    }
}

// MARK: - Ingredient
struct Ingredient: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: IngredientCategory
    let cuisineTypes: [CuisineType]
    let rarity: IngredientRarity
    let nutritionalInfo: NutritionalInfo?
    let funFact: String?
    
    init(name: String, category: IngredientCategory, cuisineTypes: [CuisineType], rarity: IngredientRarity, nutritionalInfo: NutritionalInfo? = nil, funFact: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.cuisineTypes = cuisineTypes
        self.rarity = rarity
        self.nutritionalInfo = nutritionalInfo
        self.funFact = funFact
    }
    
    var displayName: String {
        return name.capitalized
    }
    
    var icon: String {
        return category.icon
    }
    
    // MARK: - Equatable
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.cuisineTypes == rhs.cuisineTypes &&
               lhs.rarity == rhs.rarity
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(cuisineTypes)
        hasher.combine(rarity)
    }
}

enum IngredientCategory: String, CaseIterable, Codable {
    case vegetable = "Vegetable"
    case fruit = "Fruit"
    case protein = "Protein"
    case grain = "Grain"
    case dairy = "Dairy"
    case spice = "Spice"
    case herb = "Herb"
    case sauce = "Sauce"
    case oil = "Oil"
    case sweetener = "Sweetener"
    
    var icon: String {
        switch self {
        case .vegetable: return "🥬"
        case .fruit: return "🍎"
        case .protein: return "🥩"
        case .grain: return "🌾"
        case .dairy: return "🥛"
        case .spice: return "🌶️"
        case .herb: return "🌿"
        case .sauce: return "🥫"
        case .oil: return "🫒"
        case .sweetener: return "🍯"
        }
    }
}

enum IngredientRarity: String, CaseIterable, Codable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .legendary: return .purple
        }
    }
    
    var points: Int {
        switch self {
        case .common: return 10
        case .uncommon: return 25
        case .rare: return 50
        case .legendary: return 100
        }
    }
}

struct NutritionalInfo: Codable, Hashable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let vitamins: [String]
}

// MARK: - Recipe
struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let ingredients: [Ingredient]
    let cuisineType: CuisineType
    let difficulty: GameDifficulty
    let cookingTime: TimeInterval
    let description: String
    let instructions: [String]
    
    init(name: String, ingredients: [Ingredient], cuisineType: CuisineType, difficulty: GameDifficulty, cookingTime: TimeInterval, description: String, instructions: [String]) {
        self.id = UUID()
        self.name = name
        self.ingredients = ingredients
        self.cuisineType = cuisineType
        self.difficulty = difficulty
        self.cookingTime = cookingTime
        self.description = description
        self.instructions = instructions
    }
    
    var displayName: String {
        return name.capitalized
    }
    
    var totalIngredients: Int {
        return ingredients.count
    }
    
    // MARK: - Equatable
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.name == rhs.name &&
               lhs.cuisineType == rhs.cuisineType &&
               lhs.difficulty == rhs.difficulty
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(cuisineType)
        hasher.combine(difficulty)
    }
}

// MARK: - Game Mode
enum GameMode: String, CaseIterable, Codable {
    case culinaryChallenge = "Culinary Challenge"
    case tasteTest = "Taste Test"
    case ingredientMastery = "Ingredient Mastery"
    case dailyQuest = "Daily Quest"
    case arHunt = "AR Hunt"
    
    var icon: String {
        switch self {
        case .culinaryChallenge: return "chef.hat"
        case .tasteTest: return "clock"
        case .ingredientMastery: return "trophy"
        case .dailyQuest: return "calendar"
        case .arHunt: return "camera.viewfinder"
        }
    }
    
    var description: String {
        switch self {
        case .culinaryChallenge:
            return "Create unique dishes with randomly provided ingredients"
        case .tasteTest:
            return "Beat the clock naming ingredients in displayed dishes"
        case .ingredientMastery:
            return "Compete globally on ingredient knowledge"
        case .dailyQuest:
            return "Complete time-limited culinary challenges"
        case .arHunt:
            return "Find virtual ingredients in augmented reality"
        }
    }
}

// MARK: - Score and Achievement
struct GameScore: Identifiable, Codable, Hashable {
    let id: UUID
    let playerId: String
    let playerName: String
    let score: Int
    let gameMode: GameMode
    let difficulty: GameDifficulty
    let achievedAt: Date
    let timeElapsed: TimeInterval
    
    init(playerId: String, playerName: String, score: Int, gameMode: GameMode, difficulty: GameDifficulty, achievedAt: Date, timeElapsed: TimeInterval) {
        self.id = UUID()
        self.playerId = playerId
        self.playerName = playerName
        self.score = score
        self.gameMode = gameMode
        self.difficulty = difficulty
        self.achievedAt = achievedAt
        self.timeElapsed = timeElapsed
    }
    
    var formattedScore: String {
        return NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
    }
    
    var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Equatable
    static func == (lhs: GameScore, rhs: GameScore) -> Bool {
        return lhs.playerId == rhs.playerId &&
               lhs.score == rhs.score &&
               lhs.gameMode == rhs.gameMode &&
               lhs.achievedAt == rhs.achievedAt
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(playerId)
        hasher.combine(score)
        hasher.combine(gameMode)
        hasher.combine(achievedAt)
    }
}

struct Achievement: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let points: Int
    let isUnlocked: Bool
    let unlockedAt: Date?
    let requirement: AchievementRequirement
    
    init(title: String, description: String, icon: String, points: Int, isUnlocked: Bool, unlockedAt: Date?, requirement: AchievementRequirement) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.points = points
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.requirement = requirement
    }
    
    // MARK: - Equatable
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.title == rhs.title &&
               lhs.description == rhs.description &&
               lhs.points == rhs.points
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(points)
    }
}

enum AchievementRequirement: Codable, Hashable {
    case totalScore(Int)
    case gamesPlayed(Int)
    case perfectGames(Int)
    case ingredientsDiscovered(Int)
    case recipesCompleted(Int)
    case timeRecord(TimeInterval)
    case streakDays(Int)
}

// MARK: - Daily Quest
struct DailyQuest: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let questType: QuestType
    let requirement: QuestRequirement
    let reward: QuestReward
    let expiresAt: Date
    let isCompleted: Bool
    let completedAt: Date?
    
    init(title: String, description: String, questType: QuestType, requirement: QuestRequirement, reward: QuestReward, expiresAt: Date, isCompleted: Bool, completedAt: Date?) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.questType = questType
        self.requirement = requirement
        self.reward = reward
        self.expiresAt = expiresAt
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
    
    var isExpired: Bool {
        return Date() > expiresAt
    }
    
    // MARK: - Equatable
    static func == (lhs: DailyQuest, rhs: DailyQuest) -> Bool {
        return lhs.title == rhs.title &&
               lhs.questType == rhs.questType &&
               lhs.expiresAt == rhs.expiresAt
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(questType)
        hasher.combine(expiresAt)
    }
}

enum QuestType: String, CaseIterable, Codable, Hashable {
    case createRecipes = "Create Recipes"
    case identifyIngredients = "Identify Ingredients"
    case exploreNewCuisine = "Explore New Cuisine"
    case speedChallenge = "Speed Challenge"
    case perfectGame = "Perfect Game"
}

struct QuestRequirement: Codable, Hashable {
    let target: Int
    let criteria: String
}

struct QuestReward: Codable, Hashable {
    let points: Int
    let ingredients: [Ingredient]
    let recipes: [Recipe]
    let title: String?
}

// MARK: - Player Progress
struct PlayerProgress: Codable {
    var level: Int
    var totalXP: Int
    var gamesPlayed: Int
    var totalScore: Int
    var bestScore: Int
    var discoveredIngredients: Set<String>
    var unlockedRecipes: Set<String>
    var achievements: [Achievement]
    var favoriteThemes: [CuisineType]
    var streakDays: Int
    var lastPlayedDate: Date?
    
    var currentLevelXP: Int {
        let xpForCurrentLevel = xpRequiredForLevel(level)
        return totalXP - xpForCurrentLevel
    }
    
    var xpNeededForNextLevel: Int {
        let xpForNextLevel = xpRequiredForLevel(level + 1)
        return xpForNextLevel - totalXP
    }
    
    var progressToNextLevel: Double {
        let currentLevelXP = xpRequiredForLevel(level)
        let nextLevelXP = xpRequiredForLevel(level + 1)
        let levelXPRange = nextLevelXP - currentLevelXP
        let currentProgress = totalXP - currentLevelXP
        return Double(currentProgress) / Double(levelXPRange)
    }
    
    private func xpRequiredForLevel(_ level: Int) -> Int {
        return level * level * 100
    }
} 