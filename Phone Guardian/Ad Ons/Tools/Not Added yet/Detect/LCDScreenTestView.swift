//
//  LCDScreenTestView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/26/24.
//
/*
import SwiftUI

struct LCDScreenTestView: View {
    @State private var showFullScreenColor = false
    @State private var selectedColor: Color = .white

    var body: some View {
        VStack {
            Text("LCD Screen Test")
                .font(.title)
                .padding()

            Text("Tap a color below to test your screen for any defects like dead pixels.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            HStack {
                ForEach([Color.red, Color.green, Color.blue, Color.white, Color.black], id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                        showFullScreenColor = true
                    }) {
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showFullScreenColor) {
            FullScreenColorView(color: selectedColor)
        }
        .navigationTitle("LCD Screen Test")
    }
}

struct FullScreenColorView: View {
    var color: Color

    var body: some View {
        color
            .ignoresSafeArea()
            .onTapGesture {
                dismissSheet()
            }
    }

    private func dismissSheet() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
 */
