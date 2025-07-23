import SwiftUI

struct CatalogRewardsModal: View {
    var onSave: ([String], [CatalogReward]) -> Void
    var initiallySelected: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selected: Set<String>
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    @State private var expandedRewardId: String? = nil
    var catalog: [CatalogReward] {
        getLocalizedRewardsCatalog()
    }
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var customRewards: [CatalogReward] = []
    @State private var isCreatingCustomReward = false
    @State private var newCustomReward: CatalogReward? = nil
    @State private var editingCustomRewardId: String? = nil
    // Remove all colorIndex state and logic
    // For new custom reward creation and preview, always assign color using the stateless pattern
    init(onSave: @escaping ([String], [CatalogReward]) -> Void, initiallySelected: [String]) {
        self.onSave = onSave
        self.initiallySelected = initiallySelected
        _selected = State(initialValue: Set(initiallySelected))
    }
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A5ADC3"),
            bannerHeight: 100,
            containerOffsetY: -36,
            content: {
                VStack(spacing: 0) {
                    PageTitle(NSLocalizedString("catalog_rewards_title", tableName: nil, bundle: Bundle.main, value: "", comment: "")) {
                        ButtonRegular(iconName: "icon_close", variant: .light) { save() }
                        .accessibilityIdentifier("saveRewardsButton")
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                    ScrollView {
                        VStack(spacing: 14) {
                            if isCreatingCustomReward || editingCustomRewardId != nil {
                                HStack(spacing: 14) {
                                    if horizontalSizeClass == .compact {
                                        ButtonTextiPhone(title: NSLocalizedString("save", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .primary, action: { saveCustomReward() }, fullWidth: true)
                                            .disabled(!canSaveCustomReward)
                                        ButtonTextiPhone(title: NSLocalizedString("cancel", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: { cancelCustomReward() }, fullWidth: true)
                                    } else {
                                        ButtonText(title: NSLocalizedString("save", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .primary, action: { saveCustomReward() }, fontSize: 24, fullWidth: true)
                                            .disabled(!canSaveCustomReward)
                                        ButtonText(title: NSLocalizedString("cancel", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: { cancelCustomReward() }, fontSize: 24, fullWidth: true)
                                    }
                                }
                            }
                            if !isCreatingCustomReward && editingCustomRewardId == nil {
                                if horizontalSizeClass == .compact {
                                    Button(action: { startCreatingCustomReward() }) {
                                        HStack(spacing: 8) {
                                            Image("icon_plus").resizable().frame(width: 20, height: 20)
                                            Text(NSLocalizedString("create_reward", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                        }
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(Color(hex: "#EAF3EA"))
                                        .cornerRadius(12)
                                    }
                                } else {
                                    Button(action: { startCreatingCustomReward() }) {
                                        HStack(spacing: 12) {
                                            Image("icon_plus").resizable().frame(width: 24, height: 24)
                                            Text(NSLocalizedString("create_reward", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                        }
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, minHeight: 56)
                                        .background(Color(hex: "#EAF3EA"))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            if let custom = newCustomReward, editingCustomRewardId == nil {
                                EditableCustomRewardCard(
                                    reward: custom,
                                    onTitleChange: { newTitle in newCustomReward?.title = newTitle },
                                    onPeanutsChange: { newPeanuts in newCustomReward?.peanuts = newPeanuts },
                                    color: custom.color,
                                    isEditing: true
                                )
                            } else if let editingId = editingCustomRewardId, let item = customRewards.first(where: { $0.id == editingId }) {
                                EditableCustomRewardCard(
                                    reward: item,
                                    onTitleChange: { newTitle in updateEditingCustomRewardTitle(newTitle, id: item.id) },
                                    onPeanutsChange: { newPeanuts in updateEditingCustomRewardPeanuts(newPeanuts, id: item.id) },
                                    color: item.color,
                                    isEditing: true
                                )
                            }
                            ForEach(customRewards) { item in
                                if editingCustomRewardId == item.id {
                                    EmptyView()
                                } else {
                                    rewardCard(for: item)
                                        .contextMenu {
                                            Button("Edit") { startEditingCustomReward(item) }
                                            Button("Delete", role: .destructive) { deleteCustomReward(id: item.id) }
                                        }
                                }
                            }
                            ForEach(catalog, id: \.id) { item in
                                rewardCard(for: item)
                            }
                        }
                        .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                        .padding(.top, horizontalSizeClass == .compact ? 0 : 8)
                        .padding(.bottom, horizontalSizeClass == .compact ? 0 : 24)
                    }
                }
            }
        )
        .id(localizationManager.currentLanguage)
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
        .onAppear(perform: fetchCustomRewards)
    }
    private func rewardCard(for item: CatalogReward) -> some View {
        let isSelected = selected.contains(item.id)
        let isExpanded = expandedRewardId == item.id
        return RewardAdultCard(
            reward: Reward(id: item.id, title: item.title, cost: item.peanuts, isActive: true),
            onArchive: {
                if isSelected {
                    selected.remove(item.id)
                    toastMessage = NSLocalizedString("toast_removed_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    toastIcon = "minus.circle.fill"
                    toastIconColor = Color(hex: "#BBB595")
                } else {
                    selected.insert(item.id)
                    toastMessage = NSLocalizedString("toast_added_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
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
                    expandedRewardId = nil
                } else {
                    expandedRewardId = item.id
                }
            },
            expanded: isExpanded
        )
        .accessibilityIdentifier("rewardCell_\(item.id)")
    }
    private func save() {
        onSave(Array(selected), customRewards)
        dismiss()
    }
    private func fetchCustomRewards() {
        guard let userId = authManager.firebaseUser?.uid else { return }
        FirestoreManager.shared.fetchCustomRewards(userId: userId) { rewards in
            DispatchQueue.main.async {
                self.customRewards = rewards.filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
            }
        }
    }
    private func startCreatingCustomReward() {
        if isCreatingCustomReward || editingCustomRewardId != nil { return }
        editingCustomRewardId = nil
        let color = cardPalette[(rewardsCatalog.count + customRewards.count) % cardPalette.count]
        newCustomReward = CatalogReward(id: UUID().uuidString, title: "", peanuts: 1, color: color, colorHex: color.toHexString(), isCustom: true)
        isCreatingCustomReward = true
    }
    private func saveCustomReward() {
        guard let reward = newCustomReward, canSaveCustomReward, let userId = authManager.firebaseUser?.uid else { return }
        // Assign color from cardPalette using stateless pattern (matches curated logic)
        let allRewards = rewardsCatalog + customRewards
        let colorIndex = allRewards.count % cardPalette.count
        var coloredReward = reward
        coloredReward.color = cardPalette[colorIndex]
        newCustomReward = nil
        isCreatingCustomReward = false
        editingCustomRewardId = nil
        FirestoreManager.shared.addCustomReward(userId: userId, reward: coloredReward) { error in
            if error == nil {
                customRewards.insert(coloredReward, at: 0)
            }
        }
    }
    private func cancelCustomReward() {
        newCustomReward = nil
        isCreatingCustomReward = false
        editingCustomRewardId = nil
    }
    private var canSaveCustomReward: Bool {
        guard let reward = newCustomReward else { return false }
        return !reward.title.trimmingCharacters(in: .whitespaces).isEmpty && (1...9).contains(reward.peanuts)
    }
    private func startEditingCustomReward(_ reward: CatalogReward) {
        editingCustomRewardId = reward.id
        newCustomReward = reward
    }
    private func updateEditingCustomRewardTitle(_ newTitle: String, id: String) {
        if newCustomReward?.id == id {
            newCustomReward?.title = newTitle
        }
    }
    private func updateEditingCustomRewardPeanuts(_ newPeanuts: Int, id: String) {
        if newCustomReward?.id == id {
            newCustomReward?.peanuts = newPeanuts
        }
    }
    private func deleteCustomReward(id: String) {
        guard let userId = authManager.firebaseUser?.uid else { return }
        FirestoreManager.shared.deleteCustomReward(userId: userId, rewardId: id) { error in
            if error == nil {
                fetchCustomRewards()
                if newCustomReward?.id == id { newCustomReward = nil; editingCustomRewardId = nil }
            }
        }
    }
}

struct EditableCustomRewardCard: View {
    @State var reward: CatalogReward
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
                if (titleText.isEmpty && reward.title.isEmpty) {
                    Text(NSLocalizedString("placeholder_new_reward", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
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
                        get: { titleText.isEmpty ? reward.title : titleText },
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
                    TextField(NSLocalizedString("placeholder_1_9", tableName: nil, bundle: Bundle.main, value: "", comment: ""), text: Binding(
                        get: {
                            peanutsText.isEmpty ? String(reward.peanuts) : peanutsText
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
            titleText = reward.title
            peanutsText = String(reward.peanuts)
        }
    }
} 