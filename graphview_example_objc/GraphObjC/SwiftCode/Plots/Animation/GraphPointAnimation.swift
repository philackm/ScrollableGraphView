import UIKit

internal class GraphPointAnimation : Equatable {
    
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

// Simplified easing functions from: http://www.joshondesign.com/2013/03/01/improvedEasingEquations
internal struct Easings {
    
    static let easeInQuad =  { (t:Double) -> Double in  return t*t; }
    static let easeOutQuad = { (t:Double) -> Double in  return 1 - Easings.easeInQuad(1-t); }
    
    static let easeOutElastic = { (t: Double) -> Double in
        var p = 0.3;
        return pow(2,-10*t) * sin((t-p/4)*(2*Double.pi)/p) + 1;
    }
}
