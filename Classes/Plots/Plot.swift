
import UIKit

open class Plot {
    
    // The id for this plot. Used when determining which data to give it in the dataSource
    var identifier: String!
    
    var graphViewDrawingDelegate: ScrollableGraphViewDrawingDelegate! = nil
    
    // Animation Settings
    // ##################
    
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
    
    // Private Animation State
    // #######################
    
    private var currentAnimations = [GraphPointAnimation]()
    private var displayLink: CADisplayLink!
    private var previousTimestamp: CFTimeInterval = 0
    private var currentTimestamp: CFTimeInterval = 0
    
    private var graphPoints = [GraphPoint]()
    
    // Initialisation
    // ##############
    
    init() {

    }
    
    // MARK: Plot Animation
    // ####################
    
    // Animation update loop for co-domain changes.
    @objc private func animationUpdate() {
        let dt = timeSinceLastFrame()
        
        for animation in currentAnimations {
            
            animation.update(withTimestamp: dt)
            
            if animation.finished {
                dequeue(animation: animation)
            }
        }
        
        graphViewDrawingDelegate.updatePaths()
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
    
    internal func dequeueAllAnimations() {
        
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
    
    public func startAnimations(forPoints pointsToAnimate: CountableRange<Int>, withData data: [Double], withStaggerValue stagger: Double) {
        
        // For any visible points, kickoff the animation to their new position after the axis' min/max has changed.
        //let numberOfPointsToAnimate = pointsToAnimate.endIndex - pointsToAnimate.startIndex
        var index = 0
        for i in pointsToAnimate {
            let newPosition = graphViewDrawingDelegate.calculatePosition(atIndex: i, value: data[i])
            let point = graphPoints[i]
            animate(point: point, to: newPosition, withDelay: Double(index) * stagger)
            index += 1
        }
        
        // Update any non-visible & non-animating points so they come on to screen at the right scale.
        for i in 0 ..< graphPoints.count {
            if(i > pointsToAnimate.lowerBound && i < pointsToAnimate.upperBound || graphPoints[i].currentlyAnimatingToPosition) {
                continue
            }
            
            let newPosition = graphViewDrawingDelegate.calculatePosition(atIndex: i, value: data[i])
            graphPoints[i].x = newPosition.x
            graphPoints[i].y = newPosition.y
        }
    }
    
    public func createGraphPoints(data: [Double], shouldAnimateOnStartup: Bool, range: (min: Double, max: Double)) {
        for i in 0 ..< data.count {

            let value = (shouldAnimateOnStartup) ? range.min : data[i]
            
            let position = graphViewDrawingDelegate.calculatePosition(atIndex: i, value: value)
            let point = GraphPoint(position: position)
            graphPoints.append(point)
        }
    }
    
    public func setup() {
        displayLink = CADisplayLink(target: self, selector: #selector(animationUpdate))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        displayLink.isPaused = true
    }
    
    public func reset() {
        currentAnimations.removeAll()
        graphPoints.removeAll()
        displayLink?.invalidate()
        previousTimestamp = 0
        currentTimestamp = 0
    }
    
    internal func graphPoint(forIndex index: Int) -> GraphPoint {
        return graphPoints[index]
    }
}










