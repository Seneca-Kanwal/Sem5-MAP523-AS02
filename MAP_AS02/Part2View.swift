//
//  Part2View.swift
//  MAP_AS02
//
//  Created by Kanwaljot Singh on 2025-10-01.
//

import SwiftUI

struct Part2View: View {
    @State private var isBuy: Bool = true
    @State private var selectedCard: String = "5282 3456 7890 1289"
    @State private var selectedCurrency: String = "USD"
    @State private var payCurrency: String = "USD"
    @State private var payAmount: String = ""
    @State private var showSuccess: Bool = false
    
    // MARK: - Sample cards
    let cards = [
        "5282 3456 7890 1289",
        "4444 3333 2222 1111",
        "9876 5432 1098 7654"
    ]
    
    // MARK: - Top 5 most used currencies
    let currencies = ["USD", "EUR", "JPY", "GBP", "CAD"]
    
    // MARK: - Fixed conversion rates (example values)
    let conversionRates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.92,
        "JPY": 149.50,
        "GBP": 0.79,
        "CAD": 1.36
    ]
    
    // MARK: - Conversion logic
    private var receiveAmount: String {
        guard let payValue = Double(payAmount.replacingOccurrences(of: ",", with: "")) else { return "0" }
        guard let fromRate = conversionRates[payCurrency],
              let toRate = conversionRates[selectedCurrency] else { return "0" }
        
        let usdValue = payValue / fromRate
        let converted = usdValue * toRate
        return String(format: "%.2f", converted)
    }
    
    // MARK: - Validation
    private var isTransactionValid: Bool {
        if let payValue = Double(payAmount),
           let receiveValue = Double(receiveAmount),
           payValue > 0, receiveValue >= 1 {
            return true
        }
        return false
    }
    
    private var transactionError: String? {
        if payAmount.isEmpty {
            return "Enter an amount"
        }
        if let payValue = Double(payAmount),
           let receiveValue = Double(receiveAmount) {
            if payValue <= 0 {
                return "Amount must be greater than 0"
            }
            if receiveValue < 1 {
                return "You must receive at least 1 coin"
            }
        }
        return nil
    }
    
    // MARK: - Reset Form
    private func resetForm() {
        isBuy = true
        selectedCard = "5282 3456 7890 1289"
        selectedCurrency = "USD"
        payCurrency = "USD"
        payAmount = ""
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemGray5).ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Top Bar
                    TopBarView(title: "Exchange")
                    
                    // MARK: - Buy / Sell Toggle
                    BuySellSwitch(isBuy: $isBuy)
                    
                    // MARK: - Select Card
                    DropdownBox(
                        label: "Select Card",
                        selected: selectedCard,
                        options: cards,
                        icon: AnyView(Circle().fill(Color.black).frame(width: 20, height: 20)),
                        onSelect: { selectedCard = $0 }
                    )
                    
                    // MARK: - Select Currency
                    DropdownBox(
                        label: "Select Currency",
                        selected: selectedCurrency,
                        options: currencies,
                        icon: AnyView(Image(systemName: "dollarsign.circle")),
                        onSelect: { selectedCurrency = $0 }
                    )
                    
                    // MARK: - You Pay + Inline Error
                    VStack(alignment: .leading, spacing: 4) {
                        PayInputBox(
                            amount: $payAmount,
                            currency: $payCurrency,
                            currencies: currencies
                        )
                        
                        if let error = transactionError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                    }
                    
                    // MARK: - You Receive
                    ReceiveBox(
                        amount: receiveAmount,
                        currency: selectedCurrency
                    )
                    
                    // MARK: - Button
                    // MARK: - Button
                    PrimaryButton(title: isBuy ? "💰 Buy Coins" : "💸 Sell Coins") {
                        showSuccess = true
                    }
                    .disabled(!isTransactionValid)
                    .opacity(isTransactionValid ? 1 : 0.5)

                }
                .padding()
                .background(Color(red: 0.96, green: 0.94, blue: 0.90))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
                .padding()
            }
        }
        // MARK: - Success Alert
        .alert(isBuy ? "Buy Complete 🎉" : "Sell Complete 🎉", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(isBuy ? "You bought" : "You sold") \(receiveAmount) \(selectedCurrency).")
        }

    }
}

#Preview {
    Part2View()
}

//
// MARK: - Reusable Components
//

struct TopBarView: View {
    var title: String
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
            Spacer()
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "line.3.horizontal")
        }
    }
}

struct BuySellSwitch: View {
    @Binding var isBuy: Bool  // true = BUY (left/green), false = SELL (right/yellow)

    var body: some View {
        HStack(spacing: 12) {
            // BUY label
            Text("BUY")
                .font(.system(size: 18, weight: isBuy ? .bold : .regular))
                .foregroundColor(isBuy ? .black : .gray)
                .onTapGesture { withAnimation(.spring()) { isBuy = true } }

            // Custom pill switch
            ZStack(alignment: isBuy ? .leading : .trailing) {
                Capsule()
                    .fill((isBuy ? Color.green : Color.yellow).opacity(0.25))
                    .frame(width: 70, height: 34)

                Circle()
                    .fill(isBuy ? Color.green : Color.yellow)
                    .frame(width: 30, height: 30)
                    .padding(2)
            }
            .onTapGesture { withAnimation(.spring()) { isBuy.toggle() } }

            // SELL label
            Text("SELL")
                .font(.system(size: 18, weight: !isBuy ? .bold : .regular))
                .foregroundColor(!isBuy ? .black : .gray)
                .onTapGesture { withAnimation(.spring()) { isBuy = false } }
        }
        .padding(.horizontal)
    }
}

struct DropdownBox: View {
    var label: String
    var selected: String
    var options: [String]
    var icon: AnyView
    var onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { onSelect(option) }
                }
            } label: {
                HStack {
                    icon
                    Text(selected)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
            }
        }
    }
}

struct PayInputBox: View {
    @Binding var amount: String
    @Binding var currency: String
    var currencies: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("You Pay").font(.subheadline)
            HStack {
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                Spacer()
                Menu {
                    ForEach(currencies, id: \.self) { option in
                        Button(option) { currency = option }
                    }
                } label: {
                    HStack {
                        Text(currency)
                        Image(systemName: "chevron.down")
                    }
                }
            }
            .padding()
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
        }
    }
}

struct ReceiveBox: View {
    var amount: String
    var currency: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("You Receive").font(.subheadline)
            HStack {
                Text(amount)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                Spacer()
                Text(currency)
            }
            .padding()
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
        }
    }
}

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
        }
    }
}
