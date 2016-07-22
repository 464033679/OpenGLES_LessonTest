uniform mat4 projection;
uniform mat4 modelView;
attribute vec4 vPosition;
attribute vec4 vSourceColor;
varying vec4 vDestinationColor;

//光照有关变量
uniform mat3 normalMatrix;
uniform vec3 vLightPosition;
uniform vec4 vAmbientMaterial;
uniform vec4 vSpecularMaterial;
uniform float shininess;

attribute vec4 vDiffuseMaterial;
attribute vec3 vNormal;

void main(void)
{
    gl_Position = projection * modelView  * vPosition;
    vec3 N = normalMatrix * vNormal;//法线向量
    vec3 L = normalize(vLightPosition);//入射光线向量
    vec3 E = vec3(0,0,1);//视线向量
    vec3 H = normalize(L+E);//平分线向量
    float df = max(0.0,dot(N,L));//漫反射因子
    float sf = max(0.0,dot(N,H));//镜面反射因子
    sf = pow(sf,shininess);
    if(df < 0.1)
    df = 0.0;
    else if(df< 0.2)
    df = 0.2;
    else if(df < 0.4)
    df = 0.4;
    else if(df <0.6)
    df = 0.6;
    else if(df <0.8)
    df = 0.8;
    else df = 1.0;
    vDestinationColor = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
    //vDestinationColor = vSourceColor;
}
