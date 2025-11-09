import Speech
import AVFoundation

/// Service for handling speech recognition and audio processing
@Observable
final class SpeechService {
    var isRecording = false
    var transcription = ""
    var errorMessage: String?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    
    /// Request necessary permissions for speech and microphone
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self.errorMessage = "Speech recognition not authorized"
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    self.errorMessage = "Microphone access not granted"
                }
            }
        }
    }
    
    /// Start recording audio and transcribing speech
    func startRecording() {
        errorMessage = nil
        transcription = ""
        
        speechRecognizer = SFSpeechRecognizer()
        audioEngine = AVAudioEngine()
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition not available"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine!.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcription = result.bestTranscription.formattedString
                }
            }
            if error != nil {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine!.prepare()
        do {
            try audioEngine!.start()
            isRecording = true
        } catch {
            errorMessage = "Could not start audio engine"
        }
    }
    
    /// Stop recording and finish audio processing
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
    }
    
    /// Clean up resources
    func cleanup() {
        stopRecording()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine = nil
        speechRecognizer = nil
    }
}
