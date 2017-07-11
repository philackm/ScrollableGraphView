# ScrollableGraphView Major API Changes in v4

# Overview

The older versions of the graph have multiple issues:

- Setting data is a one time event that happens before the graph is shown, making it hard to update the data if it happens to change. Currently the entire graph has to be recreated.
- Multiple plots on a single graph are unsupported.
- Reference lines have limited customisation options and user specified locations for reference lines is lacking and clumsy.
- Approximately 60 settings all specified as public properties on a single class, `ScrollableGraphView`. This makes both maintenance and adding new features difficult to achieve.

The new API aims to resolve these issues by:

- Refactoring the current monolithic graph into multiple files and appropriate classes.
- Using common delegate based patterns as a more robust way of providing the graph with data for multiple plots.
- Reworking the way reference lines are specified and added to the graph.
- Providing a new method of configuring the graph, separating the code for the appearance of the graph and the data for the graph.

## Contents

- [API - ScrollableGraphView](#api---scrollablegraphview-class)
- [API - ScrollableGraphViewDataSource](#api---scrollablegraphviewdatasource-protocol)
- [API - ReferenceLines](#api---referencelines-class)
- [Example Usage](#example-usage)
    - [Creating a Graph and Configuring it Programmatically](#creating-a-graph-and-configuring-it-programmatically)
- [List of New Protocols and Types](#list-of-new-protocols-and-types)

# API - ScrollableGraphView Class

## Creating a Graph

```swift
init(frame: CGRect, dataSource: ScrollableGraphViewDataSource)
```

Returns a graph instance. The data source for the graph is an object which conforms to the `GraphViewDataSource` protocol.

## Adding

```swift
func addPlot(plot: Plot)
```

Adds a plot to the graph. Can be called multiple times to add multiple plots. The `identifier` for the plot is passed to the `dataSource` delegate when requesting data.

## Adding Reference Lines to the Graph

```swift
func addReferenceLines(referenceLines: ReferenceLines)
```

Adds an instance of ReferenceLines to the graph. Multiple calls will override the previous reference lines.

## Giving the Graph Data

```swift
var dataSource: ScrollableGraphViewDataSource
```

The data source delegate which provides the graph data. This object must conform to the `GraphViewDataSource` protocol by implementing the following three methods.

```swift
func reload()
```

Causes the graph to recall the delegate functions, to refetch the data.

# API - ScrollableGraphViewDataSource Protocol

```swift
func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double
```

Provides the y-axis value for a given x-axis index.

```swift
func label(atIndex pointIndex: Int) -> String
```

Provides the label that will appear on the x-axis below the point.

```swift
func numberOfPoints(forPlot plot: Plot) -> Int
```

Provides the number of points for each each plot.

# API - ReferenceLines Class

## New Customisation Options for Reference Lines

```swift
var positionType: ReferenceLinePositionType
```

Specifies whether references lines are positioned used percentages or absolute values.

```swift
var relativePositions: [Double]
```

An array of positions specified in percentages where the reference lines will be placed. For example, a value of `[0, 0.5, 0.8, 0.9, 1]` would render 5 reference lines at 0%, 50%, 80%, 90% and 100% of the `rangeMax`.

```swift
var absolutePositions: [Double]
```

An array of positions specified in absolute values where the reference lines will be rendered.

## Example Usage

### Creating a Graph and Configuring it Programmatically

```ViewController.swift```

```swift
class ViewController: UIViewController, ScrollableGraphViewDataSource {
    
    // Class members and init...
    
    var linePlotData: [Double] = // data for line plot
    var barPlotData: [Double] =  // data for bar plot
    var xAxisLabels: [String] =  // the labels along the x axis

    override func viewDidLoad() {
        super.viewDidLoad()

        let graph = ScrollableGraphView(frame: self.view.frame, dataSource: self)
        
        // Graph Configuration
        // ###################

        graph.backgroundColor = UIColor.white
        graph.shouldAnimateOnStartup = true
        
        // Reference Lines
        // ###############
        
        let referenceLines = ReferenceLines()
        referenceLines.positionType = .relative
        referenceLines.relativePositions = [0, 0.5, 0.8, 0.9, 1]
        
        graph.addReferenceLines(referenceLines: referenceLines)
        
        // Adding Plots
        // ############
        
        let linePlot = LinePlot(identifier: "linePlot")
        linePlot.lineWidth = 5
        linePlot.color = UIColor.black
        
        let barPlot = BarPlot(identifier: "barPlot")
        barPlot.barWidth = 20
        barPlot.barFillColor = UIColor.black
        barPlot.barOutlineColor = UIColor.gray
        
        graph.addPlot(plot: linePlot)
        graph.addPlot(plot: barPlot)

        self.view.addSubview(graph)
    }

    // Other class methods...

    // Implementation for ScrollableGraphViewDataSource protocol
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.name) {
            case "linePlot":
                return linePlotData[pointIndex]
                break
            case "barPlot":
                return barPlotData[pointIndex]
                break
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return xAxisLabels[pointIndex]
    }
    
    func numberOfPoints() -> Int {
        return numberOfPointsInGraph
    }
}
```

# List of New Protocols and Types

## New Protocols

`ScrollableGraphViewDataSource`

## New Types

`Plot`

`ReferenceLines`
