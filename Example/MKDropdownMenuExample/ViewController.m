//
//  ViewController.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 17/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "ViewController.h"
#import "Utilities.h"

@interface ViewController ()
@property (strong, nonatomic) NSArray<NSString *> *colors;
@end

@implementation ViewController

- (ChildViewController *)childViewController {
    return (ChildViewController *)self.childViewControllers.firstObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colors = @[@"#0F4C81", @"#166BB5", @"#1B86E3"];
    self.textLabel.text = self.colors[0];
    
    self.view.backgroundColor = UIColorWithHexString(self.colors[0]);
    
    
    // Create dropdown menu in code
    
    self.navBarMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    self.navBarMenu.dataSource = self;
    self.navBarMenu.delegate = self;
    self.navBarMenu.backgroundDimmingOpacity = 0;
    
    // Set custom disclosure indicator image
    UIImage *indicator = [UIImage imageNamed:@"indicator"];
    self.navBarMenu.disclosureIndicatorImage = indicator;
    
    // Add an arrow between the menu header and the dropdown
    UIImageView *spacer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle"]];

    // Prevent the arrow image from stretching
    spacer.contentMode = UIViewContentModeCenter;
    
    self.navBarMenu.spacerView = spacer;
    
    // Offset the arrow to align with the disclosure indicator
    self.navBarMenu.spacerViewOffset = UIOffsetMake(self.navBarMenu.bounds.size.width/2 - indicator.size.width/2 - 8, 1);
    
    // Hide top row separator to blend with the arrow
    self.navBarMenu.showsTopRowSeparator = NO;
    
    self.navBarMenu.dropdownBouncesScroll = NO;
    
    self.navBarMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.navBarMenu.rowTextAlignment = NSTextAlignmentCenter;
    
    // Round all corners (by default only bottom corners are rounded)
    self.navBarMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
    
    // Let the dropdown take the whole width of the screen with 10pt insets
    self.navBarMenu.useFullScreenWidth = YES;
    self.navBarMenu.fullScreenInsetLeft = 10;
    self.navBarMenu.fullScreenInsetRight = 10;
    
    // Add the dropdown menu to navigation bar
    self.navigationItem.titleView = self.navBarMenu;
    
}

#pragma mark - MKDropdownMenuDataSource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

#pragma mark - MKDropdownMenuDelegate

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    return 60;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
        return [[NSAttributedString alloc] initWithString:@"MKDropdownMenu"
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight],
                                                            NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableAttributedString *string =
    [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"Color %zd: ", row + 1]
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [string appendAttributedString:
     [[NSAttributedString alloc] initWithString:self.colors[row]
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightMedium],
                                                  NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    return string;
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    return UIColorWithHexString(self.colors[row]);
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForHighlightedRowsInComponent:(NSInteger)component {
    return [UIColor colorWithWhite:1.0 alpha:0.5];
}


- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *colorString = self.colors[row];
    self.textLabel.text = colorString;
   
    UIColor *color = UIColorWithHexString(colorString);
    self.view.backgroundColor = color;
    self.childViewController.shapeView.strokeColor = color;
    
    delay(0.15, ^{
        [dropdownMenu closeAllComponentsAnimated:YES];
    });
}

@end
