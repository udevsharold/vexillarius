# vexillarius
 Helper for displaying banners in iOS 14

## What's this?
This package is an imposter holding special privilege (com.apple.BluetoothUIService entitlement) in iOS 14 for displaying that little tiny banner. It's designed as an On-Demand daemon and will be activated whenever it's summoned ([by some dark magic](https://github.com/udevsharold/perseus/blob/b2fae5375fd04694e3261f5da43458a4006b891e/Perseus.xm#L79)).

As of iOS 14.3, only few entities hold special privilege (com.apple.bannerkit.post) for posting banners:
- com.apple.BluetoothUIService
- com.apple.DragUI.druid
- com.apple.BannerKitTest
- com.apple.Maps
- com.apple.proximitycontrold

where they all have different UI design (I didn't dissect them all to be honest) for the banner, but similar in backbone. For example, the "Pasted from XXX" banner is holding com.apple.DragUI.druid entitlement, but is not designed for displaying glyphs.
They all however works by sending XPC message to 
[BannerKit](https://github.com/udevsharold/iOS-14.3-Headers/tree/acfaa34b5a3bdf288ae972ee72b47ebcbbd45f89/System/Library/PrivateFrameworks/BannerKit.framework) framework (where entitlement will be verified), and if you're one of the special ones (you're not), it will be presented using the method

```
postPresentable:withOptions:userInfo:error:
```
So technically, you could create/design your own banner using 
[BNBannerSource](https://github.com/udevsharold/iOS-14.3-Headers/blob/acfaa34b5a3bdf288ae972ee72b47ebcbbd45f89/System/Library/PrivateFrameworks/BannerKit.framework/BNBannerSource.h) (I wouldn't), but you'll also have to deal with the entitlement. vexillarius, on the other hand, sends XPC message to BluetoothUIService, and let it do all the dirty work of designing and managing the banners, and then dispatch it to BannerKit. BluetoothUIService will verify that if the client process is holding com.apple.BluetoothUIService entitlement before proceed with the XPC message request.

## Example Implementation
Example use case of this package could be found in 
[Perseus](https://github.com/udevsharold/perseus)'s source code. For your laziness, specifically this 
[line](https://github.com/udevsharold/perseus/blob/b2fae5375fd04694e3261f5da43458a4006b891e/Perseus.xm#L79).

## Notice
I didn't spend too much time on exploring all other options that are available in this package, one of them is .backgroundColor. So, it's provided as it is.

## License
All source code in this repository are licensed under GPLv3, unless stated otherwise.

Copyright (c) 2021 udevs