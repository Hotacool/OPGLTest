//
//  OPNode.h
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/16.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id OPGLData;

@interface OPNode : NSObject
@property (nonatomic, strong, readonly) CAEAGLLayer *hostLayer;
@property (nonatomic, assign, readonly) CGRect rect;
@property (nonatomic, strong) OPGLData data;

+ (instancetype)nodeWithHostLayer:(CAEAGLLayer*)layer;

- (void)setNeedsDisplay;
@end

NS_ASSUME_NONNULL_END
