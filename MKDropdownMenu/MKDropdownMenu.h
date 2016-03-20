/*
 The MIT License (MIT)
 
 Copyright (c) 2016 Max Konovalov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKDropdownMenuDataSource, MKDropdownMenuDelegate;

@interface MKDropdownMenu : UIView

@property (nullable, weak, nonatomic) IBOutlet id<MKDropdownMenuDataSource> dataSource;
@property (nullable, weak, nonatomic) IBOutlet id<MKDropdownMenuDelegate> delegate;

@property (assign, nonatomic) BOOL dropdownDropsShadow; // default = YES
@property (assign, nonatomic) BOOL dropdownBouncesScroll; // default = YES

// the strength of the screen dimming (black color) under presented dropdown
@property (assign, nonatomic) CGFloat backgroundDimmingOpacity; // default = 0.2

// the color of the header components and rows separators
@property (nullable, strong, nonatomic) UIColor *componentSeparatorColor;
@property (nullable, strong, nonatomic) UIColor *rowSeparatorColor;

// show the separator above the first row in dropdown
@property (assign, nonatomic) BOOL showsTopRowSeparator; // default = YES

// the view to place between header component and dropdown (like an arrow in popover).
// the height of the view's frame is preserved, and the view itself is stretched to fit the witdth of the dropdown
@property (nullable, strong, nonatomic) UIView *spacerView;

// the offset for the spacer view
@property (assign, nonatomic) UIOffset spacerViewOffset;

// the background color of the expanded header component
@property (nullable, strong, nonatomic) UIColor *selectedComponentBackgroundColor;

// the background color of the dropdown rows.
// for semi-transparent background colors (alpha < 1), `shouldDropShadow` must be set to NO
@property (nullable, strong, nonatomic) UIColor *dropdownBackgroundColor; // default = white

// the accessory image in the header components, rotates to indicate open/closed state.
// provide an image with UIImageRenderingModeAlwaysTemplate to respect the view's tint color
@property (nullable, strong, nonatomic) UIImage *disclosureIndicatorImage;

// the alignment of the labels in header components and rows
@property (assign, nonatomic) NSTextAlignment componentTextAlignment; // default = NSTextAlignmentCenter
@property (assign, nonatomic) NSTextAlignment rowTextAlignment; // default = NSTextAlignmentLeft

// the corner radius of the dropdown
@property (assign, nonatomic) CGFloat dropdownCornerRadius; // default = 2

// the corners to be rounded in the dropdown
@property (assign, nonatomic) UIRectCorner dropdownRoundedCorners; // default = UIRectCornerBottomLeft|UIRectCornerBottomRight

// if `useFullScreenWidth = YES`, the dropdown will occupy the full width of the screen for all components marked in `-dropdownMenu:shouldUseFullRowWidthForComponent:`, otherwise the width of these components will be equal to DropdownMenu's width
@property (assign, nonatomic) BOOL useFullScreenWidth; // default = NO

// when `useFullScreenWidth` is enabled, left and right insets to screen edges can be specified (both default to 0)
@property (assign, nonatomic) CGFloat fullScreenInsetLeft;
@property (assign, nonatomic) CGFloat fullScreenInsetRight;

@property (assign, nonatomic) BOOL allowsMultipleSelection; // default = NO

// cached info from the data source
- (NSInteger)numberOfComponents;
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

// returns the view provided by the delegate via `-dropdownMenu:viewForRow:forComponent:reusingView:` or nil if the row/component is not visible
- (nullable UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component;

// reload all data from scratch
- (void)reloadAllComponents;

// reload the component header and rows, keeps rows selection
- (void)reloadComponent:(NSInteger)component;

// selecting/deselecting rows in component, makes the corresponding rows reload.
// provide visual feedback by implementing the desired behavior in appropriate delegate methods, e.g. `-dropdownMenu:accessoryViewForRow:forComponent:`
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component;
- (void)deselectRow:(NSInteger)row inComponent:(NSInteger)component;

// returns the indexes of selected rows in the specified component or empty set if nothing is selected
- (NSIndexSet *)selectedRowsInComponent:(NSInteger)component;

// expand the specified component. if other component is open, it will be closed first
- (void)openComponent:(NSInteger)component animated:(BOOL)animated;
// dismiss all components
- (void)closeAllComponentsAnimated:(BOOL)animated;

@end


@protocol MKDropdownMenuDataSource <NSObject>
@required

// return the number of column items in menu
- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu;

// return the number of rows in each component
- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component;

@end


@protocol MKDropdownMenuDelegate <NSObject>
@optional

// return the desired dimensions of menu items
- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu widthForComponent:(NSInteger)component;
- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component;

// return YES if the dropdown for this component should occupy the full width of the menu, otherwise its width will be equal to its header component's width.
// if `useFullScreenWidth = YES`, the width of the dropdown for the specified component will be equal to screen width minus `fullScreenInsetLeft` and `fullScreenInsetRight`
- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu shouldUseFullRowWidthForComponent:(NSInteger)component; // default = YES

// return the maximum rows limit
- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu maximumNumberOfRowsInComponent:(NSInteger)component;


// the following methods return either a plain NSString, an NSAttributedString, or a custom view to display the row for the component

// return the display data for the header components
- (nullable NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForComponent:(NSInteger)component;
- (nullable NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForSelectedComponent:(NSInteger)component;
- (nullable NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component;
- (nullable NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForSelectedComponent:(NSInteger)component;
- (UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu viewForComponent:(NSInteger)component;

// return the display data for the rows in components
- (nullable NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (nullable NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view;

// return the accessory view for the row in component, e.g. for selection indicator
- (nullable UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu accessoryViewForRow:(NSInteger)row forComponent:(NSInteger)component;

// return the background color for the row in component
- (nullable UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component;

// return the background color for the highlighted rows in component
- (nullable UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForHighlightedRowsInComponent:(NSInteger)component;


// called when a row was tapped. if selection needs to be handled, use `-(de)selectRow:inComponent:` as appropriate
- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

// called when the component was expanded
- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didOpenComponent:(NSInteger)component;

// called when the component did dismiss
- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didCloseComponent:(NSInteger)component;

@end

NS_ASSUME_NONNULL_END
