//
//  TouchDetector.swift
//  FirmPressDetector
//
//  Created by Raphael Tang on 31/8/22.
//

import SwiftUI

class TouchDetectingData {
    static var shared = TouchDetectingData()
    
    private var onUpdateCallbacks = [TouchDetectingUIView.OnUpdateCallback]()
    
    func addOnUpdateCallback(_ callback: @escaping TouchDetectingUIView.OnUpdateCallback) {
        onUpdateCallbacks.append(callback)
    }
    func notifyHandlers(_ position: CGPoint, _ radius: CGFloat) {
        onUpdateCallbacks.forEach { callback in
            callback(position, radius)
        }
    }
}

class TouchDetectingUIView: UIView {
    typealias OnUpdateCallback = (CGPoint, CGFloat) -> Void
    
    var onUpdate: OnUpdateCallback?
    var touchTypes: TouchDetectorView.TouchType = .all
    var limitToBounds = true

    // Our main initializer, making sure interaction is enabled.
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }

    // Just in case you're using storyboards!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
    }

    // Triggered when a touch starts.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let radius = touch.majorRadius
        send(location, radius, forEvent: .started)
    }

    // Triggered when an existing touch moves.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let radius = touch.majorRadius
        send(location, radius, forEvent: .moved)
    }

    // Triggered when the user lifts a finger.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let radius = touch.majorRadius
        send(location, radius, forEvent: .ended)
    }

    // Triggered when the user's touch is interrupted, e.g. by a low battery alert.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let radius = touch.majorRadius
        send(location, radius, forEvent: .ended)
    }

    // Send a touch location only if the user asked for it
    func send(_ location: CGPoint, _ radius: CGFloat, forEvent event: TouchDetectorView.TouchType) {
        guard touchTypes.contains(event) else {
            return
        }

        if limitToBounds == false || bounds.contains(location) {
            onUpdate?(CGPoint(x: round(location.x), y: round(location.y)), radius)
        }
    }
}

struct TouchDetectorView: UIViewRepresentable {
    // The types of touches users want to be notified about
    struct TouchType: OptionSet {
        let rawValue: Int

        static let started = TouchType(rawValue: 1 << 0)
        static let moved = TouchType(rawValue: 1 << 1)
        static let ended = TouchType(rawValue: 1 << 2)
        static let all: TouchType = [.started, .moved, .ended]
    }

    // A closure to call when touch data has arrived
    var onUpdate: TouchDetectingUIView.OnUpdateCallback

    // The list of touch types to be notified of
    var types = TouchType.all

    // Whether touch information should continue after the user's finger has left the view
    var limitToBounds = true

    func makeUIView(context: Context) -> TouchDetectingUIView {
        // Create the underlying UIView, passing in our configuration
        let view = TouchDetectingUIView()
        TouchDetectingData.shared.addOnUpdateCallback(onUpdate)
        view.onUpdate = TouchDetectingData.shared.notifyHandlers
        view.touchTypes = types
        view.limitToBounds = limitToBounds
        return view
    }

    func updateUIView(_ uiView: TouchDetectingUIView, context: Context) {
    }
}

// A custom SwiftUI view modifier that overlays a view with our UIView subclass.
struct TouchDetector: ViewModifier {
    var type: TouchDetectorView.TouchType = .all
    var limitToBounds = true
    let perform: TouchDetectingUIView.OnUpdateCallback

    func body(content: Content) -> some View {
        content
            .overlay(
                TouchDetectorView(onUpdate: perform, types: type, limitToBounds: limitToBounds)
            )
    }
}

// A new method on View that makes it easier to apply our touch detector view.
extension View {
    func onTouch(type: TouchDetectorView.TouchType = .all, limitToBounds: Bool = true, perform: @escaping TouchDetectingUIView.OnUpdateCallback) -> some View {
        self.modifier(TouchDetector(type: type, limitToBounds: limitToBounds, perform: perform))
    }
}
