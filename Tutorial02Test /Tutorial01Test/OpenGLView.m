//
//  OpenGLView.m
//  Tutorial01Test
//
//  Created by 李明 on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView

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
-(void)render
{
    //glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampfalpha) 用来设置清屏颜色，默认为黑色；
    glClearColor(0, 0, 1.0, 1.0);
    /*glClear (GLbitfieldmask)用来指定要用清屏颜色来清除由mask指定的buffer，mask 可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合。在这里我们只使用到 color buffer，所以清除的就是 clolor buffer。*/
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    GLfloat vertices[] = 
                        {
                            1.0f,   -1.0f,  0.0f,
                            -1.0f,  -1.0f,  0.0f,
                            0.0f,  1.0f, 0.0f
                            };
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    
    
    
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
}
@end
