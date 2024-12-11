import Foundation

struct DownloadSpeedTester {
    static func testDownloadSpeed(completion: @escaping (Double) -> Void) {
        guard let url = URL(string: "http://ipv4.download.thinkbroadband.com/5MB.zip") else {
            completion(0)
            return
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(0)
                return
            }
            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            let bytesReceived = Double(data.count)
            let speedMbps = (bytesReceived * 8) / (elapsedTime * 1_000_000)
            DispatchQueue.main.async {
                completion(speedMbps)
            }
        }
        task.resume()
    }
}

struct UploadSpeedTester {
    static func testUploadSpeed(completion: @escaping (Double) -> Void) {
        guard let url = URL(string: "https://postman-echo.com/post") else {
            completion(0)
            return
        }

        let dataToUpload = Data(count: 5_000_000)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let startTime = CFAbsoluteTimeGetCurrent()
        let task = URLSession.shared.uploadTask(with: request, from: dataToUpload) { _, response, error in
            guard error == nil else {
                completion(0)
                return
            }
            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            let bytesSent = Double(dataToUpload.count)
            let speedMbps = (bytesSent * 8) / (elapsedTime * 1_000_000)
            DispatchQueue.main.async {
                completion(speedMbps)
            }
        }
        task.resume()
    }
}
