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

    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbuckPositionSlider: UISlider!
    @IBOutlet weak var musicSpeedSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // メッセージラベルのテキストをクリア
        musicNameLabel.text = ""

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
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
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
                
                // 再生レート変更可能にする
                player.enableRate = true
                
                // sliderに合わせてrateを変更
                player.rate = musicSpeedSlider.value
                
                // 再生
                player.play()
            }
        } else {
            // messageLabelに失敗したことを表示
            musicNameLabel.text = "アイテムのurlがnilなので再生できません"
            
            audioPlayer = nil
        }
        
    }
    
    //選択がキャンセルされた時に呼ばれるメソッド
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePlaybuckPosition(_ sender: Any) {
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
        if let player = audioPlayer {
            player.currentTime -= 10
        }
    }
    
    @IBAction func forward10sec(_ sender: Any) {
        // 10秒進む
        if let player = audioPlayer {
            player.currentTime += 10
        }
    }
    
    @IBAction func changePlaySpeed(_ sender: Any) {
        // 再生速度変更
        if let player = audioPlayer {
            player.rate = musicSpeedSlider.value
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
