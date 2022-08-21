//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController {
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrame: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session()
        qrCodeScanner()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func session() {
        captureSession.checkDevice {[weak self] device in
            self?.captureSession.addInput(device: device)
        }
        captureSession.addOutput(delegate: self)
        setupPreviewLayer()
        captureSession.startRunning()
        
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: topbar)
    }
    
    private func setupPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
    }
    
    private func qrCodeScanner() {
        qrCodeFrame = UIView()
        
        if let qrCodeFrame = qrCodeFrame {
            qrCodeFrame.layer.borderColor = UIColor.systemGreen.cgColor
            qrCodeFrame.layer.borderWidth = 2
            view.addSubview(qrCodeFrame)
            view.bringSubview(toFront: qrCodeFrame)
        }
    }
    
    func launchApp(decodedURL: String) {
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrame?.frame = CGRect.zero
            messageLabel.text = "qr code not Found"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObj = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrame?.frame = barCodeObj!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                launchApp(decodedURL: metadataObj.stringValue!)
            }
        }
    }
}
