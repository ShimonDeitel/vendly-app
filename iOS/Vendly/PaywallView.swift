import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.accent)
                    Text("Vendly Pro")
                        .font(Theme.titleFont)
                    Text("Weekly spend trend graph and per-location breakdown")
                        .font(Theme.bodyFont)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    Spacer()
                    if let product = purchases.product {
                        Button {
                            Task {
                                await purchases.purchase()
                                if purchases.isPro { dismiss() }
                            }
                        } label: {
                            Text("Unlock for \(product.displayPrice) one-time")
                                .font(Theme.headlineFont)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .accessibilityIdentifier("purchaseButton")
                        .padding(.horizontal)
                    } else {
                        ProgressView()
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .font(.footnote)
                    .padding(.bottom)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("closePaywallButton")
                }
            }
        }
    }
}
