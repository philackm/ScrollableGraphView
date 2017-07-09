
import UIKit

// MARK: Drawing the bars
internal class BarDrawingLayer: ScrollableGraphViewDrawingLayer {
    
    private var barPath = UIBezierPath()
    private var barWidth: CGFloat = 4
    private var shouldRoundCorners = false
    
    init(frame: CGRect, barWidth: CGFloat, barColor: UIColor, barLineWidth: CGFloat, barLineColor: UIColor, shouldRoundCorners: Bool) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.barWidth = barWidth
        self.lineWidth = barLineWidth
        self.strokeColor = barLineColor.cgColor
        self.fillColor = barColor.cgColor
        self.shouldRoundCorners = shouldRoundCorners
        
        self.lineJoin = lineJoin
        self.lineCap = lineCap
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createBarPath(centre: CGPoint) -> UIBezierPath {
        
        let barWidthOffset: CGFloat = self.barWidth / 2
        
        let origin = CGPoint(x: centre.x - barWidthOffset, y: centre.y)
        let size = CGSize(width: barWidth, height: zeroYPosition - centre.y)
        let rect = CGRect(origin: origin, size: size)
        
        let barPath: UIBezierPath = {
            if shouldRoundCorners {
                return UIBezierPath(roundedRect: rect, cornerRadius: barWidthOffset)
            } else {
                return UIBezierPath(rect: rect)
            }
        }()
        
        return barPath
    }
    
    private func createPath () -> UIBezierPath {
        
        barPath.removeAllPoints()
        
        // We can only move forward if we can get the data we need from the delegate.
        guard let
            activePointsInterval = self.owner?.graphViewDrawingDelegate?.intervalForActivePoints()
            else {
                return barPath
        }
        
        for i in activePointsInterval {
            
            var location = CGPoint.zero
            
            if let pointLocation = owner?.graphPoint(forIndex: i).location {
                location = pointLocation
            }
            
            let pointPath = createBarPath(centre: location)
            barPath.append(pointPath)
        }
        
        return barPath
    }
    
    override func updatePath() {
        
        self.path = createPath ().cgPath
    }
}
