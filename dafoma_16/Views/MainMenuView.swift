import SwiftUI

struct MainMenuView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var userSettings: UserSettings
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showLeaderboard = false
    @State private var animateTitle = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header with Title and Player Info
                    headerView
                    
                    // Daily Quest Card
                    dailyQuestCard
                    
                    // Game Modes Grid
                    gameModesGrid
                    
                    // Player Stats
                    playerStatsCard
                    
                    // Quick Actions
                    quickActionsRow
                }
                .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 20)
                .padding(.top, 20)
                .frame(maxWidth: horizontalSizeClass == .regular ? 800 : .infinity, alignment: .center)
            }
            .background(FlavorQuestColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                animateTitle = true
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 20) {
            // Top Navigation Bar
            HStack {
                // Settings Button
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                }
                
                Spacer()
                
                // Game Logo/Title
                Text("FLAVOR QUEST")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.accent)
                    .scaleEffect(animateTitle ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateTitle)
                
                Spacer()
                
                // Profile/Stats Button
                Button(action: { showAchievements = true }) {
                    ZStack {
                        Circle()
                            .fill(FlavorQuestColors.secondary)
                            .frame(width: 40, height: 40)
                        
                        Text("\(gameManager.playerProgress.level)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.accent)
                    }
                }
            }
            
            // Player Welcome Message
            VStack(spacing: 8) {
                Text("Welcome back, \(userSettings.playerName)!")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                
                // XP Progress Bar
                ProgressView(value: gameManager.playerProgress.progressToNextLevel)
                    .progressViewStyle(FlavorQuestProgressStyle())
                    .frame(height: 8)
                
                Text("Level \(gameManager.playerProgress.level) • \(gameManager.playerProgress.xpNeededForNextLevel) XP to next level")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textSecondary)
            }
        }
    }
    
    // MARK: - Daily Quest Card
    private var dailyQuestCard: some View {
        Group {
            if let dailyQuest = gameManager.dailyQuests.first(where: { !$0.isCompleted && !$0.isExpired }) {
                FlavorQuestCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Quest")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(FlavorQuestColors.accent)
                                
                                Text(dailyQuest.title)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(FlavorQuestColors.textPrimary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 24))
                                .foregroundColor(FlavorQuestColors.accent)
                        }
                        
                        Text(dailyQuest.description)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                        
                        HStack {
                            Text("Reward: \(dailyQuest.reward.points) XP")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(FlavorQuestColors.textSecondary)
                            
                            Spacer()
                            
                            Button("Start Quest") {
                                gameManager.startGame(.dailyQuest, difficulty: userSettings.preferredDifficulty)
                            }
                            .buttonStyle(FlavorQuestButtonStyle(style: .small))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Game Modes Grid
    private var gameModesGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Your Challenge")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(FlavorQuestColors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: horizontalSizeClass == .regular ? 3 : 2), spacing: 16) {
                GameModeCard(
                    mode: .culinaryChallenge,
                    primaryColor: FlavorQuestColors.primary
                ) {
                    gameManager.startGame(.culinaryChallenge, difficulty: userSettings.preferredDifficulty)
                }
                
                GameModeCard(
                    mode: .tasteTest,
                    primaryColor: FlavorQuestColors.accent
                ) {
                    gameManager.startGame(.tasteTest, difficulty: userSettings.preferredDifficulty)
                }
                
                GameModeCard(
                    mode: .ingredientMastery,
                    primaryColor: FlavorQuestColors.success
                ) {
                    gameManager.startGame(.ingredientMastery, difficulty: userSettings.preferredDifficulty)
                }
                
                GameModeCard(
                    mode: .arHunt,
                    primaryColor: FlavorQuestColors.warning
                ) {
                    if userSettings.arEnabled {
                        gameManager.startGame(.arHunt, difficulty: userSettings.preferredDifficulty)
                    }
                }
            }
        }
    }
    
    // MARK: - Player Stats Card
    private var playerStatsCard: some View {
        FlavorQuestCard(style: .normal) {
            VStack(spacing: 20) {
                Text("Your Culinary Journey")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: horizontalSizeClass == .regular ? 4 : 3), spacing: 16) {
                    StatCard(
                        title: "Games Played",
                        value: "\(gameManager.playerProgress.gamesPlayed)",
                        icon: "gamecontroller"
                    )
                    
                    StatCard(
                        title: "Best Score",
                        value: "\(gameManager.playerProgress.bestScore)",
                        icon: "star"
                    )
                    
                    StatCard(
                        title: "Ingredients Found",
                        value: "\(gameManager.playerProgress.discoveredIngredients.count)",
                        icon: "leaf"
                    )
                    
                    StatCard(
                        title: "Current Streak",
                        value: "\(gameManager.playerProgress.streakDays)",
                        icon: "flame"
                    )
                    
                    StatCard(
                        title: "Total XP",
                        value: "\(gameManager.playerProgress.totalXP)",
                        icon: "bolt"
                    )
                    
                    StatCard(
                        title: "Achievements",
                        value: "\(gameManager.achievements.filter { $0.isUnlocked }.count)",
                        icon: "trophy"
                    )
                }
            }
        }
    }
    
    // MARK: - Quick Actions Row
    private var quickActionsRow: some View {
        HStack(spacing: 16) {
            Button(action: { showLeaderboard = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "list.number")
                    Text("Leaderboard")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
            .frame(maxWidth: .infinity)
            
            Button(action: { showAchievements = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.circle")
                    Text("Achievements")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Game Mode Card
struct GameModeCard: View {
    let mode: GameMode
    let primaryColor: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
                
                // Title
                Text(mode.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(mode.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Spacer()
            }
            .padding(20)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(FlavorQuestColors.secondary.opacity(0.8))
                    .shadow(color: primaryColor.opacity(0.3), radius: isPressed ? 12 : 6, x: 0, y: isPressed ? 6 : 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryColor.opacity(isPressed ? 0.8 : 0.3), lineWidth: 2)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(FlavorQuestColors.accent)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(FlavorQuestColors.textPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(FlavorQuestColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FlavorQuestColors.secondary.opacity(0.6))
        )
    }
}

// MARK: - Custom Progress Style
struct FlavorQuestProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(FlavorQuestColors.secondary.opacity(0.6))
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [FlavorQuestColors.accent, FlavorQuestColors.primary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0))
                    .animation(.easeInOut(duration: 0.5), value: configuration.fractionCompleted)
            }
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(GameManager())
        .environmentObject(UserSettings())
} 