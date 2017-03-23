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

/// The view the dropdown to be presented in. If not specified, the dropdown will be presented in the containing window.
@property (nullable, weak, nonatomic) IBOutlet UIView *presentingView;

/// If presented in scroll view, its vertical content offset will be updated to fit the dropdown. Default = NO.
@property (assign, nonatomic) BOOL adjustsContentOffset;

/// If presented in scroll view, its bottom content inset will be updated to fit the dropdown. Default = YES.
@property (assign, nonatomic) BOOL adjustsContentInset;

/// Show a shadow under the dropdown. Default = YES.
@property (assign, nonatomic) BOOL dropdownDropsShadow UI_APPEARANCE_SELECTOR;

/// Bounce table view scroll of the dropdown. Default = YES.
@property (assign, nonatomic) BOOL dropdownBouncesScroll UI_APPEARANCE_SELECTOR;

/// Show the separator above the first row in dropdown. Default = YES.
@property (assign, nonatomic) BOOL dropdownShowsTopRowSeparator UI_APPEARANCE_SELECTOR;

/// Show the separator below the last row in dropdown. Default = YES.
@property (assign, nonatomic) BOOL dropdownShowsBottomRowSeparator UI_APPEARANCE_SELECTOR;

/// Show the border around the dropdown. Drawn in the same color as row separators. Default = NO.
@property (assign, nonatomic) BOOL dropdownShowsBorder UI_APPEARANCE_SELECTOR;

/// Show the dropdown's content above the menu instead of normal below. Default = NO.
@property (assign, nonatomic) BOOL dropdownShowsContentAbove UI_APPEARANCE_SELECTOR;

/// The strength of the screen dimming (black color) under presented dropdown. Negative values produce white dimming color instead of black. Default = 0.2.
@property (assign, nonatomic) CGFloat backgroundDimmingOpacity UI_APPEARANCE_SELECTOR;

/// The color of the header components separator lines (vertical).
@property (nullable, strong, nonatomic) UIColor *componentSeparatorColor UI_APPEARANCE_SELECTOR;

/// The color of the dropdown rows separators (horizontal).
@property (nullable, strong, nonatomic) UIColor *rowSeparatorColor UI_APPEARANCE_SELECTOR;

/// The view to place between header component and dropdown (like an arrow in popover). The height of the view's frame is preserved, and the view itself is stretched to fit the witdth of the dropdown.
@property (nullable, strong, nonatomic) UIView *spacerView;

/// The offset for the spacer view.
@property (assign, nonatomic) UIOffset spacerViewOffset;

/// The background color of the expanded header component.
@property (nullable, strong, nonatomic) UIColor *selectedComponentBackgroundColor UI_APPEARANCE_SELECTOR;

/// The background color of the dropdown rows. For semi-transparent background colors (alpha < 1), `shouldDropShadow` must be set to NO. Defaults to white color.
@property (nullable, strong, nonatomic) UIColor *dropdownBackgroundColor UI_APPEARANCE_SELECTOR;

/// The accessory image in the header components, rotates to indicate open/closed state. Provide an image with `UIImageRenderingModeAlwaysTemplate` to respect the view's tint color.
@property (nullable, strong, nonatomic) UIImage *disclosureIndicatorImage UI_APPEARANCE_SELECTOR;

/// The rotation angle (in radians) of the disclosure indicator when the component is selected. Default = M_PI.
@property (assign, nonatomic) CGFloat disclosureIndicatorSelectionRotation UI_APPEARANCE_SELECTOR;

/// The technique to use for wrapping and truncating the component title text. Multiline title can be displayed by specifying `NSLineBreakByWordWrapping` or `NSLineBreakByCharWrapping`. Default = `NSLineBreakByTruncatingMiddle`.
@property (assign, nonatomic) NSLineBreakMode componentLineBreakMode UI_APPEARANCE_SELECTOR;

/// The alignment of the labels in header components. Default = NSTextAlignmentCenter.
@property (assign, nonatomic) NSTextAlignment componentTextAlignment UI_APPEARANCE_SELECTOR;

/// The alignment of the labels in rows. Default = NSTextAlignmentLeft.
@property (assign, nonatomic) NSTextAlignment rowTextAlignment UI_APPEARANCE_SELECTOR;

/// The corner radius of the dropdown. Default = 2.
@property (assign, nonatomic) CGFloat dropdownCornerRadius UI_APPEARANCE_SELECTOR;

/// The corners to be rounded in the dropdown. If not set, the dropdown will automatically switch between `UIRectCornerBottomLeft|UIRectCornerBottomRight` for the default presentation and `UIRectCornerTopLeft|UIRectCornerTopRight` when the dropdown is shown above.
@property (assign, nonatomic) UIRectCorner dropdownRoundedCorners UI_APPEARANCE_SELECTOR;

/// If `useFullScreenWidth = YES`, the dropdown will occupy the full width of the screen for all components marked in `-dropdownMenu:shouldUseFullRowWidthForComponent:`, otherwise the width of these components will be equal to DropdownMenu's width. Default = NO.
@property (assign, nonatomic) BOOL useFullScreenWidth;

/// When `useFullScreenWidth` is enabled, the left inset to screen edge can be specified. Default = 0.
@property (assign, nonatomic) CGFloat fullScreenInsetLeft;

/// When `useFullScreenWidth` is enabled, the right inset to screen edge can be specified. Default = 0.
@property (assign, nonatomic) CGFloat fullScreenInsetRight;

/// Allow multiple rows selection in dropdown. Default = NO.
@property (assign, nonatomic) BOOL allowsMultipleRowsSelection;

/// The currently expanded component. NSNotFound when no components are selected.
@property (readonly, nonatomic) NSInteger selectedComponent;

/// The number of components in the dropdown (cached from the data source).
- (NSInteger)numberOfComponents;

/// The number of rows in a component in the dropdown (cached from the data source).
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

/// Returns the view provided by the delegate via `-dropdownMenu:viewForRow:forComponent:reusingView:` or nil if the row/component is not visible.
- (nullable UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component;

/// Reload all data from scratch.
- (void)reloadAllComponents;

/// Reload the component header and rows, keeps rows selection.
- (void)reloadComponent:(NSInteger)component;

/// Selecting/deselecting rows in component, makes the corresponding rows reload. Provide visual feedback by implementing the desired behavior in appropriate delegate methods, e.g. `-dropdownMenu:accessoryViewForRow:forComponent:`.
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component;

/// Deselecting rows in component, makes the corresponding rows reload. Provide visual feedback by implementing the desired behavior in appropriate delegate methods, e.g. `-dropdownMenu:accessoryViewForRow:forComponent:`.
- (void)deselectRow:(NSInteger)row inComponent:(NSInteger)component;

/// Returns the indexes of selected rows in the specified component or empty set if nothing is selected.
- (NSIndexSet *)selectedRowsInComponent:(NSInteger)component;

/// Expand the specified component. If other component is open, it will be closed first.
- (void)openComponent:(NSInteger)component animated:(BOOL)animated;

/// Dismiss all components.
- (void)closeAllComponentsAnimated:(BOOL)animated;

/// Moves the dropdown view so that it appears on top of all other subviews in presenting view.
- (void)bringDropdownViewToFront;

@end


@protocol MKDropdownMenuDataSource <NSObject>
@required

/// Return the number of column items in menu.
- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu;

/// Return the number of rows in each component.
- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component;

@end


@protocol MKDropdownMenuDelegate <NSObject>
@optional

/// Return the desired dimensions of menu items.
- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu widthForComponent:(NSInteger)component;
- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component;

/// Return YES if the dropdown for this component should occupy the full width of the menu, otherwise its width will be equal to its header component's width. If `useFullScreenWidth = YES`, the width of the dropdown for the specified component will be equal to screen width minus `fullScreenInsetLeft` and `fullScreenInsetRight`. Default = YES.
- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu shouldUseFullRowWidthForComponent:(NSInteger)component;

/// Return the maximum rows limit.
- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu maximumNumberOfRowsInComponent:(NSInteger)component;


// The following methods return either a plain NSString, an NSAttributedString, or a custom view to display the row for the component:

/// Return the title for a header component.
- (nullable NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForComponent:(NSInteger)component;

/// Return the title for a selected header component.
- (nullable NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForSelectedComponent:(NSInteger)component;

/// Return the attributed title for a header component.
- (nullable NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component;

/// Return the attributed title for a selected header component.
- (nullable NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForSelectedComponent:(NSInteger)component;

/// Return the custom view for a header component.
- (UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu viewForComponent:(NSInteger)component;

/// Return the title for a row in a component.
- (nullable NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component;

/// Return the attributed title for a row in a component.
- (nullable NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component;

/// Return the custom view for a row in a component.
- (UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view;

/// Return the accessory view for the row in component, e.g. for selection indicator.
- (nullable UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu accessoryViewForRow:(NSInteger)row forComponent:(NSInteger)component;

/// Return the background color for the row in component.
- (nullable UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component;

/// Return the background color for the highlighted rows in component.
- (nullable UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForHighlightedRowsInComponent:(NSInteger)component;

/// Return NO if the component is used as a dummy space for other components and should not be interacted with. The disclosure indicator is hidden for such components. Default = YES.
- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu enableComponent:(NSInteger)component;


/// Called when a row was tapped. If selection needs to be handled, use `-(de)selectRow:inComponent:` as appropriate.
- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

/// Called when the component was expanded.
- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didOpenComponent:(NSInteger)component;

/// Called when the component did dismiss.
- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didCloseComponent:(NSInteger)component;

@end

NS_ASSUME_NONNULL_END
