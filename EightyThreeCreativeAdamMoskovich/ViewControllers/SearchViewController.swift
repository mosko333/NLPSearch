//
//  SearchViewController.swift
//  EightyThreeCreativeAdamMoskovich
//
//  Created by Adam on 24/08/2018.
//  Copyright © 2018 Adam Moskovich. All rights reserved.
//

import UIKit
import Speech

class SearchViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    //
    // MARK: - Properties
    //
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    //
    // MARK: - Outlets
    //
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var recordBtn: UIButton!
    
    //
    // MARK: - Lifecycle Functions
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        DatabaseController.shared.memoizationKeyWords()
        checkForSpeechAuthorization()
    }
    
    //
    // MARK: - Methods
    //
    func setupSearchBar() {
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchBar.delegate = self
        hideKeyboard()
    }
    
    func checkForSpeechAuthorization() {
        recordBtn.alpha = 0.3
        recordBtn.isEnabled = false
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.recordBtn.isEnabled = isButtonEnabled
            }
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            self.searchBar.isUserInteractionEnabled = true
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                self.searchBar.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recordBtn.isEnabled = true
                self.searchBar.isUserInteractionEnabled = true
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
            searchBar.isUserInteractionEnabled = true
        }
        searchBar.text = "Say something, I'm listening!"
    }
    
    func performSearch() {
        guard let searchPhrase = searchBar.text,
            !searchPhrase.isEmpty else { return }
        DatabaseController.shared.generateResultsWith(searchPhrase: searchPhrase)
        searchResultsTableView.reloadData()
    }
    
    //
    // MARK: - Delegate @ Data Source Methods
    //
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordBtn.isEnabled = true
        } else {
            recordBtn.isEnabled = false
        }
    }
    
    //
    // MARK: - Actions
    //
    @IBAction func recordBtnTapped(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordBtn.isEnabled = false
            recordBtn.alpha = 0.3
            performSearch()
            searchBar.isUserInteractionEnabled = true
        } else {
            startRecording()
            recordBtn.alpha = 1
            searchBar.isUserInteractionEnabled = false
        }
    }
}

//
// MARK: - Extensions
//
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    //
    // MARK: - Delegate @ Data Source Methods
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseController.shared.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? SearchResultTableViewCell {
            let productName = DatabaseController.shared.searchResults[indexPath.row]
            cell.productNameLabel.text = productName
            return cell
        }
        return UITableViewCell()
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    //
    // MARK: - Delegate @ Data Source Methods
    //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    //
    // MARK: - Methods
    //
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        searchBar.endEditing(true)
    }
}
