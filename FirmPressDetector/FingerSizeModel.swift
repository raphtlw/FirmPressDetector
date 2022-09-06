//
//  FingerSizeModel.swift
//  FirmPressDetector
//
//  Created by Raphael Tang on 6/9/22.
//

import Foundation

class FingerSizeModel {
    /// A constant for the "default" finger size
    private let initialSize = 20.0
    
    /// A history of normal taps (not firm presses)
    private var tapHistory = [Float]()
    
    /// The current normal finger tap radius (not firm press)
    var currentSize: Double {
        get {
            if tapHistory.isEmpty {
                return initialSize
            } else {
                return Double(tapHistory.reduce(0, +)) / Double(tapHistory.count)
            }
        }
    }
    
    func addFingerSize(_ size: Float) {
        tapHistory.append(size)
        if tapHistory.count >= 20 {
            tapHistory.removeFirst()
        }
    }
    
    func isFirmPress(size: Float) -> Bool {
        return size > Float(currentSize)
    }
}
