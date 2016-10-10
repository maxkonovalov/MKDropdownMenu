//
//  ViewController.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 17/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "ViewController2.h"
#import "JDropdownMenu.h"
#import "Utilities.h"


@interface ViewController2()<JDropdownMenuDelegate>

@property (weak, nonatomic) IBOutlet JDropdownMenu *navBarMenu;
@end
@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
        self.navBarMenu.delegate = self;
    
    // Make background light instead of dark when presenting the dropdown
    self.navBarMenu.backgroundDimmingOpacity = 0.15;
    
    /*
    // Add an arrow between the menu header and the dropdown
    UIImageView *spacer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle"]];

    // Prevent the arrow image from stretching
    spacer.contentMode = UIViewContentModeCenter;
    
    self.navBarMenu.spacerView = spacer;
    
    // Offset the arrow to align with the disclosure indicator
    self.navBarMenu.spacerViewOffset = UIOffsetMake(self.navBarMenu.bounds.size.width/2 - 8, 1);
    */
    
    // Hide top row separator to blend with the arrow
    self.navBarMenu.showsTopRowSeparator = NO;
    
    /*
    // Round all corners (by default only bottom corners are rounded)
    self.navBarMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
    
    // Let the dropdown take the whole width of the screen with 10pt insets
    self.navBarMenu.fullScreenInsetLeft = 10;
    self.navBarMenu.fullScreenInsetRight = 10;
    */
    
    UILabel *view = [UILabel new];
    view.text = @"Hello, world.";
    view.textColor = [UIColor whiteColor];
    view.backgroundColor = UIColorWithHexString(@"0DA199");
    self.navBarMenu.containerCustomView = view;
    self.navBarMenu.contentHeight = 60;
    
    [self.view addSubview:self.navBarMenu];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navBarMenu closeComponentAnimated:NO];
}

#pragma mark - MKDropdownMenuDelegate

- (IBAction)barMenuCick:(id)sender {
    if([self.navBarMenu isComponentOpened]) {
        [self.navBarMenu closeComponentAnimated:YES];
    } else {
        [self.navBarMenu openComponentAnimated:YES];
    }
}

@end
