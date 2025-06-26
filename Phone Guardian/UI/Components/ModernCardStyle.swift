import SwiftUI

// MARK: - Modern Card Style for iOS 26
struct ModernCardStyle: ViewModifier {
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(cornerRadius: CGFloat = 16, padding: CGFloat = 20) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.quaternary, lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Modern Button Style
struct ModernButtonStyle: ViewModifier {
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(backgroundColor: Color = .blue, foregroundColor: Color = .white) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
            )
    }
}

// MARK: - Modern Info Row Style
struct ModernInfoRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
            )
    }
}

// MARK: - View Extensions
extension View {
    func modernCard(cornerRadius: CGFloat = 16, padding: CGFloat = 20) -> some View {
        modifier(ModernCardStyle(cornerRadius: cornerRadius, padding: padding))
    }
    
    func modernButton(backgroundColor: Color = .blue, foregroundColor: Color = .white) -> some View {
        modifier(ModernButtonStyle(backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
    
    func modernInfoRow() -> some View {
        modifier(ModernInfoRowStyle())
    }
}

// MARK: - Modern Section Header
struct ModernSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }
}

// MARK: - Modern Loading View
struct ModernLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
} 