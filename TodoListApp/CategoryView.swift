import SwiftUI
import SwiftData

struct CategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var newCategoryName = ""
    @State private var selectedColor = Color.blue
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    TextField("New category name", text: $newCategoryName)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ThemeColors.surface)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(ThemeColors.primary.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .tint(ThemeColors.primary)
                        .foregroundColor(ThemeColors.textPrimary)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                    
                    Button(action: addCategory) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [ThemeColors.primary, ThemeColors.primary.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(newCategoryName.isEmpty ? 1 : 1.05)
                    .animation(.spring(response: 0.3), value: newCategoryName.isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                List {
                    ForEach(categories, id: \.id) { category in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(category.uiColor)
                                .frame(width: 20, height: 20)
                            
                            HStack(spacing: 8) {
                                Text(category.name)
                                    .font(.system(.body, weight: .medium))
                                    .foregroundColor(ThemeColors.textPrimary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(category.items.count)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(ThemeColors.surface)
                                    .foregroundColor(ThemeColors.textPrimary)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(ThemeColors.divider, lineWidth: 1)
                                    )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 44)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeColors.surface)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    .onDelete(perform: deleteCategories)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(.plain)
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
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        let hexColor = String(format: "#%02X%02X%02X",
                            Int(selectedColor.components.red * 255),
                            Int(selectedColor.components.green * 255),
                            Int(selectedColor.components.blue * 255))
        let category = Category(name: newCategoryName, color: hexColor)
        modelContext.insert(category)
        newCategoryName = ""
    }
    
    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(categories[index])
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