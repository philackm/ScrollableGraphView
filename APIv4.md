# ScrollableGraphView

# Overview

The current graph has multiple issues:

- Setting data is a one time event that happens before the graph is shown, making it hard to update the data if it happens to change. Currently the entire graph has to be recreated.
- Multiple plots on a single graph are unsupported.
- Reference lines have limited customisation options and user specified locations for reference lines is lacking and clumsy.
- Approximately 60 settings all specified as public properties on a single class, `ScrollableGraphView`. This makes both maintenance and adding new features difficult to achieve.

The new proposed API aims to resolve these issues by:
- Refactoring the current monolithic graph into multiple files and appropriate classes.
- Using common delegate based patterns as a more robust way of providing the graph with data for multiple plots.
- Reworking the way reference lines are specified and added to the graph.
- Providing a new method of configuring the graph, separating the code for the appearance of the graph and the data for the graph.

## Contents

- [API - ScrollableGraphView](#proposed-api---scrollablegraphview-class)
- [API - ScrollableGraphViewDataSource](#proposed-api---scrollablegraphviewdatasource-protocol)
- [API - ReferenceLines](#proposed-api---referencelines-class)
- [API - Encapsulating Settings](#proposed-api---encapsulating-customisation-settings)
- [API - Configuration Files](#proposed-api---configuration-files)
- [Example Usage](#example-usage)
    - [Creating a Graph via Configuration File](#creating-a-graph-via-configuration-file)
    - [Creating a Graph and Configuring it Programmatically](#creating-a-graph-and-configuring-it-programmatically)
- [List of New Protocols and Types](#list-of-new-protocols-and-types)

# Proposed API - ScrollableGraphView Class

## Creating a Graph

```swift
init(frame: CGRect, dataSource: GraphViewDataSource)
```

Returns a graph instance. The data source for the graph is an object which conforms to the `GraphViewDataSource` protocol.

## Adding/Removing Plots

```swift
func addPlot(type: PlotType, id: String, config: PlotConfiguration)
```

Adds a plot to the graph. Can be called multiple times to add multiple plots. The `id` for the plot is passed to the `dataSource` delegate when requesting data.

```swift
func removePlot(id: String)
```

Removes a plot from the graph for a given id.

## Adding Reference Lines to the Graph

```swift
func addReferenceLines(referenceLines: ReferenceLines)
```

Adds an instance of ReferenceLines to the graph. Multiple calls will override the previous reference lines.

## Giving the Graph Data

```swift
var dataSource: GraphViewDataSource
```

The data source delegate which provides the graph data. This object must conform to the `GraphViewDataSource` protocol by implementing the following three methods.

```swift
func reload()
```

Causes the graph to recall the delegate functions, to refetch the data. The delegate method `numberOfPoints` will also be called. This is used when points have been added/removed from the plot.

## Using Configuration Files

```swift
var configurationFilePath: String
```

Path to the JSON configuration file.

# Proposed API - ScrollableGraphViewDataSource Protocol

```swift
func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double
```

Provides the y-axis value for a given x-axis index.

```swift
func label(forPlot plot: Plot, atIndex pointIndex: Int) -> String
```

Provides the label that will appear on the x-axis below the point.

```swift
func numberOfPoints(forPlot plot: Plot) -> Int
```

Provides the number of points for each each plot.

# Proposed API - ReferenceLines Class

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

# Proposed API - Encapsulating Customisation Settings

Refactoring is required to organise the customisation settings. The `PlotConfiguration` and `GraphConfiguration` classes will encapsulate the settings for the plot and graph respectively. These data structures are then passed to the graph via the `setConfiguration` and `addPlot` methods.

# Proposed API - Configuration Files

In addition to the `PlotConfiguration` and `GraphConfiguration` classes, an alternative method of using JSON configuration files to specify the appearance of the graph will be provided.

# Example Usage

## Creating a graph via Configuration File

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
        graph.configuration = Bundle.main.path(forResource: "configuration", ofType: "json")

        self.view.addSubview(graph)
    }

    // Other class methods...

    // Implementation for ScrollableGraphViewDataSource
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
    
    func label(forPlot plot: Plot, atIndex pointIndex: Int) -> String {
        return xAxisLabels[pointIndex]
    }
    
    func numberOfPoints(forPlot plot: Plot) -> Int {
        switch(plot.name) {
        case "linePlot":
            return linePlotData.count
            break
        case "barPlot":
            return barPlotData.count
            break
        }
    }
}
```

```configuration.json```

```json
// Example JSON configuration file.
{
    "graph":
    {
        "backgroundColor" : "#FFFFFF",
        "shouldAnimateOnStartup" : true,
        "animationDuration" : 2.0
    },
    
    "reference":
    {
        "positionType" : "relative",
        "relativePositions" : [0, 0.5, 0.8, 0.9, 1]
    },
    
    "plots":
    [
        {
            "id" : "lineplot",
            "type" : "line",
            "lineWidth" : 5,
            "lineColor" : "#000000",
        },
    
        {
            "id" : "barplot",
            "type" : "bar",
            "barWidth" : 20,
            "barFillColor" : "#000000",
            "barOutlineColor" : "#333333"
        }
    ]
}
```

## Creating a Graph and Configuring it Programmatically

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

        let graphConfig = GraphConfiguration()
        graphConfig.backgroundColor = UIColor.white
        graphConfig.shouldAnimateOnStartup = true
        graphConfig.animationDuration = 2.0
        
        graph.setConfiguration(graphConfig)
        
        // Reference Lines
        // ###############
        
        let referenceLines = ReferenceLines()
        referenceLines.positionType = .relative
        referenceLines.relativePositions = [0, 0.5, 0.8, 0.9, 1]
        
        graph.addReferenceLines(referenceLines)
        
        // Adding Plots
        // ############
        
        let lineConfig = PlotConfiguration()
        lineConfig.lineWidth = 5
        lineConfig.color = UIColor.black
        
        let barConfig = PlotConfiguration()
        barConfig.barWidth = 20
        barConfig.barFillColor = UIColor.black
        barConfig.barOutlineColor = UIColor.gray
        
        graph.addPlot(PlotType.line, "lineplot", lineConfig?)
        graph.addPlot(PlotType.bar, "barplot", barConfig?)

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
    
    func label(forPlot plot: Plot, atIndex pointIndex: Int) -> String {
        return xAxisLabels[pointIndex]
    }
    
    func numberOfPoints(forPlot plot: Plot) -> Int {
        switch(plot.name) {
        case "linePlot":
            return linePlotData.count
            break
        case "barPlot":
            return barPlotData.count
            break
        }
    }
}
```

# List of New Protocols and Types

## New Protocols

`ScrollableGraphViewDataSource`

## New Types

`Plot`

`PlotType`

`ReferenceLines`

`PlotConfiguration`

`GraphConfiguration`