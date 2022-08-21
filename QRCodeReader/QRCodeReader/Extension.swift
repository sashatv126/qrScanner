//
//  Extension.swift
//  QRCodeReader
//
//  Created by Александр Александрович on 21.08.2022.
//  Copyright © 2022 AppCoda. All rights reserved.
//

import AVFoundation

extension AVCaptureSession {
    // create queue for session
    private var queue: DispatchQueue {
        return DispatchQueue(label: "serial")
    }

    //check device permission
    
    func checkDevice(completion: @escaping ((AVCaptureDevice?) -> Void)) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            completion(nil)
            return
        }
        completion(device)
    }
    
    //set capture session
    
    func addInput(device: AVCaptureDevice?) {
        guard let device = device else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            self.addInput(input)
        } catch {
            return
        }
    }
    
    func addOutput(delegate: AVCaptureMetadataOutputObjectsDelegate) {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        self.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
}

