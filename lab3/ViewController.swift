//
//  ViewController.swift
//  lab3
//
//  Created by arek on 17/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import UIKit

class ViewController: UIViewController,  URLSessionDownloadDelegate {
    
    @IBAction func thirdButtonAction(_ sender: Any) {
        downloads.forEach { (entry) in
            let (_, download) = entry
            log("Stopping task " + download.filename )
            download.cancel()
        }
    }
    
    //MARK: Console
    var startTime = Date()
    
    @IBOutlet weak var console: UITextView!
    
    @IBAction func clearConsole(_ sender: Any) {
        console.text = ""
    }
    @IBOutlet weak var imageView: UIImageView!
    
    func log(_ str: String) {
        DispatchQueue.main.async {
            
            let finishTime = Date()
            let measuredTime = finishTime.timeIntervalSince(self.startTime)
            let strWithTime = String(format: "[%.2f s] ", measuredTime) + str
            print(strWithTime)
            self.console.text = self.console.text + "\n" + strWithTime
            
            let lastLine = NSMakeRange(self.console.text.count - 1, 1);
            self.console.scrollRangeToVisible(lastLine)
        }
    }
    
    
    //MARK: downloading data
    
    var downloads: [Int: Download] = [:]
    
    
    
    @IBAction func start(_ sender: Any) {
        self.startTime = Date()
        let config = URLSessionConfiguration.background(withIdentifier: "pl.edu.agh.kis.bgDownload")
        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = true
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
        Urls.getUrls().forEach { (url) in
            
            let task = session.downloadTask(with: url)
            downloads[task.taskIdentifier] = Download(filename: url.lastPathComponent, taskId: task.taskIdentifier, task: task)
            log("\(downloads.count) Download started \(url.path)")
            task.resume()
        }
    }
    
    
    //MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let download = self.downloads[downloadTask.taskIdentifier] {
            
            let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let fileManager = FileManager.default
            let targetPath = String(format: "%@/%@", docDir, download.filename)
            
            try? fileManager.removeItem(atPath: targetPath)
            
            if fileManager.fileExists(atPath: location.path) {
                do {
                    let targetURL = URL(fileURLWithPath: targetPath)
                    try fileManager.copyItem(at: location, to: targetURL)
                    self.log("download finished" + download.filename)
                    
                    self.log("Downloaded file can be found in " + String(format: "%@/%@", docDir, download.filename))
                    
                    let data = try? Data(contentsOf: targetURL)
                    let img = UIImage(data: data!)
                    
                    DispatchQueue.main.async {
                        self.self.imageView.image = img
                    }
                    
                    DispatchQueue.global(qos: .background).async {
                        self.faces(img, name: targetURL.lastPathComponent, download: download)
                    }
                    
                } catch let x{
                    print("ERROR: An error occured!" + x.localizedDescription)
                }
            } else {
                print("ERROR: Downloading file finished but unable to locate file in download path!")
            }
        }
    }
    
    func urlSession(_ x: URLSession, downloadTask: URLSessionDownloadTask, didWriteData: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let download = downloads[downloadTask.taskIdentifier] {
            let percent = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100.0
            let roundedPercentage = Int(percent/10.0) * 10
            if (roundedPercentage > download.lastPercentage) {
                download.lastPercentage = roundedPercentage
                log(String(format: "Downloaded %d %% of %@", download.lastPercentage, download.filename))
            }
        }
    }
    
    func faces(_ image: UIImage?, name: String, download: Download) {
        log("Starting face detection for " + name)
        if let validImg = image, let ciImage = CIImage(image: validImg) {
            let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
            let faces = detector!.features(in: ciImage)
            log("Found \(faces.count) faces in \(name).")
            self.downloads.removeValue(forKey: download.taskId)
            let remaining = self.downloads.count > 0 ? "\(self.downloads.count) tasks remaining" : "All tasks finished!"
            log("Task \(name) finished, \(remaining)")
        } else {
            print("ERROR: Face detection failed!")
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class Download {
    let filename: String
    let taskId: Int
    var lastPercentage: Int = 0
    let task: URLSessionDownloadTask
    
    init(filename: String, taskId: Int, task: URLSessionDownloadTask) {
        self.filename = filename
        self.taskId = taskId
        self.task = task
    }
    
    func cancel() {
        task.cancel()
    }
}
