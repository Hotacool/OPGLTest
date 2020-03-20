//
//  OPGLView.m
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/11.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#import "OPGLView.h"
#import "OPNode.h"

@interface OPGLView ()
@property (nonatomic, strong) OPNode *node;
@end

@implementation OPGLView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]];//注: 需要提前设定scale
        _node = [OPNode nodeWithHostLayer:(CAEAGLLayer*)self.layer];
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [self refresh];
}

- (void)refresh {
    [self.node setNeedsDisplay];
}

@end
