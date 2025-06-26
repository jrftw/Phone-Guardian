// OtherSectionView.swift

import SwiftUI

struct OtherSectionView: View {
    var body: some View {
        Section(header: Text("Other")) {
            Link("Send Feedback", destination: URL(string: "mailto:kdoyle@infinitumimagery.com")!)
            Link("Website", destination: URL(string: "https://infinitumlive.com/apps")!)
            Link("Follow Developer", destination: URL(string: "https://www.tiktok.com/@jrftw")!)
            NavigationLink(destination: ChangelogView()) {
                Text("Changelog")
            }
            Link("View All Our Apps & Software", destination: URL(string: "https://infinitumlive.com/apps/")!)
            Link("Join the Discord", destination: URL(string: "https://discord.gg/qtSx6WXbaE")!)
            Link("View the GitHub", destination: URL(string: "https://github.com/jrftw/Phone-Guardian")!)
            Link("Get the beta", destination: URL(string:"https://testflight.apple.com/join/hRa1wNvr")!)
        }
        
        Section(header: Text("Download our Other Apps")) {
            Link("Blitz Rose 31 Card Game", destination: URL(string: "https://apps.apple.com/us/app/blitz-rose-31-card-game/id6736508556")!)
            Link("Infinitum Block Smash", destination: URL(string: "https://apps.apple.com/us/app/infinitum-block-smash/id6746708231")!)
        }
    }
}
