//
//  CameraManager.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/20/24.
//


import Foundation
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureMovieFileOutput()

    func setupSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.startRunning()
    }

    func stopSession() {
        captureSession.stopRunning()
    }

    func startRecording() {
        let outputDirectory = FileManager.default.temporaryDirectory
        let filePath = outputDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        videoOutput.startRecording(to: filePath, recordingDelegate: self)
    }

    func stopRecording() {
        videoOutput.stopRecording()
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording failed: \(error.localizedDescription)")
        } else {
            print("Recording completed: \(outputFileURL)")
        }
    }
}