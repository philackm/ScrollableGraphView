
import UIKit

internal class LabelPool {
    
    var labels = [UILabel]()
    var relations = [Int : Int]()
    var unused = [Int]()
    
    func deactivateLabel(forPointIndex pointIndex: Int){
        
        if let unusedLabelIndex = relations[pointIndex] {
            unused.append(unusedLabelIndex)
        }
        relations[pointIndex] = nil
    }
    
    @discardableResult
    func activateLabel(forPointIndex pointIndex: Int) -> UILabel {
        var label: UILabel
        
        if(unused.count >= 1) {
            let unusedLabelIndex = unused.first!
            unused.removeFirst()
            
            label = labels[unusedLabelIndex]
            relations[pointIndex] = unusedLabelIndex
        }
        else {
            label = UILabel()
            labels.append(label)
            let newLabelIndex = labels.index(of: label)!
            relations[pointIndex] = newLabelIndex
        }
        
        return label
    }
    
    var activeLabels: [UILabel] {
        get {
            
            var currentlyActive = [UILabel]()
            let numberOfLabels = labels.count
            
            for i in 0 ..< numberOfLabels {
                if(!unused.contains(i)) {
                    currentlyActive.append(labels[i])
                }
            }
            return currentlyActive
        }
    }
}
