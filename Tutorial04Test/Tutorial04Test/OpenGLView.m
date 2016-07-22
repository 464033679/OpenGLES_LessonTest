//
//  OpenGLView.m
//  Tutorial04Test
//
//  Created by 李明 on 13-1-22.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView
-(void)setAngleShoulder:(float)angleShoulder
{
    _angleShoulder = angleShoulder;
    [self render];
}
-(float)angleShoulder
{
    return _angleShoulder;
}
-(void)setAngleEblow:(float)angleEblow
{
    _angleEblow = angleEblow;
    [self render];
}
-(float)angleEblow
{
    return _angleEblow;
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
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[[EAGLContext alloc] initWithAPI:api] autorelease];
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
    glDeleteRenderbuffers(1,& _colorRenderBuffer);
    _colorRenderBuffer = 0;
}
-(void)render
{
    ksVec4 colorRed = {1,0,0,1};
    ksVec4 colorWhite = {1,1,1,1};
    glClearColor(0, 0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    [self updateShoulderTransform];
    [self drawCube:colorRed];
    [self updateEblowTransform];
    [self drawCube:colorWhite];
    [self updateColorCubeTransform];
    [self drawColorCube];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
-(void)setupProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    GLuint vertexShader = [GLESUtils loadshader:GL_VERTEX_SHADER withFilePath:vertexShaderPath];
    GLuint fragShader = [GLESUtils loadshader:GL_FRAGMENT_SHADER withFilePath:fragShaderPath];
    _programHandle = glCreateProgram();
    if(!_programHandle)
    {
        NSLog(@"failed to create program");
        return;
    }
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragShader);
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
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _colorSolt = glGetAttribLocation(_programHandle, "vSourceColor");
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
    _modelviewSlot = glGetUniformLocation(_programHandle, "modelView");
}
-(void)setupProjection
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    glUniformMatrix4fv(_modelviewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60, self.frame.size.width/self.frame.size.height, 1.0f, 20.0f);
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
    
    
}
//-(void)cleanup
//{
//    
//}
-(void)toggleDisplayLink
{
    if(_displaylink == nil)
    {
        _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        [_displaylink invalidate];
        [_displaylink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displaylink = nil;
    }
}
-(void)displayLinkCallback:(CADisplayLink *)displayLink
{
    _anglecube += displayLink.duration * 90;
    NSLog(@"displayLink.duration是%f",displayLink.duration);
    [self render];
}
-(void)updateShoulderTransform
{
    ksMatrixLoadIdentity(&_shoulderModelViewMatrix);
    ksMatrixTranslate(&_shoulderModelViewMatrix, -0.0, 0.0, -5.5);
    ksMatrixRotate(&_shoulderModelViewMatrix, self.angleShoulder, 0.0, 0.0, 1.0);
    ksMatrixCopy(&_modelViewMatrix, &_shoulderModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.5, 0.6, 0.6);
    glUniformMatrix4fv(_modelviewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}
-(void)updateEblowTransform
{
    ksMatrixCopy(&_elbowModelViewMatrix, &_shoulderModelViewMatrix);
    ksMatrixTranslate(&_elbowModelViewMatrix, 1.5, 0.0, 0.0);
    ksMatrixRotate(&_elbowModelViewMatrix, self.angleEblow, 0.0, 0.0, 1.0);
    ksMatrixCopy(&_modelViewMatrix, &_elbowModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.0, 0.4, 0.4);
    glUniformMatrix4fv(_modelviewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    
}
-(void)drawCube:(ksVec4)color
{
    GLfloat vertices[] = 
                        {
                            0.0f,-0.5f,0.5f,
                            0.0f,0.5f,0.5f,
                            1.0f,0.5f,0.5f,
                            1.0f,-0.5f,0.5f,
                            
                            1.0f,-0.5f,-0.5f,
                            1.0f,0.5f,-0.5f,
                            0.0f,0.5f,-0.5f,
                            0.0f,-0.5f,-0.5f,
                        };
    GLubyte indices[] = 
                        {
                            0,1,1,2,2,3,3,0,
                            4,5,5,6,6,7,7,4,
                            0,7,1,6,2,5,3,4,
                        };
    glVertexAttrib4f(_colorSolt, color.x, color.y, color.z, color.w);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
}
-(void)updateColorCubeTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksMatrixTranslate(&_modelViewMatrix, 0.0, -2, -5.5);
    ksMatrixRotate(&_modelViewMatrix, _anglecube, 0.0, 1.0, 0.0);
    glUniformMatrix4fv(_modelviewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}
-(void)drawColorCube
{
    GLfloat vertices[] = 
                        {
                            -0.5f,-0.5f,0.5f,1.0,0.0,0.0,1.0,
                            -0.5f,0.5f,0.5f,1.0,1.0,0.0,1.0,
                            0.5f,0.5f,0.5f,0.0,0.0,1.0,1.0,
                            0.5f,-0.5f,0.5f,1.0,1.0,1.0,1.0,
                            
                            
                            0.5f,-0.5f,-0.5f,1.0,1.0,0.0,1.0,
                            0.5f,0.5f,-0.5f,1.0,0.0,0.0,1.0,
                            -0.5f,0.5f,-0.5f,1.0,1.0,1.0,1.0,
                            -0.5f,-0.5f,-0.5f,0.0,0.0,1.0,1.0,
                        };
    GLubyte indices[] = 
                        {
                            0,3,2,0,2,1,
                            7,5,4,7,6,5,
                            0,1,6,0,6,7,
                            3,4,5,3,5,2,
                            1,2,5,1,5,6,
                            0,7,4,0,4,3,
                        };
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7*sizeof(GLfloat), vertices);
    glVertexAttribPointer(_colorSolt, 4, GL_FLOAT, GL_FALSE, 7*sizeof(GLfloat), vertices+3);
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSolt);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
    glDisableVertexAttribArray(_colorSolt);
    
}
@end
