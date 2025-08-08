import SwiftUI

struct OnboardingFlowView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var userSettings: UserSettings
    @State private var currentPage = 0
    @State private var selectedDifficulty: GameDifficulty = .medium
    @State private var selectedThemes: Set<CuisineType> = []
    @State private var playerName: String = ""
    
    private let pages = ["intro", "tutorial", "personalization", "welcome"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                FlavorQuestColors.background.ignoresSafeArea()
                
                TabView(selection: $currentPage) {
                    // Page 1: Interactive Intro
                    IntroductionView()
                        .tag(0)
                    
                    // Page 2: Tutorial
                    TutorialView()
                        .tag(1)
                    
                    // Page 3: Personalization
                    PersonalizationView(
                        selectedDifficulty: $selectedDifficulty,
                        selectedThemes: $selectedThemes,
                        playerName: $playerName
                    )
                    .tag(2)
                    
                    // Page 4: Welcome Splash
                    WelcomeSplashView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                .frame(maxWidth: horizontalSizeClass == .regular ? 800 : .infinity, alignment: .center)
                
                VStack {
                    Spacer()
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? FlavorQuestColors.accent : FlavorQuestColors.textSecondary)
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // Navigation Buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 1 ? "Start Playing!" : "Next") {
                            if currentPage == pages.count - 1 {
                                completeOnboarding()
                            } else {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                        .buttonStyle(FlavorQuestButtonStyle(style: currentPage == pages.count - 1 ? .accent : .primary))
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? 48 : 32)
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        userSettings.playerName = playerName.isEmpty ? "Chef" : playerName
        userSettings.preferredDifficulty = selectedDifficulty
        userSettings.favoriteThemes = Array(selectedThemes)
        
        // Mark onboarding as completed
        StorageService.shared.isOnboardingCompleted = true
        
        // Transition to main menu
        withAnimation(.easeInOut(duration: 0.5)) {
            gameManager.currentGameState = .mainMenu
        }
    }
}

// MARK: - Introduction View
struct IntroductionView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var animateChef = false
    @State private var animateIngredients = false
    
    private var isSmallScreen: Bool { horizontalSizeClass == .compact || verticalSizeClass == .compact }
    
    private var content: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("🍽️")
                    .font(.system(size: 80))
                    .scaleEffect(animateChef ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateChef)
                
                Text("Welcome to")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textSecondary)
                
                Text("FLAVOR QUEST")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.accent)
                    .multilineTextAlignment(.center)
            }
            
            // Description
            VStack(spacing: 20) {
                Text("Embark on a culinary adventure that combines the excitement of gaming with the art of cooking!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Animated Ingredients
                HStack(spacing: 12) {
                    ForEach(["🍅", "🧄", "🌿", "🧀", "🌶️"], id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 30))
                            .scaleEffect(animateIngredients ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(Double.random(in: 0...0.5)), value: animateIngredients)
                    }
                }
                .padding(.top, 20)
            }
            
            Spacer()
            
            // Features Preview
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                FeatureCard(icon: "chef.hat", title: "Create Recipes", description: "Mix ingredients to create unique dishes")
                FeatureCard(icon: "clock", title: "Beat the Clock", description: "Test your knowledge against time")
                FeatureCard(icon: "trophy", title: "Compete Globally", description: "Climb the leaderboards")
                FeatureCard(icon: "calendar", title: "Daily Challenges", description: "New quests every day")
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .onAppear {
            animateChef = true
            animateIngredients = true
        }
    }
    
    var body: some View {
        if isSmallScreen {
            ScrollView {
                content
                    .padding(.bottom, 160)
            }
        } else {
            content
        }
    }
}

// MARK: - Tutorial View
struct TutorialView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var currentStep = 0
    @State private var selectedIngredient: String? = nil
    
    private let tutorialSteps = [
        TutorialStep(
            title: "Tap to Select",
            description: "Tap on ingredients to add them to your recipe",
            icon: "hand.tap"
        ),
        TutorialStep(
            title: "Create Combinations",
            description: "Mix different ingredient types for bonus points",
            icon: "plus.circle"
        ),
        TutorialStep(
            title: "Watch the Timer",
            description: "Complete challenges before time runs out",
            icon: "timer"
        ),
        TutorialStep(
            title: "Earn Rewards",
            description: "Unlock achievements and climb levels",
            icon: "star.circle"
        )
    ]
    
    private var content: some View {
        VStack(spacing: 40) {
            // Title
            Text("How to Play")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(FlavorQuestColors.accent)
            
            // Tutorial Steps
            TabView(selection: $currentStep) {
                ForEach(0..<tutorialSteps.count, id: \.self) { index in
                    TutorialStepView(step: tutorialSteps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 400)
            
            // Interactive Demo Area
            VStack(spacing: 20) {
                Text("Try it out!")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                
                HStack(spacing: 16) {
                    ForEach(["🍅", "🧄", "🌿"], id: \.self) { ingredient in
                        Button(action: {
                            selectedIngredient = ingredient
                        }) {
                            Text(ingredient)
                                .font(.system(size: 40))
                                .frame(width: 80, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedIngredient == ingredient ? FlavorQuestColors.accent.opacity(0.3) : FlavorQuestColors.secondary)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedIngredient == ingredient ? FlavorQuestColors.accent : Color.clear, lineWidth: 2)
                                )
                        }
                        .scaleEffect(selectedIngredient == ingredient ? 1.1 : 1.0)
                        .animation(.spring(), value: selectedIngredient)
                    }
                }
                
                if selectedIngredient != nil {
                    Text("Great! You selected an ingredient!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.success)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: selectedIngredient)
        }
        .padding(.horizontal, 32)
    }
    
    var body: some View {
        let isSmallScreen = horizontalSizeClass == .compact || verticalSizeClass == .compact
        if isSmallScreen {
            ScrollView {
                content
                    .padding(.bottom, 160)
            }
        } else {
            content
        }
    }
}

// MARK: - Personalization View
struct PersonalizationView: View {
    @Binding var selectedDifficulty: GameDifficulty
    @Binding var selectedThemes: Set<CuisineType>
    @Binding var playerName: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Title
                Text("Customize Your Experience")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.accent)
                    .multilineTextAlignment(.center)
                
                // Player Name
                VStack(alignment: .leading, spacing: 12) {
                    Text("What should we call you?")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                    
                    TextField("Enter your chef name", text: $playerName)
                        .textFieldStyle(FlavorQuestTextFieldStyle())
                }
                
                // Difficulty Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose your difficulty level")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                    
                    VStack(spacing: 12) {
                        ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                            DifficultyOptionView(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                }
                
                // Cuisine Preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select your favorite cuisines")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                    
                    Text("(Choose any that interest you)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(CuisineType.allCases, id: \.self) { cuisine in
                            CuisineSelectionView(
                                cuisine: cuisine,
                                isSelected: selectedThemes.contains(cuisine)
                            ) {
                                if selectedThemes.contains(cuisine) {
                                    selectedThemes.remove(cuisine)
                                } else {
                                    selectedThemes.insert(cuisine)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Welcome Splash View
struct WelcomeSplashView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var animate = false
    @State private var showConfetti = false
    
    private var content: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Main Message
                VStack(spacing: 24) {
                    Text("🎉")
                        .font(.system(size: 100))
                        .scaleEffect(animate ? 1.2 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animate)
                    
                    Text("You're All Set!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                        .multilineTextAlignment(.center)
                    
                    Text("Your culinary adventure awaits!\nLet's start cooking up some fun!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Achievement Preview
                FlavorQuestCard(style: .elevated) {
                    VStack(spacing: 16) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(FlavorQuestColors.accent)
                        
                        Text("Ready to earn your first achievement?")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("\"First Steps\" - Play your first game")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                animate = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showConfetti = true
            }
        }
    }
    
    var body: some View {
        let isSmallScreen = horizontalSizeClass == .compact || verticalSizeClass == .compact
        if isSmallScreen {
            ScrollView {
                content
                    .padding(.bottom, 160)
            }
        } else {
            content
        }
    }
}

// MARK: - Supporting Views and Models
struct TutorialStep {
    let title: String
    let description: String
    let icon: String
}

struct TutorialStepView: View {
    let step: TutorialStep
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: step.icon)
                .font(.system(size: 60))
                .foregroundColor(FlavorQuestColors.accent)
            
            Text(step.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(FlavorQuestColors.textPrimary)
            
            Text(step.description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(FlavorQuestColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        FlavorQuestCard(style: .compact) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(FlavorQuestColors.accent)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct DifficultyOptionView: View {
    let difficulty: GameDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                    
                    Text("\(Int(difficulty.timeLimit))s • \(difficulty.pointMultiplier, specifier: "%.1f")x points")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? FlavorQuestColors.accent : FlavorQuestColors.textSecondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? FlavorQuestColors.secondary : FlavorQuestColors.secondary.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? FlavorQuestColors.accent : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct CuisineSelectionView: View {
    let cuisine: CuisineType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(cuisine.icon)
                    .font(.system(size: 30))
                
                Text(cuisine.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? cuisine.color.opacity(0.3) : FlavorQuestColors.secondary.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? cuisine.color : Color.clear, lineWidth: 2)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct FlavorQuestTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FlavorQuestColors.secondary.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FlavorQuestColors.accent.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(FlavorQuestColors.textPrimary)
            .font(.system(size: 16, weight: .medium, design: .rounded))
    }
}

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                ConfettiPiece()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    @State private var location = CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: -50)
    @State private var opacity: Double = 1
    
    var body: some View {
        Rectangle()
            .fill(Color.random)
            .frame(width: 10, height: 10)
            .position(location)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 2...4))) {
                    location.y = UIScreen.main.bounds.height + 50
                    opacity = 0
                }
            }
    }
}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(GameManager())
        .environmentObject(UserSettings())
} 