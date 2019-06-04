iTunes-Volume-Control
=====================

Description
-----------

* This app allows you to control iTunes's volume and Spotify's volume using ``volume-up`` and ``volume-down`` hotkeys from your keyboard.
* It also allows you to control the same iTunes volume by means of your Apple Remote control.
* This is particularly useful to control the volume of AirPlay devices.
* You can adjust the finess by which you change the volume.
* You can disable the heads-up display showing the volume status; this is quite handy when you are watching movies and you do not want to be distracted by the overlay volume display.
* Using the volume keys, the volume of the currently playing application (either iTunes or Spotify) is controlled. If neither iTunes nor Spotify are playing music. Then the global volume will be affected by the volume keys.

![alt tag](https://raw.github.com/alberti42/iTunes-Volume-Control/master/screenshot.png)

Why do you need this app?
-------------------------

* iTunes volume cannot be controlled from the keyboard. Volume keys only affect the global system volume.
* However, you might desire to directly control iTunes volume. This is especially relevant when listening to musing on external speakers like AirPlay devices. The volume level of AirPlay devices depends on iTunes's volume but not on the global volume, which you can set with the volume keys.
* iTunes does not respond to volume change from your Apple Remote. Again, Apple Remote would only change the system volume settings, leaving unaffected the volume of your AirPlay devices.
* Sometimes you might desire to hide the volume heads-up overlay from your screen, especially when watching movies. This app can be configured to hide it.

How to get it installed?
------------------------

It is simple. There is no need of any installation.

* Just download this [dmg package](https://github.com/alberti42/iTunes-Volume-Control/raw/master/iTunes%20Volume%20Control.dmg).
* Open it.
* Drag the *iTunes Volume Control* app into your *Application* folder, or any other folder of your choice.
* Run the *iTunes Volume Control* app and a "music note" symbol will appear in your status bar.
* Make sure that *iTunes Volume Control* is enabled in the *Accessibility* panel of *Security & Privacy* of the *System Preferences* (see screenshot below); otherwise the application will not start.
* While iTunes is running, use the volume control keys to change its volume. This will not affect the main volume.

![alt tag](https://raw.github.com/alberti42/iTunes-Volume-Control/master/SecurityPrivacy.png)


Installing it on Mojave as a third-party application
----------------------------------------------------

Mojave has recently increased security with version 10.14.5, disabling the possibility to install third-party application, which are not downloaded from a certified developer. Only companies who are recognized as legal entity can receive from Apple a ``notarization'' quality seal. As I am not planning to start a company to distribute this app, if you want to install it, you can choose either of the two options:

* You can clone the Git repository onto your computer by typing from terminal:

	``git co https://github.com/alberti42/iTunes-Volume-Control.git``
	
 and compile the source code with Xcode. This overcomes the foregoing limitation.
 
* You can temporariy disable Apple's Gatekeeper protection by typing from terminal:

	``sudo spctl --master-disable``
	
  This will add an extra option in the Security & Privacy configuration panel, which you have to select before running the app for the first time.
  
  ![alt tag](https://raw.github.com/alberti42/iTunes-Volume-Control/master/SecurityPrivacyMojave.png)
  
  Do not forget to enable the Gatekeeper back again after you have launched for the first time the application.

	``sudo spctl --master-enable``


Remove quarantine flag
----------------------

If you get an error message *...is damaged and can't be opened...*, it is likely that a quarantine flag has been added to the downloaded file. To remove it, you can either

* Download the program using the terminal. In this case, type:
	
	``wget https://github.com/alberti42/iTunes-Volume-Control/raw/master/iTunes%20Volume%20Control.dmg``
	
	If you downloaded one the zip files linked below, then replace in the above command the dmg file with the corresponding zip file.
	
* Remove the *com.apple.quarantine* flag using the terminal, typing:

	``xattr -d -r com.apple.quarantine ~/Downloads/iTunes\ Volume\ Control.dmg``
	
	replacing *~/Downloads/iTunes\ Volume\ Control.dmg* with the filename where you have downloaded the .dmg package.
	
If you have a suggestion how to avoid such a cumbersome procedure, I would appreciate to hear your feedback.

Requirements
------------

Mac OS X version at least 10.14 (Mojave) or greater

Credits
-------

This app has been inspired by *Volume for iTunes* by Yogi Patel. The icon has been designed by Alexandro Rei. The apple remote control has been adapted from iremotepipe by Steven Wittens. The utilization of MacOS native HUD is based on code written by Benno Krauss and on reverse engineering of */System/Library/CoreServices/OSDUIHelper.app/Contents/MacOS/OSDUIHelper*.

Contacts
--------

If you have any questions, you can contact me at a.alberti82@gmail.com. If you want to know what I do in the real life, visit [http://quantum-technologies.iap.uni-bonn.de/alberti/](http://quantum-technologies.iap.uni-bonn.de/alberti/).


Versions
--------

* [1.6.0](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.6.0.zip): Able to control Spotify, iTunes, and main volume.
* [1.5.3](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.5.3.zip): Made use of Mojave's native heads-up display to show the volume status.
* [1.5.2](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.5.2.zip): Fixed compatibility with Mojave. Prior versions are no longer supported. Fixed small bug on displaying the volume level when controlling it with the Apple Remote.
* [1.5.1](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.5.1.zip): Added the compatibility with Mac OS X versions greater than OS X 10.7 (Lion).
* [1.5](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.5.zip): Added the possibility to change the increment step on the volume. Backward compatible with Mavericks and Yosemite.
* [1.4.10](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.10.zip): Corrected bug on repositioning the volume indicator on right position.
* [1.4.9](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.9.zip): Started to prepare the transition to Yosemite look.
* [1.4.8](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.8.zip): Updates are now signed with DSA. This improves the security, e.g., preventing man-in-the-middle attacks.
* [1.4.7](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.7.zip): Changed icons and graphics to be compatible with retina display.
* [1.4.6](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.6.zip): Added the option to hide the icon from status bar. The icon reappears temporarily (for 10 seconds) by simply restarting the application. This gives the time to change the hide behavior as desired.
* [1.4.5](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.5.zip): Added the option to enable/disable automatic updates occurring once a week
* [1.4.4](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.4.zip): Corrected two bugs: the focus remains correctly on the selected application after changing the volume; cap lock does not prevent anymore the volume to be changed.
* [1.4.3](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.3.zip): Corrected bug: properly hide transparent panels when animations are completed (thanks to Justin Kerr Sheckler)
* [1.4.2](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.2.zip): Added iTunes icon to volume indicator. Corrected bug when iTunes is busy.
* [1.4.1](http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControl-v1.4.1.zip): Added automatic upgrade capability.
* 1.4: Added "mute" control.
* 1.3: Added graphic overlay panel indicating the volume level.
* 1.2: Added options, load at login, use CMD modifier.
* 1.1: Controlling iTunes volume using Apple Remote.
* 1.0: Controlling iTunes volume using keyboard "volume up"/"volume down".

Note: you can download old versions by clicking on the links which appear above here.

Requirements
------------

It is required Mac OS X 10.7 (Lion). The app has been tested with Mac OS X 10.7, 10.8.
