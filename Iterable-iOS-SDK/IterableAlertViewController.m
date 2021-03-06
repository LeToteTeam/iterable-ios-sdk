//
//  IterableAlertViewController.m
//  Iterable-iOS-SDK

//  Implementation based of of NYAlert created by Nealon Young
//  Copyright (c) 2015 Nealon Young. All rights reserved.
//

#import "IterableAlertViewController.h"

#import "IterableAlertView.h"
#import "IterableConstants.h"
#import "IterableInAppManager.h"

@interface IterableAlertAction ()

@property (weak, nonatomic) UIButton *actionButton;

@end

@implementation IterableAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style actionName:(NSString *)actionName {
    IterableAlertAction *action = [[IterableAlertAction alloc] init];
    action.title = title;
    action.style = style;
    action.actionName = actionName;
    
    return action;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _enabled = YES;
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    self.actionButton.enabled = enabled;
}

@end

@interface IterableAlertViewPresentationAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property IterableAlertViewControllerTransitionStyle transitionStyle;
@property IterableInAppNotificationLocation notificationLocation;

@property CGFloat duration;

@end

static CGFloat const kDefaultPresentationAnimationDuration = 0.7f;

@implementation IterableAlertViewPresentationAnimationController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.duration = kDefaultPresentationAnimationDuration;
    }
    
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionStyle == IterableAlertViewControllerTransitionStyleSlideFromTop || self.transitionStyle == IterableAlertViewControllerTransitionStyleSlideFromBottom) {
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect initialFrame = [transitionContext finalFrameForViewController:toViewController];
        
        initialFrame.origin.y = self.transitionStyle == IterableAlertViewControllerTransitionStyleSlideFromTop ? -(initialFrame.size.height + initialFrame.origin.y) : (initialFrame.size.height + initialFrame.origin.y);
        toViewController.view.frame = initialFrame;
        
        [[transitionContext containerView] addSubview:toViewController.view];
        
        // If we're using the slide from top transition, apply a 3D rotation effect to the alert view as it animates in
        if (self.transitionStyle == IterableAlertViewControllerTransitionStyleSlideFromTop) {
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0f / 600.0f;
            transform = CATransform3DRotate(transform,  M_PI_4 * 1.3f, 1.0f, 0.0f, 0.0f);
            
            toViewController.view.layer.zPosition = 100.0f;
            toViewController.view.layer.transform = transform;
        }
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:0.76f
              initialSpringVelocity:0.2f
                            options:0
                         animations:^{
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             toViewController.view.layer.opacity = 1.0f;
                             toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    } else {
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        [[transitionContext containerView] addSubview:toViewController.view];
        
        toViewController.view.layer.transform = CATransform3DMakeScale(1.2f, 1.2f, 1.2f);
        toViewController.view.layer.opacity = 0.0f;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             toViewController.view.layer.opacity = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.transitionStyle) {
        case IterableAlertViewControllerTransitionStyleFade:
            return 0.3f;
            break;
            
        case IterableAlertViewControllerTransitionStyleSlideFromTop:
        case IterableAlertViewControllerTransitionStyleSlideFromBottom:
            return 0.6f;
    }
}

@end

@interface IterableAlertViewDismissalAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property IterableAlertViewControllerTransitionStyle transitionStyle;
@property CGFloat duration;

@end

static CGFloat const kDefaultDismissalAnimationDuration = 0.6f;

@implementation IterableAlertViewDismissalAnimationController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.duration = kDefaultDismissalAnimationDuration;
    }
    
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionStyle == IterableAlertViewControllerTransitionStyleSlideFromTop || self.transitionStyle == IterableAlertViewControllerTransitionStyleSlideFromBottom) {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        CGRect finalFrame = [transitionContext finalFrameForViewController:fromViewController];
        finalFrame.origin.y = 1.2f * CGRectGetHeight([transitionContext containerView].frame);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:0.8f
              initialSpringVelocity:0.1f
                            options:0
                         animations:^{
                             fromViewController.view.frame = finalFrame;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    } else {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             fromViewController.view.layer.opacity = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.transitionStyle) {
        case IterableAlertViewControllerTransitionStyleFade:
            return 0.3f;
            break;
            
        case IterableAlertViewControllerTransitionStyleSlideFromTop:
        case IterableAlertViewControllerTransitionStyleSlideFromBottom:
            return 0.6f;
    }}

@end

@interface IterableAlertViewPresentationController : UIPresentationController

@property CGFloat presentedViewControllerHorizontalInset;
@property CGFloat presentedViewControllerVerticalInset;
@property (nonatomic) BOOL backgroundTapDismissalGestureEnabled;
@property UIView *backgroundDimmingView;
//@property CGFloat startingDimmingBackgroundAlpha;

@end

@interface IterableAlertViewPresentationController ()

- (void)tapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer;

@end

@implementation IterableAlertViewPresentationController

- (void)presentationTransitionWillBegin {
    self.presentedViewController.view.layer.masksToBounds = YES;
    
    self.backgroundDimmingView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.backgroundDimmingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.backgroundDimmingView.alpha = 0.0f;
    self.backgroundDimmingView.backgroundColor = [UIColor blackColor];
    [self.containerView addSubview:self.backgroundDimmingView];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundDimmingView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_backgroundDimmingView)]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundDimmingView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_backgroundDimmingView)]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [self.backgroundDimmingView addGestureRecognizer:tapGestureRecognizer];
    
    // Shrink the presenting view controller, and animate in the dark background view
    id <UIViewControllerTransitionCoordinator> transitionCoordinator = [self.presentingViewController transitionCoordinator];
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.backgroundDimmingView.alpha = ((IterableAlertViewController *) self.presentedViewController).startingDimmingBackgroundAlpha;
    }
                                           completion:nil];
}

- (BOOL)shouldPresentInFullscreen {
    return NO;
}

- (BOOL)shouldRemovePresentersView {
    return NO;
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    [super presentationTransitionDidEnd:completed];
    
    if (!completed) {
        [self.backgroundDimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    
    id <UIViewControllerTransitionCoordinator> transitionCoordinator = [self.presentingViewController transitionCoordinator];
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.backgroundDimmingView.alpha = 0.0f;
        
        self.presentingViewController.view.transform = CGAffineTransformIdentity;
    }
                                           completion:nil];
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    
    [self presentedView].frame = [self frameOfPresentedViewInContainerView];
    
    self.backgroundDimmingView.frame = self.containerView.bounds;
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    
    if (completed) {
        [self.backgroundDimmingView removeFromSuperview];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.backgroundTapDismissalGestureEnabled) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

@interface IterableAlertViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property IterableAlertView *view;
@property UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegate;

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@implementation IterableAlertViewController

@dynamic view;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message {
    IterableAlertViewController *alertController = [[IterableAlertViewController alloc] initWithNibName:nil bundle:nil];
    alertController.title = title;
    alertController.message = message;
    
    return alertController;
}

// documented in IterableAlertViewController.h
-(void)ITESetData:(NSDictionary *)jsonPayload {
    if ([jsonPayload objectForKey:ITERABLE_IN_APP_TITLE]) {
        NSDictionary* title = [jsonPayload objectForKey:ITERABLE_IN_APP_TITLE];
        self.title = [title objectForKey:ITERABLE_IN_APP_TEXT];
        if ([title objectForKey:ITERABLE_IN_APP_TEXT_FONT])
            self.titleFont = [UIFont fontWithName:[title objectForKey:ITERABLE_IN_APP_TEXT_FONT] size:18.0f];
        if ([title objectForKey:ITERABLE_IN_APP_TEXT_COLOR])
            self.titleColor = UIColorFromRGB([IterableInAppManager getIntColorFromKey:title keyString:ITERABLE_IN_APP_TEXT_COLOR]);
    }
    
    if ([jsonPayload objectForKey:ITERABLE_IN_APP_BODY]) {
        NSDictionary* body = [jsonPayload objectForKey:ITERABLE_IN_APP_BODY];
        self.message = [body objectForKey:ITERABLE_IN_APP_TEXT];
        if ([body objectForKey:ITERABLE_IN_APP_TEXT_FONT])
            self.messageFont = [UIFont fontWithName:[body objectForKey:ITERABLE_IN_APP_TEXT_FONT] size:16.0f];
        if ([body objectForKey:ITERABLE_IN_APP_TEXT_COLOR])
            self.messageColor = UIColorFromRGB([IterableInAppManager getIntColorFromKey:body keyString:ITERABLE_IN_APP_TEXT_COLOR]);
    }
    
    if ([jsonPayload objectForKey:ITERABLE_IN_APP_BUTTONS]) {
        NSArray* buttons = [jsonPayload objectForKey:ITERABLE_IN_APP_BUTTONS];
        for (int i = 0; i < [buttons count]; i++) {
            NSDictionary* button = (NSDictionary *)[buttons objectAtIndex:i];
            if (i == [buttons count]-1) {
                NSString *title;
                if ([button objectForKey:ITERABLE_IN_APP_CONTENT]) {
                    NSDictionary* buttonContent = [button objectForKey:ITERABLE_IN_APP_CONTENT];
                    if ([buttonContent objectForKey:ITERABLE_IN_APP_TEXT_FONT]) {
                        self.cancelButtonTitleFont = [UIFont fontWithName:[buttonContent objectForKey:ITERABLE_IN_APP_TEXT_FONT] size:self.buttonTitleFont.pointSize];
                    }
                    if ([buttonContent objectForKey:ITERABLE_IN_APP_TEXT_COLOR]) {
                        self.cancelButtonTitleColor = UIColorFromRGB([IterableInAppManager getIntColorFromKey:buttonContent keyString:ITERABLE_IN_APP_TEXT_COLOR]);
                    }
                    title = [buttonContent objectForKey:ITERABLE_IN_APP_TEXT];
                }
                self.cancelButtonColor = UIColorFromRGB([IterableInAppManager getIntColorFromKey:button keyString:ITERABLE_IN_APP_BACKGROUND_COLOR]);
                [self addAction:[IterableAlertAction actionWithTitle:NSLocalizedString(title, nil)
                                                               style:UIAlertActionStyleCancel
                                                          actionName:[button objectForKey:ITERABLE_IN_APP_BUTTON_ACTION]]];
            } else {
                NSString *title;
                if ([button objectForKey:ITERABLE_IN_APP_CONTENT]) {
                    NSDictionary* buttonContent = [button objectForKey:ITERABLE_IN_APP_CONTENT];
                    if ([buttonContent objectForKey:ITERABLE_IN_APP_TEXT_FONT]) {
                        self.buttonTitleFont = [UIFont fontWithName:[buttonContent objectForKey:ITERABLE_IN_APP_TEXT_FONT] size:self.buttonTitleFont.pointSize];
                    }
                    if ([buttonContent objectForKey:ITERABLE_IN_APP_TEXT_COLOR]) {
                        self.buttonTitleColor = UIColorFromRGB([IterableInAppManager getIntColorFromKey:buttonContent keyString:ITERABLE_IN_APP_TEXT_COLOR]);
                    }
                    title = [buttonContent objectForKey:ITERABLE_IN_APP_TEXT];
                }
                self.buttonColor = UIColorFromRGB([IterableInAppManager getIntColorFromKey:button keyString:ITERABLE_IN_APP_BACKGROUND_COLOR]);
                
                [self addAction:[IterableAlertAction actionWithTitle:NSLocalizedString([button objectForKey:ITERABLE_IN_APP_TEXT], nil)
                                                               style:UIAlertActionStyleDefault
                                                          actionName:[button objectForKey:ITERABLE_IN_APP_BUTTON_ACTION]]];
            }
        }
    }
    
    if ([jsonPayload objectForKey:ITERABLE_IN_APP_BACKGROUND_COLOR]) {
        self.alertViewBackgroundColor = UIColorFromRGB([IterableInAppManager getIntColorFromKey:jsonPayload keyString:ITERABLE_IN_APP_BACKGROUND_COLOR]);
    }
        
    //Set Notification Location
    NSString* type = [jsonPayload objectForKey:ITERABLE_IN_APP_TYPE];
    if ([type isEqual:ITERABLE_IN_APP_TYPE_TOP]) {
        [((IterableAlertView *) self.view) setInAppLocation:NotifLocationTop];
    } else if ([type isEqual:ITERABLE_IN_APP_TYPE_BOTTOM]) {
        [((IterableAlertView *) self.view) setInAppLocation:NotifLocationBottom];
        self.transitionStyle = IterableAlertViewControllerTransitionStyleSlideFromBottom;
    }else {
        [((IterableAlertView *) self.view) setInAppLocation:NotifLocationCenter];
        self.transitionStyle = IterableAlertViewControllerTransitionStyleFade;
    }
    
    self.buttonCornerRadius = 0.0f;
    self.alertViewCornerRadius = 0.0f;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    
    UIDevice *myDevice = [UIDevice currentDevice];
    UIDeviceOrientation deviceOrientation = myDevice.orientation;
    
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        return UIInterfaceOrientationLandscapeRight;
    }
    else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        return UIInterfaceOrientationLandscapeLeft;
    }
    else {
        return UIInterfaceOrientationLandscapeLeft;
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)viewDidDisappear:(BOOL)animated {
    // Necessary to avoid retain cycle - http://stackoverflow.com/a/21218703/1227862
    self.transitioningDelegate = nil;
    [super viewDidDisappear:animated];
}

- (void)commonInit {
    _actions = [NSArray array];
    _textFields = [NSArray array];
    
    _showsStatusBar = YES;
    
    _buttonTitleFont = [UIFont systemFontOfSize:16.0f];
    _cancelButtonTitleFont = [UIFont boldSystemFontOfSize:16.0f];
    _destructiveButtonTitleFont = [UIFont systemFontOfSize:16.0f];
    
    _buttonColor = [UIColor darkGrayColor];
    _buttonTitleColor = [UIColor whiteColor];
    _cancelButtonColor = [UIColor darkGrayColor];
    _cancelButtonTitleColor = [UIColor whiteColor];
    _destructiveButtonColor = [UIColor colorWithRed:1.0f green:0.23f blue:0.21f alpha:1.0f];
    _destructiveButtonTitleColor = [UIColor whiteColor];
    _disabledButtonColor = [UIColor lightGrayColor];
    _disabledButtonTitleColor = [UIColor whiteColor];
    
    _buttonCornerRadius = 6.0f;
    
    _transitionStyle = IterableAlertViewControllerTransitionStyleSlideFromTop;
    
    self.startingDimmingBackgroundAlpha = 0.7f;
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGestureRecognizer.delegate = self;
    self.panGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)loadView {
    self.view = [[IterableAlertView alloc] initWithFrame:CGRectZero];
}

- (BOOL)prefersStatusBarHidden {
    return !self.showsStatusBar;
}

- (CGFloat)maximumWidth {
    return self.view.maximumWidth;
}

- (void)setMaximumWidth:(CGFloat)maximumWidth {
    self.view.maximumWidth = maximumWidth;
}

- (UIView *)alertViewContentView {
    return self.view.contentView;
}

- (void)setAlertViewContentView:(UIView *)alertViewContentView {
    self.view.contentView = alertViewContentView;
}

- (void)setSwipeDismissalGestureEnabled:(BOOL)swipeDismissalGestureEnabled {
    _swipeDismissalGestureEnabled = swipeDismissalGestureEnabled;
    
    self.panGestureRecognizer.enabled = swipeDismissalGestureEnabled;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer {
    self.view.backgroundViewVerticalCenteringConstraint.constant = [gestureRecognizer translationInView:self.view].y;
    
    IterableAlertViewPresentationController *presentationController = (IterableAlertViewPresentationController* )self.presentationController;
    
    CGFloat windowHeight = CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds);
    presentationController.backgroundDimmingView.alpha = self.startingDimmingBackgroundAlpha - (fabs([gestureRecognizer translationInView:self.view].y) / windowHeight);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat verticalGestureVelocity = [gestureRecognizer velocityInView:self.view].y;
        
        // If the gesture is moving fast enough, animate the alert view offscreen and dismiss the view controller. Otherwise, animate the alert view back to its initial position
        if (fabs(verticalGestureVelocity) > 500.0f) {
            CGFloat backgroundViewYPosition;
            
            if (verticalGestureVelocity > 500.0f) {
                backgroundViewYPosition = CGRectGetHeight(self.view.frame);
            } else {
                backgroundViewYPosition = -CGRectGetHeight(self.view.frame);
            }
            
            CGFloat animationDuration = 500.0f / fabs(verticalGestureVelocity);
            
            self.view.backgroundViewVerticalCenteringConstraint.constant = backgroundViewYPosition;
            [UIView animateWithDuration:animationDuration
                                  delay:0.0f
                 usingSpringWithDamping:0.8f
                  initialSpringVelocity:0.2f
                                options:0
                             animations:^{
                                 presentationController.backgroundDimmingView.alpha = 0.0f;
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        } else {
            self.view.backgroundViewVerticalCenteringConstraint.constant = 0.0f;
            [UIView animateWithDuration:0.5f
                                  delay:0.0f
                 usingSpringWithDamping:0.8f
                  initialSpringVelocity:0.4f
                                options:0
                             animations:^{
                                 presentationController.backgroundDimmingView.alpha = self.startingDimmingBackgroundAlpha;
                                 [self.view layoutIfNeeded];
                             }
                             completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self createActionButtons];
    self.view.textFields = self.textFields;
}

- (void)setAlertViewBackgroundColor:(UIColor *)alertViewBackgroundColor {
    _alertViewBackgroundColor = alertViewBackgroundColor;
    
    self.view.alertBackgroundView.backgroundColor = alertViewBackgroundColor;
}

- (void)createActionButtons {
    NSMutableArray *buttons = [NSMutableArray array];
    
    // Create buttons for each action
    for (int i = 0; i < [self.actions count]; i++) {
        IterableAlertAction *action = self.actions[i];
        
        IterableAlertViewButton *button = [IterableAlertViewButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = i;
        [self ITEAddActionButton:button.tag actionString:action.actionName];
        [button addTarget:self action:@selector(ITEActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button.enabled = action.enabled;
        
        button.cornerRadius = self.buttonCornerRadius;
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitle:action.title forState:UIControlStateNormal];
        
        [button setTitleColor:self.disabledButtonTitleColor forState:UIControlStateDisabled];
        [button ITESetButtonBackgroundColor:self.disabledButtonColor forState:UIControlStateDisabled];
        
        if (action.style == UIAlertActionStyleCancel) {
            [button setTitleColor:self.cancelButtonTitleColor forState:UIControlStateNormal];
            [button setTitleColor:self.cancelButtonTitleColor forState:UIControlStateHighlighted];
            [button ITESetButtonBackgroundColor:self.cancelButtonColor forState:UIControlStateNormal];

            button.titleLabel.font = self.cancelButtonTitleFont;
        } else if (action.style == UIAlertActionStyleDestructive) {
            [button setTitleColor:self.destructiveButtonTitleColor forState:UIControlStateNormal];
            [button setTitleColor:self.destructiveButtonTitleColor forState:UIControlStateHighlighted];
            [button ITESetButtonBackgroundColor:self.destructiveButtonColor forState:UIControlStateNormal];

            button.titleLabel.font = self.destructiveButtonTitleFont;
        } else {
            [button setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
            [button setTitleColor:self.buttonTitleColor forState:UIControlStateHighlighted];
            [button ITESetButtonBackgroundColor:self.buttonColor forState:UIControlStateNormal];

            button.titleLabel.font = self.buttonTitleFont;
        }
        
        [buttons addObject:button];
        
        action.actionButton = button;
    }
    
    self.view.actionButtons = buttons;
}

#pragma mark - Getters/Setters

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    self.view.titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    self.view.messageTextView.text = message;
}

- (UIFont *)titleFont {
    return self.view.titleLabel.font;
}

- (void)setTitleFont:(UIFont *)titleFont {
    self.view.titleLabel.font = titleFont;
}

- (UIFont *)messageFont {
    return self.view.messageTextView.font;
}

- (void)setMessageFont:(UIFont *)messageFont {
    self.view.messageTextView.font = messageFont;
}

- (void)setButtonTitleFont:(UIFont *)buttonTitleFont {
    _buttonTitleFont = buttonTitleFont;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style != UIAlertActionStyleCancel) {
            button.titleLabel.font = buttonTitleFont;
        }
    }];
}

- (void)setCancelButtonTitleFont:(UIFont *)cancelButtonTitleFont {
    _cancelButtonTitleFont = cancelButtonTitleFont;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style == UIAlertActionStyleCancel) {
            button.titleLabel.font = cancelButtonTitleFont;
        }
    }];
}

- (void)setDestructiveButtonTitleFont:(UIFont *)destructiveButtonTitleFont {
    _destructiveButtonTitleFont = destructiveButtonTitleFont;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style == UIAlertActionStyleDestructive) {
            button.titleLabel.font = destructiveButtonTitleFont;
        }
    }];
}

- (UIColor *)titleColor {
    return self.view.titleLabel.textColor;
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.view.titleLabel.textColor = titleColor;
}

- (UIColor *)messageColor {
    return self.view.messageTextView.textColor;
}

- (void)setMessageColor:(UIColor *)messageColor {
    self.view.messageTextView.textColor = messageColor;
}

- (void)setButtonColor:(UIColor *)buttonColor {
    _buttonColor = buttonColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style != UIAlertActionStyleCancel) {
            [button ITESetButtonBackgroundColor:buttonColor forState:UIControlStateNormal];
        }
    }];
}

- (void)setCancelButtonColor:(UIColor *)cancelButtonColor {
    _cancelButtonColor = cancelButtonColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style == UIAlertActionStyleCancel) {
            [button ITESetButtonBackgroundColor:cancelButtonColor forState:UIControlStateNormal];
        }
    }];
}

- (void)setDestructiveButtonColor:(UIColor *)destructiveButtonColor {
    _destructiveButtonColor = destructiveButtonColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style == UIAlertActionStyleDestructive) {
            [button ITESetButtonBackgroundColor:destructiveButtonColor forState:UIControlStateNormal];
        }
    }];
}

- (void)setDisabledButtonColor:(UIColor *)disabledButtonColor {
    _disabledButtonColor = disabledButtonColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (!action.enabled) {
            [button ITESetButtonBackgroundColor:disabledButtonColor forState:UIControlStateNormal];
        }
    }];
}

- (void)setButtonTitleColor:(UIColor *)buttonTitleColor {
    _buttonTitleColor = buttonTitleColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style != UIAlertActionStyleCancel) {
            [button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
            [button setTitleColor:buttonTitleColor forState:UIControlStateHighlighted];
        }
    }];
}

- (void)setCancelButtonTitleColor:(UIColor *)cancelButtonTitleColor {
    _cancelButtonTitleColor = cancelButtonTitleColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style == UIAlertActionStyleCancel) {
            [button setTitleColor:cancelButtonTitleColor forState:UIControlStateNormal];
            [button setTitleColor:cancelButtonTitleColor forState:UIControlStateHighlighted];
        }
    }];
}

- (void)setDestructiveButtonTitleColor:(UIColor *)destructiveButtonTitleColor {
    _destructiveButtonTitleColor = destructiveButtonTitleColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (action.style == UIAlertActionStyleDestructive) {
            [button setTitleColor:destructiveButtonTitleColor forState:UIControlStateNormal];
            [button setTitleColor:destructiveButtonTitleColor forState:UIControlStateHighlighted];
        }
    }];
}

- (void)setDisabledButtonTitleColor:(UIColor *)disabledButtonTitleColor {
    _disabledButtonTitleColor = disabledButtonTitleColor;
    
    [self.view.actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        IterableAlertAction *action = self.actions[idx];
        
        if (!action.enabled) {
            [button setTitleColor:disabledButtonTitleColor forState:UIControlStateNormal];
            [button setTitleColor:disabledButtonTitleColor forState:UIControlStateHighlighted];
        }
    }];
}

- (CGFloat)alertViewCornerRadius {
    return self.view.alertBackgroundView.layer.cornerRadius;
}

- (void)setAlertViewCornerRadius:(CGFloat)alertViewCornerRadius {
    self.view.alertBackgroundView.layer.cornerRadius = alertViewCornerRadius;
}

- (void)setButtonCornerRadius:(CGFloat)buttonCornerRadius {
    _buttonCornerRadius = buttonCornerRadius;
    
    for (IterableAlertViewButton *button in self.view.actionButtons) {
        button.cornerRadius = buttonCornerRadius;
    }
}

- (void)addAction:(UIAlertAction *)action {
    _actions = [self.actions arrayByAddingObject:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    
    configurationHandler(textField);
    
    _textFields = [self.textFields arrayByAddingObject:textField];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    IterableAlertViewPresentationController *presentationController = [[IterableAlertViewPresentationController alloc] initWithPresentedViewController:presented
                                                                                                                  presentingViewController:presenting];
    presentationController.backgroundTapDismissalGestureEnabled = self.backgroundTapDismissalGestureEnabled;
    return presentationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    IterableAlertViewPresentationAnimationController *presentationAnimationController = [[IterableAlertViewPresentationAnimationController alloc] init];
    presentationAnimationController.transitionStyle = self.transitionStyle;
    return presentationAnimationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    IterableAlertViewDismissalAnimationController *dismissalAnimationController = [[IterableAlertViewDismissalAnimationController alloc] init];
    dismissalAnimationController.transitionStyle = self.transitionStyle;
    return dismissalAnimationController;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Don't recognize the pan gesture in the button, so users can move their finger away after touching down
    if (([touch.view isKindOfClass:[UIButton class]])) {
        return NO;
    }
    
    return YES;
}

- (void)viewWillLayoutSubviews {
    [self.view updateHorizontalConstraint];
}

@end
