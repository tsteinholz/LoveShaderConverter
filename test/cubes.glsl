vec2 doModel(vec3 p);

float gaussianSpecular_2_0(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float shininess) {
  vec3 H = normalize(lightDirection + viewDirection);
  float theta = acos(dot(H, surfaceNormal));
  float w = theta / shininess;
  return exp(-w*w);
}

vec2 calcRayIntersection_3_1(vec3 rayOrigin, vec3 rayDir, float maxd, float precis) {
  float latest = precis * 2.0;
  float dist   = +0.0;
  float type   = -1.0;
  vec2  res    = vec2(-1.0, -1.0);

  for (int i = 0; i < 125; i++) {
    if (latest < precis || dist > maxd) break;

    vec2 result = doModel(rayOrigin + rayDir * dist);

    latest = result.x;
    type   = result.y;
    dist  += latest * 0.75;
  }

  if (dist < maxd) {
    res = vec2(dist, type);
  }

  return res;
}

vec2 calcRayIntersection_3_1(vec3 rayOrigin, vec3 rayDir) {
  return calcRayIntersection_3_1(rayOrigin, rayDir, 20.0, 1.);
}


vec3 calcNormal_4_2(vec3 pos, float eps) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * doModel( pos + v1*eps ).x +
                    v2 * doModel( pos + v2*eps ).x +
                    v3 * doModel( pos + v3*eps ).x +
                    v4 * doModel( pos + v4*eps ).x );
}

vec3 calcNormal_4_2(vec3 pos) {
  return calcNormal_4_2(pos, 0.002);
}

vec2 squareFrame_9_3(vec2 screenSize, vec2 coord) {
  vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}



mat3 calcLookAtMatrix_11_4(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}




vec3 getRay_10_5(mat3 camMat, vec2 screenPos, float lensLength) {
  return normalize(camMat * vec3(screenPos, lensLength));
}

vec3 getRay_10_5(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = calcLookAtMatrix_11_4(origin, target, 0.0);
  return getRay_10_5(camMat, screenPos, lensLength);
}




void orbitCamera_5_6(
  in float camAngle,
  in float camHeight,
  in float camDistance,
  in vec2 screenResolution,
  out vec3 rayOrigin,
  out vec3 rayDirection,
  in vec2 fragCoord
) {
  vec2 screenPos = squareFrame_9_3(screenResolution, fragCoord);
  vec3 rayTarget = vec3(0.0);

  rayOrigin = vec3(
    camDistance * sin(camAngle),
    camHeight,
    camDistance * cos(camAngle)
  );

  rayDirection = getRay_10_5(rayOrigin, rayTarget, screenPos, 2.0);
}

highp float random_6_13(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}


// Originally sourced from:
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float sdBox_7_14(vec3 position, vec3 dimensions) {
  vec3 d = abs(position) - dimensions;

  return min(max(d.x, max(d.y,d.z)), 0.0) + length(max(d, 0.0));
}



float fogFactorExp2_8_15(
  const float dist,
  const float density
) {
  const float LOG2 = -1.442695;
  float d = density * dist;
  return 1.0 - clamp(exp2(d * d * LOG2), 0.0, 1.0);
}



  
#define rs(a) (a * 0.5 + 0.5)
#define sr(a) (a * 2.0 - 1.0)
  
vec3 wrap(vec3 v, float n) {
  return mod(v + n, n * 2.) - n;
}

vec3 wrapId(vec3 p, float v) {
  return floor(p / v + 0.5) * v;
}
  
vec3 fogColor = vec3(0.015, 0.09, 0.2).bgr;

// http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
mat4 rotationMatrix(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
              oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
              oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
              0.0,                                0.0,                                0.0,                                1.0);
}

float boxGrid(vec3 p, float l) {
  vec3 idx = wrapId(p, l);
  float idd = idx.y + idx.x + idx.z;
  
  p.xyz = wrap(p.xyz, l);
  
  vec3 dim = vec3(0.225);
  
  dim *= rs(sin(idd * 0.924 + iGlobalTime * 0.5)) * 0.5 + 0.5;
  p.y += sin(iGlobalTime * 0.8 + idd * 43.43290432) * 0.065;
  p.z += sin(iGlobalTime * 1.1 + idd * 93.43290432) * 0.065;
  p.x += sin(iGlobalTime * 1.5 + idd * 23.43290432) * 0.065;
  p = ((rotationMatrix(normalize(vec3(idx.xz, 1)), 1.5 * iGlobalTime + idd * 1.324)) * vec4(p, 1)).xyz;
  
  return sdBox_7_14(p, dim);
}

vec2 doModel(vec3 p) {
  float id = 0.0;
  
  p.z += sin(p.y * 0.125) * 2.;
  
  float d1 = boxGrid(p, 1.5);
  float d2 = d1;
  
  return vec2(min(d1, d2), id);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec3 color = fogColor;
  vec3 ro, rd;
  vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.;
  
  float rotation = sin(iGlobalTime * 0.2);
  float height   = 10.5;
  float dist     = 2.5;
  orbitCamera_5_6(rotation, height, dist, iResolution.xy, ro, rd, fragCoord);

  ro.y += iGlobalTime * 3.5;
  
  vec2 t = calcRayIntersection_3_1(ro, rd, 50.0, 0.035);
  if (t.x > -0.5) {
    vec3 pos = ro + rd * t.x;
    vec3 nor = calcNormal_4_2(pos);
    vec3 ang = vec3(0, 1, 0);
    vec3 mat = vec3(0.9, 0.5, 0.3);
    vec3 col = vec3(0.8, 0.7, 0.4);
    
    float diff = max(0.0, dot(nor, ang)) * 0.25;
    float spec = gaussianSpecular_2_0(ang, -rd, nor, 0.38);
    
    color = vec3(col * mat * diff + spec * col);
  }
  
  color = mix(clamp(color, vec3(0), vec3(1)), fogColor, fogFactorExp2_8_15(t.x, 0.04));
  color *= 1.0 - dot(uv, uv) * 0.3 * vec3(1.05, 1.35, 1.2);
  color = pow(color, vec3(0.7575));
  color.b = smoothstep(-0.1, 0.9, color.b);
  color = mix(color, color.rrr, 3.5);

  fragColor.rgb = color;
  fragColor.a   = 1.0;
}