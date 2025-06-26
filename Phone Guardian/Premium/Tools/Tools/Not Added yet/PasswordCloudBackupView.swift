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
        // Implement cloud backup logic
        // For this example, show a success message
        let alert = UIAlertController(title: "Success", message: "Passwords have been backed up to the cloud.", preferredStyle: .alert)
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
