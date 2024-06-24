# Round & Split

I needed a tip calculator back in 2014, so I wrote one.

I always round my tips, and when I dine out with a friend, I email them
reminders that I owe them money or vice versa. I was looking for a tip
calculator that could do both, but there wasn't any. Plus, most tip calculators
out there have a lot of features that I don't need.

So I decided to make one. Or two in fact – I've made an iOS version and an
Android version, because I happen to know programming on both platforms.

This (now archived) repo contains the open source version of the project. The repo only provides placeholder app icons.


## Features

* Calculate tip at three most common rates in the United States: 15%, 18%, and
  20%.
* Always give you a rounded total.
* Send email reminder with pre-populated subject lines.


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
of writing, that is Xcode 8.3.2 running on macOS 10.12.4 or higher.

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


## Acknowledgments

User interface designed by the Smoking Hare.

The iOS version of this app uses the Fira Sans typeface from Mozilla:
https://github.com/mozilla/Fira.


## Copyright and License

The source code is released under the MIT License (MIT).

Copyright (c) 2014-2024 Lukhnos Liu.

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
