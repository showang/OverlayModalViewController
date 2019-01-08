# OverlayModalViewController

[![Build Status](https://dev.azure.com/maxislover/maxislover/_apis/build/status/showang.OverlayModalViewController?branchName=master)](https://dev.azure.com/maxislover/maxislover/_build/latest?definitionId=1?branchName=master)
[![CI Status](http://img.shields.io/travis/showang/OverlayModalViewController.svg?style=flat)](https://travis-ci.org/showang/OverlayModalViewController)
[![Version](https://img.shields.io/cocoapods/v/OverlayModalViewController.svg?style=flat)](http://cocoapods.org/pods/OverlayModalViewController)
[![License](https://img.shields.io/cocoapods/l/OverlayModalViewController.svg?style=flat)](http://cocoapods.org/pods/OverlayModalViewController)
[![Platform](https://img.shields.io/cocoapods/p/OverlayModalViewController.svg?style=flat)](http://cocoapods.org/pods/OverlayModalViewController)

A simple view controller super class to help you make overlay present easier.
(By using native modal present method.)


## Example

Supporting customize your own background effects by implement `OverlayBackgroundView` protocal.

There are two build-in background effects.

| Dark Mask | Scale Blur  |
| ------------- | ----- |
| <img src="https://user-images.githubusercontent.com/780712/36146390-6f400ade-10ef-11e8-88ac-7b3dfcac4c43.gif" width = "192" height = "341" alt="background-darkmask" align=center /> | <img src="https://user-images.githubusercontent.com/780712/36146406-7cec3ba8-10ef-11e8-8d99-5fa70c1385e5.gif" width = "192" height = "341" alt="background-scaleblur" align=center /> |

Support pan gesture with UIScrollView(EX:UITableView...etc) and handling safe area problems.(iOS8 ~ iOS11)

<img src="https://user-images.githubusercontent.com/780712/36146962-5b145964-10f1-11e8-90d8-8c2f5e7462e1.gif" width = "192" height = "341" alt="pangesture_tableview" align=center />

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS8, swift3

## Installation

OverlayModalViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OverlayModalViewController'
```

## Author

William Wang, showang730@gmail.com

## License

OverlayModalViewController is available under the MIT license. See the LICENSE file for more info.
