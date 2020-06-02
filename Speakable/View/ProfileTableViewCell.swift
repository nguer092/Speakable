//
//  ProfileTableViewCell.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse
import AVFoundation 

class ProfileTableViewCell: UITableViewCell {

    //MARK: - Properties, Outlets, Actions
    
    var audioFile: Data?
    var audioPlayer : AVAudioPlayer?
    var timer = Timer()
    @IBOutlet weak var podDescription: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        if self.audioPlayer != nil {
            if (self.audioPlayer?.isPlaying)! {
                self.audioPlayer?.pause()
                self.playButton.setImage(#imageLiteral(resourceName: "bluePlay"), for: .normal)
            }
            else {
                self.audioPlayer?.play()
                self.playButton.setImage(#imageLiteral(resourceName: "bluePause"), for: .normal)
            }
            return
        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(data: self.audioFile!)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.delegate = self as? AVAudioPlayerDelegate
            self.audioPlayer?.play()
            self.playButton.setImage(#imageLiteral(resourceName: "bluePause"), for: .normal)
        } catch {
            print(#line, error.localizedDescription)
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ProfileTableViewCell.updateProgress)), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func rewind15Pressed(_ sender: UIButton) {
        audioPlayer?.currentTime = -15
    }
    
    @IBAction func forward15Pressed(_ sender: UIButton) {
        audioPlayer?.currentTime = 15
    }
    
    
    func configureCell(pod: Pod){
        self.progressView.progress = 0
        self.audioFile = pod.audio
        self.podDescription.text = pod.podDescription
    }
    
    
    @objc func updateProgress() {
        // Increase progress value
        
        if self.audioPlayer != nil {
            progressView.progress = Float((self.audioPlayer?.currentTime)! / (self.audioPlayer?.duration)!)
        }
        
        if self.progressView.progress >= 1 {
            self.timer.invalidate()
            self.progressView.progress = 0.0
        }
        
        if self.audioPlayer?.isPlaying == false {
            self.playButton.setImage(#imageLiteral(resourceName: "bluePlay"), for: .normal)
        }
    }
    
}

