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

See [here](Help/README.md).

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


[1]: https://github.com/thomasfinch/GammaThingy
