//
//  OpenGLView.m
//  Tutorial05Test
//
//  Created by 李明 on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView
const GLfloat vertices[] = {
    -1.5f,-1.5f,1.5f,-0.577350,-0.577350,0.577350,
    -1.5f,1.5f,1.5f,-0.577350,0.577350,0.577350,
    1.5f,1.5f,1.5f,0.577350,0.577350,0.577350,
    1.5f,-1.5f,1.5f,0.577350,-0.577350,0.577350,
    
    1.5f,-1.5f,-1.5f,0.577350,-0.577350,-0.577350,
    1.5f,1.5f,-1.5f,0.577350,0.577350,-0.577350,
    -1.5f,1.5f,-1.5f,-0.577350,0.577350,-0.577350,
    -1.5f,-1.5f,-1.5f,-0.577350,-0.577350,-0.577350,
};
//const GLfloat vertices[] = {
//    -0.5f,-0.5f,0.5f,1.0,0.0,0.0,1.0,
//    -0.5f,0.5f,0.5f,1.0,1.0,0.0,1.0,
//    0.5f,0.5f,0.5f,0.0,0.0,1.0,1.0,
//    0.5f,-0.5f,0.5f,1.0,1.0,1.0,1.0,
//    
//    
//    0.5f,-0.5f,-0.5f,1.0,1.0,0.0,1.0,
//    0.5f,0.5f,-0.5f,1.0,0.0,0.0,1.0,
//    -0.5f,0.5f,-0.5f,1.0,1.0,1.0,1.0,
//    -0.5f,-0.5f,-0.5f,0.0,0.0,1.0,1.0,
//};
//const GLushort indices[] = {
//    0,3,2,0,2,1,
//    7,5,4,7,6,5,
//    0,1,6,0,6,7,
//    3,4,5,3,5,2,
//    1,2,5,1,5,6,
//    0,7,4,0,4,3,
//};

const GLushort indices[] = {
    // Front face
    3, 2, 1, 3, 1, 0,
    
    // Back face
    7, 5, 4, 7, 6, 5,
    
    // Left face
    0, 1, 6, 0, 6, 7,
    
    // Right face
    3, 4, 5, 3, 5, 2,
    
    // Up face
    1, 2, 5, 1, 5, 6,
    
    // Down face
    0, 7, 4, 0, 4, 3,
};
-(void)setSelectedSegment:(int)selectedSegment
{
    _selectedSegment = selectedSegment;
}
-(int)selectedSegment
{
    return _selectedSegment;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self destroyRenderAndFrameBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupProgram];
        [self setupProjection];
        [self setupVBO];
        [self render];
        
    }
    return self;
}

+(Class)layerClass
{
    return [CAEAGLLayer class];
}
-(void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
}
-(void)setupContext
{
    _context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
    if(!_context)
    {
        NSLog(@"failed to create context");
        exit(1);
    }
    if(![EAGLContext setCurrentContext:_context])
    {
        NSLog(@"failed to set current context");
        exit(1);
    }
}
-(void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

-(void)setupFrameBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}
-(void)destroyRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}
-(void)render
{
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    [self drawCube];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
-(void)setupProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    GLuint vertexShader = [GLESUtils loadshader:GL_VERTEX_SHADER withFilePath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadshader:GL_FRAGMENT_SHADER withFilePath:fragmentShaderPath];
    _programHandle = glCreateProgram();
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    glLinkProgram(_programHandle);
    GLint link;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &link);
    if(!link)
    {
        GLint infolen = 0;
        glGetProgramiv(_programHandle, GL_INFO_LOG_LENGTH, &infolen);
        if(infolen>1)
        {
            char *infoglog = malloc(sizeof(char)*infolen);
            glGetProgramInfoLog(_programHandle, infolen, NULL, infoglog);
            NSLog(@"Error:/n%s/n",infoglog);
            free(infoglog);
        }
        return;
    }
    glUseProgram(_programHandle);
     NSLog(@"programHandle is %d",_programHandle);
    _positionSolt = glGetAttribLocation(_programHandle, "vPosition");
    NSLog(@"positionSolt is %d",_positionSolt);
    _colorSolt = glGetAttribLocation(_programHandle, "vSourceColor");
    NSLog(@"colorSolt is %d",_colorSolt);
    _projectionSolt = glGetUniformLocation(_programHandle, "projection");
    NSLog(@"projectionSolt is %d",_projectionSolt);
    _modelviewSolt = glGetUniformLocation(_programHandle, "modelView");
    NSLog(@"modelviewSolt is %d",_modelviewSolt);
}
-(void)setupProjection
{
    ksMatrixLoadIdentity(&_modelviewMatrix);
    ksMatrixTranslate(&_modelviewMatrix, 0, 0, -10.0f);
    ksMatrixRotate(&_modelviewMatrix, 70, 1, 0, 0);
    glUniformMatrix4fv(_modelviewSolt, 1, GL_FALSE, (GLfloat *)&_modelviewMatrix.m[0][0]);
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60, self.frame.size.width/self.frame.size.height, 1.0f, 20.0f);
    glUniformMatrix4fv(_projectionSolt, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
    //glEnable(GL_DEPTH_TEST);
}
-(void)setupVBO
{
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    /*void glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
     参数 target：与 glBindBuffer 中的参数 target 相同；
     参数 size ：指定顶点缓存区的大小，以字节为单位计数；
     data ：用于初始化顶点缓存区的数据，可以为 NULL，表示只分配空间，之后再由 glBufferSubData 进行初始化；
     usage ：表示该缓存区域将会被如何使用，它的主要目的是用于提示OpenGL该对该缓存区域做何种程度的优化。其参数为以下三个之一：
     GL_STATIC_DRAW：表示该缓存区不会被修改；
     GL_DyNAMIC_DRAW：表示该缓存区会被周期性更改；
     GL_STREAM_DRAW：表示该缓存区会被频繁更改；
     如果顶点数据一经初始化就不会被修改，那么就应该尽量使用 GL_STATIC_DRAW，这样能获得更好的性能。*/
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indicesBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
}
-(void)drawCube
{
    
    /*void glVertexAttribPointer (GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr);
     参数 index ：为顶点数据（如顶点，颜色，法线，纹理或点精灵大小）在着色器程序中的槽位；
     参数 size ：指定每一种数据的组成大小，比如顶点由 x, y, z 3个组成部分，纹理由 u, v 2个组成部分；
     参数 type ：表示每一个组成部分的数据格式；
     参数 normalized ： 表示当数据为法线数据时，是否需要将法线规范化为单位长度，对于其他顶点数据设置为 GL_FALSE 即可。如果法线向量已经为单位长度设置为 GL_FALSE 即可，这样可免去不必要的计算，提升效率；
     stride ： 表示上一个数据到下一个数据之间的间隔（同样是以字节为单位），OpenGL ES根据该间隔来从由多个顶点数据混合而成的数据块中跳跃地读取相应的顶点数据；
     ptr ：值得注意，这个参数是个多面手。如果没有使用 VBO，它指向 CPU 内存中的顶点数据数组；如果使用 VBO 绑定到 GL_ARRAY_BUFFER，那么它表示该种类型顶点数据在顶点缓存中的起始偏移量。*/
    glVertexAttribPointer(_positionSolt, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), 0);
    glEnableVertexAttribArray(_positionSolt);
    
    glVertexAttribPointer(_colorSolt, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), (GLvoid *)(3*sizeof(GLfloat)));
    glEnableVertexAttribArray(_colorSolt);
    
    /*void glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
     
     参数 mode ：表示描绘的图元类型，如：GL_TRIANGLES，GL_LINES，GL_POINTS；
     参数 count ： 表示索引数据的个数；
     参数 type ： 表示索引数据的格式，必须是无符号整形值；
     indices ：这个参数也是个多面手，如果没有使用 VBO，它指向 CPU 内存中的索引数据数组；如果使用 VBO 绑定到 GL_ELEMENT_ARRAY_BUFFER，那么它表示索引数据在 VBO 中的偏移量。*/
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_SHORT, 0);
    glDisableVertexAttribArray(_positionSolt);
    glDisableVertexAttribArray(_colorSolt);
}
@end
