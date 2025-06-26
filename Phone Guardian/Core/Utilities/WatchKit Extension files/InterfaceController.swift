//
//  InterfaceController.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/27/24.
//
/*
import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var button: WKInterfaceButton!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Activate WatchConnectivity session if supported
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Action for the WKInterfaceButton
    @IBAction func buttonTapped() {
        label.setText("Button Pressed!")
        
        // Example of sending a message to the paired iPhone app
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["action": "buttonTapped"], replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        }
    }

    // MARK: - WCSession Delegate Methods

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Handle incoming messages from the iPhone app
        if let text = message["text"] as? String {
            DispatchQueue.main.async {
                self.label.setText(text)
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    // MARK: - Optional WCSession Methods for Extended Features
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Reachability changed: \(session.isReachable)")
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Handle received application context updates
    }
}
 */

