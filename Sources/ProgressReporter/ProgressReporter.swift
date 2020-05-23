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


/// A mutable representation of tangible progress
/// 
/// Does not discern between continuous or discrete progress.
/// Create this in a `ProgressReporter` and use a `ProgressWatcher`
/// for monitoring.
///
public struct TangibleProgress {
    
    internal init(completed: Int, total: Int) {
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
public protocol ProgressCensus {
    func reportProgress()
    func addStepsToProgress(additionalSteps: Int)
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
open class ProgressCoordinator: ProgressCensus {
    
    public static let shared = ProgressCoordinator()
    public var watcher: ProgressWatcher?
    
    public var progress: TangibleProgress {
        get {
            return TangibleProgress.init(completed: completedSteps, total: totalSteps)
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
    
    public func reportProgress() {
        completedSteps = completedSteps + 1
        updateReporterSafely()
    }
    
    public func addStepsToProgress(additionalSteps: Int) {
        totalSteps = totalSteps + additionalSteps
        updateReporterSafely()
    }
    
    private func updateReporterSafely() {
        if Thread.isMainThread {
            watcher?.hasProgressToReport(report: progress)
        } else {
            DispatchQueue.main.async {
                self.watcher?.hasProgressToReport(report: self.progress)
            }
        }
    }
    
}
