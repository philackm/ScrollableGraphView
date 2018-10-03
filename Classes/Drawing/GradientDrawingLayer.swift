
import UIKit

internal class GradientDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    private var startColor: UIColor
    private var endColor: UIColor
    private var gradientType: ScrollableGraphViewGradientType
    
    // Gradient fills are only used with lineplots and we need 
    // to know what the line looks like.
    private var lineDrawingLayer: LineDrawingLayer
    
    lazy private var gradientMask: CAShapeLayer = ({
        let mask = CAShapeLayer()
        
        mask.frame = CGRect(x: 0, y: 0, width: self.viewportWidth, height: self.viewportHeight)
        mask.fillRule = CAShapeLayerFillRule.evenOdd
        mask.lineJoin = self.lineJoin
        
        return mask
    })()
    
    init(frame: CGRect, startColor: UIColor, endColor: UIColor, gradientType: ScrollableGraphViewGradientType, lineJoin: String = convertFromCAShapeLayerLineJoin(CAShapeLayerLineJoin.round), lineDrawingLayer: LineDrawingLayer) {
        self.startColor = startColor
        self.endColor = endColor
        self.gradientType = gradientType
        //self.lineJoin = lineJoin
        
        self.lineDrawingLayer = lineDrawingLayer
        
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
        gradientMask.path = lineDrawingLayer.createLinePath().cgPath
    }
    
    override func draw(in ctx: CGContext) {
        
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        
        let displacement = ((viewportWidth / viewportHeight) / 2.5) * self.bounds.height
        let topCentre = CGPoint(x: offset + self.bounds.width / 2, y: -displacement)
        let bottomCentre = CGPoint(x: offset + self.bounds.width / 2, y: self.bounds.height)
        let startRadius: CGFloat = 0
        let endRadius: CGFloat = self.bounds.width
        
        switch(gradientType) {
        case .linear:
            ctx.drawLinearGradient(gradient!, start: topCentre, end: bottomCentre, options: .drawsAfterEndLocation)
        case .radial:
            ctx.drawRadialGradient(gradient!, startCenter: topCentre, startRadius: startRadius, endCenter: topCentre, endRadius: endRadius, options: .drawsAfterEndLocation)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineJoin(_ input: CAShapeLayerLineJoin) -> String {
	return input.rawValue
}
