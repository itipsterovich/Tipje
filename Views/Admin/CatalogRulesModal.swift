import SwiftUI
// Remove 'import Models' if present

struct CatalogRulesModal: View {
    var onSave: ([String], [CatalogRule]) -> Void
    var initiallySelected: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var authManager: AuthManager
    @State private var selected: Set<String>
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    @State private var expandedRuleId: String? = nil
    @State private var customRules: [CatalogRule] = []
    @State private var isCreatingCustomRule = false
    @State private var newCustomRule: CatalogRule? = nil
    @State private var editingCustomRuleId: String? = nil
    let catalog = rulesCatalog // This is [CatalogRule]
    // Remove local colorPalette and colorHex arrays
    // Use tipjeColorPalette for all color assignments
    // Remove all colorIndex state and logic
    // For new custom rule creation and preview, always assign color using the stateless pattern
    init(onSave: @escaping ([String], [CatalogRule]) -> Void, initiallySelected: [String]) {
        self.onSave = onSave
        self.initiallySelected = initiallySelected
        _selected = State(initialValue: Set(initiallySelected))
    }
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A2AFC1"),
            bannerHeight: 100,
            containerOffsetY: -36,
            content: {
                VStack(spacing: 0) {
                    PageTitle("Rule Catalog") {
                        ButtonRegular(iconName: "icon_close", variant: .light) {
                            saveAndClose()
                        }
                        .accessibilityIdentifier("saveRulesButton")
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                    ScrollView {
                        VStack(spacing: 14) {
                            // Show Save/Cancel buttons above the list when creating or editing
                            if isCreatingCustomRule || editingCustomRuleId != nil {
                                HStack(spacing: 14) {
                                    if horizontalSizeClass == .compact {
                                        ButtonTextiPhone(title: "Save", variant: .primary, action: { saveCustomRule() }, fullWidth: true)
                                            .disabled(!canSaveCustomRule)
                                        ButtonTextiPhone(title: "Cancel", variant: .secondary, action: { cancelCustomRule() }, fullWidth: true)
                                    } else {
                                        ButtonText(title: "Save", variant: .primary, action: { saveCustomRule() }, fontSize: 24, fullWidth: true)
                                            .disabled(!canSaveCustomRule)
                                        ButtonText(title: "Cancel", variant: .secondary, action: { cancelCustomRule() }, fontSize: 24, fullWidth: true)
                                    }
                                }
                            } else {
                                // Create Rule button (shown when not creating or editing)
                                if horizontalSizeClass == .compact {
                                    Button(action: { startCreatingCustomRule() }) {
                                        HStack(spacing: 8) {
                                            Image("icon_plus")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Create Rule")
                                                .font(.custom("Inter-Regular_Medium", size: 17))
                                        }
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(Color(hex: "#EAF3EA"))
                                        .cornerRadius(12)
                                    }
                                } else {
                                    Button(action: { startCreatingCustomRule() }) {
                                        HStack(spacing: 12) {
                                            Image("icon_plus")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            Text("Create Rule")
                                                .font(.custom("Inter-Regular_Medium", size: 24))
                                        }
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, minHeight: 56)
                                        .background(Color(hex: "#EAF3EA"))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            // Only one editable card for newCustomRule or editing, at the top of the list
                            if let custom = newCustomRule, editingCustomRuleId == nil {
                                EditableCustomRuleCard(
                                    rule: custom,
                                    onTitleChange: { newTitle in newCustomRule?.title = newTitle },
                                    onPeanutsChange: { newPeanuts in newCustomRule?.peanuts = newPeanuts },
                                    color: custom.color,
                                    isEditing: true
                                )
                            } else if let editingId = editingCustomRuleId, let item = customRules.first(where: { $0.id == editingId }) {
                                EditableCustomRuleCard(
                                    rule: item,
                                    onTitleChange: { newTitle in updateEditingCustomRuleTitle(newTitle, id: item.id) },
                                    onPeanutsChange: { newPeanuts in updateEditingCustomRulePeanuts(newPeanuts, id: item.id) },
                                    color: item.color,
                                    isEditing: true
                                )
                            }
                            // Custom rules (saved)
                            ForEach(customRules) { item in
                                if editingCustomRuleId == item.id {
                                    // Do not render the editable card here; it's already at the top
                                    EmptyView()
                                } else {
                                    RuleAdultCard(
                                        rule: Rule(id: item.id, title: item.title, peanutValue: item.peanuts, isActive: true),
                                        onArchive: {
                                            if selected.contains(item.id) {
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
                                        selected: selected.contains(item.id),
                                        baseColor: item.color,
                                        onTap: {
                                            if expandedRuleId == item.id {
                                                expandedRuleId = nil
                                            } else {
                                                expandedRuleId = item.id
                                            }
                                        },
                                        expanded: expandedRuleId == item.id
                                    )
                                    .accessibilityIdentifier("ruleCell_\(item.id)")
                                    .contextMenu {
                                        Button("Edit") { startEditingCustomRule(item) }
                                        Button("Delete", role: .destructive) { deleteCustomRule(id: item.id) }
                                    }
                                }
                            }
                            // Curated rules
                            ForEach(catalog, id: \.id) { item in
                                ruleCard(for: item)
                            }
                        }
                        .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                        .padding(.top, horizontalSizeClass == .compact ? 0 : 8)
                        .padding(.bottom, horizontalSizeClass == .compact ? 0 : 24)
                    }
                }
            }
        )
        .onAppear(perform: fetchCustomRules)
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
    }
    
    private func ruleCard(for item: CatalogRule) -> some View {
        let isSelected = selected.contains(item.id)
        let isExpanded = expandedRuleId == item.id
        return RuleAdultCard(
            rule: Rule(id: item.id, title: item.title, peanutValue: item.peanuts, isActive: true),
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
                    expandedRuleId = nil
                } else {
                    expandedRuleId = item.id
                }
            },
            expanded: isExpanded
        )
        .accessibilityIdentifier("ruleCell_\(item.id)")
    }
    private func saveAndClose() {
        onSave(Array(selected), customRules)
        dismiss()
    }
    // MARK: - Custom Rule Logic
    private func fetchCustomRules() {
        guard let userId = authManager.firebaseUser?.uid else { return }
        FirestoreManager.shared.fetchCustomRules(userId: userId) { rules in
            DispatchQueue.main.async {
                // Filter out any blank/empty rules
                self.customRules = rules.filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
            }
        }
    }
    private func startCreatingCustomRule() {
        if isCreatingCustomRule || editingCustomRuleId != nil { return }
        editingCustomRuleId = nil // Ensure editing state is cleared
        let color = cardPalette[(rulesCatalog.count + customRules.count) % cardPalette.count]
        newCustomRule = CatalogRule(id: UUID().uuidString, title: "", peanuts: 1, color: color, colorHex: color.toHexString(), isCustom: true)
        isCreatingCustomRule = true
    }
    private func saveCustomRule() {
        guard let rule = newCustomRule, canSaveCustomRule, let userId = authManager.firebaseUser?.uid else { return }
        // Assign color from cardPalette using stateless pattern (matches curated logic)
        let allRules = rulesCatalog + customRules
        let colorIndex = allRules.count % cardPalette.count
        var coloredRule = rule
        coloredRule.color = cardPalette[colorIndex]
        newCustomRule = nil
        isCreatingCustomRule = false
        editingCustomRuleId = nil
        FirestoreManager.shared.addCustomRule(userId: userId, rule: coloredRule) { error in
            if error == nil {
                customRules.insert(coloredRule, at: 0)
            }
        }
    }
    private func cancelCustomRule() {
        newCustomRule = nil
        isCreatingCustomRule = false
        editingCustomRuleId = nil
    }
    private var canSaveCustomRule: Bool {
        guard let rule = newCustomRule else { return false }
        return !rule.title.trimmingCharacters(in: .whitespaces).isEmpty && (1...9).contains(rule.peanuts)
    }
    private func startEditingCustomRule(_ rule: CatalogRule) {
        editingCustomRuleId = rule.id
        newCustomRule = rule
    }
    private func updateEditingCustomRuleTitle(_ newTitle: String, id: String) {
        if newCustomRule?.id == id {
            newCustomRule?.title = newTitle
        }
    }
    private func updateEditingCustomRulePeanuts(_ newPeanuts: Int, id: String) {
        if newCustomRule?.id == id {
            newCustomRule?.peanuts = newPeanuts
        }
    }
    private func deleteCustomRule(id: String) {
        guard let userId = authManager.firebaseUser?.uid else { return }
        FirestoreManager.shared.deleteCustomRule(userId: userId, ruleId: id) { error in
            if error == nil {
                fetchCustomRules()
                if newCustomRule?.id == id { newCustomRule = nil; editingCustomRuleId = nil }
            } else {
                // Handle error
            }
        }
    }
}

// Editable custom rule card
struct EditableCustomRuleCard: View {
    @State var rule: CatalogRule
    var onTitleChange: (String) -> Void
    var onPeanutsChange: (Int) -> Void
    var color: Color
    var isEditing: Bool
    @State private var peanutsText: String = ""
    @State private var titleText: String = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        let cardWidth: CGFloat = horizontalSizeClass == .compact ? 372 : 600
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 14 : 20, style: .continuous)
                    .strokeBorder(color, lineWidth: 2)
                if (titleText.isEmpty && rule.title.isEmpty) {
                    Text("Enter your new family rule 🏡")
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
                        get: { titleText.isEmpty ? rule.title : titleText },
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
                // Border only, white background
                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 14 : 20, style: .continuous)
                    .strokeBorder(color, lineWidth: 2)
                    .background(Color.white.cornerRadius(horizontalSizeClass == .compact ? 14 : 20))
                HStack(spacing: 0) {
                    Spacer().frame(width: horizontalSizeClass == .compact ? 10 : 24)
                    TextField("1-9", text: Binding(
                        get: {
                            peanutsText.isEmpty ? String(rule.peanuts) : peanutsText
                        },
                        set: { newValue in
                            // Only allow 1-9
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
            titleText = rule.title
            peanutsText = String(rule.peanuts)
        }
    }
} 
