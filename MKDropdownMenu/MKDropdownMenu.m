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

#import "MKDropdownMenu.h"

#pragma mark - Constants -

static const NSTimeInterval kAnimationDuration = 0.25;

static const CGFloat kDefaultRowHeight = 44;
static const CGFloat kDefaultDisclosureIndicatorSize = 8;
static const CGFloat kDefaultCornerRadius = 2;
static const CGFloat kDefaultBackgroundDimmingOpacity = 0.2;

static const CGFloat kShadowOpacity = 0.2;

static NSString * const kCellIdentifier = @"cell";


@interface UIColor (MKDropdownMenu)
+ (UIColor *)mk_defaultSeparatorColor;
@end

@implementation UIColor (MKDropdownMenu)
+ (UIColor *)mk_defaultSeparatorColor {
    return [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];
}
@end


#pragma mark - Component Button -

static UIImage * MKDropdownMenuDisclosureIndicatorImage() {
    CGFloat a = kDefaultDisclosureIndicatorSize;
    CGFloat h = a * 0.866;
    CGRect rect = CGRectMake(0, a - h, a, h);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(a, a), NO, 0);
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    [path closePath];
    [[UIColor blackColor] setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


@interface MKDropdownMenuComponentButton : UIButton
@property (readonly, nonatomic) UIImageView *disclosureIndicatorView;
@property (readonly, nonatomic) UIView *containerView;
@property (readonly, nonatomic) UIView *currentCustomView;
@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (assign, nonatomic) CGFloat disclosureIndicatorAngle;
- (void)setAttributedTitle:(NSAttributedString *)title selectedTitle:(NSAttributedString *)selectedTitle;
- (void)setCustomView:(UIView *)customView;
- (void)setDisclosureIndicatorImage:(UIImage *)image;
@end

@implementation MKDropdownMenuComponentButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

static UIImage *disclosureIndicatorImage = nil;

- (void)setup {
    self.clipsToBounds = YES;
    
    _containerView = [UIView new];
    _containerView.frame = self.bounds;
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_containerView];
    
    _disclosureIndicatorView = [UIImageView new];
    _disclosureIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_disclosureIndicatorView];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_disclosureIndicatorView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:8],
                           [NSLayoutConstraint constraintWithItem:_disclosureIndicatorView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]]];
}

- (UIView *)currentCustomView {
    return self.containerView.subviews.lastObject;
}

- (void)setCustomView:(UIView *)customView {
    if (self.currentCustomView != customView) {
        [self.currentCustomView removeFromSuperview];
        customView.frame = self.containerView.bounds;
        customView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.containerView addSubview:customView];
    }
    self.containerView.hidden = NO;
    [self setAttributedTitle:nil selectedTitle:nil];
}

- (void)setAttributedTitle:(NSAttributedString *)title selectedTitle:(NSAttributedString *)selectedTitle {
    [self setAttributedTitle:title forState:UIControlStateNormal];
    [self setAttributedTitle:selectedTitle forState:UIControlStateSelected];
    [self setAttributedTitle:selectedTitle forState:UIControlStateSelected|UIControlStateHighlighted];
    if (title != nil) {
        [self.currentCustomView removeFromSuperview];
        self.containerView.hidden = YES;
    }
}

- (void)setDisclosureIndicatorImage:(UIImage *)image {
    if (image == nil) {
        if (disclosureIndicatorImage == nil) {
            disclosureIndicatorImage = MKDropdownMenuDisclosureIndicatorImage();
        }
        image = disclosureIndicatorImage;
    }
    
    self.disclosureIndicatorView.image = image;
    [self.disclosureIndicatorView sizeToFit];
    CGFloat insetLeft = 8;
    CGFloat insetRight = (image.size.width > 0) ? image.size.width + 4 + insetLeft : insetLeft;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, insetLeft, 0, insetRight);
    [self setNeedsLayout];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    switch (textAlignment) {
        case NSTextAlignmentLeft:
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            break;
        case NSTextAlignmentRight:
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            break;
        case NSTextAlignmentCenter:
        default:
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            break;
    }
}

- (NSTextAlignment)textAlignment {
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft:
            return NSTextAlignmentLeft;
        case UIControlContentHorizontalAlignmentRight:
            return NSTextAlignmentRight;
        case UIControlContentHorizontalAlignmentCenter:
        default:
            return NSTextAlignmentCenter;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.disclosureIndicatorView.transform = CGAffineTransformMakeRotation(selected ? self.disclosureIndicatorAngle : 0.0);
    self.backgroundColor = selected ? self.selectedBackgroundColor : nil;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.disclosureIndicatorView.hidden = !enabled;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *targetView = [super hitTest:point withEvent:event];
    if (CGRectContainsPoint(self.bounds, point) && ![targetView isKindOfClass:[UIControl class]]) {
        return self;
    }
    return targetView;
}

@end



#pragma mark - Table View Cell -

@interface MKDropdownMenuTableViewCell : UITableViewCell
@property (readonly, nonatomic) UIView *containerView;
@property (readonly, nonatomic) UIView *currentCustomView;
- (void)setAttributedTitle:(NSAttributedString *)attributedTitle;
- (void)setCustomView:(UIView *)customView;
@end

@implementation MKDropdownMenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = YES;
    
    _containerView = [UIView new];
    _containerView.frame = self.contentView.bounds;
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _containerView.userInteractionEnabled = YES;
    [self.contentView addSubview:_containerView];
}

- (UIView *)currentCustomView {
    return self.containerView.subviews.lastObject;
}

- (void)setCustomView:(UIView *)customView {
    if (customView == nil) {
        [self.currentCustomView removeFromSuperview];
        self.containerView.hidden = YES;
    } else if (self.currentCustomView != customView) {
        [self.currentCustomView removeFromSuperview];
        customView.frame = self.containerView.bounds;
        customView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.containerView addSubview:customView];
    }
    self.containerView.hidden = NO;
    [self setAttributedTitle:nil];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    self.textLabel.attributedText = attributedTitle;
}

- (void)setHighlightColor:(UIColor *)color {
    if (color != nil) {
        UIView *selectionView = [UIView new];
        selectionView.backgroundColor = color;
        self.selectedBackgroundView = selectionView;
    } else {
        self.selectedBackgroundView = nil;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.currentCustomView removeFromSuperview];
    self.containerView.hidden = YES;
}

@end



#pragma mark - Content Controller -

@class MKDropdownMenuContentViewController;

#pragma mark Delegate Protocol

@protocol MKDropdownMenuContentViewControllerDelegate <NSObject>
- (NSInteger)numberOfRows;
- (NSInteger)maximumNumberOfRows;
- (NSAttributedString *)attributedTitleForRow:(NSInteger)row;
- (UIView *)customViewForRow:(NSInteger)row reusingView:(UIView *)view;
- (UIView *)accessoryViewForRow:(NSInteger)row;
- (UIColor *)backgroundColorForRow:(NSInteger)row;
- (void)didSelectRow:(NSInteger)row;
- (void)willDisappear;
@end

#pragma mark Controller

@interface MKDropdownMenuContentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
    NSLayoutConstraint *_heightConstraint;
    NSLayoutConstraint *_topConstraint;
    NSLayoutConstraint *_leftConstraint;
    NSLayoutConstraint *_rightConstraint;
}
@property (weak, nonatomic) id<MKDropdownMenuContentViewControllerDelegate> delegate;

@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) UIView *shadowView;

@property (strong, nonatomic) UIView *borderView;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (assign, nonatomic) BOOL showsBorder;

@property (strong, nonatomic) UIView *tableContainerView;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIView *separatorContainerView;
@property (assign, nonatomic) UIOffset separatorViewOffset;
@property (assign, nonatomic) BOOL showsTopRowSeparator;

@property (strong, nonatomic) UIColor *highlightColor;

@property (assign, nonatomic) UIEdgeInsets contentInset;

@property (assign, nonatomic) NSTextAlignment textAlignment;

@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) UIRectCorner roundedCorners;

@property (assign, nonatomic) NSInteger rowsCount;
@property (assign, nonatomic) NSInteger maxRows;
@property (readonly, nonatomic) CGFloat maxHeight;
@property (readonly, nonatomic) CGFloat contentHeight;

@end

@implementation MKDropdownMenuContentViewController

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
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:kDefaultBackgroundDimmingOpacity];
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
    self.cornerRadius = kDefaultCornerRadius;
    self.roundedCorners = UIRectCornerBottomLeft|UIRectCornerBottomRight;
    
    
    // Table View
    
    self.tableView = [UITableView new];
    self.tableView.clipsToBounds = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = kDefaultRowHeight;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor mk_defaultSeparatorColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.showsTopRowSeparator = YES;
    
    [self.tableView registerClass:[MKDropdownMenuTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    
    // Shadow
    
    self.shadowView = [UIView new];
    self.shadowView.clipsToBounds = NO;
    self.shadowView.backgroundColor = [UIColor clearColor];
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.shadowView.layer.shadowOpacity = kShadowOpacity;
    self.shadowView.layer.shadowRadius = kDefaultCornerRadius;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 1);
    
    
    // Separator
    
    self.separatorContainerView = [UIView new];
    self.separatorContainerView.clipsToBounds = NO;
    self.separatorContainerView.backgroundColor = [UIColor clearColor];
    self.separatorContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    // Border
    
    self.borderView = [UIView new];
    self.borderView.backgroundColor = [UIColor clearColor];
    self.borderView.userInteractionEnabled = NO;
    self.borderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.frame = self.tableContainerView.bounds;
    self.borderLayer.fillColor = [[UIColor clearColor] CGColor];
    self.borderLayer.strokeColor = [[UIColor mk_defaultSeparatorColor] CGColor];
    self.borderLayer.lineWidth = 1;
    
    [self.borderView.layer addSublayer:self.borderLayer];
    
    self.borderView.hidden = YES;
    
    
    /* Add subviews */
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.shadowView];
    [self.containerView addSubview:self.borderView];
    [self.containerView addSubview:self.separatorContainerView];
    [self.containerView addSubview:self.tableContainerView];
    [self.tableContainerView addSubview:self.tableView];
    
    
    /* Setup constraints */
    
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self.tableContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kDefaultRowHeight];
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
    
    [self.tableContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:kNilOptions metrics:nil views:@{@"v": self.tableView}]];
    [self.tableContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:kNilOptions metrics:nil views:@{@"v": self.tableView}]];
    
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
    
    [self.containerView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.borderView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:self.borderView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.borderView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:self.tableContainerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.borderView
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
    self.shadowView.layer.shadowRadius = MAX(r, kDefaultCornerRadius);
    
    self.borderLayer.path = maskPath.CGPath;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
    self.tableView.contentOffset = CGPointZero;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate willDisappear];
}

- (void)updateData {
    self.rowsCount = [self.delegate numberOfRows];
    self.maxRows = [self.delegate maximumNumberOfRows];
    [self updateContainerHeight];
    [self.tableView reloadData];
}

- (void)updateDataAtIndexes:(NSIndexSet *)indexes {
    NSMutableArray *indexPaths = [NSMutableArray new];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)updateContainerHeight {
    _heightConstraint.constant = self.contentHeight;
    [self.containerView layoutIfNeeded];
}

- (CGFloat)maxHeight {
    NSInteger limit = (self.maxRows > 0) ? self.maxRows : NSIntegerMax;
    limit = MIN(limit, self.view.bounds.size.height / self.tableView.rowHeight);
    return limit * self.tableView.rowHeight;
}

- (CGFloat)contentHeight {
    return MIN(MAX(self.rowsCount * self.tableView.rowHeight, 0), self.maxHeight)
    + self.tableView.tableHeaderView.frame.size.height;
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

- (void)setShowsTopRowSeparator:(BOOL)showsTopRowSeparator {
    if (showsTopRowSeparator) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
        header.backgroundColor = self.tableView.separatorColor;
        self.tableView.tableHeaderView = header;
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

- (BOOL)showsTopRowSeparator {
    return self.tableView.tableHeaderView != nil;
}

- (void)setShowsBorder:(BOOL)showsBorder {
    self.borderView.hidden = !showsBorder;
}

- (BOOL)showsBorder {
    return !self.borderView.hidden;
}

#pragma mark - Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.tableView]) {
        return NO;
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate didSelectRow:NSNotFound];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKDropdownMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    UIView *customView = cell.currentCustomView;
    customView = [self.delegate customViewForRow:indexPath.row reusingView:customView];
    
    [cell setCustomView:customView];
    if (customView == nil) {
        NSAttributedString *attributedTitle = [self.delegate attributedTitleForRow:indexPath.row];
        [cell setAttributedTitle:attributedTitle];
    }
    
    [cell setHighlightColor:self.highlightColor];
    
    cell.backgroundColor = [self.delegate backgroundColorForRow:indexPath.row];
    
    cell.accessoryView = [self.delegate accessoryViewForRow:indexPath.row];
    
    cell.textLabel.textAlignment = self.textAlignment;
    
    cell.layoutMargins = UIEdgeInsetsZero;
    
    if (self.showsBorder && indexPath.row == self.rowsCount - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(tableView.bounds), 0, 0);
    } else {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate didSelectRow:indexPath.row];
}

@end



#pragma mark - Transition -

static const CGFloat kScrollViewBottomSpace = 5;

@interface MKDropdownMenuTransition : NSObject {
    CGFloat _previousScrollViewBottomInset;
}
@property (assign, nonatomic) NSTimeInterval duration;
@property (readonly, nonatomic) BOOL isAnimating;
@property (weak, nonatomic) MKDropdownMenu *menu;
@property (weak, nonatomic) MKDropdownMenuContentViewController *controller;
@property (weak, nonatomic) UIView *containerView;
@end

@implementation MKDropdownMenuTransition

- (instancetype)initWithDropdownMenu:(MKDropdownMenu *)menu
               contentViewController:(MKDropdownMenuContentViewController *)controller {
    self = [super init];
    if (self) {
        self.menu = menu;
        self.controller = controller;
        self.duration = kAnimationDuration;
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
        CGFloat contentMaxY = topOffset + contentHeight + kScrollViewBottomSpace;
        
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

@interface MKDropdownMenu () <MKDropdownMenuContentViewControllerDelegate>

@property (strong, nonatomic) MKDropdownMenuTransition *transition;

@property (strong, nonatomic) MKDropdownMenuContentViewController *contentViewController;
@property (strong, nonatomic) NSMutableArray<MKDropdownMenuComponentButton *> *buttons;
@property (strong, nonatomic) NSMutableArray<UIView *> *separators;

@property (strong, nonatomic) NSMutableArray<NSNumber *> *components;
@property (assign, nonatomic) NSInteger selectedComponent;
@property (strong, nonatomic) NSMutableArray<NSMutableIndexSet *> *selectedRows;

@end

@implementation MKDropdownMenu

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
    self.contentViewController = [MKDropdownMenuContentViewController new];
    self.contentViewController.delegate = self;
    
    // load content view
    [self.contentViewController view];
    
    self.transition = [[MKDropdownMenuTransition alloc] initWithDropdownMenu:self
                                                       contentViewController:self.contentViewController];
    
    _selectedComponent = NSNotFound;
    
    _componentTextAlignment = NSTextAlignmentCenter;
    
    _adjustsContentInset = YES;
    _adjustsContentOffset = NO;
    
    _disclosureIndicatorSelectionRotation = M_PI;
    
    self.components = [NSMutableArray new];
    self.selectedRows = [NSMutableArray new];
    self.buttons = [NSMutableArray new];
    self.separators = [NSMutableArray new];
}

- (void)setupComponents {
    if (self.dataSource == nil) {
        return;
    }
    
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfComponentsInDropdownMenu:)], @"required method `numberOfComponentsInDropdownMenu:` in data source not implemented");
    
    NSInteger numberOfComponents = [self.dataSource numberOfComponentsInDropdownMenu:self];
    
    [self.components removeAllObjects];
    [self.selectedRows removeAllObjects];
    
    NSAssert([self.dataSource respondsToSelector:@selector(dropdownMenu:numberOfRowsInComponent:)], @"required method `dropdownMenu:numberOfRowsInComponent:` in data source not implemented");
    
    for (NSInteger i = 0; i < numberOfComponents; i++) {
        NSInteger numberOfRows = [self.dataSource dropdownMenu:self numberOfRowsInComponent:i];
        [self.components addObject:@(numberOfRows)];
        [self.selectedRows addObject:[NSMutableIndexSet new]];
        if (self.buttons.count <= i) {
            MKDropdownMenuComponentButton *button = [MKDropdownMenuComponentButton new];
            [self.buttons addObject:button];
            [self addSubview:button];
            [button addTarget:self action:@selector(selectedComponent:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (i < numberOfComponents - 1 && self.separators.count <= i) {
            UIView *separator = [UIView new];
            [self.separators addObject:separator];
            [self addSubview:separator];
        }
    }
    while (self.buttons.count > numberOfComponents) {
        MKDropdownMenuComponentButton *button = self.buttons.lastObject;
        [button removeFromSuperview];
        [self.buttons removeLastObject];
    }
    while (self.separators.count > numberOfComponents - 1) {
        UIView *separator = self.separators.lastObject;
        [separator removeFromSuperview];
        [self.separators removeLastObject];
    }
}

- (void)updateComponentButtons {
    [self.buttons enumerateObjectsUsingBlock:^(MKDropdownMenuComponentButton *btn, NSUInteger idx, BOOL *stop) {
        [self updateButton:btn forComponent:idx];
    }];
    [self updateComponentSeparators];
}

- (void)updateButton:(MKDropdownMenuComponentButton *)button forComponent:(NSInteger)component {
    BOOL enabled = YES;
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:enableComponent:)]) {
        enabled = [self.delegate dropdownMenu:self enableComponent:component];
    }
    [button setEnabled:enabled];
    
    [button setTextAlignment:self.componentTextAlignment];
    [button setDisclosureIndicatorImage:self.disclosureIndicatorImage];
    [button setSelectedBackgroundColor:self.selectedComponentBackgroundColor];
    [button setDisclosureIndicatorAngle:self.disclosureIndicatorSelectionRotation];
    
    UIView *customView = button.currentCustomView;
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:viewForComponent:)]) {
        customView = [self.delegate dropdownMenu:self viewForComponent:component];
    }
    
    if (customView != nil) {
        
        [button setCustomView:customView];
        
    } else {
        
        NSAttributedString *attributedTitle = nil;
        
        if ([self.delegate respondsToSelector:@selector(dropdownMenu:attributedTitleForComponent:)]) {
            attributedTitle = [self.delegate dropdownMenu:self attributedTitleForComponent:component];
        }
        
        if (attributedTitle == nil && [self.delegate respondsToSelector:@selector(dropdownMenu:titleForComponent:)]) {
            NSString *title = [self.delegate dropdownMenu:self titleForComponent:component];
            if (title != nil) {
                attributedTitle = [[NSAttributedString alloc] initWithString:title];
            }
        }
        
        NSAttributedString *attributedSelectedTitle = nil;
        
        if (attributedTitle != nil) {
            
            if ([self.delegate respondsToSelector:@selector(dropdownMenu:attributedTitleForSelectedComponent:)]) {
                attributedSelectedTitle = [self.delegate dropdownMenu:self attributedTitleForSelectedComponent:component];
            }
            
            if (attributedSelectedTitle == nil && [self.delegate respondsToSelector:@selector(dropdownMenu:titleForSelectedComponent:)]) {
                NSString *selectedTitle = [self.delegate dropdownMenu:self titleForSelectedComponent:component];
                if (selectedTitle != nil) {
                    attributedSelectedTitle = [[NSAttributedString alloc] initWithString:selectedTitle];
                }
            }
            
        }
        
        [button setAttributedTitle:attributedTitle selectedTitle:attributedSelectedTitle];
    }
}

- (void)updateComponentSeparators {
    UIColor *separatorColor = self.componentSeparatorColor
    ? self.componentSeparatorColor : [UIColor mk_defaultSeparatorColor];
    
    [self.separators enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.backgroundColor = separatorColor;
        [self bringSubviewToFront:obj];
    }];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window != nil) {
        [self reloadAllComponents];
    }
}

- (void)setDataSource:(id<MKDropdownMenuDataSource>)dataSource {
    _dataSource = dataSource;
    if (self.window != nil) {
        [self reloadAllComponents];
    }
}

- (void)layoutComponentButtons {
    if (self.buttons.count == 0) {
        return;
    }
    
    CGFloat totalCustomWidth = 0;
    NSInteger customWidthsCount = 0;
    
    NSMutableArray *widths = [NSMutableArray new];
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:widthForComponent:)]) {
        for (NSInteger i = 0; i < self.buttons.count; i++) {
            CGFloat width = [self.delegate dropdownMenu:self widthForComponent:i];
            [widths addObject:@(width)];
            if (width > 0) {
                totalCustomWidth += width;
                customWidthsCount++;
            }
        }
    }
    
    CGFloat defaultWidth = self.bounds.size.width / self.buttons.count;
    if (customWidthsCount > 0 && self.buttons.count > customWidthsCount) {
        defaultWidth = (self.bounds.size.width - totalCustomWidth) / (self.buttons.count - customWidthsCount);
    }
    
    NSAssert(totalCustomWidth <= self.bounds.size.width, @"total width for components (%.1f) must not be greater than view bounds width (%.1f)", totalCustomWidth, self.bounds.size.width);
    
    __block CGFloat dx = 0;
    [self.buttons enumerateObjectsUsingBlock:^(MKDropdownMenuComponentButton *btn, NSUInteger idx, BOOL *stop) {
        CGFloat width = 0;
        if (idx == self.buttons.count - 1) {
            width = self.bounds.size.width - dx;
        } else {
            if (idx < widths.count) {
                width = [widths[idx] floatValue];
            }
        }
        if (width <= 0) {
            width = defaultWidth;
        }
        btn.frame = CGRectMake(dx, 0, width, self.bounds.size.height);
        dx += width;
    }];
}

- (void)layoutComponentSeparators {
    [self.separators enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        CGRect btnFrame = self.buttons[idx].frame;
        obj.frame = CGRectMake(CGRectGetMaxX(btnFrame) - 0.25, CGRectGetMinY(btnFrame), 0.5, CGRectGetHeight(btnFrame));
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutComponentButtons];
    [self layoutComponentSeparators];
    
    if (self.selectedComponent != NSNotFound) {
        self.contentViewController.contentInset = [self contentInsetForSelectedComponent];
    }
}

#pragma mark - Properties

- (void)setDropdownDropsShadow:(BOOL)dropdownDropsShadow {
    self.contentViewController.shadowView.hidden = !dropdownDropsShadow;
    self.contentViewController.tableContainerView.backgroundColor = dropdownDropsShadow ? [UIColor blackColor] : [UIColor clearColor];
}

- (BOOL)dropdownDropsShadow {
    return !self.contentViewController.shadowView.hidden;
}

- (void)setDropdownBouncesScroll:(BOOL)dropdownBouncesScroll {
    self.contentViewController.tableView.bounces = dropdownBouncesScroll;
}

- (BOOL)dropdownBouncesScroll {
    return self.contentViewController.tableView.bounces;
}

- (void)setDropdownShowsTopRowSeparator:(BOOL)dropdownShowsTopRowSeparator {
    self.contentViewController.showsTopRowSeparator = dropdownShowsTopRowSeparator;
}

- (BOOL)dropdownShowsTopRowSeparator {
    return self.contentViewController.showsTopRowSeparator;
}

- (void)setDropdownShowsBorder:(BOOL)dropdownShowsBorder {
    self.contentViewController.showsBorder = dropdownShowsBorder;
}

- (BOOL)dropdownShowsBorder {
    return self.contentViewController.showsBorder;
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

- (void)setComponentSeparatorColor:(UIColor *)componentSeparatorColor {
    _componentSeparatorColor = componentSeparatorColor;
    [self updateComponentSeparators];
}

- (void)setRowSeparatorColor:(UIColor *)rowSeparatorColor {
    _rowSeparatorColor = rowSeparatorColor;
    UIColor *separatorColor = rowSeparatorColor ? rowSeparatorColor : [UIColor mk_defaultSeparatorColor];
    self.contentViewController.tableView.separatorColor = separatorColor;
    self.contentViewController.tableView.tableHeaderView.backgroundColor = separatorColor;
    self.contentViewController.borderLayer.strokeColor = separatorColor.CGColor;
}

- (void)setSpacerView:(UIView *)spacerView {
    _spacerView = spacerView;
    [self.contentViewController insertSeparatorView:spacerView];
}

- (void)setSpacerViewOffset:(UIOffset)spacerViewOffset {
    self.contentViewController.separatorViewOffset = spacerViewOffset;
}

- (UIOffset)spacerViewOffset {
    return self.contentViewController.separatorViewOffset;
}

- (void)setComponentTextAlignment:(NSTextAlignment)componentTextAlignment {
    _componentTextAlignment = componentTextAlignment;
    [self updateComponentButtons];
}

- (void)setRowTextAlignment:(NSTextAlignment)rowTextAlignment {
    self.contentViewController.textAlignment = rowTextAlignment;
    [self.contentViewController updateData];
}

- (NSTextAlignment)rowTextAlignment {
    return self.contentViewController.textAlignment;
}

- (void)setDisclosureIndicatorImage:(UIImage *)disclosureIndicatorImage {
    _disclosureIndicatorImage = disclosureIndicatorImage;
    [self updateComponentButtons];
}

- (void)setDisclosureIndicatorSelectionRotation:(CGFloat)disclosureIndicatorSelectionRotation {
    _disclosureIndicatorSelectionRotation = disclosureIndicatorSelectionRotation;
    [self updateComponentButtons];
}

- (void)setDropdownBackgroundColor:(UIColor *)dropdownBackgroundColor {
    self.contentViewController.tableView.backgroundColor = dropdownBackgroundColor;
}

- (UIColor *)dropdownBackgroundColor {
    return self.contentViewController.tableView.backgroundColor;
}

- (void)setSelectedComponentBackgroundColor:(UIColor *)selectedComponentBackgroundColor {
    _selectedComponentBackgroundColor = selectedComponentBackgroundColor;
    [self updateComponentButtons];
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

- (NSInteger)numberOfComponents {
    return self.components.count;
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component {
    NSAssert(component >= 0 && component < self.components.count, @"invalid component: %zd", component);
    return [self.components[component] integerValue];
}

- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.selectedComponent == NSNotFound || component != self.selectedComponent) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    if ([[self.contentViewController.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
        MKDropdownMenuTableViewCell *cell = [self.contentViewController.tableView cellForRowAtIndexPath:indexPath];
        return cell.currentCustomView;
    }
    return nil;
}

- (void)reloadAllComponents {
    [self setupComponents];
    [self updateComponentButtons];
    [self setNeedsLayout];
    [self.contentViewController updateData];
}

- (void)reloadComponent:(NSInteger)component {
    NSAssert(component >= 0 && component < self.components.count, @"invalid component: %zd", component);
    
    NSAssert([self.dataSource respondsToSelector:@selector(dropdownMenu:numberOfRowsInComponent:)], @"required method `dropdownMenu:numberOfRowsInComponent:` in data source not implemented");
    
    NSInteger numberOfRows = [self.dataSource dropdownMenu:self numberOfRowsInComponent:component];
    self.components[component] = @(numberOfRows);
    
    [self updateButton:self.buttons[component] forComponent:component];
    
    if (self.selectedComponent != NSNotFound && component == self.selectedComponent) {
        [self.contentViewController updateData];
    }
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSAssert(component >= 0 && component < self.components.count, @"invalid component: %zd", component);
    NSAssert(row >= 0 && row < [self.components[component] integerValue], @"invalid row: %zd", row);
    
    NSMutableIndexSet *indexesToUpdate = [NSMutableIndexSet new];
    
    if (!self.allowsMultipleRowsSelection) {
        [self.selectedRows[component] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [indexesToUpdate addIndex:idx];
        }];
        [self.selectedRows[component] removeAllIndexes];
    }
    
    [self.selectedRows[component] addIndex:row];
    [indexesToUpdate addIndex:row];
    
    if (component == self.selectedComponent) {
        [self.contentViewController updateDataAtIndexes:indexesToUpdate];
    }
}

- (void)deselectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSAssert(component >= 0 && component < self.components.count, @"invalid component: %zd", component);
    NSAssert(row >= 0 && row < [self.components[component] integerValue], @"invalid row: %zd", row);
    
    [self.selectedRows[component] removeIndex:row];
    
    if (component == self.selectedComponent) {
        [self.contentViewController updateDataAtIndexes:[NSIndexSet indexSetWithIndex:row]];
    }
}

- (NSIndexSet *)selectedRowsInComponent:(NSInteger)component {
    NSAssert(component >= 0 && component < self.components.count, @"invalid component: %zd", component);
    return [self.selectedRows[component] copy];
}

- (void)openComponent:(NSInteger)component animated:(BOOL)animated {
    NSAssert(component >= 0 && component < self.components.count, @"invalid component: %zd", component);
    
    NSInteger previousComponent = self.selectedComponent;
    
    void (^presentation)() = ^{
        self.selectedComponent = component;
        [self presentDropdownForSelectedComponentAnimated:animated completion:nil];
        if (component != NSNotFound && [self.delegate respondsToSelector:@selector(dropdownMenu:didOpenComponent:)]) {
            [self.delegate dropdownMenu:self didOpenComponent:component];
        }
    };
    
    if (previousComponent != NSNotFound) {
        [self dismissDropdownAnimated:animated completion:^{
            presentation();
        }];
        if ([self.delegate respondsToSelector:@selector(dropdownMenu:didCloseComponent:)]) {
            [self.delegate dropdownMenu:self didCloseComponent:previousComponent];
        }
    } else {
        presentation();
    }
}

- (void)closeAllComponentsAnimated:(BOOL)animated {
    [self dismissDropdownAnimated:animated completion:nil];
    [self cleanupSelectedComponents];
}

- (void)bringDropdownViewToFront {
    [self.contentViewController.view.superview bringSubviewToFront:self.contentViewController.view];
}

#pragma mark - Private

- (void)selectedComponent:(MKDropdownMenuComponentButton *)sender {
    if (self.transition.isAnimating) {
        return;
    }
    if (sender == nil) {
        [self closeAllComponentsAnimated:YES];
    } else {
        NSInteger selectedIndex = [self.buttons indexOfObject:sender];
        if (selectedIndex == self.selectedComponent) {
            [self closeAllComponentsAnimated:YES];
        } else {
            [self openComponent:selectedIndex animated:YES];
        }
    }
}

- (UIEdgeInsets)contentInsetForSelectedComponent {
    if (self.selectedComponent == NSNotFound) {
        return UIEdgeInsetsZero;
    }
    
    UIView *presentingView = [self containerView];
    
    BOOL fullWidth = YES;
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:shouldUseFullRowWidthForComponent:)]) {
        fullWidth = [self.delegate dropdownMenu:self shouldUseFullRowWidthForComponent:self.selectedComponent];
    }
    
    CGFloat left = 0;
    CGFloat right = 0;
    
    if (fullWidth && self.useFullScreenWidth) {
        left = CGRectGetMinX(presentingView.bounds) + self.fullScreenInsetLeft;
        right = CGRectGetMaxX(presentingView.bounds) - self.fullScreenInsetRight;
    } else if (fullWidth) {
        CGRect leftButtonFrame = [presentingView convertRect:self.buttons.firstObject.frame fromView:self];
        CGRect rightButtonFrame = [presentingView convertRect:self.buttons.lastObject.frame fromView:self];
        left = CGRectGetMinX(leftButtonFrame);
        right = CGRectGetMaxX(rightButtonFrame);
    } else {
        CGRect buttonFrame = [presentingView convertRect:self.buttons[self.selectedComponent].frame fromView:self];
        left = CGRectGetMinX(buttonFrame);
        right = CGRectGetMaxX(buttonFrame);
    }
    
    return UIEdgeInsetsMake(0, left, 0, CGRectGetWidth(presentingView.bounds) - right + 0.5);
}

- (void)cleanupSelectedComponents {
    NSInteger previousComponent = self.selectedComponent;
    self.selectedComponent = NSNotFound;
    if (previousComponent != NSNotFound && [self.delegate respondsToSelector:@selector(dropdownMenu:didCloseComponent:)]) {
        [self.delegate dropdownMenu:self didCloseComponent:previousComponent];
    }
}

- (void)updateComponentButtonsSelection:(BOOL)selected {
    void (^animation)() = ^{
        if (selected && self.selectedComponent != NSNotFound) {
            [self.buttons[self.selectedComponent] setSelected:YES];
        } else {
            [self.buttons enumerateObjectsUsingBlock:^(MKDropdownMenuComponentButton *btn, NSUInteger idx, BOOL *stop) {
                [btn setSelected:NO];
            }];
        }
    };
    
    if (self.contentViewController.transitionCoordinator != nil) {
        [self.contentViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            animation();
        } completion:nil];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            animation();
        }];
    }
}

#pragma mark - Dropdown Presenting & Dismissing

- (UIView *)containerView {
    return self.presentingView ? self.presentingView : self.window;
}

- (void)presentDropdownForSelectedComponentAnimated:(BOOL)animated completion:(void (^)())completion {
    if (self.selectedComponent == NSNotFound) {
        if (completion) {
            completion();
        }
        return;
    }
    
    UIView *presentingView = [self containerView];
    
    self.contentViewController.contentInset = [self contentInsetForSelectedComponent];
    
    CGFloat rowHeight = 0;
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:rowHeightForComponent:)]) {
        rowHeight = [self.delegate dropdownMenu:self rowHeightForComponent:self.selectedComponent];
    }
    self.contentViewController.tableView.rowHeight = (rowHeight > 0) ? rowHeight : kDefaultRowHeight;
    
    UIColor *highlightColor = nil;
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:backgroundColorForHighlightedRowsInComponent:)]) {
        highlightColor = [self.delegate dropdownMenu:self backgroundColorForHighlightedRowsInComponent:self.selectedComponent];
    }
    self.contentViewController.highlightColor = highlightColor;
    
    [self.transition presentDropdownInContainerView:presentingView animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
    
    [self updateComponentButtonsSelection:YES];
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
    
    [self updateComponentButtonsSelection:NO];
}

#pragma mark - DropdownMenuContentViewControllerDelegate

- (NSInteger)numberOfRows {
    if (self.selectedComponent == NSNotFound) {
        return 0;
    }
    return [self numberOfRowsInComponent:self.selectedComponent];
}

- (NSInteger)maximumNumberOfRows {
    if (self.selectedComponent == NSNotFound) {
        return 0;
    }
    
    NSInteger maxRows = 0;
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:maximumNumberOfRowsInComponent:)]) {
        maxRows = [self.delegate dropdownMenu:self maximumNumberOfRowsInComponent:self.selectedComponent];
    }
    
    return MAX(0, maxRows);
}

- (NSAttributedString *)attributedTitleForRow:(NSInteger)row {
    NSAttributedString *attributedTitle = nil;
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:attributedTitleForRow:forComponent:)]) {
        attributedTitle = [self.delegate dropdownMenu:self attributedTitleForRow:row forComponent:self.selectedComponent];
    }
    
    if (attributedTitle == nil && [self.delegate respondsToSelector:@selector(dropdownMenu:titleForRow:forComponent:)]) {
        NSString *title = [self.delegate dropdownMenu:self titleForRow:row forComponent:self.selectedComponent];
        if (title != nil) {
            attributedTitle = [[NSAttributedString alloc] initWithString:title];
        }
    }
    
    return attributedTitle;
}

- (UIView *)customViewForRow:(NSInteger)row reusingView:(UIView *)view {
    UIView *customView = nil;
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:viewForRow:forComponent:reusingView:)]) {
        customView = [self.delegate dropdownMenu:self viewForRow:row forComponent:self.selectedComponent reusingView:view];
    }
    
    return customView;
}

- (UIView *)accessoryViewForRow:(NSInteger)row {
    UIView *accessoryView = nil;
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:accessoryViewForRow:forComponent:)]) {
        accessoryView = [self.delegate dropdownMenu:self accessoryViewForRow:row forComponent:self.selectedComponent];
    }
    
    return accessoryView;
}

- (UIColor *)backgroundColorForRow:(NSInteger)row {
    UIColor *backgroundColor = nil;
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:backgroundColorForRow:forComponent:)]) {
        backgroundColor = [self.delegate dropdownMenu:self backgroundColorForRow:row forComponent:self.selectedComponent];
    }
    
    if (backgroundColor == nil) {
        backgroundColor = [UIColor clearColor];
    }
    
    return backgroundColor;
}

- (void)didSelectRow:(NSInteger)row {
    if (row == NSNotFound) {
        [self selectedComponent:nil];
    } else if ([self.delegate respondsToSelector:@selector(dropdownMenu:didSelectRow:inComponent:)]) {
        [self.delegate dropdownMenu:self didSelectRow:row inComponent:self.selectedComponent];
    }
}

- (void)willDisappear {
    if (self.selectedComponent != NSNotFound) {
        [self cleanupSelectedComponents];
        [self updateComponentButtonsSelection:NO];
    }
}

@end
