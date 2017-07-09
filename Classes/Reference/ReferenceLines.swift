
import UIKit

// Currently just a simple data structure to hold the settings for the reference lines.
open class ReferenceLines {
    
    // Reference Lines
    // ###############
    
    /// Whether or not to show the y-axis reference lines and labels.
    @IBInspectable open var shouldShowReferenceLines: Bool = true
    /// The colour for the reference lines.
    @IBInspectable open var referenceLineColor: UIColor = UIColor.black
    /// The thickness of the reference lines.
    @IBInspectable open var referenceLineThickness: CGFloat = 0.5
    
    @IBInspectable var referenceLinePosition_: Int {
        get { return referenceLinePosition.rawValue }
        set {
            if let enumValue = ScrollableGraphViewReferenceLinePosition(rawValue: newValue) {
                referenceLinePosition = enumValue
            }
        }
    }
    /// Where the labels should be displayed on the reference lines.
    open var referenceLinePosition = ScrollableGraphViewReferenceLinePosition.left
    
    @IBInspectable open var positionType = ReferenceLinePositioningType.relative
    @IBInspectable open var relativePositions: [Double] = [0.25, 0.5, 0.75]
    @IBInspectable open var absolutePositions: [Double] = [25, 50, 75]
    @IBInspectable open var includeMinMax: Bool = true
    
    /// Whether or not to add labels to the intermediate reference lines.
    @IBInspectable open var shouldAddLabelsToIntermediateReferenceLines: Bool = true
    /// Whether or not to add units specified by the referenceLineUnits variable to the labels on the intermediate reference lines.
    @IBInspectable open var shouldAddUnitsToIntermediateReferenceLineLabels: Bool = false
    
    // Reference Line Labels
    // #####################
    
    /// The font to be used for the reference line labels.
    open var referenceLineLabelFont = UIFont.systemFont(ofSize: 8)
    /// The colour of the reference line labels.
    @IBInspectable open var referenceLineLabelColor: UIColor = UIColor.black
    
    /// Whether or not to show the units on the reference lines.
    @IBInspectable open var shouldShowReferenceLineUnits: Bool = true
    /// The units that the y-axis is in. This string is used for labels on the reference lines.
    @IBInspectable open var referenceLineUnits: String?
    /// The number of decimal places that should be shown on the reference line labels.
    @IBInspectable open var referenceLineNumberOfDecimalPlaces: Int = 0
    /// The NSNumberFormatterStyle that reference lines should use to display
    @IBInspectable open var referenceLineNumberStyle: NumberFormatter.Style = .none
    
    // Data Point Labels // TODO: Refactor these into their own settings and allow for more label options (positioning)
    // ################################################################################################################
    
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
    
    public init() {
        // Need this for external frameworks.
    }
}


@objc public enum ScrollableGraphViewReferenceLinePosition : Int {
    case left
    case right
    case both
}

@objc public enum ReferenceLinePositioningType : Int {
    case relative
    case absolute
}

@objc public enum ScrollableGraphViewReferenceLineType : Int {
    case cover
}
