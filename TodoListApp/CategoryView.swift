import SwiftUI
import SwiftData

struct CategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var newCategoryName = ""
    @State private var selectedColor = Color.blue
    @State private var showAddCategory = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                if showAddCategory {
                    addCategorySection
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if categories.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("No Categories", systemImage: "folder")
                        },
                        description: {
                            Text("Add a category to organize your tasks")
                        }
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categories) { category in
                                CategoryCard(category: category) {
                                    deleteCategory(category)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(duration: 0.6)) {
                            showAddCategory.toggle()
                        }
                    }) {
                        Image(systemName: showAddCategory ? "xmark" : "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [ThemeColors.primary, ThemeColors.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: ThemeColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .rotationEffect(.degrees(showAddCategory ? 45 : 0))
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(ThemeColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .foregroundStyle(ThemeColors.textPrimary)
        .tint(ThemeColors.primary)
        .navigationBarAppearance(backgroundColor: ThemeColors.background, foregroundColor: ThemeColors.textPrimary)
    }
    
    private var addCategorySection: some View {
        HStack(spacing: 12) {
            TextField("New category name", text: $newCategoryName)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeColors.surface)
                        .shadow(color: ThemeColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .tint(ThemeColors.primary)
                .foregroundColor(ThemeColors.textPrimary)
                .submitLabel(.done)
                .onSubmit {
                    if !newCategoryName.isEmpty {
                        addCategory()
                    }
                }
            
            ColorPicker("", selection: $selectedColor)
                .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        withAnimation {
            let hexColor = String(format: "#%02X%02X%02X",
                                Int(selectedColor.components.red * 255),
                                Int(selectedColor.components.green * 255),
                                Int(selectedColor.components.blue * 255))
            let category = Category(name: newCategoryName, color: hexColor)
            modelContext.insert(category)
            newCategoryName = ""
            showAddCategory = false
        }
    }
    
    private func deleteCategory(_ category: Category) {
        withAnimation {
            modelContext.delete(category)
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let onDelete: () -> Void
    @State private var offset = CGSize.zero
    @State private var isSwiped = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button
            Button(action: {
                withAnimation(.spring(duration: 0.3)) {
                    onDelete()
                }
            }) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 100)
                    .background(Color.red)
                    .cornerRadius(16)
            }
            
            // Card content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(category.uiColor)
                        .frame(width: 32, height: 32)
                    
                    Spacer()
                    
                    Text("\(category.items.count)")
                        .font(.system(.title3, weight: .semibold))
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                Text(category.name)
                    .font(.system(.body, weight: .medium))
                    .foregroundColor(ThemeColors.textPrimary)
                    .lineLimit(1)
            }
            .frame(height: 100)
            .padding(16)
            .background(ThemeColors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .offset(x: offset.width)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            self.offset = gesture.translation
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(duration: 0.3)) {
                            if self.offset.width < -50 {
                                self.offset.width = -80
                                self.isSwiped = true
                            } else {
                                self.offset = .zero
                                self.isSwiped = false
                            }
                        }
                    }
            )
            .onTapGesture {
                if isSwiped {
                    withAnimation(.spring(duration: 0.3)) {
                        self.offset = .zero
                        self.isSwiped = false
                    }
                }
            }
        }
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }
        
        return (r, g, b, o)
    }
}

extension View {
    func navigationBarAppearance(backgroundColor: Color, foregroundColor: Color) -> some View {
        self.onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(backgroundColor)
            appearance.titleTextAttributes = [.foregroundColor: UIColor(foregroundColor)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(foregroundColor)]
            appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(foregroundColor)]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().tintColor = UIColor(foregroundColor)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryView()
            .modelContainer(for: [Category.self, Item.self])
    }
} 