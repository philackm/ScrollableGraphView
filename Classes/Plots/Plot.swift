
import UIKit

public enum PlotType {
    case line
    case bar
    case dot
}

open class Plot {
    var identifier: String
    
    init() {
        identifier = "Plot"
    }
}

open class LinePlot : Plot {
    
    // Public settings for the LinePlot
    // ################################
    
    /// Specifies how thick the graph of the line is. In points.
    @IBInspectable open var lineWidth: CGFloat = 2
    
    /// The color of the graph line. UIColor.
    @IBInspectable open var lineColor: UIColor = UIColor.black
    
    /// Whether the line is straight or curved.
    @IBInspectable var lineStyle_: Int {
        get { return lineStyle.rawValue }
        set {
            if let enumValue = ScrollableGraphViewLineStyle(rawValue: newValue) {
                lineStyle = enumValue
            }
        }
    }
    
    /// Whether or not the line should be rendered using bezier curves are straight lines.
    open var lineStyle = ScrollableGraphViewLineStyle.straight
    
    /// How each segment in the line should connect. Takes any of the Core Animation LineJoin values.
    @IBInspectable open var lineJoin: String = kCALineJoinRound
    
    /// The line caps. Takes any of the Core Animation LineCap values.
    @IBInspectable open var lineCap: String = kCALineCapRound
    @IBInspectable open var lineCurviness: CGFloat = 0.5
    
    
    // Fill Settings
    // #############
    
    /// Specifies whether or not the plotted graph should be filled with a colour or gradient.
    @IBInspectable open var shouldFill: Bool = false
    
    @IBInspectable var fillType_: Int {
        get { return fillType.rawValue }
        set {
            if let enumValue = ScrollableGraphViewFillType(rawValue: newValue) {
                fillType = enumValue
            }
        }
    }
    
    /// Specifies whether to fill the graph with a solid colour or gradient.
    open var fillType = ScrollableGraphViewFillType.solid
    
    /// If fillType is set to .Solid then this colour will be used to fill the graph.
    @IBInspectable open var fillColor: UIColor = UIColor.black
    
    /// If fillType is set to .Gradient then this will be the starting colour for the gradient.
    @IBInspectable open var fillGradientStartColor: UIColor = UIColor.white
    
    /// If fillType is set to .Gradient, then this will be the ending colour for the gradient.
    @IBInspectable open var fillGradientEndColor: UIColor = UIColor.black
    
    @IBInspectable var fillGradientType_: Int {
        get { return fillGradientType.rawValue }
        set {
            if let enumValue = ScrollableGraphViewGradientType(rawValue: newValue) {
                fillGradientType = enumValue
            }
        }
    }
    
    /// If fillType is set to .Gradient, then this defines whether the gradient is rendered as a linear gradient or radial gradient.
    open var fillGradientType = ScrollableGraphViewGradientType.linear
    
    // Private State
    // #############
    
    private var lineLayer: LineDrawingLayer?
    private var fillLayer: FillDrawingLayer?
    private var gradientLayer: GradientDrawingLayer?
    
    override init() {
        super.init()
        self.identifier = "LinePlot"
    }
    
    func layers(forViewport viewport: CGRect) -> [ScrollableGraphViewDrawingLayer?] {
        createLayers(viewport: viewport)
        return [lineLayer, fillLayer, gradientLayer]
    }
    
    private func createLayers(viewport: CGRect) {
        
        // Create the line drawing layer.
        lineLayer = LineDrawingLayer(frame: viewport, lineWidth: lineWidth, lineColor: lineColor, lineStyle: lineStyle, lineJoin: lineJoin, lineCap: lineCap, shouldFill: shouldFill, lineCurviness: lineCurviness)
        
        // Depending on whether we want to fill with solid or gradient, create the layer accordingly.
        
        // Gradient and Fills
        switch (self.fillType) {
            
        case .solid:
            if(shouldFill) {
                // Setup fill
                fillLayer = FillDrawingLayer(frame: viewport, fillColor: fillColor, lineDrawingLayer: lineLayer!)
            }
            
        case .gradient:
            if(shouldFill) {
                gradientLayer = GradientDrawingLayer(frame: viewport, startColor: fillGradientStartColor, endColor: fillGradientEndColor, gradientType: fillGradientType, lineDrawingLayer: lineLayer!)
            }
        }
    }
}


open class DataPointPlot : Plot {
    
    // Customisation
    // #############
    
    /// Whether or not to draw a symbol for each data point.
    @IBInspectable open var shouldDrawDataPoint: Bool = true
    /// The shape to draw for each data point.
    open var dataPointType = ScrollableGraphViewDataPointType.circle
    /// The size of the shape to draw for each data point.
    @IBInspectable open var dataPointSize: CGFloat = 5
    /// The colour with which to fill the shape.
    @IBInspectable open var dataPointFillColor: UIColor = UIColor.black
    /// If dataPointType is set to .Custom then you,can provide a closure to create any kind of shape you would like to be displayed instead of just a circle or square. The closure takes a CGPoint which is the centre of the shape and it should return a complete UIBezierPath.
    open var customDataPointPath: ((_ centre: CGPoint) -> UIBezierPath)?
    
    // Private State
    // #############
    
    private var dataPointLayer: DataPointDrawingLayer?
    
    override init() {
        super.init()
        self.identifier = "DataPointPlot"
    }
    
    func layers(forViewport viewport: CGRect) -> [ScrollableGraphViewDrawingLayer?] {
        createLayers(viewport: viewport)
        return [dataPointLayer]
    }
    
    private func createLayers(viewport: CGRect) {
        // Data Point layer
        if(shouldDrawDataPoint) {
            dataPointLayer = DataPointDrawingLayer(frame: viewport, fillColor: dataPointFillColor, dataPointType: dataPointType, dataPointSize: dataPointSize, customDataPointPath: customDataPointPath)
        }
    }
}

open class BarPlot : Plot {
    override init() {
        super.init()
        self.identifier = "BarPlot"
    }
}



