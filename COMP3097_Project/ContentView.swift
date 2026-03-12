import SwiftUI



// MARK: - Root (Launch -> Main Tabs)
struct RootView: View {
    @State private var showMain = false

    var body: some View {
        Group {
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
                    .font(.title3).bold()
                Text("Milestone 1 Skeleton")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
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

// MARK: - Models (Milestone Fake Data)
struct ShoppingGroup: Identifiable, Hashable {
    let id = UUID()
    var name: String
}

struct ShoppingItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var price: Double
    var quantity: Int
    var purchased: Bool
}

// MARK: - 2) Groups Screen (Home)
struct GroupsView: View {
    @State private var groups: [ShoppingGroup] = [
        .init(name: "Food"),
        .init(name: "Medication"),
        .init(name: "Cleaning Products")
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
        .navigationDestination(for: ShoppingGroup.self) { group in
            GroupDetailView(group: group)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    groups.append(.init(name: "New Group \(groups.count + 1)"))
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// MARK: - 3) Group Detail / Shopping List Screen
struct GroupDetailView: View {
    let group: ShoppingGroup

    @State private var items: [ShoppingItem] = [
        .init(name: "Milk", price: 3.00, quantity: 2, purchased: false),
        .init(name: "Bread", price: 2.50, quantity: 1, purchased: true),
        .init(name: "Apple", price: 1.00, quantity: 6, purchased: false),
    ]

    @State private var showAddItem = false


    private var taxRate: Double { 0.13 }

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
        List {
            Section("Items") {
                ForEach($items) { $item in
                    HStack(spacing: 12) {
                        Button {
                            item.purchased.toggle()
                        } label: {
                            Image(systemName: item.purchased ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.purchased ? .green : .secondary)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .strikethrough(item.purchased)
                            Text(String(format: "$%.2f  x %d", item.price, item.quantity))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
            }

            Section("Summary") {
                summaryRow(title: "Subtotal", value: subtotal)
                summaryRow(title: "Tax", value: tax)
                summaryRow(title: "Total", value: total, bold: true)
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
    var onSave: (ShoppingItem) -> Void

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
                    let item = ShoppingItem(
                        name: name.isEmpty ? "New Item" : name,
                        price: price,
                        quantity: max(1, qty),
                        purchased: false
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
    @State private var taxRateText: String = "13"

    @State private var foodTaxable = false
    @State private var medicationTaxable = false
    @State private var cleaningTaxable = true

    var body: some View {
        Form {
            Section("Default Tax Rate (%)") {
                TextField("e.g. 13", text: $taxRateText)
                    .keyboardType(.decimalPad)
            }

            Section("Category Taxable?") {
                Toggle("Food", isOn: $foodTaxable)
                Toggle("Medication", isOn: $medicationTaxable)
                Toggle("Cleaning Products", isOn: $cleaningTaxable)
            }

            Section("Milestone Note") {
                Text("This screen is a skeleton for the tax configuration feature. Logic will be implemented in a later milestone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Tax Settings")
    }
}
