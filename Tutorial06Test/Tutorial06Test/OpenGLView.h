//
//  OpenGLView.h
//  123123
//
//  Created by 李明 on 13-1-30.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#include "GLESUtils.h"
#include "ksMatrix.h"
@interface OpenGLView : UIView
{
    
    CAEAGLLayer *_eagllayer;
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
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _projectionMatrix;
    
    //光照有关槽位
    
    GLuint _normalMatrixSolt;
    GLuint _lightPositionSolt;
    
    GLint _normalSolt;
    GLint _ambientSolt;
    GLint _specularSolt;
    GLint _diffuseSolt;
    GLint _shininessSolt;
    
    
    ksVec3 _lightPosition;
    ksColor _ambient;
    ksColor _diffuse;
    ksColor _specular;
    GLfloat _shininess;
}
@property (nonatomic,assign)ksVec3 lightPosition;
@property (nonatomic,assign)ksColor ambient;
@property (nonatomic,assign)ksColor diffuse;
@property (nonatomic,assign)ksColor specular;
@property (nonatomic,assign)GLfloat shininess;
@end
