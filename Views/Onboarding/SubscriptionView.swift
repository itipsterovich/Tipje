import SwiftUI
import StoreKit

// SubscriptionView: Device-specific layout switcher (like HomeView)
struct SubscriptionView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    // Closure to call when a plan is selected
    var onPlanSelected: (Plan) -> Void
    var body: some View {
        if horizontalSizeClass == .compact {
            SubscriptionViewiPhone(onPlanSelected: onPlanSelected)
        } else {
            SubscriptionViewiPad(onPlanSelected: onPlanSelected)
        }
    }
}

// Plan enum for both subviews
enum Plan {
    case monthly, yearly
}

// =======================
// iPhone layout
// =======================
struct SubscriptionViewiPhone: View {
    @StateObject private var storeKit = StoreKitManager()
    @State private var selectedPlan: Plan = .monthly
    @State private var selectedValueIndex: Int = 0
    let valuePoints = [
        "Don’t lose your progress! Subscribe to keep enjoying Tipje’s rewards, routines, and family fun.",
        "Curated catalog of rules, chores, and rewards. From \"say thank you\" to tidying up, it adapts to your values and grows with your child.",
        "Less nagging, more joy. Tipje brings calm, structure, and motivation to your everyday routine."
    ]
    var onPlanSelected: (Plan) -> Void
    let monthlyProductID = "com.Tipje.month"
    let yearlyProductID = "com.Tipje.year"
    @State private var isPurchasing = false
    @State private var purchaseError: String? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // BG color and gradient
                Color(hex: "#ADA57F").ignoresSafeArea()
            LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.22)]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
                // il_clouds at the top
                Image("il_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.9)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.18)
                    .opacity(0.7)
                // on_4b at the bottom
                VStack {
                    Spacer()
                    Image("on_4b")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .offset(y: 40)
                        .opacity(1.00)
                }
                .onAppear {
                    print("[SubscriptionView] onAppear. isLoading: \(storeKit.isLoading), products: \(storeKit.products.map { $0.id })")
                    }
                if storeKit.isLoading {
                    // Show loader while products are loading
                    TipjeLoadingView()
                } else if let error = storeKit.error {
                    // Show error and retry button
                    VStack(spacing: 16) {
                        Text("Failed to load products. Please check your connection and try again.")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button(action: { Task { await storeKit.loadProducts() } }) {
                            Text("Retry")
                                .font(.custom("Inter-Regular_SemiBold", size: 18))
                                .foregroundColor(Color(hex: "#799B44"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 24)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 2)
                        }
                    }
                    .frame(maxWidth: 340)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(24)
                    .shadow(radius: 8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                } else {
                    VStack {
                        Spacer()
                        VStack(spacing: 14) {
                            Text("Your free trial has ended")
                                .font(.custom("Inter-Regular_SemiBold", size: 24))
                                .foregroundColor(Color(hex: "#494646"))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                            TabView(selection: $selectedValueIndex) {
                                ForEach(0..<valuePoints.count, id: \ .self) { idx in
                                    Text(valuePoints[idx])
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color(hex: "#494646").opacity(0.85))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                }
                            }
                            .frame(height: 90)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            HStack(spacing: 8) {
                                ForEach(0..<valuePoints.count, id: \ .self) { idx in
                                    Circle()
                                        .fill(idx == selectedValueIndex ? Color(hex: "#799B44") : Color(hex: "#D4D7E3"))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            VStack(spacing: 16) {
                                planCard(plan: .monthly, selected: selectedPlan == .monthly, product: storeKit.product(for: monthlyProductID))
                                planCard(plan: .yearly, selected: selectedPlan == .yearly, product: storeKit.product(for: yearlyProductID))
                    }
                    .padding(.top, 8)
                            Button(action: {
                                Task {
                                    isPurchasing = true
                                    purchaseError = nil
                                    let product = selectedPlan == .monthly ? storeKit.product(for: monthlyProductID) : storeKit.product(for: yearlyProductID)
                                    print("[Paywall] Purchase button tapped. Selected plan: \(selectedPlan), Product: \(String(describing: product?.id))")
                                    if let product = product {
                                        let success = await storeKit.purchase(product: product)
                                        print("[Paywall] Purchase result: success=\(success)")
                                        await storeKit.refreshSubscriptionStatus()
                                        print("[Paywall] After refresh, isSubscribed=\(storeKit.isSubscribed)")
                                        isPurchasing = false
                                        if success && storeKit.isSubscribed {
                                            print("[Paywall] Purchase successful and subscription active. Proceeding.")
                                            onPlanSelected(selectedPlan)
                                        } else {
                                            print("[Paywall] Purchase failed or subscription not active. Not proceeding.")
                                            purchaseError = storeKit.error ?? "Purchase failed or subscription not active. Please try again."
                                        }
                                    } else {
                                        isPurchasing = false
                                        purchaseError = "Product not available."
                                    }
                                }
                            }) {
                                if isPurchasing {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                } else {
                                    Text("Subscribe")
                            .font(.custom("Inter-Regular_SemiBold", size: 22))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#799B44"))
                            .cornerRadius(28)
                    }
                            }
                            .disabled(isPurchasing || storeKit.isLoading)
                            if let error = purchaseError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            HStack(spacing: 4) {
                                Link("Privacy Policy", destination: URL(string: "https://www.tipje.tiplyx.com/privacy")!)
                                    .font(.custom("Inter-Regular", size: 14))
                                    .underline()
                                    .foregroundColor(Color(hex: "#799B44").opacity(0.8))
                                Text("and")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(Color(hex: "#494646").opacity(0.7))
                                Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        .font(.custom("Inter-Regular", size: 14))
                                    .underline()
                                    .foregroundColor(Color(hex: "#799B44").opacity(0.8))
                            }
                        .multilineTextAlignment(.center)
                }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 32)
                        .background(Color.white)
                        .cornerRadius(32)
                        .padding(.horizontal, 16)
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
    private func planCard(plan: Plan, selected: Bool, product: Product?) -> some View {
        Button(action: { selectedPlan = plan }) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    if plan == .monthly {
                        Text("Tipje Monthly")
                            .font(.custom("Inter-Regular_SemiBold", size: 20))
                            .foregroundColor(Color(hex: "#494646"))
                        Text("Pay monthly. Cancel anytime")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color(hex: "#494646").opacity(0.7))
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Tipje Yearly")
                        .font(.custom("Inter-Regular_SemiBold", size: 20))
                        .foregroundColor(Color(hex: "#494646"))
                        Text("Best value. Save 20%")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color(hex: "#494646").opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                if let product = product {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(product.displayPrice)
                            .font(.custom("Inter-Regular_SemiBold", size: 20))
                            .foregroundColor(Color(hex: "#799B44"))
                        Text(plan == .monthly ? "/mo" : "/yr")
                            .font(.custom("Inter-Regular_SemiBold", size: 18 * 0.85))
                            .foregroundColor(Color(hex: "#799B44").opacity(0.7))
                            .padding(.bottom, 2)
                    }
                } else if storeKit.isLoading {
                    ProgressView()
                        .frame(width: 40, height: 40, alignment: .center)
                        .padding(.top, 4)
                } else {
                    Text("Not available")
                        .font(.custom("Inter-Regular_SemiBold", size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(Color.white.opacity(selected ? 0.95 : 0.7))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selected ? Color(hex: "#799B44") : Color.gray.opacity(0.2), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

// =======================
// iPad layout
// =======================
struct SubscriptionViewiPad: View {
    @StateObject private var storeKit = StoreKitManager()
    @State private var selectedPlan: Plan = .monthly
    @State private var selectedValueIndex: Int = 0
    let valuePoints = [
        "Don’t lose your progress! Subscribe to keep enjoying Tipje’s rewards, routines, and family fun.",
        "Curated catalog of rules, chores, and rewards. From \"say thank you\" to tidying up, it adapts to your values and grows with your child.",
        "Less nagging, more joy. Tipje brings calm, structure, and motivation to your everyday routine."
    ]
    var onPlanSelected: (Plan) -> Void
    let monthlyProductID = "com.Tipje.month"
    let yearlyProductID = "com.Tipje.year"
    @State private var isPurchasing = false
    @State private var purchaseError: String? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // BG color and gradient
                Color(hex: "#ADA57F").ignoresSafeArea()
            LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.22)]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
                // il_clouds at the top
                Image("il_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.7, 700))
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.18)
                    .opacity(0.7)
                // on_4b at the bottom
                VStack {
                    Spacer()
                    Image("on_4b")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .offset(y: 24)
                        .opacity(1.00)
                }
                .onAppear {
                    print("[SubscriptionView] onAppear. isLoading: \(storeKit.isLoading), products: \(storeKit.products.map { $0.id })")
                }
                if storeKit.isLoading {
                    // Show loader while products are loading
                    TipjeLoadingView()
                } else if let error = storeKit.error {
                    // Show error and retry button
                    VStack(spacing: 16) {
                        Text("Failed to load products. Please check your connection and try again.")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button(action: { Task { await storeKit.loadProducts() } }) {
                            Text("Retry")
                                .font(.custom("Inter-Regular_SemiBold", size: 18))
                                .foregroundColor(Color(hex: "#799B44"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 24)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 2)
                        }
                    }
                    .frame(maxWidth: 340)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(24)
                    .shadow(radius: 8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                } else {
                    VStack(spacing: 16) {
                        Text("Your free trial has ended")
                    .font(.custom("Inter-Regular_SemiBold", size: 36))
                    .foregroundColor(Color(hex: "#494646"))
                    .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        TabView(selection: $selectedValueIndex) {
                            ForEach(0..<valuePoints.count, id: \ .self) { idx in
                                Text(valuePoints[idx])
                                    .font(.custom("Inter-Regular", size: 20))
                                    .foregroundColor(Color(hex: "#494646").opacity(0.85))
                .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .frame(height: 110)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        HStack(spacing: 8) {
                            ForEach(0..<valuePoints.count, id: \ .self) { idx in
                                Circle()
                                    .fill(idx == selectedValueIndex ? Color(hex: "#799B44") : Color(hex: "#D4D7E3"))
                                    .frame(width: 8, height: 8)
                            }
                        }
                .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        VStack(spacing: 16) {
                            planCard(plan: .monthly, selected: selectedPlan == .monthly, product: storeKit.product(for: monthlyProductID))
                            planCard(plan: .yearly, selected: selectedPlan == .yearly, product: storeKit.product(for: yearlyProductID))
                }
                .padding(.top, 8)
                        Button(action: {
                            Task {
                                isPurchasing = true
                                purchaseError = nil
                                let product = selectedPlan == .monthly ? storeKit.product(for: monthlyProductID) : storeKit.product(for: yearlyProductID)
                                print("[Paywall] Purchase button tapped. Selected plan: \(selectedPlan), Product: \(String(describing: product?.id))")
                                if let product = product {
                                    let success = await storeKit.purchase(product: product)
                                    print("[Paywall] Purchase result: success=\(success)")
                                    await storeKit.refreshSubscriptionStatus()
                                    print("[Paywall] After refresh, isSubscribed=\(storeKit.isSubscribed)")
                                    isPurchasing = false
                                    if success && storeKit.isSubscribed {
                                        print("[Paywall] Purchase successful and subscription active. Proceeding.")
                                        onPlanSelected(selectedPlan)
                                    } else {
                                        print("[Paywall] Purchase failed or subscription not active. Not proceeding.")
                                        purchaseError = storeKit.error ?? "Purchase failed or subscription not active. Please try again."
                                    }
                                } else {
                                    isPurchasing = false
                                    purchaseError = "Product not available."
                                }
                            }
                        }) {
                            if isPurchasing {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            } else {
                                Text("Subscribe")
                        .font(.custom("Inter-Regular_SemiBold", size: 22))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#799B44"))
                        .cornerRadius(28)
                }
                        }
                        .disabled(isPurchasing || storeKit.isLoading)
                        if let error = purchaseError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        HStack(spacing: 4) {
                            Link("Privacy Policy", destination: URL(string: "https://www.tipje.tiplyx.com/privacy")!)
                                .font(.custom("Inter-Regular", size: 16))
                                .underline()
                                .foregroundColor(Color(hex: "#799B44").opacity(0.8))
                            Text("and")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color(hex: "#494646").opacity(0.7))
                            Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                .font(.custom("Inter-Regular", size: 16))
                                .underline()
                                .foregroundColor(Color(hex: "#799B44").opacity(0.8))
                            Text(".")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color(hex: "#494646").opacity(0.7))
                        }
                    .multilineTextAlignment(.center)
            }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 40)
                    .background(Color.white)
                    .cornerRadius(32)
            .frame(maxWidth: 500)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
    }
    private func planCard(plan: Plan, selected: Bool, product: Product?) -> some View {
        Button(action: { selectedPlan = plan }) {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    if plan == .monthly {
                        Text("Tipje Monthly")
                            .font(.custom("Inter-Regular_SemiBold", size: 20))
                            .foregroundColor(Color(hex: "#494646"))
                        Text("Pay monthly. Cancel anytime")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color(hex: "#494646").opacity(0.7))
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Tipje Yearly")
                        .font(.custom("Inter-Regular_SemiBold", size: 20))
                        .foregroundColor(Color(hex: "#494646"))
                        Text("Best value. Save 20%")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color(hex: "#494646").opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                if let product = product {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(product.displayPrice)
                            .font(.custom("Inter-Regular_SemiBold", size: 20))
                            .foregroundColor(Color(hex: "#799B44"))
                        Text(plan == .monthly ? "/mo" : "/yr")
                            .font(.custom("Inter-Regular_SemiBold", size: 18 * 0.85))
                            .foregroundColor(Color(hex: "#799B44").opacity(0.7))
                            .padding(.bottom, 2)
                    }
                } else if storeKit.isLoading {
                    ProgressView()
                        .frame(width: 40, height: 40, alignment: .center)
                } else {
                    Text("Not available")
                        .font(.custom("Inter-Regular_SemiBold", size: 18))
                        .foregroundColor(.gray)
                        .frame(minWidth: 80, alignment: .trailing)
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(Color.white.opacity(selected ? 0.95 : 0.7))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selected ? Color(hex: "#799B44") : Color.gray.opacity(0.2), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView(onPlanSelected: { _ in })
            .previewDevice("iPhone 14 Pro")
        SubscriptionView(onPlanSelected: { _ in })
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
#endif 
