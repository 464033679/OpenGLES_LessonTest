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
@interface OpenGLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _depthBuffer;
    GLuint _frameBuffer;
}
-(void)setupLayer;
-(void)setupContext;
-(void)setupRenderBuffer;
-(void)setupFrameBuffer;
-(void)destroyRenderAndFrameBuffer;
-(void)render;
//-(void)setupDepthBuffer;
@end


