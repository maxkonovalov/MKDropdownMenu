//
//  MenuTableViewCell.h
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 01/04/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKDropdownMenu.h"

@interface MenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MKDropdownMenu *dropdownMenu;

@end
