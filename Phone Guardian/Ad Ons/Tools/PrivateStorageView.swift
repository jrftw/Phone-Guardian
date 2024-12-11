// PrivateStorageView.swift

import SwiftUI
import LocalAuthentication
import os.log

struct PrivateStorageView: View {
    @State private var pin: String = ""
    @State private var storedPin: String? = UserDefaults.standard.string(forKey: "StoredPin")
    @State private var isPinSet = UserDefaults.standard.string(forKey: "StoredPin") != nil
    @State private var isUnlocked = false
    @State private var showFaceIDError = false

    var body: some View {
        NavigationView {
            VStack {
                if !isPinSet {
                    SetPinView(pin: $pin, isPinSet: $isPinSet, storedPin: $storedPin)
                } else if isUnlocked {
                    PrivateStorageAlbumsView(onPinChange: updateStoredPin)
                } else {
                    UnlockView(pin: $pin, storedPin: storedPin, isUnlocked: $isUnlocked, authenticateWithBiometrics: authenticateWithBiometrics)
                }
            }
            .onAppear {
                if isPinSet && !isUnlocked {
                    authenticateWithBiometrics()
                }
            }
            .alert(isPresented: $showFaceIDError) {
                Alert(title: Text("Authentication Failed"), message: Text("Unable to authenticate using biometrics."), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Private Storage", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private func updateStoredPin(newPin: String) {
        UserDefaults.standard.set(newPin, forKey: "StoredPin")
        storedPin = newPin
        os_log("Stored PIN updated.")
    }

    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your private storage."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        os_log("Biometric authentication succeeded.")
                    } else {
                        os_log("Biometric authentication failed: %@", authenticationError?.localizedDescription ?? "Unknown error")
                        showFaceIDError = true
                    }
                }
            }
        } else {
            os_log("Biometric authentication not available: %@", error?.localizedDescription ?? "Unknown error")
        }
    }
}

// MARK: - Set PIN View

struct SetPinView: View {
    @Binding var pin: String
    @Binding var isPinSet: Bool
    @Binding var storedPin: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Your PIN")
                .font(.title2)
                .bold()

            SecureField("Enter PIN (4+ digits)", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if pin.count >= 4 {
                    storedPin = pin
                    UserDefaults.standard.set(pin, forKey: "StoredPin")
                    isPinSet = true
                    os_log("PIN set successfully.")
                }
            }) {
                Text("Set PIN")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(pin.count >= 4 ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(pin.count < 4)
        }
        .padding()
    }
}

// MARK: - Unlock View

struct UnlockView: View {
    @Binding var pin: String
    var storedPin: String?
    @Binding var isUnlocked: Bool
    var authenticateWithBiometrics: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter PIN to Access")
                .font(.title2)
                .bold()

            SecureField("Enter PIN", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if pin == storedPin {
                    isUnlocked = true
                    os_log("PIN authentication succeeded.")
                } else {
                    os_log("PIN authentication failed.")
                }
            }) {
                Text("Unlock")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(pin.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(pin.isEmpty)
            .padding(.bottom, 20)

            Button(action: {
                authenticateWithBiometrics()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Use Face ID")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - Private Storage Albums View

struct PrivateStorageAlbumsView: View {
    @State private var albums: [String] = UserDefaults.standard.stringArray(forKey: "PrivateAlbums") ?? []
    @State private var newAlbumName: String = ""
    var onPinChange: (String) -> Void

    var body: some View {
        VStack {
            Text("Private Albums")
                .font(.title2)
                .bold()
                .padding(.top)

            List {
                ForEach(albums, id: \.self) { album in
                    NavigationLink(destination: AlbumDetailView(albumName: album)) {
                        Text(album)
                    }
                }
                .onDelete(perform: deleteAlbum)
            }

            HStack {
                TextField("New Album Name", text: $newAlbumName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: addAlbum) {
                    Image(systemName: "plus")
                        .padding()
                        .background(newAlbumName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(newAlbumName.isEmpty)
            }
            .padding()

            Button(action: changePin) {
                Text("Change PIN")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationBarTitle("Private Albums", displayMode: .inline)
    }

    private func addAlbum() {
        guard !newAlbumName.isEmpty else { return }
        albums.append(newAlbumName)
        saveAlbums()
        os_log("Added new album: %@", newAlbumName)
        newAlbumName = ""
    }

    private func deleteAlbum(at offsets: IndexSet) {
        albums.remove(atOffsets: offsets)
        saveAlbums()
        let indices = offsets.map { String($0) }.joined(separator: ", ")
        os_log("Deleted album at offsets: %@", indices)
    }

    private func saveAlbums() {
        UserDefaults.standard.set(albums, forKey: "PrivateAlbums")
    }

    private func changePin() {
        let alert = UIAlertController(title: "Change PIN", message: "Enter new PIN", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New PIN (4+ digits)"
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            if let newPin = alert.textFields?.first?.text, newPin.count >= 4 {
                onPinChange(newPin)
                os_log("PIN changed successfully.")
            } else {
                os_log("Failed to change PIN: Invalid PIN entered.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }),
           let rootVC = window.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}

// MARK: - Album Detail View

struct AlbumDetailView: View {
    let albumName: String
    @State private var items: [String] = []
    @State private var newItemName: String = ""

    var body: some View {
        VStack {
            Text(albumName)
                .font(.title2)
                .bold()
                .padding(.top)

            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete(perform: deleteItem)
            }

            HStack {
                TextField("Add Item", text: $newItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: addItem) {
                    Image(systemName: "plus")
                        .padding()
                        .background(newItemName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(newItemName.isEmpty)
            }
            .padding()
        }
        .onAppear {
            loadItems()
        }
        .onDisappear {
            saveItems()
        }
        .navigationBarTitle(albumName, displayMode: .inline)
    }

    private func addItem() {
        guard !newItemName.isEmpty else { return }
        items.append(newItemName)
        os_log("Added item: %@", newItemName)
        newItemName = ""
    }

    private func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        let indices = offsets.map { String($0) }.joined(separator: ", ")
        os_log("Deleted item at offsets: %@", indices)
    }

    private func loadItems() {
        items = UserDefaults.standard.stringArray(forKey: "Items_\(albumName)") ?? []
        os_log("Loaded items for album: %@", albumName)
    }

    private func saveItems() {
        UserDefaults.standard.set(items, forKey: "Items_\(albumName)")
        os_log("Saved items for album: %@", albumName)
    }
}
