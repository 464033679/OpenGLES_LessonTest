//
//  OpenGLView.h
//  Tutorial01Test
//
//  Created by 李明 on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OPenGLES/ES2/gl.h>
#include <OPenGLES/ES2/glext.h>
#import "GLESUtils.h"
#include "ksMatrix.h"
@interface OpenGLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _projectionMatrix;
    
    float _trans_x;
    float _trans_y;
    float _trans_z;
    
    float _angle_x;
    float _angle_y;
    float _angle_z;
    
    float _scale_x;
    float _scale_y;
    float _scale_z;
    CADisplayLink *_displayLink;
}
@property (nonatomic,assign) float trans_x;
@property (nonatomic,assign) float trans_y;
@property (nonatomic,assign) float trans_z;
@property (nonatomic,assign) float angle_x;
@property (nonatomic,assign) float angle_y;
@property (nonatomic,assign) float angle_z;
@property (nonatomic,assign) float scale_x;
@property (nonatomic,assign) float scale_y;
@property (nonatomic,assign) float scale_z;
-(void)setupLayer;
-(void)setupContext;
-(void)setupRenderBuffer;
-(void)setupFrameBuffer;
-(void)destroyRenderAndFrameBuffer;
-(void)render;
-(void)setupProgram;
-(void)setupProjection;
-(void)updateTransform;
-(void)resetTransform;
-(void)displayLinkCallback:(CADisplayLink *)displayLink;
-(void)toggleDisplayLink;
@end
