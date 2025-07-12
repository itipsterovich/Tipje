import SwiftUI

struct CatalogChoresModal: View {
    var onSave: ([String], [CatalogChore]) -> Void
    var initiallySelected: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var authManager: AuthManager
    @State private var selected: Set<String>
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    @State private var expandedChoreId: String? = nil
    @State private var customChores: [CatalogChore] = []
    @State private var isCreatingCustomChore = false
    @State private var newCustomChore: CatalogChore? = nil
    @State private var editingCustomChoreId: String? = nil
    // Remove local colorPalette and colorHex arrays
    // Use tipjeColorPalette for all color assignments
    let catalog = choresCatalog
    init(onSave: @escaping ([String], [CatalogChore]) -> Void, initiallySelected: [String]) {
        self.onSave = onSave
        self.initiallySelected = initiallySelected
        _selected = State(initialValue: Set(initiallySelected))
    }
    var body: some View {
        return BannerPanelLayout(
            bannerColor: Color(hex: "#C3BCA5"),
            bannerHeight: 100,
            containerOffsetY: -36,
            content: {
                VStack(spacing: 0) {
                    PageTitle("Chore Catalog") {
                        ButtonRegular(iconName: "icon_close", variant: .light) { save() }
                        .accessibilityIdentifier("saveChoresButton")
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                    ScrollView {
                        VStack(spacing: 14) {
                            if isCreatingCustomChore || editingCustomChoreId != nil {
                                HStack(spacing: 14) {
                                    if horizontalSizeClass == .compact {
                                        ButtonTextiPhone(title: "Save", variant: .primary, action: { saveCustomChore() }, fullWidth: true)
                                            .disabled(!canSaveCustomChore)
                                        ButtonTextiPhone(title: "Cancel", variant: .secondary, action: { cancelCustomChore() }, fullWidth: true)
                                    } else {
                                        ButtonText(title: "Save", variant: .primary, action: { saveCustomChore() }, fontSize: 24, fullWidth: true)
                                            .disabled(!canSaveCustomChore)
                                        ButtonText(title: "Cancel", variant: .secondary, action: { cancelCustomChore() }, fontSize: 24, fullWidth: true)
                                    }
                                }
                            }
                            if !isCreatingCustomChore && editingCustomChoreId == nil {
                                if horizontalSizeClass == .compact {
                                    Button(action: { startCreatingCustomChore() }) {
                                        HStack(spacing: 8) {
                                            Image("icon_plus").resizable().frame(width: 20, height: 20)
                                            Text("Create Chore").font(.custom("Inter-Regular_Medium", size: 17))
                                        }
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(Color(hex: "#EAF3EA"))
                                        .cornerRadius(12)
                                    }
                                } else {
                                    Button(action: { startCreatingCustomChore() }) {
                                        HStack(spacing: 12) {
                                            Image("icon_plus").resizable().frame(width: 24, height: 24)
                                            Text("Create Chore").font(.custom("Inter-Regular_Medium", size: 24))
                                        }
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, minHeight: 56)
                                        .background(Color(hex: "#EAF3EA"))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            if let custom = newCustomChore, editingCustomChoreId == nil {
                                EditableCustomChoreCard(
                                    chore: custom,
                                    onTitleChange: { newTitle in newCustomChore?.title = newTitle },
                                    onPeanutsChange: { newPeanuts in newCustomChore?.peanuts = newPeanuts },
                                    color: custom.color,
                                    isEditing: true
                                )
                            } else if let editingId = editingCustomChoreId, let item = customChores.first(where: { $0.id == editingId }) {
                                EditableCustomChoreCard(
                                    chore: item,
                                    onTitleChange: { newTitle in updateEditingCustomChoreTitle(newTitle, id: item.id) },
                                    onPeanutsChange: { newPeanuts in updateEditingCustomChorePeanuts(newPeanuts, id: item.id) },
                                    color: item.color,
                                    isEditing: true
                                )
                            }
                            ForEach(customChores) { item in
                                if editingCustomChoreId == item.id {
                                    EmptyView()
                                } else {
                                    choreCard(for: item)
                                        .contextMenu {
                                            Button("Edit") { startEditingCustomChore(item) }
                                            Button("Delete", role: .destructive) { deleteCustomChore(id: item.id) }
                                        }
                                }
                            }
                            ForEach(catalog, id: \.id) { item in
                                choreCard(for: item)
                            }
                        }
                        .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                        .padding(.top, horizontalSizeClass == .compact ? 0 : 8)
                        .padding(.bottom, horizontalSizeClass == .compact ? 0 : 24)
                    }
                }
            }
        )
        .overlay(
            Group {
                if showToast {
                    AppleStyleToast(message: toastMessage, systemImage: toastIcon, iconColor: toastIconColor)
                        .zIndex(1)
                }
            },
            alignment: .center
        )
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear(perform: fetchCustomChores)
    }
    private func choreCard(for item: CatalogChore) -> some View {
        let isSelected = selected.contains(item.id)
        let isExpanded = expandedChoreId == item.id
        return ChoreAdultCard(
            chore: Chore(id: item.id, title: item.title, peanutValue: item.peanuts, isActive: true),
            onArchive: {
                if isSelected {
                    selected.remove(item.id)
                    toastMessage = "Removed from your Hub"
                    toastIcon = "minus.circle.fill"
                    toastIconColor = Color(hex: "#BBB595")
                } else {
                    selected.insert(item.id)
                    toastMessage = "Added to your Hub"
                    toastIcon = "checkmark.circle.fill"
                    toastIconColor = Color(hex: "#799B44")
                }
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
            },
            selected: isSelected,
            baseColor: item.color,
            onTap: {
                if isExpanded {
                    expandedChoreId = nil
                } else {
                    expandedChoreId = item.id
                }
            },
            expanded: isExpanded
        )
        .accessibilityIdentifier("choreCell_\(item.id)")
    }
    private func save() {
        onSave(Array(selected), customChores)
        dismiss()
    }
    // MARK: - Custom Chore Logic
    private func fetchCustomChores() {
        guard let userId = authManager.firebaseUser?.uid else { return }
        FirestoreManager.shared.fetchCustomChores(userId: userId) { chores in
            DispatchQueue.main.async {
                self.customChores = chores.filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
            }
        }
    }
    private func startCreatingCustomChore() {
        if isCreatingCustomChore || editingCustomChoreId != nil { return }
        editingCustomChoreId = nil
        let color = cardPalette[(choresCatalog.count + customChores.count) % cardPalette.count]
        newCustomChore = CatalogChore(id: UUID().uuidString, title: "", peanuts: 1, color: color, colorHex: color.toHexString(), isCustom: true)
        isCreatingCustomChore = true
    }
    private func saveCustomChore() {
        guard let chore = newCustomChore, canSaveCustomChore, let userId = authManager.firebaseUser?.uid else { return }
        // Assign color from cardPalette using stateless pattern (matches curated logic)
        let allChores = choresCatalog + customChores
        let colorIndex = allChores.count % cardPalette.count
        var coloredChore = chore
        coloredChore.color = cardPalette[colorIndex]
        newCustomChore = nil
        isCreatingCustomChore = false
        editingCustomChoreId = nil
        FirestoreManager.shared.addCustomChore(userId: userId, chore: coloredChore) { error in
            if error == nil {
                customChores.insert(coloredChore, at: 0)
            }
        }
    }
    private func cancelCustomChore() {
        newCustomChore = nil
        isCreatingCustomChore = false
        editingCustomChoreId = nil
    }
    private var canSaveCustomChore: Bool {
        guard let chore = newCustomChore else { return false }
        return !chore.title.trimmingCharacters(in: .whitespaces).isEmpty && (1...9).contains(chore.peanuts)
    }
    private func startEditingCustomChore(_ chore: CatalogChore) {
        editingCustomChoreId = chore.id
        newCustomChore = chore
    }
    private func updateEditingCustomChoreTitle(_ newTitle: String, id: String) {
        if newCustomChore?.id == id {
            newCustomChore?.title = newTitle
        }
    }
    private func updateEditingCustomChorePeanuts(_ newPeanuts: Int, id: String) {
        if newCustomChore?.id == id {
            newCustomChore?.peanuts = newPeanuts
        }
    }
    private func deleteCustomChore(id: String) {
        guard let userId = authManager.firebaseUser?.uid else { return }
        FirestoreManager.shared.deleteCustomChore(userId: userId, choreId: id) { error in
            if error == nil {
                fetchCustomChores()
                if newCustomChore?.id == id { newCustomChore = nil; editingCustomChoreId = nil }
            }
        }
    }
}

struct EditableCustomChoreCard: View {
    @State var chore: CatalogChore
    var onTitleChange: (String) -> Void
    var onPeanutsChange: (Int) -> Void
    var color: Color
    var isEditing: Bool
    @State private var peanutsText: String = ""
    @State private var titleText: String = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 14 : 20, style: .continuous)
                    .strokeBorder(color, lineWidth: 2)
                if (titleText.isEmpty && chore.title.isEmpty) {
                    Text("Enter your new family chore 🧹")
                        .foregroundColor(color)
                        .font(.custom("Inter-Medium", size: horizontalSizeClass == .compact ? 17 : 24))
                        .padding(.leading, horizontalSizeClass == .compact ? 14 : 24)
                        .padding(.trailing, horizontalSizeClass == .compact ? 14 : 24)
                        .padding(.vertical, 14)
                        .lineLimit(2)
                }
                TextField(
                    "",
                    text: Binding(
                        get: { titleText.isEmpty ? chore.title : titleText },
                        set: { newValue in
                            titleText = newValue
                            onTitleChange(newValue)
                        }
                    )
                )
                .padding(.leading, horizontalSizeClass == .compact ? 14 : 24)
                .padding(.trailing, horizontalSizeClass == .compact ? 14 : 24)
                .padding(.vertical, 14)
                .foregroundColor(color)
                .font(.custom("Inter-Medium", size: horizontalSizeClass == .compact ? 17 : 24))
                .accentColor(color)
                .lineLimit(2)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: horizontalSizeClass == .compact ? 70 : 90, maxHeight: horizontalSizeClass == .compact ? 70 : 90, alignment: .leading)
            .layoutPriority(1)
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: horizontalSizeClass == .compact ? 42 : 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(color)
            .frame(width: 1.5, height: horizontalSizeClass == .compact ? 42 : 60)
            .padding(.vertical, horizontalSizeClass == .compact ? 14 : 15)
            ZStack {
                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 14 : 20, style: .continuous)
                    .strokeBorder(color, lineWidth: 2)
                    .background(Color.white.cornerRadius(horizontalSizeClass == .compact ? 14 : 20))
                HStack(spacing: 0) {
                    Spacer().frame(width: horizontalSizeClass == .compact ? 10 : 24)
                    TextField("1-9", text: Binding(
                        get: {
                            peanutsText.isEmpty ? String(chore.peanuts) : peanutsText
                        },
                        set: { newValue in
                            let filtered = newValue.filter { "123456789".contains($0) }
                            if let intVal = Int(filtered), (1...9).contains(intVal) {
                                peanutsText = filtered
                                onPeanutsChange(intVal)
                            } else if filtered.isEmpty {
                                peanutsText = ""
                                onPeanutsChange(1)
                            }
                        }
                    ))
                    .keyboardType(.numberPad)
                    .foregroundColor(color)
                    .font(.custom("Inter-Medium", size: horizontalSizeClass == .compact ? 17 : 24))
                    .frame(width: horizontalSizeClass == .compact ? 20 : 30, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    Spacer().frame(width: 4)
                    Image("icon_peanut")
                        .resizable()
                        .frame(width: horizontalSizeClass == .compact ? 20 : 24, height: horizontalSizeClass == .compact ? 20 : 24)
                        .foregroundColor(color)
                    Spacer().frame(width: horizontalSizeClass == .compact ? 12 : 14)
                }
                .frame(height: horizontalSizeClass == .compact ? 70 : 90)
                .frame(width: horizontalSizeClass == .compact ? 100 : 144)
            }
            .layoutPriority(0)
        }
        .frame(height: horizontalSizeClass == .compact ? 70 : 90)
        .background(Color.white)
        .cornerRadius(horizontalSizeClass == .compact ? 14 : 20)
        .shadow(color: color.opacity(0.08), radius: 2, x: 0, y: 1)
        .onAppear {
            titleText = chore.title
            peanutsText = String(chore.peanuts)
        }
    }
} 