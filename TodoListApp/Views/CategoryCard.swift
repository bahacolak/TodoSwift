import SwiftUI

struct CategoryCard: View {
    let category: Category
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(destination: CategoryDetailView(category: category)) {
            VStack(alignment: .leading, spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: getCategoryIcon(for: category.name))
                        .font(.system(size: 24))
                        .foregroundColor(Color(.systemBackground))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemBackground))
                    
                    Text("\(category.items?.count ?? 0) tasks")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemBackground).opacity(0.8))
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [category.uiColor, category.uiColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: category.uiColor.opacity(0.3), radius: 10, x: 0, y: 5)
            .overlay(alignment: .topTrailing) {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(.systemBackground))
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(12)
            }
        }
    }
    
    private func getCategoryIcon(for categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "today's tasks": return "calendar"
        case "personal": return "person.fill"
        case "work": return "briefcase.fill"
        case "shopping": return "cart.fill"
        case "health": return "heart.fill"
        default: return "folder.fill"
        }
    }
} 