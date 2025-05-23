import SwiftUI

struct PageTitle<Content: View>: View {
    let text: String
    let trailing: () -> Content
    
    init(_ text: String, @ViewBuilder trailing: @escaping () -> Content = { EmptyView() }) {
        self.text = text
        self.trailing = trailing
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.custom("Inter-Medium", size: 28))
                .foregroundColor(Color.titlePrimary)
            Spacer()
            trailing()
        }
        .padding(.vertical, 8)
    }
}

extension PageTitle where Content == EmptyView {
    init(_ text: String) {
        self.text = text
        self.trailing = { EmptyView() }
    }
}

#if DEBUG
struct PageTitle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            PageTitle("Reward shop")
            PageTitle("Add new rule") {
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif 