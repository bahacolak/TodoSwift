import SwiftUI
import SwiftData

struct CategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var newCategoryName = ""
    @State private var selectedColor = Color.blue
    
    var body: some View {
        List {
            Section {
                HStack {
                    TextField("New category name", text: $newCategoryName)
                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                    Button(action: addCategory) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(ThemeColors.primary)
                    }
                }
            }
            
            Section {
                ForEach(categories, id: \.id) { category in
                    HStack {
                        Circle()
                            .fill(category.uiColor)
                            .frame(width: 20, height: 20)
                        Text(category.name)
                            .foregroundColor(ThemeColors.textPrimary)
                        Spacer()
                        Text("\(category.items.count)")
                            .foregroundColor(ThemeColors.secondary)
                    }
                }
                .onDelete(perform: deleteCategories)
            }
        }
        .navigationTitle("Categories")
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