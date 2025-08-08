import SwiftUI

struct GameOverView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var userSettings: UserSettings
    @State private var showShareSheet = false
    @State private var animateResults = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            FlavorQuestColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerView
                    
                    // Results Card
                    if let results = gameManager.gameResults {
                        resultsCard(results)
                    }
                    
                    // Achievements Section
                    if !gameManager.achievements.filter({ $0.isUnlocked }).isEmpty {
                        achievementsSection
                    }
                    
                    // Action Buttons
                    actionButtons
                }
                .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 20)
                .padding(.top, 40)
                .frame(maxWidth: horizontalSizeClass == .regular ? 800 : .infinity, alignment: .center)
            }
            
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                animateResults = true
            }
            
            if let results = gameManager.gameResults, results.score > 500 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showConfetti = true
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Game Over Title with emoji based on performance
            VStack(spacing: 8) {
                Text(getPerformanceEmoji())
                    .font(.system(size: 80))
                    .scaleEffect(animateResults ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateResults)
                
                Text(getPerformanceTitle())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.accent)
                    .multilineTextAlignment(.center)
                    .opacity(animateResults ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateResults)
            }
            
            // Game Mode
            Text("\(gameManager.currentGameMode?.rawValue ?? "Game") Complete!")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(FlavorQuestColors.textPrimary)
                .opacity(animateResults ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(0.7), value: animateResults)
        }
    }
    
    // MARK: - Results Card
    private func resultsCard(_ results: GameResults) -> some View {
        FlavorQuestCard(style: .elevated) {
            VStack(spacing: 24) {
                // Score
                VStack(spacing: 8) {
                    Text("Final Score")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                    
                    Text("\(results.score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                        .scaleEffect(animateResults ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.9), value: animateResults)
                }
                
                Divider()
                    .background(FlavorQuestColors.textSecondary.opacity(0.3))
                
                // Detailed Stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: horizontalSizeClass == .regular ? 3 : 2), spacing: 20) {
                    StatDetailCard(
                        title: "Time Taken",
                        value: results.formattedTime,
                        icon: "clock"
                    )
                    
                    StatDetailCard(
                        title: "Accuracy",
                        value: results.accuracyPercentage,
                        icon: "target"
                    )
                    
                    StatDetailCard(
                        title: "Ingredients Found",
                        value: "\(results.ingredientsDiscovered)",
                        icon: "leaf"
                    )
                    
                    StatDetailCard(
                        title: "XP Earned",
                        value: "+\(results.score / 10)",
                        icon: "bolt"
                    )
                }
                
                // Personal Best Check
                if results.score >= gameManager.playerProgress.bestScore {
                    VStack(spacing: 8) {
                        Text("🎉 NEW PERSONAL BEST! 🎉")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.accent)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
        .opacity(animateResults ? 1.0 : 0.0)
        .offset(y: animateResults ? 0 : 50)
        .animation(.easeInOut(duration: 0.8).delay(1.1), value: animateResults)
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(FlavorQuestColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gameManager.achievements.filter { $0.isUnlocked }.prefix(3)) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .opacity(animateResults ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.8).delay(1.3), value: animateResults)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Play Again Button
            Button("Play Again") {
                if let currentMode = gameManager.currentGameMode {
                    gameManager.startGame(currentMode, difficulty: userSettings.preferredDifficulty)
                }
            }
            .buttonStyle(FlavorQuestButtonStyle(style: .primary))
            
            HStack(spacing: 16) {
                // Share Score Button
                Button(action: { showShareSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
                .frame(maxWidth: .infinity)
                
                // Main Menu Button
                Button("Main Menu") {
                    gameManager.returnToMainMenu()
                }
                .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 40)
        .opacity(animateResults ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.8).delay(1.5), value: animateResults)
    }
    
    // MARK: - Helper Methods
    private func getPerformanceEmoji() -> String {
        guard let results = gameManager.gameResults else { return "🎮" }
        
        switch results.accuracy {
        case 0.9...1.0: return "🌟"
        case 0.7...0.89: return "🎉"
        case 0.5...0.69: return "👍"
        default: return "💪"
        }
    }
    
    private func getPerformanceTitle() -> String {
        guard let results = gameManager.gameResults else { return "Game Complete!" }
        
        switch results.accuracy {
        case 0.9...1.0: return "OUTSTANDING!"
        case 0.7...0.89: return "EXCELLENT!"
        case 0.5...0.69: return "GOOD JOB!"
        default: return "KEEP TRYING!"
        }
    }
}

// MARK: - Stat Detail Card
struct StatDetailCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(FlavorQuestColors.accent)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(FlavorQuestColors.textPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(FlavorQuestColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FlavorQuestColors.secondary.opacity(0.6))
        )
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        FlavorQuestCard(style: .compact) {
            VStack(spacing: 12) {
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundColor(FlavorQuestColors.accent)
                
                Text(achievement.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("+\(achievement.points) XP")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.accent)
            }
        }
        .frame(width: 140)
    }
}

#Preview {
    GameOverView()
        .environmentObject(GameManager())
        .environmentObject(UserSettings())
} 
