# Installing GoodNight

1. Download the [latest version of Xcode][1].
2. Download and unzip the [.zip of GoodNight][2].
3. Open `GoodNight.xcodeproj` in Xcode.
4. Select **GoodNight**, then open the **General** tab.
5. Change **Bundle Identifier** to `com.<something>.goodnight` where
`<something>` is some arbitrary string of characters a-z.
6. Change **Team** to your own Apple ID.
7. Click **Fix Issue** below **Team**.
![help-img-1](help-img-1.png)
8. Repeat 4-7 for **GoodNight-Widget**. (Make sure the **Bundle Identifier** has
the same arbitrary string as the first one.)
9. Select your iOS Device in Xcode, then unlock it (type in your passcode if you
have one).
![help-img-2](help-img-2.png)
10. Hit `⌘R` to install. (You may get "Process launch failed: Security." That's
OK.)
11. On your iOS device, go to **Settings → General → Device Management →
\<your Apple ID\>** and hit **Trust**.
12. Launch the GoodNight app on your iOS device from the Home screen.

Note: If you'd like to test your own version of GoodNight, you must select
"Generic iOS Device", or your own device (if plugged in, of course), to
successfully compile and build GoodNight without errors. Please ensure that you
are not building for the iOS Simulator.

[1]: https://itunes.apple.com/us/app/xcode/id497799835
[2]: https://github.com/anthonya1999/GoodNight/archive/master.zip
