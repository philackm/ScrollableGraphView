
import UIKit

internal class FillDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    init(frame: CGRect, fillColor: UIColor) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        self.fillColor = fillColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updatePath() {
        self.path = graphViewDrawingDelegate?.currentPath().cgPath
    }
}
