//
//  ViewController.m
//  SPInteractiveLabel
//
//  Created by Stephen Poletto on 12/10/11.
//

#import "ViewController.h"

@interface ViewController()

@property (nonatomic, strong) SPUserResizableView *imageResizableView;
@property (nonatomic, strong) CAShapeLayer *fillLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:appFrame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(100, 100, 200, 200);
    self.imageResizableView = [[SPUserResizableView alloc] initWithFrame:frame];
    
    self.imageResizableView.contentView = [[UIView alloc] initWithFrame:frame];
    self.imageResizableView.contentView.backgroundColor = [UIColor redColor];
    self.imageResizableView.delegate = self;
    self.imageResizableView.disablePan = NO;
    [self.imageResizableView showEditingHandles];
    
    self.fillLayer = [CAShapeLayer layer];
    self.fillLayer.path = self.fillLayer.path = [self getOverlayPath:appFrame transparentBounds:frame].CGPath;
    self.fillLayer.fillRule = kCAFillRuleEvenOdd;
    self.fillLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    [self.view.layer addSublayer:self.fillLayer];
    
    [self.view addSubview:self.imageResizableView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
    if ([currentlyEditingView hitTest:[touch locationInView:currentlyEditingView] withEvent:nil]) {
        return NO;
    }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)userResizableViewNewRealFrame:(SPUserResizableView *)userResizableView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    self.fillLayer.path = [self getOverlayPath:appFrame transparentBounds:self.imageResizableView.frame].CGPath;
    [self.fillLayer didChangeValueForKey:@"path"];
}

- (UIBezierPath *)getOverlayPath:(CGRect)overlayBounds transparentBounds:(CGRect)transparentBounds
{
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:overlayBounds];
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRect:transparentBounds];
    [overlayPath appendPath:transparentPath];
    [overlayPath setUsesEvenOddFillRule:YES];
    return overlayPath;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 1.0;
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}

@end
