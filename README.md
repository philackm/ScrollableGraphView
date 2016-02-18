# Scrolling GraphView

## About

![Example Application Usage](readme_images/IMG_5814_small.jpg)

An adaptive scrollable graph view for iOS to visualise simple discrete datasets. Written in Swift. Originally written for a small personal project.

![Init Animation](readme_images/init_anim_high_fps.gif)

## Contents

- [Features](#features)
- [Basic Usage](#usage)
- [Gallery](#gallerythemes)
- [Customisation](#customisation)
- [Improvements](#improvements)
- [Known Issues](#known-issues)
- [Other](#other)

## Features

### Animating!

![Animating](readme_images/animating.gif)

### Manual/Auto/Adaptive Ranging!

![Adapting](readme_images/adapting.gif)

### Scrolling!

![Scrolling](readme_images/scrolling.gif)

### More Scrolling!

![More_Scrolling](readme_images/more_scrolling.gif)

### [Customising!](#Customisation)
![More_Scrolling](readme_images/customising.gif)

## Usage

### Adding the GraphView to your project:

1. Add [GraphView.swift](graphview_example/GraphView/GraphView.swift) to your project in Xcode  

2. Create a GraphView instance and set the data and labels  
```swift
let graphView = GraphView(frame: someFrame)
let data = [4, 8, 15, 16, 23, 42]
let labels = ["one", "two", "three", "four", "five", "six"]
graphView.setData(data, withLabels: labels)
```

3. Add the GraphView to the view hierarchy.
```swift
someViewController.view.addSubview(graphView)
```

### Things you *could* use it for:

- ✔ Study applications to show time studied/etc
- ✔ Weather applications
- ✔ Prototyping
- ✔ *Simple* data visualisation

### Things you **shouldn't/cannot** use it for:

- ✘ Rigorous statistical software
- ✘ Important & complex data visualisation
- ✘ Graphing continuous mathematical functions


## Gallery/Themes

_Note: Examples here use a "colorFromHex" extension for UIColor._

### Default
![dark](readme_images/gallery/default.png)
```swift
let graphView = GraphView(frame: frame)
graphView.setData(data, withLabels: labels)
self.view.addSubview(graphView)
```

### Smooth Dark
![dark](readme_images/gallery/dark.png)
```swift
let graphView = GraphView(frame: frame)

graphView.backgroundFillColor = UIColor.colorFromHex("#333333")

graphView.rangeMax = 50

graphView.lineWidth = 1
graphView.lineColor = UIColor.colorFromHex("#777777")
graphView.lineStyle = GraphViewLineStyle.Smooth

graphView.shouldFill = true
graphView.fillType = GraphViewFillType.Gradient
graphView.fillColor = UIColor.colorFromHex("#555555")
graphView.fillGradientType = GraphViewGradientType.Linear
graphView.fillGradientStartColor = UIColor.colorFromHex("#555555")
graphView.fillGradientEndColor = UIColor.colorFromHex("#444444")

graphView.dataPointSpacing = 80
graphView.dataPointSize = 2
graphView.dataPointFillColor = UIColor.whiteColor()

graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(8)
graphView.referenceLineColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
graphView.referenceLineLabelColor = UIColor.whiteColor()
graphView.dataPointLabelColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)

graphView.setData(data, withLabels: labels)
self.view.addSubview(graphView)
```

### Dot
![dot](readme_images/gallery/dot.png)
```swift
let graphView = GraphView(frame:frame)
graphView.backgroundFillColor = UIColor.colorFromHex("#00BFFF")
graphView.lineColor = UIColor.clearColor()

graphView.dataPointSize = 5
graphView.dataPointSpacing = 80
graphView.dataPointLabelFont = UIFont.boldSystemFontOfSize(10)
graphView.dataPointLabelColor = UIColor.whiteColor()
graphView.dataPointFillColor = UIColor.whiteColor()

graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(10)
graphView.referenceLineColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
graphView.referenceLineLabelColor = UIColor.whiteColor()
graphView.referenceLinePosition = GraphViewReferenceLinePosition.Both

graphView.numberOfIntermediateReferenceLines = 9

graphView.rangeMax = 50

self.view.addSubview(graphView)
```

### Pink Mountain
![pink](readme_images/gallery/pink_mountain.png)
```swift
let graphView = GraphView(frame:frame)
graphView.backgroundFillColor = UIColor.colorFromHex("#222222")
graphView.lineColor = UIColor.clearColor()

graphView.shouldFill = true
graphView.fillColor = UIColor.colorFromHex("#FF0080")

graphView.shouldDrawDataPoint = false
graphView.dataPointSpacing = 80
graphView.dataPointLabelFont = UIFont.boldSystemFontOfSize(10)
graphView.dataPointLabelColor = UIColor.whiteColor()

graphView.referenceLineThickness = 1
graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(10)
graphView.referenceLineColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
graphView.referenceLineLabelColor = UIColor.whiteColor()
graphView.referenceLinePosition = GraphViewReferenceLinePosition.Both

graphView.numberOfIntermediateReferenceLines = 1

graphView.rangeMax = 50

self.view.addSubview(graphView)
```

### Solid Pink with Margins
You can use the top and bottom margin to leave space for other content:

![pink_margins](readme_images/gallery/pink_margins.png)
```swift
let graphView = GraphView(frame:frame)

graphView.bottomMargin = 350
graphView.topMargin = 20

graphView.backgroundFillColor = UIColor.colorFromHex("#222222")
graphView.lineColor = UIColor.clearColor()
graphView.lineStyle = GraphViewLineStyle.Smooth

graphView.shouldFill = true
graphView.fillColor = UIColor.colorFromHex("#FF0080")

graphView.shouldDrawDataPoint = false
graphView.dataPointSpacing = 80
graphView.dataPointLabelFont = UIFont.boldSystemFontOfSize(10)
graphView.dataPointLabelColor = UIColor.whiteColor()

graphView.referenceLineThickness = 1
graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(10)
graphView.referenceLineColor = UIColor.whiteColor().colorWithAlphaComponent(0.25)
graphView.referenceLineLabelColor = UIColor.whiteColor()

graphView.numberOfIntermediateReferenceLines = 0

graphView.rangeMax = 50

self.view.addSubview(graphView)
```

## Customisation

The graph can be customised by setting any of the following public properties before displaying the GraphView. The defaults are shown below.

### Line Styles

```swift
var lineWidth: CGFloat = 2
```
Specifies how thick the graph of the line is. In points.

```swift
var lineColor = UIColor.blackColor()
```
The color of the graph line. UIColor.

```swift
var lineStyle = GraphViewLineStyle.Straight
```
Whether or not the line should be rendered using bezier curves are straight lines.

Possible values:

- ```GraphViewLineStyle.Straight```
- ```GraphViewLineStyle.Smooth```

```swift
var lineJoin = kCALineJoinRound
```
How each segment in the line should connect. Takes any of the Core Animation LineJoin values.

```swift
var lineCap = kCALineCapRound
```
The line caps. Takes any of the Core Animation LineCap values.

### Fill Styles
```swift
var backgroundFillColor = UIColor.whiteColor()
```
The background colour for the entire graph view, not just the plotted graph.

```swift
var shouldFill = false
```
Specifies whether or not the plotted graph should be filled with a colour or gradient.

```swift
var fillType = GraphViewFillType.Solid
```
Specifies whether to fill the graph with a solid colour or gradient.

Possible values:

- ```GraphViewFillType.Solid```
- ```GraphViewFillType.Gradient```

```swift
var fillColor = UIColor.blackColor()
```
If ```fillType``` is set to ```.Solid``` then this colour will be used to fill the graph.

```swift
var fillGradientStartColor = UIColor.whiteColor()
```
If ```fillType``` is set to ```.Gradient``` then this will be the starting colour for the gradient.

```swift
var fillGradientEndColor = UIColor.blackColor()
```
If ```fillType``` is set to ```.Gradient```, then this will be the ending colour for the gradient.

```swift
var fillGradientType = GraphViewGradientType.Linear
```
If ```fillType``` is set to ```.Gradient```, then this defines whether the gradient is rendered as a linear gradient or radial gradient.

Possible values:

- ```GraphViewFillType.Solid```
- ```GraphViewFillType.Gradient```

### Spacing

![spacing](readme_images/spacing.png)

```swift
var topMargin: CGFloat = 10
```
How far the "maximum" reference line is from the top of the view's frame. In points.

```swift
var bottomMargin: CGFloat = 10
```
How far the "minimum" reference line is from the bottom of the view's frame. In points.

```swift
var leftmostPointPadding: CGFloat = 50
```
How far the first point on the graph should be placed from the left hand side of the view.

```swift
var rightmostPointPadding: CGFloat = 50
```
How far the final point on the graph should be placed from the right hand side of the view.

```swift
var dataPointSpacing: CGFloat = 40
```
How much space should be between each data point.

```swift
var direction = GraphViewDirection.LeftToRight
```
Which way the user is expected to scroll from.

Possible values:

- ```GraphViewDirection.LeftToRight```
- ```GraphViewDirection.RightToLeft```


### Graph Range
```swift
var rangeMin: Double = 0
```
The minimum value for the y-axis. This is ignored when ```shouldAutomaticallyDetectRange``` or ```shouldAdaptRange``` = ```true```

```swift
var rangeMax: Double = 100
```
The maximum value for the y-axis. This is ignored when ```shouldAutomaticallyDetectRange``` or ```shouldAdaptRange``` = ```true```

```swift
var shouldAutomaticallyDetectRange = false
```
If this is set to true, then the range will automatically be detected from the data the graph is given.

```swift
var shouldRangeAlwaysStartAtZero = false
```
Forces the graph's minimum to always be zero. Used in conjunction with ```shouldAutomaticallyDetectRange``` or ```shouldAdaptRange```, if you want to force the minimum to stay at 0 rather than the detected minimum.


### Data Point Drawing
```swift
var shouldDrawDataPoint = true
```
Whether or not to draw a symbol for each data point.

```swift
var dataPointType = GraphViewDataPointType.Circle
```
The shape to draw for each data point.

Possible values:

- ```GraphViewDataPointType.Circle```
- ```GraphViewDataPointType.Square```
- ```GraphViewDataPointType.Custom```

```swift
var dataPointSize: CGFloat = 5
```
The size of the shape to draw for each data point.

```swift
var dataPointFillColor: UIColor = UIColor.blackColor()
```
The colour with which to fill the shape.

```swift
var customDataPointPath: ((centre: CGPoint) -> UIBezierPath)?
```
If ```dataPointType``` is set to ```.Custom``` then you can provide a closure to create any kind of shape you would like to be displayed instead of just a circle or square. The closure takes a ```CGPoint``` which is the centre of the shape and it should return a complete ```UIBezierPath```.

### Adapting & Animations
```swift
var shouldAdaptRange = true
```
Whether or not the y-axis' range should adapt to the points that are visible on screen. This means if there are only 5 points visible on screen at any given time, the maximum on the y-axis will be the maximum of those 5 points. This is updated automatically as the user scrolls along the graph.

![Adapting](readme_images/adapting.gif)

```swift
var shouldAnimateOnAdapt = true
```
If ```shouldAdaptRange``` is set to ```true``` then this specifies whether or not the points on the graph should animate to their new positions. Default is set to true. Looks very janky if set to false.

```swift
var animationDuration = 1
```
How long the animation should take. Affects both the startup animation and the animation when the range of the y-axis adapts to onscreen points.

```swift
var adaptAnimationType = GraphViewAnimationType.EaseOut
```
The animation style.

Possible values:

- ```GraphViewAnimationType.EaseOut```
- ```GraphViewAnimationType.Elastic```
- ```GraphViewAnimationType.Custom```

```swift
var customAnimationEasingFunction: ((t: Double) -> Double)?
```
If ```adaptAnimationType``` is set to ```.Custom```, then this is the easing function you would like applied for the animation.

```swift
var shouldAnimateOnStartup = true
```
Whether or not the graph should animate to their positions when the graph is first displayed.

### Reference Lines
```swift
var shouldShowReferenceLines = true
```
Whether or not to show the y-axis reference lines _and_ labels.

```swift
var referenceLineColor = UIColor.blackColor()
```
The colour for the reference lines.

```swift
var referenceLineThickness: CGFloat = 0.5
```
The thickness of the reference lines.

```swift
var referenceLinePosition = GraphViewReferenceLinePosition.Left
```
Where the labels should be displayed on the reference lines.

Possible values:

- ```GraphViewReferenceLinePosition.Left```
- ```GraphViewReferenceLinePosition.Right```
- ```GraphViewReferenceLinePosition.Both```

```swift
var referenceLineType = GraphViewReferenceLineType.Cover
```
The type of reference lines. Currently only ```.Cover``` is available.

```swift
var numberOfIntermediateReferenceLines: Int = 3
```
How many reference lines should be between the minimum and maximum reference lines. If you want a total of 4 reference lines, you would set this to 2. This can be set to 0 for no intermediate reference lines.

This can be used to create reference lines at specific intervals. If the desired result is to have a reference line at every 10 units on the y-axis, you could, for example, set ```rangeMax``` to 100, ```rangeMin``` to 0 and ```numberOfIntermediateReferenceLines``` to 9.

```swift
var shouldAddLabelsToIntermediateReferenceLines = true
```
Whether or not to add labels to the intermediate reference lines.

```swift
var shouldAddUnitsToIntermediateReferenceLineLabels = false
```
Whether or not to add units specified by the ```referenceLineUnits``` variable to the labels on the intermediate reference lines.

### Reference Line Labels
```swift
var referenceLineLabelFont = UIFont.systemFontOfSize(8)
```
The font to be used for the reference line labels.

```swift
var referenceLineLabelColor = UIColor.blackColor()
```
The colour of the reference line labels.

```swift
var shouldShowReferenceLineUnits = true
```
Whether or not to show the units on the reference lines.

```swift
var referenceLineUnits: String?
```
The units that the y-axis is in. This string is used for labels on the reference lines.

```swift
var referenceLineNumberOfDecimalPlaces: Int = 0
```
The number of decimal places that should be shown on the reference line labels.

### Data Point Labels (x-axis)

```swift
var shouldShowLabels = true
```
Whether or not to show the labels on the x-axis for each point.

```swift
var dataPointLabelTopMargin: CGFloat = 10
```
How far from the "minimum" reference line the data point labels should be rendered.

```swift
var dataPointLabelBottomMargin: CGFloat = 0
```
How far from the bottom of the view the data point labels should be rendered.

```swift
var dataPointLabelFont: UIFont? = UIFont.systemFontOfSize(10)
```
The font for the data point labels.

```swift
var dataPointLabelColor = UIColor.blackColor()
```
The colour for the data point labels.



## Improvements

Pull requests, improvements & criticisms to any and all of the code are more than welcome.



## Known Issues

If you find any bugs please create an issue on Github.



## Other

[Follow me on twitter](https://twitter.com/philackm) for interesting updates (read: gifs) about other things that I make.
