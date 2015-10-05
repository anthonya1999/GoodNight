# GoodNight  
Based off of Thomas Finch's "GammaThingy", at https://github.com/thomasfinch/GammaThingy.  
  
Goodnight is an app that allows you to directly access the screen's gamma levels, and modify it using IOMobileFramebuffer. With this you can do any of the following:  
* Change the screen temperature  
* Put the brightness lower than iOS would normally allow you to  
* Adjust the RGB values of the framebuffer  
  
This application uses dlsym, which loads in the private symbols at runtime, rather than using headers, so no additional setup is needed once you download the source.
