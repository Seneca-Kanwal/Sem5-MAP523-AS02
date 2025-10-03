//
//  Part1View.swift
//  Assignment2
//

import SwiftUI

struct Part1View: View {
    // MARK: - State variables
    @State private var pirateName: String = ""
    @State private var email: String = ""
    @State private var bountyID: String = ""
    @State private var secretPower: String = ""
    @State private var confirmPower: String = ""
    @State private var joinForever: Bool = false
    @State private var treasureUpdates: Bool = false
    @State private var bounty: Double = 0.0
    @State private var showSuccessAlert: Bool = false
    
    // MARK: - Validation checks
    private var isPirateNameValid: Bool {
        !pirateName.isEmpty
    }
    
    private var isEmailValid: Bool {
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        let range = NSRange(location: 0, length: email.utf16.count)
        return regex.firstMatch(in: email, options: [], range: range) != nil
    }
    
    private var isPowerMatch: Bool {
        !secretPower.isEmpty && secretPower == confirmPower
    }
    
    private var isFormValid: Bool {
        isPirateNameValid && isEmailValid && isPowerMatch && !bountyID.isEmpty
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    headerSection
                    personalInfoSection
                    devilFruitSection
                    crewPreferencesSection
                    setSailButton
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("⛵").font(.largeTitle)
            Text("Straw Hat Pirates")
                .font(.title).bold()
            Text("Join the crew")
                .foregroundColor(.gray)
            Text("\"I'm gonna be King of the Pirates!\"")
                .foregroundColor(.red)
                .italic()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
    
    // MARK: - Personal Info
    private var personalInfoSection: some View {
        Section(header: Text("Personal Info").font(.headline)) {
            
            ValidatedTextField(
                label: "👑 Pirate Name",
                placeholder: "What's your dream name?",
                text: $pirateName,
                isValid: isPirateNameValid,
                errorMessage: "Name required"
            )
            
            ValidatedTextField(
                label: "📞 Den Den Mushi",
                placeholder: "contact@grandline.sea",
                text: $email,
                isValid: isEmailValid,
                errorMessage: "Invalid email format",
                keyboardType: .emailAddress
            )
            
            ValidatedTextField(
                label: "⭐ Bounty ID",
                placeholder: "Your wanted poster name",
                text: $bountyID,
                isValid: !bountyID.isEmpty,
                errorMessage: "Bounty ID required",
                maxLength: 20
            )
        }
    }
    
    // MARK: - Devil Fruit Powers
    private var devilFruitSection: some View {
        Section(header: Text("Devil Fruit Powers").font(.headline)) {
            
            ValidatedSecureField(
                label: "🔥 Secret Power",
                placeholder: "Your hidden ability",
                text: $secretPower,
                isValid: !secretPower.isEmpty, // ✅ not empty
                showLevel: true
            )

            ValidatedSecureField(
                label: "✅ Confirm Power",
                placeholder: "Confirm your ability",
                text: $confirmPower,
                isValid: confirmPower == secretPower && !confirmPower.isEmpty, // ✅ must match
                errorMessage: "Powers don't match"
            )

        }
    }
    
    // MARK: - Crew Preferences
    private var crewPreferencesSection: some View {
        Section(header: Text("Crew Preferences").font(.headline)) {
            
            VStack(alignment: .leading) {
                Toggle("💖 Join Straw Hats Forever", isOn: $joinForever)
                    .tint(.yellow)
                Text("Loyalty to Luffy & crew")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 30)
            }
            
            VStack(alignment: .leading) {
                Toggle("🗺 Treasure Updates", isOn: $treasureUpdates)
                    .tint(.yellow)
                Text("Adventure notifications")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 30)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Starting Bounty")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(bounty.formattedBounty())
                        .foregroundColor(.yellow)
                        .bold()
                }
                Text("Set your initial reward")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Slider(value: $bounty, in: 0...500, step: 0.1)
                    .tint(.yellow)
                
                HStack {
                    Text("50฿").font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("500M฿").font(.caption).foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Button
    private var setSailButton: some View {
        Button(action: {
            showSuccessAlert = true
        }) {
            Text("⛵ Set Sail 🏴‍☠️")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.red : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!isFormValid)
        .alert("Welcome to the Crew! 🎉", isPresented: $showSuccessAlert) {
            Button("Start Adventure") {
                resetForm()
            }
        
            Button("Stay Here", role: .cancel) { }
        } message: {
            Text("You're now a Straw Hat Pirate with a \(bounty.formattedBounty()) berry bounty!")
        }
    }

    
    private func resetForm() {
        pirateName = ""
        email = ""
        bountyID = ""
        secretPower = ""
        confirmPower = ""
        joinForever = false
        treasureUpdates = false
        bounty = 0.0
    }
}

//
// MARK: - Custom Text Field with Validation
//
struct ValidatedTextField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var isValid: Bool
    var errorMessage: String = ""
    var keyboardType: UIKeyboardType = .default
    var maxLength: Int? = nil
    
    @State private var hasEdited: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).fontWeight(.semibold)
                Spacer()
                if hasEdited {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isValid ? .green : .red)
                }
            }
            
            TextField(placeholder, text: $text, onEditingChanged: { began in
                if began { hasEdited = true }
            })
            .keyboardType(keyboardType)
            .autocapitalization(.none)      // 👈 disable auto-capitalization
            .disableAutocorrection(true)    // 👈 disable autocorrect
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onChange(of: text) { _, newValue in
                if let max = maxLength, newValue.count > max {
                    text = String(newValue.prefix(max))
                }
            }
            
            if let max = maxLength {
                Text("\(text.count)/\(max)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if hasEdited && !isValid {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

//
// MARK: - Custom Secure Field with Validation
struct ValidatedSecureField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var isValid: Bool
    var errorMessage: String = ""
    var showLevel: Bool = false
    
    @State private var hasEdited: Bool = false
    
    private var powerLevel: String {
        if !showLevel { return "" }
        if text.isEmpty { return "" }
        if text.count <= 5 { return "East Blue Level" }
        else if text.count <= 8 { return "Grand Line Level" }
        else { return "New World Level" }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // Label + validation icon
            HStack {
                Text(label).fontWeight(.semibold)
                Spacer()
                if hasEdited {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isValid ? .green : .red)
                }
            }
            
            // SecureField with onChange to trigger validation after edit
            SecureField(placeholder, text: $text)
                .textContentType(.username)     // 👈 stops "Strong Password" popup
                .keyboardType(.default)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: text) { _, _ in
                    hasEdited = true           // ✅ only validates after typing
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            // Show power level for Secret Power field
            if showLevel && !powerLevel.isEmpty {
                Text(powerLevel)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Show error only after edit
            if hasEdited && !isValid && !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

//
// MARK: - Helper Extension
//
extension Double {
    func formattedBounty() -> String {
        if self < 100 {
            // if whole number, no decimal
            if self == floor(self) {
                return String(format: "%.0fM฿", self)
            } else {
                return String(format: "%.1fM฿", self)
            }
        } else {
            return "\(Int(self))M฿"
        }
    }
}




#Preview {
    Part1View()
}
