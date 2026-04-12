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

private struct EmptyStateCard: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppTheme.funkyGold)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(message)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

private extension Double {
    var currencyText: String {
        String(format: "$%.2f", self)
    }

    var percentageText: String {
        String(format: "%.0f%%", self * 100)
    }

    var clampedCurrency: Double {
        max(0, self)
    }
}

// MARK: - Root
struct RootView: View {
    @State private var showMain = false
    @StateObject private var store = ShoppingStore()

    var body: some View {
        SwiftUI.Group {
            if showMain {
                MainTabView()
                    .environmentObject(store)
                    .task {
                        await store.loadInitialData()
                    }
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

// MARK: - Launch
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

                    Text("Shopping List, Checkout, and Tax History")
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
                        colors: [AppTheme.carbonFiber, AppTheme.richBlack],
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

// MARK: - Models
struct AppShoppingGroup: Identifiable, Hashable {
    let id: UUID
    var name: String
    var apiCategory: String
    var isCustom: Bool
    var isTaxable: Bool
}

struct AppShoppingItem: Identifiable, Hashable, Codable {
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

struct TaxRule: Codable, Hashable {
    var isTaxable: Bool
    var rate: Double
}

struct CheckoutCoupon: Hashable, Codable {
    enum Kind: String, Codable {
        case percent
        case fixedAmount
    }

    let code: String
    let description: String
    let kind: Kind
    let value: Double

    func discount(for subtotal: Double) -> Double {
        switch kind {
        case .percent:
            return subtotal * value
        case .fixedAmount:
            return value
        }
    }
}

struct CheckoutLineItem: Identifiable, Hashable, Codable {
    let id: UUID
    let groupName: String
    let itemName: String
    let quantity: Int
    let unitPrice: Double
    let lineSubtotal: Double
    let taxRate: Double
    let taxAmount: Double
}

struct CheckoutSummary: Hashable, Codable {
    let subtotal: Double
    let discount: Double
    let taxableSubtotal: Double
    let tax: Double
    let total: Double
}

struct ShoppingSession: Identifiable, Hashable, Codable {
    let id: UUID
    let completedAt: Date
    let couponCode: String?
    let couponDescription: String?
    let items: [CheckoutLineItem]
    let summary: CheckoutSummary
}

struct CheckoutPreview {
    let items: [CheckoutLineItem]
    let summary: CheckoutSummary
    let coupon: CheckoutCoupon?
}

typealias StoredShoppingGroup = AppShoppingGroup
typealias StoredShoppingItem = AppShoppingItem

enum ProductSortOption: String, CaseIterable, Identifiable {
    case featured = "Featured"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case nameAToZ = "Name: A to Z"
    case nameZToA = "Name: Z to A"

    var id: String { rawValue }
}

enum TaxCalculator {
    static func summary(items: [CheckoutLineItem], coupon: CheckoutCoupon?) -> CheckoutSummary {
        let subtotal = items.reduce(0) { $0 + $1.lineSubtotal }
        let rawDiscount = coupon?.discount(for: subtotal) ?? 0
        let discount = min(subtotal, rawDiscount).clampedCurrency
        let taxableSubtotal = max(0, subtotal - discount)
        let originalTaxableBase = subtotal == 0 ? 0 : subtotal

        let tax = items.reduce(0) { partial, item in
            let proportionalDiscount = originalTaxableBase == 0 ? 0 : (item.lineSubtotal / originalTaxableBase) * discount
            let adjustedLineSubtotal = max(0, item.lineSubtotal - proportionalDiscount)
            return partial + (adjustedLineSubtotal * item.taxRate)
        }

        return CheckoutSummary(
            subtotal: subtotal,
            discount: discount,
            taxableSubtotal: taxableSubtotal,
            tax: tax,
            total: max(0, taxableSubtotal + tax)
        )
    }
}

// MARK: - Store
@MainActor
final class ShoppingStore: ObservableObject {
    @Published private(set) var groups: [AppShoppingGroup] = []
    @Published private(set) var itemsByGroupID: [UUID: [AppShoppingItem]] = [:]
    @Published private(set) var history: [ShoppingSession] = []
    @Published private(set) var isLoaded = false

    private let persistence = PersistenceController.shared
    private let historyStore = ShoppingHistoryStore()
    private let taxRulesKey = "taxRulesByCategory"
    private let availableCoupons: [CheckoutCoupon] = [
        .init(code: "SAVE10", description: "10% off subtotal", kind: .percent, value: 0.10),
        .init(code: "WELCOME5", description: "$5 off subtotal", kind: .fixedAmount, value: 5.0),
        .init(code: "STUDENT15", description: "15% off subtotal", kind: .percent, value: 0.15)
    ]
    private let defaultGroups: [AppShoppingGroup] = [
        .init(id: UUID(uuidString: "6A2D509A-BA09-4B31-A103-7546A1C3A001")!, name: "Men's Clothing", apiCategory: "men's clothing", isCustom: false, isTaxable: true),
        .init(id: UUID(uuidString: "6A2D509A-BA09-4B31-A103-7546A1C3A002")!, name: "Women's Clothing", apiCategory: "women's clothing", isCustom: false, isTaxable: true),
        .init(id: UUID(uuidString: "6A2D509A-BA09-4B31-A103-7546A1C3A003")!, name: "Jewelry", apiCategory: "jewelery", isCustom: false, isTaxable: true),
        .init(id: UUID(uuidString: "6A2D509A-BA09-4B31-A103-7546A1C3A004")!, name: "Electronics", apiCategory: "electronics", isCustom: false, isTaxable: true)
    ]

    func loadInitialData() async {
        guard !isLoaded else { return }

        groups = defaultGroups
        history = historyStore.load()
        migrateLegacyTaxSettingsIfNeeded()
        await loadCustomGroups()

        for group in groups {
            itemsByGroupID[group.id] = loadStoredItems(for: group)
            ensureRuleExists(for: group)
        }

        isLoaded = true
    }

    func items(for group: AppShoppingGroup) -> [AppShoppingItem] {
        itemsByGroupID[group.id] ?? []
    }

    func pendingItemCount(for group: AppShoppingGroup) -> Int {
        items(for: group).filter { $0.purchased }.count
    }

    func pendingCartCount() -> Int {
        groups.reduce(0) { $0 + pendingItemCount(for: $1) }
    }

    func cartPreview(couponCode: String) -> CheckoutPreview {
        let coupon = coupon(for: couponCode)
        let lineItems = groups.flatMap { group -> [CheckoutLineItem] in
            let rule = taxRule(for: group)
            return items(for: group)
                .filter { $0.purchased }
                .map { item in
                    let lineSubtotal = item.price * Double(item.quantity)
                    let lineTax = rule.isTaxable ? lineSubtotal * rule.rate : 0

                    return CheckoutLineItem(
                        id: item.id,
                        groupName: group.name,
                        itemName: item.name,
                        quantity: item.quantity,
                        unitPrice: item.price,
                        lineSubtotal: lineSubtotal,
                        taxRate: rule.isTaxable ? rule.rate : 0,
                        taxAmount: lineTax
                    )
                }
        }

        return CheckoutPreview(
            items: lineItems,
            summary: TaxCalculator.summary(items: lineItems, coupon: coupon),
            coupon: coupon
        )
    }

    func taxRule(for group: AppShoppingGroup) -> TaxRule {
        let stored = taxRules()[ruleKey(for: group)]
        return stored ?? TaxRule(isTaxable: group.isTaxable, rate: 0.13)
    }

    func updateTaxRule(for group: AppShoppingGroup, isTaxable: Bool, rate: Double) {
        var rules = taxRules()
        rules[ruleKey(for: group)] = TaxRule(isTaxable: isTaxable, rate: rate)
        saveTaxRules(rules)
    }

    func coupon(for code: String) -> CheckoutCoupon? {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !normalized.isEmpty else { return nil }
        return availableCoupons.first { $0.code == normalized }
    }

    func allCoupons() -> [CheckoutCoupon] {
        availableCoupons
    }

    func ensureItemsLoaded(for group: AppShoppingGroup) async throws {
        if let current = itemsByGroupID[group.id], !current.isEmpty || group.isCustom {
            return
        }

        if group.isCustom {
            itemsByGroupID[group.id] = []
            return
        }

        let filtered = try await APIService.shared.fetchProducts(matchingGroup: group.apiCategory)
        let mapped = filtered.map {
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

        replaceItems(mapped, for: group)
    }

    func addItem(_ item: AppShoppingItem, to group: AppShoppingGroup) {
        var updated = items(for: group)
        updated.append(item)
        replaceItems(updated, for: group)
    }

    func updateItem(_ item: AppShoppingItem, in group: AppShoppingGroup) {
        var updated = items(for: group)
        guard let index = updated.firstIndex(where: { $0.id == item.id }) else { return }
        updated[index] = item
        replaceItems(updated, for: group)
    }

    func addGroup(name: String, isTaxable: Bool, taxRate: Double) throws {
        let group = try persistence.saveCustomGroup(name: name, isTaxable: isTaxable)
        groups.append(group)
        itemsByGroupID[group.id] = []
        updateTaxRule(for: group, isTaxable: isTaxable, rate: taxRate)
    }

    func completeCheckout(couponCode: String) throws {
        let preview = cartPreview(couponCode: couponCode)
        guard !preview.items.isEmpty else { return }

        let session = ShoppingSession(
            id: UUID(),
            completedAt: Date(),
            couponCode: preview.coupon?.code,
            couponDescription: preview.coupon?.description,
            items: preview.items,
            summary: preview.summary
        )

        history.insert(session, at: 0)
        try historyStore.save(history)

        for group in groups {
            let updated = items(for: group).map { item in
                var changed = item
                if changed.purchased {
                    changed.purchased = false
                }
                return changed
            }
            replaceItems(updated, for: group)
        }
    }

    func clearHistory() throws {
        history = []
        try historyStore.save(history)
    }

    private func replaceItems(_ items: [AppShoppingItem], for group: AppShoppingGroup) {
        itemsByGroupID[group.id] = items

        do {
            try persistence.replaceItems(items, for: group)
        } catch {
            print("Failed to save items for \(group.name): \(error.localizedDescription)")
        }
    }

    private func loadCustomGroups() async {
        do {
            let customGroups = try persistence.fetchCustomGroups()
            groups.append(contentsOf: customGroups)
        } catch {
            print("Failed to load custom groups: \(error.localizedDescription)")
        }
    }

    private func loadStoredItems(for group: AppShoppingGroup) -> [AppShoppingItem] {
        do {
            let storedItems = try persistence.fetchItems(for: group)
            let normalizedItems = normalizeInitialSelectionState(for: storedItems, group: group)

            if normalizedItems != storedItems {
                try persistence.replaceItems(normalizedItems, for: group)
            }

            return normalizedItems
        } catch {
            print("Failed to load items for \(group.name): \(error.localizedDescription)")
            return []
        }
    }

    private func normalizeInitialSelectionState(for items: [AppShoppingItem], group: AppShoppingGroup) -> [AppShoppingItem] {
        guard !group.isCustom, !items.isEmpty else {
            return items
        }

        let allRemoteItems = items.allSatisfy { $0.remoteID != nil }
        let allSelected = items.allSatisfy(\.purchased)

        guard allRemoteItems, allSelected else {
            return items
        }

        return items.map { item in
            var updated = item
            updated.purchased = false
            return updated
        }
    }

    private func ruleKey(for group: AppShoppingGroup) -> String {
        group.isCustom ? group.id.uuidString : group.apiCategory.lowercased()
    }

    private func taxRules() -> [String: TaxRule] {
        guard
            let data = UserDefaults.standard.data(forKey: taxRulesKey),
            let decoded = try? JSONDecoder().decode([String: TaxRule].self, from: data)
        else {
            return [:]
        }

        return decoded
    }

    private func saveTaxRules(_ rules: [String: TaxRule]) {
        if let data = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(data, forKey: taxRulesKey)
        }
    }

    private func ensureRuleExists(for group: AppShoppingGroup) {
        var rules = taxRules()
        let key = ruleKey(for: group)

        if rules[key] == nil {
            rules[key] = TaxRule(isTaxable: group.isTaxable, rate: 0.13)
            saveTaxRules(rules)
        }
    }

    private func migrateLegacyTaxSettingsIfNeeded() {
        var rules = taxRules()
        let defaults = UserDefaults.standard
        let mappings: [(String, String)] = [
            ("men's clothing", "mensClothingTaxable"),
            ("women's clothing", "womensClothingTaxable"),
            ("jewelery", "jewelryTaxable"),
            ("electronics", "electronicsTaxable")
        ]
        let defaultRate = defaults.object(forKey: "defaultTaxRate") as? Double ?? 0.13

        for (category, taxableKey) in mappings where rules[category] == nil {
            let isTaxable = defaults.object(forKey: taxableKey) as? Bool ?? true
            rules[category] = TaxRule(isTaxable: isTaxable, rate: defaultRate)
        }

        saveTaxRules(rules)
    }
}

private struct ShoppingHistoryStore {
    private let fileName = "shopping_history.json"

    func load() -> [ShoppingSession] {
        guard
            let url = try? fileURL(),
            let data = try? Data(contentsOf: url),
            let sessions = try? JSONDecoder().decode([ShoppingSession].self, from: data)
        else {
            return []
        }

        return sessions.sorted(by: { $0.completedAt > $1.completedAt })
    }

    func save(_ sessions: [ShoppingSession]) throws {
        guard let url = try fileURL(createDirectory: true) else { return }
        let data = try JSONEncoder().encode(sessions)
        try data.write(to: url, options: .atomic)
    }

    private func fileURL(createDirectory: Bool = false) throws -> URL? {
        guard let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        let directory = baseURL.appendingPathComponent("SmartCart", isDirectory: true)

        if createDirectory {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory.appendingPathComponent(fileName)
    }
}

// MARK: - Tabs
struct MainTabView: View {
    @EnvironmentObject private var store: ShoppingStore

    var body: some View {
        TabView {
            NavigationStack {
                GroupsView()
            }
            .tabItem {
                Label("Lists", systemImage: "list.bullet")
            }

            NavigationStack {
                CheckoutView()
            }
            .tabItem {
                Label("Checkout", systemImage: "creditcard")
            }
            .badge(store.pendingCartCount())

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
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

// MARK: - Groups
struct GroupsView: View {
    @EnvironmentObject private var store: ShoppingStore
    @State private var showAddGroup = false

    var body: some View {
        List {
            Section("Shopping Groups") {
                ForEach(store.groups) { group in
                    NavigationLink(value: group) {
                        ElevatedCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(group.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    let rule = store.taxRule(for: group)
                                    Text("\(store.pendingItemCount(for: group)) active items • \(rule.isTaxable ? rule.rate.percentageText : "Tax free")")
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
                AddGroupView()
            }
        }
        .navigationDestination(for: AppShoppingGroup.self) { group in
            GroupDetailView(group: group)
        }
    }
}

struct GroupDetailView: View {
    let group: AppShoppingGroup

    @EnvironmentObject private var store: ShoppingStore
    @State private var showAddItem = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var sortOption: ProductSortOption = .featured

    private var items: [AppShoppingItem] {
        store.items(for: group)
    }

    private var availableCategories: [String] {
        let values = Set(items.map(\.category).filter { !$0.isEmpty })
        return ["All"] + values.sorted()
    }

    private var filteredItems: [AppShoppingItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return items
            .filter { item in
                (selectedCategory == "All" || item.category == selectedCategory) &&
                (query.isEmpty ||
                 item.name.lowercased().contains(query) ||
                 item.details.lowercased().contains(query) ||
                 item.category.lowercased().contains(query))
            }
            .sorted(by: sortComparator)
    }

    private var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedCategory != "All"
    }

    private var sortComparator: (AppShoppingItem, AppShoppingItem) -> Bool {
        switch sortOption {
        case .featured:
            return { lhs, rhs in
                if lhs.purchased != rhs.purchased {
                    return lhs.purchased && !rhs.purchased
                }

                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        case .priceLowToHigh:
            return { lhs, rhs in
                if lhs.price == rhs.price {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhs.price < rhs.price
            }
        case .priceHighToLow:
            return { lhs, rhs in
                if lhs.price == rhs.price {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhs.price > rhs.price
            }
        case .nameAToZ:
            return { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        case .nameZToA:
            return { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
            }
        }
    }

    private var preview: CheckoutPreview {
        let lineItems = items.filter { $0.purchased }.map { item in
            let rule = store.taxRule(for: group)
            let lineSubtotal = item.price * Double(item.quantity)
            return CheckoutLineItem(
                id: item.id,
                groupName: group.name,
                itemName: item.name,
                quantity: item.quantity,
                unitPrice: item.price,
                lineSubtotal: lineSubtotal,
                taxRate: rule.isTaxable ? rule.rate : 0,
                taxAmount: rule.isTaxable ? lineSubtotal * rule.rate : 0
            )
        }

        return CheckoutPreview(
            items: lineItems,
            summary: TaxCalculator.summary(items: lineItems, coupon: nil),
            coupon: nil
        )
    }

    var body: some View {
        SwiftUI.Group {
            if isLoading {
                loadingState
            } else if let errorMessage {
                errorState(message: errorMessage)
            } else {
                List {
                    controlsSection

                    Section("Items") {
                        if items.isEmpty {
                            EmptyStateCard(
                                title: "No products yet",
                                systemImage: group.isCustom ? "square.and.pencil" : "shippingbox",
                                message: group.isCustom ? "No items in this custom group yet." : "No products were returned for this category."
                            )
                            .listRowBackground(Color.clear)
                        } else if filteredItems.isEmpty {
                            EmptyStateCard(
                                title: "No matching products",
                                systemImage: "magnifyingglass",
                                message: "Try a different search term, category filter, or sort option."
                            )
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(filteredItems) { item in
                                productRow(item)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                            }
                        }
                    }

                    Section("Summary") {
                        summaryRow(title: "Subtotal", value: preview.summary.subtotal)
                        summaryRow(title: "Tax", value: preview.summary.tax)
                        summaryRow(title: "Total", value: preview.summary.total, bold: true)
                    }

                    Section("Tax Rule") {
                        let rule = store.taxRule(for: group)
                        HStack {
                            Text("Applied rule")
                            Spacer()
                            Text(rule.isTaxable ? rule.rate.percentageText : "Tax free")
                                .foregroundStyle(AppTheme.funkyGold)
                        }

                        NavigationLink("Open Checkout") {
                            CheckoutView()
                        }
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search products")
        .sheet(isPresented: $showAddItem) {
            NavigationStack {
                AddEditItemView(group: group)
            }
        }
        .task {
            await loadProducts()
        }
    }

    private func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            try await store.ensureItemsLoaded(for: group)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private var controlsSection: some View {
        Section("Browse") {
            Picker("Category", selection: $selectedCategory) {
                ForEach(availableCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }

            Picker("Sort", selection: $sortOption) {
                ForEach(ProductSortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }

            if hasActiveFilters {
                Button("Clear Search and Filters") {
                    searchText = ""
                    selectedCategory = "All"
                    sortOption = .featured
                }
                .foregroundStyle(AppTheme.funkyGold)
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(AppTheme.funkyGold)
                .scaleEffect(1.2)

            Text("Loading products...")
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.appBackground.ignoresSafeArea())
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            EmptyStateCard(
                title: "Unable to Load Products",
                systemImage: "wifi.exclamationmark",
                message: message
            )

            Button("Try Again") {
                Task {
                    await loadProducts()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.funkyGold)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.appBackground.ignoresSafeArea())
    }

    private func productRow(_ item: AppShoppingItem) -> some View {
        ElevatedCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Button {
                        var updated = item
                        updated.purchased.toggle()
                        store.updateItem(updated, in: group)
                    } label: {
                        Image(systemName: item.purchased ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.purchased ? AppTheme.funkyGold : .secondary)
                    }
                    .buttonStyle(.plain)

                    productThumbnail(for: item, size: 52)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .lineLimit(2)
                            .foregroundStyle(.white)

                        Text(item.category)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.funkyGold)

                        Text("\(item.price.currencyText) x \(item.quantity)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        if !item.details.isEmpty {
                            Text(item.details)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer()
                }

                HStack(spacing: 12) {
                    Spacer()

                    Button {
                        guard item.quantity > 1 else { return }
                        var updated = item
                        updated.quantity -= 1
                        store.updateItem(updated, in: group)
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
                        var updated = item
                        updated.quantity += 1
                        store.updateItem(updated, in: group)
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(AppTheme.bronzeCoin)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ProductDetailView(group: group, itemID: item.id)
                    } label: {
                        Text("Details")
                            .font(.footnote.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.funkyGold)
                }
            }
        }
    }

    private func productThumbnail(for item: AppShoppingItem, size: CGFloat) -> some View {
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
                    .padding(12)
            case .empty:
                ProgressView()
                    .tint(AppTheme.funkyGold)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: size, height: size)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func summaryRow(title: String, value: Double, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value.currencyText)
                .fontWeight(bold ? .bold : .regular)
        }
    }
}

struct ProductDetailView: View {
    let group: AppShoppingGroup
    let itemID: UUID

    @EnvironmentObject private var store: ShoppingStore

    private var item: AppShoppingItem? {
        store.items(for: group).first(where: { $0.id == itemID })
    }

    var body: some View {
        SwiftUI.Group {
            if let item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ElevatedCard {
                            VStack(spacing: 18) {
                                detailImage(for: item)
                                    .frame(height: 240)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.category)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppTheme.funkyGold)

                                    Text(item.name)
                                        .font(.title2.weight(.bold))
                                        .foregroundStyle(.white)

                                    Text(item.price.currencyText)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.92))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        ElevatedCard {
                            VStack(alignment: .leading, spacing: 14) {
                                detailRow(title: "Shopping Group", value: group.name)
                                detailRow(title: "Unit Price", value: item.price.currencyText)
                                detailRow(title: "Quantity", value: "\(item.quantity)")
                                detailRow(title: "Status", value: item.purchased ? "In Cart" : "Not in Cart")

                                Divider()
                                    .overlay(Color.white.opacity(0.08))

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text(item.details.isEmpty ? "No description available." : item.details)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        ElevatedCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Quick Actions")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Button(item.purchased ? "Remove from Cart" : "Add to Cart") {
                                    var updated = item
                                    updated.purchased.toggle()
                                    store.updateItem(updated, in: group)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.funkyGold)

                                HStack(spacing: 16) {
                                    Button("Decrease Quantity") {
                                        guard item.quantity > 1 else { return }
                                        var updated = item
                                        updated.quantity -= 1
                                        store.updateItem(updated, in: group)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(AppTheme.bronzeCoin)
                                    .disabled(item.quantity <= 1)

                                    Button("Increase Quantity") {
                                        var updated = item
                                        updated.quantity += 1
                                        store.updateItem(updated, in: group)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(AppTheme.bronzeCoin)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            } else {
                EmptyStateCard(
                    title: "Product unavailable",
                    systemImage: "shippingbox",
                    message: "This product could not be found in the current shopping group."
                )
                .padding(24)
            }
        }
        .background(AppTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func detailImage(for item: AppShoppingItem) -> some View {
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
                    .padding(32)
            case .empty:
                ProgressView()
                    .tint(AppTheme.funkyGold)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Checkout
struct CheckoutView: View {
    @EnvironmentObject private var store: ShoppingStore
    @State private var couponCode = ""
    @State private var checkoutMessage: String?
    @State private var checkoutError: String?

    private var preview: CheckoutPreview {
        store.cartPreview(couponCode: couponCode)
    }

    private var groupedItems: [String: [CheckoutLineItem]] {
        Dictionary(grouping: preview.items, by: \.groupName)
    }

    var body: some View {
        List {
            if preview.items.isEmpty {
                emptyCartSection
            } else {
                cartItemsSection
                couponSection
                totalsSection

                if let checkoutMessage {
                    Section {
                        Text(checkoutMessage)
                            .foregroundStyle(AppTheme.funkyGold)
                    }
                }

                if let checkoutError {
                    Section {
                        Text(checkoutError)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Complete Checkout") {
                        finishCheckout()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Checkout")
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var emptyCartSection: some View {
        Section {
            EmptyStateCard(
                title: "Your cart is empty",
                systemImage: "cart",
                message: "Add items from any shopping group, then complete checkout here."
            )
            .listRowBackground(Color.clear)
        }
    }

    private var cartItemsSection: some View {
        Section("Current Cart") {
            ForEach(groupedItems.keys.sorted(), id: \.self) { groupName in
                cartGroupCard(groupName: groupName, items: groupedItems[groupName] ?? [])
            }
        }
    }

    private var couponSection: some View {
        Section("Coupon / Discount") {
            TextField("Optional code", text: $couponCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()

            Text(couponStatusText)
                .font(.footnote)
                .foregroundStyle(preview.coupon == nil && !couponCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : AppTheme.funkyGold)
        }
    }

    private var totalsSection: some View {
        Section("Totals") {
            summaryRow(title: "Subtotal", value: preview.summary.subtotal)
            summaryRow(title: "Discount", value: -preview.summary.discount)
            summaryRow(title: "Taxable Amount", value: preview.summary.taxableSubtotal)
            summaryRow(title: "Tax", value: preview.summary.tax)
            summaryRow(title: "Total", value: preview.summary.total, bold: true)
        }
    }

    private var couponStatusText: String {
        let codes = store.allCoupons().map(\.code).joined(separator: ", ")
        let trimmed = couponCode.trimmingCharacters(in: .whitespacesAndNewlines)

        if let coupon = preview.coupon {
            return "\(coupon.code): \(coupon.description)"
        }

        if trimmed.isEmpty {
            return "Available: \(codes)"
        }

        return "Code not recognized. Available: \(codes)"
    }

    private func cartGroupCard(groupName: String, items: [CheckoutLineItem]) -> some View {
        ElevatedCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(groupName)
                    .font(.headline)
                    .foregroundStyle(.white)

                ForEach(items) { item in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.itemName)
                                .foregroundStyle(.white)
                            Text("Qty \(item.quantity) • \(item.unitPrice.currencyText) each")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.lineSubtotal.currencyText)
                                .foregroundStyle(.white)
                            Text(item.taxRate == 0 ? "Tax free" : item.taxRate.percentageText)
                                .font(.footnote)
                                .foregroundStyle(AppTheme.funkyGold)
                        }
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
    }

    private func finishCheckout() {
        checkoutMessage = nil
        checkoutError = nil

        do {
            try store.completeCheckout(couponCode: couponCode)
            let total = preview.summary.total
            couponCode = ""
            checkoutMessage = "Session saved locally. Charged \(total.currencyText)."
        } catch {
            checkoutError = "Unable to save checkout history right now."
        }
    }

    private func summaryRow(title: String, value: Double, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value.currencyText)
                .fontWeight(bold ? .bold : .regular)
        }
    }
}

// MARK: - History
struct HistoryView: View {
    @EnvironmentObject private var store: ShoppingStore
    @State private var showClearAlert = false

    var body: some View {
        List {
            if store.history.isEmpty {
                emptyHistorySection
            } else {
                sessionsSection
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .navigationTitle("History")
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if !store.history.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        showClearAlert = true
                    }
                }
            }
        }
        .alert("Clear History?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                try? store.clearHistory()
            }
        } message: {
            Text("This removes locally saved completed shopping sessions.")
        }
        .navigationDestination(for: ShoppingSession.self) { session in
            HistoryDetailView(session: session)
        }
    }

    private var emptyHistorySection: some View {
        Section {
            EmptyStateCard(
                title: "No checkout history",
                systemImage: "tray",
                message: "Completed shopping sessions are stored locally and will appear here."
            )
            .listRowBackground(Color.clear)
        }
    }

    private var sessionsSection: some View {
        Section("Completed Sessions") {
            ForEach(store.history) { session in
                sessionRow(session)
            }
        }
    }

    private func sessionRow(_ session: ShoppingSession) -> some View {
        NavigationLink(value: session) {
            ElevatedCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(session.completedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(session.summary.total.currencyText)
                            .font(.headline)
                            .foregroundStyle(AppTheme.funkyGold)
                    }

                    Text("\(session.items.count) items • tax \(session.summary.tax.currencyText)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let couponCode = session.couponCode {
                        Text("Coupon: \(couponCode)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

struct HistoryDetailView: View {
    let session: ShoppingSession

    var body: some View {
        List {
            Section("Session") {
                row("Completed", session.completedAt.formatted(date: .abbreviated, time: .shortened))
                row("Subtotal", session.summary.subtotal.currencyText)
                row("Discount", (-session.summary.discount).currencyText)
                row("Tax", session.summary.tax.currencyText)
                row("Total", session.summary.total.currencyText)

                if let couponCode = session.couponCode {
                    row("Coupon", couponCode)
                }
            }

            Section("Items") {
                ForEach(session.items) { item in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.itemName)
                            Text("\(item.groupName) • Qty \(item.quantity)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(item.lineSubtotal.currencyText)
                            Text(item.taxRate == 0 ? "Tax free" : item.taxRate.percentageText)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Session Detail")
        .toolbarBackground(AppTheme.richBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Add Forms
struct AddEditItemView: View {
    let group: AppShoppingGroup

    @EnvironmentObject private var store: ShoppingStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var priceText = ""
    @State private var qtyText = "1"

    var body: some View {
        Form {
            Section("Group") {
                Text(group.name)
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
                    let item = AppShoppingItem(
                        id: UUID(),
                        remoteID: nil,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        price: Double(priceText) ?? 0,
                        quantity: max(1, Int(qtyText) ?? 1),
                        purchased: false,
                        category: group.apiCategory,
                        details: "",
                        imageURL: ""
                    )

                    store.addItem(item, to: group)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct AddGroupView: View {
    @EnvironmentObject private var store: ShoppingStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var isTaxable = true
    @State private var taxRate = 0.13
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Group Info") {
                TextField("Group name", text: $name)
                Toggle("Taxable", isOn: $isTaxable)
                Stepper("Tax rate \(taxRate.percentageText)", value: $taxRate, in: 0...0.25, step: 0.01)
                    .disabled(!isTaxable)
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
                    do {
                        try store.addGroup(name: name, isTaxable: isTaxable, taxRate: taxRate)
                        dismiss()
                    } catch {
                        errorMessage = "Could not save this group right now."
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

// MARK: - Settings
struct TaxSettingsView: View {
    @EnvironmentObject private var store: ShoppingStore

    var body: some View {
        Form {
            Section("Tax Rules By Category") {
                ForEach(store.groups.filter { !$0.isCustom }) { group in
                    TaxRuleEditor(group: group)
                }
            }

            if !store.groups.filter(\.isCustom).isEmpty {
                Section("Custom Group Rules") {
                    ForEach(store.groups.filter(\.isCustom)) { group in
                        TaxRuleEditor(group: group)
                    }
                }
            }

            Section("Checkout Notes") {
                Text("Tax is applied per group rule. Coupons reduce the subtotal before tax, and completed sessions are saved locally on this device.")
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

private struct TaxRuleEditor: View {
    let group: AppShoppingGroup

    @EnvironmentObject private var store: ShoppingStore
    @State private var isTaxable = true
    @State private var rate = 0.13

    var body: some View {
        let current = store.taxRule(for: group)

        VStack(alignment: .leading, spacing: 10) {
            Text(group.name)
                .font(.headline)

            Toggle("Taxable", isOn: Binding(
                get: { isTaxable },
                set: { newValue in
                    isTaxable = newValue
                    store.updateTaxRule(for: group, isTaxable: newValue, rate: rate)
                }
            ))

            Stepper("Rate \(rate.percentageText)", value: Binding(
                get: { rate },
                set: { newValue in
                    rate = newValue
                    store.updateTaxRule(for: group, isTaxable: isTaxable, rate: newValue)
                }
            ), in: 0...0.25, step: 0.01)
            .disabled(!isTaxable)

            Text(current.isTaxable ? "Currently taxed at \(current.rate.percentageText)." : "Currently tax free.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            isTaxable = current.isTaxable
            rate = current.rate
        }
    }
}
