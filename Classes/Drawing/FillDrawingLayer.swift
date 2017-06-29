
import UIKit

internal class FillDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    // Fills are only used with lineplots and we need
    // to know what the line looks like.
    private var lineDrawingLayer: LineDrawingLayer
    
    init(frame: CGRect, fillColor: UIColor, lineDrawingLayer: LineDrawingLayer) {
        
        self.lineDrawingLayer = lineDrawingLayer
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        self.fillColor = fillColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updatePath() {
        self.path = lineDrawingLayer.createLinePath().cgPath
    }
}
