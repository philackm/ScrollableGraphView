
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
    /// The type of reference lines. Currently only .Cover is available.
    open var referenceLineType = ScrollableGraphViewReferenceLineType.cover
    
    /// How many reference lines should be between the minimum and maximum reference lines. If you want a total of 4 reference lines, you would set this to 2. This can be set to 0 for no intermediate reference lines.This can be used to create reference lines at specific intervals. If the desired result is to have a reference line at every 10 units on the y-axis, you could, for example, set rangeMax to 100, rangeMin to 0 and numberOfIntermediateReferenceLines to 9.
    @IBInspectable open var numberOfIntermediateReferenceLines: Int = 3
    
    @IBInspectable open var positionType = ReferenceLinePositionType.relative
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
}

public enum ReferenceLinePositionType {
    case relative
    case absolute
}
