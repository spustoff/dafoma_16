import SwiftUI

// MARK: - Pause Menu View
struct PauseMenuView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                Text("Game Paused")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.accent)
                
                VStack(spacing: 16) {
                    Button("Resume Game") {
                        dismiss()
                    }
                    .buttonStyle(FlavorQuestButtonStyle(style: .primary))
                    
                    Button("Main Menu") {
                        gameManager.returnToMainMenu()
                        dismiss()
                    }
                    .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .background(FlavorQuestColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(FlavorQuestColors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Paused Game View
struct PausedGameView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Game Paused")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(FlavorQuestColors.accent)
            
            Button("Resume") {
                gameManager.currentGameState = .playing
            }
            .buttonStyle(FlavorQuestButtonStyle(style: .primary))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FlavorQuestColors.background)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Player") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Chef Name", text: $userSettings.playerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Picker("Preferred Difficulty", selection: $userSettings.preferredDifficulty) {
                        ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                }
                
                Section("Audio & Haptics") {
                    Toggle("Sound Effects", isOn: $userSettings.soundEnabled)
                    Toggle("Background Music", isOn: $userSettings.musicEnabled)
                    Toggle("Haptic Feedback", isOn: $userSettings.hapticsEnabled)
                }
                
                Section("Gameplay") {
                    Toggle("AR Features", isOn: $userSettings.arEnabled)
                    Toggle("Animations", isOn: $userSettings.animationsEnabled)
                    Toggle("Notifications", isOn: $userSettings.notificationsEnabled)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $userSettings.darkModeEnabled)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(gameManager.achievements) { achievement in
                        AchievementDetailCard(achievement: achievement)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(FlavorQuestColors.background)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(FlavorQuestColors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Achievement Detail Card
struct AchievementDetailCard: View {
    let achievement: Achievement
    
    var body: some View {
        FlavorQuestCard(style: .normal) {
            VStack(spacing: 16) {
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundColor(achievement.isUnlocked ? FlavorQuestColors.accent : FlavorQuestColors.textSecondary)
                    .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                
                VStack(spacing: 8) {
                    Text(achievement.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(achievement.description)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                HStack {
                    Text("\(achievement.points) XP")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                    
                    Spacer()
                    
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(FlavorQuestColors.success)
                    } else {
                        Image(systemName: "lock")
                            .foregroundColor(FlavorQuestColors.textSecondary)
                    }
                }
            }
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGameMode: GameMode = .culinaryChallenge
    
    private var topScores: [GameScore] {
        StorageService.shared.getTopScores(for: selectedGameMode)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Game Mode Selector
                Picker("Game Mode", selection: $selectedGameMode) {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                // Leaderboard List
                if topScores.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                        
                        Text("No scores yet!")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textPrimary)
                        
                        Text("Be the first to set a high score in \(selectedGameMode.rawValue)!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(topScores.enumerated()), id: \.element.id) { index, score in
                                LeaderboardRow(score: score, rank: index + 1)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .background(FlavorQuestColors.background)
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(FlavorQuestColors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let score: GameScore
    let rank: Int
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return FlavorQuestColors.textSecondary
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal"
        default: return "\(rank).circle"
        }
    }
    
    var body: some View {
        FlavorQuestCard(style: .compact) {
            HStack(spacing: 16) {
                // Rank
                HStack(spacing: 8) {
                    Image(systemName: rankIcon)
                        .foregroundColor(rankColor)
                        .font(.system(size: 20))
                    
                    if rank > 3 {
                        Text("\(rank)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                    }
                }
                .frame(width: 50)
                
                // Player Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(score.playerName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                    
                    Text(score.formattedTime)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                }
                
                Spacer()
                
                // Score
                VStack(alignment: .trailing, spacing: 4) {
                    Text(score.formattedScore)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                    
                    Text(score.difficulty.rawValue)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                }
            }
        }
    }
}

#Preview("Pause Menu") {
    PauseMenuView()
        .environmentObject(GameManager())
}

#Preview("Settings") {
    SettingsView()
        .environmentObject(UserSettings())
}

#Preview("Achievements") {
    AchievementsView()
        .environmentObject(GameManager())
}

#Preview("Leaderboard") {
    LeaderboardView()
        .environmentObject(GameManager())
} 