//
//  ChildViewController.h
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 18/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKDropdownMenu.h"
#import "ShapeView.h"

@interface ChildViewController : UIViewController <MKDropdownMenuDataSource, MKDropdownMenuDelegate>

@property (weak, nonatomic) IBOutlet MKDropdownMenu *dropdownMenu;

@property (weak, nonatomic) IBOutlet ShapeView *shapeView;

@end
