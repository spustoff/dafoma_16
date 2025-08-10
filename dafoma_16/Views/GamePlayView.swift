import SwiftUI

struct GamePlayView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var userSettings: UserSettings
    @State private var showPauseMenu = false
    @State private var userInput = ""
    @State private var showHint = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            FlavorQuestColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Game Header
                gameHeader
                
                // Game Content Area
                ScrollView {
                    VStack(spacing: 24) {
                        // Game Mode Specific Content
                        gameContent
                        
                        // Action Area
                        actionArea
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 20)
                    .padding(.top, 20)
                    .frame(maxWidth: horizontalSizeClass == .regular ? 900 : .infinity)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPauseMenu) {
            PauseMenuView()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if gameManager.timeRemaining <= 10 && gameManager.isGameActive {
                withAnimation(.easeInOut(duration: 0.5)) {
                    pulseAnimation.toggle()
                }
            }
        }
    }
    
    // MARK: - Game Header
    private var gameHeader: some View {
        FlavorQuestCard(style: .compact) {
            HStack {
                // Pause Button
                Button(action: { showPauseMenu = true }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                }
                
                Spacer()
                
                // Game Mode Title
                VStack(spacing: 4) {
                    Text(gameManager.currentGameMode?.rawValue ?? "Game")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                    
                    Text("Score: \(gameManager.currentScore)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                }
                
                Spacer()
                
                // Timer
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(gameManager.timeRemaining <= 10 ? FlavorQuestColors.error : FlavorQuestColors.textPrimary)
                        .scaleEffect(pulseAnimation && gameManager.timeRemaining <= 10 ? 1.1 : 1.0)
                    
                    Text("TIME")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 20)
        .padding(.top, 20)
    }
    
    // MARK: - Game Content
    @ViewBuilder
    private var gameContent: some View {
        switch gameManager.currentGameMode {
        case .culinaryChallenge:
            culinaryChallengeContent
        case .tasteTest:
            tasteTestContent
        case .ingredientMastery:
            ingredientMasteryContent
        case .dailyQuest:
            dailyQuestContent
        case .arHunt:
            arHuntContent
        case .none:
            EmptyView()
        }
    }
    
    // MARK: - Culinary Challenge Content
    private var culinaryChallengeContent: some View {
        VStack(spacing: 24) {
            // Challenge Description
            FlavorQuestCard(style: .normal) {
                VStack(spacing: 12) {
                    Text("🍳 Create Your Masterpiece")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                    
                    Text("Select ingredients to create a unique recipe. Mix different categories for bonus points!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Available Ingredients
            VStack(alignment: .leading, spacing: 16) {
                Text("Available Ingredients")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: horizontalSizeClass == .regular ? 5 : 3), spacing: 12) {
                    ForEach(gameManager.currentIngredients) { ingredient in
                        IngredientCard(
                            ingredient: ingredient,
                            isSelected: gameManager.selectedIngredients.contains(where: { $0.id == ingredient.id })
                        ) {
                            gameManager.selectIngredient(ingredient)
                        }
                    }
                }
            }
            
            // Selected Ingredients
            if !gameManager.selectedIngredients.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Recipe")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textPrimary)
                    
                    FlavorQuestCard(style: .elevated) {
                        VStack(spacing: 12) {
                            HStack {
                                ForEach(gameManager.selectedIngredients) { ingredient in
                                    VStack(spacing: 4) {
                                        Text(ingredient.icon)
                                            .font(.system(size: 24))
                                        
                                        Text(ingredient.displayName)
                                            .font(.system(size: 10, weight: .medium, design: .rounded))
                                            .foregroundColor(FlavorQuestColors.textSecondary)
                                    }
                                    .onTapGesture {
                                        gameManager.removeSelectedIngredient(ingredient)
                                    }
                                }
                            }
                            
                            if gameManager.selectedIngredients.count >= 2 {
                                Button("Complete Recipe") {
                                    if gameManager.createRecipe() {
                                        // Show success feedback
                                    }
                                }
                                .buttonStyle(FlavorQuestButtonStyle(style: .accent))
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Taste Test Content
    private var tasteTestContent: some View {
        VStack(spacing: 24) {
            // Recipe Display
            if let recipe = gameManager.currentRecipe {
                FlavorQuestCard(style: .elevated) {
                    VStack(spacing: 16) {
                        Text("🍽️ \(recipe.displayName)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.accent)
                        
                        Text("Identify all the ingredients in this dish!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        // Recipe Visual (placeholder with emojis)
                        HStack(spacing: 8) {
                            ForEach(recipe.ingredients.prefix(5)) { ingredient in
                                Text(ingredient.icon)
                                    .font(.system(size: 32))
                                    .opacity(gameManager.guessedIngredients.contains(ingredient.name.lowercased()) ? 1.0 : 0.3)
                            }
                        }
                    }
                }
            }
            
            // Progress Indicator
            VStack(spacing: 8) {
                Text("Ingredients Found: \(gameManager.guessedIngredients.count) / \(gameManager.currentIngredients.count)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                
                ProgressView(value: Double(gameManager.guessedIngredients.count), total: Double(gameManager.currentIngredients.count))
                    .progressViewStyle(FlavorQuestProgressStyle())
                    .frame(height: 8)
            }
            
            // Input Area
            VStack(spacing: 16) {
                TextField("Type an ingredient name...", text: $userInput)
                    .textFieldStyle(FlavorQuestTextFieldStyle())
                    .onSubmit {
                        submitGuess()
                    }
                
                Button("Submit Guess") {
                    submitGuess()
                }
                .buttonStyle(FlavorQuestButtonStyle(style: .primary))
                .disabled(userInput.isEmpty)
            }
            
            // Guessed Ingredients
            if !gameManager.guessedIngredients.isEmpty {
                FlavorQuestCard(style: .normal) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Correct Guesses")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: horizontalSizeClass == .regular ? 5 : 3), spacing: 8) {
                            ForEach(Array(gameManager.guessedIngredients), id: \.self) { ingredient in
                                Text(ingredient.capitalized)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(FlavorQuestColors.success)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(FlavorQuestColors.success.opacity(0.2))
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Ingredient Mastery Content
    private var ingredientMasteryContent: some View {
        VStack(spacing: 24) {
            // Challenge Description
            FlavorQuestCard(style: .normal) {
                VStack(spacing: 12) {
                    Text("🧠 Ingredient Mastery")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                    
                    Text("Test your culinary knowledge! Identify as many ingredients as possible.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Ingredient Grid (scrambled display)
            VStack(alignment: .leading, spacing: 16) {
                Text("Identify These Ingredients")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: horizontalSizeClass == .regular ? 6 : 3), spacing: 16) {
                    ForEach(gameManager.currentIngredients) { ingredient in
                        VStack(spacing: 8) {
                            Text(ingredient.icon)
                                .font(.system(size: 40))
                                .opacity(gameManager.guessedIngredients.contains(ingredient.name.lowercased()) ? 0.3 : 1.0)
                            
                            if gameManager.guessedIngredients.contains(ingredient.name.lowercased()) {
                                Text(ingredient.displayName)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(FlavorQuestColors.success)
                            } else {
                                Text("?")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(FlavorQuestColors.textSecondary)
                            }
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(FlavorQuestColors.secondary.opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    gameManager.guessedIngredients.contains(ingredient.name.lowercased()) ? 
                                    FlavorQuestColors.success : Color.clear, 
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            
            // Input Area
            VStack(spacing: 16) {
                TextField("Type an ingredient name...", text: $userInput)
                    .textFieldStyle(FlavorQuestTextFieldStyle())
                    .onSubmit {
                        submitGuess()
                    }
                
                Button("Submit Guess") {
                    submitGuess()
                }
                .buttonStyle(FlavorQuestButtonStyle(style: .primary))
                .disabled(userInput.isEmpty)
            }
        }
    }
    
    // MARK: - Daily Quest Content
    private var dailyQuestContent: some View {
        VStack(spacing: 24) {
            if let quest = gameManager.dailyQuests.first(where: { !$0.isCompleted && !$0.isExpired }) {
                FlavorQuestCard(style: .elevated) {
                    VStack(spacing: 16) {
                        Text("📅 Daily Quest")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.accent)
                        
                        Text(quest.title)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textPrimary)
                        
                        Text(quest.description)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Reward: \(quest.reward.points) XP")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(FlavorQuestColors.accent)
                    }
                }
                
                // Quest-specific content based on type
                switch quest.questType {
                case .createRecipes:
                    culinaryChallengeContent
                case .identifyIngredients:
                    ingredientMasteryContent
                case .speedChallenge:
                    tasteTestContent
                default:
                    culinaryChallengeContent
                }
            }
        }
    }
    
    // MARK: - AR Hunt Content
    private var arHuntContent: some View {
        VStack(spacing: 24) {
            FlavorQuestCard(style: .elevated) {
                VStack(spacing: 16) {
                    Text("📱 AR Ingredient Hunt")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(FlavorQuestColors.accent)
                    
                    Text("Use your camera to find virtual ingredients in the real world!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(FlavorQuestColors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Launch AR Camera") { gameManager.presentARCamera = true }
                    .buttonStyle(FlavorQuestButtonStyle(style: .accent))
                }
            }
            
            // Fallback to regular ingredient hunt if AR not available
            Text("AR not available? Try the regular ingredient challenge below!")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(FlavorQuestColors.textSecondary)
            
            ingredientMasteryContent
        }
        .fullScreenCover(isPresented: $gameManager.presentARCamera) {
            ARCameraContainer()
        }
    }
    
    // MARK: - Action Area
    private var actionArea: some View {
        VStack(spacing: 16) {
            // Hint Button
            if gameManager.currentGameMode == .tasteTest || gameManager.currentGameMode == .ingredientMastery {
                Button(action: { showHint.toggle() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb")
                        Text("Need a hint?")
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .buttonStyle(FlavorQuestButtonStyle(style: .small))
                
                if showHint {
                    FlavorQuestCard(style: .compact) {
                        Text(getHint())
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(FlavorQuestColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            // End Game Button
            Button("End Game") {
                gameManager.endGame()
            }
            .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Helper Methods
    private var timeString: String {
        let minutes = Int(gameManager.timeRemaining) / 60
        let seconds = Int(gameManager.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func submitGuess() {
        guard !userInput.isEmpty else { return }
        
        let success = gameManager.guessIngredient(userInput)
        
        if success {
            // Success feedback
            userInput = ""
        } else {
            // Error feedback - maybe shake animation
            userInput = ""
        }
    }
    
    private func getHint() -> String {
        let unguessedIngredients = gameManager.currentIngredients.filter { 
            !gameManager.guessedIngredients.contains($0.name.lowercased()) 
        }
        
        if let randomIngredient = unguessedIngredients.randomElement() {
            return "Try looking for something from the \(randomIngredient.category.rawValue.lowercased()) category..."
        }
        
        return "You're doing great! Keep thinking about different ingredient types."
    }
}

// MARK: - Ingredient Card
struct IngredientCard: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(ingredient.icon)
                    .font(.system(size: 32))
                
                Text(ingredient.displayName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(FlavorQuestColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                // Rarity indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(ingredient.rarity.color)
                    .frame(height: 3)
            }
            .padding(12)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? FlavorQuestColors.accent.opacity(0.3) : FlavorQuestColors.secondary.opacity(0.8))
                    .shadow(color: isSelected ? FlavorQuestColors.accent.opacity(0.3) : Color.clear, radius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? FlavorQuestColors.accent : Color.clear, lineWidth: 2)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    GamePlayView()
        .environmentObject(GameManager())
        .environmentObject(UserSettings())
} 