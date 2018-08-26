//
//  SpeechViewController.swift
//  EightyThreeCreativeAdamMoskovich
//
//  Created by Adam on 25/08/2018.
//  Copyright © 2018 Adam Moskovich. All rights reserved.
//

import UIKit
import Speech
import AVFoundation


// NOT WORKING YET!
// This class contains my current attempts to record and transcribe speech.
// There are two seperate methods I'm attempting in this code
class SpeechViewController: UIViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate {
    //
    // MARK: - Properties
    //
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioURL: URL?
    //
    // MARK: - Lifecycle Functions
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTranscribePermissions()
        createRecodingSession()
    }
    //
    // MARK: - Methods
    //
    func createRecodingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    //    func loadRecordingUI() {
    //        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
    //        recordButton.setTitle("Tap to Record", for: .normal)
    //        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
    //        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
    //        view.addSubview(recordButton)
    //    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        audioURL = audioFilename
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            print("Tap to stop recoding")
            //recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            print("Success")
            transcribeAudio(url: audioURL!)
            recognizeFile(url: audioURL!)
            //recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            print("Fail")
            //recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            print("recording started")
            startRecording()
        } else {
            finishRecording(success: true)
            print("recording stopped")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    // Dictation:
    //    let request = SFSpeechURLRecognitionRequest(url: url)
    //    SFSpeechRecognizer()?.recognitionTask(with: request) { (result, _) in
    //    if let transcription = result?.bestTranscription {
    //    print("\(transcription.formattedString)")
    //    }
    //    }
    
    func recognizeFile(url: URL) {
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !myRecognizer.isAvailable {
            // The recognizer is not available right now
            return
        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        myRecognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                return
            }
            if result.isFinal {
                // Print the speech that has been recognized so far
                print("Speech in the file is \(result.bestTranscription.formattedString)")
            }
        }}
    
    
    ///////////
    // Second Method which repeats many of the same steps
    ///////////
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        // start recognition!
        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }
            
            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                print(result.bestTranscription.formattedString)
            }
        }
    }
    //
    // MARK: - Actions
    //
    @IBAction func speechBtnTapped(_ sender: UIButton) {
        startRecording()
    }
    
}
