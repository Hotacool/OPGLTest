//
//  OPPainter.h
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/16.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OPContext : NSObject
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CAEAGLLayer *layer;
@property (nonatomic , assign) GLuint renderbuffer;
@property (nonatomic , assign) GLuint framebuffer;

+ (instancetype)contextWithLayer:(CAEAGLLayer*)layer;
@end

@interface OPProgram : NSObject
@property (nonatomic, copy) NSString *vsh;
@property (nonatomic, copy) NSString *fsh;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign, readonly) BOOL isUsing;

+ (instancetype)programWithVSH:(NSString*)vsh FSH:(NSString*)fsh;

- (GLuint)getAttribLocation:(const char *)attrib ;

- (GLuint)getUniformLocation:(const char *)uniform ;

- (void)use ;
@end

@interface OPEnvironment : NSObject
@property (nonatomic, copy, readonly) NSDictionary<NSString *, OPProgram*>* programs;

- (OPProgram*)loadProgramWithVSH:(NSString*)vsh FSH:(NSString*)fsh;
@end

@interface OPPainter : NSObject
@property (nonatomic, strong) CAEAGLLayer *canvas;
@property (nonatomic, strong, readonly) OPContext *context;
@property (nonatomic, strong, readonly) OPEnvironment *environment;

+ (instancetype)painterWithCanvas:(CAEAGLLayer*)canvas;

- (BOOL)prepareBrushs;

- (void)begin;

- (void)end;

- (void)paintLine:(NSArray<NSValue*>*)points isSmooth:(BOOL)smooth color:(UIColor *)color;

- (void)paintText:(NSString*)text inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment ;

- (void)paintRect:(CGRect)rect isHollow:(BOOL)hollow color:(UIColor*)color ;
@end

NS_ASSUME_NONNULL_END
