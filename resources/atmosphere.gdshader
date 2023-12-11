shader_type spatial;
//render_mode unshaded;
const vec3 sphere_position = vec3(0.0,0.0,0.0);
const float sphere_radius = 6.480;
uniform float thickness_scale = 3.2;
varying vec3 cam_position;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;
vec3 raySpehereIntersectMaxDepthAlt(vec3 ro, vec3 rd,vec3 so, float sr, float max_depth){
	float t = dot(so-ro,rd);
	vec3 P = ro + rd*t;
	float y = length(so -P);
	
	if (y>sr){
		return vec3(-1.0);
	}
	float x = sqrt(sr*sr - y*y);
	float t1 = max(t-x,0.0);
	float t2 = min(t+x,max_depth);
	return vec3(t1,t2,min(1.0-y/sphere_radius,0.016));
}
void vertex(){
	cam_position = MODELVIEW_MATRIX[3].xyz;
}

void fragment(){
	float depth = texture(DEPTH_TEXTURE,SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc,1.0);
	view.xyz/= view.w;
	float max_depth = length(view.xyz);
	vec3 so =- (vec4(sphere_position, 1.0) * INV_VIEW_MATRIX).xyz;
	vec3 rsi = raySpehereIntersectMaxDepthAlt(cam_position, VIEW, so , sphere_radius, max_depth);
	
	ALPHA = clamp((rsi.y - rsi.x)*thickness_scale*rsi.z,0.0,1.0);
}
