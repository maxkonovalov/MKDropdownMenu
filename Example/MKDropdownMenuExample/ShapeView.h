//
//  ShapeView.h
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 18/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeView : UIView

// sidesCount < 3 will produce a circle
@property (assign, nonatomic) NSUInteger sidesCount;

@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *strokeColor;

@property (assign, nonatomic) CGFloat lineWidth;

@end
