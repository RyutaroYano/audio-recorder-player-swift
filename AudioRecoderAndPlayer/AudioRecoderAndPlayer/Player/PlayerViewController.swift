//
//  PlayerViewController.swift
//  AudioRecoderAndPlayer
//
//  Created by jmas2577-User on 2019/12/12.
//  Copyright © 2019 ryutaroyano. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var isPlaying = false
    var playbackSpeed : Float = 2
    
    //スライダーと曲を連動させるタイマー
    var timer = Timer()

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbuckPositionSlider: UISlider!
    @IBOutlet weak var musicSpeedSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // メッセージラベルのテキストをクリア
        musicNameLabel.text = "曲名"
        
        addRemoteCommandEvent()
        
    }
    
    @IBAction func selectMusic(_ sender: Any) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択を不可にする。（trueにすると、複数選択できる）
        picker.allowsPickingMultipleItems = false
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
        
    }
    
    // メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        // このfunctionを抜ける際にピッカーを閉じ、破棄する
        // (defer文はfunctionを抜ける際に実行される)
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        // 選択した曲情報がmediaItemCollectionに入っている
        // mediaItemCollection.itemsから入っているMPMediaItemの配列を取得できる
        let items = mediaItemCollection.items
        if items.isEmpty {
            // itemが一つもなかったので戻る
            return
        }
        
        // 先頭のMPMediaItemを取得し、そのassetURLからプレイヤーを作成する
        let item = items[0]
        if let url = item.assetURL {
            do {
                // itemのassetURLからプレイヤーを作成する
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch  {
                // エラー発生してプレイヤー作成失敗
                
                // messageLabelに失敗したことを表示
                musicNameLabel.text = "このurlは再生できません"
                
                audioPlayer = nil
                
                // 戻る
                return
            }
            
            // 再生開始
            if let player = audioPlayer {
                
                
                // メッセージラベルに曲タイトルを表示
                // (MPMediaItemが曲情報を持っているのでそこから取得)
                musicNameLabel.text = item.title ?? ""
                
                // sliderに合わせて再生位置を変更
                playbuckPositionSlider.maximumValue = Float(player.duration)
                
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeCount), userInfo: nil, repeats: true)
                
                // 再生レート変更可能にする
                player.enableRate = true
                
                // sliderに合わせてrateを変更
                player.rate = musicSpeedSlider.value * playbackSpeed
                
                totalTimeLabel.text = formatTimeString(d: player.duration)
                
                /// バックグラウンドでも再生できるセッションに設定する
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setCategory(AVAudioSession.Category.playback)
                } catch  {
                    // エラー処理
                    fatalError("カテゴリ設定失敗")
                }

                // sessionのアクティブ化
                do {
                    try session.setActive(true)
                } catch {
                    // audio session有効化失敗時の処理
                    // (ここではエラーとして停止している）
                    fatalError("session有効化失敗")
                }
                
                // 再生
                player.play()
                
                var nowPlayingInfo = [String : Any]()
                // シングル名
                nowPlayingInfo[MPMediaItemPropertyTitle] = item.title ?? ""
                // アーティスト名
                nowPlayingInfo[MPMediaItemPropertyArtist] = item.artist ?? ""
                // ジャケット (MPMediaItemArtwork)
//                nowPlayingInfo[MPMediaItemPropertyArtwork] = item.artwork ?? MPMediaItemPropertyArtwork

                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
                // ミュージックの長さ
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
                // ミュージックの再生時点
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime

                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        } else {
            // messageLabelに失敗したことを表示
            musicNameLabel.text = "アイテムのurlがnilなので再生できません"
            
            audioPlayer = nil
        }
        
    }
    
    func formatTimeString(d: Double) -> String {
        let s = d.truncatingRemainder(dividingBy: 60).rounded(.towardZero)
        let sm = (d - s) / 60
        let m = sm.truncatingRemainder(dividingBy: 60).rounded(.towardZero)
        let mh = (d - m - s) / 3600
        let h = mh.truncatingRemainder(dividingBy: 3600).rounded(.towardZero)
        let str = String(format: "%02d:%02d:%02d", Int(h), Int(m), Int(s))
        return str
    }
    
    //選択がキャンセルされた時に呼ばれるメソッド
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePlaybuckPosition(_ sender: Any) {
        // 再生位置をスライダーと同期する
        changePosition()
    }
    
    func changePosition() {
        if let player = audioPlayer {
            player.currentTime = TimeInterval(playbuckPositionSlider.value)
        }
    }
    
    @IBAction func playMusic(_ sender: Any) {
        
        if !isPlaying {
            
            // 再生
            if let player = audioPlayer {
                player.play()
            }
            
            // sliderと再生位置を同期
            if timer.isValid == false {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeCount), userInfo: nil, repeats: true)
            }
            
            isPlaying = true
            
            playButton.setTitle("STOP", for: .normal)
            
        }else{
            
            // 一時停止
            if let player = audioPlayer {
                player.pause()
            }
            isPlaying = false
            
            playButton.setTitle("PLAY", for: .normal)
            
        }
    }
    
    @IBAction func stopMusic(_ sender: Any) {
        // 停止
        if let player = audioPlayer {
            player.stop()
        }
    }

    @IBAction func back10sec(_ sender: Any) {
        // 10秒戻る
        timeChange(second: -10)
    }
    
    @IBAction func forward10sec(_ sender: Any) {
        // 10秒進む
        timeChange(second: 10)
    }
    
    @IBAction func changePlaySpeed(_ sender: Any) {
        // 再生速度変更
        if let player = audioPlayer {
            player.rate = musicSpeedSlider.value * playbackSpeed
        }
    }
    
    @objc func timeCount() {
        if let player = audioPlayer {
            playbuckPositionSlider.value = Float(player.currentTime)
            currentTimeLabel.text = formatTimeString(d: player.currentTime)
        }
    }
    
    // MARK: Remote Command Event
    func addRemoteCommandEvent() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.togglePlayPauseCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remoteTogglePlayPause(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.playCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remotePlay(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.pauseCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remotePause(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.nextTrackCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remoteNextTrack(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.previousTrackCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remotePrevTrack(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget{
//            [unowned self]
            commandEvent in
            self.changePlaybackPosition(commandEvent)
            return .success
        }
        commandCenter.changePlaybackRateCommand.isEnabled = true
        commandCenter.changePlaybackRateCommand.addTarget{commandEvent in
            return .success

        }
    }
    
    // Handle remote events
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.skipForwardCommand.preferredIntervals = [15.0]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
            self.timeChange(second: event.interval)
            return .success
        }
        
        // Scrubber
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self](remoteEvent) -> MPRemoteCommandHandlerStatus in
            guard let self = self else {return .commandFailed}
            if let player = self.audioPlayer, let positionEvent = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                player.currentTime = positionEvent.positionTime
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true

        // Register to receive events
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func remoteTogglePlayPause(_ event: MPRemoteCommandEvent) {
        // イヤホンのセンターボタンを押した時の処理
        if let player = audioPlayer {
            if player.isPlaying {
                player.stop()
            } else {
                player.play()
            }
        }
    }
    
    func remotePlay(_ event: MPRemoteCommandEvent) {
        // プレイボタンが押された時の処理
        if let player = audioPlayer {
            player.play()
        }
    }
    
    func remotePause(_ event: MPRemoteCommandEvent) {
        // ポーズボタンが押された時の処理
        if let player = audioPlayer {
            player.stop()
        }
    }
    
    func remotePrevTrack(_ event: MPRemoteCommandEvent) {
        // 10秒戻る
        timeChange(second: -10)
    }
    
    func remoteNextTrack(_ event: MPRemoteCommandEvent) {
        // 10秒進む
        timeChange(second: 10)
    }
    
    func changePlaybackPosition(_ event: MPRemoteCommandEvent) {
        if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
            if let player = audioPlayer {
                player.currentTime = positionEvent.positionTime
            }
        }
    }
    
    func timeChange(second time: Double) {
        // time秒だけ時間を変更する
        if let player = audioPlayer {
            player.currentTime = player.currentTime + time
        }
    }
    
}



/*
 
 ・プレイリストの作成
 ・曲の複数選択
 ・バックグラウンドのスライダー
 ・歌詞を表示できるように　MPMediaItemCollection
 ・曲がなくても再生ボタンを押せるバグ
 
 */
