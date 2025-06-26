// DuplicateResultsView.swift

import SwiftUI
import Contacts
import EventKit
import PhotosUI

struct DuplicateResultsView: View {
    @ObservedObject var scanner = DuplicateScanner.shared
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [UUID: DuplicateItem] = [:]
    @State private var showDeletionConfirmation = false
    @State private var deletionError: DeletionError?

    var body: some View {
        NavigationView {
            List {
                ForEach(scanner.duplicatesByCategory.keys.sorted(), id: \.self) { category in
                    if let duplicates = scanner.duplicatesByCategory[category], !duplicates.isEmpty {
                        Section(header: Text(category)) {
                            ForEach(duplicates) { duplicate in
                                DuplicateRowView(
                                    duplicate: duplicate,
                                    category: category,
                                    isSelected: selectedItems[duplicate.id] != nil
                                ) {
                                    if selectedItems[duplicate.id] != nil {
                                        selectedItems.removeValue(forKey: duplicate.id)
                                    } else {
                                        selectedItems[duplicate.id] = duplicate
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Duplicate Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !selectedItems.isEmpty {
                        Button("Delete (\(selectedItems.count))") {
                            showDeletionConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert(isPresented: $showDeletionConfirmation) {
                Alert(
                    title: Text("Delete Duplicates"),
                    message: Text("Are you sure you want to delete the selected items? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteSelectedItems()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(item: $deletionError) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func deleteSelectedItems() {
        let itemsToDelete = Array(selectedItems.values)
        var deletionErrors: [String] = []
        let group = DispatchGroup()

        for item in itemsToDelete {
            group.enter()
            switch item.detail {
            case "Duplicate Photo", "Duplicate Video":
                deleteAsset(item.asset) { success, error in
                    if !success, let error = error {
                        deletionErrors.append(error.localizedDescription)
                    }
                    group.leave()
                }
            case "Duplicate Contact":
                deleteContact(item.contact) { success, error in
                    if !success, let error = error {
                        deletionErrors.append(error.localizedDescription)
                    }
                    group.leave()
                }
            case "Duplicate Event":
                deleteEvent(item.event) { success, error in
                    if !success, let error = error {
                        deletionErrors.append(error.localizedDescription)
                    }
                    group.leave()
                }
            default:
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if deletionErrors.isEmpty {
                selectedItems.removeAll()
                scanner.startDuplicateScan()
            } else {
                self.deletionError = DeletionError(message: deletionErrors.joined(separator: "\n"))
            }
        }
    }

    private func deleteAsset(_ asset: PHAsset?, completion: @escaping (Bool, Error?) -> Void) {
        guard let asset = asset else {
            completion(false, nil)
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }, completionHandler: { success, error in
            completion(success, error)
        })
    }

    private func deleteContact(_ contact: CNContact?, completion: @escaping (Bool, Error?) -> Void) {
        guard let contact = contact else {
            completion(false, nil)
            return
        }

        let store = CNContactStore()
        do {
            let request = CNSaveRequest()
            if let mutableContact = contact.mutableCopy() as? CNMutableContact {
                request.delete(mutableContact)
                try store.execute(request)
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        } catch {
            completion(false, error)
        }
    }

    private func deleteEvent(_ event: EKEvent?, completion: @escaping (Bool, Error?) -> Void) {
        guard let event = event else {
            completion(false, nil)
            return
        }

        let store = EKEventStore()
        do {
            try store.remove(event, span: .thisEvent)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
}

struct DeletionError: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - DuplicateRowView

struct DuplicateRowView: View {
    let duplicate: DuplicateItem
    let category: String
    let isSelected: Bool
    let toggleSelection: () -> Void

    var body: some View {
        HStack {
            if category == "Photos" || category == "Videos" {
                if let asset = duplicate.asset {
                    ThumbnailView(asset: asset)
                        .frame(width: 50, height: 50)
                }
            } else {
                Image(systemName: category == "Contacts" ? "person.crop.circle" : "calendar")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading) {
                Text(duplicate.name)
                    .font(.headline)
                Text(duplicate.detail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: toggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - ThumbnailView

struct ThumbnailView: View {
    let asset: PHAsset
    @State private var thumbnail: UIImage? = nil

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        let manager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat

        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 50, height: 50),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            thumbnail = image
        }
    }
}
