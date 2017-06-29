
import UIKit

internal class LineDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    init(frame: CGRect, lineWidth: CGFloat, lineColor: UIColor, lineStyle: ScrollableGraphViewLineStyle, lineJoin: String, lineCap: String) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.lineWidth = lineWidth
        self.strokeColor = lineColor.cgColor
        
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        
        // Setup
        self.fillColor = UIColor.clear.cgColor // This is handled by the fill drawing layer.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updatePath() {
        self.path = graphViewDrawingDelegate?.currentPath().cgPath
    }
}
