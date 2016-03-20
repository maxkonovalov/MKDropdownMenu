//
//  ShapeView.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 18/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "ShapeView.h"

@implementation ShapeView

- (void)setSidesCount:(NSUInteger)sidesCount {
    _sidesCount = sidesCount;
    [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGPoint c = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat r = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2 - self.lineWidth;
    
    UIBezierPath *path = nil;
    
    if (self.sidesCount < 3) {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(c.x - r, c.y - r, 2 * r, 2 * r)];
    } else {
        path = [UIBezierPath new];
        
        [path moveToPoint:CGPointMake(c.x, c.y - r)];
        
        CGFloat angleStep = 2 * M_PI / self.sidesCount;
        
        for (NSInteger i = 1; i < self.sidesCount; i++) {
            CGFloat a = angleStep * i - M_PI_2;
            [path addLineToPoint:CGPointMake(c.x + r * cos(a), c.y + r * sin(a))];
        }
        
        [path closePath];
    }
    
    [self.fillColor setFill];
    [path fill];
    
    path.lineWidth = self.lineWidth;
    [self.strokeColor setStroke];
    [path stroke];
}

@end
