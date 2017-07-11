//
//  ViewController.m
//  GraphObjC
//

#import "ViewController.h"
#import "GraphObjC-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    numberOfDataItems = 30;
    
    data = [Random generateRandomData:numberOfDataItems max:100 shouldIncludeOutliers:false];
    
    ScrollableGraphView* graphView = [[ScrollableGraphView alloc] initWithFrame: self.view.frame dataSource: self];
    LinePlot* plot = [[LinePlot alloc] initWithIdentifier:@"linePlot"];
    ReferenceLines* referenceLines = [[ReferenceLines alloc] init];
    
    [graphView addPlotWithPlot:plot];
    [graphView addReferenceLinesWithReferenceLines:referenceLines];
    
    [self.view addSubview: graphView];
}

// Implement ScrollableGraphViewDataSource
- (double)valueForPlot:(Plot * _Nonnull)plot atIndex:(NSInteger)pointIndex {
    double value = [data[pointIndex] doubleValue];
    return value;
}

- (NSString * _Nonnull)labelAtIndex:(NSInteger)pointIndex {
    return @"label";
}

- (NSInteger)numberOfPoints {
    return numberOfDataItems;
}

@end
