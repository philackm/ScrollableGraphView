//
//  ViewController.h
//  GraphObjC
//

#import <UIKit/UIKit.h>
#import "GraphObjC-Swift.h"

@interface ViewController : UIViewController <ScrollableGraphViewDataSource> {
    NSArray* data;
    NSInteger numberOfDataItems;
}

@end

