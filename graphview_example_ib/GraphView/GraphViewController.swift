//
//  Simple example usage of ScrollableGraphView.swift
//  #######################################
//

import UIKit

class GraphViewController: UIViewController {
    @IBOutlet var graphView: ScrollableGraphView?
    var data: [Double]?
    var labels: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let data = data else {
            return
        }
        guard let labels = labels else {
            return
        }
        graphView?.setData(data, withLabels: labels)
    }

}
