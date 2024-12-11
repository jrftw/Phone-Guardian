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
    }
}
