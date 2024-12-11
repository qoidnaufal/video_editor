# WIP
Originally, I'm very impressed by QuickTime video player's low CPU usage.
This motivates me to try to play around with Swift and AVKit. So far this doesn't dissapoint me.<br>
So, maybe, instead of fighting to get the best performance with Ffmpeg and Rust's any GUI framework, maybe I'll just use SwiftUI & AVKit.
And maybe later add some functionality with Rust.<br>

### Compiling
To compile: `swiftc -framework AVKit -o <whatever_file_name_you_want>` and run with `./<whatever_file_name_you_use>`.<br>
The `-framework AVKit` is super important if you don't use XCode like I did.<br>
Some functions have compatibility issue with different macOS versions, so it's important to add `platforms: [.macOS(.<latest_version>)]` in `Package.swift`

### References
- [Compile Swift app without using XCode](https://gist.github.com/chriseidhof/26768f0b63fa3cdf8b46821e099df5ff)
- [Programmatic video editing with Swift](https://videowithswift.com/initial-environment-setup-to-edit-play-and-export-video-with-swift/)
