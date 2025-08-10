import SwiftUI
import Foundation
import Combine

class GameManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentGameState: GameState = .mainMenu
    @Published var currentGameMode: GameMode?
    @Published var currentDifficulty: GameDifficulty = .medium
    @Published var currentScore: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isGameActive: Bool = false
    @Published var playerProgress: PlayerProgress
    @Published var achievements: [Achievement] = []
    @Published var dailyQuests: [DailyQuest] = []
    @Published var showingAchievement: Achievement?
    @Published var showingLevelUp: Bool = false
    
    // Game specific state
    @Published var currentIngredients: [Ingredient] = []
    @Published var currentRecipe: Recipe?
    @Published var selectedIngredients: [Ingredient] = []
    @Published var guessedIngredients: Set<String> = Set()
    @Published var gameResults: GameResults?
    @Published var presentARCamera: Bool = false
    
    // MARK: - Services
    private let dataService = GameDataService.shared
    private let storageService = StorageService.shared
    
    // MARK: - Timer
    private var gameTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.playerProgress = storageService.loadPlayerProgress()
        self.achievements = dataService.achievements
        self.dailyQuests = dataService.dailyQuests
        
        updateDailyStreak()
        checkForAchievements()
    }
    
    // MARK: - Game State Management
    func startGame(_ mode: GameMode, difficulty: GameDifficulty = .medium) {
        currentGameMode = mode
        currentDifficulty = difficulty
        currentScore = 0
        timeRemaining = difficulty.timeLimit
        isGameActive = true
        currentGameState = .playing
        guessedIngredients.removeAll()
        selectedIngredients.removeAll()
        
        setupGameMode(mode, difficulty: difficulty)
        startTimer()
        
        // Update player stats
        playerProgress.gamesPlayed += 1
        saveProgress()
    }
    
    func endGame() {
        isGameActive = false
        gameTimer?.invalidate()
        gameTimer = nil
        
        let finalScore = currentScore
        let gameTime = currentDifficulty.timeLimit - timeRemaining
        
        // Create game results
        gameResults = GameResults(
            score: finalScore,
            gameMode: currentGameMode ?? .culinaryChallenge,
            timeElapsed: gameTime,
            accuracy: calculateAccuracy(),
            ingredientsDiscovered: guessedIngredients.count,
            newAchievements: [],
            levelUp: false
        )
        
        // Update progress
        updateProgressAfterGame(score: finalScore)
        
        // Save high score
        if let mode = currentGameMode {
            let score = GameScore(
                playerId: UUID().uuidString,
                playerName: "Player", // TODO: Get from settings
                score: finalScore,
                gameMode: mode,
                difficulty: currentDifficulty,
                achievedAt: Date(),
                timeElapsed: gameTime
            )
            storageService.saveHighScore(score)
        }
        
        currentGameState = .gameOver
        checkForAchievements()
        checkForLevelUp()
    }
    
    func returnToMainMenu() {
        currentGameState = .mainMenu
        currentGameMode = nil
        gameResults = nil
        currentIngredients.removeAll()
        selectedIngredients.removeAll()
        guessedIngredients.removeAll()
        currentRecipe = nil
    }
    
    // MARK: - Game Mode Setup
    private func setupGameMode(_ mode: GameMode, difficulty: GameDifficulty) {
        switch mode {
        case .culinaryChallenge:
            setupCulinaryChallenge(difficulty: difficulty)
        case .tasteTest:
            setupTasteTest(difficulty: difficulty)
        case .ingredientMastery:
            setupIngredientMastery(difficulty: difficulty)
        case .dailyQuest:
            setupDailyQuest()
        case .arHunt:
            setupARHunt(difficulty: difficulty)
        }
    }
    
    private func setupCulinaryChallenge(difficulty: GameDifficulty) {
        let ingredientCount = difficulty == .easy ? 3 : difficulty == .medium ? 5 : 7
        currentIngredients = dataService.getRandomIngredients(count: ingredientCount)
    }
    
    private func setupTasteTest(difficulty: GameDifficulty) {
        currentRecipe = dataService.getRandomRecipe()
        currentIngredients = currentRecipe?.ingredients ?? []
    }
    
    private func setupIngredientMastery(difficulty: GameDifficulty) {
        let ingredientCount = difficulty == .easy ? 5 : difficulty == .medium ? 8 : 12
        currentIngredients = dataService.getRandomIngredients(count: ingredientCount)
    }
    
    private func setupDailyQuest() {
        // Set up based on current daily quest
        if let quest = dailyQuests.first(where: { !$0.isCompleted && !$0.isExpired }) {
            switch quest.questType {
            case .createRecipes:
                setupCulinaryChallenge(difficulty: .medium)
            case .identifyIngredients:
                setupIngredientMastery(difficulty: .easy)
            case .exploreNewCuisine:
                currentIngredients = dataService.getIngredientsForCuisine(.italian) // TODO: Random cuisine
            case .speedChallenge:
                setupTasteTest(difficulty: .hard)
            case .perfectGame:
                setupCulinaryChallenge(difficulty: .medium)
            }
        }
    }
    
    private func setupARHunt(difficulty: GameDifficulty) {
        let ingredientCount = difficulty == .easy ? 3 : difficulty == .medium ? 5 : 8
        currentIngredients = dataService.getRandomIngredients(count: ingredientCount, excludeRarity: [.legendary])
    }
    
    // MARK: - Game Actions
    func selectIngredient(_ ingredient: Ingredient) {
        guard isGameActive else { return }
        
        if !selectedIngredients.contains(where: { $0.id == ingredient.id }) {
            selectedIngredients.append(ingredient)
            currentScore += ingredient.rarity.points
            
            // Add to discovered ingredients
            playerProgress.discoveredIngredients.insert(ingredient.name)
            
            // Check if this completes the current objective
            checkGameCompletion()
        }
    }
    
    func guessIngredient(_ ingredientName: String) -> Bool {
        guard isGameActive else { return false }
        
        let lowercaseName = ingredientName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let correctGuess = currentIngredients.contains { $0.name.lowercased() == lowercaseName }
        
        if correctGuess && !guessedIngredients.contains(lowercaseName) {
            guessedIngredients.insert(lowercaseName)
            
            if let ingredient = currentIngredients.first(where: { $0.name.lowercased() == lowercaseName }) {
                currentScore += ingredient.rarity.points
                playerProgress.discoveredIngredients.insert(ingredient.name)
            }
            
            checkGameCompletion()
            return true
        }
        
        return false
    }
    
    func removeSelectedIngredient(_ ingredient: Ingredient) {
        selectedIngredients.removeAll { $0.id == ingredient.id }
        currentScore = max(0, currentScore - ingredient.rarity.points)
    }
    
    func createRecipe() -> Bool {
        guard selectedIngredients.count >= 2 else { return false }
        
        // Award points for creativity and ingredient combinations
        let bonusPoints = calculateRecipeBonus()
        currentScore += bonusPoints
        
        // Clear selected ingredients
        selectedIngredients.removeAll()
        
        return true
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
    }
    
    // MARK: - Game Completion Logic
    private func checkGameCompletion() {
        guard let mode = currentGameMode else { return }
        
        switch mode {
        case .tasteTest:
            // Complete when all ingredients are guessed
            if guessedIngredients.count == currentIngredients.count {
                endGame()
            }
        case .culinaryChallenge:
            // Complete when recipe is created with minimum ingredients
            if selectedIngredients.count >= 3 {
                // Auto-complete after some time or manual trigger
            }
        case .ingredientMastery:
            // Complete when all ingredients are identified
            if guessedIngredients.count == currentIngredients.count {
                endGame()
            }
        default:
            break
        }
    }
    
    // MARK: - Scoring and Progress
    private func calculateAccuracy() -> Double {
        guard !currentIngredients.isEmpty else { return 0.0 }
        
        switch currentGameMode {
        case .tasteTest, .ingredientMastery:
            return Double(guessedIngredients.count) / Double(currentIngredients.count)
        case .culinaryChallenge:
            return Double(selectedIngredients.count) / Double(currentIngredients.count)
        default:
            return 1.0
        }
    }
    
    private func calculateRecipeBonus() -> Int {
        let uniqueCategories = Set(selectedIngredients.map { $0.category })
        let rarityBonus = selectedIngredients.reduce(0) { $0 + $1.rarity.points }
        let creativityBonus = uniqueCategories.count * 10
        
        return rarityBonus + creativityBonus
    }
    
    private func updateProgressAfterGame(score: Int) {
        playerProgress.totalScore += score
        playerProgress.bestScore = max(playerProgress.bestScore, score)
        
        // Award XP based on performance
        let baseXP = score / 10
        let difficultyMultiplier = currentDifficulty.pointMultiplier
        let finalXP = Int(Double(baseXP) * difficultyMultiplier)
        
        playerProgress.totalXP += finalXP
        
        saveProgress()
    }
    
    private func checkForLevelUp() {
        let currentLevel = playerProgress.level
        let newLevel = calculateLevel(from: playerProgress.totalXP)
        
        if newLevel > currentLevel {
            playerProgress.level = newLevel
            showingLevelUp = true
            saveProgress()
        }
    }
    
    private func calculateLevel(from xp: Int) -> Int {
        return Int(sqrt(Double(xp) / 100.0)) + 1
    }
    
    // MARK: - Achievements
    private func checkForAchievements() {
        for achievement in achievements {
            if !achievement.isUnlocked && checkAchievementRequirement(achievement.requirement) {
                unlockAchievement(achievement)
            }
        }
    }
    
    private func checkAchievementRequirement(_ requirement: AchievementRequirement) -> Bool {
        switch requirement {
        case .totalScore(let targetScore):
            return playerProgress.totalScore >= targetScore
        case .gamesPlayed(let targetGames):
            return playerProgress.gamesPlayed >= targetGames
        case .ingredientsDiscovered(let targetCount):
            return playerProgress.discoveredIngredients.count >= targetCount
        case .timeRecord(let targetTime):
            return timeRemaining >= (60 - targetTime) // Completed within target time
        default:
            return false
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        var updatedAchievement = achievement
        updatedAchievement = Achievement(
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            points: achievement.points,
            isUnlocked: true,
            unlockedAt: Date(),
            requirement: achievement.requirement
        )
        
        if let index = achievements.firstIndex(where: { $0.id == achievement.id }) {
            achievements[index] = updatedAchievement
        }
        
        playerProgress.totalXP += achievement.points
        showingAchievement = updatedAchievement
        
        saveProgress()
        storageService.saveAchievements(achievements)
    }
    
    // MARK: - Daily Streak
    private func updateDailyStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastPlayedDate = playerProgress.lastPlayedDate {
            if calendar.isDate(lastPlayedDate, inSameDayAs: today) {
                // Already played today
                return
            } else if calendar.isDate(lastPlayedDate, equalTo: calendar.date(byAdding: .day, value: -1, to: today) ?? today, toGranularity: .day) {
                // Played yesterday, continue streak
                playerProgress.streakDays += 1
            } else {
                // Streak broken
                playerProgress.streakDays = 1
            }
        } else {
            // First time playing
            playerProgress.streakDays = 1
        }
        
        playerProgress.lastPlayedDate = today
        saveProgress()
    }
    
    // MARK: - Data Persistence
    private func saveProgress() {
        storageService.savePlayerProgress(playerProgress)
    }
}

// MARK: - Game State
enum GameState {
    case mainMenu
    case playing
    case paused
    case gameOver
    case onboarding
    case settings
}

// MARK: - Game Results
struct GameResults {
    let score: Int
    let gameMode: GameMode
    let timeElapsed: TimeInterval
    let accuracy: Double
    let ingredientsDiscovered: Int
    let newAchievements: [Achievement]
    let levelUp: Bool
    
    var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var accuracyPercentage: String {
        return String(format: "%.1f%%", accuracy * 100)
    }
} 