//
//  Simple example usage of ScrollableGraphView.swift
//  #######################################
//

import UIKit


class ViewController: UIViewController {
    
    var childVC: GraphViewController?

    var currentGraphType = GraphType.Dark
    
    var label = UILabel()
    var labelConstraints = [NSLayoutConstraint]()
    
    // Data
    let numberOfDataItems = 29
    
    lazy var data: [Double] = self.generateRandomData(self.numberOfDataItems, max: 50)
    lazy var labels: [String] = self.generateSequentialLabels(self.numberOfDataItems, text: "FEB")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addGraphViewController(currentGraphType.description())

        addLabel(withText: "DARK (TAP HERE)")
    }
    
    func addGraphViewController(name: String) {
        guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier(name) as? GraphViewController else {
            return
        }
        
        // remove the previous child VC
        if let childVC = childVC {
            childVC.willMoveToParentViewController(nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()
        }
        
        // pass the data
        vc.data = data
        vc.labels = labels

        // add our new child vc
        addChildViewController(vc)
        vc.view.frame = view.bounds
        
        view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
        
        childVC = vc
    }
    
    func didTap(gesture: UITapGestureRecognizer) {
        
        currentGraphType.next()
        
        addGraphViewController(currentGraphType.description())
        
        addLabel(withText: currentGraphType.description().uppercaseString)
    }

    
    // Adding and updating the graph switching label in the top right corner of the screen.
    private func addLabel(withText text: String) {
        
        label.removeFromSuperview()
        label = createLabel(withText: text)
        label.userInteractionEnabled = true
        
        let rightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -20)
        
        let topConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
        
        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40)
        let widthConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: label.frame.width * 1.5)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTap))
        label.addGestureRecognizer(tapGestureRecogniser)
        
        self.view.addSubview(label)
        self.view.addConstraints([rightConstraint, topConstraint, heightConstraint, widthConstraint])
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        
        label.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        label.text = text
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(14)
        
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        
        return label
    }
    
    // Data Generation
    private func generateRandomData(numberOfItems: Int, max: Double) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(random()) % max
            
            if(random() % 100 < 10) {
                randomNumber *= 3
            }
            
            data.append(randomNumber)
        }
        return data
    }
    
    private func generateSequentialLabels(numberOfItems: Int, text: String) -> [String] {
        var labels = [String]()
        for i in 0 ..< numberOfItems {
            labels.append("\(text) \(i+1)")
        }
        return labels
    }
    
    // The type of the current graph we are showing.
    enum GraphType {
        case Dark
        case Bar
        case Dot
        case Pink
        
        mutating func next() {
            switch(self) {
            case .Dark:
                self = GraphType.Bar
            case .Bar:
                self = GraphType.Dot
            case .Dot:
                self = GraphType.Pink
            case .Pink:
                self = GraphType.Dark
            }
        }
        
        func description() -> String {
            switch(self) {
            case .Dark:
                return "Dark"
            case .Bar:
                return "Bar"
            case .Dot:
                return "Dot"
            case .Pink:
                return "Pink"
            }

        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

