import Foundation
import SwiftUI

class StorageService: ObservableObject {
    static let shared = StorageService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys for UserDefaults
    private struct Keys {
        static let playerProgress = "flavor_quest_player_progress"
        static let highScores = "flavor_quest_high_scores"
        static let userSettings = "flavor_quest_user_settings"
        static let completedQuests = "flavor_quest_completed_quests"
        static let achievements = "flavor_quest_achievements"
        static let firstLaunch = "flavor_quest_first_launch"
        static let onboardingCompleted = "flavor_quest_onboarding_completed"
    }
    
    private init() {}
    
    // MARK: - Player Progress
    func savePlayerProgress(_ progress: PlayerProgress) {
        do {
            let data = try encoder.encode(progress)
            userDefaults.set(data, forKey: Keys.playerProgress)
        } catch {
            print("Failed to save player progress: \(error)")
        }
    }
    
    func loadPlayerProgress() -> PlayerProgress {
        guard let data = userDefaults.data(forKey: Keys.playerProgress),
              let progress = try? decoder.decode(PlayerProgress.self, from: data) else {
            return createDefaultProgress()
        }
        return progress
    }
    
    private func createDefaultProgress() -> PlayerProgress {
        return PlayerProgress(
            level: 1,
            totalXP: 0,
            gamesPlayed: 0,
            totalScore: 0,
            bestScore: 0,
            discoveredIngredients: Set<String>(),
            unlockedRecipes: Set<String>(),
            achievements: [],
            favoriteThemes: [],
            streakDays: 0,
            lastPlayedDate: nil
        )
    }
    
    // MARK: - High Scores
    func saveHighScore(_ score: GameScore) {
        var scores = loadHighScores()
        scores.append(score)
        
        // Keep only top 100 scores for each game mode
        let groupedScores = Dictionary(grouping: scores) { $0.gameMode }
        var topScores: [GameScore] = []
        
        for (_, modeScores) in groupedScores {
            let sortedScores = modeScores.sorted { $0.score > $1.score }
            topScores.append(contentsOf: Array(sortedScores.prefix(100)))
        }
        
        do {
            let data = try encoder.encode(topScores)
            userDefaults.set(data, forKey: Keys.highScores)
        } catch {
            print("Failed to save high scores: \(error)")
        }
    }
    
    func loadHighScores() -> [GameScore] {
        guard let data = userDefaults.data(forKey: Keys.highScores),
              let scores = try? decoder.decode([GameScore].self, from: data) else {
            return []
        }
        return scores
    }
    
    func getTopScores(for gameMode: GameMode, limit: Int = 10) -> [GameScore] {
        let allScores = loadHighScores()
        let modeScores = allScores.filter { $0.gameMode == gameMode }
        return Array(modeScores.sorted { $0.score > $1.score }.prefix(limit))
    }
    
    // MARK: - User Settings
    func saveUserSettings(_ settings: UserSettings) {
        do {
            let data = try encoder.encode(settings)
            userDefaults.set(data, forKey: Keys.userSettings)
        } catch {
            print("Failed to save user settings: \(error)")
        }
    }
    
    func loadUserSettings() -> UserSettings {
        guard let data = userDefaults.data(forKey: Keys.userSettings),
              let settings = try? decoder.decode(UserSettings.self, from: data) else {
            return UserSettings()
        }
        return settings
    }
    
    // MARK: - Daily Quests
    func saveCompletedQuests(_ quests: [DailyQuest]) {
        do {
            let data = try encoder.encode(quests)
            userDefaults.set(data, forKey: Keys.completedQuests)
        } catch {
            print("Failed to save completed quests: \(error)")
        }
    }
    
    func loadCompletedQuests() -> [DailyQuest] {
        guard let data = userDefaults.data(forKey: Keys.completedQuests),
              let quests = try? decoder.decode([DailyQuest].self, from: data) else {
            return []
        }
        return quests
    }
    
    // MARK: - Achievements
    func saveAchievements(_ achievements: [Achievement]) {
        do {
            let data = try encoder.encode(achievements)
            userDefaults.set(data, forKey: Keys.achievements)
        } catch {
            print("Failed to save achievements: \(error)")
        }
    }
    
    func loadAchievements() -> [Achievement] {
        guard let data = userDefaults.data(forKey: Keys.achievements),
              let achievements = try? decoder.decode([Achievement].self, from: data) else {
            return []
        }
        return achievements
    }
    
    // MARK: - App State
    var isFirstLaunch: Bool {
        get {
            return !userDefaults.bool(forKey: Keys.firstLaunch)
        }
        set {
            userDefaults.set(!newValue, forKey: Keys.firstLaunch)
        }
    }
    
    var isOnboardingCompleted: Bool {
        get {
            return userDefaults.bool(forKey: Keys.onboardingCompleted)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.onboardingCompleted)
        }
    }
    
    // MARK: - Data Management
    func clearAllData() {
        let keys = [
            Keys.playerProgress,
            Keys.highScores,
            Keys.userSettings,
            Keys.completedQuests,
            Keys.achievements,
            Keys.firstLaunch,
            Keys.onboardingCompleted
        ]
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    func exportGameData() -> Data? {
        let gameData = GameData(
            playerProgress: loadPlayerProgress(),
            highScores: loadHighScores(),
            userSettings: loadUserSettings(),
            completedQuests: loadCompletedQuests(),
            achievements: loadAchievements()
        )
        
        return try? encoder.encode(gameData)
    }
    
    func importGameData(_ data: Data) -> Bool {
        guard let gameData = try? decoder.decode(GameData.self, from: data) else {
            return false
        }
        
        savePlayerProgress(gameData.playerProgress)
        
        for score in gameData.highScores {
            saveHighScore(score)
        }
        
        saveUserSettings(gameData.userSettings)
        saveCompletedQuests(gameData.completedQuests)
        saveAchievements(gameData.achievements)
        
        return true
    }
}

// MARK: - Data Export/Import Structure
struct GameData: Codable {
    let playerProgress: PlayerProgress
    let highScores: [GameScore]
    let userSettings: UserSettings
    let completedQuests: [DailyQuest]
    let achievements: [Achievement]
}

// MARK: - User Settings
class UserSettings: ObservableObject, Codable {
    @Published var playerName: String
    @Published var preferredDifficulty: GameDifficulty
    @Published var favoriteThemes: [CuisineType]
    @Published var soundEnabled: Bool
    @Published var musicEnabled: Bool
    @Published var hapticsEnabled: Bool
    @Published var notificationsEnabled: Bool
    @Published var darkModeEnabled: Bool
    @Published var animationsEnabled: Bool
    @Published var arEnabled: Bool
    
    init() {
        self.playerName = "Chef"
        self.preferredDifficulty = .medium
        self.favoriteThemes = []
        self.soundEnabled = true
        self.musicEnabled = true
        self.hapticsEnabled = true
        self.notificationsEnabled = true
        self.darkModeEnabled = true
        self.animationsEnabled = true
        self.arEnabled = true
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case playerName, preferredDifficulty, favoriteThemes
        case soundEnabled, musicEnabled, hapticsEnabled
        case notificationsEnabled, darkModeEnabled, animationsEnabled, arEnabled
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        playerName = try container.decode(String.self, forKey: .playerName)
        preferredDifficulty = try container.decode(GameDifficulty.self, forKey: .preferredDifficulty)
        favoriteThemes = try container.decode([CuisineType].self, forKey: .favoriteThemes)
        soundEnabled = try container.decode(Bool.self, forKey: .soundEnabled)
        musicEnabled = try container.decode(Bool.self, forKey: .musicEnabled)
        hapticsEnabled = try container.decode(Bool.self, forKey: .hapticsEnabled)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        darkModeEnabled = try container.decode(Bool.self, forKey: .darkModeEnabled)
        animationsEnabled = try container.decode(Bool.self, forKey: .animationsEnabled)
        arEnabled = try container.decode(Bool.self, forKey: .arEnabled)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(playerName, forKey: .playerName)
        try container.encode(preferredDifficulty, forKey: .preferredDifficulty)
        try container.encode(favoriteThemes, forKey: .favoriteThemes)
        try container.encode(soundEnabled, forKey: .soundEnabled)
        try container.encode(musicEnabled, forKey: .musicEnabled)
        try container.encode(hapticsEnabled, forKey: .hapticsEnabled)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(darkModeEnabled, forKey: .darkModeEnabled)
        try container.encode(animationsEnabled, forKey: .animationsEnabled)
        try container.encode(arEnabled, forKey: .arEnabled)
    }
} 