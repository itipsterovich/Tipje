import SwiftUI

struct CustomDropdownCompact<T: Hashable>: View {
    @Binding var selection: T
    var options: [T]
    var display: (T) -> String
    @State private var showMenu = false

    var body: some View {
        Button(action: { showMenu = true }) {
            HStack {
                Text(display(selection))
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .foregroundColor(.white)
                Image("icon_she")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 3)
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
                            .foregroundColor(.black)
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
