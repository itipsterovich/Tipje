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

    init(userId: String, onNext: (() -> Void)? = nil, initialKids: [Kid]? = nil) {
        self.userId = userId
        self.onNext = onNext
        self.initialKids = initialKids
        if let initialKids = initialKids {
            _kidNames = State(initialValue: initialKids.map { $0.name })
        } else {
            _kidNames = State(initialValue: [""])
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "#ADA57F").ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 100)
                Image("il_profile")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 500)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.bottom, 16)
                Text("onboarding_title")
                    .font(.custom("Inter-Regular_SemiBold", size: 40))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer().frame(height: 16)
                Text("onboarding_subtitle")
                    .font(.custom("Inter-Regular_Medium", size: 20))
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 500)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer().frame(height: 40)
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
                            index: index
                        )
                        .id(index)
                    }
                    if kidNames.count < 2 {
                        ButtonRegular(iconName: "icon_plus", variant: .light) {
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
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#ADA57F")) {
                        saveKids()
                    }
                    .accessibilityIdentifier("kidsProfileNextButton")
                    .disabled(!isNextActive || isLoading)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 32)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: kidNames) { _ in
            validateNames()
        }
        .onAppear {
            validateNames()
        }
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
                        FirestoreManager.shared.createKid(userId: userId, kid: kid) { error in
                            if let error = error { errors.append(error) }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                } else {
                    // Add new kid
                    let kidId = UUID().uuidString
                    let kid = Kid(id: kidId, name: name, createdAt: nil, balance: 0)
                    FirestoreManager.shared.createKid(userId: userId, kid: kid) { error in
                        if let error = error { errors.append(error) }
                        group.leave()
                    }
                }
            }
            // Remove kid if deleted
            if kidsToSave.count < initialKids.count {
                for kid in initialKids[kidsToSave.count...] {
                    group.enter()
                    FirestoreManager.shared.cascadeDeleteKid(userId: userId, kidId: kid.id) { error in
                        if let error = error { errors.append(error) }
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
                FirestoreManager.shared.createKid(userId: userId, kid: kid) { error in
                    if let error = error { errors.append(error) }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            isLoading = false
            if errors.isEmpty {
                onNext?()
            } else {
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
                IconRoundButton(iconName: "icon_delete", iconColor: Color(hex: "#ADA57F"), action: onDelete)
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
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .font(.custom("Inter", size: 24))
                .foregroundColor(.white)
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
                Text(placeholder)
                    .font(.custom("Inter", size: 24))
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding(.leading, 18)
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
