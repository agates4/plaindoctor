/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The primary view controller. The speach-to-text engine is managed an configured here.
 */

import UIKit
import Speech
import SwiftyJSON
import Alamofire
import SwiftSiriWaveformView
import SwiftSpinner
import SideMenu

class RecordViewController: MenuItem, SFSpeechRecognizerDelegate {
    
    // time elapsed / not found notifier
    @IBOutlet weak var displayTimeLabel: UILabel!
    @IBOutlet weak var notFound: UILabel!
    
    // used to get user location
    let loc = GetLocation()
    
    // footer stuff
    @IBOutlet weak var micButton: UIButton!
    
    // text output
    @IBOutlet weak var textLabel: UITextView!
    
    // wave form
    @IBOutlet weak var audioView: SwiftSiriWaveformView!
    
    // timer to update waveform
    var waveFormMultiplier : CGFloat = 1.0
    var updateWaveTimer:Timer?
    var waveFormChanger:CGFloat = 0.01
    
    // timers to update elapsed time
    var updateElapsedTimer = Timer()
    var elapsedTimeInterval = TimeInterval()
    
    // our transcript
    private var lastSessionString = ""
    private var diagnosisString = ""
    
    // speech to text properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var wantToRecord = false
    
    @IBOutlet var recordButton : UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        (navigationItem.titleView?.subviews[0] as! UIImageView).image = UIImage(named: "Microphone.png")
        
        self.audioView.density = 1.0
        
        textLabel.text = "Ready to record?"
        self.micButton.alpha = 0
        
        // Disable the record buttons until authorization has been granted.
        recordButton.isEnabled = false
        
        if self.view.frame.width == 320.0 {
            waveFormMultiplier = 4.0
        }
    }
    
    internal func refreshAudioView(_:Timer) {
        if self.audioView.amplitude <= self.audioView.idleAmplitude || self.audioView.amplitude > 1.0 {
            self.waveFormChanger *= -1.0
        }
        
        // Simply set the amplitude to whatever you need and the view will update itself.
        self.audioView.amplitude += self.waveFormChanger * waveFormMultiplier
    }
    
    override public func viewDidAppear(_ animated: Bool) {

        self.micButton.fadeIn()
        
        speechRecognizer.delegate = self
        
        loc.request()
        
        SFSpeechRecognizer.requestAuthorization { authStatus in

            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording(restartSession : Bool = false) throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                if(restartSession)
                {
                    self.diagnosisString = self.lastSessionString + result.bestTranscription.formattedString
                    self.textLabel.text = self.lastSessionString + result.bestTranscription.formattedString
                    self.textLabel.scrollRectToVisible(self.textLabel.frame, animated: true)
                    isFinal = result.isFinal
                }
                else
                {
                    self.diagnosisString = result.bestTranscription.formattedString
                    self.textLabel.text = result.bestTranscription.formattedString
                    self.textLabel.scrollRectToVisible(CGRect(x: self.textLabel.frame.origin.x, y: self.textLabel.frame.origin.y - 30, width: self.textLabel.frame.width, height: self.textLabel.frame.height), animated: true)
                    isFinal = result.isFinal
                }
            }
            
            if !self.wantToRecord {
                
                print("ending")
                
                self.audioEngine.stop()
                self.recognitionRequest?.endAudio()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            
            }
            else if error != nil && self.wantToRecord {
                
                print("error, attempting to restart")
                
                self.audioEngine.stop()
                self.recognitionRequest?.endAudio()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.lastSessionString = self.diagnosisString + " "
                try! self.startRecording(restartSession: true)
                
            }
            else if isFinal && self.wantToRecord {
                
                print("one minute limit reached, trying to start another session")
                
                self.audioEngine.stop()
                self.recognitionRequest?.endAudio()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.lastSessionString = self.diagnosisString + " "
                try! self.startRecording(restartSession: true)

            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    // updates the time displayed when recording
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - elapsedTimeInterval
        
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)

        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        displayTimeLabel.text = "\(strMinutes):\(strSeconds)"
    }
    
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning
        {
            wantToRecord = false
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
            
            SwiftSpinner.show("Fetching Data...")
            
            var cityStreet : String = "Not provided"
            var parameters : Parameters = [
                "diagnosis": self.diagnosisString,
                "timezone": (NSTimeZone.local as NSTimeZone).name,
                "location": cityStreet,
                "user_id": self.userID
            ]
            loc.getAddress(completion: { (result) -> () in
                if let city = result["City"] as? String
                {
                    cityStreet = (result["Street"] as! String) + ", " + city + ", " + (result["State"] as! String) + " " + (result["ZIP"] as! String)
                    parameters["location"] = cityStreet
                }
                var swiftyJsonVar : JSON!
                Alamofire.request("https://geczy.tech/plaindoc/endpoint/analyze_transcript.php", method: .post, parameters: parameters, encoding: JSONEncoding(options: [])).responseJSON { (responseData) -> Void in
                    var appointmentID : Int = 0
                    
                    if((responseData.result.value) != nil) {
                        swiftyJsonVar = JSON(responseData.result.value!)
                        
                        appointmentID = Int(swiftyJsonVar["Appointment_ID"].numberValue as Int!)
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DiagnosisViewController") as! DiagnosisViewController
                        let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        controller.modalTransitionStyle = modalStyle
                        controller.appointmentID = appointmentID
                        controller.comeFromHome = true
                        self.micButton.alpha = 0
                        
                        self.navigationController?.pushViewController(controller, animated: false)
                    }
                    else
                    {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            print("speech running, will stop")
                            self.backToNorm()
                            SwiftSpinner.hide()
                            self.notFound.fadeInOut(duration: 0.5, delay: 0.2)
                        }
                    }
                }
            })
        }
        else // audio engine not running
        {
            wantToRecord = true
            print("speech not running, will start")
            try! startRecording()
            textLabel.text = ""
            recordButton.setTitle("Stop recording", for: [])
            backToRecord()
        }
    }
    
    fileprivate func backToRecord()
    {
        textLabel.textAlignment = .right
        self.textLabel.font = self.textLabel.font?.withSize(17)
        let updateElapsedTime : Selector = #selector(RecordViewController.updateTime)
        elapsedTimeInterval = NSDate.timeIntervalSinceReferenceDate
        recordButton.setTitle("Stop recording", for: [])
        let image : UIImage = UIImage(named : "yesR_copy.png")!
        recordButton.setImage(image, for: .normal)
        updateWaveTimer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(RecordViewController.refreshAudioView(_:)), userInfo: nil, repeats: true)
        updateElapsedTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: updateElapsedTime, userInfo: nil, repeats: true)
        audioView.numberOfWaves = 5
    }
    
    fileprivate func backToNorm()
    {
        recognitionRequest = nil
        recognitionTask = nil
        audioEngine.stop()
        self.displayTimeLabel.text = "00:00"
        self.textLabel.textAlignment = .center
        self.textLabel.font = self.textLabel.font?.withSize(28)
        self.textLabel.text = "Ready to record?"
        let image : UIImage = UIImage(named : "notR_copy.png")!
        self.recordButton.setImage(image, for: .normal)
        recordButton.isEnabled = true
        recordButton.setTitle("Start Recording", for: [])
        self.updateWaveTimer?.invalidate()
        self.updateElapsedTimer.invalidate()
        self.audioView.numberOfWaves = 1
        self.audioView.amplitude = 0
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        self.micButton.alpha = 0
    }
    
    @IBAction func unwindToRecord(segue: UIStoryboardSegue){
        
    }
}


