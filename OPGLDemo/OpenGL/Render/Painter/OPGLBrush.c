//
//  OPGLBrush.c
//  HStockCharts_Example
//
//  Created by Hotacool on 2020/3/11.
//  Copyright © 2020 shisosen@163.com. All rights reserved.
//

#include "OPGLBrush.h"

// 手机纹理st坐标系左上为(0, 0)
static const GLfloat textureCoordinates[] = {
    0.0f, 1.0f,    0.0, 1.0f,  // 左下
    0.0f, 0.0f,   0.0, 1.0f,   // 左上
    1.0f, 1.0f,   0.0, 1.0f,   // 右下
    1.0f, 0.0f,   0.0, 1.0f   // 右上
};

void opgl_drawLine(const GLvoid* data, GLsizeiptr size, GLint unit, RGBA *color, OPGLContext *context)
{
    if (data == NULL || context == NULL) {
        return;
    }
    
    GLuint vertexBuffer;
    
    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER目标
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    // 为VBO申请空间，初始化并传递数据
    glBufferData(GL_ARRAY_BUFFER, size, data, GL_STATIC_DRAW);
    
    // 给_positionSlot传递vertices数据
    glVertexAttribPointer(context->position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * unit, NULL);
    
    glEnableVertexAttribArray(context->position);
    
    // 取出Colors数组中的每个坐标点的颜色值，赋给_colorSlot ???
    glVertexAttribPointer(context->textColor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * unit, (float *)NULL + 3);
    
    glEnableVertexAttribArray(context->textColor);
    
    glLineWidth(1);
    
    glDrawArrays(GL_LINE_STRIP, 0, (GLsizei)size/(sizeof(GLfloat) * unit));
    
    glDeleteBuffers(1, &vertexBuffer);
}

void opgl_drawRect(const GLvoid* data, GLsizeiptr size, GLint unit, RGBA *color, GLboolean hollow, OPGLContext *context)
{
    if (data == NULL || context == NULL) {
        return;
    }
    
    // 4个点的颜色(分别表示RGBA值)
    const float Colors[] = {
        color->r, color->g, color->b, color->a, // 左下
        color->r, color->g, color->b, color->a, // 左上
        color->r, color->g, color->b, color->a,// 右上
        color->r, color->g, color->b, color->a,// 右下
    };
    
    // 1. 不使用vbo
//    // 给_positionSlot传递vertices数据
//    glVertexAttribPointer(context->position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * unit, data);
//
//    glEnableVertexAttribArray(context->position);
//
//    // 取出Colors数组中的每个坐标点的颜色值
//    glVertexAttribPointer(context->textColor, 4, GL_FLOAT, GL_FALSE, 0, Colors);
//
//    glEnableVertexAttribArray(context->textColor);
//
//    glLineWidth(10);
//
//    glDrawArrays(GL_LINE_LOOP, 0, (GLsizei)size/(sizeof(GLfloat) * unit));
    
    // 2. 使用vbo
    GLuint vertexBuffer;
    // 生成buffer
    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER目标，生成后绑定才能进行后续
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr colorSize = sizeof(Colors);
    // 为VBO申请空间，初始化并传递数据
    glBufferData(GL_ARRAY_BUFFER, size + colorSize, 0, GL_STATIC_DRAW);
    // 为VBO设置顶点数据的值
    glBufferSubData(GL_ARRAY_BUFFER, 0, size, data);
    glBufferSubData(GL_ARRAY_BUFFER, size, colorSize, Colors);
    
    // 给_positionSlot传递vertices数据
    glVertexAttribPointer(context->position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * unit, (void *)0);
    glEnableVertexAttribArray(context->position);
    
    // 取出Colors数组中的每个坐标点的颜色值
    glVertexAttribPointer(context->textColor, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (float *)size);
    glEnableVertexAttribArray(context->textColor);
    
    glLineWidth(1);
    
    if (hollow) {
        glDrawArrays(GL_LINE_LOOP, 0, (GLsizei)size/(sizeof(GLfloat) * unit));
    } else {
        // 索引数组，指定好了绘制三角形的方式
        const GLubyte Indices[] = {
            0,1,2, // 三角形0
            0,2,3  // 三角形1
        };
        glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, Indices);
    }
    
    glDeleteBuffers(1, &vertexBuffer);// 及时清除VBO缓存
}

void opgl_drawImage(const GLvoid* data, GLsizeiptr size, GLubyte *imageData, GLsizei width, GLsizei height, OPGLContext *context) {
    GLuint          texId;
    // 开启纹理混合
    glEnable(GL_BLEND);
    // 设置混合因子
    glBlendFunc(GL_ONE, GL_ONE);
    //激活纹理单元，一个纹理时sampler2D默认为GL_TEXTURE0
    glActiveTexture(GL_TEXTURE0);
    // Use OpenGL ES to generate a name for the texture.
    glGenTextures(1, &texId);
    // 绑定纹理到默认的纹理ID
    glBindTexture(GL_TEXTURE_2D, texId);
    // 第二个参数要与前面激活的纹理单元数对应，前面是GL_TEXTURE0，这里就是0，默认为0
    glUniform1i(context->inputImageTexture, 0);
    
    // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    // Specify a 2D texture image, providing the a pointer to the image data in memory
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    // Release  the image data; it's no longer needed
    glBindTexture(GL_TEXTURE_2D, texId);
    
    // 1. 不使用vbo
//    // 传值到shader
//    glVertexAttribPointer(context->position, 4, GL_FLOAT, 0, 0, data);
//    glVertexAttribPointer(context->inputTextureCoordinate, 4, GL_FLOAT, 0, 0, textureCoordinates);
//    glEnableVertexAttribArray(context->position);
//    glEnableVertexAttribArray(context->inputTextureCoordinate);
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 2.0 vbo
    GLuint vertexBuffer;
    // 生成buffer
    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER目标，生成后绑定才能进行后续
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr textureSize = sizeof(textureCoordinates);
    // 为VBO申请空间，初始化并传递数据
    glBufferData(GL_ARRAY_BUFFER, size + textureSize, 0, GL_STATIC_DRAW);
    // 为VBO设置顶点数据的值
    glBufferSubData(GL_ARRAY_BUFFER, 0, size, data);
    glBufferSubData(GL_ARRAY_BUFFER, size, textureSize, textureCoordinates);
    
    // 给_positionSlot传递vertices数据
    glVertexAttribPointer(context->position, 4, GL_FLOAT, GL_FALSE, 0, (void *)0);
    glEnableVertexAttribArray(context->position);
    
    // 取出Colors数组中的每个坐标点的颜色值
    glVertexAttribPointer(context->inputTextureCoordinate, 4, GL_FLOAT, GL_FALSE, 0, (float *)size);
    glEnableVertexAttribArray(context->inputTextureCoordinate);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDeleteTextures(1, &texId);
    glDeleteBuffers(1, &vertexBuffer);
}
