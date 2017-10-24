//
//  RecordSoundsViewController.swift
//  pperfect
//
//  Created by Guilherme Ramos on 20/10/2017.
//  Copyright © 2017 Progeekt. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    var audioRecorder:AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopRecordingButton.isEnabled = false
    }
    
    // MARK: Actions
    
    /// Starts an audio session and creates a recorder
    ///
    /// - Parameter sender: Element that triggered the action
    @IBAction func recordAudio(_ sender: Any) {
        setRecordingState(true)
        
        if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as Array? {
            let recordingPath = "\(dir[0])/recordedVoice.wav"
            let filePath = URL(fileURLWithPath: recordingPath)
            
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
    }
    
    
    /// Stops the current recording session transitions to the PlaySoundsViewController
    ///
    /// - Parameter sender: Element that triggered the action
    @IBAction func stopRecording(_ sender: Any) {
        setRecordingState(false)
        audioRecorder.stop()
        try! AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: Utility methods
    
    /// Set the recording state for both stop and record buttons (inverted state for the record button)
    ///
    /// - Parameters:
    ///   - recording: Recording session state
    fileprivate func setRecordingState(_ recording:Bool) {
        
        if recording {
            recordingLabel.text = "Recording in Progress"
        } else {
            recordingLabel.text = "Tap to record"
        }
        recordButton.isEnabled = !recording
        stopRecordingButton.isEnabled = recording
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            playSoundsVC.recordedAudioURL = sender as! URL
        }
    }
    
}

// MARK: AVAudioRecorderDelegate Extension Section

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording was not successful")
            return
        }
        performSegue(withIdentifier: "stopRecording", sender: recorder.url)
    }
}

