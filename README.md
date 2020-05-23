# ProgressReporter

A highly abstract method to coordinate input from multiple objects on the progress of a single, complex task.

## Why?
There's really not much to it. If your project uses Swift and has complex or long-running tasks, try this out. **Maybe you won't have to reinvent the wheel.** I use it in my own projects for networking operations and Core Data migrations as well as complex data tasks... basically anything the user needs to see a progress bar for.

## Installation
There's only one file. You can drag and drop it into your project as use as needed. Or if you're feeling fancy / lazy / extravagant you can use Swift Package Manager.

## Getting Started
Inline documentation is verbose and helpful, but if you're not sure where to get started, here's a rundown of things:

### Most use-cases
 1. Create a `ProgressWatcher` and use the `shared` instance in places you need to report progress.
 2. Conform a view or controller to the `ProgressReporter` protocol and then set the `reporter` object on your Watcher.
 3. Add as many steps to a `Progress` object as needed using `addStepsToProgress`.  
 4. Each time a "step" completes, call `reportProgress` on your shared instance.
 5. That's it. `hasProgressToReport` will be called on your `ProgressReporter` each time an update occurs. Check the `progress` value of the `Progress` struct for a float betwee 0.0 and 1.0. Perfect for a `UIProgressView`!

### More complex cases
The shared instance model may not make sense for you. You can simply avoid accessing the `shared` instance and initialize in your own way. 

You can subclass the `ProgressWatcher` or implement the `ProgressCensus` protocol. Either way, your flexibility increases greatly. The drawback (or potentially, benefit) with implementing the protocol is that you must perform progress calcualtions on your own.
