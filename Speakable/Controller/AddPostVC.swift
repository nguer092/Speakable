//
//  CreatePostVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class AddPostVC: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        tabBarController?.tabBar.isHidden = true
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
                    }
                }
            }
        } catch {
            print("Failed to record!")
        }
        
        // Audio Settings
        
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    //MARK: - Properties, Outlets, Actions
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var settings = [String : Int]()
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    var seconds = 180
    var timer = Timer()
    var isTimerRunning = false
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if audioRecorder == nil  {
            startRecording()
            runTimer()
        } else if audioRecorder.isRecording {
            finishRecording(success: true)
            saveButton.isEnabled = true
            timer.invalidate()
        } else if !audioRecorder.isRecording {
            seconds = 181
            startRecording()
            runTimer()
        }
    }
    
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioRecorder.url)
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.delegate = self
                self.audioPlayer.play()
            } catch {
                print(#line, error.localizedDescription)
            }
    }
    
    
    @IBAction func saveTapped(_ sender: UIButton) {
        // Get Url, Create data object, Create Pod, Save to Parse
        do {
            let data = try Data(contentsOf: tempFileURL)
            let pod = Pod()
            pod.audio = data
            pod.createdBy = PFUser.current()!
            if descriptionTextField.text != nil {
                pod.podDescription = descriptionTextField.text!
            } else {
                pod.podDescription = "No Description"
            }
            pod.saveInBackground {
                (success: Bool, error: Error?) in
                if (!success) {
                    print(#line, "fy===!")
                }
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            print(#line, error.localizedDescription)
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Functions
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(AddPostVC.updateTimer)), userInfo: nil, repeats: true)
    }
    
    
    @objc func updateTimer() {
        if seconds > 0 {
        seconds -= 1
        timeLabel.text = timeString(time: TimeInterval(seconds))
        }
        else {
            timer.invalidate()
        }
    }
    
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}


extension AddPostVC: AVAudioRecorderDelegate {
    
    var tempFileURL: URL {
        let fileManager = FileManager.default
        var temp = fileManager.temporaryDirectory
        temp.appendPathComponent("sound.m4a")
        return temp
    }
    
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: tempFileURL,
                                                settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print(#line, error.localizedDescription)
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
            recordLabel.text = "Tap to stop"
        } catch {
            print(#line, error.localizedDescription)
        }
    }
    
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            recordLabel.text = "Tap to Re-record"
        } else {
            recordLabel.text = "Tap to Record"
            audioRecorder = nil
        }
    }
}




