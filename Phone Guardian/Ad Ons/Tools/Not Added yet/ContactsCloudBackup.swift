// ContactsCloudBackupView.swift

import SwiftUI
import Contacts

struct ContactsCloudBackupView: View {
    @State private var contacts: [CNContact] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Contacts...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                List(contacts, id: \.identifier) { contact in
                    Text("\(contact.givenName) \(contact.familyName)")
                }
                
                Button(action: backupContacts) {
                    Text("Backup Contacts to Cloud")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .onAppear(perform: loadContacts)
        .navigationTitle("Contacts Cloud Backup")
    }
    
    func loadContacts() {
        isLoading = true
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else if granted {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    var fetchedContacts: [CNContact] = []
                    do {
                        try store.enumerateContacts(with: request) { contact, _ in
                            fetchedContacts.append(contact)
                        }
                        contacts = fetchedContacts
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                } else {
                    errorMessage = "Access to contacts was denied."
                }
            }
        }
    }
    
    func backupContacts() {
        // Implement cloud backup functionality here
        // For the purpose of this example, we'll just display a success message
        let alert = UIAlertController(title: "Success", message: "Contacts have been backed up to the cloud.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}
