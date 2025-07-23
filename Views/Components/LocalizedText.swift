import SwiftUI

struct LocalizedText: View {
    let key: String
    let comment: String
    @ObservedObject private var localizationManager = LocalizationManager.shared

    init(_ key: String, comment: String = "") {
        self.key = key
        self.comment = comment
    }

    var body: some View {
        Text(
            NSLocalizedString(
                key,
                tableName: nil,
                bundle: Bundle.main,
                value: "",
                comment: comment
            )
        )
    }
} 