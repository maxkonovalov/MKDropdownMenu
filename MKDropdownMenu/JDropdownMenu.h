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

@protocol JDropdownMenuDelegate;

@interface JDropdownMenu : UIView

@property (nullable, weak, nonatomic) IBOutlet id<JDropdownMenuDelegate> delegate;

// the view the dropdown to be presented in. if not specified, the dropdown will be presented in the containing window
@property (nullable, weak, nonatomic) UIView *presentingView;

@property (assign, nonatomic) UIView *containerCustomView;
@property (nonatomic) CGFloat contentHeight;
    
// if presented in scroll view, its vertical content offset will be updated to fit the dropdown
@property (assign, nonatomic) BOOL adjustsContentOffset; // default = NO

// if presented in scroll view, its bottom content inset will be updated to fit the dropdown
@property (assign, nonatomic) BOOL adjustsContentInset; // default = YES

@property (assign, nonatomic) BOOL dropdownDropsShadow UI_APPEARANCE_SELECTOR; // default = YES

// the strength of the screen dimming (black color) under presented dropdown.
// negative values produce white dimming color instead of black
@property (assign, nonatomic) CGFloat backgroundDimmingOpacity UI_APPEARANCE_SELECTOR; // default = 0.2

// the color of the header components and rows separators
@property (nullable, strong, nonatomic) UIColor *componentSeparatorColor UI_APPEARANCE_SELECTOR;

// show the separator above the first row in dropdown
@property (assign, nonatomic) BOOL showsTopRowSeparator UI_APPEARANCE_SELECTOR; // default = YES

// the view to place between header component and dropdown (like an arrow in popover).
// the height of the view's frame is preserved, and the view itself is stretched to fit the witdth of the dropdown
@property (nullable, strong, nonatomic) UIView *spacerView;

// the offset for the spacer view
@property (assign, nonatomic) UIOffset spacerViewOffset;

// the background color of the dropdown rows.
// for semi-transparent background colors (alpha < 1), `shouldDropShadow` must be set to NO
@property (nullable, strong, nonatomic) UIColor *dropdownBackgroundColor UI_APPEARANCE_SELECTOR; // default = white

// the corner radius of the dropdown
@property (assign, nonatomic) CGFloat dropdownCornerRadius UI_APPEARANCE_SELECTOR; // default = 2

// the corners to be rounded in the dropdown
@property (assign, nonatomic) UIRectCorner dropdownRoundedCorners UI_APPEARANCE_SELECTOR; // default = UIRectCornerBottomLeft|UIRectCornerBottomRight

// when `useFullScreenWidth` is enabled, left and right insets to screen edges can be specified (both default to 0)
@property (assign, nonatomic) CGFloat fullScreenInsetLeft;
@property (assign, nonatomic) CGFloat fullScreenInsetRight;

@property (assign, nonatomic) BOOL allowsMultipleSelection; // default = NO

@property (readonly, nonatomic) BOOL isComponentOpened;
    
// reload all data from scratch
- (void)reloadComponent;

// expand the specified component. if other component is open, it will be closed first
- (void)openComponentAnimated:(BOOL)animated;
// dismiss all components
- (void)closeComponentAnimated:(BOOL)animated;

// moves the dropdown view so that it appears on top of all other subviews in presenting view
- (void)bringDropdownViewToFront;
    
@end

@protocol JDropdownMenuDelegate <NSObject>
@optional

// called when a row was tapped. if selection needs to be handled, use `-(de)selectRow:inComponent:` as appropriate
- (void)dropdownMenuComponentDidTapBlankArea:(JDropdownMenu *)dropdownMenu;
    
// called when the component was expanded
- (void)dropdownMenuComponentDidOpen:(JDropdownMenu *)dropdownMenu;

// called when the component did dismiss
- (void)dropdownMenuComponentDidClose:(JDropdownMenu *)dropdownMenu;

@end

NS_ASSUME_NONNULL_END
