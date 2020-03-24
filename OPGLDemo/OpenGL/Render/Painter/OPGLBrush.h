//
//  OPGLBrush.h
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/11.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#ifndef OPGLBrush_h
#define OPGLBrush_h

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>
#include "types.h"

// shader attributes 索引
typedef struct {
    GLuint position;
    GLuint textColor;
    GLuint inputTextureCoordinate;
    GLuint inputImageTexture;
} OPGLContext;

/// 画线
/// @param data 顶点数据
/// @param size 顶点数据大小
/// @param unit 每个顶点数据位数，如坐标（x, y）则为2， （x, y, z）则为3
/// @param color 线色, rgba格式
/// @param context shader attributes 索引
extern void opgl_drawLine(const GLvoid* data, GLsizeiptr size, GLint unit, RGBA *color, OPGLContext *context);

/// 画矩形
/// @param data 顶点数据
/// @param size 顶点数据大小
/// @param unit 每个顶点数据位数，如坐标（x, y）则为2， （x, y, z）则为3
/// @param color 线色, rgba格式
/// @param hollow 是否空心
/// @param context shader attributes 索引
extern void opgl_drawRect(const GLvoid* data, GLsizeiptr size, GLint unit, RGBA *color, GLboolean hollow, OPGLContext *context);

/// 画文字贴图（文字生成二进制图片）
/// @param data 顶点数据，文字框四个顶点。
/// @param size 顶点数据大小
/// @param imageData 图片二进制数据
/// @param width 图片宽度
/// @param height 图片高度
/// @param context shader attributes 索引
extern void opgl_drawImage(const GLvoid* data, GLsizeiptr size, GLubyte *imageData, GLsizei width, GLsizei height, OPGLContext *context) ;

void opgl_drawCandles(const GLvoid* data, GLsizeiptr size, GLint unit, OPGLContext *context) ;
#endif /* OPGLBrush_h */
