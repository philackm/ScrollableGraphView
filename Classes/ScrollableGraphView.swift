import UIKit

// MARK: - ScrollableGraphView
@objc public class ScrollableGraphView: UIScrollView, UIScrollViewDelegate, ScrollableGraphViewDrawingDelegate {
    
    // MARK: - Public Properties
    // Use these to customise the graph.
    // #################################
    
    // Line Styles
    // ###########
    
    /// Specifies how thick the graph of the line is. In points.
    public var lineWidth: CGFloat = 2
    /// The color of the graph line. UIColor.
    public var lineColor = UIColor.blackColor()
    /// Whether or not the line should be rendered using bezier curves are straight lines.
    public var lineStyle = ScrollableGraphViewLineStyle.Straight
    /// How each segment in the line should connect. Takes any of the Core Animation LineJoin values.
    public var lineJoin = kCALineJoinRound
    /// The line caps. Takes any of the Core Animation LineCap values.
    public var lineCap = kCALineCapRound
    public var lineCurviness: CGFloat = 0.5
    
    // Bar styles
    // ##########
    
    /// Whether bars should be drawn or not. If you want a bar graph, this should be set to true.
    public var shouldDrawBarLayer = false
    /// The width of an individual bar on the graph.
    public var barWidth: CGFloat = 25;
    /// The actual colour of the bar.
    public var barColor = UIColor.grayColor()
    /// The width of the outline of the bar
    public var barLineWidth: CGFloat = 1
    /// The colour of the bar outline
    public var barLineColor = UIColor.darkGrayColor()
    
    // Fill Styles
    // ###########
    
    /// The background colour for the entire graph view, not just the plotted graph.
    public var backgroundFillColor = UIColor.whiteColor()
    
    /// Specifies whether or not the plotted graph should be filled with a colour or gradient.
    public var shouldFill = false
    /// Specifies whether to fill the graph with a solid colour or gradient.
    public var fillType = ScrollableGraphViewFillType.Solid
    /// If fillType is set to .Solid then this colour will be used to fill the graph.
    public var fillColor = UIColor.blackColor()
    /// If fillType is set to .Gradient then this will be the starting colour for the gradient.
    public var fillGradientStartColor = UIColor.whiteColor()
    /// If fillType is set to .Gradient, then this will be the ending colour for the gradient.
    public var fillGradientEndColor = UIColor.blackColor()
    /// If fillType is set to .Gradient, then this defines whether the gradient is rendered as a linear gradient or radial gradient.
    public var fillGradientType = ScrollableGraphViewGradientType.Linear
    
    // Spacing
    // #######
    
    /// How far the "maximum" reference line is from the top of the view's frame. In points.
    public var topMargin: CGFloat = 10
    /// How far the "minimum" reference line is from the bottom of the view's frame. In points.
    public var bottomMargin: CGFloat = 10
    /// How far the first point on the graph should be placed from the left hand side of the view.
    public var leftmostPointPadding: CGFloat = 50
    /// How far the final point on the graph should be placed from the right hand side of the view.
    public var rightmostPointPadding: CGFloat = 50
    /// How much space should be between each data point.
    public var dataPointSpacing: CGFloat = 40
    /// Which side of the graph the user is expected to scroll from.
    public var direction = ScrollableGraphViewDirection.LeftToRight
    
    // Graph Range
    // ###########
    
    /// If this is set to true, then the range will automatically be detected from the data the graph is given.
    public var shouldAutomaticallyDetectRange = false
    /// Forces the graph's minimum to always be zero. Used in conjunction with shouldAutomaticallyDetectRange or shouldAdaptRange, if you want to force the minimum to stay at 0 rather than the detected minimum.
    public var shouldRangeAlwaysStartAtZero = false // Used in conjunction with shouldAutomaticallyDetectRange, if you want to force the min to stay at 0.
    /// The minimum value for the y-axis. This is ignored when shouldAutomaticallyDetectRange or shouldAdaptRange = true
    public var rangeMin: Double = 0
    /// The maximum value for the y-axis. This is ignored when shouldAutomaticallyDetectRange or shouldAdaptRange = true
    public var rangeMax: Double = 100
    
    // Data Point Drawing
    // ##################
    
    /// Whether or not to draw a symbol for each data point.
    public var shouldDrawDataPoint = true
    /// The shape to draw for each data point.
    public var dataPointType = ScrollableGraphViewDataPointType.Circle
    /// The size of the shape to draw for each data point.
    public var dataPointSize: CGFloat = 5
    /// The colour with which to fill the shape.
    public var dataPointFillColor: UIColor = UIColor.blackColor()
    /// If dataPointType is set to .Custom then you,can provide a closure to create any kind of shape you would like to be displayed instead of just a circle or square. The closure takes a CGPoint which is the centre of the shape and it should return a complete UIBezierPath.
    public var customDataPointPath: ((centre: CGPoint) -> UIBezierPath)?
    
    // Adapting & Animations
    // #####################
    
    /// Whether or not the y-axis' range should adapt to the points that are visible on screen. This means if there are only 5 points visible on screen at any given time, the maximum on the y-axis will be the maximum of those 5 points. This is updated automatically as the user scrolls along the graph.
    public var shouldAdaptRange = false
    /// If shouldAdaptRange is set to true then this specifies whether or not the points on the graph should animate to their new positions. Default is set to true.
    public var shouldAnimateOnAdapt = true
    /// How long the animation should take. Affects both the startup animation and the animation when the range of the y-axis adapts to onscreen points.
    public var animationDuration: Double = 1
    /// The animation style.
    public var adaptAnimationType = ScrollableGraphViewAnimationType.EaseOut
    /// If adaptAnimationType is set to .Custom, then this is the easing function you would like applied for the animation.
    public var customAnimationEasingFunction: ((t: Double) -> Double)?
    /// Whether or not the graph should animate to their positions when the graph is first displayed.
    public var shouldAnimateOnStartup = true
    
    // Reference Lines
    // ###############
    
    /// Whether or not to show the y-axis reference lines and labels.
    public var shouldShowReferenceLines = true
    /// The colour for the reference lines.
    public var referenceLineColor = UIColor.blackColor()
    /// The thickness of the reference lines.
    public var referenceLineThickness: CGFloat = 0.5
    /// Where the labels should be displayed on the reference lines.
    public var referenceLinePosition = ScrollableGraphViewReferenceLinePosition.Left
    /// The type of reference lines. Currently only .Cover is available.
    public var referenceLineType = ScrollableGraphViewReferenceLineType.Cover
    
    /// How many reference lines should be between the minimum and maximum reference lines. If you want a total of 4 reference lines, you would set this to 2. This can be set to 0 for no intermediate reference lines.This can be used to create reference lines at specific intervals. If the desired result is to have a reference line at every 10 units on the y-axis, you could, for example, set rangeMax to 100, rangeMin to 0 and numberOfIntermediateReferenceLines to 9.
    public var numberOfIntermediateReferenceLines: Int = 3
    /// Whether or not to add labels to the intermediate reference lines.
    public var shouldAddLabelsToIntermediateReferenceLines = true
    /// Whether or not to add units specified by the referenceLineUnits variable to the labels on the intermediate reference lines.
    public var shouldAddUnitsToIntermediateReferenceLineLabels = false
    
    // Reference Line Labels
    // #####################
    
    /// The font to be used for the reference line labels.
    public var referenceLineLabelFont = UIFont.systemFontOfSize(8)
    /// The colour of the reference line labels.
    public var referenceLineLabelColor = UIColor.blackColor()
    
    /// Whether or not to show the units on the reference lines.
    public var shouldShowReferenceLineUnits = true
    /// The units that the y-axis is in. This string is used for labels on the reference lines.
    public var referenceLineUnits: String?
    /// The number of decimal places that should be shown on the reference line labels.
    public var referenceLineNumberOfDecimalPlaces: Int = 0
    
    // Data Point Labels
    // #################
    
    /// Whether or not to show the labels on the x-axis for each point.
    public var shouldShowLabels = true
    /// How far from the "minimum" reference line the data point labels should be rendered.
    public var dataPointLabelTopMargin: CGFloat = 10
    /// How far from the bottom of the view the data point labels should be rendered.
    public var dataPointLabelBottomMargin: CGFloat = 0
    /// The font for the data point labels.
    public var dataPointLabelColor = UIColor.blackColor()
    /// The colour for the data point labels.
    public var dataPointLabelFont: UIFont? = UIFont.systemFontOfSize(10)
    /// Used to force the graph to show every n-th dataPoint label
    public var dataPointLabelsSparsity: Int = 1
  
    // MARK: - Private State
    // #####################
    
    // Graph Data for Display
    private var data = [Double]()
    private var labels = [String]()
    
    private var isInitialSetup = true
    private var dataNeedsReloading = true
    private var isCurrentlySettingUp = false
    
    private var viewportWidth: CGFloat = 0 {
        didSet { if(oldValue != viewportWidth) { viewportDidChange() }}
    }
    private var viewportHeight: CGFloat = 0 {
        didSet { if(oldValue != viewportHeight) { viewportDidChange() }}
    }
    
    private var totalGraphWidth: CGFloat = 0
    private var offsetWidth: CGFloat = 0
    
    // Graph Line
    private var currentLinePath = UIBezierPath()
    private var zeroYPosition: CGFloat = 0
    
    // Labels
    private var labelsView = UIView()
    private var labelPool = LabelPool()
    
    // Graph Drawing
    private var graphPoints = [GraphPoint]()
    
    private var drawingView = UIView()
    private var barLayer: BarDrawingLayer?
    private var lineLayer: LineDrawingLayer?
    private var dataPointLayer: DataPointDrawingLayer?
    private var fillLayer: FillDrawingLayer?
    private var gradientLayer: GradientDrawingLayer?
    
    // Reference Lines
    private var referenceLineView: ReferenceLineDrawingView?
    
    // Animation
    private var displayLink: CADisplayLink!
    private var previousTimestamp: CFTimeInterval = 0
    private var currentTimestamp: CFTimeInterval = 0
    
    private var currentAnimations = [GraphPointAnimation]()
    
    // Active Points & Range Calculation
    
    private var previousActivePointsInterval: Range<Int> = -1 ..< -1
    private var activePointsInterval: Range<Int> = -1 ..< -1 {
        didSet {
            if(oldValue.startIndex != activePointsInterval.startIndex || oldValue.endIndex != activePointsInterval.endIndex) {
                if !isCurrentlySettingUp { activePointsDidChange() }
            }
        }
    }
    
    private var range: (min: Double, max: Double) = (0, 100) {
        didSet {
            if(oldValue.min != range.min || oldValue.max != range.max) {
                if !isCurrentlySettingUp { rangeDidChange() }
            }
        }
    }
    
    // MARK: - INIT, SETUP & VIEWPORT RESIZING
    // #######################################
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    private func setup() {
        
        isCurrentlySettingUp = true
        
        // Make sure everything is in a clean state.
        reset()
        
        self.delegate = self
        
        // Calculate the viewport and drawing frames.
        self.viewportWidth = self.frame.width
        self.viewportHeight = self.frame.height
        
        totalGraphWidth = graphWidthForNumberOfDataPoints(data.count)
        self.contentSize = CGSize(width: totalGraphWidth, height: viewportHeight)
        
        // Scrolling direction.
        if (direction == .RightToLeft) {
            self.offsetWidth = self.contentSize.width - viewportWidth
        }
            // Otherwise start of all the way to the left.
        else {
            self.offsetWidth = 0
        }
        
        // Set the scrollview offset.
        self.contentOffset.x = self.offsetWidth
        
        // Calculate the initial range depending on settings.
        let initialActivePointsInterval = calculateActivePointsInterval()
        let detectedRange = calculateRangeForEntireDataset(self.data)
        
        if(shouldAutomaticallyDetectRange) {
            self.range = detectedRange
        }
        else {
            self.range = (min: rangeMin, max: rangeMax)
        }
        
        if (shouldAdaptRange) { // This supercedes the shouldAutomaticallyDetectRange option
            let range = calculateRangeForActivePointsInterval(initialActivePointsInterval)
            self.range = range
        }
        
        // If the graph was given all 0s as data, we can't use a range of 0->0, so make sure we have a sensible range at all times.
        if (self.range.min == 0 && self.range.max == 0) {
            self.range = (min: 0, max: rangeMax)
        }
        
        // DRAWING
        
        let viewport = CGRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight)
        
        // Create all the GraphPoints which which are used for drawing.
        for i in 0 ..< data.count {
            let value = (shouldAnimateOnStartup) ? self.range.min : data[i]
            
            let position = calculatePosition(i, value: value)
            let point = GraphPoint(position: position)
            graphPoints.append(point)
        }
        
        // Drawing Layers
        drawingView = UIView(frame: viewport)
        drawingView.backgroundColor = backgroundFillColor
        self.addSubview(drawingView)
        
        addDrawingLayers(inViewport: viewport)
        
        // References Lines
        if(shouldShowReferenceLines) {
            addReferenceLines(inViewport: viewport)
        }
        
        // X-Axis Labels
        self.insertSubview(labelsView, aboveSubview: drawingView)
        
        updateOffsetWidths()
        
        // Animation loop for when the range adapts
        displayLink = CADisplayLink(target: self, selector: #selector(animationUpdate))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.paused = true
        
        isCurrentlySettingUp = false
        
        // Set the first active points interval. These are the points that are visible when the view loads.
        self.activePointsInterval = initialActivePointsInterval
    }
    
    // Makes sure everything is in a clean state for when we want to reset the data for a graph.
    private func reset() {
        drawingView.removeFromSuperview()
        referenceLineView?.removeFromSuperview()
        
        labelPool = LabelPool()
        
        for labelView in labelsView.subviews {
            labelView.removeFromSuperview()
        }
        
        graphPoints.removeAll()
        
        currentAnimations.removeAll()
        displayLink?.invalidate()
        previousTimestamp = 0
        currentTimestamp = 0
        
        previousActivePointsInterval = -1 ..< -1
        activePointsInterval = -1 ..< -1
        range = (0, 100)
    }
    
    private func addDrawingLayers(inViewport viewport: CGRect) {
        
        // Line Layer
        lineLayer = LineDrawingLayer(frame: viewport, lineWidth: lineWidth, lineColor: lineColor, lineStyle: lineStyle, lineJoin: lineJoin, lineCap: lineCap)
        lineLayer?.graphViewDrawingDelegate = self
        drawingView.layer.addSublayer(lineLayer!)
        
        // Data Point layer
        if(shouldDrawDataPoint) {
            dataPointLayer = DataPointDrawingLayer(frame: viewport, fillColor: dataPointFillColor, dataPointType: dataPointType, dataPointSize: dataPointSize, customDataPointPath: customDataPointPath)
            dataPointLayer?.graphViewDrawingDelegate = self
            drawingView.layer.insertSublayer(dataPointLayer!, above: lineLayer)
        }
        
        // Gradient and Fills
        switch (self.fillType) {
            
        case .Solid:
            if(shouldFill) {
                // Setup fill
                fillLayer = FillDrawingLayer(frame: viewport, fillColor: fillColor)
                fillLayer?.graphViewDrawingDelegate = self
                drawingView.layer.insertSublayer(fillLayer!, below: lineLayer)
            }
            
        case .Gradient:
            if(shouldFill) {
                gradientLayer = GradientDrawingLayer(frame: viewport, startColor: fillGradientStartColor, endColor: fillGradientEndColor, gradientType: fillGradientType)
                gradientLayer!.graphViewDrawingDelegate = self
                drawingView.layer.insertSublayer(gradientLayer!, below: lineLayer)
            }
        }
        
        // The bar layer
        if (shouldDrawBarLayer) {
            // Bar Layer
            barLayer = BarDrawingLayer(frame: viewport,
                                       barWidth: barWidth,
                                       barColor: barColor,
                                       barLineWidth: barLineWidth,
                                       barLineColor: barLineColor)
            barLayer?.graphViewDrawingDelegate = self
            drawingView.layer.insertSublayer (barLayer!, below: lineLayer)
        }
    }
    
    private func addReferenceLines(inViewport viewport: CGRect) {
        var referenceLineBottomMargin = bottomMargin
        if(shouldShowLabels && dataPointLabelFont != nil) {
            referenceLineBottomMargin += (dataPointLabelFont!.pointSize + dataPointLabelTopMargin + dataPointLabelBottomMargin)
        }
        
        referenceLineView = ReferenceLineDrawingView(
            frame: viewport,
            topMargin: topMargin,
            bottomMargin: referenceLineBottomMargin,
            referenceLineColor: self.referenceLineColor,
            referenceLineThickness: self.referenceLineThickness)
        
        // Reference line settings.
        referenceLineView?.referenceLinePosition = self.referenceLinePosition
        referenceLineView?.referenceLineType = self.referenceLineType
        
        referenceLineView?.numberOfIntermediateReferenceLines = self.numberOfIntermediateReferenceLines
        
        // Reference line label settings.
        referenceLineView?.shouldAddLabelsToIntermediateReferenceLines = self.shouldAddLabelsToIntermediateReferenceLines
        referenceLineView?.shouldAddUnitsToIntermediateReferenceLineLabels = self.shouldAddUnitsToIntermediateReferenceLineLabels
        
        referenceLineView?.labelUnits = referenceLineUnits
        referenceLineView?.labelFont = self.referenceLineLabelFont
        referenceLineView?.labelColor = self.referenceLineLabelColor
        referenceLineView?.labelDecimalPlaces = self.referenceLineNumberOfDecimalPlaces
        
        referenceLineView?.setRange(self.range)
        self.addSubview(referenceLineView!)
    }
    
    // If the view has changed we have to make sure we're still displaying the right data.
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        updateUI()
    }
    
    private func updateUI() {
        
        // Make sure we have data, if don't, just get out. We can't do anything without any data.
        guard data.count > 0 else {
            return
        }
        
        // If the data has been updated, we need to re-init everything
        if (dataNeedsReloading) {
            setup()
            
            if(shouldAnimateOnStartup) {
                startAnimations(withStaggerValue: 0.15)
            }
            
            // We're done setting up.
            dataNeedsReloading = false
            isInitialSetup = false
            
        }
            // Otherwise, the user is just scrolling and we just need to update everything.
        else {
            // Needs to update the viewportWidth and viewportHeight which is used to calculate which
            // points we can actually see.
            viewportWidth = self.frame.width
            viewportHeight = self.frame.height
            
            // If the scrollview has scrolled anywhere, we need to update the offset
            // and move around our drawing views.
            offsetWidth = self.contentOffset.x
            updateOffsetWidths()
            
            // Recalculate active points for this size.
            // Recalculate range for active points.
            let newActivePointsInterval = calculateActivePointsInterval()
            self.previousActivePointsInterval = self.activePointsInterval
            self.activePointsInterval = newActivePointsInterval
            
            // If adaption is enabled we want to
            if(shouldAdaptRange) {
                let newRange = calculateRangeForActivePointsInterval(newActivePointsInterval)
                self.range = newRange
            }
        }
    }
    
    private func updateOffsetWidths() {
        drawingView.frame.origin.x = offsetWidth
        drawingView.bounds.origin.x = offsetWidth
        
        gradientLayer?.offset = offsetWidth
        
        referenceLineView?.frame.origin.x = offsetWidth
    }
    
    private func updateFrames() {
        // Drawing view needs to always be the same size as the scrollview.
        drawingView.frame.size.width = viewportWidth
        drawingView.frame.size.height = viewportHeight
        
        // Gradient should extend over the entire viewport
        gradientLayer?.frame.size.width = viewportWidth
        gradientLayer?.frame.size.height = viewportHeight
        
        // Reference lines should extend over the entire viewport
        referenceLineView?.setViewport(viewportWidth, viewportHeight: viewportHeight)
        
        self.contentSize.height = viewportHeight
    }
    
    // MARK: - Public Methods
    // ######################
    
    public func setData(data: [Double], withLabels labels: [String]) {
        
        // If we are setting exactly the same data and labels, there's no need to re-init everything.
        if(self.data == data && self.labels == labels) {
            return
        }
        
        self.dataNeedsReloading = true
        self.data = data
        self.labels = labels
        
        if(!isInitialSetup) {
            updateUI()
        }
    }
    
    // MARK: - Private Methods
    // #######################
    
    // MARK: Animation
    
    // Animation update loop for co-domain changes.
    @objc private func animationUpdate() {
        let dt = timeSinceLastFrame()
        
        for animation in currentAnimations {
            
            animation.update(dt)
            
            if animation.finished {
                dequeueAnimation(animation)
            }
        }
        
        updatePaths()
    }
    
    private func animatePoint(point: GraphPoint, toPosition position: CGPoint, withDelay delay: Double = 0) {
        let currentPoint = CGPoint(x: point.x, y: point.y)
        let animation = GraphPointAnimation(fromPoint: currentPoint, toPoint: position, forGraphPoint: point)
        animation.animationEasing = getAnimationEasing()
        animation.duration = animationDuration
        animation.delay = delay
        enqueueAnimation(animation)
    }
    
    private func getAnimationEasing() -> (Double) -> Double {
        switch(self.adaptAnimationType) {
        case .Elastic:
            return Easings.EaseOutElastic
        case .EaseOut:
            return Easings.EaseOutQuad
        case .Custom:
            if let customEasing = customAnimationEasingFunction {
                return customEasing
            }
            else {
                fallthrough
            }
        default:
            return Easings.EaseOutQuad
        }
    }
    
    private func enqueueAnimation(animation: GraphPointAnimation) {
        if (currentAnimations.count == 0) {
            // Need to kick off the loop.
            displayLink.paused = false
        }
        currentAnimations.append(animation)
    }
    
    private func dequeueAnimation(animation: GraphPointAnimation) {
        if let index = currentAnimations.indexOf(animation) {
            currentAnimations.removeAtIndex(index)
        }
        
        if(currentAnimations.count == 0) {
            // Stop animation loop.
            displayLink.paused = true
        }
    }
    
    private func dequeueAllAnimations() {
        
        for animation in currentAnimations {
            animation.animationDidFinish()
        }
        
        currentAnimations.removeAll()
        displayLink.paused = true
    }
    
    private func timeSinceLastFrame() -> Double {
        if previousTimestamp == 0 {
            previousTimestamp = displayLink.timestamp
        } else {
            previousTimestamp = currentTimestamp
        }
        
        currentTimestamp = displayLink.timestamp
        
        var dt = currentTimestamp - previousTimestamp
        
        if dt > 0.032 {
            dt = 0.032
        }
        
        return dt
    }
    
    // MARK: Layout Calculations
    
    private func calculateActivePointsInterval() -> Range<Int> {
        
        // Calculate the "active points"
        let min = Int((offsetWidth) / dataPointSpacing)
        let max = Int(((offsetWidth + viewportWidth)) / dataPointSpacing)
        
        // Add and minus two so the path goes "off the screen" so we can't see where it ends.
        let minPossible = 0
        let maxPossible = data.count - 1
        
        let numberOfPointsOffscreen = 2
        
        let actualMin = clamp(min - numberOfPointsOffscreen, min: minPossible, max: maxPossible)
        let actualMax = clamp(max + numberOfPointsOffscreen, min: minPossible, max: maxPossible)
        
        return actualMin ..< actualMax
    }
    
    private func calculateRangeForActivePointsInterval(interval: Range<Int>) -> (min: Double, max: Double) {
        
        let dataForActivePoints = data[interval.startIndex...interval.endIndex]
        
        // We don't have any active points, return defaults.
        if(dataForActivePoints.count == 0) {
            return (min: self.rangeMin, max: self.rangeMax)
        }
        else {
            
            let range = calculateRange(dataForActivePoints)
            return cleanRange(range)
        }
    }
    
    private func calculateRangeForEntireDataset(data: [Double]) -> (min: Double, max: Double) {
        let range = calculateRange(self.data)
        return cleanRange(range)
    }
    
    private func calculateRange<T: CollectionType where T.Generator.Element == Double>(data: T) -> (min: Double, max: Double) {
        
        var rangeMin: Double = Double(Int.max)
        var rangeMax: Double = Double(Int.min)
        
        for dataPoint in data {
            if (dataPoint > rangeMax) {
                rangeMax = dataPoint
            }
            
            if (dataPoint < rangeMin) {
                rangeMin = dataPoint
            }
        }
        return (min: rangeMin, max: rangeMax)
    }
    
    private func cleanRange(range: (min: Double, max: Double)) -> (min: Double, max: Double){
        if(range.min == range.max) {
            
            let min = shouldRangeAlwaysStartAtZero ? 0 : range.min
            let max = range.max + 1
            
            return (min: min, max: max)
        }
        else if (shouldRangeAlwaysStartAtZero) {
            
            let min: Double = 0
            var max: Double = range.max
            
            // If we have all negative numbers and the max happens to be 0, there will cause a division by 0. Return the default height.
            if(range.max == 0) {
                max = rangeMax
            }
            
            return (min: min, max: max)
        }
        else {
            return range
        }
    }
    
    private func graphWidthForNumberOfDataPoints(numberOfPoints: Int) -> CGFloat {
        let width: CGFloat = (CGFloat(numberOfPoints - 1) * dataPointSpacing) + (leftmostPointPadding + rightmostPointPadding)
        return width
    }
    
    private func calculatePosition(index: Int, value: Double) -> CGPoint {
        
        // Set range defaults based on settings:
        
        // self.range.min/max is the current ranges min/max that has been detected
        // self.rangeMin/Max is the min/max that should be used as specified by the user
        let rangeMax = (shouldAutomaticallyDetectRange || shouldAdaptRange) ? self.range.max : self.rangeMax
        let rangeMin = (shouldAutomaticallyDetectRange || shouldAdaptRange) ? self.range.min : self.rangeMin
        
        //                                                     y = the y co-ordinate in the view for the value in the graph
        //     ( ( value - max )               )               value = the value on the graph for which we want to know its corresponding location on the y axis in the view
        // y = ( ( ----------- ) * graphHeight ) + topMargin   t = the top margin
        //     ( (  min - max  )               )               h = the height of the graph space without margins
        //                                                     min = the range's current mininum
        //                                                     max = the range's current maximum
        
        // Calculate the position on in the view for the value specified.
        var graphHeight = viewportHeight - topMargin - bottomMargin
        if(shouldShowLabels && dataPointLabelFont != nil) { graphHeight -= (dataPointLabelFont!.pointSize + dataPointLabelTopMargin + dataPointLabelBottomMargin) }
        
        let x = (CGFloat(index) * dataPointSpacing) + leftmostPointPadding
        let y = (CGFloat((value - rangeMax) / (rangeMin - rangeMax)) * graphHeight) + topMargin
        
        return CGPoint(x: x, y: y)
    }
    
    private func clamp<T: Comparable>(value:T, min:T, max:T) -> T {
        if (value < min) {
            return min
        }
        else if (value > max) {
            return max
        }
        else {
            return value
        }
    }
    
    // MARK: Line Path Creation
    
    private func createLinePath() -> UIBezierPath {
        
        currentLinePath.removeAllPoints()
        
        let numberOfPoints = min(data.count, activePointsInterval.endIndex)
        
        let pathSegmentAdder = lineStyle == .Straight ? addStraightLineSegment : addCurvedLineSegment
        
        zeroYPosition = calculatePosition(0, value: self.range.min).y
        
        // Connect the line to the starting edge if we are filling it.
        if(shouldFill) {
            // Add a line from the base of the graph to the first data point.
            let firstDataPoint = graphPoints[activePointsInterval.startIndex]
            
            let viewportLeftZero = CGPoint(x: firstDataPoint.x - (leftmostPointPadding), y: zeroYPosition)
            let leftFarEdgeTop = CGPoint(x: firstDataPoint.x - (leftmostPointPadding + viewportWidth), y: zeroYPosition)
            let leftFarEdgeBottom = CGPoint(x: firstDataPoint.x - (leftmostPointPadding + viewportWidth), y: viewportHeight)
            
            currentLinePath.moveToPoint(leftFarEdgeBottom)
            pathSegmentAdder(startPoint: leftFarEdgeBottom, endPoint: leftFarEdgeTop, inPath: currentLinePath)
            pathSegmentAdder(startPoint: leftFarEdgeTop, endPoint: viewportLeftZero, inPath: currentLinePath)
            pathSegmentAdder(startPoint: viewportLeftZero, endPoint: CGPoint(x: firstDataPoint.x, y: firstDataPoint.y), inPath: currentLinePath)
        }
        else {
            let firstDataPoint = graphPoints[activePointsInterval.startIndex]
            currentLinePath.moveToPoint(firstDataPoint.location)
        }
        
        // Connect each point on the graph with a segment.
        for i in activePointsInterval.startIndex ..< numberOfPoints {
            
            let startPoint = graphPoints[i].location
            let endPoint = graphPoints[i+1].location
            
            pathSegmentAdder(startPoint: startPoint, endPoint: endPoint, inPath: currentLinePath)
        }
        
        // Connect the line to the ending edge if we are filling it.
        if(shouldFill) {
            // Add a line from the last data point to the base of the graph.
            let lastDataPoint = graphPoints[activePointsInterval.endIndex]
            
            let viewportRightZero = CGPoint(x: lastDataPoint.x + (rightmostPointPadding), y: zeroYPosition)
            let rightFarEdgeTop = CGPoint(x: lastDataPoint.x + (rightmostPointPadding + viewportWidth), y: zeroYPosition)
            let rightFarEdgeBottom = CGPoint(x: lastDataPoint.x + (rightmostPointPadding + viewportWidth), y: viewportHeight)
            
            pathSegmentAdder(startPoint: lastDataPoint.location, endPoint: viewportRightZero, inPath: currentLinePath)
            pathSegmentAdder(startPoint: viewportRightZero, endPoint: rightFarEdgeTop, inPath: currentLinePath)
            pathSegmentAdder(startPoint: rightFarEdgeTop, endPoint: rightFarEdgeBottom, inPath: currentLinePath)
        }
        
        return currentLinePath
    }
    
    private func addStraightLineSegment(startPoint startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        path.addLineToPoint(endPoint)
    }
    
    private func addCurvedLineSegment(startPoint startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        // calculate control points
        let difference = endPoint.x - startPoint.x
        
        var x = startPoint.x + (difference * lineCurviness)
        var y = startPoint.y
        let controlPointOne = CGPoint(x: x, y: y)
        
        x = endPoint.x - (difference * lineCurviness)
        y = endPoint.y
        let controlPointTwo = CGPoint(x: x, y: y)
        
        // add curve from start to end
        currentLinePath.addCurveToPoint(endPoint, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
    }
    
    // MARK: Events
    
    // If the active points (the points we can actually see) change, then we need to update the path.
    private func activePointsDidChange() {
        
      let deactivatedPoints = determineDeactivatedPoints()
      let activatedPoints = determineActivatedPoints()
      
      updatePaths()
      if(shouldShowLabels) {
        let deactivatedLabelPoints = filterPointsForLabels(fromPoints: deactivatedPoints)
        let activatedLabelPoints = filterPointsForLabels(fromPoints: activatedPoints)
        updateLabels(deactivatedLabelPoints, activatedLabelPoints)
      }
  }
  
    private func rangeDidChange() {
        
        // If shouldAnimateOnAdapt is enabled it will kickoff any animations that need to occur.
        startAnimations()
        
        referenceLineView?.setRange(range)
    }
    
    private func viewportDidChange() {
        
        // We need to make sure all the drawing views are the same size as the viewport.
        updateFrames()
        
        // Basically this recreates the paths with the new viewport size so things are in sync, but only
        // if the viewport has changed after the initial setup. Because the initial setup will use the latest
        // viewport anyway.
        if(!isInitialSetup) {
            updatePaths()
            
            // Need to update the graph points so they are in their right positions for the new viewport.
            // Animate them into position if animation is enabled, but make sure to stop any current animations first.
            dequeueAllAnimations()
            startAnimations()
            
            // The labels will also need to be repositioned if the viewport has changed.
            repositionActiveLabels()
        }
    }
    
    // Update any paths with the new path based on visible data points.
    private func updatePaths() {
        
        createLinePath()
        
        if let drawingLayers = drawingView.layer.sublayers {
            for layer in drawingLayers {
                if let layer = layer as? ScrollableGraphViewDrawingLayer {
                    // The bar layer needs the zero Y position to set the bottom of the bar
                    layer.zeroYPosition = zeroYPosition
                    // Need to make sure this is set in createLinePath
                    assert (layer.zeroYPosition > 0);
                    layer.updatePath()
                }
            }
        }
    }
    
    // Update any labels for any new points that have been activated and deactivated.
    private func updateLabels(deactivatedPoints: [Int], _ activatedPoints: [Int]) {
        
        // Disable any labels for the deactivated points.
        for point in deactivatedPoints {
            labelPool.deactivateLabelForPointIndex(point)
        }
        
        // Grab an unused label and update it to the right position for the newly activated poitns
        for point in activatedPoints {
            let label = labelPool.activateLabelForPointIndex(point)
            
            label.text = (point < labels.count) ? labels[point] : ""
            label.textColor = dataPointLabelColor
            label.font = dataPointLabelFont
            
            label.sizeToFit()
            
            // self.range.min is the current ranges minimum that has been detected
            // self.rangeMin is the minimum that should be used as specified by the user
            let rangeMin = (shouldAutomaticallyDetectRange || shouldAdaptRange) ? self.range.min : self.rangeMin
            let position = calculatePosition(point, value: rangeMin)
            
            label.frame = CGRect(origin: CGPoint(x: position.x - label.frame.width / 2, y: position.y + dataPointLabelTopMargin), size: label.frame.size)
            
            labelsView.addSubview(label)
        }
    }
    
    private func repositionActiveLabels() {
        for label in labelPool.activeLabels {
            
            let rangeMin = (shouldAutomaticallyDetectRange || shouldAdaptRange) ? self.range.min : self.rangeMin
            let position = calculatePosition(0, value: rangeMin)
            
            label.frame.origin.y = position.y + dataPointLabelTopMargin
        }
    }
    
    // Returns the indices of any points that became inactive (that is, "off screen"). (No order)
    private func determineDeactivatedPoints() -> [Int] {
        let prevSet = setFromClosedRange(previousActivePointsInterval)
        let currSet = setFromClosedRange(activePointsInterval)
        
        let deactivatedPoints = prevSet.subtract(currSet)
        
        return Array(deactivatedPoints)
    }
    
    // Returns the indices of any points that became active (on screen). (No order)
    private func determineActivatedPoints() -> [Int] {
        let prevSet = setFromClosedRange(previousActivePointsInterval)
        let currSet = setFromClosedRange(activePointsInterval)
        
        let activatedPoints = currSet.subtract(prevSet)
        
        return Array(activatedPoints)
    }
    
    private func setFromClosedRange(range: Range<Int>) -> Set<Int> {
        var set = Set<Int>()
        for index in range.startIndex...range.endIndex {
            set.insert(index)
        }
        return set
    }
  
  private func filterPointsForLabels(fromPoints points:[Int]) -> [Int] {
    
    if(self.dataPointLabelsSparsity == 1) {
      return points
    }
    return points.filter({ $0 % self.dataPointLabelsSparsity == 0 })
  }
  
    private func startAnimations(withStaggerValue stagger: Double = 0) {
        
        var pointsToAnimate = 0 ..< 0
        
        if (shouldAnimateOnAdapt || (dataNeedsReloading && shouldAnimateOnStartup)) {
            pointsToAnimate = activePointsInterval
        }
        
        // For any visible points, kickoff the animation to their new position after the axis' min/max has changed.
        //let numberOfPointsToAnimate = pointsToAnimate.endIndex - pointsToAnimate.startIndex
        var index = 0
        for i in pointsToAnimate.startIndex ... pointsToAnimate.endIndex {
            let newPosition = calculatePosition(i, value: data[i])
            let point = graphPoints[i]
            animatePoint(point, toPosition: newPosition, withDelay: Double(index) * stagger)
            index += 1
        }
        
        // Update any non-visible & non-animating points so they come on to screen at the right scale.
        for i in 0 ..< graphPoints.count {
            if(i > pointsToAnimate.startIndex && i < pointsToAnimate.endIndex || graphPoints[i].currentlyAnimatingToPosition) {
                continue
            }
            
            let newPosition = calculatePosition(i, value: data[i])
            graphPoints[i].x = newPosition.x
            graphPoints[i].y = newPosition.y
        }
    }
    
    // MARK: - Drawing Delegate
    private func currentPath() -> UIBezierPath {
        return currentLinePath
    }
    
    private func intervalForActivePoints() -> Range<Int> {
        return activePointsInterval
    }
    
    private func rangeForActivePoints() -> (min: Double, max: Double) {
        return range
    }
    
    private func dataForGraph() -> [Double] {
        return data
    }
    
    private func graphPointForIndex(index: Int) -> GraphPoint {
        return graphPoints[index]
    }
}

// MARK: - LabelPool
private class LabelPool {
    
    var labels = [UILabel]()
    var relations = [Int : Int]()
    var unused = [Int]()
    
    func deactivateLabelForPointIndex(pointIndex: Int){
        
        if let unusedLabelIndex = relations[pointIndex] {
            unused.append(unusedLabelIndex)
        }
        relations[pointIndex] = nil
    }
    
    func activateLabelForPointIndex(pointIndex: Int) -> UILabel {
        var label: UILabel
        
        if(unused.count >= 1) {
            let unusedLabelIndex = unused.first!
            unused.removeFirst()
            
            label = labels[unusedLabelIndex]
            relations[pointIndex] = unusedLabelIndex
        }
        else {
            label = UILabel()
            labels.append(label)
            let newLabelIndex = labels.indexOf(label)!
            relations[pointIndex] = newLabelIndex
        }
        
        return label
    }
    
    var activeLabels: [UILabel] {
        get {
            
            var currentlyActive = [UILabel]()
            let numberOfLabels = labels.count
            
            for i in 0 ..< numberOfLabels {
                if(!unused.contains(i)) {
                    currentlyActive.append(labels[i])
                }
            }
            return currentlyActive
        }
    }
}


// MARK: - GraphPoints and Animation Classes
private class GraphPoint {
    
    var location = CGPoint(x: 0, y: 0)
    var currentlyAnimatingToPosition = false
    
    private var x: CGFloat {
        get {
            return location.x
        }
        set {
            location.x = newValue
        }
    }
    
    private var y: CGFloat {
        get {
            return location.y
        }
        set {
            location.y = newValue
        }
    }
    
    init(position: CGPoint = CGPointZero) {
        x = position.x
        y = position.y
    }
}

private class GraphPointAnimation : Equatable {
    
    // Public Properties
    var animationEasing = Easings.EaseOutQuad
    var duration: Double = 1
    var delay: Double = 0
    private(set) var finished = false
    private(set) var animationKey: String
    
    // Private State
    private var startingPoint: CGPoint
    private var endingPoint: CGPoint
    
    private var elapsedTime: Double = 0
    private var graphPoint: GraphPoint?
    private var multiplier: Double = 1
    
    static private var animationsCreated = 0
    
    init(fromPoint: CGPoint, toPoint: CGPoint, forGraphPoint graphPoint: GraphPoint, forKey key: String = "animation\(animationsCreated)") {
        self.startingPoint = fromPoint
        self.endingPoint = toPoint
        self.animationKey = key
        self.graphPoint = graphPoint
        self.graphPoint?.currentlyAnimatingToPosition = true
        
        GraphPointAnimation.animationsCreated += 1
    }
    
    func update(dt: Double) {
        
        if(!finished) {
            
            if elapsedTime > delay {
                
                let animationElapsedTime = elapsedTime - delay
                
                let changeInX = endingPoint.x - startingPoint.x
                let changeInY = endingPoint.y - startingPoint.y
                
                // t is in the range of 0 to 1, indicates how far through the animation it is.
                let t = animationElapsedTime / duration
                let interpolation = animationEasing(t)
                
                let x = startingPoint.x + changeInX * CGFloat(interpolation)
                let y = startingPoint.y + changeInY * CGFloat(interpolation)
                
                if(animationElapsedTime >= duration) {
                    animationDidFinish()
                }
                
                graphPoint?.x = CGFloat(x)
                graphPoint?.y = CGFloat(y)
                
                elapsedTime += dt * multiplier
            }
                // Keep going until we are passed the delay
            else {
                elapsedTime += dt * multiplier
            }
        }
    }
    
    func animationDidFinish() {
        self.graphPoint?.currentlyAnimatingToPosition = false
        self.finished = true
    }
}

private func ==(lhs: GraphPointAnimation, rhs: GraphPointAnimation) -> Bool {
    return lhs.animationKey == rhs.animationKey
}


// MARK: - Drawing Layers

// MARK: Delegate definition that provides the data required by the drawing layers.
private protocol ScrollableGraphViewDrawingDelegate {
    func intervalForActivePoints() -> Range<Int>
    func rangeForActivePoints() -> (min: Double, max: Double)
    func dataForGraph() -> [Double]
    func graphPointForIndex(index: Int) -> GraphPoint
    
    func currentPath() -> UIBezierPath
}

// MARK: Drawing Layer Classes

// MARK: Base Class
private class ScrollableGraphViewDrawingLayer : CAShapeLayer {
    
    var offset: CGFloat = 0 {
        didSet {
            offsetDidChange()
        }
    }
    
    var viewportWidth: CGFloat = 0
    var viewportHeight: CGFloat = 0
    var zeroYPosition: CGFloat = 0
    
    var graphViewDrawingDelegate: ScrollableGraphViewDrawingDelegate? = nil
    
    var active = true
    
    init(viewportWidth: CGFloat, viewportHeight: CGFloat, offset: CGFloat = 0) {
        super.init()
        
        self.viewportWidth = viewportWidth
        self.viewportHeight = viewportHeight
        
        self.frame = CGRect(origin: CGPoint(x: offset, y: 0), size: CGSize(width: self.viewportWidth, height: self.viewportHeight))
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Get rid of any animations.
        self.actions = ["position" : NSNull(), "bounds" : NSNull()]
    }
    
    private func offsetDidChange() {
        self.frame.origin.x = offset
        self.bounds.origin.x = offset
    }
    
    func updatePath() {
        fatalError("updatePath needs to be implemented by the subclass")
    }
}

// MARK: Drawing the bars
private class BarDrawingLayer: ScrollableGraphViewDrawingLayer {
    
    private var barPath = UIBezierPath()
    private var barWidth: CGFloat = 4
    
    init(frame: CGRect, barWidth: CGFloat, barColor: UIColor, barLineWidth: CGFloat, barLineColor: UIColor) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.barWidth = barWidth
        self.lineWidth = barLineWidth
        self.strokeColor = barLineColor.CGColor
        self.fillColor = barColor.CGColor
        
        self.lineJoin = lineJoin
        self.lineCap = lineCap
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createBarPath(centre: CGPoint) -> UIBezierPath {
        
        let squarePath = UIBezierPath()
        
        squarePath.moveToPoint(centre)
        let barWidthOffset: CGFloat = self.barWidth / 2
        
        let topLeft = CGPoint(x: centre.x - barWidthOffset, y: centre.y)
        let topRight = CGPoint(x: centre.x + barWidthOffset, y: centre.y)
        let bottomLeft = CGPoint(x: centre.x - barWidthOffset, y: zeroYPosition)
        let bottomRight = CGPoint(x: centre.x + barWidthOffset, y: zeroYPosition)
        
        squarePath.moveToPoint(topLeft)
        squarePath.addLineToPoint(topRight)
        squarePath.addLineToPoint(bottomRight)
        squarePath.addLineToPoint(bottomLeft)
        squarePath.addLineToPoint(topLeft)
        
        return squarePath
    }
    
    private func createPath () -> UIBezierPath {
        
        barPath.removeAllPoints()
        
        // We can only move forward if we can get the data we need from the delegate.
        guard let
            activePointsInterval = self.graphViewDrawingDelegate?.intervalForActivePoints(),
            data = self.graphViewDrawingDelegate?.dataForGraph()
            else {
                return barPath
        }
        
        let numberOfPoints = min(data.count, activePointsInterval.endIndex)
        
        for i in activePointsInterval.startIndex ... numberOfPoints {
            
            var location = CGPointZero
            
            if let pointLocation = self.graphViewDrawingDelegate?.graphPointForIndex(i).location {
                location = pointLocation
            }
            
            let pointPath = createBarPath(location)
            barPath.appendPath(pointPath)
        }
        
        return barPath
    }
    
    override func updatePath() {
        
        self.path = createPath ().CGPath
    }
    
}

// MARK: Drawing the Graph Line
private class LineDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    init(frame: CGRect, lineWidth: CGFloat, lineColor: UIColor, lineStyle: ScrollableGraphViewLineStyle, lineJoin: String, lineCap: String) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.lineWidth = lineWidth
        self.strokeColor = lineColor.CGColor
        
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        
        // Setup
        self.fillColor = UIColor.clearColor().CGColor // This is handled by the fill drawing layer.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updatePath() {
        self.path = graphViewDrawingDelegate?.currentPath().CGPath
    }
}

// MARK: Drawing the Individual Data Points
private class DataPointDrawingLayer: ScrollableGraphViewDrawingLayer {
    
    private var dataPointPath = UIBezierPath()
    private var dataPointSize: CGFloat = 5
    private var dataPointType: ScrollableGraphViewDataPointType = .Circle
    
    private var customDataPointPath: ((centre: CGPoint) -> UIBezierPath)?
    
    init(frame: CGRect, fillColor: UIColor, dataPointType: ScrollableGraphViewDataPointType, dataPointSize: CGFloat, customDataPointPath: ((centre: CGPoint) -> UIBezierPath)? = nil) {
        
        self.dataPointType = dataPointType
        self.dataPointSize = dataPointSize
        self.customDataPointPath = customDataPointPath
        
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.fillColor = fillColor.CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createDataPointPath() -> UIBezierPath {
        
        dataPointPath.removeAllPoints()
        
        // We can only move forward if we can get the data we need from the delegate.
        guard let
            activePointsInterval = self.graphViewDrawingDelegate?.intervalForActivePoints(),
            data = self.graphViewDrawingDelegate?.dataForGraph()
            else {
                return dataPointPath
        }
        
        let pointPathCreator = getPointPathCreator()
        let numberOfPoints = min(data.count, activePointsInterval.endIndex)
        
        for i in activePointsInterval.startIndex ... numberOfPoints {
            
            var location = CGPointZero
            
            if let pointLocation = self.graphViewDrawingDelegate?.graphPointForIndex(i).location {
                location = pointLocation
            }
            
            let pointPath = pointPathCreator(centre: location)
            dataPointPath.appendPath(pointPath)
        }
        
        return dataPointPath
    }
    
    private func createCircleDataPoint(centre: CGPoint) -> UIBezierPath {
        return UIBezierPath(arcCenter: centre, radius: dataPointSize, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
    }
    
    private func createSquareDataPoint(centre: CGPoint) -> UIBezierPath {
        
        let squarePath = UIBezierPath()
        
        squarePath.moveToPoint(centre)
        
        let topLeft = CGPoint(x: centre.x - dataPointSize, y: centre.y - dataPointSize)
        let topRight = CGPoint(x: centre.x + dataPointSize, y: centre.y - dataPointSize)
        let bottomLeft = CGPoint(x: centre.x - dataPointSize, y: centre.y + dataPointSize)
        let bottomRight = CGPoint(x: centre.x + dataPointSize, y: centre.y + dataPointSize)
        
        squarePath.moveToPoint(topLeft)
        squarePath.addLineToPoint(topRight)
        squarePath.addLineToPoint(bottomRight)
        squarePath.addLineToPoint(bottomLeft)
        squarePath.addLineToPoint(topLeft)
        
        return squarePath
    }
    
    private func getPointPathCreator() -> (centre: CGPoint) -> UIBezierPath {
        switch(self.dataPointType) {
        case .Circle:
            return createCircleDataPoint
        case .Square:
            return createSquareDataPoint
        case .Custom:
            if let customCreator = self.customDataPointPath {
                return customCreator
            }
            else {
                // We don't have a custom path, so just return the default.
                fallthrough
            }
        default:
            return createCircleDataPoint
        }
    }
    
    override func updatePath() {
        self.path = createDataPointPath().CGPath
    }
}

// MARK: Drawing the Graph Gradient Fill
private class GradientDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    private var startColor: UIColor
    private var endColor: UIColor
    private var gradientType: ScrollableGraphViewGradientType
    
    lazy private var gradientMask: CAShapeLayer = ({
        let mask = CAShapeLayer()
        
        mask.frame = CGRect(x: 0, y: 0, width: self.viewportWidth, height: self.viewportHeight)
        mask.fillRule = kCAFillRuleEvenOdd
        mask.path = self.graphViewDrawingDelegate?.currentPath().CGPath
        mask.lineJoin = self.lineJoin
        
        return mask
    })()
    
    init(frame: CGRect, startColor: UIColor, endColor: UIColor, gradientType: ScrollableGraphViewGradientType, lineJoin: String = kCALineJoinRound) {
        self.startColor = startColor
        self.endColor = endColor
        self.gradientType = gradientType
        //self.lineJoin = lineJoin
        
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        addMaskLayer()
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMaskLayer() {
        self.mask = gradientMask
    }
    
    override func updatePath() {
        gradientMask.path = graphViewDrawingDelegate?.currentPath().CGPath
    }
    
    override func drawInContext(ctx: CGContext) {
        
        let colors = [startColor.CGColor, endColor.CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        let displacement = ((viewportWidth / viewportHeight) / 2.5) * self.bounds.height
        let topCentre = CGPoint(x: offset + self.bounds.width / 2, y: -displacement)
        let bottomCentre = CGPoint(x: offset + self.bounds.width / 2, y: self.bounds.height)
        let startRadius: CGFloat = 0
        let endRadius: CGFloat = self.bounds.width
        
        switch(gradientType) {
        case .Linear:
            CGContextDrawLinearGradient(ctx, gradient, topCentre, bottomCentre, .DrawsAfterEndLocation)
        case .Radial:
            CGContextDrawRadialGradient(ctx, gradient, topCentre, startRadius, topCentre, endRadius, .DrawsAfterEndLocation)
        }
    }
}

// MARK: Drawing the Graph Fill
private class FillDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    init(frame: CGRect, fillColor: UIColor) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        self.fillColor = fillColor.CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updatePath() {
        self.path = graphViewDrawingDelegate?.currentPath().CGPath
    }
}


// MARK: - Reference Lines
private class ReferenceLineDrawingView : UIView {
    
    // PUBLIC PROPERTIES
    
    // Reference line settings.
    var referenceLineColor: UIColor = UIColor.blackColor()
    var referenceLineThickness: CGFloat = 0.5
    var referenceLinePosition = ScrollableGraphViewReferenceLinePosition.Left
    var referenceLineType = ScrollableGraphViewReferenceLineType.Cover
    
    var numberOfIntermediateReferenceLines = 3 // Number of reference lines between the min and max line.
    
    // Reference line label settings.
    var shouldAddLabelsToIntermediateReferenceLines: Bool = true
    var shouldAddUnitsToIntermediateReferenceLineLabels: Bool = false
    
    var labelUnits: String?
    var labelFont: UIFont = UIFont.systemFontOfSize(8)
    var labelColor: UIColor = UIColor.blackColor()
    var labelDecimalPlaces: Int = 2
    
    // PRIVATE PROPERTIES
    
    private var intermediateLineWidthMultiplier: CGFloat = 1 //FUTURE: Can make the intermediate lines shorter using this.
    private var referenceLineWidth: CGFloat = 100 // FUTURE: Used when referenceLineType == .Edge
    
    private var labelMargin: CGFloat = 4
    private var leftLabelInset: CGFloat = 10
    private var rightLabelInset: CGFloat = 10
    
    // Store information about the ScrollableGraphView
    private var currentRange: (min: Double, max: Double) = (0,100)
    private var topMargin: CGFloat = 10
    private var bottomMargin: CGFloat = 10
    
    // Partition recursion depth // FUTURE: For .Edge
    // private var referenceLinePartitions: Int = 3
    
    private var lineWidth: CGFloat {
        get {
            if(self.referenceLineType == ScrollableGraphViewReferenceLineType.Cover) {
                return self.bounds.width
            }
            else {
                return referenceLineWidth
            }
        }
    }
    
    private var units: String {
        get {
            if let units = self.labelUnits {
                return " \(units)"
            } else {
                return ""
            }
        }
    }
    
    // Layers
    private var labels = [UILabel]()
    private let referenceLineLayer = CAShapeLayer()
    private let referenceLinePath = UIBezierPath()
    
    init(frame: CGRect, topMargin: CGFloat, bottomMargin: CGFloat, referenceLineColor: UIColor, referenceLineThickness: CGFloat) {
        super.init(frame: frame)
        
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        
        // The reference line layer draws the reference lines and we handle the labels elsewhere.
        self.referenceLineLayer.frame = self.frame
        self.referenceLineLayer.strokeColor = referenceLineColor.CGColor
        self.referenceLineLayer.lineWidth = referenceLineThickness
        
        self.layer.addSublayer(referenceLineLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLabelAtPosition(position: CGPoint, withText text: String) -> UILabel {
        let frame = CGRect(x: position.x, y: position.y, width: 0, height: 0)
        let label = UILabel(frame: frame)
        
        return label
    }
    
    private func createReferenceLinesPath() -> UIBezierPath {
        
        referenceLinePath.removeAllPoints()
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        let maxLineStart = CGPoint(x: 0, y: topMargin)
        let maxLineEnd = CGPoint(x: lineWidth, y: topMargin)
        
        let minLineStart = CGPoint(x: 0, y: self.bounds.height - bottomMargin)
        let minLineEnd = CGPoint(x: lineWidth, y: self.bounds.height - bottomMargin)
        
        let maxString = String(format: "%.\(labelDecimalPlaces)f", arguments: [self.currentRange.max]) + units
        let minString = String(format: "%.\(labelDecimalPlaces)f", arguments: [self.currentRange.min]) + units
        
        addLineWithTag(maxString, from: maxLineStart, to: maxLineEnd, inPath: referenceLinePath)
        addLineWithTag(minString, from: minLineStart, to: minLineEnd, inPath: referenceLinePath)
        
        let initialRect = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + topMargin, width: self.bounds.size.width, height: self.bounds.size.height - (topMargin + bottomMargin))
        
        createIntermediateReferenceLines(initialRect, numberOfIntermediateReferenceLines: self.numberOfIntermediateReferenceLines, forPath: referenceLinePath)
        
        return referenceLinePath
    }
    
    private func createIntermediateReferenceLines(rect: CGRect, numberOfIntermediateReferenceLines: Int, forPath path: UIBezierPath) {
        
        let height = rect.size.height
        let spacePerPartition = height / CGFloat(numberOfIntermediateReferenceLines + 1)
        
        for i in 0 ..< numberOfIntermediateReferenceLines {
            
            let lineStart = CGPoint(x: 0, y: rect.origin.y + (spacePerPartition * CGFloat(i + 1)))
            let lineEnd = CGPoint(x: lineStart.x + lineWidth * intermediateLineWidthMultiplier, y: lineStart.y)
            
            createReferenceLineFrom(from: lineStart, to: lineEnd, inPath: path)
        }
    }
    
    // FUTURE: Can use the recursive version to create a ruler like look on the edge.
    private func recursiveCreateIntermediateReferenceLines(rect: CGRect, width: CGFloat, forPath path: UIBezierPath, remainingPartitions: Int) -> UIBezierPath {
        
        if(remainingPartitions <= 0) {
            return path
        }
        
        let lineStart = CGPoint(x: 0, y: rect.origin.y + (rect.size.height / 2))
        let lineEnd = CGPoint(x: lineStart.x + width, y: lineStart.y)
        
        createReferenceLineFrom(from: lineStart, to: lineEnd, inPath: path)
        
        let topRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height / 2)
        
        let bottomRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y + (rect.size.height / 2),
            width: rect.size.width,
            height: rect.size.height / 2)
        
        recursiveCreateIntermediateReferenceLines(topRect, width: width * intermediateLineWidthMultiplier, forPath: path, remainingPartitions: remainingPartitions - 1)
        recursiveCreateIntermediateReferenceLines(bottomRect, width: width * intermediateLineWidthMultiplier, forPath: path, remainingPartitions: remainingPartitions - 1)
        
        return path
    }
    
    private func createReferenceLineFrom(from lineStart: CGPoint, to lineEnd: CGPoint, inPath path: UIBezierPath) {
        if(shouldAddLabelsToIntermediateReferenceLines) {
            
            let value = calculateYAxisValueForPoint(lineStart)
            var valueString = String(format: "%.\(labelDecimalPlaces)f", arguments: [value])
            
            if(shouldAddUnitsToIntermediateReferenceLineLabels) {
                valueString += " \(units)"
            }
            
            addLineWithTag(valueString, from: lineStart, to: lineEnd, inPath: path)
            
        } else {
            addLineFrom(lineStart, to: lineEnd, inPath: path)
        }
    }
    
    private func addLineWithTag(tag: String, from: CGPoint, to: CGPoint, inPath path: UIBezierPath) {
        
        let boundingSize = boundingSizeForText(tag)
        let leftLabel = createLabelWithText(tag)
        let rightLabel = createLabelWithText(tag)
        
        // Left label gap.
        leftLabel.frame = CGRect(
            origin: CGPoint(x: from.x + leftLabelInset, y: from.y - (boundingSize.height / 2)),
            size: boundingSize)
        
        let leftLabelStart = CGPoint(x: leftLabel.frame.origin.x - labelMargin, y: to.y)
        let leftLabelEnd = CGPoint(x: (leftLabel.frame.origin.x + leftLabel.frame.size.width) + labelMargin, y: to.y)
        
        // Right label gap.
        rightLabel.frame = CGRect(
            origin: CGPoint(x: (from.x + self.frame.width) - rightLabelInset - boundingSize.width, y: from.y - (boundingSize.height / 2)),
            size: boundingSize)
        
        let rightLabelStart = CGPoint(x: rightLabel.frame.origin.x - labelMargin, y: to.y)
        let rightLabelEnd = CGPoint(x: (rightLabel.frame.origin.x + rightLabel.frame.size.width) + labelMargin, y: to.y)
        
        // Add the lines and tags depending on the settings for where we want them.
        var gaps = [(start: CGFloat, end: CGFloat)]()
        
        switch(self.referenceLinePosition) {
            
        case .Left:
            gaps.append((start: leftLabelStart.x, end: leftLabelEnd.x))
            self.addSubview(leftLabel)
            self.labels.append(leftLabel)
            
        case .Right:
            gaps.append((start: rightLabelStart.x, end: rightLabelEnd.x))
            self.addSubview(rightLabel)
            self.labels.append(rightLabel)
            
        case .Both:
            gaps.append((start: leftLabelStart.x, end: leftLabelEnd.x))
            gaps.append((start: rightLabelStart.x, end: rightLabelEnd.x))
            self.addSubview(leftLabel)
            self.addSubview(rightLabel)
            self.labels.append(leftLabel)
            self.labels.append(rightLabel)
        }
        
        addLineWithGaps(from, to: to, withGaps: gaps, inPath: path)
    }
    
    private func addLineWithGaps(from: CGPoint, to: CGPoint, withGaps gaps: [(start: CGFloat, end: CGFloat)], inPath path: UIBezierPath) {
        
        // If there are no gaps, just add a single line.
        if(gaps.count <= 0) {
            addLineFrom(from, to: to, inPath: path)
        }
            // If there is only 1 gap, it's just two lines.
        else if (gaps.count == 1) {
            
            let gapLeft = CGPoint(x: gaps.first!.start, y: from.y)
            let gapRight = CGPoint(x: gaps.first!.end, y: from.y)
            
            addLineFrom(from, to: gapLeft, inPath: path)
            addLineFrom(gapRight, to: to, inPath: path)
        }
            // If there are many gaps, we have a series of intermediate lines.
        else {
            
            let firstGap = gaps.first!
            let lastGap = gaps.last!
            
            let firstGapLeft = CGPoint(x: firstGap.start, y: from.y)
            let lastGapRight = CGPoint(x: lastGap.end, y: to.y)
            
            // Add the first line to the start of the first gap
            addLineFrom(from, to: firstGapLeft, inPath: path)
            
            // Add lines between all intermediate gaps
            for i in 0 ..< gaps.count - 1 {
                
                let startGapEnd = gaps[i].end
                let endGapStart = gaps[i + 1].start
                
                let lineStart = CGPoint(x: startGapEnd, y: from.y)
                let lineEnd = CGPoint(x: endGapStart, y: from.y)
                
                addLineFrom(lineStart, to: lineEnd, inPath: path)
            }
            
            // Add the final line to the end
            addLineFrom(lastGapRight, to: to, inPath: path)
        }
    }
    
    private func addLineFrom(from: CGPoint, to: CGPoint, inPath path: UIBezierPath) {
        path.moveToPoint(from)
        path.addLineToPoint(to)
    }
    
    private func boundingSizeForText(text: String) -> CGSize {
        return (text as NSString).sizeWithAttributes([NSFontAttributeName:labelFont])
    }
    
    private func calculateYAxisValueForPoint(point: CGPoint) -> Double {
        
        let graphHeight = self.frame.size.height - (topMargin + bottomMargin)
        
        //                                          value = the corresponding value on the graph for any y co-ordinate in the view
        //           y - t                          y = the y co-ordinate in the view for which we want to know the corresponding value on the graph
        // value = --------- * (min - max) + max    t = the top margin
        //             h                            h = the height of the graph space without margins
        //                                          min = the range's current mininum
        //                                          max = the range's current maximum
        
        var value = (((point.y - topMargin) / (graphHeight)) * CGFloat((self.currentRange.min - self.currentRange.max))) + CGFloat(self.currentRange.max)
        
        // Sometimes results in "negative zero"
        if(value == 0) {
            value = 0
        }
        
        return Double(value)
    }
    
    private func createLabelWithText(text: String) -> UILabel {
        let label = UILabel()
        
        label.text = text
        label.textColor = labelColor
        label.font = labelFont
        
        return label
    }
    
    // Public functions to update the reference lines with any changes to the range and viewport (phone rotation, etc).
    // When the range changes, need to update the max for the new range, then update all the labels that are showing for the axis and redraw the reference lines.
    func setRange(range: (min: Double, max: Double)) {
        self.currentRange = range
        self.referenceLineLayer.path = createReferenceLinesPath().CGPath
    }
    
    func setViewport(viewportWidth: CGFloat, viewportHeight: CGFloat) {
        self.frame.size.width = viewportWidth
        self.frame.size.height = viewportHeight
        self.referenceLineLayer.path = createReferenceLinesPath().CGPath
    }
}

// MARK: - ScrollableGraphView Settings Enums

@objc public enum ScrollableGraphViewLineStyle : Int {
    case Straight
    case Smooth
}

@objc public enum ScrollableGraphViewFillType : Int {
    case Solid
    case Gradient
}

@objc public enum ScrollableGraphViewGradientType : Int {
    case Linear
    case Radial
}

@objc public enum ScrollableGraphViewDataPointType : Int {
    case Circle
    case Square
    case Custom
}

@objc public enum ScrollableGraphViewReferenceLinePosition : Int {
    case Left
    case Right
    case Both
}

@objc public enum ScrollableGraphViewReferenceLineType : Int {
    case Cover
    //case Edge // FUTURE: Implement
}

@objc public enum ScrollableGraphViewAnimationType : Int {
    case EaseOut
    case Elastic
    case Custom
}

@objc public enum ScrollableGraphViewDirection : Int {
    case LeftToRight
    case RightToLeft
}

// Simplified easing functions from: http://www.joshondesign.com/2013/03/01/improvedEasingEquations
private struct Easings {
    
    static let EaseInQuad =  { (t:Double) -> Double in  return t*t; }
    static let EaseOutQuad = { (t:Double) -> Double in  return 1 - Easings.EaseInQuad(1-t); }
    
    static let EaseOutElastic = { (t: Double) -> Double in
        var p = 0.3;
        return pow(2,-10*t) * sin((t-p/4)*(2*M_PI)/p) + 1;
    }
}
