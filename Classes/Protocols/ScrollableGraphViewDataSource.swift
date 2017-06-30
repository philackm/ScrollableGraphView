
import UIKit

public protocol ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double
    func label(forPlot plot: Plot, atIndex pointIndex: Int) -> String
    func numberOfPoints(forPlot plot: Plot) -> Int
}
