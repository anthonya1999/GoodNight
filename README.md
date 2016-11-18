# GoodNight
Project name thanks to @Emu4iOS.

Based off of Thomas Finch's [GammaThingy][1].

GoodNight is an app that allows you to directly access the screen's gamma
levels, and modify it using `IOMobileFramebuffer`. With this you can do any of
the following:

* Change the screen temperature
* Put the brightness lower than iOS would normally allow you to
* Adjust the RGB values of the framebuffer

This application uses `dlsym`, which loads in the private symbols at runtime,
rather than using headers, so no additional setup is needed once you download
the source.

### Installing

See [here] (Help/README.md) for written instructions.  
Click on [this link] (https://www.youtube.com/watch?v=Yu62IlaqPQM) to see the official install video.  

### Compatibility

I am certain that this app will run on any iOS device running iOS 7 or higher.

### Widget

The widget's **gamma toggle button** just toggles between night gamma and gamma off (like the enable button in the temperature part of the app). It overrides the auto updates until the next cycle:

* So if you enable gamma with the widget while auto is in day mode it will keep gamma enabled until auto will turn to day the next morning.
* If you enable gamma and after that disable gamma with the widget, both during daytime, it will keep gamma deactivated until the next day sunset.
* If you disable gamma with the widget while auto is in night mode it will keep gamma disables until auto will turn to day the next evening.
* If you disable gamma and after that enable gamma with the widget, both during night time, it will keep gamma activated the complete next day until it reaches sunrise again.

Bedtime mode will only be activated if at that time the screen has active gamma. Else the bedtime mode will be skipped.

The **darkroom button** turns on darkroom mode and on deactivation of darkroom mode resumes to automatic mode immediately.

### macOS Version
The macOS version of GoodNight is very basic at the moment. You can currently enter RGB values between 0 and 1 for red, green, and blue values, and have the screen adjust to the color values you entered. For a "nighttime orange" these values work best in my testing: 
* Red: 1  
* Green: 0.5  
* Blue: 0.1  
Of course, in the future more features will become available. I plan to implement a slider and white point adjuster, as well as a touch bar slider for the new 2016 MacBook Pros! Please create pull requests! Thanks so much for everyone's help.

[1]: https://github.com/thomasfinch/GammaThingy
