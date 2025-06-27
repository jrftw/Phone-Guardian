// PasswordCloudBackupView.swift

import SwiftUI

struct PasswordCloudBackupView: View {
    @State private var passwords: [PasswordEntry] = []
    @State private var showAddPassword = false

    var body: some View {
        VStack {
            List {
                ForEach(passwords) { password in
                    HStack {
                        Text(password.account)
                        Spacer()
                        SecureField("Password", text: .constant(password.password))
                            .disabled(true)
                    }
                }
            }

            Button(action: {
                showAddPassword = true
            }) {
                Text("Add Password")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Button(action: backupPasswords) {
                Text("Backup Passwords to Cloud")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Password Cloud Backup")
        .sheet(isPresented: $showAddPassword) {
            AddPasswordView { newPassword in
                passwords.append(newPassword)
            }
        }
    }

    func backupPasswords() {
        // Implement actual iCloud backup logic
        guard !passwords.isEmpty else {
            let alert = UIAlertController(title: "No Passwords", message: "No passwords found to backup.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        // Check iCloud availability
        if FileManager.default.ubiquityIdentityToken != nil {
            // iCloud is available, proceed with backup
            backupToICloud()
        } else {
            // iCloud not available
            let alert = UIAlertController(title: "iCloud Not Available", message: "Please sign in to iCloud to backup passwords.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func backupToICloud() {
        // Create backup file in iCloud Documents directory
        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            showError("Failed to access iCloud Documents")
            return
        }
        
        let backupURL = iCloudURL.appendingPathComponent("PasswordsBackup_\(Date().timeIntervalSince1970).json")
        
        // Convert passwords to JSON (in production, this should be encrypted)
        let passwordData = passwords.map { password in
            [
                "account": password.account,
                "password": password.password,
                "id": password.id.uuidString
            ]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: passwordData, options: .prettyPrinted)
            try jsonData.write(to: backupURL)
            
            let alert = UIAlertController(title: "Backup Successful", message: "\(passwords.count) passwords have been backed up to iCloud.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true, completion: nil)
            }
        } catch {
            showError("Failed to backup passwords: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Backup Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}

struct PasswordEntry: Identifiable {
    let id = UUID()
    let account: String
    let password: String
}

struct AddPasswordView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var account = ""
    @State private var password = ""
    var onAdd: (PasswordEntry) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Account", text: $account)
                SecureField("Password", text: $password)
            }
            .navigationTitle("Add Password")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                onAdd(PasswordEntry(account: account, password: password))
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
