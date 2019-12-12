//
//  RecorderViewController.swift
//  AudioRecoderAndPlayer
//
//  Created by jmas2577-User on 2019/12/12.
//  Copyright © 2019 ryutaroyano. All rights reserved.
//

import UIKit
import AVFoundation
import CallKit

class RecorderViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, CXCallObserverDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false
    
    var callObserver: CXCallObserver? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func record(_ sender: Any) {
        record()
    }
    
    @IBAction func play(_ sender: Any) {
        play()
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        
        if call.hasEnded   == true && call.isOutgoing == false || // incoming end
            call.hasEnded   == true && call.isOutgoing == true {   // outgoing end
            print("Disconnected")
            record()
        }
        
        if call.isOutgoing == true && call.hasConnected == false && call.hasEnded == false {
            print("Dialing")
            record()
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
            record()
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            record()
        }
    }
    
    func record() {
        if !isRecording {
            
            /*
             
             info.plist で　NSMicrophoneUsageDescription を許可
             capability にて background mode の Audio, AirPlay, and Picture in Pictureをチェックする。
             
             */
            
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try! AVAudioRecorder(url: getURL(), settings: settings)
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.playAndRecord, mode: .default, options: [])
            try! session.setActive(true)
            
            audioRecorder.delegate = self
            audioRecorder.record()
            
            isRecording = true
            
            statusLabel.text = "録音中"
            recordButton.setTitle("STOP", for: .normal)
            playButton.isEnabled = false
            
        }else{
            
            audioRecorder.stop()
            isRecording = false
            
            let session = AVAudioSession.sharedInstance()
            try! session.setActive(false)
            
            statusLabel.text = "待機中"
            recordButton.setTitle("RECORD", for: .normal)
            playButton.isEnabled = true
            
        }
    }

    func play() {
        if !isPlaying {
            
            let audioPlayer2 = try! AVAudioPlayer(contentsOf: getURL())
            self.audioPlayer = audioPlayer2
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.ambient, mode: .default, options: [])
            
            audioPlayer.delegate = self
            audioPlayer.play()
            
            isPlaying = true
            
            statusLabel.text = "再生中"
            playButton.setTitle("STOP", for: .normal)
            recordButton.isEnabled = false
            
        }else{
            
            audioPlayer.stop()
            isPlaying = false
            
            statusLabel.text = "待機中"
            playButton.setTitle("PLAY", for: .normal)
            recordButton.isEnabled = true
            
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
            audioPlayer.stop()
            isPlaying = false
            
            statusLabel.text = "待機中"
            playButton.setTitle("PLAY", for: .normal)
            recordButton.isEnabled = true
            
        }
    }
    
    func getURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let url = docsDirect.appendingPathComponent("recording.im4a") // im4aだと動く
        return url
    }

}
