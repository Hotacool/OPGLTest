//
//  OPNode.m
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/16.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#import "OPNode.h"
#import "OPPainter.h"

@interface OPNode ()
@property (nonatomic, strong, readwrite) CAEAGLLayer *hostLayer;
@property (nonatomic, strong) OPPainter *painter;
@end

@implementation OPNode

+ (instancetype)nodeWithHostLayer:(CAEAGLLayer*)layer {
    OPNode *node = [[self class] new];
    node.hostLayer = layer;
    [node setUp];
    node.painter = [OPPainter painterWithCanvas:layer];
    [node.painter prepareBrushs];
    return node;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)setNeedsDisplay {
    [self.painter begin];
    // 蜡烛图
    OPCandle value[4] = {
        OPCandleMake(CGPointMake(10, 0), CGPointMake(10, 80), CGRectMake(0, 60, 20, 40), [UIColor blueColor]),
        OPCandleMake(CGPointMake(40, 10), CGPointMake(40, 80), CGRectMake(30, 40, 20, 20), [UIColor redColor]),
        OPCandleMake(CGPointMake(70, 20), CGPointMake(70, 80), CGRectMake(60, 80, 20, 50), [UIColor greenColor]),
        OPCandleMake(CGPointMake(100, 20), CGPointMake(100, 80), CGRectMake(90, 80, 20, 10), [UIColor blueColor]),
    };
    [self.painter paintCandles:value size:sizeof(value) / sizeof(OPCandle) isHollow:NO color:[UIColor blueColor]];
    // 折线
    int count = 100;
    NSMutableArray <NSValue*>* points = [NSMutableArray arrayWithCapacity:count];
    CGFloat space = self.hostLayer.bounds.size.width / (count - 1);
    for (int i = 0; i < count; i++) {
        CGFloat y = (rand() % 11) * 0.1 * self.hostLayer.bounds.size.height;
        NSValue *p = [NSValue valueWithCGPoint:CGPointMake(space * i, y)];
        [points addObject:p];
    }
    [self.painter paintLine:points isSmooth:NO color:[UIColor blackColor]];
    // 文字
    UIFont *font = [UIFont fontWithName:@"Menlo" size:12 * 2];
    [self.painter paintText:@"左上" inRect:CGRectMake(0, (rand() % 100), 100, 100) font:font color:[UIColor redColor] alignment:NSTextAlignmentRight];
    [self.painter paintText:@"左下" inRect:CGRectMake(0, 100, 100, 100) font:font color:[UIColor redColor] alignment:NSTextAlignmentRight];
    [self.painter paintText:@"右上" inRect:CGRectMake(100, 0, 100, 100) font:font color:[UIColor redColor] alignment:NSTextAlignmentRight];
    [self.painter paintText:@"右下" inRect:CGRectMake(100, 100, 100, 100) font:font color:[UIColor redColor] alignment:NSTextAlignmentRight];
    // 矩形
    [self.painter paintRect:CGRectMake(100, 100, 80, 80) isHollow:NO color:[UIColor redColor]];
    [self.painter paintRect:CGRectMake(0, 0, self.hostLayer.bounds.size.width, self.hostLayer.bounds.size.height) isHollow:YES color:[UIColor redColor]];
    [self.painter end];
}

- (void)setUp {
    [self setupLayer];
}

- (void)setupLayer {
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.hostLayer.opaque = NO;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.hostLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                         kEAGLDrawablePropertyRetainedBacking,
                                         kEAGLColorFormatRGBA8,
                                         kEAGLDrawablePropertyColorFormat,
                                         nil];
}
@end
