//
//  OPGLViewController.m
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/9.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#import "OPGLViewController.h"
#import "OPGLView.h"

@interface OPGLViewController ()

@end

@implementation OPGLViewController {
    OPGLView *_glView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    _glView = [[OPGLView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    [self.view addSubview:_glView];
    
    UIFont *font = [UIFont fontWithName:@"Menlo" size:12 * 2];
    UIImage *wenbenImage = [self imageWithString:@"点我" font:font width:576 textAlignment:NSTextAlignmentLeft];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:wenbenImage forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 220, 100, 50);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
//    __weak typeof(self) ws = self;
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        __strong typeof(ws) ss = ws;
//        [ss click:nil];
//    }];
}

- (void)click:(UIButton*)btn {
    [_glView setNeedsLayout];
}

- (UIImage *)imageWithString:(NSString *)string font:(UIFont *)font width:(CGFloat)width textAlignment:(NSTextAlignment)textAlignment {
    NSDictionary *attributeDic = @{NSFontAttributeName:font};
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                    attributes:attributeDic
                                       context:nil].size;
    
    if ([UIScreen.mainScreen respondsToSelector:@selector(scale)]) {
        if (UIScreen.mainScreen.scale == 2.0)
        {
            UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
        } else
        {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGRect rect = CGRectMake(0, 0, size.width + 1, size.height + 1);
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = textAlignment;
    
    NSDictionary *attributes = @ {
    NSForegroundColorAttributeName:[UIColor blackColor],
    NSFontAttributeName:font,
    NSParagraphStyleAttributeName:paragraph
    };
    
    [string drawInRect:rect withAttributes:attributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
@end
