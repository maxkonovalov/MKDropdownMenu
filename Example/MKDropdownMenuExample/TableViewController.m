//
//  TableViewController.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 01/04/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "TableViewController.h"
#import "MenuTableViewCell.h"

@interface TableViewController () <MKDropdownMenuDataSource, MKDropdownMenuDelegate>
@end

@implementation TableViewController

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
    cell.dropdownMenu.dataSource = self;
    cell.dropdownMenu.delegate = self;
    cell.dropdownMenu.presentingView = tableView;
    cell.dropdownMenu.adjustsContentOffset = YES;
    [cell.dropdownMenu reloadAllComponents];
    return cell;
}

#pragma mark - MKDropdownMenuDataSource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 3;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

#pragma mark - MKDropdownMenuDelegate

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForComponent:(NSInteger)component {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:
                              [self.tableView convertPoint:CGPointMake(CGRectGetMidX(dropdownMenu.bounds),
                                                                       CGRectGetMidY(dropdownMenu.bounds))
                                                  fromView:dropdownMenu]];
    
    return [NSString stringWithFormat:@"%zd-%zd", indexPath.row + 1, component + 1];
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:
                              [self.tableView convertPoint:CGPointMake(CGRectGetMidX(dropdownMenu.bounds),
                                                                       CGRectGetMidY(dropdownMenu.bounds))
                                                  fromView:dropdownMenu]];
    
    return [NSString stringWithFormat:@"%zd-%zd-%zd", indexPath.row + 1, component + 1, row + 1];
}

- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu shouldUseFullRowWidthForComponent:(NSInteger)component {
    return NO;
}

@end
