<a href="https://github.blog/2020-11-02-commit-your-vote-on-election-day/"><img src="https://i.imgur.com/jI6ihgo.png" width=100%></a>

# ProgressReporter

A highly abstract method to coordinate input from multiple objects on the progress of a single, complex task.

## Why?
There's really not much to it. If your project uses Swift and has complex or long-running tasks, try this out. **Maybe you won't have to reinvent the wheel.** I use it in my own projects for networking operations and Core Data migrations as well as complex data tasks... basically anything the user needs to see a progress bar for.

### But what about `NSProgress`?
`NSProgress` works, and it works well. But, it was written in Objective-C for iOS 7 and uses KVO. And frankly, while it has some neat tricks (direct integration with Core Data for one), it's way overly complicated for what I need. This is simple, to the point, and light.

### @ObservableObject / `Combine` Support
In the latest version of `ProgressReporter` you can setup a `ProgressCoordinator` as an `@ObservedObject` in your SwiftUI view. This will allow you to instantly update any progress indicators you may have created in your view(s) using `.onReceive`. This is yet **another reason to ditch `NSProgress`** in favor of `ProgressReporter`.

The `progress` variable is published to any subscribing views. As a result, you'll be able to create beautiful progress updaters that can display multiple points of data simultaneously (i.e. estimated time remaining, animations, countdowns, bars, etc.).

## Installation
There's only one file. You can drag and drop it into your project and use as needed. Or if you're feeling fancy / lazy / extravagant you can use Swift Package Manager.

## Getting Started
Inline documentation is verbose and helpful, but if you're not sure where to get started, here's a rundown of things:

### Most use-cases
 1. Create a `ProgressCoordinator` and use the `shared` instance in places you need to report progress.
 2. Conform a view or controller to the `ProgressWatcher` protocol and then set the `watcher` object on your Coordinator.
 3. Add as many steps to a `Progress` object as needed using `addStepsToProgress`.  
 4. Each time a "step" completes, call `reportProgress` on your shared instance.
 5. That's it. `hasProgressToReport` will be called on your `ProgressWatcher` each time an update occurs. Check the `progress` value of the `Progress` struct for a float between 0.0 and 1.0. Perfect for a `UIProgressView`!

### SwiftUI implementations
  1. Create a `ProgressCoordinator` using the `shared` instance and declare it as an `ObservableObject` on your view(s).
      ```swift
      @ObservedObject var progressCoordinator = ProgressCoordinator.shared
      ```
  2. Views that display progress information should implement the `.onReceive()` modifier like so:
      ```swift
      .onReceive(progressCoordinator.$rawProgress, perform: { progress in
          // Do what you need to update your views here. For example,
          // progressValue could be an @State object bound to some other view.
          self.progressValue = progress
      })
      ```
  3. Add as many steps to a `Progress` object as needed using `addStepsToProgress`.  
  4. Each time a "step" completes, call `reportProgress` on your shared instance.
  5. That's it. `hasProgressToReport` will be called on your `ProgressWatcher` each time an update occurs. Check the `progress` value of the `Progress` struct for a float between 0.0 and 1.0.
      
### More complex cases
The shared instance model may not make sense for you. You can simply avoid accessing the `shared` instance and initialize in your own way. 

Alternatively, you can subclass the `ProgressCoordinator` or implement the `ProgressCensus` protocol. Either way, your flexibility increases greatly. The drawback (or potentially, benefit) with implementing the protocol is that you must perform progress calculations on your own.
