import SwiftUI

private enum AppTheme {
    static let richBlack = Color(hex: "020B13")
    static let carbonFiber = Color(hex: "262626")
    static let funkyGold = Color(hex: "DAAB2D")
    static let bronzeCoin = Color(hex: "A57A03")

    static let appBackground = LinearGradient(
        colors: [richBlack, carbonFiber.opacity(0.95)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardBackground = Color.white.opacity(0.05)
    static let cardStroke = Color.white.opacity(0.10)
}

private extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleanHex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

private struct ElevatedCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.cardStroke, lineWidth: 1)
            )
    }
}

// MARK: - Root (Launch -> Main Tabs)
struct RootView: View {
    @State private var showMain = false

    var body: some View {
        SwiftUI.Group {
            if showMain {
                MainTabView()
            } else {
                LaunchView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            showMain = true
                        }
                    }
            }
        }
        .tint(AppTheme.funkyGold)
        .preferredColorScheme(.dark)
    }
}

// MARK: - 1) Launch Screen
struct LaunchView: View {
    var body: some View {
        ZStack {
            AppTheme.appBackground
            .ignoresSafeArea()

            Circle()
                .fill(AppTheme.funkyGold.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 24)
                .offset(x: 120, y: -250)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 220, height: 220)
                .blur(radius: 18)
                .offset(x: -130, y: 260)

            VStack(spacing: 20) {
                AppLogoMark()

                VStack(spacing: 6) {
                    Text("SmartCart")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.funkyGold)

                    Text("Shopping List & Tax Calculator")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.92))
                }

                VStack(spacing: 4) {
                    Text("Group Members")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))

                    VStack(spacing: 2) {
                        Text("Charlie Langmuir")
                        Text("Joel Chandra-Paul")
                        Text("Jingyu He")
                        Text("Yueyang Peng")
                    }
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.82))
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.carbonFiber.opacity(0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.bronzeCoin.opacity(0.32), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
}

private struct AppLogoMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.carbonFiber,
                            AppTheme.richBlack
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppTheme.funkyGold.opacity(0.65), lineWidth: 1.2)
                }
                .shadow(color: .black.opacity(0.28), radius: 20, x: 0, y: 12)

            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.funkyGold.opacity(0.18))
                        .frame(width: 54, height: 42)

                    Image(systemName: "cart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.funkyGold)
                }

                HStack(spacing: 6) {
                    Circle().fill(AppTheme.funkyGold).frame(width: 8, height: 8)
                    Circle().fill(AppTheme.bronzeCoin.opacity(0.85)).frame(width: 8, height: 8)
                    Circle().fill(AppTheme.bronzeCoin.opacity(0.55)).frame(width: 8, height: 8)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Main Tabs
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GroupsView()
            }
            .tabItem {
                Label("Lists", systemImage: "list.bullet")
            }

            NavigationStack {
                TaxSettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .toolbarBackground(AppTheme.richBlack, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - App Models
struct AppShoppingGroup: Identifiable, Hashable {
    let id: UUID
    var name: String
    var apiCategory: String
    var isCustom: Bool
    var isTaxable: Bool
}

struct AppShoppingItem: Identifiable, Hashable {
    let id: UUID
    var remoteID: Int?
    var name: String
    var price: Double
    var quantity: Int
    var purchased: Bool
    var category: String
    var details: String
    var imageURL: String
}

typealias StoredShoppingGroup = AppShoppingGroup
typealias StoredShoppingItem = AppShoppingItem

// MARK: - 2) Groups Screen (Home)
struct GroupsView: View {
    @State private var groups: [AppShoppingGroup] = [
        .init(id: UUID(), name: "Men's Clothing", apiCategory: "men's clothing", isCustom: false, isTaxable: true),
        .init(id: UUID(), name: "Women's Clothing", apiCategory: "women's clothing", isCustom: false, isTaxable: true),
        .init(id: UUID(), name: "Jewelry", apiCategory: "jewelery", isCustom: false, isTaxable: true),
        .init(id: UUID(), name: "Electronics", apiCategory: "electronics", isCustom: false, isTaxable: true)
    ]
    @State private var showAddGroup = false

    var body: some View {
        List {
            Section("Shopping Groups") {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        ElevatedCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(group.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text(group.isCustom ? "Custom group" : "Tap to open")
                                        .foregroundStyle(.secondary)
                                        .font(.footnote)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.bronzeCoin)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Groups")
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddGroup = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showAddGroup) {
            NavigationStack {
                AddGroupView { newGroup in
                    groups.append(newGroup)
                }
            }
        }
        .task {
            await loadCustomGroups()
        }
        .navigationDestination(for: AppShoppingGroup.self) { group in
            GroupDetailView(group: group)
        }
    }

    private func loadCustomGroups() async {
        do {
            let customGroups = try PersistenceController.shared.fetchCustomGroups()
            let defaultCategories = Set(groups.map(\.apiCategory))
            let newGroups = customGroups.filter { !defaultCategories.contains($0.apiCategory) }

            if !newGroups.isEmpty {
                groups.append(contentsOf: newGroups)
            }
        } catch {
            print("Failed to load custom groups: \(error.localizedDescription)")
        }
    }
}

// MARK: - 3) Group Detail / Shopping List Screen
struct GroupDetailView: View {
    let group: AppShoppingGroup

    @State private var items: [AppShoppingItem] = []
    @State private var showAddItem = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    @AppStorage("defaultTaxRate") private var defaultTaxRate = 0.13
    @AppStorage("mensClothingTaxable") private var mensClothingTaxable = true
    @AppStorage("womensClothingTaxable") private var womensClothingTaxable = true
    @AppStorage("jewelryTaxable") private var jewelryTaxable = true
    @AppStorage("electronicsTaxable") private var electronicsTaxable = true

    private var taxRate: Double {
        if group.isCustom {
            return group.isTaxable ? defaultTaxRate : 0
        }

        switch group.apiCategory.lowercased() {
        case "men's clothing":
            return mensClothingTaxable ? defaultTaxRate : 0
        case "women's clothing":
            return womensClothingTaxable ? defaultTaxRate : 0
        case "jewelery":
            return jewelryTaxable ? defaultTaxRate : 0
        case "electronics":
            return electronicsTaxable ? defaultTaxRate : 0
        default:
            return defaultTaxRate
        }
    }

    private var activeItems: [AppShoppingItem] {
        items.filter { !$0.purchased }
    }

    private var subtotal: Double {
        activeItems.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
    }

    private var tax: Double {
        subtotal * taxRate
    }

    private var total: Double {
        subtotal + tax
    }

    var body: some View {
        SwiftUI.Group {
            if isLoading {
                ProgressView("Loading items...")
                    .tint(AppTheme.funkyGold)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Retry") {
                        Task {
                            await loadProducts()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    Section("Items") {
                        if items.isEmpty {
                            Text("No items found for this category.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach($items) { $item in
                                ElevatedCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 12) {
                                            Button {
                                                item.purchased.toggle()
                                            } label: {
                                                Image(systemName: item.purchased ? "checkmark.circle.fill" : "circle")
                                                    .foregroundStyle(item.purchased ? AppTheme.funkyGold : .secondary)
                                            }
                                            .buttonStyle(.plain)

                                            AsyncImage(url: URL(string: item.imageURL)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                case .failure(_):
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundStyle(.secondary)
                                                case .empty:
                                                    ProgressView()
                                                        .tint(AppTheme.funkyGold)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(width: 45, height: 45)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.name)
                                                    .strikethrough(item.purchased)
                                                    .lineLimit(2)
                                                    .foregroundStyle(.white)

                                                Text(String(format: "$%.2f  x %d", item.price, item.quantity))
                                                    .font(.footnote)
                                                    .foregroundStyle(.secondary)
                                            }

                                            Spacer()
                                        }

                                        HStack(spacing: 12) {
                                            Spacer()

                                            Button {
                                                if item.quantity > 1 {
                                                    item.quantity -= 1
                                                }
                                            } label: {
                                                Image(systemName: "minus.circle")
                                                    .foregroundStyle(AppTheme.bronzeCoin)
                                            }
                                            .buttonStyle(.plain)

                                            Text("Qty \(item.quantity)")
                                                .font(.footnote.weight(.semibold))
                                                .foregroundStyle(AppTheme.funkyGold)
                                                .frame(minWidth: 52)

                                            Button {
                                                item.quantity += 1
                                            } label: {
                                                Image(systemName: "plus.circle")
                                                    .foregroundStyle(AppTheme.bronzeCoin)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                            }
                        }
                    }

                    Section("Summary") {
                        summaryRow(title: "Subtotal", value: subtotal)
                        summaryRow(title: "Tax", value: tax)
                        summaryRow(title: "Total", value: total, bold: true)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .navigationTitle(group.name)
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddItem = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            NavigationStack {
                AddEditItemView(groupName: group.name) { newItem in
                    items.append(newItem)
                }
            }
        }
        .onChange(of: items) { newItems in
            persistItems(newItems)
        }
        .task {
            if items.isEmpty {
                await loadProducts()
            }
        }
    }

    private func loadProducts() async {
        isLoading = true
        errorMessage = nil

        if let storedItems = loadStoredItems(), !storedItems.isEmpty {
            items = storedItems
            isLoading = false
            return
        }

        if group.isCustom {
            items = []
            isLoading = false
            return
        }

        do {
            let products = try await APIService.shared.fetchProducts()
            let filtered = products.filter {
                $0.category.lowercased() == group.apiCategory.lowercased()
            }

            items = filtered.map {
                AppShoppingItem(
                    id: UUID(),
                    remoteID: $0.id,
                    name: $0.title,
                    price: $0.price,
                    quantity: 1,
                    purchased: false,
                    category: $0.category,
                    details: $0.description,
                    imageURL: $0.image
                )
            }

            persistItems(items)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func loadStoredItems() -> [AppShoppingItem]? {
        do {
            return try PersistenceController.shared.fetchItems(for: group)
        } catch {
            print("Failed to load stored items: \(error.localizedDescription)")
            return nil
        }
    }

    private func persistItems(_ updatedItems: [AppShoppingItem]) {
        do {
            try PersistenceController.shared.replaceItems(updatedItems, for: group)
        } catch {
            print("Failed to save items: \(error.localizedDescription)")
        }
    }

    private func summaryRow(title: String, value: Double, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "$%.2f", value))
                .fontWeight(bold ? .bold : .regular)
        }
    }
}

// MARK: - 4) Add / Edit Item Screen
struct AddEditItemView: View {
    let groupName: String
    var onSave: (AppShoppingItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var priceText: String = ""
    @State private var qtyText: String = "1"

    var body: some View {
        Form {
            Section("Group") {
                Text(groupName)
                    .foregroundStyle(.secondary)
            }

            Section("Item Info") {
                TextField("Item name", text: $name)

                TextField("Price", text: $priceText)
                    .keyboardType(.decimalPad)

                TextField("Quantity", text: $qtyText)
                    .keyboardType(.numberPad)
            }
        }
        .navigationTitle("Add Item")
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    let price = Double(priceText) ?? 0
                    let qty = Int(qtyText) ?? 1

                    let item = AppShoppingItem(
                        id: UUID(),
                        remoteID: nil,
                        name: name.isEmpty ? "New Item" : name,
                        price: price,
                        quantity: max(1, qty),
                        purchased: false,
                        category: groupName,
                        details: "",
                        imageURL: ""
                    )

                    onSave(item)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct AddGroupView: View {
    var onSave: (AppShoppingGroup) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var isTaxable = true
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Group Info") {
                TextField("Group name", text: $name)
                Toggle("Taxable", isOn: $isTaxable)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Add Group")
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveGroup()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func saveGroup() {
        do {
            let group = try PersistenceController.shared.saveCustomGroup(name: name, isTaxable: isTaxable)
            onSave(group)
            dismiss()
        } catch {
            errorMessage = "Could not save this group right now."
        }
    }
}

// MARK: - 5) Tax Settings Screen
struct TaxSettingsView: View {
    @AppStorage("defaultTaxRate") private var defaultTaxRate = 0.13
    @AppStorage("mensClothingTaxable") private var mensClothingTaxable = true
    @AppStorage("womensClothingTaxable") private var womensClothingTaxable = true
    @AppStorage("jewelryTaxable") private var jewelryTaxable = true
    @AppStorage("electronicsTaxable") private var electronicsTaxable = true

    var body: some View {
        Form {
            Section("Default Tax Rate (%)") {
                Stepper(
                    "\(Int(defaultTaxRate * 100))%",
                    value: $defaultTaxRate,
                    in: 0.0...0.25,
                    step: 0.01
                )
            }

            Section("Category Taxable?") {
                Toggle("Men's Clothing", isOn: $mensClothingTaxable)
                Toggle("Women's Clothing", isOn: $womensClothingTaxable)
                Toggle("Jewelry", isOn: $jewelryTaxable)
                Toggle("Electronics", isOn: $electronicsTaxable)
            }

            Section("Prototype Note") {
                Text("This prototype uses real product data from Fake Store API. Tax settings are configurable locally.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Tax Settings")
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
