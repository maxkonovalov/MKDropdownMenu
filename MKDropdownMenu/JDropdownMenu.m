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

#import "JDropdownMenu.h"

#pragma mark - Constants -

static const NSTimeInterval jkAnimationDuration = 0.25;

static const CGFloat jkDefaultRowHeight = 44;
static const CGFloat jkDefaultCornerRadius = 2;
static const CGFloat jkDefaultBackgroundDimmingOpacity = 0.2;

static const CGFloat jkShadowOpacity = 0.2;

#pragma mark - Content Controller -

@class JDropdownMenuContentViewController;

#pragma mark Delegate Protocol

@protocol JDropdownMenuContentViewControllerDelegate <NSObject>
- (void)didTapBlankArea;
- (void)willDisappear;
@end

#pragma mark Controller

@interface JDropdownMenuContentViewController : UIViewController <UIGestureRecognizerDelegate> {
    NSLayoutConstraint *_heightConstraint;
    NSLayoutConstraint *_topConstraint;
    NSLayoutConstraint *_leftConstraint;
    NSLayoutConstraint *_rightConstraint;
}
@property (weak, nonatomic) id<JDropdownMenuContentViewControllerDelegate> delegate;

@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) UIView *shadowView;

@property (strong, nonatomic) UIView *tableContainerView;
@property (strong, nonatomic) UIView *myCustomView;

@property (strong, nonatomic) UIView *separatorContainerView;
@property (assign, nonatomic) UIOffset separatorViewOffset;

@property (assign, nonatomic) UIEdgeInsets contentInset;

@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) UIRectCorner roundedCorners;

@property (nonatomic) CGFloat contentHeight;
    
@end

@implementation JDropdownMenuContentViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.presentingViewController.preferredStatusBarStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:jkDefaultBackgroundDimmingOpacity];
    self.view.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    
    /* Setup Views */
    
    
    // Container View
    
    self.containerView = [UIView new];
    self.containerView.clipsToBounds = NO;
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    // Table Container View
    
    self.tableContainerView = [UIView new];
    self.tableContainerView.clipsToBounds = YES;
    self.tableContainerView.backgroundColor = [UIColor blackColor];
    self.tableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = self.tableContainerView.bounds;
    mask.fillColor = [[UIColor whiteColor] CGColor];
    self.tableContainerView.layer.mask = mask;
    self.cornerRadius = jkDefaultCornerRadius;
    self.roundedCorners = UIRectCornerBottomLeft|UIRectCornerBottomRight;

    
    // Shadow
    
    self.shadowView = [UIView new];
    self.shadowView.clipsToBounds = NO;
    self.shadowView.backgroundColor = [UIColor clearColor];
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.shadowView.layer.shadowOpacity = jkShadowOpacity;
    self.shadowView.layer.shadowRadius = jkDefaultCornerRadius;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 1);
    
    
    // Separator
    
    self.separatorContainerView = [UIView new];
    self.separatorContainerView.clipsToBounds = NO;
    self.separatorContainerView.backgroundColor = [UIColor clearColor];
    self.separatorContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
    /* Add subviews */
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.shadowView];
    [self.containerView addSubview:self.separatorContainerView];
    [self.containerView addSubview:self.tableContainerView];
    
    /* Setup constraints */
    
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self.tableContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:jkDefaultRowHeight];
    [self.tableContainerView addConstraint:_heightConstraint];
    
    _leftConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    _rightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    
    [self.view addConstraints:@[_leftConstraint, _rightConstraint,
                                [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]]];
    
    _topConstraint = [NSLayoutConstraint constraintWithItem:self.separatorContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
    
    [self.separatorContainerView addConstraint:_topConstraint];
    
    [self.containerView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.separatorContainerView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.containerView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:self.containerView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.separatorContainerView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0]]];
    
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:kNilOptions metrics:nil views:@{@"v": self.tableContainerView}]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[s][v]|" options:kNilOptions metrics:nil views:@{@"s": self.separatorContainerView, @"v": self.tableContainerView}]];
    
    [self.containerView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.shadowView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:self.shadowView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.shadowView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.shadowView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:0.0]]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateContainerHeight];
    [self updateShadow];
    [self updateMask];
}

- (void)updateShadow {
    UIBezierPath *shadowPath = [UIBezierPath new];
    [shadowPath moveToPoint:CGPointMake(0, CGRectGetMinY(self.shadowView.bounds))];
    [shadowPath addLineToPoint:CGPointMake(0, CGRectGetMaxY(self.shadowView.bounds))];
    [shadowPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.shadowView.bounds), CGRectGetMaxY(self.shadowView.bounds))];
    [shadowPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.shadowView.bounds), CGRectGetMinY(self.shadowView.bounds))];
    [shadowPath addLineToPoint:CGPointMake(CGRectGetMidX(self.shadowView.bounds), CGRectGetMidY(self.shadowView.bounds))];
    [shadowPath closePath];
    self.shadowView.layer.shadowPath = shadowPath.CGPath;
}

- (void)updateMask {
    CGFloat r = self.cornerRadius;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.tableContainerView.bounds
                                                   byRoundingCorners:self.roundedCorners
                                                         cornerRadii:CGSizeMake(r, r)];
    CAShapeLayer *mask = (CAShapeLayer *)self.tableContainerView.layer.mask;
    mask.path = maskPath.CGPath;
    self.shadowView.layer.shadowRadius = MAX(r, jkDefaultCornerRadius);
}

-(void)setMyCustomView:(UIView *)myCustomView {
    _myCustomView = myCustomView;
    self.myCustomView.clipsToBounds = YES;
    self.myCustomView.layoutMargins = UIEdgeInsetsZero;
    self.myCustomView.translatesAutoresizingMaskIntoConstraints = NO;
    CGRect frame = [self.tableContainerView convertRect:self.myCustomView.bounds fromView:self.myCustomView];

    self.myCustomView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.tableContainerView addSubview:self.myCustomView];
    [self.tableContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:kNilOptions metrics:nil views:@{@"v": self.myCustomView}]];
    [self.tableContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:kNilOptions metrics:nil views:@{@"v": self.myCustomView}]];
    self.myCustomView.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate willDisappear];
}

- (void)updateData {
    [self updateContainerHeight];
}

- (void)updateContainerHeight {
    _heightConstraint.constant = self.contentHeight;
    [self.containerView layoutIfNeeded];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _leftConstraint.active = NO;
    _rightConstraint.active = NO;
    _leftConstraint.constant = contentInset.left;
    _rightConstraint.constant = contentInset.right;
    _leftConstraint.active = YES;
    _rightConstraint.active = YES;
    [self.view layoutIfNeeded];
}
    
-(void)setContentHeight:(CGFloat)contentHeight {
    _contentHeight = contentHeight;
    [self updateContainerHeight];
}

- (UIEdgeInsets)contentInset {
    return UIEdgeInsetsMake(_topConstraint.constant, _leftConstraint.constant, 0, _rightConstraint.constant);
}

- (void)insertSeparatorView:(UIView *)separator {
    [self.separatorContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat height = 0;
    if (separator != nil) {
        height = separator.frame.size.height;
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        separator.frame = self.separatorContainerView.bounds;
        [self.separatorContainerView addSubview:separator];
    }
    
    _topConstraint.constant = height;
    
    [self updateSeparatorViewOffset];
}

- (void)updateSeparatorViewOffset {
    for (UIView *separator in self.separatorContainerView.subviews) {
        separator.frame = CGRectOffset(self.separatorContainerView.bounds,
                                       self.separatorViewOffset.horizontal, self.separatorViewOffset.vertical);
    }
}

- (void)setSeparatorViewOffset:(UIOffset)separatorViewOffset {
    _separatorViewOffset = separatorViewOffset;
    [self updateSeparatorViewOffset];
}

#pragma mark - Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.tableContainerView]) {
        return NO;
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate didTapBlankArea];
}

@end



#pragma mark - Transition -

static const CGFloat jkScrollViewBottomSpace = 5;

@interface JDropdownMenuTransition : NSObject {
    CGFloat _previousScrollViewBottomInset;
}
@property (assign, nonatomic) NSTimeInterval duration;
@property (readonly, nonatomic) BOOL isAnimating;
@property (weak, nonatomic) JDropdownMenu *menu;
@property (weak, nonatomic) JDropdownMenuContentViewController *controller;
@property (weak, nonatomic) UIView *containerView;
@end

@implementation JDropdownMenuTransition

- (instancetype)initWithDropdownMenu:(JDropdownMenu *)menu
               contentViewController:(JDropdownMenuContentViewController *)controller {
    self = [super init];
    if (self) {
        self.menu = menu;
        self.controller = controller;
        self.duration = jkAnimationDuration;
        _previousScrollViewBottomInset = CGFLOAT_MAX;
    }
    return self;
}

- (void)presentDropdownInContainerView:(UIView *)containerView animated:(BOOL)animated completion:(void (^)())completion {
    
    self.containerView = containerView;
    
    [self.controller beginAppearanceTransition:YES animated:animated];
    
    CGRect frame = [containerView convertRect:self.menu.bounds fromView:self.menu];
    CGFloat topOffset = CGRectGetMaxY(frame);
    CGFloat height = CGRectGetHeight(containerView.bounds);
    
    void (^scrollViewAdjustBlock)() = ^{};
    
    if ([containerView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)containerView;
        
        CGFloat contentHeight = self.controller.contentHeight;
        CGFloat contentMaxY = topOffset + contentHeight + jkScrollViewBottomSpace;
        
        CGFloat inset = contentMaxY - scrollView.contentSize.height - scrollView.contentInset.bottom;
        CGFloat offset = contentMaxY - scrollView.bounds.size.height;
        
        height = MAX(height - scrollView.contentInset.top, scrollView.contentSize.height + scrollView.contentInset.bottom);
        
        if (_menu.adjustsContentInset) {
            height = MAX(height, contentMaxY);
        }
        
        scrollViewAdjustBlock = ^{
            if (_menu.adjustsContentInset && inset > 0) {
                _previousScrollViewBottomInset = scrollView.contentInset.bottom;
                UIEdgeInsets contentInset = scrollView.contentInset;
                contentInset.bottom += inset;
                scrollView.contentInset = contentInset;
            }
            if (_menu.adjustsContentOffset && scrollView.contentOffset.y < offset) {
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, offset);
            }
        };
    }
    
    self.controller.view.frame = CGRectMake(CGRectGetMinX(containerView.bounds), topOffset,
                                            CGRectGetWidth(containerView.bounds), height - topOffset);
    
    [containerView addSubview:self.controller.view];
    [self.controller.view layoutIfNeeded];
    
    if (!animated) {
        scrollViewAdjustBlock();
        [self.controller endAppearanceTransition];
        if (completion) {
            completion();
        }
        return;
    }
    
    CGAffineTransform t = CGAffineTransformMakeScale(1.0, 0.5);
    t = CGAffineTransformTranslate(t, 0, -2 * CGRectGetHeight(self.controller.containerView.frame));
    self.controller.containerView.transform = t;
    
    self.controller.view.alpha = 0.0;
    
    _isAnimating = YES;
    
    [UIView animateWithDuration:self.duration
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:kNilOptions
                     animations:^{
                         self.controller.view.alpha = 1.0;
                         self.controller.containerView.transform = CGAffineTransformIdentity;
                         scrollViewAdjustBlock();
                     }
                     completion:^(BOOL finished) {
                         [self.controller endAppearanceTransition];
                         _isAnimating = NO;
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)dismissDropdownAnimated:(BOOL)animated completion:(void (^)())completion {
    
    [self.controller beginAppearanceTransition:NO animated:animated];
    
    void (^scrollViewResetBlock)() = ^{};
    
    if ([self.containerView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.containerView;
        scrollViewResetBlock = ^{
            if (_previousScrollViewBottomInset != CGFLOAT_MAX) {
                UIEdgeInsets contentInset = scrollView.contentInset;
                contentInset.bottom = _previousScrollViewBottomInset;
                scrollView.contentInset = contentInset;
                _previousScrollViewBottomInset = CGFLOAT_MAX;
            }
        };
    }
    
    if (!animated) {
        scrollViewResetBlock();
        [self.controller.view removeFromSuperview];
        [self.controller endAppearanceTransition];
        if (completion) {
            completion();
        }
        return;
    }
    
    CGAffineTransform t = CGAffineTransformMakeScale(1.0, 0.5);
    t = CGAffineTransformTranslate(t, 0, -2 * CGRectGetHeight(self.controller.containerView.frame));
    
    _isAnimating = YES;
    
    [UIView animateWithDuration:self.duration
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:kNilOptions
                     animations:^{
                         self.controller.view.alpha = 0.0;
                         self.controller.containerView.transform = t;
                         scrollViewResetBlock();
                     }
                     completion:^(BOOL finished) {
                         [self.controller.view removeFromSuperview];
                         self.controller.view.alpha = 1.0;
                         self.controller.containerView.transform = CGAffineTransformIdentity;
                         [self.controller endAppearanceTransition];
                         _isAnimating = NO;
                         if (completion) {
                             completion();
                         }
                     }];
    
    self.containerView = nil;
}

@end




#pragma mark - Dropdown Menu -

@interface JDropdownMenu () <JDropdownMenuContentViewControllerDelegate>

@property (strong, nonatomic) JDropdownMenuTransition *transition;

@property (strong, nonatomic) JDropdownMenuContentViewController *contentViewController;
@property (strong, nonatomic) NSMutableArray<UIView *> *separators;

@property (nonatomic) BOOL isComponentOpened;
@end

@implementation JDropdownMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.contentViewController = [JDropdownMenuContentViewController new];
    self.contentViewController.delegate = self;
    
    // load content view
    [self.contentViewController view];
    
    self.transition = [[JDropdownMenuTransition alloc] initWithDropdownMenu:self
                                                       contentViewController:self.contentViewController];
    
    _adjustsContentInset = YES;
    _adjustsContentOffset = NO;
    
    self.separators = [NSMutableArray new];
}

- (void)updateComponentSeparator {
    UIColor *separatorColor = self.componentSeparatorColor
    ? self.componentSeparatorColor : [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];
    
    [self.separators enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.backgroundColor = separatorColor;
        [self bringSubviewToFront:obj];
    }];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window != nil) {
        [self reloadComponent];
    }
}

- (void)layoutComponentSeparator {
    [self.separators enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        CGRect btnFrame = self.frame;
        obj.frame = CGRectMake(CGRectGetMaxX(btnFrame) - 0.25, CGRectGetMinY(btnFrame), 0.5, CGRectGetHeight(btnFrame));
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self layoutComponentSeparator];
    
    if (!self.isComponentOpened) {
        self.contentViewController.contentInset = [self contentInsetForSelectedComponent];
    }
}

#pragma mark - Properties

-(void)setContentHeight:(CGFloat)contentHeight {
    self.contentViewController.contentHeight = contentHeight;
}
    
- (void)setDropdownDropsShadow:(BOOL)dropdownDropsShadow {
    self.contentViewController.shadowView.hidden = !dropdownDropsShadow;
    self.contentViewController.tableContainerView.backgroundColor = dropdownDropsShadow ? [UIColor blackColor] : [UIColor clearColor];
}

- (BOOL)dropdownDropsShadow {
    return !self.contentViewController.shadowView.hidden;
}

- (void)setBackgroundDimmingOpacity:(CGFloat)backgroundDimmingOpacity {
    self.contentViewController.view.backgroundColor = [UIColor colorWithWhite:(backgroundDimmingOpacity < 0 ? 1.0 : 0.0)
                                                                        alpha:fabs(backgroundDimmingOpacity)];
}

- (CGFloat)backgroundDimmingOpacity {
    CGFloat white = 0.0;
    CGFloat alpha = 0.0;
    [self.contentViewController.view.backgroundColor getWhite:&white alpha:&alpha];
    return (white == 1.0 ? -alpha : alpha);
}

- (void)setSpacerView:(UIView *)spacerView {
    _spacerView = spacerView;
    [self.contentViewController insertSeparatorView:spacerView];
}

- (void)setSpacerViewOffset:(UIOffset)spacerViewOffset {
    self.contentViewController.separatorViewOffset = spacerViewOffset;
}
    
-(void)setContainerCustomView:(UIView * _Nonnull)containerCustomView {
    self.contentViewController.myCustomView = containerCustomView;
}

- (UIOffset)spacerViewOffset {
    return self.contentViewController.separatorViewOffset;
}

- (void)setDropdownCornerRadius:(CGFloat)dropdownCornerRadius {
    self.contentViewController.cornerRadius = dropdownCornerRadius;
    [self.contentViewController updateMask];
}

- (CGFloat)dropdownCornerRadius {
    return self.contentViewController.cornerRadius;
}

- (void)setDropdownRoundedCorners:(UIRectCorner)dropdownRoundedCorners {
    self.contentViewController.roundedCorners = dropdownRoundedCorners;
    [self.contentViewController updateMask];
}

- (UIRectCorner)dropdownRoundedCorners {
    return self.contentViewController.roundedCorners;
}

#pragma mark - Public Methods

- (void)reloadComponent {
    [self setNeedsLayout];
    [self.contentViewController updateData];
}

- (void)openComponentAnimated:(BOOL)animated {
    self.isComponentOpened = YES;
    [self presentDropdownForSelectedComponentAnimated:animated completion:nil];
    if ([self.delegate respondsToSelector:@selector(dropdownMenuComponentDidOpen:)]) {
        [self.delegate dropdownMenuComponentDidOpen:self];
    }
}

- (void)closeComponentAnimated:(BOOL)animated {
    [self dismissDropdownAnimated:animated completion:^{
        if ([self.delegate respondsToSelector:@selector(dropdownMenuComponentDidClose:)]) {
            [self.delegate dropdownMenuComponentDidClose:self];
        }
    }];
    [self cleanupComponent];
    
}

- (void)bringDropdownViewToFront {
    [self.contentViewController.view.superview bringSubviewToFront:self.contentViewController.view];
}

#pragma mark - Private

- (UIEdgeInsets)contentInsetForSelectedComponent {
    if (!self.isComponentOpened) {
        return UIEdgeInsetsZero;
    }
    
    UIView *presentingView = [self containerView];

    CGFloat left = 0;
    CGFloat right = 0;
    
    left = CGRectGetMinX(presentingView.bounds) + self.fullScreenInsetLeft;
    right = CGRectGetMaxX(presentingView.bounds) - self.fullScreenInsetRight;
    
    return UIEdgeInsetsMake(0, left, 0, CGRectGetWidth(presentingView.bounds) - right + 0.5);
}

- (void)cleanupComponent {
    if (!self.isComponentOpened && [self.delegate respondsToSelector:@selector(dropdownMenuComponentDidClose:)]) {
        [self.delegate dropdownMenuComponentDidClose:self];
    }
    self.isComponentOpened = NO;
}

#pragma mark - Dropdown Presenting & Dismissing

- (UIView *)containerView {
    return self.presentingView ? self.presentingView : self.window;
}

- (void)presentDropdownForSelectedComponentAnimated:(BOOL)animated completion:(void (^)())completion {
    if (!self.isComponentOpened) {
        if (completion) {
            completion();
        }
        return;
    }
    
    UIView *presentingView = [self containerView];
    
    self.contentViewController.contentInset = [self contentInsetForSelectedComponent];
    
    [self.transition presentDropdownInContainerView:presentingView animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)dismissDropdownAnimated:(BOOL)animated completion:(void (^)())completion {
    if (self.contentViewController.view.window == nil) {
        if (completion) {
            completion();
        }
        return;
    }
    
    [self.transition dismissDropdownAnimated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - DropdownMenuContentViewControllerDelegate
    
- (void)didTapBlankArea {
    if (self.transition.isAnimating) {
        return;
    }

    [self closeComponentAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(dropdownMenuComponentDidTapBlankArea:)]) {
        [self.delegate dropdownMenuComponentDidTapBlankArea:self];
    }
}


- (void)willDisappear {
    if (!self.isComponentOpened) {
        [self cleanupComponent];
    }
}

@end
