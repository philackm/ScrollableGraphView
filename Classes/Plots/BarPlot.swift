
import UIKit

open class BarPlot : Plot {
    
    // Customisation
    // #############
    
    /// The width of an individual bar on the graph.
    @IBInspectable open var barWidth: CGFloat = 25;
    /// The actual colour of the bar.
    @IBInspectable open var barColor: UIColor = UIColor.gray
    /// The width of the outline of the bar
    @IBInspectable open var barLineWidth: CGFloat = 1
    /// The colour of the bar outline
    @IBInspectable open var barLineColor: UIColor = UIColor.darkGray
    /// Whether the bars should be drawn with rounded corners
    @IBInspectable open var shouldRoundBarCorners: Bool = false
    
    // Private State
    // #############
    
    private var barLayer: BarDrawingLayer?
    
    init(identifier: String) {
        super.init()
        self.identifier = identifier
    }
    
    override func layers(forViewport viewport: CGRect) -> [ScrollableGraphViewDrawingLayer?] {
        createLayers(viewport: viewport)
        return [barLayer]
    }
    
    private func createLayers(viewport: CGRect) {
        barLayer = BarDrawingLayer(
            frame: viewport,
            barWidth: barWidth,
            barColor: barColor,
            barLineWidth: barLineWidth,
            barLineColor: barLineColor,
            shouldRoundCorners: shouldRoundBarCorners)

        barLayer?.owner = self
    }
}
