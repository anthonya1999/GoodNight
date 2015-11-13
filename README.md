# GoodNight  
Based off of Thomas Finch's "GammaThingy", at https://github.com/thomasfinch/GammaThingy.  
  
GoodNight is an app that allows you to directly access the screen's gamma levels, and modify it using IOMobileFramebuffer. With this you can do any of the following:  
* Change the screen temperature  
* Put the brightness lower than iOS would normally allow you to  
* Adjust the RGB values of the framebuffer  
  
This application uses dlsym, which loads in the private symbols at runtime, rather than using headers, so no additional setup is needed once you download the source.

### Building  
To successfully compile and build GoodNight without errors, you must select "Generic iOS Device", or your own device (if plugged in, of course). Please ensure that you are not building for the iOS Simulator.

### Compatibility  
I am certain that this app will run on any iOS device running iOS 7 or higher. However, nothing happens when turning on any adjustments if using the iPad Pro. Unfortunately, I do not currently have one, so it has hard to test and find the problem. I will do my best to look into it and find a solution.
