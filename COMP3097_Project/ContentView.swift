import SwiftUI

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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showMain = true
                        }
                    }
            }
        }
    }
}

// MARK: - 1) Launch Screen
struct LaunchView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 44, weight: .bold))

                Text("Shopping List & Tax Calculator")
                    .font(.title3)
                    .bold()

                Text("Early Prototype")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Using real product data from Fake Store API")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
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
    }
}

// MARK: - API Models
struct APIProduct: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
}

// MARK: - App Models
struct AppShoppingGroup: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var apiCategory: String
}

struct AppShoppingItem: Identifiable, Hashable {
    let id: Int
    var name: String
    var price: Double
    var quantity: Int
    var purchased: Bool
    var category: String
    var details: String
    var imageURL: String
}

// MARK: - API Service
final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchProducts() async throws -> [APIProduct] {
        let url = URL(string: "https://fakestoreapi.com/products")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([APIProduct].self, from: data)
    }
}

// MARK: - 2) Groups Screen (Home)
struct GroupsView: View {
    @State private var groups: [AppShoppingGroup] = [
        .init(name: "Men's Clothing", apiCategory: "men's clothing"),
        .init(name: "Women's Clothing", apiCategory: "women's clothing"),
        .init(name: "Jewelry", apiCategory: "jewelery"),
        .init(name: "Electronics", apiCategory: "electronics")
    ]

    var body: some View {
        List {
            Section("Shopping Groups") {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        HStack {
                            Text(group.name)
                            Spacer()
                            Text("Tap to open")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                    }
                }
            }
        }
        .navigationTitle("Groups")
        .navigationDestination(for: AppShoppingGroup.self) { group in
            GroupDetailView(group: group)
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

    private var subtotal: Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
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
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 12) {
                                        Button {
                                            item.purchased.toggle()
                                        } label: {
                                            Image(systemName: item.purchased ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(item.purchased ? .green : .secondary)
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
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: 45, height: 45)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name)
                                                .strikethrough(item.purchased)
                                                .lineLimit(2)

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
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)

                                        Text("Qty \(item.quantity)")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .frame(minWidth: 52)

                                        Button {
                                            item.quantity += 1
                                        } label: {
                                            Image(systemName: "plus.circle")
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
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
        .navigationTitle(group.name)
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
        .task {
            if items.isEmpty {
                await loadProducts()
            }
        }
    }

    private func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let products = try await APIService.shared.fetchProducts()
            let filtered = products.filter {
                $0.category.lowercased() == group.apiCategory.lowercased()
            }

            items = filtered.map {
                AppShoppingItem(
                    id: $0.id,
                    name: $0.title,
                    price: $0.price,
                    quantity: 1,
                    purchased: false,
                    category: $0.category,
                    details: $0.description,
                    imageURL: $0.image
                )
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    let price = Double(priceText) ?? 0
                    let qty = Int(qtyText) ?? 1

                    let item = AppShoppingItem(
                        id: Int.random(in: 10000...99999),
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
    }
}
