//
//  TouchViewController.swift
//  Vibe
//
//  Created by Ivan Teo on 18/6/21.
//

import UIKit

import CoreHaptics

class TouchViewController: UIViewController {
    
    // Touch Palettes:
    //@IBOutlet weak var transientPalette: UIView?
    //@IBOutlet weak var continuousPalette: UIView?
    
    // Views to represent 2D sliders.
//    private var transientPalette: UIView!
    private var continuousPalette: UIView!
    
    // Views to show where the user last touched.
//    private var transientTouchView: UIView!
    private var continuousTouchView: PulsatingView!
    
    // button
    private var playBackgroundButton: UIButton!
    private var backgroundPlaying = false
    
    private var shopButton: UIButton!
    
    // Haptic Engine & Player State:
    private var engine: CHHapticEngine!
    private var engineNeedsStart = true
    private var continuousPlayer: CHHapticAdvancedPatternPlayer!
    private var backgroundPlayer: CHHapticAdvancedPatternPlayer!
//    private var backgroundPlayer: CHHapticPatternPlayer!
    
    private lazy var supportsHaptics: Bool = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.supportsHaptics
    }()
    
    // Track the screen dimensions:
    private lazy var windowWidth: CGFloat = {
        return UIScreen.main.bounds.size.width
    }()
    
    private lazy var windowHeight: CGFloat = {
        return UIScreen.main.bounds.size.height
    }()
    
    // Constants
    private let margin: CGFloat = 24
    private let labelHeight: CGFloat = 24
    private let initialIntensity: Float = 1.0
    private let initialSharpness: Float = 0.5
    private let touchIndicatorSize: CGFloat = 50
    
    // Constant colors consistent across UI:
    private let padColor: UIColor = .systemGray3
    private let flashColor: UIColor = .systemGray2
    
    // Tokens to track whether app is in the foreground or the background:
    private var foregroundToken: NSObjectProtocol?
    private var backgroundToken: NSObjectProtocol?
    
    // Timer to handle transient haptic playback:
    private var transientTimer: DispatchSourceTimer?
    
//    private lazy var paletteSize: CGFloat = {
//        let totalWidth = windowWidth - 2 * margin
//        let totalHeight = windowHeight - 80 - 4 * labelHeight - 2 * margin
//        return min(totalWidth, totalHeight / 2)
//    }()
    
    
    private lazy var paletteHeight: CGFloat = {
        let totalHeight = windowHeight - 2 * margin
        return totalHeight
    }()
    private lazy var paletteWidth: CGFloat = {
        let totalWidth = windowWidth - 2 * margin
        return totalWidth
    }()
    
    private lazy var buttonheight: CGFloat = { return margin * 2 }()
    
    override func viewWillAppear(_ animated: Bool) {
        print("vwa")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureGradientBackground()
        
        
        
//        let pulse = PulsatingView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        pulse.center = self.view.center
//        view.addSubview(pulse)
//        pulse.pulse()
        
        
        
        layoutPaletteViews()
        layoutTouchIndicators()
        layoutButton()
        layoutShopButton()
        addGestureRecognizers()
        

        // check the previous vibration choice of user
        // Create & configure the engine before doing anything else, since the user may touch a pad immediately.
        if supportsHaptics {
            createAndStartHapticEngine()
            createContinuousHapticPlayer()
        }else{
            presentAlert(title: "Oh no!", desc: "Your device does not support haptics. Please update your iOS version to enjoy our app!")
        }
        
        
        backgroundVibrationChanged()
        
        addObservers()
    }
    
    /// - Tag: CreateAndStartEngine
    func createAndStartHapticEngine() {
        
        // Create and configure a haptic engine.
        do {
            engine = try CHHapticEngine()
        } catch let error {
//            fatalError("Engine Creation Error: \(error)")
            presentAlert(title: "Error creating engine", desc: error.localizedDescription)
            return
        }
        
        // Mute audio to reduce latency for collision haptics.
        engine.playsHapticsOnly = true
        
        // The stopped handler alerts you of engine stoppage.
        engine.stoppedHandler = { reason in
            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt")
            case .applicationSuspended:
                print("Application suspended")
            case .idleTimeout:
                print("Idle timeout")
            case .systemError:
                print("System error")
            case .notifyWhenFinished:
                print("Playback finished")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            case .engineDestroyed:
                print("Engine destroyed.")
            @unknown default:
                print("Unknown error")
            }
        }
        
        // The reset handler provides an opportunity to restart the engine.
        engine.resetHandler = {
            
            print("Reset Handler: Restarting the engine.")
            
            do {
                // Try restarting the engine.
                try self.engine.start()
                
                // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
                self.engineNeedsStart = false
                
                // Recreate the continuous player.
                self.createContinuousHapticPlayer()
                
            } catch {
                print("Failed to start the engine")
            }
        }
        
        // Start the haptic engine for the first time.
        do {
            try self.engine.start()
        } catch {
            print("Failed to start the engine: \(error)")
        }
    }
    
    /// - Tag: CreateContinuousPattern
    func createContinuousHapticPlayer() {
        // Create an intensity parameter:
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
                                               value: initialIntensity)
        
        // Create a sharpness parameter:
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
                                               value: initialSharpness)
        
        // Create a continuous event with a long duration from the parameters.
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
                                            parameters: [intensity, sharpness],
                                            relativeTime: 0,
                                            duration: 100)
        
        do {
            // Create a pattern from the continuous haptic event.
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            
            // Create a player from the continuous haptic pattern.
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            
        } catch let error {
            presentAlert(title: "Pattern Player Creation Erro", desc: error.localizedDescription)
        }
        
        // MARK: - Reset
        
        continuousPlayer.completionHandler = { _ in
            DispatchQueue.main.async {
                
                // Restore original color.
//                self.continuousPalette.backgroundColor = self.padColor
                self.continuousPalette.backgroundColor = .init(white: 1, alpha: 0.5)
//                self.continuousTouchView.stopPulse()
                self.continuousTouchView.pulse()
//                self.continuousTouchView.center = CGPoint(x: self.paletteWidth/2, y: self.paletteHeight/2)
                self.continuousTouchView.pulseLayer.transform = CATransform3DMakeScale(2, 2, 1)
                self.continuousTouchView.backgroundLayer.transform = CATransform3DMakeScale(1, 1, 1)
            }
        }
    }
    
    func createPlayer(pattern: CHHapticPattern, duration: TimeInterval, loop: Bool = true){
        do {
//            backgroundPlayer = try engine?.makePlayer(with: pattern)
            if supportsHaptics{
                backgroundPlayer = try engine?.makeAdvancedPlayer(with: pattern)
                if loop{
                    backgroundPlayer.loopEnabled = true
                    backgroundPlayer.loopEnd = duration
                    backgroundPlayer.playbackRate = 1
                }
            }
        } catch {
            presentAlert(title: "Error creating backgorund player", desc: error.localizedDescription)
        }
    }
    
    func layoutButton(){
        playBackgroundButton = UIButton(frame: CGRect(x: paletteWidth * 0.75 + margin, y: windowHeight-3*margin, width: paletteWidth / 4 , height: buttonheight))
//        playBackgroundButton = UIButton(frame: CGRect(x: 0, y: 0, width: paletteWidth / 2 , height: buttonheight))
        playBackgroundButton.backgroundColor = .init(white: 1, alpha: 0.5)
        playBackgroundButton.tintColor = .white
        playBackgroundButton.layer.cornerRadius = buttonheight / 4
        playBackgroundButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        playBackgroundButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        playBackgroundButton.layer.shadowColor = UIColor.black.cgColor
        playBackgroundButton.layer.shadowRadius = 3.5
        playBackgroundButton.layer.shadowOpacity = 0.5
        playBackgroundButton.layer.masksToBounds = false
        
        view.addSubview(playBackgroundButton)
    }
    
    func layoutShopButton(){
        shopButton = UIButton(frame: CGRect(x: margin, y: windowHeight-3*margin, width: paletteWidth * 0.75 - margin, height: buttonheight))
        shopButton.backgroundColor = .init(white: 1, alpha: 0.5)
        shopButton.tintColor = .white
        shopButton.layer.cornerRadius = buttonheight / 4
//        shopButton.setTitle("Background Vibration", for: .normal)
        shopButton.titleLabel?.font = UIFont(name: "Futura", size: 20)
        
        shopButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        shopButton.layer.shadowColor = UIColor.black.cgColor
        shopButton.layer.shadowRadius = 3.5
        shopButton.layer.shadowOpacity = 0.5
        shopButton.layer.masksToBounds = false
        
        view.addSubview(shopButton)
    }
    
    // Layout two palettes and format their appearance.
    func layoutPaletteViews() {
        
        let xPalette = (windowWidth - paletteWidth) / 2.0
        let yTop = margin * 2
//        let yTop = windowHeight / 2 - margin - labelHeight - paletteWidth
//        let yBottom = windowHeight / 2 + labelHeight + margin
        
        let continuousFrame = CGRect(x: xPalette, y: yTop, width: paletteWidth, height: paletteHeight - 2 * yTop)
        
        continuousPalette = UIView(frame: continuousFrame)
        
        formatPalette(continuousPalette)
        
        self.view.addSubview(continuousPalette)
    }
    
    func formatPalette(_ palette: UIView) {
        palette.layer.cornerRadius = 16
//        palette.backgroundColor = padColor
        palette.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        palette.clipsToBounds = true
    }
    
    func layoutTouchIndicators() {
        
        // Start each touch indicator in the middle of the pad.
        let size = touchIndicatorSize
//        let frame = CGRect(x: (paletteWidth - size) / 2.0,
//                           y: (paletteWidth - size) / 2.0,
//                           width: size,
//                           height: size)
        
        let frame = CGRect(x: 0,
                           y: 0,
                           width: size,
                           height: size)
        
        continuousTouchView = PulsatingView(frame: frame)
        formatTouchView(continuousTouchView)
        
        
//        transientPalette.addSubview(transientTouchView)
        continuousPalette.addSubview(continuousTouchView)
    }
    
    // Ensure all touch indicators share the same consistent appearance.
    func formatTouchView(_ touchView: PulsatingView) {
//        touchView.backgroundColor = #colorLiteral(red: 0.9696919322, green: 0.654135406, blue: 0.5897029042, alpha: 1)
        touchView.center = CGPoint(x: paletteWidth/2, y: paletteHeight/2)
//        touchView.layer.cornerRadius = touchView.bounds.width / 2.0
        touchView.pulseLayer.transform = CATransform3DMakeScale(2, 2, 1)
        touchView.pulse()
    }
    
    // MARK: - Vibration Functions
    
    func backgroundVibrationChanged(){
        
        let backgroundChoiceId = BackgroundVibrationManager.shared.getBackgroundChoice()
        let bgVibration = BackgroundVibrationManager.backgroundVibrations[backgroundChoiceId]
        shopButton.setTitle(bgVibration.title, for: .normal)
        
        let result = BackgroundVibrationManager.shared.getPattern(id: bgVibration.id)
        
        if supportsHaptics{
            switch result {
            case .success(let pattern):
                createPlayer(pattern: pattern,
                             duration: bgVibration.duration)
            case .failure(let error):
                presentAlert(title: "Error getting pattern", desc: error.localizedDescription)
            }
        }
    }
    
    fileprivate func animateButton(_ btn: UIButton){
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .beginFromCurrentState, .allowUserInteraction]) {
            btn.backgroundColor = UIColor(named: Constants.Colours.orange)
        }
    }
    
    fileprivate func stopAnimatingButton(_ btn: UIButton){
        btn.layer.removeAllAnimations()
        btn.backgroundColor = .init(white: 1, alpha: 0.5)
    }
    
    private func toggleBackgroundPlayer() {
        backgroundPlaying = !backgroundPlaying
        if supportsHaptics {
            if backgroundPlaying{
                // Warm engine.
                self.playBackgroundButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                
                // start animation
                animateButton(shopButton)
                animateButton(playBackgroundButton)
                
                do {
                    // Begin playing continuous pattern.
                    try backgroundPlayer.start(atTime: CHHapticTimeImmediate)
                    
                } catch let error {
                    print("Error starting the continuous haptic player: \(error)")
                }
            }else{
                // Stop playing the haptic pattern.
                self.playBackgroundButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                
                // stop animation
                stopAnimatingButton(shopButton)
                stopAnimatingButton(playBackgroundButton)
                
                do {
                    try backgroundPlayer.stop(atTime: CHHapticTimeImmediate)
                } catch let error {
                    presentAlert(title: "Error Stopping Player", desc: error.localizedDescription)
                }
            }
            // Darken the background.
            // Do Background Stuff
        }else{
            presentAlert(title: "Oh no!", desc: "Your device does not support haptics. Please update your iOS version to enjoy our app!")
        }
    }
    
    private func addObservers() {
        backgroundToken = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                                 object: nil,
                                                                 queue: nil)
        { _ in
            guard self.supportsHaptics else {
                return
            }
            // Stop the haptic engine.
            self.engine.stop(completionHandler: { error in
                if let error = error {
                    self.presentAlert(title: "Haptic Engine Shutdown Error", desc: error.localizedDescription)
                    return
                }
                self.engineNeedsStart = true
            })
        }
        foregroundToken = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                                 object: nil,
                                                                 queue: nil)
        { _ in
            guard self.supportsHaptics else {
                return
            }
            // Restart the haptic engine.
            self.engine.start(completionHandler: { error in
                if let error = error {
                    self.presentAlert(title: "Haptic Engine Startup Error", desc: error.localizedDescription)
                    return
                }
                self.engineNeedsStart = false
                DispatchQueue.main.async {
                    self.continuousTouchView.pulse()
                }
            })
        }
    }
    
    func addGestureRecognizers() {
        
        let continuousPress = UILongPressGestureRecognizer(target: self, action: #selector(continuousPalettePressed))
        continuousPress.minimumPressDuration = 0
        
        let btnTap = UITapGestureRecognizer(target: self, action: #selector(playBackgroundButtonTapped))
        let shopBtnTap = UITapGestureRecognizer(target: self, action: #selector(shopButtonTapped))
        
//        transientPalette.addGestureRecognizer(transientPress)
        continuousPalette.addGestureRecognizer(continuousPress)
        playBackgroundButton.addGestureRecognizer(btnTap)
        shopButton.addGestureRecognizer(shopBtnTap)
    }
    
    // MARK: - Objc functions
    
    @objc
    private func continuousPalettePressed(_ press: UILongPressGestureRecognizer) {
        
        let location = press.location(in: continuousPalette)
        
        // Clip location to the minimum and maximum values, then normalize to [0,1].
        let clippedLocation = clipLocation(location, toView: continuousPalette)
        let normalizedLocation = normalizeCoordinates(clippedLocation, toView: continuousPalette)
        
        // The intensity should be highest at the top, opposite of the iOS y-axis direction, so subtract.
        let dynamicIntensity: Float = 1 - Float(normalizedLocation.y)
        
        // Dynamic parameters range from -0.5 to 0.5 to map the final sharpness to the [0,1] range.
        let dynamicSharpness: Float = Float(normalizedLocation.x) - 0.5
        
        // Move the continuous touch indicator to the touch's location.
        continuousTouchView.center = clippedLocation
        
        // The perceived intensity value multiplies the original event parameter intensity by the dynamic parameter's value.
        let perceivedIntensity = initialIntensity * dynamicIntensity
        
        // The perceived sharpness value adds the dynamic parameter to the original pattern's event parameter sharpness.
        let perceivedSharpness = initialSharpness + dynamicSharpness
        
        // Update the labels to show the latest intensity and sharpness values.
//        updateText(label: continuousValueLabel,
//                   sharpness: perceivedSharpness,
//                   intensity: perceivedIntensity)
        updateSize(view: continuousTouchView, sharpness: perceivedSharpness, intensity: perceivedIntensity)
        
        if supportsHaptics {
            // Create dynamic parameters for the updated intensity & sharpness.
            let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                              value: dynamicIntensity,
                                                              relativeTime: 0)
            
            let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl,
                                                              value: dynamicSharpness,
                                                              relativeTime: 0)
            
            // Send dynamic parameters to the haptic player.
            do {
                try continuousPlayer.sendParameters([intensityParameter, sharpnessParameter],
                                                    atTime: 0)
            } catch let error {
                print("Dynamic Parameter Error: \(error)")
            }
        }
        
        switch press.state {
        case .began:
        
            // Highlight the touch point by enlargening and boldening indicator.
            self.continuousTouchView.alpha = 1
            
            // Proceed if and only if the device supports haptics.
            if supportsHaptics {
                
                // Warm engine.
                do {
                    // Begin playing continuous pattern.
                    try continuousPlayer.start(atTime: CHHapticTimeImmediate)
                } catch let error {
                    presentAlert(title: "Error starting continuous player", desc: error.localizedDescription)
                }
                
                // Darken the background.
//                self.continuousPalette.backgroundColor = self.flashColor
                self.continuousPalette.backgroundColor = UIColor.init(white: 1, alpha: 0.6)
//                self.continuousTouchView.pulse()
                self.continuousTouchView.stopPulse()
            }
            
        case .ended, .cancelled:
            
            if supportsHaptics {
                // Stop playing the haptic pattern.
                do {
                    try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
                } catch let error {
                    presentAlert(title: "Error stopping continuous player", desc: error.localizedDescription)
                }
                
                // The background color returns to normal in the player's completion handler.
                
            }
            
        default: break // Do nothing.
        }
    }
    
    
    @objc func playBackgroundButtonTapped(_ sender: UIButton){
        toggleBackgroundPlayer()
    }
    
    @objc func shopButtonTapped(_ sender:UIButton){
        let layout = UICollectionViewFlowLayout()
        let shopVC = ShopCollectionViewController(collectionViewLayout: layout)
        shopVC.delegate = self
        present(shopVC, animated: true, completion: nil)
    }
    
    // --- HELPER FUNCTIONS ---
    
    // Helper function to compute the sharpness and intensity at a specified point inside a pad.
    private func sharpnessAndIntensityAt(location: CGPoint, in view: UIView) -> (Float, Float) {
        
        // Clip location to the minimum and maximum values.
        let clippedLocation = clipLocation(location, toView: view)
        
        // Normalize coordinates to a [0, 1] spectrum.
        let normalizedLocation = normalizeCoordinates(clippedLocation, toView: view)
        
        // The intensity should be highest at the top, opposite of the iOS y-axis direction, so subtract.
        let eventIntensity: Float = 1 - Float(normalizedLocation.y)
        
        // The sharpness spectrum is 0 to 1. Map the x-coordinate to that range.
        let eventSharpness: Float = Float(normalizedLocation.x)
        
        return (eventSharpness, eventIntensity)
    }
    
    // Helper function to clip a touch location to the bounds of a palette view:
    private func clipLocation(_ point: CGPoint, toView clipView: UIView) -> CGPoint {
        
        var clippedLocation = point
        
        if point.x < 0 {
            clippedLocation.x = 0
        } else if point.x > clipView.bounds.width {
            clippedLocation.x = clipView.bounds.width
        }
        
        if point.y < 0 {
            clippedLocation.y = 0
        } else if point.y > clipView.bounds.height {
            clippedLocation.y = clipView.bounds.height
        }
        
        return clippedLocation
    }
    
    /// - Tag: NormalizeCoordinates
    // Helper function to normalize a touch location within a palette view:
    private func normalizeCoordinates(_ point: CGPoint, toView paletteView: UIView) -> CGPoint {
        
        let width = paletteView.bounds.width
        let height = paletteView.bounds.height
        
        return CGPoint(x: point.x / width,
                       y: point.y / height)
    }
    
    // Helper function to update a label as the user's touch moves across a palette:
//    private func updateText(label: UILabel, sharpness: Float, intensity: Float) {
//        label.text = String(format: "Sharpness %.2f, Intensity %.2f", sharpness, intensity)
//    }
    private func updateSize(view: PulsatingView, sharpness: Float, intensity: Float){
//        view.pulseLayer.transform = CATransform3DMakeScale(2*CGFloat(sharpness+1), 2*CGFloat(intensity+1), 1)
        let size = 2*CGFloat(intensity+1)
        view.pulseLayer.transform = CATransform3DMakeScale(size, size, 1)
        let bgSize = CGFloat(intensity+1)
        view.backgroundLayer.transform = CATransform3DMakeScale(bgSize, bgSize, 1)
    }
    
    private func presentAlert(title: String, desc: String){
        // create the alert
       let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        // add button
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
   }
    
}

extension TouchViewController:ShopCollectionViewDelegate{
    func didSelectBgVibration(sender: ShopCollectionViewController){
        backgroundVibrationChanged()
    }
    func didDismissVC(sender: ShopCollectionViewController){
        if backgroundPlaying{
            toggleBackgroundPlayer()
            toggleBackgroundPlayer()
        }
    }
    func didTestSample(id: Int) {
        if backgroundPlaying{
            //stop playing
            toggleBackgroundPlayer()
        }
        
        let bgVibration = BackgroundVibrationManager.backgroundVibrations[id]
        let result = BackgroundVibrationManager.shared.getPattern(id: id)
        
        if supportsHaptics{
            switch result {
            case .success(let pattern):
                createPlayer(pattern: pattern,
                             duration: bgVibration.duration,
                             loop: false)
                do{
                    try backgroundPlayer.start(atTime: CHHapticTimeImmediate)
                }catch{
                    presentAlert(title: "Error playing pattern", desc: error.localizedDescription)
                }
            case .failure(let error):
                presentAlert(title: "Error getting pattern", desc: error.localizedDescription)
            }
        }
    }
}
