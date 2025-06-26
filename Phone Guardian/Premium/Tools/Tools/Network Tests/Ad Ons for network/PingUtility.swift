/* import Foundation

#if os(macOS)
class PingUtility {
    /// Perform a ping to the specified host and return the ping time.
    func performPing(to host: String) -> String {
        let process = Process()
        let pipe = Pipe()

        // Specify the ping executable and arguments
        process.executableURL = URL(fileURLWithPath: "/sbin/ping")
        process.arguments = ["-c", "1", host] // Send 1 ICMP echo request

        // Redirect the output
        process.standardOutput = pipe

        do {
            // Run the ping process
            try process.run()
            process.waitUntilExit()

            // Read the output
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // Parse the output to extract the ping time
                if let pingLine = output
                    .components(separatedBy: .newlines)
                    .first(where: { $0.contains("time=") }),
                   let time = pingLine
                    .components(separatedBy: " ")
                    .first(where: { $0.contains("time=") })?
                    .replacingOccurrences(of: "time=", with: "") {
                    return "\(time) ms"
                }
            }
        } catch {
            print("Error running ping: \(error.localizedDescription)")
        }
        return "Ping Failed"
    }
}
#else
import SwiftyPing

class PingUtility {
    private var pinger: SwiftyPing?

    /// Perform a ping to the specified host and return the ping time via completion handler.
    func performPing(to host: String, completion: @escaping (String) -> Void) {
        do {
            let configuration = try PingConfiguration(interval: 1.0, with: 1) // Single ping request
            pinger = try SwiftyPing(host: host, configuration: configuration, queue: .main)

            pinger?.observer = { response in
                // Correctly handle the response
                let duration = response.duration
                if duration > 0 {
                    completion(String(format: "%.2f ms", duration * 1000)) // Convert seconds to milliseconds
                } else {
                    completion("Ping Failed")
                }
            }

            // Start the ping
            try pinger?.startPinging()
        } catch {
            print("Ping error: \(error.localizedDescription)")
            completion("Ping Failed")
        }
    }

    func stopPing() {
        do {
            try pinger?.stopPinging()
        } catch {
            print("Error stopping ping: \(error.localizedDescription)")
        }
    }
}
#endif
*/

