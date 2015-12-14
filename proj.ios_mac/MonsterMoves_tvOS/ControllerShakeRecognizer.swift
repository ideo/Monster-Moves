//
//  ControllerShakeRecognizer.swift
//  MonsterMove
//
//  Created by Poojan Jhaveri on 12/13/15.
//
//

import Foundation
import GameController

private let epsilonMotion = 1.0

private func near(a: Double, _ b: Double) -> Bool {
    return abs(a - b) < epsilonMotion
}

private let minimumNotableAcceleration = 1.0
private let maximumShakeTime = 1.0
private let numberOfReversals = 7

private enum Direction { case Negative, Positive }

class ControllerShakeRecognizer {
    let shakeHandler: Void -> Void
    
    init(shakeHandler: Void -> Void) {
        self.shakeHandler = shakeHandler
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerConnected:", name: GCControllerDidConnectNotification, object: nil)
        GCController.controllers().forEach(monitorController)
    }
    
    @objc private func controllerConnected(note: NSNotification) {
        monitorController(note.object as! GCController)
    }
    
    private func monitorController(controller: GCController) {
        controller.motion?.valueChangedHandler = controllerMoving
    }
    
    private var lastAcceleration = GCAcceleration()
    
    func passesHighPassFilter(acceleration: GCAcceleration) -> Bool {
        if !near(lastAcceleration.x, acceleration.x) || !near(lastAcceleration.y, acceleration.y) || !near(lastAcceleration.z, acceleration.z) {
            lastAcceleration = acceleration
            return true
        }
        return false
    }
    
    private var lastDirection: Direction?
    private var reversals = 0
    
    func controllerMoving(motion: GCMotion) {
        let thisAcceleration = motion.userAcceleration
        
        guard passesHighPassFilter(thisAcceleration) else {
            return
        }
        
        var thisDirection: Direction?
        
        if thisAcceleration.x > minimumNotableAcceleration {
            thisDirection = .Positive
        }
        
        if thisAcceleration.x < -minimumNotableAcceleration {
            thisDirection = .Negative
        }
        
        guard thisDirection != nil else { return }
        
        scheduleReset()
        
        guard thisDirection != lastDirection else { return }
        
        // We had a direction reversal!
        reversals++
        
        // Exact so we don't trigger it more than once.
        if reversals == numberOfReversals {
            shakeHandler()
        }
    }
    
    weak var resetTimer: NSTimer?
    
    func scheduleReset() {
        resetTimer?.invalidate()
        resetTimer = NSTimer.scheduledTimerWithTimeInterval(maximumShakeTime, target: self, selector: "reset:", userInfo: nil, repeats: false)
    }
    
    @objc private func reset(timer: NSTimer) {
        lastDirection = nil
        reversals = 0
    }
}
