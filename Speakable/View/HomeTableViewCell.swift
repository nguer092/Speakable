//
//  HomeTableViewCell.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class HomeTableViewCell: UITableViewCell {

    //MARK: - Properties, Outlets, Actions
    
    var audioFile: Data?
    var audioPlayer : AVAudioPlayer!
    var timer = Timer()
    var playButtonTapped : (()->())?
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var progressView : UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var listensCountLabel: UILabel!
    
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playButtonTapped?()
        
        if self.audioPlayer != nil {
            if self.audioPlayer.isPlaying {
                self.audioPlayer.pause()
                self.playButton.setImage(#imageLiteral(resourceName: "bluePlay"), for: .normal)
            }
            else {
                self.audioPlayer.play()
                self.playButton.setImage(#imageLiteral(resourceName: "bluePause"), for: .normal)
            }
            return
        }
        do {
            self.audioPlayer = try AVAudioPlayer(data: self.audioFile!)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self as? AVAudioPlayerDelegate
            self.audioPlayer.play()
            self.playButton.setImage(#imageLiteral(resourceName: "bluePause"), for: .normal)
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
        } catch {
            print(#line, error.localizedDescription)
        }
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HomeTableViewCell.updateProgress)), userInfo: nil, repeats: true)
    }
    
    @IBAction func rewindTapped(_ sender: UIButton) {
          if audioPlayer != nil {
                  audioPlayer?.currentTime -= 15
                  }
        }
    

    @IBAction func forwardTapped(_ sender: UIButton) {
            if audioPlayer != nil {
            audioPlayer?.currentTime += 15
            }
        }

}


//MARK: - Functions

extension HomeTableViewCell{
    
    func configureCell(pod: Pod){
        self.usernameLabel.text = pod.createdBy.username
        self.audioFile = pod.audio
        self.listensCountLabel.text = "Listens: \(pod.listens)"
        self.descriptionLabel.text = pod.podDescription
        let userImageFile = pod.createdBy["picture"] as? PFFileObject
        userImageFile?.getDataInBackground {
            (imageData: Data?, error: Error?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.profilePicture.image = image
                }
                else {
                    print(error?.localizedDescription as Any)
                }
            }
        }
        profilePicture.formatImage()
    }
    
    
    @objc func updateProgress() {
        progressView.progress = Float(self.audioPlayer.currentTime / self.audioPlayer.duration)
        if self.progressView.progress >= 1 {
            self.timer.invalidate()
            self.progressView.progress = 0.0
        }
        if self.audioPlayer?.isPlaying == false {
            self.playButton.setImage(#imageLiteral(resourceName: "bluePlay"), for: .normal)
        }
    }
    
}


