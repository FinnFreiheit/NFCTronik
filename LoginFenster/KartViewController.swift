//
//  KartViewController.swift
//  LoginFenster
//
//  Created by Armin Vosoghi Marand on 10.08.20.
//  Copyright © 2020 NFCtronik-Team. All rights reserved.
//

import UIKit
import CoreNFC
class KartViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    
    var session: NFCNDEFReaderSession?
    var TheActualMessage = "MaxMustermann2"
    
    let newLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newLayer.colors = [UIColor.init(red: (5/255), green: (105/255), blue: (127/255), alpha: 1.0).cgColor,
                           UIColor.init(red: (6/255), green: (136/255), blue: (164/255), alpha: 1.0).cgColor]
        newLayer.frame = view.frame
        view.layer.anchorPointZ = 5
        view.layer.addSublayer(newLayer)
        newLayer.anchorPointZ=1
        print("Ich war hier")
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your Iphone near an NDEF Tag"
        session?.begin()
    
    }
    override open var shouldAutorotate: Bool{
        return false
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    
    }
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        var str:String = "\(TheActualMessage)" // Später ändern evtl"
        var strToUnit8:[UInt8] = [UInt8](str.utf8)
        
            if tags.count > 1 {
                // Restart polling in 500 milliseconds.
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }
            
            // Connect to the found tag and write an NDEF message to it.
            let tag = tags.first!
            session.connect(to: tag, completionHandler: { (error: Error?) in
                if nil != error {
                    session.alertMessage = "Unable to connect to tag."
                    session.invalidate()
                    return
                }
                
                tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                    guard error == nil else {
                        session.alertMessage = "Unable to query the NDEF status of tag."
                        session.invalidate()
                        return
                    }

                    switch ndefStatus {
                    case .notSupported:
                        session.alertMessage = "Tag is not NDEF compliant."
                        session.invalidate()
                    case .readOnly:
                        session.alertMessage = "Tag is read only."
                        session.invalidate()
                    case .readWrite:
                        tag.writeNDEF(.init(records: [.init(format: .nfcWellKnown, type: Data([06]), identifier: Data([0x0C]), payload: Data(strToUnit8))]), completionHandler: { (error: Error?) in
                            if nil != error {
                                session.alertMessage = "Write NDEF message fail: \(error!)"
                            } else {
                                session.alertMessage = "Write NDEF message successful."
                            }
                            session.invalidate()
                        })
                    @unknown default:
                        session.alertMessage = "Unknown NDEF tag status."
                        session.invalidate()
                    }
                })
            })
        }
        
        /// - Tag: sessionBecomeActive
        func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
            
        }
        
        /// - Tag: endScanning
        func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
            // Check the invalidation reason from the returned error.
            if let readerError = error as? NFCReaderError {
                // Show an alert when the invalidation reason is not because of a success read
                // during a single tag read mode, or user canceled a multi-tag read mode session
                // from the UI or programmatically using the invalidate method call.
                if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                    && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                    let alertController = UIAlertController(
                        title: "Session Invalidated",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
}
