import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        let request = URLRequest(url: url)
        webview.load(request)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
