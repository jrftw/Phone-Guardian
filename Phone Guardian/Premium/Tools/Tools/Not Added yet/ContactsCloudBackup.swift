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
        // Implement actual iCloud backup functionality
        guard !contacts.isEmpty else {
            let alert = UIAlertController(title: "No Contacts", message: "No contacts found to backup.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
            let alert = UIAlertController(title: "iCloud Not Available", message: "Please sign in to iCloud to backup contacts.", preferredStyle: .alert)
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
        
        let backupURL = iCloudURL.appendingPathComponent("ContactsBackup_\(Date().timeIntervalSince1970).json")
        
        // Convert contacts to JSON
        let contactData = contacts.map { contact in
            [
                "givenName": contact.givenName,
                "familyName": contact.familyName,
                "identifier": contact.identifier
            ]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: contactData, options: .prettyPrinted)
            try jsonData.write(to: backupURL)
            
            let alert = UIAlertController(title: "Backup Successful", message: "\(contacts.count) contacts have been backed up to iCloud.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true, completion: nil)
            }
        } catch {
            showError("Failed to backup contacts: \(error.localizedDescription)")
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
