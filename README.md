# Round & Split

[![Build Status](https://travis-ci.org/lukhnos/roundandsplit.svg?branch=master)](https://travis-ci.org/lukhnos/roundandsplit)

I needed a tip calculator, so I wrote one.

I always round my tips, and when I dine out with a friend, I use
[Square® Cash](https://square.com/cash) to
split the bill with him or her. I was looking for a tip calculator that could
do both, but there wasn't any. Plus, most tip calculators out there have a lot
of features that I don't need.

So I decided to make one. Or two in fact – I've made an iOS version and an
Android version, because I happen to know programming on both platforms.

You can download the iOS app on
[the App Store](https://itunes.apple.com/us/app/round-split/id912288737?ls=1&mt=8)
for $0.99. It's a free app on
[Google Play](https://play.google.com/store/apps/details?id=org.lukhnos.roundandsplit).

I've also made this an open source project. You are welcome to build the app
on your own from the source code. The only difference is that the source code
here does not include the app icons made by a professional icon designer.


## Features

* Calculate tip at three most common rates in the United States: 15%, 18%, and
  20%.
* Always give you a rounded total.
* Split the bill. The app helps you send an email to Square® Cash. You can use
  that to request money from or pay the split amount to your dining partner.


## On Rounding

When Round & Split rounds the total for you, the rounding can go up or down.
Which direction it goes depends on the effective rate of the tip. The rate
that is closest to your chosen rate wins.

For example, if the charged amount is $37.14, and you want to tip at 18%,
the tip would be $6.69 (37.14 × 18% = 6.69) and the total $43.83, which is
a bit unwieldy for a total. If we round the total down to $43.00, the tip
becomes $5.86, which translate to an effective rate of 15.8%
(5.86/37.14 = 0.158). On the other hand, if we round it up to $44.00, the tip
becomes $6.86, and the effective rate 18.5% (6.86/37.14 = 0.185). 18.5% is
closer to 18%, and so we use $6.86 as the tip and $44.00 as the total. The
point is that I want neither overtipping nor undertipping too much.


## How to Build the App on Your Own

### iOS

Make sure you have the latest version of Xcode installed. At the time
of writing, that is Xcode 6 running on OS X 10.9.4 or higher.

To build Round & Split from source code, follow the steps below:

1. Run `./setup.sh` in your cloned repo directory. This fetches the Fira Sans
   fonts used by the app.
2. In `./iOS/RoundAndSplit`, open `RoundAndSplit.xcodeproj` with Xcode.
3. Use Product > Build.

This allows you to run the app in an iOS Simulator. To upload the built app to
your iOS device, you need to be a member of Apple's iOS Developer Program.

### Android

Make sure you have the latest Android Studio installed and `$ANDROID_HOME`
properly set. Once you have cloned the repo, go to `./Android/RoundAndSplit`
and run:

	./gradlew clean build

The build `.apk` file will be at:

	./Android/RoundAndSplit/app/build/outputs/apk/app-debug.apk

Then you can just upload the app to your connected device with:

	adb install -r app-debug.apk

This, of course, assumes you have enabled the developer mode on your Android
device.

I haven't tried this on Linux or Windows. On Windows you may have to use
`gradlew.bat` to build the app.


## Contribution Policy

This is an open source project, but I also sell a paid version on the App
Store. If you make a pull request, I'll ask you to allow me to use your code
in the paid app without compensation. Your contribution will be acknowledged.


## Acknowledgments

App icon designed by [OneToad](http://onetoad.com/).

User interface designed by the Smoking Hare.

The iOS version of this app uses the Fira Sans typeface from Mozilla:
https://github.com/mozilla/Fira.


## Disclaimer

The "Split and Request/Pay" feature uses Square® Cash to request money from or
pay to another person.

For more information about Square® Cash, visit https://square.com/cash.

Square® Cash is a service provided by Square, Inc. and may not be available in
your region or country.

Neither the developer nor the app is affiliated with Square, Inc. or its
services.


## Copyright and License

The source code is released under the MIT License (MIT).

Copyright (c) 2014 Lukhnos Liu.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
