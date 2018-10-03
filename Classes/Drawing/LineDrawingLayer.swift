
import UIKit

internal class LineDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    private var currentLinePath = UIBezierPath()
    
    private var lineStyle: ScrollableGraphViewLineStyle
    private var shouldFill: Bool
    private var lineCurviness: CGFloat
    
    init(frame: CGRect, lineWidth: CGFloat, lineColor: UIColor, lineStyle: ScrollableGraphViewLineStyle, lineJoin: String, lineCap: String, shouldFill: Bool, lineCurviness: CGFloat) {
        
        self.lineStyle = lineStyle
        self.shouldFill = shouldFill
        self.lineCurviness = lineCurviness
        
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.lineWidth = lineWidth
        self.strokeColor = lineColor.cgColor
        
        self.lineJoin = convertToCAShapeLayerLineJoin(lineJoin)
        self.lineCap = convertToCAShapeLayerLineCap(lineCap)
        
        // Setup
        self.fillColor = UIColor.clear.cgColor // This is handled by the fill drawing layer.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createLinePath() -> UIBezierPath {
        
        guard let owner = owner else {
            return UIBezierPath()
        }
        
        // Can't really do anything without the delegate.
        guard let delegate = self.owner?.graphViewDrawingDelegate else {
            return currentLinePath
        }
        
        currentLinePath.removeAllPoints()
        
        let pathSegmentAdder = lineStyle == .straight ? addStraightLineSegment : addCurvedLineSegment
        
        let activePointsInterval = delegate.intervalForActivePoints()
        
        let pointPadding = delegate.paddingForPoints()
        
        let min = delegate.rangeForActivePoints().min
        zeroYPosition = delegate.calculatePosition(atIndex: 0, value: min).y
        
        let viewport = delegate.currentViewport()
        let viewportWidth = viewport.width
        let viewportHeight = viewport.height
        
        // Connect the line to the starting edge if we are filling it.
        if(shouldFill) {
            // Add a line from the base of the graph to the first data point.
            let firstDataPoint = owner.graphPoint(forIndex: activePointsInterval.lowerBound)
            
            let viewportLeftZero = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding), y: zeroYPosition)
            let leftFarEdgeTop = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding + viewportWidth), y: zeroYPosition)
            let leftFarEdgeBottom = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding + viewportWidth), y: viewportHeight)
            
            currentLinePath.move(to: leftFarEdgeBottom)
            pathSegmentAdder(leftFarEdgeBottom, leftFarEdgeTop, currentLinePath)
            pathSegmentAdder(leftFarEdgeTop, viewportLeftZero, currentLinePath)
            pathSegmentAdder(viewportLeftZero, CGPoint(x: firstDataPoint.location.x, y: firstDataPoint.location.y), currentLinePath)
        }
        else {
            let firstDataPoint = owner.graphPoint(forIndex: activePointsInterval.lowerBound)
            currentLinePath.move(to: firstDataPoint.location)
        }
        
        // Connect each point on the graph with a segment.
        for i in activePointsInterval.lowerBound ..< activePointsInterval.upperBound - 1 {
            
            let startPoint = owner.graphPoint(forIndex: i).location
            let endPoint = owner.graphPoint(forIndex: i+1).location
            
            pathSegmentAdder(startPoint, endPoint, currentLinePath)
        }
        
        // Connect the line to the ending edge if we are filling it.
        if(shouldFill) {
            // Add a line from the last data point to the base of the graph.
            let lastDataPoint = owner.graphPoint(forIndex: activePointsInterval.upperBound - 1).location
            
            let viewportRightZero = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding), y: zeroYPosition)
            let rightFarEdgeTop = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding + viewportWidth), y: zeroYPosition)
            let rightFarEdgeBottom = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding + viewportWidth), y: viewportHeight)
            
            pathSegmentAdder(lastDataPoint, viewportRightZero, currentLinePath)
            pathSegmentAdder(viewportRightZero, rightFarEdgeTop, currentLinePath)
            pathSegmentAdder(rightFarEdgeTop, rightFarEdgeBottom, currentLinePath)
        }
        
        return currentLinePath
    }
    
    private func addStraightLineSegment(startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        path.addLine(to: endPoint)
    }
    
    private func addCurvedLineSegment(startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        // calculate control points
        let difference = endPoint.x - startPoint.x
        
        var x = startPoint.x + (difference * lineCurviness)
        var y = startPoint.y
        let controlPointOne = CGPoint(x: x, y: y)
        
        x = endPoint.x - (difference * lineCurviness)
        y = endPoint.y
        let controlPointTwo = CGPoint(x: x, y: y)
        
        // add curve from start to end
        currentLinePath.addCurve(to: endPoint, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
    }
    
    override func updatePath() {
        self.path = createLinePath().cgPath
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineJoin(_ input: String) -> CAShapeLayerLineJoin {
	return CAShapeLayerLineJoin(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}
