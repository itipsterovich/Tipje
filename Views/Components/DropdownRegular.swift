import SwiftUI

struct DropdownRegular<T: Hashable>: View {
    @Binding var selection: T
    var options: [T]
    var display: (T) -> String
    @State private var showMenu = false

    var body: some View {
        Button(action: { showMenu = true }) {
            HStack {
                Text(display(selection))
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .foregroundColor(Color(hex: "#799B44"))
                Spacer()
                Image("icon_she")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#799B44"), lineWidth: 2)
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showMenu) {
            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        showMenu = false
                    }) {
                        Text(display(option))
                            .font(.custom("Inter-Regular_Medium", size: 24))
                            .foregroundColor(Color(hex: "#799B44"))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    if option != options.last {
                        Divider()
                    }
                }
            }
            .background(Color.white)
            .presentationDetents([.height(CGFloat(options.count) * 56 + 16)])
        }
    }
} 