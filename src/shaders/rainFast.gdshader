shader_type canvas_item;

render_mode unshaded, blend_add;
uniform sampler2D texture_1;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
uniform float o131592_rainRate = 25.000000000; // {default:1, label:rain, max:100, min:0, name:rainRate, step:0.01, type:named_parameter}
uniform float o131592_rainSpeed = 1.000000000; // {default:0.5, label:speed, max:10, min:0, name:rainSpeed, step:0.01, type:named_parameter}
uniform float o131592_rainAng = 0.000000000; // {default:0, label:and, max:360, min:0, name:rainAng, step:0.01, type:named_parameter}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
vec2 get_from_tileset(float count, float seed, vec2 uv) {
	return clamp((uv+floor(rand2(vec2(seed))*count))/count, vec2(0.0), vec2(1.0));
}
vec2 custom_uv_transform(vec2 uv, vec2 cst_scale, float rnd_rotate, float rnd_scale, vec2 seed) {
	seed = rand2(seed);
	uv -= vec2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = vec2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += vec2(0.5);
	return uv;
}
vec2 rotate(vec2 uv, float rotate) {
 	vec2 rv;
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	return rv;	
}
const float p_o1289527_w = 0.250000000;
const float p_o131593_cx = 0.000000000;
const float p_o131593_cy = 0.000000000;
const float p_o131580_rotate = 0.000000000;
const float p_o131580_scale_x = 1.000000000;
const float p_o131580_scale_y = 1.000000000;
const float seed_o131587 = 0.279995084;
const float p_o131587_overlap = 1.000000000;
const float p_o131587_scale_x = 0.300000000;
const float p_o131587_scale_y = 0.500000000;
const float p_o131587_fixed_offset = 0.500000000;
const float p_o131587_offset = 0.500000000;
const float p_o131587_rotate = 0.000000000;
const float p_o131587_scale = 0.500000000;
const float p_o131587_value = 1.000000000;
const float seed_o131586 = 0.291207969;
const float p_o131586_rotate = 0.000000000;
const float p_o131586_scale_x = 0.030000000;
const float p_o131591_sides = 1.000000000;
const float p_o131591_radius = 0.400000000;
const float p_o131591_edge = 0.020000000;
float o131587_input_in(vec2 uv, float _seed_variation_) {
float o131591_0_1_f = shape_circle((transform2((uv), vec2((cos(elapsed_time+param_rnd(0,1, (seed_o131586+fract(_seed_variation_))+-0.999990))*0.05)*(2.0*1.0-1.0), (sin(elapsed_time+param_rnd(0,1, (seed_o131586+fract(_seed_variation_))+16.000010))*0.01)*(2.0*1.0-1.0)), p_o131586_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o131586_scale_x*(2.0*1.0-1.0), (o131592_rainSpeed * 0.03 + 0.03)*(2.0*1.0-1.0)))), p_o131591_sides, p_o131591_radius*1.0, p_o131591_edge*1.0);
vec4 o131586_0_1_rgba = vec4(vec3(o131591_0_1_f), 1.0);
return (dot((o131586_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o131587_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 tiler_o131587(vec2 uv, vec2 tile, int overlap, inout vec3 instance_uv, vec2 _seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	for (int dx = -overlap; dx <= overlap; ++dx) {
		for (int dy = -overlap; dy <= overlap; ++dy) {
			vec2 pos = uv*tile+vec2(float(dx), float(dy)); pos = fract((floor(mod(pos, tile))+vec2(0.5))/tile)-vec2(0.5);
			vec2 seed = rand2(pos+_seed);
			rc1 = rand3(seed);
			pos = fract(pos+vec2(p_o131587_fixed_offset/tile.x, 0.0)*floor(mod(pos.y*tile.y, 2.0))+p_o131587_offset*seed/tile);
			float mask = o131587_input_mask(fract(pos+vec2(0.5)), _seed_variation_);
			if (mask > 0.01) {
				vec2 pv = fract(uv - pos)-vec2(0.5);
				seed = rand2(seed);
				float angle = (seed.x * 2.0 - 1.0) * p_o131587_rotate * 0.01745329251;
				float ca = cos(angle);
				float sa = sin(angle);
				pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
				pv *= (seed.y-0.5)*2.0*p_o131587_scale+1.0;
				pv /= vec2(p_o131587_scale_x, p_o131587_scale_y);
				pv += vec2(0.5);
				seed = rand2(seed);
				vec2 clamped_pv = clamp(pv, vec2(0.0), vec2(1.0));
				if (pv.x != clamped_pv.x || pv.y != clamped_pv.y) {
					continue;
				}
				vec2 full_uv = pv;
				pv = get_from_tileset( 1.0, seed.x, pv);
				float c1 = o131587_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o131587_value*seed.x);
				c = max(c, c1);
				rc = mix(rc, rc1, step(c, c1));
				instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
			}
		}
	}
	return vec4(rc, c);
}vec4 o1289527_input_in(vec2 uv, float _seed_variation_) {
vec2 o131593_0_c = vec2(0.5+p_o131593_cx, 0.5+p_o131593_cy);vec3 o131587_0_instance_uv = vec3(0.0);
vec4 o131587_0_rch = tiler_o131587((fract(transform2((rotate((uv)-o131593_0_c, (o131592_rainAng)*0.01745329251)+o131593_0_c), vec2((o131592_rainRate)*(2.0*1.0-1.0), (elapsed_time*o131592_rainSpeed)*(2.0*1.0-1.0)), p_o131580_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o131580_scale_x*(2.0*1.0-1.0), p_o131580_scale_y*(2.0*1.0-1.0))))), vec2((o131592_rainRate), (o131592_rainRate)), int(p_o131587_overlap), o131587_0_instance_uv, vec2(float((seed_o131587+fract(_seed_variation_)))), _seed_variation_);float o131587_0_1_f = o131587_0_rch.a;
vec4 o131580_0_1_rgba = vec4(vec3(o131587_0_1_f), 1.0);
vec4 o131593_0_1_rgba = o131580_0_1_rgba;
return o131593_0_1_rgba;
}
vec4 make_tileable_o1289527(vec2 uv, float w, float _seed_variation_) {
	vec4 a = o1289527_input_in(uv, _seed_variation_);
	vec4 b = o1289527_input_in(fract(uv+vec2(0.5)), _seed_variation_);
	float coef_ab = sin(1.57079632679*clamp((length(uv-vec2(0.5))-0.5+w)/w, 0.0, 1.0));
	vec4 c = o1289527_input_in(fract(uv+vec2(0.25)), _seed_variation_);
	float coef_abc = sin(1.57079632679*clamp((min(min(length(uv-vec2(0.0, 0.5)), length(uv-vec2(0.5, 0.0))), min(length(uv-vec2(1.0, 0.5)), length(uv-vec2(0.5, 1.0))))-w)/w, 0.0, 1.0));
	return mix(c, mix(a, b, coef_ab), coef_abc);
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec4 o1289527_0_1_rgba = make_tileable_o1289527((uv), 0.5*p_o1289527_w, _seed_variation_);

	vec4 color_tex = o1289527_0_1_rgba;
	color_tex.a = color_tex.a - texture(texture_1, SCREEN_UV).a;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	COLOR = color_tex;

}



