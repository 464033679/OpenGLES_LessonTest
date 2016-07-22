//
//  OpenGLView.h
//  Tutorial05Test
//
//  Created by 李明 on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import "ksMatrix.h"
#import "GLESUtils.h"
@interface OpenGLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    GLuint _frameBuffer;
    GLuint _vertexBuffer;
    GLuint _indicesBuffer;
    GLuint _programHandle;
    GLuint _positionSolt;
    GLuint _colorSolt;
    GLuint _projectionSolt;
    GLuint _modelviewSolt;
    
    ksMatrix4 _projectionMatrix;
    ksMatrix4 _modelviewMatrix;
    int _selectedSegment;
}
@property (nonatomic,assign)int selectedSegment;
-(void)setupLayer;
-(void)setupContext;
-(void)setupRenderBuffer;
-(void)setupDepthBuffer;
-(void)setupFrameBuffer;
-(void)destroyRenderAndFrameBuffer;
-(void)render;
-(void)setupProgram;
-(void)setupProjection;
-(void)setupVBO;
-(void)drawCube;
@end
