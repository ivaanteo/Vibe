////
////  ViewController.swift
////  Vibe
////
////  Created by Ivan Teo on 18/6/21.
////
//
//import UIKit
//import AVFoundation
//import SwiftUI
//import CoreHaptics
//
//class ViewController: UIViewController {
//    private var engine: CHHapticEngine!
//    private var continuousPlayer: CHHapticAdvancedPatternPlayer!
//    private var engineNeedsStart = true
//    
//    // check if supports haptics. this way, we can force unwrap engine and player.
//    // they are only called if supportsHaptics==true
//    private lazy var supportsHaptics: Bool = {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.supportsHaptics
//    }()
//    
//    // Views
//    private var touchPadView: UIView!
//    private var touchCursorView: UIView!
//    
//    // Track the screen dimensions:
//    private lazy var windowWidth: CGFloat = {
//        return UIScreen.main.bounds.width
//    }()
//    
//    private lazy var windowHeight: CGFloat = {
//        return UIScreen.main.bounds.height
//    }()
//    
//    // Constants
//    private let margin: CGFloat = 16
//    private let labelHeight: CGFloat = 24
//    private let initialIntensity: Float = 1.0
//    private let initialSharpness: Float = 0.5
//    private let touchIndicatorSize: CGFloat = 50
//    
//    // Tokens to track whether app is in the foreground or the background:
//    // to start and stop engine as required
//    private var foregroundToken: NSObjectProtocol?
//    private var backgroundToken: NSObjectProtocol?
//    
//    private lazy var touchPadWidth: CGFloat = {
//        let width = windowWidth - 2 * margin
//        return width
//    }()
//    
//    private lazy var touchPadHeight: CGFloat = {
//        let height = windowHeight - 80 - 4 * labelHeight - 2 * margin
//        return height
//    }()
//    
//    @objc func longPressView(){
////        HapticsManager.shared.vibrate(for: .success)
////        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
////        complexSuccess()
//        
//        // Normalize coordinates to a [0, 1] spectrum.
//        let normalizedLocation = normalizeCoordinates(clippedLocation, toView: view)
//        
//        // The intensity should be highest at the top, opposite of the iOS y-axis direction, so subtract.
//        let eventIntensity: Float = 1 - Float(normalizedLocation.y)
//
//        // The sharpness spectrum is 0 to 1. Map the x-coordinate to that range.
//        let eventSharpness: Float = Float(normalizedLocation.x)
//        
//        // Create dynamic parameters for the updated intensity & sharpness.
//        let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
//                                                          value: eventIntensity,
//                                                          relativeTime: 0)
//
//        let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl,
//                                                          value: eventSharpness,
//                                                          relativeTime: 0)
//
//        // Send dynamic parameters to the haptic player.
//        do {
//            try continuousPlayer?.sendParameters([intensityParameter, sharpnessParameter],
//                                                atTime: 0)
//        } catch let error {
//            print("Dynamic Parameter Error: \(error)")
//        }
//        
////        vibrate()
//    }
//    
//    @objc
//    private func continuousPalettePressed(_ press: UILongPressGestureRecognizer) {
//        
//        let location = press.location(in: touchPadView)
//        
//        // Clip location to the minimum and maximum values, then normalize to [0,1].
//        let clippedLocation = clipLocation(location, toView: touchPadView)
//        let normalizedLocation = normalizeCoordinates(clippedLocation, toView: touchPadView)
//        
//        // The intensity should be highest at the top, opposite of the iOS y-axis direction, so subtract.
//        let dynamicIntensity: Float = 1 - Float(normalizedLocation.y)
//        
//        // Dynamic parameters range from -0.5 to 0.5 to map the final sharpness to the [0,1] range.
//        let dynamicSharpness: Float = Float(normalizedLocation.x) - 0.5
//        
//        // Move the continuous touch indicator to the touch's location.
//        touchCursorView.center = clippedLocation
//        
//        // The perceived intensity value multiplies the original event parameter intensity by the dynamic parameter's value.
//        let perceivedIntensity = initialIntensity * dynamicIntensity
//        
//        // The perceived sharpness value adds the dynamic parameter to the original pattern's event parameter sharpness.
//        let perceivedSharpness = initialSharpness + dynamicSharpness
//        
//        // Update the labels to show the latest intensity and sharpness values.
////        updateText(label: continuousValueLabel,
////                   sharpness: perceivedSharpness,
////                   intensity: perceivedIntensity)
//        
//        if supportsHaptics {
//            // Create dynamic parameters for the updated intensity & sharpness.
//            let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
//                                                              value: dynamicIntensity,
//                                                              relativeTime: 0)
//            
//            let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl,
//                                                              value: dynamicSharpness,
//                                                              relativeTime: 0)
//            
//            // Send dynamic parameters to the haptic player.
//            do {
//                try continuousPlayer.sendParameters([intensityParameter, sharpnessParameter],
//                                                    atTime: 0)
//            } catch let error {
//                print("Dynamic Parameter Error: \(error)")
//            }
//        }
//        
//        switch press.state {
//        case .began:
//        
//            // Highlight the touch point by enlargening and boldening indicator.
//            self.touchCursorView.alpha = 1
//            
//            // Proceed if and only if the device supports haptics.
//            if supportsHaptics {
//                
//                // Warm engine.
//                do {
//                    // Begin playing continuous pattern.
//                    try continuousPlayer.start(atTime: CHHapticTimeImmediate)
//                } catch let error {
//                    print("Error starting the continuous haptic player: \(error)")
//                }
//                
//                // Darken the background.
//                self.touchPadView.backgroundColor = .blue
//            }
//            
//        case .ended, .cancelled:
//            
//            if supportsHaptics {
//                // Stop playing the haptic pattern.
//                do {
//                    try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
//                } catch let error {
//                    print("Error stopping the continuous haptic player: \(error)")
//                }
//                
//                // The background color returns to normal in the player's completion handler.
//            }
//            
//        default: break // Do nothing.
//        }
//    }
//    
//    func prepareHaptics() {
//        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        do {
//            self.engine = try CHHapticEngine()
//            try engine?.start()
//        } catch {
//            print("There was an error creating the engine: \(error.localizedDescription)")
//        }
//    }
//    
//    func complexSuccess() {
//        // make sure that the device supports haptics
//        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        var events = [CHHapticEvent]()
//
//        // create one intense, sharp tap
//        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
//        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
//        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
//        events.append(event)
//
//        // convert those events into a pattern and play it immediately
//        do {
//            let pattern = try CHHapticPattern(events: events, parameters: [])
//            let player = try engine?.makeAdvancedPlayer(with: pattern)
////            let player = try engine?.makePlayer(with: pattern)
//            try player?.start(atTime: 0)
//            
////            engine.start(completionHandler:nil)
////            try player.start(atTime: 0)
////            engine.stop(completionHandler: nil)
//        } catch {
//            print("Failed to play pattern: \(error.localizedDescription).")
//        }
//    }
//    
//    func vibrate(){
//        let hapticDict = [
//            CHHapticPattern.Key.pattern: [
//                [CHHapticPattern.Key.event: [CHHapticPattern.Key.eventType: CHHapticEvent.EventType.hapticTransient,
//                      CHHapticPattern.Key.time: 0.001,
//                      CHHapticPattern.Key.eventDuration: 1.0] // End of first event
//                ] // End of first dictionary entry in the array
//            ] // End of array
//        ] // End of haptic dictionary
//        
//        do{
//            let pattern = try CHHapticPattern(dictionary: hapticDict)
//            let player = try engine?.makeAdvancedPlayer(with: pattern)
//            try player?.start(atTime: 0)
//        }catch{
//            print("Failed to play pattern: \(error.localizedDescription)")
//        }
//    }
//    
//    func configureVibration(){
//        let initialIntensity:Float = 0.5
//        let initialSharpness:Float = 0.5
//        
//        // Create an intensity parameter:
//        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
//                                               value: initialIntensity)
//
//        // Create a sharpness parameter:
//        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
//                                               value: initialSharpness)
//
//        // Create a continuous event with a long duration from the parameters.
//        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
//                                            parameters: [intensity, sharpness],
//                                            relativeTime: 0,
//                                            duration: 100)
//
//        do {
//            // Create a pattern from the continuous haptic event.
//            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
//            
//            // Create a player from the continuous haptic pattern.
//            continuousPlayer = try engine?.makeAdvancedPlayer(with: pattern)
//            
//        } catch let error {
//            print("Pattern Player Creation Error: \(error)")
//        }
//
//        
//        
////        continuousPlayer?.completionHandler = { _ in
////            DispatchQueue.main.async {
////                // Restore original color.
////                self.continuousPalette.backgroundColor = self.padColor
////            }
////        }
//
//    }
//    
//    // Build View
//    
//    func layoutTouchPadView() {
//        
//        let xPalette = (windowWidth - paletteSize) / 2.0
//        let yTop = windowHeight / 2 - margin - labelHeight - paletteSize
//        let yBottom = windowHeight / 2 + labelHeight + margin
//        
//        let continuousFrame = CGRect(x: xPalette, y: yTop, width: paletteSize, height: paletteSize)
//        let transientFrame = CGRect(x: xPalette, y: yBottom, width: paletteSize, height: paletteSize)
//        
//        transientPalette = UIView(frame: transientFrame)
//        continuousPalette = UIView(frame: continuousFrame)
//        
//        formatPalette(transientPalette)
//        formatPalette(continuousPalette)
//        
//        self.view.addSubview(transientPalette)
//        self.view.addSubview(continuousPalette)
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        view.backgroundColor = .red
//        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressView)))
//        prepareHaptics()
//        configureVibration()
//    }
//
//    // --- HELPER FUNCTIONS ---
//    
//    // Helper function to change the background color briefly to indicate the transient timer fired.
////    private func flashBackground(in viewToFlash: UIView) {
////
////        viewToFlash.backgroundColor = self.flashColor
////
////        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30), execute: {
////
////            viewToFlash.backgroundColor = self.padColor
////        })
////    }
//    
//    // Helper function to compute the sharpness and intensity at a specified point inside a pad.
//    private func sharpnessAndIntensityAt(location: CGPoint, in view: UIView) -> (Float, Float) {
//        
//        // Clip location to the minimum and maximum values.
//        let clippedLocation = clipLocation(location, toView: view)
//        
//        // Normalize coordinates to a [0, 1] spectrum.
//        let normalizedLocation = normalizeCoordinates(clippedLocation, toView: view)
//        
//        // The intensity should be highest at the top, opposite of the iOS y-axis direction, so subtract.
//        let eventIntensity: Float = 1 - Float(normalizedLocation.y)
//        
//        // The sharpness spectrum is 0 to 1. Map the x-coordinate to that range.
//        let eventSharpness: Float = Float(normalizedLocation.x)
//        
//        return (eventSharpness, eventIntensity)
//    }
//    
//    // Helper function to clip a touch location to the bounds of a palette view:
//    private func clipLocation(_ point: CGPoint, toView clipView: UIView) -> CGPoint {
//        
//        var clippedLocation = point
//        
//        if point.x < 0 {
//            clippedLocation.x = 0
//        } else if point.x > clipView.bounds.width {
//            clippedLocation.x = clipView.bounds.width
//        }
//        
//        if point.y < 0 {
//            clippedLocation.y = 0
//        } else if point.y > clipView.bounds.height {
//            clippedLocation.y = clipView.bounds.height
//        }
//        
//        return clippedLocation
//    }
//    
//    /// - Tag: NormalizeCoordinates
//    // Helper function to normalize a touch location within a palette view:
//    private func normalizeCoordinates(_ point: CGPoint, toView paletteView: UIView) -> CGPoint {
//        
//        let width = paletteView.bounds.width
//        let height = paletteView.bounds.height
//        
//        return CGPoint(x: point.x / width,
//                       y: point.y / height)
//    }
//    
//    // Helper function to update a label as the user's touch moves across a palette:
////    private func updateText(label: UILabel, sharpness: Float, intensity: Float) {
////        label.text = String(format: "Sharpness %.2f, Intensity %.2f", sharpness, intensity)
////    }
//}
//
