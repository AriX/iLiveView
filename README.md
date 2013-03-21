iLiveView
=========

This code is a proof-of-concept iOS driver for the Sony Ericsson LiveView watch. It is /extremely/ unfinished. You can see a quick demo here: http://www.youtube.com/watch?v=SWtLeoRSQ8M

I wrote this several years ago, and I'm open sourcing it today because I have not had the time to finish the project myself, and many people seem to still be interested in it! Hopefully someone can pick up where I left off.

The code can be used in two ways. It can be built and run via Xcode, for a quick demo app that will connect to the LiveView. (Note that the buttons in this app probably don't do what they say they will do. Try pressing "Set Menu Zero" and then "Vibrate." Boom. Sgt. Pepper's) Or it can be built as an actual tweak, with support for reading your unread text messages an emails, with [Theos](https://github.com/DHowett/theos).

Major Caveats
=========

Your phone must be jailbroken and have BTStack installed in order for this to work.

Major things that need to be done:
- Daemonization

Currently, iLiveView hooks into SpringBoard in order to get notifications. This means that the whole driver is running under the SpringBoard process, and if it crashes (which it sometimes does), the entirety of SpringBoard will crash. It needs to be separated into its own daemon, which should communicate with a SpringBoard tweak via XPC or similar.
- Bluetooth device searching

Currently, my code is hardcoded to the MAC address of my LiveView unit. You can change it yourself to work with your unit; I believe it is hardcoded in LVController.m. But for normal users to be able to use this, there needs to be some sort of set-up GUI that allows you to find your LiveView among the available Bluetooth devices. There is some code included in this repo from BTStack that should help with this.
- Stability improvements

Currently, the driver crashes sometimes.
- More functionality

The driver currently doesn't do many basic things. It has a basic proof-of-concept for controlling your music and reading your Mail and text notifications. It doesn't do anything else. It won't notify you when you get a phone call. A lot of other functionality is missing.
- Finish migrating stuff to C structures

Part of this code is still based on an NSMutableData category from fayep that approximates the functionality of Python's struct module. I didn't like this too much, so I rewrote it to use C structures (see LiveViewConstants.h). I didn't quite finish, and you'll notice some calls to a method involving "legacyNSData," which should be replaced.
- The code isn't that well-written.

It's a proof-of-concept. It could use some work. The endianness stuff is not handled gracefully. Somehow I ended up with mixed  tabs and spaces. That should be fixed too.
- Probably other stuff

Credzzz
=========

This code was originally inspired by adq's reverse engineering effort. The result of this can be found here: http://code.google.com/p/adqmisc/source/browse/#svn%2Ftrunk%2Fliveview

A small amount of this code is based on [fayep's Mac LiveView implementation](https://github.com/fayep/GrowLView). I ripped the theos project structure from the old [MobileNotifier project](https://github.com/peterhajas/MobileNotifier); forgive me if there is a file or two lingering from there.

Thanks to mringwal for BTStack!

License
=========

iLiveView is licensed under the BSD license. See the LICENSE file for details.
