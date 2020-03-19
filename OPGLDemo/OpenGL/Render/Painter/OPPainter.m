//
//  OPPainter.m
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/16.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#import "OPPainter.h"
#import <OpenGLES/ES2/gl.h>
#include "fileUtil.h"
#include "shaderUtil.h"
#include "OPGLBrush.h"

NSString * programKey(NSString *vsh, NSString *fsh)
{
    NSString *key = [NSString stringWithFormat:@"prog-%@-%@", vsh, fsh];
    return key;
}

// 转换矩阵, iPhone页面坐标转OpenGL顶点坐标
const float transformMatrix[4][4] = {
                               2, 0, 0, 0,
                               0, -2, 0, 0,
                               0, 0, 0, 0,
                               -1, 1, 0, 1
};

/*
 *    matrixmult -
 *        multiply two matricies
 */
static void matrixmult(a,b,c)
float a[4][4], b[4][4], c[4][4];
{
    int x, y;
    float temp[4][4];
    
    for(y=0; y<4 ; y++)
        for(x=0 ; x<4 ; x++) {
            temp[y][x] = b[y][0] * a[0][x]
            + b[y][1] * a[1][x]
            + b[y][2] * a[2][x]
            + b[y][3] * a[3][x];
        }
    for(y=0; y<4; y++)
        for(x=0; x<4; x++)
            c[y][x] = temp[y][x];
}

RGBA RGBAFromCGColor(CGColorRef color)
{
  RGBA rgba;

  CGColorSpaceRef color_space = CGColorGetColorSpace(color);
  CGColorSpaceModel color_space_model = CGColorSpaceGetModel(color_space);
  const CGFloat *color_components = CGColorGetComponents(color);
  int color_component_count = (int)CGColorGetNumberOfComponents(color);

  switch (color_space_model)
  {
    case kCGColorSpaceModelMonochrome:
    {
      assert(color_component_count == 2);
      rgba = (RGBA)
      {
        .r = color_components[0],
        .g = color_components[0],
        .b = color_components[0],
        .a = color_components[1]
      };
      break;
    }

    case kCGColorSpaceModelRGB:
    {
      assert(color_component_count == 4);
      rgba = (RGBA)
      {
        .r = color_components[0],
        .g = color_components[1],
        .b = color_components[2],
        .a = color_components[3]
      };
      break;
    }

    default:
    {
      NSLog(@"Unsupported color space model %i", color_space_model);
      rgba = (RGBA) { 0, 0, 0, 0 };
      break;
    }
  }

  return rgba;
}

@implementation OPContext
+ (instancetype)contextWithLayer:(CAEAGLLayer*)layer {
    OPContext *context = [OPContext new];
    context.layer = layer;
    [context setup];
    return context;
}

- (void)dealloc {
    [self destoryRenderBuffer:&_renderbuffer frameBuffer:&_framebuffer];
}

- (void)setup {
    self.context = [self setupContext];
    self.renderbuffer = [self setupRenderBuffer];
    // 为颜色缓冲区 分配存储空间
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.layer];
    self.framebuffer = [self setupFrameBuffer];
    // 将_colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, self.renderbuffer);
}

- (EAGLContext *)setupContext {
    // 指定使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    NSAssert(context, @"Failed to initialize OpenGLES 2.0 context");
    NSAssert([EAGLContext setCurrentContext:context], @"Failed to set current OpenGL context");
    return context;
}

- (GLuint)setupRenderBuffer {
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    return buffer;
}

- (GLuint)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    return buffer;
}

- (void)destoryRenderBuffer:(GLuint*)renderBuffer frameBuffer:(GLuint*)frameBuffer {
    glDeleteFramebuffers(1, frameBuffer);
    *frameBuffer = 0;
    glDeleteRenderbuffers(1, renderBuffer);
    *renderBuffer = 0;
}
@end

@interface OPProgram ()
@property (nonatomic, assign, readwrite) BOOL isUsing; // 不准确，没有重置
@end
@implementation OPProgram

+ (instancetype)programWithVSH:(NSString *)vsh FSH:(NSString *)fsh {
    if (vsh.length > 0 && fsh.length > 0) {
        OPProgram *program = [OPProgram new];
        program.vsh = vsh;
        program.fsh = fsh;
        [program setup];
        if (program.program > 0) {
            return program;
        }
    }
    return nil;
}

- (void)setup {
    char *vsrc = readFile(pathForResource([self.vsh UTF8String]));
    char *fsrc = readFile(pathForResource([self.fsh UTF8String]));
    glueCreateProgram(vsrc, fsrc,
                      0, 0, 0,
                      0, 0, 0,
                      &_program);
    free(vsrc);
    free(fsrc);
}

- (GLuint)getAttribLocation:(const char *)attrib {
    return glGetAttribLocation(self.program, attrib);
}

- (GLuint)getUniformLocation:(const char *)uniform {
    return glGetUniformLocation(self.program, uniform);
}

- (void)use {
    glUseProgram(self.program);
    _isUsing = YES;
}
@end

@implementation OPEnvironment {
    NSMutableDictionary<NSString *, OPProgram*>* _programs;
}

- (instancetype)init {
    if (self = [super init]) {
        _programs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (OPProgram*)loadProgramWithVSH:(NSString*)vsh FSH:(NSString*)fsh {
    NSString *key = programKey(vsh, fsh);
    OPProgram *prog = _programs[key];
    if (!prog) { // TODO: program复用，目前看无法复用，可能随render、frame buffer失效
        prog = [OPProgram programWithVSH:vsh FSH:fsh];
        if (prog) {
            [_programs setObject:prog forKey:key];
        }
    }
    return prog;
}

- (NSDictionary<NSString *,OPProgram *> *)programs {
    return [_programs copy];
}
@end

@interface OPPainter ()
@property (nonatomic, strong, readwrite) OPContext *context;
@property (nonatomic, strong, readwrite) OPEnvironment *environment;
@end

@implementation OPPainter {
}

+ (instancetype)painterWithCanvas:(CAEAGLLayer *)canvas {
    OPPainter *painter = [OPPainter new];
    painter.canvas = canvas;
    painter.context = [OPContext contextWithLayer:canvas];
    painter.environment = [[OPEnvironment alloc] init];
    return painter;
}

- (BOOL)prepareBrushs {
    [self.environment loadProgramWithVSH:@"default.vsh" FSH:@"default.fsh"];
    [self.environment loadProgramWithVSH:@"textImage.vsh" FSH:@"textImage.fsh"];
    return YES;
}

- (void)begin {
    // 切换EAGLContext上下文，必须paint到当前context
    NSAssert([EAGLContext setCurrentContext:self.context.context], @"Failed to set current OpenGL context");
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen] scale]; //获取视图放大倍数，可以把scale设置为1试试
    CGRect rect = self.context.layer.bounds;
    glViewport(0, 0, rect.size.width * scale, rect.size.height * scale); //设置视口大小
}

- (void)end {
    [self.context.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)paintLine:(NSArray<NSValue*>*)points isSmooth:(BOOL)smooth color:(UIColor *)color {
    if (points.count == 0) {
        return;
    }
    OPGLContext *context = (OPGLContext*)malloc(sizeof(OPGLContext));
    [self getOPGLContext:context withVSH:@"default.vsh" FSH:@"default.fsh"];
    
    RGBA rgba = RGBAFromCGColor(color.CGColor);
    
    CGFloat hWidth = self.context.layer.bounds.size.width;// layer width
    CGFloat hHeight = self.context.layer.bounds.size.height;// layer height
    
    int size = (int)points.count;
    int unit = 6;
    GLfloat values[size * unit];
    int i = 0;
    for (NSValue *point in points) {
        CGPoint p = [point CGPointValue];
        // 坐标变换：iOS坐标系转OpenGL顶点坐标
        values[i * unit] = (p.x / hWidth - 0.5) * 2; // f(x) = (x - 0.5) * 2
        values[i * unit + 1] = -(p.y / hHeight - 0.5) * 2; // f(y) = -(y - 0.5) * 2
        values[i * unit + 2] = rgba.r;
        values[i * unit + 3] = rgba.g;
        values[i * unit + 4] = rgba.b;
        values[i * unit + 5] = rgba.a;
        i++;
    }

    opgl_drawLine(values, sizeof(values), unit, 0, context);
}

- (void)paintText:(NSString*)text inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    if (text.length == 0) {
        return;
    }
    OPGLContext *context = (OPGLContext*)malloc(sizeof(OPGLContext));
    [self getOPGLContext:context withVSH:@"textImage.vsh" FSH:@"textImage.fsh"];
    
    // text
    CGFloat hWidth = self.context.layer.bounds.size.width;// layer width
    CGFloat hHeight = self.context.layer.bounds.size.height;// layer height
    
    CGImageRef        brushImage;
    CGContextRef    brushContext;
    GLubyte            *brushData;
    size_t            width, height;
    
    // 1获取图片的CGImageRef
    brushImage = [self imageWithString:text font:font width:hWidth color:color textAlignment:alignment?:NSTextAlignmentLeft].CGImage;
    // 2 读取图片的大小
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    // Allocate  memory needed for the bitmap context
    brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    // Use  the bitmatp creation function provided by the Core Graphics framework.
    brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
    // 3在CGContextRef上绘图
    CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
    // You don't need the context at this point, so you need to release it to avoid memory leaks.
    CGContextRelease(brushContext);
    
    float originX = rect.origin.x / hWidth;
    float originY = rect.origin.y / hHeight;
    float w = width / hWidth;
    float h = height / hHeight;
    // 顶点坐标
    float verticesMatrix[4][4];
    // 转换为ST坐标
    float pointCoordinates[4][4] = {
        originX, originY + h, 0, 1,    // 左下
        originX, originY, 0, 1,     // 左上
        originX + w, originY + h, 0, 1,     // 右下
        originX + w, originY, 0, 1     // 右上
    };
    // 转化为顶点坐标
    matrixmult(transformMatrix, pointCoordinates, verticesMatrix);
    
    opgl_drawImage(verticesMatrix, sizeof(verticesMatrix), brushData, (GLsizei)width, (GLsizei)height, context);
    
    free(brushData);
}

- (void)paintRect:(CGRect)rect isHollow:(BOOL)hollow color:(UIColor*)color  {
    OPGLContext *context = (OPGLContext*)malloc(sizeof(OPGLContext));
    [self getOPGLContext:context withVSH:@"default.vsh" FSH:@"default.fsh"];
    
    CGFloat hWidth = self.context.layer.bounds.size.width;// layer width
    CGFloat hHeight = self.context.layer.bounds.size.height;// layer height
    float originX = rect.origin.x / hWidth;
    float originY = rect.origin.y / hHeight;
    float w = rect.size.width / hWidth;
    float h = rect.size.height / hHeight;
    // 顶点坐标
    float verticesMatrix[4][4];
    // 转换为ST坐标
    float pointCoordinates[4][4] = {
        originX, originY + h, 0.0f, 1.0f,    // 左下
        originX, originY, 0.0f, 1.0f,     // 左上
        originX + w, originY, 0.0f, 1.0f,   // 右上
        originX + w, originY + h,  0.0f, 1.0f,     // 右下
    };
    
    RGBA rgba = RGBAFromCGColor(color.CGColor);
    
    // 转化为顶点坐标
    matrixmult(transformMatrix, pointCoordinates, verticesMatrix);
    
    opgl_drawRect(verticesMatrix, sizeof(verticesMatrix), 4, &rgba, hollow, context);
}

- (void)getOPGLContext:(OPGLContext*)context withVSH:(NSString*)vsh FSH:(NSString*)fsh {
    OPProgram *useProgram = self.environment.programs[programKey(vsh, fsh)];
    if (!useProgram) {
        return;
    }
    [useProgram use];
    context->position = [useProgram getAttribLocation:"position"];
    context->textColor = [useProgram getAttribLocation:"sourceColor"];
    context->inputTextureCoordinate = [useProgram getAttribLocation:"inputTextureCoordinate"];
    context->inputImageTexture = [useProgram getUniformLocation:"inputImageTexture"];
}

- (UIImage *)imageWithString:(NSString *)string font:(UIFont *)font width:(CGFloat)width color:(UIColor*)color textAlignment:(NSTextAlignment)textAlignment {
    NSDictionary *attributeDic = @{NSFontAttributeName:font};
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                    attributes:attributeDic
                                       context:nil].size;
    
    if ([UIScreen.mainScreen respondsToSelector:@selector(scale)]) {
        if (UIScreen.mainScreen.scale == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGRect rect = CGRectMake(0, 0, size.width + 1, size.height + 1);
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = textAlignment;
    
    NSDictionary *attributes = @ {
    NSForegroundColorAttributeName:color?:[UIColor blackColor],
    NSFontAttributeName:font,
    NSParagraphStyleAttributeName:paragraph
    };
    
    [string drawInRect:rect withAttributes:attributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
@end
