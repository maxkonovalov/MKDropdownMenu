//
//  MenuTableViewCell.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 01/04/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dropdownMenu.rowTextAlignment = NSTextAlignmentCenter;
    self.dropdownMenu.selectedComponentBackgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
    self.dropdownMenu.dropdownBackgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    self.dropdownMenu.backgroundDimmingOpacity = 0;
    [self layoutIfNeeded];
}

@end
