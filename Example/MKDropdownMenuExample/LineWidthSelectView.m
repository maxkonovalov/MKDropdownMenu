//
//  LineWidthSelectView.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 18/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "LineWidthSelectView.h"

static const CGFloat kInset = 10;

@implementation LineWidthSelectView

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath new];
    path.lineWidth = self.lineWidth;
    path.lineCapStyle = kCGLineCapSquare;
    
    [path moveToPoint:CGPointMake(CGRectGetMinX(rect) + kInset + self.lineWidth/2, CGRectGetMidY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - kInset - self.lineWidth/2, CGRectGetMidY(rect))];
    
    [self.lineColor setStroke];
    [path stroke];
}

@end
