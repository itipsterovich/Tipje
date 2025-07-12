import SwiftUI
import Foundation

struct KidsProfileView: View {
    @State private var kidNames: [String]
    @State private var isNextActive: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    let userId: String
    var onNext: (() -> Void)? = nil
    var initialKids: [Kid]? = nil
    var onLoginRequest: (() -> Void)? = nil
    @EnvironmentObject var store: TipjeStore

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(userId: String, onNext: (() -> Void)? = nil, initialKids: [Kid]? = nil, onLoginRequest: (() -> Void)? = nil) {
        self.userId = userId
        self.onNext = onNext
        self.initialKids = initialKids
        self.onLoginRequest = onLoginRequest
        if let initialKids = initialKids {
            _kidNames = State(initialValue: initialKids.map { $0.name })
        } else {
            _kidNames = State(initialValue: [""])
        }
    }

    var body: some View {
        if userId.isEmpty {
            ErrorStateView(
                headline: "Welcome back!",
                bodyText: "It looks like you were logged out. Please log in again to continue your journey with Tipje.",
                buttonTitle: "Log In",
                onButtonTap: { onLoginRequest?() },
                imageName: "mascot_empty_chores"
            )
        } else {
            ZStack {
                Color(hex: "#BBB595").ignoresSafeArea()
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                Group {
                    if horizontalSizeClass == .compact {
                        kidsProfileiPhone
                    } else {
                        kidsProfileiPad
                    }
                }
                // Overlay the mascot image at the bottom, full width, 1.0 opacity
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Image("on_4b")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width)
                            .opacity(1.0)
                            .ignoresSafeArea(edges: .bottom)
                            .offset(y: 35)
                    }
                }
                .allowsHitTesting(false)
                // Overlay Next button for iPad only
                if horizontalSizeClass != .compact {
                    VStack {
                        Spacer()
                        ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#BBB595")) {
                            saveKids()
                        }
                        .accessibilityIdentifier("kidsProfileNextButton")
                        .disabled(!isNextActive || isLoading)
                        .padding(.bottom, 40)
                        .zIndex(2)
                    }
                }
            }
            .onChange(of: kidNames) { _ in
                validateNames()
            }
            .onAppear {
                validateNames()
            }
        }
    }

    // iPhone layout
    private var kidsProfileiPhone: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 50)
            Image("mascot_empty")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipped()
                .padding(.bottom, 16)
            Text("Who's Joining Tipje?")
                .font(.custom("Inter-Regular_SemiBold", size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            Spacer().frame(height: 16)
            Text("Add your child (or two) to begin your mindful journey.")
                .font(.custom("Inter-Regular_Medium", size: 18))
                .foregroundColor(.white)
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .frame(maxWidth: 400)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
            kidsFormContent
            Spacer()
            ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#BBB595")) {
                saveKids()
            }
            .accessibilityIdentifier("kidsProfileNextButton")
            .disabled(!isNextActive || isLoading)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
    }

    // iPad layout
    private var kidsProfileiPad: some View {
        ZStack {
            // Background illustration layer
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Image("mascot_empty")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 700)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .padding(.bottom, 80)
                }
                .frame(height: geometry.size.height)
            }
            
            // Content layer
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer().frame(height: geometry.size.height * 0.1)
                    Text("Who's Joining Tipje?")
                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                    Spacer().frame(height: 16)
                    Text("Add your child (or two) to begin your mindful journey.")
                        .font(.custom("Inter-Regular_Medium", size: 24))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 500)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().frame(height: 40)
                    kidsFormContent
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height)
            }
        }
        .ignoresSafeArea(.keyboard) // Allow content to move up with keyboard
    }

    private var kidsFormContent: some View {
        VStack(spacing: 16) {
            ForEach(Array(kidNames.enumerated()), id: \.offset) { index, _ in
                KidInputRow(
                    text: $kidNames[index],
                    showDelete: kidNames.count == 2,
                    onDelete: {
                        if kidNames.indices.contains(index) {
                            kidNames.remove(at: index)
                        }
                    },
                    placeholder: index == 0 ? String(localized: "onboarding_child_name") : String(localized: "onboarding_child_name_2"),
                    index: index,
                    deleteIconColor: Color(hex: "#BBB595")
                )
                .id(index)
            }
            if kidNames.count < 2 {
                ButtonRegular(iconName: "icon_plus") {
                    kidNames.append("")
                }
                .padding(.top, 16)
            }
            if hasDuplicateNames {
                Text(String(localized: "Same name chosen for two kids—if intentional, proceed."))
                    .font(.footnote)
                    .foregroundColor(.yellow)
            }
            if let error = errorMessage {
                Text(error)
                    .font(.custom("Inter-Regular_Medium", size: 20))
                    .foregroundColor(Color(hex: "#494646"))
                    .opacity(0.5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 32)
    }

    var hasDuplicateNames: Bool {
        let nonEmpty = kidNames.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return Set(nonEmpty).count != nonEmpty.count && nonEmpty.count > 1
    }

    func validateNames() {
        errorMessage = nil
        let valid = kidNames[0].isValidKidName
        isNextActive = valid && (kidNames.count == 1 || kidNames[1].isValidKidName)
        if !kidNames[0].isEmpty && !kidNames[0].isValidKidName {
            errorMessage = String(localized: "Name can only contain letters and spaces.")
        } else if kidNames.count == 2 && !kidNames[1].isEmpty && !kidNames[1].isValidKidName {
            errorMessage = String(localized: "Name can only contain letters and spaces.")
        }
    }

    /// Saves kids to Firestore under /users/{userId}/kids/{kidId}
    func saveKids() {
        isLoading = true
        errorMessage = nil
        let kidsToSave = kidNames.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        print("[KidsProfileView] Attempting to save kids: \(kidsToSave)")
        let group = DispatchGroup()
        var errors: [Error] = []
        // If editing, update existing kids or add new
        if let initialKids = initialKids {
            for (index, name) in kidsToSave.prefix(2).enumerated() {
                group.enter()
                if index < initialKids.count {
                    // Update existing kid if name changed
                    var kid = initialKids[index]
                    if kid.name != name {
                        kid.name = name
                        print("[KidsProfileView] Updating kid: id=\(kid.id), name=\(kid.name)")
                        FirestoreManager.shared.createKid(userId: userId, kid: kid) { error in
                            if let error = error {
                                print("[KidsProfileView] Error updating kid: \(error)")
                                errors.append(error)
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                } else {
                    // Add new kid
                    let kidId = UUID().uuidString
                    let kid = Kid(id: kidId, name: name, createdAt: nil, balance: 0)
                    print("[KidsProfileView] Adding new kid: id=\(kid.id), name=\(kid.name)")
                    FirestoreManager.shared.createKid(userId: userId, kid: kid) { error in
                        if let error = error {
                            print("[KidsProfileView] Error adding new kid: \(error)")
                            errors.append(error)
                        }
                        group.leave()
                    }
                }
            }
            // Remove kid if deleted
            if kidsToSave.count < initialKids.count {
                for kid in initialKids[kidsToSave.count...] {
                    group.enter()
                    print("[KidsProfileView] Deleting kid: id=\(kid.id), name=\(kid.name)")
                    FirestoreManager.shared.cascadeDeleteKid(userId: userId, kidId: kid.id) { error in
                        if let error = error {
                            print("[KidsProfileView] Error deleting kid: \(error)")
                            errors.append(error)
                        }
                        group.leave()
                    }
                }
            }
        } else {
            // Onboarding: just add new kids
            for name in kidsToSave.prefix(2) {
                group.enter()
                let kidId = UUID().uuidString
                let kid = Kid(id: kidId, name: name, createdAt: nil, balance: 0)
                print("[KidsProfileView] Adding new kid (onboarding): id=\(kid.id), name=\(kid.name)")
                FirestoreManager.shared.createKid(userId: userId, kid: kid) { error in
                    if let error = error {
                        print("[KidsProfileView] Error adding new kid (onboarding): \(error)")
                        errors.append(error)
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            isLoading = false
            if errors.isEmpty {
                print("[KidsProfileView] Kids saved successfully: \(kidsToSave)")
                // Trigger a fetch and selection of kids in the Store
                FirestoreManager.shared.fetchKids(userId: userId) { kids in
                    Task { @MainActor in
                        if let firstKid = kids.first {
                            print("[KidsProfileView] Selecting first kid: \(firstKid.name)")
                            store.kids = kids
                            store.selectKid(firstKid)
                        }
                        onNext?()
                    }
                }
            } else {
                print("[KidsProfileView] Failed to save kids. Errors: \(errors)")
                errorMessage = String(localized: "Failed to save kids. Please try again.")
            }
        }
    }
}

fileprivate extension String {
    var isValidKidName: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        let allowed = CharacterSet.letters.union(.whitespaces)
        return trimmed.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}

struct KidInputRow: View {
    @Binding var text: String
    var showDelete: Bool
    var onDelete: () -> Void
    var placeholder: String
    var index: Int
    var deleteIconColor: Color = Color(hex: "#ADA57F")
    var body: some View {
        HStack(spacing: 24) {
            Spacer()
            OnboardingInputField(
                text: $text,
                placeholder: placeholder,
                index: index
            )
            .frame(width: 240, height: 56)
            if showDelete {
                IconRoundButton(iconName: "icon_delete", iconColor: deleteIconColor, action: onDelete)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct OnboardingInputField: View {
    @Binding var text: String
    var placeholder: String
    var index: Int? = nil
    @FocusState private var isFocused: Bool
    var body: some View {
        ZStack(alignment: .center) {
            TextField("", text: $text)
                .font(.custom("Inter", size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textInputAutocapitalization(.never)
                .keyboardType(.default)
                .textContentType(.name)
                .submitLabel(.done)
                .accessibilityIdentifier(index != nil ? "kidNameField_\(index!)" : "kidNameField")
            if text.isEmpty {
                if isFocused {
                    // Show only the blinking cursor (handled by TextField itself)
                    // No placeholder
                    EmptyView()
                } else {
                    Text(placeholder)
                        .font(.custom("Inter", size: 24))
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 0)
                }
            }
        }
        .frame(height: 56)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 1.5)
        )
        .cornerRadius(16)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .accessibilityIdentifier(index != nil ? "kidNameField_\(index!)" : "kidNameField")
    }
} 
