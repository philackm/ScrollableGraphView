import UIKit

// MARK: - ScrollableGraphView
@IBDesignable
@objc open class ScrollableGraphView: UIScrollView, UIScrollViewDelegate, ScrollableGraphViewDrawingDelegate {
    
    // MARK: - Public Properties
    // Use these to customise the graph.
    // #################################

    // Fill Styles
    // ###########
    
    /// The background colour for the entire graph view, not just the plotted graph.
    @IBInspectable open var backgroundFillColor: UIColor = UIColor.white
    
    // Spacing
    // #######
    
    /// How far the "maximum" reference line is from the top of the view's frame. In points.
    @IBInspectable open var topMargin: CGFloat = 10
    /// How far the "minimum" reference line is from the bottom of the view's frame. In points.
    @IBInspectable open var bottomMargin: CGFloat = 10
    /// How far the first point on the graph should be placed from the left hand side of the view.
    @IBInspectable open var leftmostPointPadding: CGFloat = 50
    /// How far the final point on the graph should be placed from the right hand side of the view.
    @IBInspectable open var rightmostPointPadding: CGFloat = 50
    /// How much space should be between each data point.
    @IBInspectable open var dataPointSpacing: CGFloat = 40
    
    @IBInspectable var direction_: Int {
        get { return direction.rawValue }
        set {
            if let enumValue = ScrollableGraphViewDirection(rawValue: newValue) {
                direction = enumValue
            }
        }
    }
    /// Which side of the graph the user is expected to scroll from.
    open var direction = ScrollableGraphViewDirection.leftToRight
    
    // Graph Range
    // ###########
    
    /// If this is set to true, then the range will automatically be detected from the data the graph is given.
    @IBInspectable open var shouldAutomaticallyDetectRange: Bool = false
    /// Forces the graph's minimum to always be zero. Used in conjunction with shouldAutomaticallyDetectRange or shouldAdaptRange, if you want to force the minimum to stay at 0 rather than the detected minimum.
    @IBInspectable open var shouldRangeAlwaysStartAtZero: Bool = false // Used in conjunction with shouldAutomaticallyDetectRange, if you want to force the min to stay at 0.
    /// The minimum value for the y-axis. This is ignored when shouldAutomaticallyDetectRange or shouldAdaptRange = true
    @IBInspectable open var rangeMin: Double = 0
    /// The maximum value for the y-axis. This is ignored when shouldAutomaticallyDetectRange or shouldAdaptRange = true
    @IBInspectable open var rangeMax: Double = 100
    
    // Adapting & Animations
    // #####################
    
    /// Whether or not the y-axis' range should adapt to the points that are visible on screen. This means if there are only 5 points visible on screen at any given time, the maximum on the y-axis will be the maximum of those 5 points. This is updated automatically as the user scrolls along the graph.
    @IBInspectable open var shouldAdaptRange: Bool = false
    /// If shouldAdaptRange is set to true then this specifies whether or not the points on the graph should animate to their new positions. Default is set to true.
    @IBInspectable open var shouldAnimateOnAdapt: Bool = true
    /// How long the animation should take. Affects both the startup animation and the animation when the range of the y-axis adapts to onscreen points.
    @IBInspectable open var animationDuration: Double = 1
    
    @IBInspectable var adaptAnimationType_: Int {
        get { return adaptAnimationType.rawValue }
        set {
            if let enumValue = ScrollableGraphViewAnimationType(rawValue: newValue) {
                adaptAnimationType = enumValue
            }
        }
    }
    /// The animation style.
    open var adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
    /// If adaptAnimationType is set to .Custom, then this is the easing function you would like applied for the animation.
    open var customAnimationEasingFunction: ((_ t: Double) -> Double)?
    /// Whether or not the graph should animate to their positions when the graph is first displayed.
    @IBInspectable open var shouldAnimateOnStartup: Bool = true
    
    // Data Point Labels
    // #################
    
    /// Whether or not to show the labels on the x-axis for each point.
    @IBInspectable open var shouldShowLabels: Bool = true
    /// How far from the "minimum" reference line the data point labels should be rendered.
    @IBInspectable open var dataPointLabelTopMargin: CGFloat = 10
    /// How far from the bottom of the view the data point labels should be rendered.
    @IBInspectable open var dataPointLabelBottomMargin: CGFloat = 0
    /// The font for the data point labels.
    @IBInspectable open var dataPointLabelColor: UIColor = UIColor.black
    /// The colour for the data point labels.
    open var dataPointLabelFont: UIFont? = UIFont.systemFont(ofSize: 10)
    /// Used to force the graph to show every n-th dataPoint label
    @IBInspectable open var dataPointLabelsSparsity: Int = 1
    
    // Reference Line Settings
    // #######################
    
    var referenceLines: ReferenceLines? = nil
    
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
    private var zeroYPosition: CGFloat = 0
    
    // Labels
    private var labelsView = UIView()
    private var labelPool = LabelPool()
    
    // Graph Drawing
    private var graphPoints = [GraphPoint]()
    private var drawingView = UIView()
    
    private var plots: [Plot] = [Plot]()
    
    // Reference Lines
    private var referenceLineView: ReferenceLineDrawingView?
    
    // Animation
    private var displayLink: CADisplayLink!
    private var previousTimestamp: CFTimeInterval = 0
    private var currentTimestamp: CFTimeInterval = 0
    
    private var currentAnimations = [GraphPointAnimation]()
    
    // Active Points & Range Calculation
    
    private var previousActivePointsInterval: CountableRange<Int> = -1 ..< -1
    private var activePointsInterval: CountableRange<Int> = -1 ..< -1 {
        didSet {
            if(oldValue.lowerBound != activePointsInterval.lowerBound || oldValue.upperBound != activePointsInterval.upperBound) {
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
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        set(data: [10, 2, 34, 11, 22, 11, 44, 9, 12, 4], withLabels: ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"])
    }
    
    private func setup() {
        
        isCurrentlySettingUp = true
        
        // Make sure everything is in a clean state.
        reset()
        
        // Calculate the viewport and drawing frames.
        self.viewportWidth = self.frame.width
        self.viewportHeight = self.frame.height
        
        totalGraphWidth = graphWidth(forNumberOfDataPoints: data.count)
        self.contentSize = CGSize(width: totalGraphWidth, height: viewportHeight)
        
        // Scrolling direction.
        #if TARGET_INTERFACE_BUILDER
            self.offsetWidth = 0
        #else
        if (direction == .rightToLeft) {
            self.offsetWidth = self.contentSize.width - viewportWidth
        }
            // Otherwise start of all the way to the left.
        else {
            self.offsetWidth = 0
        }
        #endif
        
        // Set the scrollview offset.
        self.contentOffset.x = self.offsetWidth
        
        // Calculate the initial range depending on settings.
        let initialActivePointsInterval = calculateActivePointsInterval()
        let detectedRange = calculateRange(forEntireDataset: self.data)
        
        if(shouldAutomaticallyDetectRange) {
            self.range = detectedRange
        }
        else {
            self.range = (min: rangeMin, max: rangeMax)
        }
        
        if (shouldAdaptRange) { // This supercedes the shouldAutomaticallyDetectRange option
            let range = calculateRange(forActivePointsInterval: initialActivePointsInterval)
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
            #if TARGET_INTERFACE_BUILDER
            let value = data[i]
            #else
            let value = (shouldAnimateOnStartup) ? self.range.min : data[i]
            #endif
            
            let position = calculatePosition(atIndex: i, value: value)
            let point = GraphPoint(position: position)
            graphPoints.append(point)
        }
        
        // Drawing Layers
        drawingView = UIView(frame: viewport)
        drawingView.backgroundColor = backgroundFillColor
        self.addSubview(drawingView)
        
        //addDrawingLayers(inViewport: viewport)
        addDrawingLayersForPlots(inViewport: viewport)
        
        // References Lines
        if(referenceLines != nil) {
            addReferenceViewDrawingView()
        }
        
        // X-Axis Labels
        self.insertSubview(labelsView, aboveSubview: drawingView)
        
        updateOffsetWidths()
        
        #if !TARGET_INTERFACE_BUILDER
        // Animation loop for when the range adapts
        displayLink = CADisplayLink(target: self, selector: #selector(animationUpdate))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        displayLink.isPaused = true
        #endif
        
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
    
    // TODO: Plot layer ordering.
    private func addDrawingLayersForPlots(inViewport viewport: CGRect) {
        
        for plot in plots {
            switch(plot) {
            case let plot as LinePlot:
                addSubLayers(layers: plot.layers(forViewport: viewport))
            case let plot as DotPlot:
                addSubLayers(layers: plot.layers(forViewport: viewport))
            case let plot as BarPlot:
                addSubLayers(layers: plot.layers(forViewport: viewport))
            default:
                print("not a concrete plot")
            }
        }
    }
    
    private func addSubLayers(layers: [ScrollableGraphViewDrawingLayer?]) {
        for layer in layers {
            if let layer = layer {
                layer.graphViewDrawingDelegate = self
                drawingView.layer.addSublayer(layer)
            }
        }
    }
    
    private func addReferenceViewDrawingView() {
        
        guard let referenceLines = self.referenceLines else {
            // We can only add this if the settings arent nil.
            return
        }
        
        let viewport = CGRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight)
        var referenceLineBottomMargin = bottomMargin
        
        // Have to adjust the bottom line if we are showing data point labels (x-axis).
        if(shouldShowLabels && dataPointLabelFont != nil) {
            referenceLineBottomMargin += (dataPointLabelFont!.pointSize + dataPointLabelTopMargin + dataPointLabelBottomMargin)
        }
        
        referenceLineView = ReferenceLineDrawingView(
            frame: viewport,
            topMargin: topMargin,
            bottomMargin: referenceLineBottomMargin,
            referenceLineColor: referenceLines.referenceLineColor,
            referenceLineThickness: referenceLines.referenceLineThickness,
            referenceLineSettings: referenceLines)
        
        referenceLineView?.set(range: self.range)
        
        self.addSubview(referenceLineView!)
    }
    
    // If the view has changed we have to make sure we're still displaying the right data.
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // while putting the view on the IB, we may get calls with frame too small
        // if frame height is too small we won't be able to calculate zeroYPosition
        // so make sure to proceed only if there is enough space
        var availableGraphHeight = frame.height
        availableGraphHeight = availableGraphHeight - topMargin - bottomMargin
        
        if(shouldShowLabels && dataPointLabelFont != nil) { availableGraphHeight -= (dataPointLabelFont!.pointSize + dataPointLabelTopMargin + dataPointLabelBottomMargin) }
        
        if availableGraphHeight > 0 {
            updateUI()
        }
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
                let newRange = calculateRange(forActivePointsInterval: newActivePointsInterval)
                self.range = newRange
            }
        }
    }
    
    private func updateOffsetWidths() {
        drawingView.frame.origin.x = offsetWidth
        drawingView.bounds.origin.x = offsetWidth
        
        updateOffsetsForGradients(offsetWidth: offsetWidth)
        //gradientLayer?.offset = offsetWidth
        
        referenceLineView?.frame.origin.x = offsetWidth
    }
    
    private func updateOffsetsForGradients(offsetWidth: CGFloat) {
        guard let sublayers = drawingView.layer.sublayers else {
            return
        }
        
        for layer in sublayers {
            switch(layer) {
            case let layer as GradientDrawingLayer:
                layer.offset = offsetWidth
            default: break
            }
        }
    }
    
    private func updateFrames() {
        // Drawing view needs to always be the same size as the scrollview.
        drawingView.frame.size.width = viewportWidth
        drawingView.frame.size.height = viewportHeight
        
        // Gradient should extend over the entire viewport
        updateFramesForGradientLayers(viewportWidth: viewportWidth, viewportHeight: viewportHeight)
        // gradientLayer?.frame.size.width = viewportWidth
        // gradientLayer?.frame.size.height = viewportHeight
        
        // Reference lines should extend over the entire viewport
        referenceLineView?.set(viewportWidth: viewportWidth, viewportHeight: viewportHeight)
        
        self.contentSize.height = viewportHeight
    }
    
    private func updateFramesForGradientLayers(viewportWidth: CGFloat, viewportHeight: CGFloat) {
        
        guard let sublayers = drawingView.layer.sublayers else {
            return
        }
        
        for layer in sublayers {
            switch(layer) {
            case let layer as GradientDrawingLayer:
                layer.frame.size.width = viewportWidth
                layer.frame.size.height = viewportHeight
            default: break
            }
        }
    }
    
    // MARK: - Public Methods
    // ######################
    
    open func set(data: [Double], withLabels labels: [String]) {
        
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
    
    public func addPlot(plot: Plot) {
        self.plots.append(plot)
    }
    
    public func addReferenceLines(referenceLines: ReferenceLines) {
        self.referenceLines = referenceLines
    }
    
    // MARK: - Private Methods
    // #######################
    
    // MARK: Animation
    // ###############
    
    // Animation update loop for co-domain changes.
    @objc private func animationUpdate() {
        let dt = timeSinceLastFrame()
        
        for animation in currentAnimations {
            
            animation.update(withTimestamp: dt)
            
            if animation.finished {
                dequeue(animation: animation)
            }
        }
        
        updatePaths()
    }
    
    private func animate(point: GraphPoint, to position: CGPoint, withDelay delay: Double = 0) {
        let currentPoint = CGPoint(x: point.x, y: point.y)
        let animation = GraphPointAnimation(fromPoint: currentPoint, toPoint: position, forGraphPoint: point)
        animation.animationEasing = getAnimationEasing()
        animation.duration = animationDuration
        animation.delay = delay
        enqueue(animation: animation)
    }
    
    private func getAnimationEasing() -> (Double) -> Double {
        switch(self.adaptAnimationType) {
        case .elastic:
            return Easings.easeOutElastic
        case .easeOut:
            return Easings.easeOutQuad
        case .custom:
            if let customEasing = customAnimationEasingFunction {
                return customEasing
            }
            else {
                fallthrough
            }
        default:
            return Easings.easeOutQuad
        }
    }
    
    private func enqueue(animation: GraphPointAnimation) {
        if (currentAnimations.count == 0) {
            // Need to kick off the loop.
            displayLink.isPaused = false
        }
        currentAnimations.append(animation)
    }
    
    private func dequeue(animation: GraphPointAnimation) {
        if let index = currentAnimations.index(of: animation) {
            currentAnimations.remove(at: index)
        }
        
        if(currentAnimations.count == 0) {
            // Stop animation loop.
            displayLink.isPaused = true
        }
    }
    
    private func dequeueAllAnimations() {
        
        for animation in currentAnimations {
            animation.animationDidFinish()
        }
        
        currentAnimations.removeAll()
        displayLink.isPaused = true
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
    // #########################
    
    private func calculateActivePointsInterval() -> CountableRange<Int> {
        
        // Calculate the "active points"
        let min = Int((offsetWidth) / dataPointSpacing)
        let max = Int(((offsetWidth + viewportWidth)) / dataPointSpacing)
        
        // Add and minus two so the path goes "off the screen" so we can't see where it ends.
        let minPossible = 0
        let maxPossible = data.count - 1
        
        let numberOfPointsOffscreen = 2
        
        let actualMin = clamp(value: min - numberOfPointsOffscreen, min: minPossible, max: maxPossible)
        let actualMax = clamp(value: max + numberOfPointsOffscreen, min: minPossible, max: maxPossible)
        
        return actualMin..<actualMax.advanced(by: 1)
    }
    
    private func calculateRange(forActivePointsInterval interval: CountableRange<Int>) -> (min: Double, max: Double) {
        
        let dataForActivePoints = data[interval]
        
        // We don't have any active points, return defaults.
        if(dataForActivePoints.count == 0) {
            return (min: self.rangeMin, max: self.rangeMax)
        }
        else {
            
            let range = calculateRange(for: dataForActivePoints)
            return clean(range: range)
        }
    }
    
    private func calculateRange(forEntireDataset data: [Double]) -> (min: Double, max: Double) {
        let range = calculateRange(for: self.data)
        return clean(range: range)
    }
    
    private func calculateRange<T: Collection>(for data: T) -> (min: Double, max: Double) where T.Iterator.Element == Double {
        
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
    
    private func clean(range: (min: Double, max: Double)) -> (min: Double, max: Double){
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
    
    private func graphWidth(forNumberOfDataPoints numberOfPoints: Int) -> CGFloat {
        let width: CGFloat = (CGFloat(numberOfPoints - 1) * dataPointSpacing) + (leftmostPointPadding + rightmostPointPadding)
        return width
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
    
    // MARK: Events
    // ############
    
    // If the active points (the points we can actually see) change, then we need to update the path.
    private func activePointsDidChange() {
        
      let deactivatedPoints = determineDeactivatedPoints()
      let activatedPoints = determineActivatedPoints()
      
      updatePaths()
      if(shouldShowLabels) {
        let deactivatedLabelPoints = filterPointsForLabels(fromPoints: deactivatedPoints)
        let activatedLabelPoints = filterPointsForLabels(fromPoints: activatedPoints)
        updateLabels(deactivatedPoints: deactivatedLabelPoints, activatedPoints: activatedLabelPoints)
      }
  }
  
    private func rangeDidChange() {
        
        // If shouldAnimateOnAdapt is enabled it will kickoff any animations that need to occur.
        startAnimations()
        
        referenceLineView?.set(range: range)
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
            #if !TARGET_INTERFACE_BUILDER
                dequeueAllAnimations()
            #endif
            startAnimations()
            
            // The labels will also need to be repositioned if the viewport has changed.
            repositionActiveLabels()
        }
    }
    
    // Update any paths with the new path based on visible data points.
    private func updatePaths() {
        
        zeroYPosition = calculatePosition(atIndex: 0, value: self.range.min).y
        
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
    private func updateLabels(deactivatedPoints: [Int], activatedPoints: [Int]) {
        
        // Disable any labels for the deactivated points.
        for point in deactivatedPoints {
            labelPool.activateLabel(forPointIndex: point)
        }
        
        // Grab an unused label and update it to the right position for the newly activated poitns
        for point in activatedPoints {
            let label = labelPool.activateLabel(forPointIndex: point)
            
            label.text = (point < labels.count) ? labels[point] : ""
            label.textColor = dataPointLabelColor
            label.font = dataPointLabelFont
            
            label.sizeToFit()
            
            // self.range.min is the current ranges minimum that has been detected
            // self.rangeMin is the minimum that should be used as specified by the user
            let rangeMin = (shouldAutomaticallyDetectRange || shouldAdaptRange) ? self.range.min : self.rangeMin
            let position = calculatePosition(atIndex: point, value: rangeMin)
            
            label.frame = CGRect(origin: CGPoint(x: position.x - label.frame.width / 2, y: position.y + dataPointLabelTopMargin), size: label.frame.size)
            
            let _ = labelsView.subviews.filter { $0.frame == label.frame }.map { $0.removeFromSuperview() }

            labelsView.addSubview(label)
        }
    }
    
    private func repositionActiveLabels() {
        for label in labelPool.activeLabels {
            
            let rangeMin = (shouldAutomaticallyDetectRange || shouldAdaptRange) ? self.range.min : self.rangeMin
            let position = calculatePosition(atIndex: 0, value: rangeMin)
            
            label.frame.origin.y = position.y + dataPointLabelTopMargin
        }
    }
    
    // Returns the indices of any points that became inactive (that is, "off screen"). (No order)
    private func determineDeactivatedPoints() -> [Int] {
        let prevSet = Set(previousActivePointsInterval)
        let currSet = Set(activePointsInterval)
        
        let deactivatedPoints = prevSet.subtracting(currSet)
        
        return Array(deactivatedPoints)
    }
    
    // Returns the indices of any points that became active (on screen). (No order)
    private func determineActivatedPoints() -> [Int] {
        let prevSet = Set(previousActivePointsInterval)
        let currSet = Set(activePointsInterval)
        
        let activatedPoints = currSet.subtracting(prevSet)
        
        return Array(activatedPoints)
    }
  
    private func filterPointsForLabels(fromPoints points:[Int]) -> [Int] {
        
        if(self.dataPointLabelsSparsity == 1) {
            return points
        }
        return points.filter({ $0 % self.dataPointLabelsSparsity == 0 })
    }
  
    private func startAnimations(withStaggerValue stagger: Double = 0) {
        
        var pointsToAnimate = 0 ..< 0
        
        #if !TARGET_INTERFACE_BUILDER
        if (shouldAnimateOnAdapt || (dataNeedsReloading && shouldAnimateOnStartup)) {
            pointsToAnimate = activePointsInterval
        }
        #endif
        
        // For any visible points, kickoff the animation to their new position after the axis' min/max has changed.
        //let numberOfPointsToAnimate = pointsToAnimate.endIndex - pointsToAnimate.startIndex
        var index = 0
        for i in pointsToAnimate {
            let newPosition = calculatePosition(atIndex: i, value: data[i])
            let point = graphPoints[i]
            animate(point: point, to: newPosition, withDelay: Double(index) * stagger)
            index += 1
        }
        
        // Update any non-visible & non-animating points so they come on to screen at the right scale.
        for i in 0 ..< graphPoints.count {
            if(i > pointsToAnimate.lowerBound && i < pointsToAnimate.upperBound || graphPoints[i].currentlyAnimatingToPosition) {
                continue
            }
            
            let newPosition = calculatePosition(atIndex: i, value: data[i])
            graphPoints[i].x = newPosition.x
            graphPoints[i].y = newPosition.y
        }
    }
    
    // MARK: - Drawing Delegate
    // ########################
    
    internal func calculatePosition(atIndex index: Int, value: Double) -> CGPoint {
        
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
    
    internal func intervalForActivePoints() -> CountableRange<Int> {
        return activePointsInterval
    }
    
    internal func rangeForActivePoints() -> (min: Double, max: Double) {
        return range
    }
    
    internal func graphPoint(forIndex index: Int) -> GraphPoint {
        return graphPoints[index]
    }
    
    internal func currentViewport() -> CGRect {
        return CGRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight)
    }
}

// MARK: - LabelPool
// #################

private class LabelPool {
    
    var labels = [UILabel]()
    var relations = [Int : Int]()
    var unused = [Int]()
    
    func deactivateLabel(forPointIndex pointIndex: Int){
        
        if let unusedLabelIndex = relations[pointIndex] {
            unused.append(unusedLabelIndex)
        }
        relations[pointIndex] = nil
    }
    
    @discardableResult
    func activateLabel(forPointIndex pointIndex: Int) -> UILabel {
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
            let newLabelIndex = labels.index(of: label)!
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
// #########################################

internal class GraphPoint {
    
    var location = CGPoint(x: 0, y: 0)
    var currentlyAnimatingToPosition = false
    
    fileprivate var x: CGFloat {
        get {
            return location.x
        }
        set {
            location.x = newValue
        }
    }
    
    fileprivate var y: CGFloat {
        get {
            return location.y
        }
        set {
            location.y = newValue
        }
    }
    
    init(position: CGPoint = CGPoint.zero) {
        x = position.x
        y = position.y
    }
}

private class GraphPointAnimation : Equatable {
    
    // Public Properties
    var animationEasing = Easings.easeOutQuad
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
    
    func update(withTimestamp dt: Double) {
        
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
    
    static func ==(lhs: GraphPointAnimation, rhs: GraphPointAnimation) -> Bool {
        return lhs.animationKey == rhs.animationKey
    }
}

// MARK: - ScrollableGraphView Settings Enums
// ##########################################

@objc public enum ScrollableGraphViewLineStyle : Int {
    case straight
    case smooth
}

@objc public enum ScrollableGraphViewFillType : Int {
    case solid
    case gradient
}

@objc public enum ScrollableGraphViewGradientType : Int {
    case linear
    case radial
}

@objc public enum ScrollableGraphViewDataPointType : Int {
    case circle
    case square
    case custom
}

@objc public enum ScrollableGraphViewReferenceLinePosition : Int {
    case left
    case right
    case both
}

@objc public enum ScrollableGraphViewReferenceLineType : Int {
    case cover
    //case Edge // FUTURE: Implement
}

@objc public enum ScrollableGraphViewAnimationType : Int {
    case easeOut
    case elastic
    case custom
}

@objc public enum ScrollableGraphViewDirection : Int {
    case leftToRight
    case rightToLeft
}

// Simplified easing functions from: http://www.joshondesign.com/2013/03/01/improvedEasingEquations
private struct Easings {
    
    static let easeInQuad =  { (t:Double) -> Double in  return t*t; }
    static let easeOutQuad = { (t:Double) -> Double in  return 1 - Easings.easeInQuad(1-t); }
    
    static let easeOutElastic = { (t: Double) -> Double in
        var p = 0.3;
        return pow(2,-10*t) * sin((t-p/4)*(2*Double.pi)/p) + 1;
    }
}
