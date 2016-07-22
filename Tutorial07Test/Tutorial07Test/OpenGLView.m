//
//  OpenGLView.m
//  123123
//
//  Created by 李明 on 13-1-30.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView
@synthesize lightPosition = _lightPosition;
@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize shininess = _shininess;
//@synthesize shaderflag;
-(void)setLightPosition:(ksVec3)lightPosition
{
    NSLog(@"lightPosition");
    _lightPosition = lightPosition;
    [self updateLights];
    [self render];
}
-(void)setAmbient:(ksColor)ambient
{
    NSLog(@"ambient");
    _ambient = ambient;
    [self updateLights];
    [self render];
}
-(void)setSpecular:(ksColor)specular
{
     NSLog(@"specular");
    _specular = specular;
    [self updateLights];
    [self render];
}
-(void)setDiffuse:(ksColor)diffuse
{
    NSLog(@"diffuse");
    _diffuse = diffuse;
    [self updateLights];
    [self render];
}
-(void)setShininess:(GLfloat)shininess
{
    NSLog(@"1111shininess = %f",shininess);
    _shininess = shininess;
    [self updateLights];
    [self render];
}
-(GLint)shaderflag
{
    return _shaderflag;
}
-(void)setShaderflag:(GLint)shaderflag
{
    _shaderflag = shaderflag;
    [self setupProgram];
    [self setupProjectMatrix];
    //[self setupLight];
    [self updateLights];
    [self render];
    NSLog(@"456456");
}
const GLfloat size = 1.8f;
const GLfloat vertices[] = {
    -size, -size, size, -0.577350, -0.577350, 0.577350,
    -size, size, size, -0.577350, 0.577350, 0.577350,
    size, size, size, 0.577350, 0.577350, 0.577350,
    size, -size, size, 0.577350, -0.577350, 0.577350,
    
    size, -size, -size, 0.577350, -0.577350, -0.577350,
    size, size, -size, 0.577350, 0.577350, -0.577350,
    -size, size, -size, -0.577350, 0.577350, -0.577350,
    -size, -size, -size, -0.577350, -0.577350, -0.577350
};

const GLushort indices[] = {
    // Front face
    3, 2, 1, 3, 1, 0,
    
    // Back face
    7, 5, 4, 7, 6, 5,
    
    // Left face
    0, 1, 7, 7, 1, 6,
    
    // Right face
    3, 4, 5, 3, 5, 2,
    
    // Up face
    1, 2, 5, 1, 5, 6,
    
    // Down face
    0, 7, 3, 3, 7, 4
};
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];//设置CAEAGLLayer
        [self setupContext];//设置OpenGL环境
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupVertexAndIndicesBuffer];
        [self setupProgram];
        [self setupProjectMatrix];
        [self setupLight];
        [self updateLights];
        [self render];
    }
    return self;
}


-(void)setupDepthBuffer
{
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    
}
-(void)setupFrameBuffer
{
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    
}
+(Class)layerClass
{
    return [CAEAGLLayer class];
}
-(void)setupLayer
{
    _eagllayer = (CAEAGLLayer *) self.layer;
    _eagllayer.opaque = YES;
    _eagllayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
}

-(void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if(!_context)
    {
        NSLog(@"fail to initialize OpenGL ES 2.0 context");
        exit(1);
    }
    if(![EAGLContext setCurrentContext:_context])
    {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}
-(void)setupRenderBuffer//渲染缓冲区
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eagllayer];
}
-(void)setupVertexAndIndicesBuffer
{
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    NSLog(@"vertexBuffer is %d",_vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indicesBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBuffer);
    NSLog(@"indicesBuffer is %d",_indicesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
}
-(void)render
{
    glClearColor(0, 104.0/255, 55.0/255, 1.0);//RGB三色以及透明度
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);//GL_DEPTH_BUFFER_BIT，表示每次绘制时先把深度缓存清空，也就是先把所有像素的 深度值设为最大可能距离。
    glEnable(GL_DEPTH_TEST);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    [self drawGraphics];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
-(void)setupProgram
{
    NSString *vertexShaderPath = nil;
    NSString *fragmentShaderPath = nil;
    if(self.shaderflag ==1)
    {
        vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
        fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    }
    else {
        vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"PerPixelVertex" ofType:@"glsl"];
        fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"PerPixelFragment" ofType:@"glsl"];
    }
    _programHandle = [GLESUtils loadProgramVertexShaderFilepath:vertexShaderPath withFragmentShaderFilepath:fragmentShaderPath];
    NSLog(@"programHandle is %d",_programHandle);
    if(_programHandle == 0)
    {
        NSLog(@"fail to set up program");
        return;
    }
    glUseProgram(_programHandle);
    _positionSolt = glGetAttribLocation(_programHandle, "vPosition");//点坐标
    NSLog(@"positionSolt is %d",_positionSolt);
//    _colorSolt = glGetAttribLocation(_programHandle, "vSourceColor");
//    NSLog(@"colorSolt is %d",_colorSolt);
    _projectionSolt = glGetUniformLocation(_programHandle, "projection");//投影矩阵槽位
    NSLog(@"projectionSolt is %d",_projectionSolt);
    _modelviewSolt = glGetUniformLocation(_programHandle, "modelView");//模型视图变换槽位
    NSLog(@"modelviewSolt is %d",_modelviewSolt);
    _normalMatrixSolt = glGetUniformLocation(_programHandle, "normalMatrix");
    NSLog(@"normalMatrixSolt is %d",_normalMatrixSolt);
    _ambientSolt = glGetUniformLocation(_programHandle, "vAmbientMaterial");
    NSLog(@"ambientSolt is %d",_ambientSolt);
    _specularSolt = glGetUniformLocation(_programHandle, "vSpecularMaterial");
    NSLog(@"specularSolt is %d",_specularSolt);
    _lightPositionSolt = glGetUniformLocation(_programHandle, "vLightPosition");
    NSLog(@"lightPositionSolt is %d",_lightPositionSolt);
    _shininessSolt = glGetUniformLocation(_programHandle, "shininess");
    NSLog(@"shininessSolt is %d",_shininessSolt);
    
    _normalSolt = glGetAttribLocation(_programHandle, "vNormal");
    NSLog(@"normalSolt is %d",_normalSolt);
    _diffuseSolt = glGetAttribLocation(_programHandle, "vDiffuseMaterial");
    NSLog(@"diffuseSolt is %d",_diffuseSolt);
}
-(void)setupProjectMatrix
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksMatrixTranslate(&_modelViewMatrix, 0, 0, -10);
    ksMatrixRotate(&_modelViewMatrix, 60, 1, 0, 0);
    glUniformMatrix4fv(_modelviewSolt, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60, self.frame.size.width/self.frame.size.height, 1, 20);
    glUniformMatrix4fv(_projectionSolt, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    
    ksMatrix3 normalMatrix3;
    ksMatrix4ToMatrix3(&normalMatrix3, &_modelViewMatrix);
    glUniformMatrix3fv(_normalMatrixSolt, 1, GL_FALSE, (GLfloat *)&normalMatrix3.m[0][0]);
    glEnable(GL_CULL_FACE);

}
-(void)drawGraphics
{
    glVertexAttribPointer(_positionSolt, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(_positionSolt);
//    glVertexAttribPointer(_colorSolt, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GL_FLOAT), (GLvoid *)(3*sizeof(GL_FLOAT)));
//    glEnableVertexAttribArray(_colorSolt);
    glVertexAttribPointer(_normalSolt, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GL_FLOAT), (GLvoid *)(3*sizeof(GL_FLOAT)));
    glEnableVertexAttribArray(_normalSolt);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_SHORT, 0);
}
-(void)setupLight
{
    
    _lightPosition.x = _lightPosition.y = _lightPosition.z = 1.0;
    _ambient.r = _ambient.g = _ambient.b = 0.04;_ambient.a = 1.0;
    _specular.r = _specular.g = _specular.b = 0.5;_specular.a = 1.0;
    _diffuse.r = 0.0f;
    _diffuse.g = 0.5f;
    _diffuse.b = 1.0;
    _diffuse.a = 1.0;
    _shininess = 10;
    
}
-(void)updateLights
{
    glUniform3f(_lightPositionSolt, _lightPosition.x, _lightPosition.y, _lightPosition.z);
    NSLog(@"lightPosition.x = %f,lightPosition.y = %f,lightPosition.z = %f",_lightPosition.x,_lightPosition.y,_lightPosition.z);
    glUniform4f(_ambientSolt, _ambient.r, _ambient.g, _ambient.b, _ambient.a);
    glUniform4f(_specularSolt, _specular.r, _specular.g, _specular.b, _specular.a);
    glVertexAttrib4f(_diffuseSolt, _diffuse.r, _diffuse.g, _diffuse.b, _diffuse.a);
    glUniform1f(_shininessSolt, self.shininess);
    NSLog(@"shininess = %f",_shininess);
}
@end
