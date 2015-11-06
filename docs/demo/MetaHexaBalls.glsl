extern vec3 iResolution;
extern number iGlobalTime;
extern vec4 iMouse;



/*by mu6k, Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

 I have no idea how I ended up here, but it demosceneish enough to publish.
 You can use the mouse to rotate the camera around the 'object'.
 If you can't see the shadows, increase occlusion_quality.
 If it doesn't compile anymore decrease object_count and render_steps.

 15/06/2013:
 - published

 16/06/2013:
 - modified for better performance and compatibility

 muuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuusk!*/

#define occlusion_enabled
#define occlusion_quality 4
//#define occlusion_preview

#define noise_use_smoothstep

#define light_color vec3(0.1,0.4,0.6)
#define light_direction normalize(vec3(.2,1.0,-0.2))
#define light_speed_modifier 1.0

#define object_color vec3(0.9,0.1,0.1)
#define object_count 9
#define object_speed_modifier 1.0

#define render_steps 33

number hash(number x)
{
	return fract(sin(x*.0127863)*17143.321);
}

number hash(vec2 x)
{
	return fract(cos(dot(x.xy,vec2(2.31,53.21))*124.123)*412.0);
}

vec3 cc(vec3 color, number factor,number factor2) //a wierd color modifier
{
	number w = color.x+color.y+color.z;
	return mix(color,vec3(w)*factor,w*factor2);
}

number hashmix(number x0, number x1, number interp)
{
	x0 = hash(x0);
	x1 = hash(x1);
	#ifdef noise_use_smoothstep
	interp = smoothstep(0.0,1.0,interp);
	#endif
	return mix(x0,x1,interp);
}

number noise(number p) // 1D noise
{
	number pm = mod(p,1.0);
	number pd = p-pm;
	return hashmix(pd,pd+1.0,pm);
}

vec3 rotate_y(vec3 v, number angle)
{
	number ca = cos(angle); number sa = sin(angle);
	return v*mat3(
		+ca, +.0, -sa,
		+.0,+1.0, +.0,
		+sa, +.0, +ca);
}

vec3 rotate_x(vec3 v, number angle)
{
	number ca = cos(angle); number sa = sin(angle);
	return v*mat3(
		+1.0, +.0, +.0,
		+.0, +ca, -sa,
		+.0, +sa, +ca);
}

number max3(number a, number b, number c)//returns the maximum of 3 values
{
	return max(a,max(b,c));
}

vec3 bpos[object_count];//position for each metaball

number dist(vec3 p)//distance function
{
	number d=1024.0;
	number nd;
	for (int i=0 ;i<object_count; i++)
	{
		vec3 np = p+bpos[i];
		number shape0 = max3(abs(np.x),abs(np.y),abs(np.z))-1.0;
		number shape1 = length(np)-1.0;
		nd = shape0+(shape1-shape0)*2.0;
		d = mix(d,nd,smoothstep(-1.0,+1.0,d-nd));
	}
	return d;
}

vec3 normal(vec3 p,number e) //returns the normal, uses the distance function
{
	number d=dist(p);
	return normalize(vec3(dist(p+vec3(e,0,0))-d,dist(p+vec3(0,e,0))-d,dist(p+vec3(0,0,e))-d));
}

vec3 light = light_direction; //global variable that holds light direction

vec3 background(vec3 d)//render background
{
	number t=iGlobalTime*0.5*light_speed_modifier;
	number qq = dot(d,light)*.5+.5;
	number bgl = qq;
	number q = (bgl+noise(bgl*6.0+t)*.85+noise(bgl*12.0+t)*.85);
	q+= pow(qq,32.0)*2.0;
	vec3 sky = vec3(0.1,0.4,0.6)*q;
	return sky;
}

number occlusion(vec3 p, vec3 d)//returns how much a point is visible from a given direction
{
	number occ = 1.0;
	p=p+d;
	for (int i=0; i<occlusion_quality; i++)
	{
		number dd = dist(p);
		p+=d*dd;
		occ = min(occ,dd);
	}
	return max(.0,occ);
}

vec3 object_material(vec3 p, vec3 d)
{
	vec3 color = normalize(object_color*light_color);
	vec3 n = normal(p,0.1);
	vec3 r = reflect(d,n);

	number reflectance = dot(d,r)*.5+.5;reflectance=pow(reflectance,2.0);
	number diffuse = dot(light,n)*.5+.5; diffuse = max(.0,diffuse);

	#ifdef occlusion_enabled
		number oa = occlusion(p,n)*.4+.6;
		number od = occlusion(p,light)*.95+.05;
		number os = occlusion(p,r)*.95+.05;
	#else
		number oa=1.0;
		number ob=1.0;
		number oc=1.0;
	#endif

	#ifndef occlusion_preview
		color =
		color*oa*.2 + //ambient
		color*diffuse*od*.7 + //diffuse
		background(r)*os*reflectance*.7; //reflection
	#else
		color=vec3((oa+od+os)*.3);
	#endif

	return color;
}

#define offset1 4.7
#define offset2 4.6

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy - 0.5;
	uv.x *= iResolution.x/iResolution.y; //fix aspect ratio
	vec3 mouse = vec3(iMouse.xy/iResolution.xy - 0.5,iMouse.z-.5);

	number t = iGlobalTime*.5*object_speed_modifier + 2.0;

	for (int i=0 ;i<object_count; i++) //position for each metaball
	{
		bpos[i] = 1.3*vec3(
			sin(t*0.967+number(i)*42.0),
			sin(t*.423+number(i)*152.0),
			sin(t*.76321+number(i)));
	}

	//setup the camera
	vec3 p = vec3(.0,0.0,-4.0);
	p = rotate_x(p,mouse.y*9.0+offset1);
	p = rotate_y(p,mouse.x*9.0+offset2);
	vec3 d = vec3(uv,1.0);
	d.z -= length(d)*.5; //lens distort
	d = normalize(d);
	d = rotate_x(d,mouse.y*9.0+offset1);
	d = rotate_y(d,mouse.x*9.0+offset2);

	//and action!
	number dd;
	vec3 color;
	for (int i=0; i<render_steps; i++) //raymarch
	{
		dd = dist(p);
		p+=d*dd*.7;
		if (dd<.04 || dd>4.0) break;
	}

	if (dd<0.5) //close enough
		color = object_material(p,d);
	else
		color = background(d);

	//post procesing
	color *=.85;
	color = mix(color,color*color,0.3);
	color -= hash(color.xy+uv.xy)*.015;
	color -= length(uv)*.1;
	color =cc(color,.5,.6);
	fragColor = vec4(color,1.0);
}



vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
    vec2 fragCoord = texture_coords * iResolution.xy;
    mainImage( color, fragCoord );
    return color;
}