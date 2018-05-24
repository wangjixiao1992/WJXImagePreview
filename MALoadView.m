//
//  扇形菊花
//  MumUnion
//
//  Created by wangjixiao on 16/7/12.
//  Copyright © 2016年 octech. All rights reserved.

#import "MALoadView.h"

#define PI 3.14159265358979323846

@interface MALoadView ()

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGFloat loadProgress;

@end

@implementation MALoadView

+ (MALoadView *)showViewInView:(UIView *)view
{
    MALoadView *hud = [[self alloc] initWithView:view];
    [view bringSubviewToFront:hud];
    [view addSubview:hud];
    return hud;
}


- (void)viewHidden:(BOOL)hidden
{
    if (hidden) {
        [self setNeedsDisplay];
        [self removeFromSuperview];
    }
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake((view.frame.size.width - 30) / 2, (view.frame.size.height - 30) / 2, 30, 30);
   
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    CGPoint point = CGPointMake(15, 15);
    [self moveShapeLayerToPoint:point radius:13.5];
}


- (void)moveShapeLayerToPoint:(CGPoint)point radius:(CGFloat)radius
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.backView.bounds];
    [path addArcWithCenter:CGPointMake(point.x, point.y) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.usesEvenOddFillRule = YES; // 自动填充
    
    self.shapeLayer.path = path.CGPath;
    self.backView.layer.mask = self.shapeLayer;
}

- (void)setLoadValues:(CGFloat)values
{
    if (values >= 100) {
        [self viewHidden:YES];
    }else {
        self.progress = values * M_PI / 100 * 2;
        [self setNeedsDisplay];
    }
}

- (void)drawFillPie:(CGRect)rect cgContext:(CGContextRef)cgContext margin:(CGFloat)margin color:(UIColor *)color percentage:(CGFloat)percentage
{
    CGFloat centerX = 30 * 0.5;
    
    CGContextSetFillColorWithColor(cgContext, [color CGColor]);
    CGContextMoveToPoint(cgContext, centerX, centerX);
    CGContextAddArc(cgContext, centerX, centerX, 12.5, (CGFloat) -M_PI_2, (CGFloat) (-M_PI_2 + percentage), 0);
    CGContextClosePath(cgContext);
    CGContextFillPath(cgContext);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    [self drawFillPie:rect cgContext:cgContext margin:0 color:[UIColor whiteColor] percentage:self.progress];
}


- (UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.frame = CGRectMake(0, 0, 30, 30);
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.clipsToBounds = YES;
        _backView.layer.cornerRadius = 15;
    }
    return _backView;
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor blackColor].CGColor; // 非透明颜色即可
        _shapeLayer.fillRule = kCAFillRuleEvenOdd;
    }
    return _shapeLayer;
}


@end
