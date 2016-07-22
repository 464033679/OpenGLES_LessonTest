//
//  OpenGLView.m
//  Tutorial01Test
//
//  Created by 李明 on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView
//平移
-(void)setTrans_x:(float)trans_x
{
    _trans_x = trans_x;
    [self updateTransform];
    [self render];
    
}
-(float)trans_x
{
    return _trans_x;
}
-(void)setTrans_y:(float)trans_y
{
    _trans_y = trans_y;
    [self updateTransform];
    [self render];
}
-(float)trans_y
{
    return _trans_y;
}
-(void)setTrans_z:(float)trans_z
{
    _trans_z = trans_z;
    [self updateTransform];
    [self render];
}
-(float)trans_z
{
    return _trans_z;
}
//旋转
-(void)setAngle_x:(float)angle_x
{
    _angle_x = angle_x;
    [self updateTransform];
    [self render];
}
-(float)angle_x
{
    return _angle_x;
}
-(void)setAngle_y:(float)angle_y
{
    _angle_y = angle_y;
    [self updateTransform];
    [self render];
}
-(float)angle_y
{
    return _angle_y;
}
-(void)setAngle_z:(float)angle_z
{
    _angle_z = angle_z;
    [self updateTransform];
    [self render];
}
-(float)angle_z
{
    return _angle_z;
}
//缩放
-(void)setScale_x:(float)scale_x
{
    _scale_x = scale_x;
    [self updateTransform];
    [self render];
}
-(float)scale_x
{
    return _scale_x;
}
-(void)setScale_y:(float)scale_y
{
    _scale_y = scale_y;
    [self updateTransform];
    [self render];
}
-(float)scale_y
{
    return _scale_y;
}
-(void)setScale_z:(float)scale_z
{
    _scale_z = scale_z;
    [self updateTransform];
    [self render];
}
-(float)scale_z
{
    return _scale_z;
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
        [self render];
    }
    return self;
}
+(Class)layerClass
{
    //只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}
-(void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    
}
/*我们需要创建OpenGL ES 渲染上下文（在iOS中对应的实现为EAGLContext），这个 context 管理所有使用OpenGL ES 进行描绘的状态，命令以及资源信息。然后，需要将它设置为当前 context，因为我们要使用 OpenGL ES 进行渲染（描绘）。*/
-(void)setupContext
{
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0 
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[[EAGLContext alloc] initWithAPI:api] autorelease];
    if(!_context)
    {
        NSLog(@"fail to create context ");
        exit(1);
    }
    // 设置为当前上下文
    if(![EAGLContext setCurrentContext:_context])
    {
        _context = nil;
        NSLog(@"fail to set current context");
        exit(1);
    }
}
/*有了上下文，openGL还需要在一块 buffer 上进行描绘，这块 buffer 就是 RenderBuffer（OpenGL ES 总共有三大不同用途的color buffer，depth buffer 和 stencil buffer，这里是最基本的 color buffer）。*/
-(void)setupRenderBuffer
{
    /*glGenRenderbuffers 的原型为：
     void glGenRenderbuffers (GLsizei n, GLuint* renderbuffers)
     它是为 renderbuffer 申请一个 id（或曰名字）。参数 n 表示申请生成 renderbuffer 的个数，而 renderbuffers 返回分配给 renderbuffer 的 id，注意：返回的 id 不会为0，id 0 是OpenGL ES 保留的，我们也不能使用 id 为0的 renderbuffer。*/
    glGenRenderbuffers(1, &_colorRenderBuffer);
    /*glBindRenderbuffer 的原型为：
    void glBindRenderbuffer (GLenum target, GLuint renderbuffer) 
    这个函数将指定 id 的 renderbuffer 设置为当前 renderbuffer。参数 target 必须为 GL_RENDERBUFFER，参数 renderbuffer 是就是使用 glGenRenderbuffers 生成的 id。当指定 id 的 renderbuffer 第一次被设置为当前 renderbuffer 时，会初始化该 renderbuffer 对象，其初始值为：
    
    width 和 height：像素单位的宽和高，默认值为0；
    internal format：内部格式，三大 buffer 格式之一 -- color，depth or stencil；
    Color bit-depth：仅当内部格式为 color 时，设置颜色的 bit-depth，默认值为0；
    Depth bit-depth：仅当内部格式为 depth时，默认值为0；
    Stencil bit-depth: 仅当内部格式为 stencil，默认值为0；*/
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    /*函数 - (BOOL)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable; 在内部使用 drawable（在这里是 EAGLLayer）的相关信息（还记得在 setupLayer 时设置了drawableProperties的一些属性信息么？）作为参数调用了 glRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height); 后者 glRenderbufferStorage 指定存储在 renderbuffer 中图像的宽高以及颜色格式，并按照此规格为之分配存储空间。在这里，将使用我们在前面设置 eaglLayer 的颜色格式 RGBA8， 以及 eaglLayer 的宽高作为参数调用 glRenderbufferStorage。*/
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}
/*framebuffer object 通常也被称之为 FBO，它相当于 buffer(color, depth, stencil)的管理者，三大buffer 可以附加到一个 FBO 上。我们是用 FBO 来在 off-screen buffer上进行渲染。*/
-(void)setupFrameBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    /*glFramebufferRenderbuffer的函数原型为：
     void glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
     该函数是将相关 buffer（三大buffer之一）attach到framebuffer上（如果 renderbuffer不为 0，知道前面为什么说glGenRenderbuffers 返回的id 不会为 0 吧）或从 framebuffer上detach（如果 renderbuffer为 0）。参数 attachment 是指定 renderbuffer 被装配到那个装配点上，其值是GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT中的一个，分别对应 color，depth和 stencil三大buffer。*/
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
}
/*当 UIView 在进行布局变化之后，由于 layer 的宽高变化，导致原来创建的 renderbuffer不再相符，我们需要销毁既有 renderbuffer 和 framebuffer。*/
-(void)destroyRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}
-(void)drawTriCone
{
    GLfloat vertices[] =                            
    {
        0.5f,   0.5f,   0.0f,
        0.5f,   -0.5f,  0.0f,
        -0.5f,  -0.5f,  0.0f,
        -0.5f,  0.5f,   0.0f,
        0.0f,   0.0f,   -0.707f,
    };
    GLubyte indices[] = 
    {
        0,1,1,2,2,3,3,0,
        4,0,4,1,4,2,4,3
    };
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    /* glDrawElements 与glDrawArrays区别是减少存储重复顶点的内存消耗。比如：若用glDrawArrays，则vertices应把各个点重新描述一遍*/
    /*glDrawElements 函数的原型为：
     void glDrawElements(GLenum mode,GLsizei count,GLenum type,const GLvoid * indices);
     第一个参数 mode 为描绘图元的模式，其有效值为：GL_POINTS, GL_LINES, GL_LINE_STRIP,  GL_LINE_LOOP,  GL_TRIANGLES,  GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN。这些模式具体含义下面有介绍。
     
     第二个参数 count 为顶点索引的个数也就是，type 是指顶点索引的数据类型，因为索引始终是正值，索引这里必须是无符号型的非浮点类型，因此只能是 GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT 之一，为了减少内存的消耗，尽量使用最小规格的类型如 GL_UNSIGNED_BYTE。
     
     第三个参数 indices 是存放顶点索引的数组。（indices 是 index 的复数形式，3D 里面很多单词的复数都挺特别的。）*/
    glLineWidth(5.0f);//设置线宽
    /*要获得当前设置的线宽度可以使用如下代码：
    GLfloat lineWidthRange[2];
    glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, lineWidthRange)
     
     
     OpenGL ES 还支持描绘点(精灵, sprite)的模式：GL_POINTS，此外还可以通过内建变量 gl_PointSize 来设置点精灵的大小，要获取当前设置的点精灵的大小可以使用如下代码：
     GLfloat pointSizeRange[2]; 
     glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE, pointSizeRange);*/
    
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
}

-(void)render
{
    //glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampfalpha) 用来设置清屏颜色，默认为黑色；
    glClearColor(0, 0, 1.0, 1.0);
    /*glClear (GLbitfieldmask)用来指定要用清屏颜色来清除由mask指定的buffer，mask 可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合。在这里我们只使用到 color buffer，所以清除的就是 clolor buffer。*/
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self drawTriCone];
    
    
    
    /*- (BOOL)presentRenderbuffer:(NSUInteger)target 是将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。在前面设置 drawable 属性时，我们设置 kEAGLDrawablePropertyRetainedBacking 为FALSE，表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。将该设置为 TRUE 对性能和资源影像较大，因此只有当renderbuffer需要保持其内容不变时，我们才设置 kEAGLDrawablePropertyRetainedBacking  为 TRUE。*/
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
//-(void)layoutSubviews//这个方法是view自带的
//{
//    [EAGLContext setCurrentContext:_context];
//    [self destroyRenderAndFrameBuffer];
//    [self setupRenderBuffer];
//    [self setupFrameBuffer];
//    [self render];
//}
-(void)setupProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    GLuint vertexShader = [GLESUtils loadshader:GL_VERTEX_SHADER withFilePath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadshader:GL_FRAGMENT_SHADER withFilePath:fragmentShaderPath];
    _programHandle = glCreateProgram();
    if(!_programHandle)
    {
        NSLog(@"Failed to create program");
        return;
    }
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    glLinkProgram(_programHandle);
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked);
    if(!linked)
    {
        GLint infoLen = 0;
        glGetProgramiv(_programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen>1)
        {
            char *infoLog = malloc(sizeof(char)*infoLen);
            glGetProgramInfoLog(_programHandle, infoLen, NULL, infoLog);
            NSLog(@"Error linking program:\n%s\n",infoLog);
            free(infoLog);
        }
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    /*那我们就可以调用 glUseProgram 激活 program 对象从而在 render 中使用它。通过调用 glGetAttribLocation 我们获取到 shader 中定义的变量 vPosition 在 program 的槽位，通过该槽位我们就可以对 vPosition 进行操作。*/
    glUseProgram(_programHandle);
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
    
}
-(void)setupProjection
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix);
    
    
    float aspect = (float)self.frame.size.width/(self.frame.size.height);
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0f, 20.0f);
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
}
-(void)updateTransform
{
    
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksMatrixTranslate(&_modelViewMatrix, self.trans_x, self.trans_y, self.trans_z);
    ksMatrixRotate(&_modelViewMatrix, self.angle_x, 1, 0, 0);
    ksMatrixRotate(&_modelViewMatrix, self.angle_y, 0, 1, 0);
    ksMatrixRotate(&_modelViewMatrix, self.angle_z, 0, 0, 1);
    ksMatrixScale(&_modelViewMatrix, self.scale_x, self.scale_y, self.scale_z);
//    ksTranslate(&_modelViewMatrix, self.trans_x, self.trans_y, self.trans_z);
//    ksRotate(&_modelViewMatrix, self.angle_x, self.angle_y, self.angle_z);
//    ksScale(&_modelViewMatrix, self.scale_x, self.scale_y, self.scale_z);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix);
    
    
}
-(void)resetTransform
{
    _trans_x = 0.0;
    _trans_y = 0.0;
    _trans_z = -5.5;
    
    _scale_x = 1.0;
    _scale_y = 1.0;
    _scale_z = 1.0;
    
    _angle_x = 0.0;
    _angle_y = 0.0;
    _angle_z = 0.0;
    [self updateTransform];
}
-(void)displayLinkCallback:(CADisplayLink *)displayLink
{
    self.angle_x += displayLink.duration * 90;
}
-(void)toggleDisplayLink
{
    if(_displayLink == nil)
    {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}
@end
