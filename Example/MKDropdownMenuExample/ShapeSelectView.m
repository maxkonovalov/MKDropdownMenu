//
//  ShapeSelectView.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 18/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "ShapeSelectView.h"

@implementation ShapeSelectView

- (void)awakeFromNib {
    self.shapeView.fillColor = [UIColor clearColor];
    self.shapeView.strokeColor = self.textLabel.textColor;
    self.shapeView.lineWidth = 1;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.shapeView.fillColor = selected ? self.shapeView.strokeColor : [UIColor clearColor];
    self.textLabel.font = [UIFont systemFontOfSize:self.textLabel.font.pointSize
                                            weight:selected ? UIFontWeightMedium : UIFontWeightLight];
}

@end
