//
//  OpenGLView.h
//  Tutorial04Test
//
//  Created by 李明 on 13-1-22.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLESUtils.h"
#include "ksMatrix.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
@interface OpenGLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _colorSolt;
    GLuint _projectionSlot;
    GLuint _modelviewSlot;
    
    ksMatrix4 _projectionMatrix;
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _shoulderModelViewMatrix;
    ksMatrix4 _elbowModelViewMatrix;
    
    float _angleShoulder;
    float _angleEblow;
    float _anglecube;
    CADisplayLink *_displaylink;
    
}
@property (nonatomic,assign)float angleShoulder;
@property (nonatomic,assign)float angleEblow;
-(void)setupLayer;
-(void)setupContext;
-(void)setupRenderBuffer;
-(void)setupFrameBuffer;
-(void)destroyRenderAndFrameBuffer;
-(void)render;
-(void)setupProgram;
-(void)setupProjection;
//-(void)cleanup;
-(void)toggleDisplayLink;

-(void)updateShoulderTransform;
-(void)updateEblowTransform;

-(void)updateColorCubeTransform;
-(void)drawColorCube;
-(void)drawCube:(ksVec4) color;
-(void)displayLinkCallback:(CADisplayLink *)displayLink;
@end
