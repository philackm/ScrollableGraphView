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

        guard let data = data, let labels = labels else {
            return
        }
        graphView?.set(data: data, withLabels: labels)
    }

}
