import SwiftUI

struct SubTabBar<T: Hashable>: View {
    let tabs: [T]
    @Binding var selectedTab: T
    var title: (T) -> String

    var body: some View {
        HStack(spacing: 10) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: { 
                    print("SubTabBar: tapped \(tab)")
                    selectedTab = tab 
                }) {
                    Text(title(tab))
                        .font(.custom("Inter-Regular_Medium", size: 24))
                        .foregroundColor(selectedTab == tab ? .white : Color(hex: "#799B44"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedTab == tab ? Color(hex: "#799B44") : .white)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "#EAF3EA"))
        )
    }
}

#if DEBUG
enum SubTabExample: String, CaseIterable { case rules = "Family rules", chores = "Chores" }
struct SubTabBar_Previews: PreviewProvider {
    @State static var selectedTab: SubTabExample = .rules
    static var previews: some View {
        SubTabBar(tabs: SubTabExample.allCases, selectedTab: $selectedTab, title: { $0.rawValue })
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
}
#endif 