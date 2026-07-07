import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: VendlyStore
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: VendlyEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    totalHeader
                    List {
                        ForEach(store.entries) { entry in
                            entryRow(entry)
                                .listRowBackground(Theme.card)
                                .contentShape(Rectangle())
                                .onTapGesture { editingEntry = entry }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Vendly")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEntrySheet { title, amount in
                    store.add(title: title, amount: amount)
                }
            }
            .sheet(item: $editingEntry) { entry in
                AddEntrySheet(existing: entry) { title, amount in
                    var updated = entry
                    updated.title = title
                    updated.amount = amount
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var totalHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Running Total")
                .font(Theme.bodyFont)
                .foregroundStyle(.secondary)
            Text(store.total, format: .currency(code: "USD"))
                .font(Theme.titleFont)
                .foregroundStyle(Theme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private func entryRow(_ entry: VendlyEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(Theme.headlineFont)
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(entry.amount, format: .currency(code: "USD"))
                .font(Theme.monoFont)
                .foregroundStyle(entry.amount < 0 ? Theme.negative : Theme.positive)
        }
        .padding(.vertical, 4)
    }
}

struct AddEntrySheet: View {
    @Environment(\.dismiss) var dismiss
    var existing: VendlyEntry?
    var onSave: (String, Double) -> Void

    @State private var title: String = ""
    @State private var amountText: String = ""
    @FocusState private var isFocused: Bool

    init(existing: VendlyEntry? = nil, onSave: @escaping (String, Double) -> Void) {
        self.existing = existing
        self.onSave = onSave
        _title = State(initialValue: existing?.title ?? "")
        _amountText = State(initialValue: existing != nil ? String(existing!.amount) : "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item / Price") {
                    TextField("Title", text: $title)
                        .focused($isFocused)
                        .accessibilityIdentifier("entryTitleField")
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                        .accessibilityIdentifier("entryAmountField")
                }
            }
            .navigationTitle(existing == nil ? "Add Purchase" : "Edit Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelEntryButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let amount = Double(amountText) ?? 0
                        onSave(title.isEmpty ? "Untitled" : title, amount)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveEntryButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}
