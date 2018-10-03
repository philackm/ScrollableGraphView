
import UIKit

internal class ReferenceLineDrawingView : UIView {
    
    var settings: ReferenceLines = ReferenceLines()
    
    // PRIVATE PROPERTIES
    // ##################
    
    private var labelMargin: CGFloat = 4
    private var leftLabelInset: CGFloat = 10
    private var rightLabelInset: CGFloat = 10
    
    // Store information about the ScrollableGraphView
    private var currentRange: (min: Double, max: Double) = (0,100)
    private var topMargin: CGFloat = 10
    private var bottomMargin: CGFloat = 10
    
    private var lineWidth: CGFloat {
        get {
            return self.bounds.width
        }
    }
    
    private var units: String {
        get {
            if let units = self.settings.referenceLineUnits {
                return " \(units)"
            } else {
                return ""
            }
        }
    }
    
    // Layers
    private var labels = [UILabel]()
    private let referenceLineLayer = CAShapeLayer()
    private let referenceLinePath = UIBezierPath()
    
    init(frame: CGRect, topMargin: CGFloat, bottomMargin: CGFloat, referenceLineColor: UIColor, referenceLineThickness: CGFloat, referenceLineSettings: ReferenceLines) {
        super.init(frame: frame)
        
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        
        // The reference line layer draws the reference lines and we handle the labels elsewhere.
        self.referenceLineLayer.frame = self.frame
        self.referenceLineLayer.strokeColor = referenceLineColor.cgColor
        self.referenceLineLayer.lineWidth = referenceLineThickness
        
        self.settings = referenceLineSettings
        
        self.layer.addSublayer(referenceLineLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLabel(at position: CGPoint, withText text: String) -> UILabel {
        let frame = CGRect(x: position.x, y: position.y, width: 0, height: 0)
        let label = UILabel(frame: frame)
        
        return label
    }
    
    private func createReferenceLinesPath() -> UIBezierPath {
        
        referenceLinePath.removeAllPoints()
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        if(self.settings.includeMinMax) {
            let maxLineStart = CGPoint(x: 0, y: topMargin)
            let maxLineEnd = CGPoint(x: lineWidth, y: topMargin)
            
            let minLineStart = CGPoint(x: 0, y: self.bounds.height - bottomMargin)
            let minLineEnd = CGPoint(x: lineWidth, y: self.bounds.height - bottomMargin)
            
            let numberFormatter = referenceNumberFormatter()
            
            let maxString = numberFormatter.string(from: self.currentRange.max as NSNumber)! + units
            let minString = numberFormatter.string(from: self.currentRange.min as NSNumber)! + units
            
            addLine(withTag: maxString, from: maxLineStart, to: maxLineEnd, in: referenceLinePath)
            addLine(withTag: minString, from: minLineStart, to: minLineEnd, in: referenceLinePath)
        }
        
        let initialRect = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + topMargin, width: self.bounds.size.width, height: self.bounds.size.height - (topMargin + bottomMargin))
        
        switch(settings.positionType) {
        case .relative:
            createReferenceLines(in: initialRect, atRelativePositions: self.settings.relativePositions, forPath: referenceLinePath)
        case .absolute:
            createReferenceLines(in: initialRect, atAbsolutePositions: self.settings.absolutePositions, forPath: referenceLinePath)
        }
        
        return referenceLinePath
    }
    
    private func referenceNumberFormatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = self.settings.referenceLineNumberStyle
        numberFormatter.minimumFractionDigits = self.settings.referenceLineNumberOfDecimalPlaces
        numberFormatter.maximumFractionDigits = self.settings.referenceLineNumberOfDecimalPlaces
        
        return numberFormatter
    }
    
    private func createReferenceLines(in rect: CGRect, atRelativePositions relativePositions: [Double], forPath path: UIBezierPath) {
        
        let height = rect.size.height
        var relativePositions = relativePositions
        
        // If we are including the min and max already need to make sure we don't redraw them.
        if(self.settings.includeMinMax) {
            relativePositions = relativePositions.filter({ (x:Double) -> Bool in
                return (x != 0 && x != 1)
            })
        }
        
        for relativePosition in relativePositions {
            
            let yPosition = height * CGFloat(1 - relativePosition)
            
            let lineStart = CGPoint(x: 0, y: rect.origin.y + yPosition)
            let lineEnd = CGPoint(x: lineStart.x + lineWidth, y: lineStart.y)
            
            createReferenceLineFrom(from: lineStart, to: lineEnd, in: path)
        }
    }
    
    private func createReferenceLines(in rect: CGRect, atAbsolutePositions absolutePositions: [Double], forPath path: UIBezierPath) {
        
        for absolutePosition in absolutePositions {
            
            let yPosition = calculateYPositionForYAxisValue(value: absolutePosition)
            
            // don't need to add rect.origin.y to yPosition like we do for relativePositions,
            // as we calculate the position for the y axis value in the previous line,
            // this already takes into account margins, etc.
            let lineStart = CGPoint(x: 0, y: yPosition)
            let lineEnd = CGPoint(x: lineStart.x + lineWidth, y: lineStart.y)
            
            createReferenceLineFrom(from: lineStart, to: lineEnd, in: path)
        }
    }
    
    private func createReferenceLineFrom(from lineStart: CGPoint, to lineEnd: CGPoint, in path: UIBezierPath) {
        if(self.settings.shouldAddLabelsToIntermediateReferenceLines) {
            
            let value = calculateYAxisValue(for: lineStart)
            let numberFormatter = referenceNumberFormatter()
            var valueString = numberFormatter.string(from: value as NSNumber)!
            
            if(self.settings.shouldAddUnitsToIntermediateReferenceLineLabels) {
                valueString += " \(units)"
            }
            
            addLine(withTag: valueString, from: lineStart, to: lineEnd, in: path)
            
        } else {
            addLine(from: lineStart, to: lineEnd, in: path)
        }
    }
    
    private func addLine(withTag tag: String, from: CGPoint, to: CGPoint, in path: UIBezierPath) {
        
        let boundingSize = self.boundingSize(forText: tag)
        let leftLabel = createLabel(withText: tag)
        let rightLabel = createLabel(withText: tag)
        
        // Left label gap.
        leftLabel.frame = CGRect(
            origin: CGPoint(x: from.x + leftLabelInset, y: from.y - (boundingSize.height / 2)),
            size: boundingSize)
        
        let leftLabelStart = CGPoint(x: leftLabel.frame.origin.x - labelMargin, y: to.y)
        let leftLabelEnd = CGPoint(x: (leftLabel.frame.origin.x + leftLabel.frame.size.width) + labelMargin, y: to.y)
        
        // Right label gap.
        rightLabel.frame = CGRect(
            origin: CGPoint(x: (from.x + self.frame.width) - rightLabelInset - boundingSize.width, y: from.y - (boundingSize.height / 2)),
            size: boundingSize)
        
        let rightLabelStart = CGPoint(x: rightLabel.frame.origin.x - labelMargin, y: to.y)
        let rightLabelEnd = CGPoint(x: (rightLabel.frame.origin.x + rightLabel.frame.size.width) + labelMargin, y: to.y)
        
        // Add the lines and tags depending on the settings for where we want them.
        var gaps = [(start: CGFloat, end: CGFloat)]()
        
        switch(self.settings.referenceLinePosition) {
            
        case .left:
            gaps.append((start: leftLabelStart.x, end: leftLabelEnd.x))
            self.addSubview(leftLabel)
            self.labels.append(leftLabel)
            
        case .right:
            gaps.append((start: rightLabelStart.x, end: rightLabelEnd.x))
            self.addSubview(rightLabel)
            self.labels.append(rightLabel)
            
        case .both:
            gaps.append((start: leftLabelStart.x, end: leftLabelEnd.x))
            gaps.append((start: rightLabelStart.x, end: rightLabelEnd.x))
            self.addSubview(leftLabel)
            self.addSubview(rightLabel)
            self.labels.append(leftLabel)
            self.labels.append(rightLabel)
        }
        
        addLine(from: from, to: to, withGaps: gaps, in: path)
    }
    
    private func addLine(from: CGPoint, to: CGPoint, withGaps gaps: [(start: CGFloat, end: CGFloat)], in path: UIBezierPath) {
        
        // If there are no gaps, just add a single line.
        if(gaps.count <= 0) {
            addLine(from: from, to: to, in: path)
        }
            // If there is only 1 gap, it's just two lines.
        else if (gaps.count == 1) {
            
            let gapLeft = CGPoint(x: gaps.first!.start, y: from.y)
            let gapRight = CGPoint(x: gaps.first!.end, y: from.y)
            
            addLine(from: from, to: gapLeft, in: path)
            addLine(from: gapRight, to: to, in: path)
        }
            // If there are many gaps, we have a series of intermediate lines.
        else {
            
            let firstGap = gaps.first!
            let lastGap = gaps.last!
            
            let firstGapLeft = CGPoint(x: firstGap.start, y: from.y)
            let lastGapRight = CGPoint(x: lastGap.end, y: to.y)
            
            // Add the first line to the start of the first gap
            addLine(from: from, to: firstGapLeft, in: path)
            
            // Add lines between all intermediate gaps
            for i in 0 ..< gaps.count - 1 {
                
                let startGapEnd = gaps[i].end
                let endGapStart = gaps[i + 1].start
                
                let lineStart = CGPoint(x: startGapEnd, y: from.y)
                let lineEnd = CGPoint(x: endGapStart, y: from.y)
                
                addLine(from: lineStart, to: lineEnd, in: path)
            }
            
            // Add the final line to the end
            addLine(from: lastGapRight, to: to, in: path)
        }
    }
    
    private func addLine(from: CGPoint, to: CGPoint, in path: UIBezierPath) {
        path.move(to: from)
        path.addLine(to: to)
    }
    
    private func boundingSize(forText text: String) -> CGSize {
        return (text as NSString).size(withAttributes:
            [NSAttributedString.Key.font:self.settings.referenceLineLabelFont])
    }
    
    private func calculateYAxisValue(for point: CGPoint) -> Double {
        
        let graphHeight = self.frame.size.height - (topMargin + bottomMargin)
        
        //                                          value = the corresponding value on the graph for any y co-ordinate in the view
        //           y - t                          y = the y co-ordinate in the view for which we want to know the corresponding value on the graph
        // value = --------- * (min - max) + max    t = the top margin
        //             h                            h = the height of the graph space without margins
        //                                          min = the range's current mininum
        //                                          max = the range's current maximum
        
        var value = (((point.y - topMargin) / (graphHeight)) * CGFloat((self.currentRange.min - self.currentRange.max))) + CGFloat(self.currentRange.max)
        
        // Sometimes results in "negative zero"
        if(value == 0) {
            value = 0
        }
        
        return Double(value)
    }
    
    private func calculateYPositionForYAxisValue(value: Double) -> CGFloat {
        
        // Just an algebraic re-arrangement of calculateYAxisValue
        let graphHeight = self.frame.size.height - (topMargin + bottomMargin)
        var y = ((CGFloat(value - self.currentRange.max) / CGFloat(self.currentRange.min - self.currentRange.max)) * graphHeight) + topMargin
        
        if (y == 0) {
            y = 0
        }
        
        return y
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        
        label.text = text
        label.textColor = self.settings.referenceLineLabelColor
        label.font = self.settings.referenceLineLabelFont
        
        return label
    }
    
    // Public functions to update the reference lines with any changes to the range and viewport (phone rotation, etc).
    // When the range changes, need to update the max for the new range, then update all the labels that are showing for the axis and redraw the reference lines.
    func set(range: (min: Double, max: Double)) {
        self.currentRange = range
        self.referenceLineLayer.path = createReferenceLinesPath().cgPath
    }
    
    func set(viewportWidth: CGFloat, viewportHeight: CGFloat) {
        self.frame.size.width = viewportWidth
        self.frame.size.height = viewportHeight
        self.referenceLineLayer.path = createReferenceLinesPath().cgPath
    }
}
