//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Guillermo Varela on 12/23/16.
//  Copyright © 2016 Guillermo Varela. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var songPicker: UIPickerView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!

    var audioPlayer: AVAudioPlayer!
    var songsList: [URL] = [URL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.songPicker.delegate = self
        self.songPicker.dataSource = self

        songsList = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "media/songs/")!
        songsList.append(contentsOf: Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: "media/songs/")!)
    }

    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return songsList.count
    }

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getSongName(songsList[row])
    }

    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        playSong(row, true)
    }

    @IBAction func play() {
        playSong(songPicker.selectedRow(inComponent: 0), false)
    }

    @IBAction func pause() {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.pause()
        }
    }

    @IBAction func stop() {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0.0
        }
    }

    @IBAction func random() {
        let index = Int(arc4random_uniform(UInt32(songsList.count)))
        songPicker.selectRow(index, inComponent: 0, animated: true)
        playSong(index, true)
    }

    @IBAction func increaseVol() {
        if audioPlayer != nil && audioPlayer.isPlaying && audioPlayer.volume < 1.0 {
            audioPlayer.volume += 0.1
        }
    }

    @IBAction func decreaseVol() {
        if audioPlayer != nil && audioPlayer.isPlaying && audioPlayer.volume > 0.0 {
            audioPlayer.volume -= 0.1
        }
    }

    private func getFileName(_ path: URL) -> String {
        return path.lastPathComponent
    }

    private func getFileNameNoExtension(_ path: URL) -> String {
        return getFileName(path).components(separatedBy: ".").first!
    }

    private func getFileExtension(_ path: URL) -> String {
        return path.pathExtension
    }

    private func getSongName(_ path: URL) -> String {
        return getFileNameNoExtension(path).components(separatedBy: "-")[1]
    }

    private func getCover(_ path: URL) -> UIImage {
        let imagePath = "media/covers/\(getFileNameNoExtension(path)).jpg"
        return UIImage(named: imagePath)!
    }

    private func playSong(_ songIndex: Int, _ forceChange: Bool) {
        if audioPlayer == nil || forceChange {
            coverImageView.image = getCover(songsList[songIndex])
            songTitleLabel.text = getSongName(songsList[songIndex])

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: songsList[songIndex])
                audioPlayer.play()
            } catch let error {
                print(error.localizedDescription)
            }
        } else if audioPlayer != nil && !audioPlayer.isPlaying {
            audioPlayer.play()
        }
    }
}

