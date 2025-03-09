import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var searchText = ""
    @Binding var showingAddCategory: Bool
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [ThemeColors.primary, ThemeColors.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(buttonGradient)
                            
                            TextField("Search categories...", text: $searchText)
                                .foregroundColor(ThemeColors.textPrimary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: ThemeColors.primary.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        
                        if filteredCategories.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundStyle(buttonGradient)
                                
                                Text("No categories yet")
                                    .font(.title3)
                                    .foregroundColor(ThemeColors.textPrimary)
                                
                                Text("Tap + to add a new category")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            // Categories Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(filteredCategories) { category in
                                    CategoryCard(
                                        category: category,
                                        onDelete: { deleteCategory(category) }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("My Tasks")
            }
        }
    }
    
    private func deleteCategory(_ category: Category) {
        withAnimation {
            modelContext.delete(category)
        }
    }
}

struct ColorSelectionCircle: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(Color(.systemBackground), lineWidth: 2)
                    .padding(2)
            )
            .overlay(
                Image(systemName: "checkmark")
                    .foregroundColor(Color(.systemBackground))
                    .opacity(isSelected ? 1 : 0)
            )
            .onTapGesture(perform: action)
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var categoryName = ""
    @State private var selectedColorIndex = 0
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [ThemeColors.primary, ThemeColors.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var disabledGradient: LinearGradient {
        LinearGradient(
            colors: [Color.gray, Color.gray],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Category Name", text: $categoryName)
                        .autocapitalization(.words)
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ThemeColors.categoryColors.indices, id: \.self) { index in
                                ColorSelectionCircle(
                                    color: ThemeColors.categoryColors[index],
                                    isSelected: index == selectedColorIndex,
                                    action: { selectedColorIndex = index }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(buttonGradient)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCategory()
                        dismiss()
                    }
                    .disabled(categoryName.isEmpty)
                    .foregroundStyle(categoryName.isEmpty ? disabledGradient : buttonGradient)
                }
            }
        }
    }
    
    private func addCategory() {
        let selectedColor = ThemeColors.categoryColors[selectedColorIndex]
        let category = Category(name: categoryName, color: selectedColor.toHex() ?? "#000000")
        modelContext.insert(category)
    }
}

extension Color {
    func toHex() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        return String(format: "#%02X%02X%02X",
                     Int(red * 255),
                     Int(green * 255),
                     Int(blue * 255))
    }
}

#Preview {
    HomeView(showingAddCategory: .constant(false))
        .modelContainer(for: [Category.self, Item.self])
} 