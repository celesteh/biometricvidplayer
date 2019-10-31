# biometricvidplayer
Bitalino Controlled video player for performance

## Dependencies
To add dependencies, drag and drop the jar files on top of the Processing sketch in the app.  Add both Bluecove jars and both jars from the bitalino downloads.

* Bitalino https://jar-download.com/artifacts/com.bitalino/bitalino-java-sdk/1.1.0/source-code

### Mac and Win
* Bluecove Mac and Win https://sourceforge.net/projects/bluecove/

### Linux
* Linux users also have system dependencies: `sudo apt-get install libbluetooth-dev`.
* Bluecove Linux http://www.bluecove.org/bluecove-gpl/
* Linux users may have difficulty pairing with the device: (from https://makezine.com/projects/use-bitalino-graph-biosignals-play-pong/ )
>Getting the sketch working under Linux requires two extra steps. (I tested it under Ubuntu 14.04 LTS with Processing 2.2.1.) The Bluetooth setup application might have some difficulty pairing with BITalino if you’re not quick enough (just click all buttons in 20 seconds after you’ve turned it on and you’ll be fine, otherwise the setup application will generate its own pairing code and the pairing will fail; see [this forum post](https://bugs.launchpad.net/ubuntu/+source/gnome-bluetooth/+bug/551950). Next, you have to bind the paired device to a serial comm port:
```
    $ sudo hcitool scan
    Scanning ...
    	20:17:09:18:58:28	BITalino-58-28
    $ sudo rfcomm bind /dev/rfcomm0 20:17:09:18:58:28 1
    $ ls -l /dev/rfcomm0
    crw-rw---- 1 root dialout 216, 0 Oct 31 10:03 /dev/rfcomm0
```
