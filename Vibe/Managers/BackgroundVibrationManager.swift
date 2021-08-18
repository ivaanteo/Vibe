//
//  BackgroundVibrationManager.swift
//  Vibe
//
//  Created by Ivan Teo on 24/6/21.
//

import UIKit
import CoreHaptics

class BackgroundVibrationManager{
    // ensure only one instance of singleton is created
    private init() {}
    static let shared = BackgroundVibrationManager()
    
    var vibrationsOwned: [Int]{
        return getVibrationsOwned()
    }
    
    // Vibration Patterns Data
    static let backgroundVibrations = [BackgroundVibrationModel(id: 0,
                                                                title: "Pulsate",
                                                                productID: "-",
                                                                price: 0,
                                                                img: UIImage(systemName: "dot.radiowaves.left.and.right") ?? UIImage(),
//                                                                duration: 0.8),
                                                                duration: 2.4),
                                       BackgroundVibrationModel(id: 1,
                                                                title: "Medium Flat",
                                                                productID: "-",
                                                                price: 0.99,
                                                                img: UIImage(systemName: "waveform.path.ecg")  ?? UIImage(),
                                                                duration: 1.5),
                                       BackgroundVibrationModel(id: 2,
                                                                title: "Intense Flat",
                                                                productID: "com.ivaanteo.Vibe.IntenseFlat",
                                                                price: 0.99,
                                                                img: UIImage(systemName: "waveform")!,
                                                                duration: 1.5),
                                       BackgroundVibrationModel(id: 3,
                                                                title: "Rapids",
                                                                productID: "com.ivaanteo.Vibe.Rapids",
                                                                price: 0.99,
                                                                img: UIImage(systemName: "wave.3.right")!,
                                                                duration: 1.8),
                                       BackgroundVibrationModel(id: 4,
                                                                title: "Calm Waves",
                                                                productID: "com.ivaanteo.Vibe.CalmWaves",
                                                                price: 0.99,
                                                                img: UIImage(systemName: "leaf")!,
//                                                                duration: 0.8),
                                                                duration: 2.4),
                                       BackgroundVibrationModel(id: 5,
                                                                title: "Rocky Beach",
                                                                productID: "com.ivaanteo.Vibe.RockyBeach",
                                                                price: 0.99,
                                                                img: UIImage(systemName: "bolt.horizontal")!,
                                                                duration: 4),
                                       BackgroundVibrationModel(id: 6,
                                                                title: "Surf's Up",
                                                                productID: "com.ivaanteo.Vibe.Surf's Up",
                                                                price: 0.99,
                                                                img: UIImage(systemName: "wind")!,
                                                                duration: 1.5),
                                       BackgroundVibrationModel(id: 7,
                                                                title: "Falls",
                                                                productID: "com.ivaanteo.Vibe.Falls",
                                                                price: 0.99,
                                                                img: UIImage(systemName: "waveform")!,
                                                                duration: 1.5),
                                       
    ]
    
    // Background Choice
    func getBackgroundChoice() -> Int{
        guard let choice = UserDefaults.standard.value(forKey: Constants.backgroundChoice) else {
            UserDefaults.standard.setValue(0, forKey: Constants.backgroundChoice)
            return 0}
        return choice as! Int
    }
    
    func setBackgroundChoice(id: Int){
        UserDefaults.standard.setValue(id, forKey: Constants.backgroundChoice)
    }
    
    // Vibrations Owned
    func getVibrationsOwned() -> [Int]{
        guard let vibrations = UserDefaults.standard.value(forKey: Constants.vibrationsOwned) else {
            let defaultVibrations = [0, 1, 2, 3]
            UserDefaults.standard.setValue(defaultVibrations, forKey: Constants.vibrationsOwned)
            return defaultVibrations
        }
        return vibrations as! [Int]
    }
    
    func updateVibrationsOwned(vibrationId: Int) {
        var updatedVibrationsOwned = vibrationsOwned
        updatedVibrationsOwned.append(vibrationId)
        UserDefaults.standard.setValue(updatedVibrationsOwned, forKey: Constants.vibrationsOwned)
    }
    
    // Vibration Patterns
    func getPattern(id:Int) -> Result<CHHapticPattern, Error>{
        var result: Result<CHHapticPattern, Error>
        switch id {
        case 1:
            result = mediumPattern()
        case 2:
            result = intensePattern()
        case 3:
            result = rapidPattern()
        case 4:
            result = calmWavesPattern()
        case 5:
            result = fancyPattern()
        case 6:
            result = surfPattern()
        case 7:
            result = fallsPattern()
        default:
            result = defaultPattern()
        }
        return result
    }
    
    
    // ID = 7, falls
    // increasing, sprinkles at the end
    func fallsPattern() -> Result<CHHapticPattern, Error>{
        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()
        
        // create one continuous buzz that fades out
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
        let highSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.4)
        let peak = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 2, value: 1)
        
        
        let intensityPC = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, peak, end], relativeTime: 0)
        
        for i in 0...8{
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [highSharpness, intensity], relativeTime: 0.9+Double(i)*0.12, duration: 0.1)
            events.append(event)
        }
        let backgroundEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 1.5)
        events.append(backgroundEvent)
        curves.append(intensityPC)
        do{
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
    
    // ID = 6, surf's up
    // constant bg, sprinkles
    func surfPattern() -> Result<CHHapticPattern, Error>{
        var events = [CHHapticEvent]()

        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
                                            parameters: [intensity, sharpness],
                                            relativeTime: 0,
                                            duration: 1.5)
        events.append(continuousEvent)
        for i in 0...4 {
            // make some sparkles
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
//            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: TimeInterval.random(in: 0.1...1.5))
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: Double(i) * 0.3, duration: 0.25)
            events.append(event)
        }
        
        
        
        do{
            let pattern = try CHHapticPattern(events: events, parameters: [])
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
    
    
    
    // ID = 5, Rocky
    func fancyPattern() -> Result<CHHapticPattern, Error>{
//        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()
        
        // create one continuous buzz that fades out
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
        let highSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
//        let highIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.5)
        let peak = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 2, value: 0.5)
        let mid2 = CHHapticParameterCurve.ControlPoint(relativeTime: 3, value: 1)
        let end2 = CHHapticParameterCurve.ControlPoint(relativeTime: 4, value: 0.5)
        
//        let intensityPC = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, peak, mid, end], relativeTime: 0)
        let intensityPC = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, peak, end, mid2, end2], relativeTime: 0)
        let backgroundEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 4)
        let transientEvent1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [highSharpness, intensity], relativeTime: 0.7, duration: 0.5)
        let transientEvent2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [highSharpness, intensity], relativeTime: 1.3, duration: 0.5)
        let transientEvent3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [highSharpness, intensity], relativeTime: 2.7, duration: 0.5)
        let transientEvent4 = CHHapticEvent(eventType: .hapticContinuous, parameters: [highSharpness, intensity], relativeTime: 3.3, duration: 0.5)
        let events = [backgroundEvent, transientEvent1, transientEvent2, transientEvent3, transientEvent4]
        curves.append(intensityPC)
        do{
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
    
    // ID = 4, Waves
    func calmWavesPattern() -> Result<CHHapticPattern, Error>{
        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()
        
        // create one continuous buzz that fades out
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.4)
        let peak = CHHapticParameterCurve.ControlPoint(relativeTime: 0.3, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 0.8, value: 0.4)
        let peak1 = CHHapticParameterCurve.ControlPoint(relativeTime: 1.1, value: 1)
        let end1 = CHHapticParameterCurve.ControlPoint(relativeTime: 1.6, value: 0.4)
        let peak2 = CHHapticParameterCurve.ControlPoint(relativeTime: 1.9, value: 1)
        let end2 = CHHapticParameterCurve.ControlPoint(relativeTime: 2.4, value: 0.4)
        
        let intensityPC = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, peak, end, peak1, end1, peak2, end2], relativeTime: 0)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 2.4)
        events.append(event)
        curves.append(intensityPC)
        do{
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
    
    // ID = 3, White Water Rapids
    func rapidPattern() -> Result<CHHapticPattern, Error>{
//        var events = [CHHapticEvent]()
        let curves = [CHHapticParameterCurve]()
        
        // create one continuous buzz that fades out
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
//        let highIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
//        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
//        let peak = CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 1)
//        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 0.51, value: 0)
        
//        let intensityPC = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, peak, end], relativeTime: 0)
        
        
        let backgroundEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 0.5)
        let backgroundEvent1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0.6, duration: 0.5)
        let backgroundEvent2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 1.2, duration: 0.5)
        let events = [backgroundEvent, backgroundEvent1, backgroundEvent2]
//        curves.append(intensityPC)
        do{
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
    
    // ID = 2, Strong Flat
    func intensePattern() -> Result<CHHapticPattern, Error>{
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
                                            parameters: [intensity, sharpness],
                                            relativeTime: 0,
                                            duration: 1.5)
        do{
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
    
    
    // ID = 1, Flat vibration
    func mediumPattern() -> Result<CHHapticPattern, Error>{
        // create one continuous buzz that fades out
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
                                            parameters: [intensity, sharpness],
                                            relativeTime: 0,
                                            duration: 1.5)
        do{
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
    
    // ID = 0, Pulsate
    func defaultPattern() -> Result<CHHapticPattern, Error>{
        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()
        
        // create one continuous buzz that fades out
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
        let mid = CHHapticParameterCurve.ControlPoint(relativeTime: 0.4, value: 0.6)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 0.8, value: 0.4)
        let start1 = CHHapticParameterCurve.ControlPoint(relativeTime: 0.81, value: 1)
        let mid1 = CHHapticParameterCurve.ControlPoint(relativeTime: 1.2, value: 0.6)
        let end1 = CHHapticParameterCurve.ControlPoint(relativeTime: 1.6, value: 0.4)
        let start2 = CHHapticParameterCurve.ControlPoint(relativeTime: 1.61, value: 1)
        let mid2 = CHHapticParameterCurve.ControlPoint(relativeTime: 2.0, value: 0.6)
        let end2 = CHHapticParameterCurve.ControlPoint(relativeTime: 2.4, value: 0.4)
        
        let parameter = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, mid, end, start1, mid1, end1, start2, mid2, end2], relativeTime: 0)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 2.4)
        events.append(event)
        curves.append(parameter)
        
        do{
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            return .success(pattern)
        }catch let error{
            print("error creating pattern: ", error)
            return .failure(error)
        }
    }
}

//protocol BackgroundVibrationManagerDelegate: AnyObject{
//    func updateBackgroundVibration(sender: TouchViewController)
//}
