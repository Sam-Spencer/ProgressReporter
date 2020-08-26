//
//  ProgressReporter.swift
//  LessonNote
//
//  Created by Sam Spencer on 3/2/20.
//  Copyright © 2020 LSAlliance. All rights reserved.
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, 
//  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following 
//  conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
// 

import Foundation
import Combine

/// A mutable representation of tangible progress
/// 
/// Does not discern between continuous or discrete progress.
/// Create this in a `ProgressReporter` and use a `ProgressWatcher`
/// for monitoring.
///
public struct TangibleProgress {
    
    public init(completed: Int, total: Int) {
        self.completed = completed
        self.total = total
    }
    
    /// Representation of progress towards completion.
    public var completed: Int
    
    /// Representation of total expected progress until completion.
    public var total: Int {
        didSet {
            if total < completed {
                total = completed
            }
        }
    }
    
    /// Current percent towards completion from 0.0 to 1.0
    public var progress: Float {
        get {
            let complete = Float(completed)
            let totes = Float(total)
            return complete / totes
        }
    }
    
}


/// Objects which coordinate progress on long-running tasks should
/// adopt this protocol.
///
/// - note: Adopting this protocol yourself is likely unnecessary.
///   Instead, use the `ProgressWatcher` object.
/// 
@available(iOS 13.0, *)
public protocol ProgressCensus: ObservableObject {
    func reportProgress(for steps: Int)
    func addStepsToProgress(additionalSteps: Int)
    func resetProgress()
}


/// A Progress Reporter is responsible for recieving updates
/// from a Progress Census and deciding how to proceed with the
/// given information (i.e. updating a UI).
public protocol ProgressWatcher {
    func hasProgressToReport(report: TangibleProgress)
}


/// Coordinates input from multiple objects on the progress of a single task.
/// 
/// Only one task may be active at any given time. The benefit, however,
///  is that multiple objects may access this same Census and provide updates
///  asynchronously.
/// 
/// If you need multiple different tasks reporting different progress values, 
/// you should either: 
///   - Conform to the `ProgressCensus` protocol in your own custom object.  
///   - Subclass this class to take advantage of multiple *shared* Census coordinators.
///   - Avoid use of the `shared` property and instead initialize in a traditional manner,
///     thus maintaining your own references and ensuring multiple instances of 
///     `ProgressWatcher` can be generated at once.
/// 
@available(iOS 13.0, *)
open class ProgressCoordinator: ProgressCensus {
    
    public static let shared = ProgressCoordinator()
    public var watcher: ProgressWatcher?
    
    /// A rough estimate of the amount of time (seconds) it will take for a single 
    /// increment of progress when reported via `reportProgress(...)`
    ///
    /// This value should be coordinated with the `anticipatedIncrementBatchSize`.
    /// `ProgressCoordinator` uses this in concert with the batch size to provide time estimates.
    public var anticipatedTimeForIncrement: TimeInterval = 0.5
    
    /// An estimated batch size used to calculate an estimate of remaining time.
    /// The default value is 1, meaning the batch size corresponds to one increment
    /// of progress.
    /// 
    /// This is useful if you perform concurrent, asynchronous operations. For example,
    /// if you use an `OperationQueue` to run multiple operations, you should specify
    /// your expected maximum concurrent operation size.
    /// 
    /// Remember that the maximum concurrency sizes for an `OperationQueue` are much larger
    /// in the iOS / iPadOS Simulator than they are on an actual device. Test this on-device
    /// for the most accurate results.
    public var anticipatedIncrementBatchSize: Int = 1
    
    @Published public var timeRemaining: TimeInterval = 0.0
    @Published public var rawProgress: Float = 0.0
    public var progress: TangibleProgress {
        get {
            return TangibleProgress(completed: completedSteps, total: totalSteps)
        }
    }
    
    private var completedSteps = 0
    private var totalSteps = 1 {
        didSet {
            if totalSteps < 1 {
                totalSteps = 1
            }
        }
    }
    
    public init() {
        completedSteps = 0
        totalSteps = 1
    }
    
    public func reportProgress(for steps: Int = 1) {
        completedSteps = completedSteps + steps
        updateReporterSafely()
        estimateTimeRemaining()
    }
    
    public func addStepsToProgress(additionalSteps: Int = 1) {
        totalSteps = totalSteps + additionalSteps
        updateReporterSafely()
        estimateTimeRemaining()
    }
    
    public func resetProgress() {
        completedSteps = 0
        totalSteps = 1
        updateReporterSafely()
        estimateTimeRemaining()
    }
    
    @discardableResult
    public func estimateTimeRemaining() -> TimeInterval {
        let batch = Double(anticipatedIncrementBatchSize)
        let count = Double(totalSteps)
        let increment = anticipatedTimeForIncrement
        
        let batches = count / batch
        let totalDuration = increment * batches
        let remainingProgress = 1.0 - Double(progress.progress)
        
        let remainingDuration = totalDuration * remainingProgress
        Thread.executeOnMainThread {
            self.timeRemaining = TimeInterval(exactly: remainingDuration) ?? 0
        }
        return remainingDuration
    }
    
    private func updateReporterSafely() {
        if Thread.isMainThread {
            watcher?.hasProgressToReport(report: progress)
            rawProgress = progress.progress
        } else {
            DispatchQueue.main.async {
                self.watcher?.hasProgressToReport(report: self.progress)
                self.rawProgress = self.progress.progress
            }
        }
    }
    
}

extension Thread {
    
    class func executeOnMainThread(task: @escaping (Void) -> Void) {
        if Thread.isMainThread {
            task()
        } else {
            DispatchQueue.main.async {
                task()
            }
        }
    }
    
}
