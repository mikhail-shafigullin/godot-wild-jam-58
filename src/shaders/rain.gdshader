shader_type canvas_item;

render_mode unshaded, blend_add;

uniform vec3 uv1_scale = vec3(4.0, 4.0, 4.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float o9498_rainRate = 1.760000000; // {default:1, label:rain, max:100, min:0, name:rainRate, step:0.01, type:named_parameter}
uniform float o9498_rainSpeed = 0.070000000; // {default:0.5, label:speed, max:10, min:0, name:rainSpeed, step:0.01, type:named_parameter}
uniform float o9498_rainAng = -1.020000000; // {default:0, label:and, max:360, min:0, name:rainAng, step:0.01, type:named_parameter}
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
uniform sampler2D texture_1;
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
const float p_o9499_cx = -0.500000000;
const float p_o9499_cy = -0.500000000;
const float seed_o9487 = 0.898660004;
const float p_o9487_count = 3.000000000;
const float p_o9487_scale_x = 1.000000000;
const float p_o9487_scale_y = 1.000000000;
const float p_o9487_rotate = 0.000000000;
const float p_o9487_scale = 0.000000000;
const float p_o9487_value = 0.200000000;
const float p_o9486_rotate = 0.000000000;
const float p_o9486_scale_x = 1.000000000;
const float p_o9486_scale_y = 1.000000000;
const float seed_o9493 = 0.279995084;
const float p_o9493_overlap = 3.000000000;
const float p_o9493_scale_x = 0.500000000;
const float p_o9493_scale_y = 0.500000000;
const float p_o9493_fixed_offset = 0.500000000;
const float p_o9493_offset = 0.500000000;
const float p_o9493_rotate = 0.000000000;
const float p_o9493_scale = 0.500000000;
const float p_o9493_value = 0.330000000;
const float seed_o9492 = 0.291207969;
const float p_o9492_rotate = 0.000000000;
const float p_o9492_scale_x = 0.010000000;
const float p_o9497_sides = 1.000000000;
const float p_o9497_radius = 0.450000000;
const float p_o9497_edge = 0.060000000;
float o9493_input_in(vec2 uv, float _seed_variation_) {
float o9497_0_1_f = shape_circle((transform2((uv), vec2((cos(elapsed_time+param_rnd(0,1, (seed_o9492+fract(_seed_variation_))+-0.999990))*0.05)*(2.0*1.0-1.0), (sin(elapsed_time+param_rnd(0,1, (seed_o9492+fract(_seed_variation_))+16.000010))*0.05)*(2.0*1.0-1.0)), p_o9492_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o9492_scale_x*(2.0*1.0-1.0), (o9498_rainSpeed * 0.1 + 0.02)*(2.0*1.0-1.0)))), p_o9497_sides, p_o9497_radius*1.0, p_o9497_edge*1.0);
vec4 o9492_0_1_rgba = vec4(vec3(o9497_0_1_f), 1.0);
return (dot((o9492_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o9493_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 tiler_o9493(vec2 uv, vec2 tile, int overlap, inout vec3 instance_uv, vec2 _seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	for (int dx = -overlap; dx <= overlap; ++dx) {
		for (int dy = -overlap; dy <= overlap; ++dy) {
			vec2 pos = uv*tile+vec2(float(dx), float(dy)); pos = fract((floor(mod(pos, tile))+vec2(0.5))/tile)-vec2(0.5);
			vec2 seed = rand2(pos+_seed);
			rc1 = rand3(seed);
			pos = fract(pos+vec2(p_o9493_fixed_offset/tile.x, 0.0)*floor(mod(pos.y*tile.y, 2.0))+p_o9493_offset*seed/tile);
			float mask = o9493_input_mask(fract(pos+vec2(0.5)), _seed_variation_);
			if (mask > 0.01) {
				vec2 pv = fract(uv - pos)-vec2(0.5);
				seed = rand2(seed);
				float angle = (seed.x * 2.0 - 1.0) * p_o9493_rotate * 0.01745329251;
				float ca = cos(angle);
				float sa = sin(angle);
				pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
				pv *= (seed.y-0.5)*2.0*p_o9493_scale+1.0;
				pv /= vec2(p_o9493_scale_x, p_o9493_scale_y);
				pv += vec2(0.5);
				seed = rand2(seed);
				vec2 clamped_pv = clamp(pv, vec2(0.0), vec2(1.0));
				if (pv.x != clamped_pv.x || pv.y != clamped_pv.y) {
					continue;
				}
				vec2 full_uv = pv;
				pv = get_from_tileset( 1.0, seed.x, pv);
				float c1 = o9493_input_in(pv, true ? seed.x : 0.0)*mask*(1.0-p_o9493_value*seed.x);
				c = max(c, c1);
				rc = mix(rc, rc1, step(c, c1));
				instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
			}
		}
	}
	return vec4(rc, c);
}float o9487_input_in(vec2 uv, float _seed_variation_) {
vec3 o9493_0_instance_uv = vec3(0.0);
vec4 o9493_0_rch = tiler_o9493((fract(transform2((uv), vec2((o9498_rainRate)*(2.0*1.0-1.0), (elapsed_time*o9498_rainSpeed)*(2.0*1.0-1.0)), p_o9486_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o9486_scale_x*(2.0*1.0-1.0), p_o9486_scale_y*(2.0*1.0-1.0))))), vec2((o9498_rainRate * 1.2), (o9498_rainRate * 2.0)), int(p_o9493_overlap), o9493_0_instance_uv, vec2(float((seed_o9493+fract(_seed_variation_)))), _seed_variation_);float o9493_0_1_f = o9493_0_rch.a;
vec4 o9486_0_1_rgba = vec4(vec3(o9493_0_1_f), 1.0);
return (dot((o9486_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o9487_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o9487(vec2 uv, int count, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	for (int i = 0; i < count; ++i) {
		seed = rand2(seed);
		rc1 = rand3(seed);
		float mask = o9487_input_mask(fract(seed+vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = fract(uv - seed)-vec2(0.5);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o9487_rotate * 0.01745329251;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv *= (seed.y-0.5)*2.0*p_o9487_scale+1.0;
			pv /= vec2(p_o9487_scale_x, p_o9487_scale_y);
			pv += vec2(0.5);
			seed = rand2(seed);
			vec2 clamped_pv = clamp(pv, vec2(0.0), vec2(1.0));
			if (pv.x != clamped_pv.x || pv.y != clamped_pv.y) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o9487_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o9487_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o79992_default_in1 = 0.000000000;
const float p_o79992_default_in2 = 0.000000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract( SCREEN_UV *uv1_scale.xy+uv1_offset.xy );
vec2 o9499_0_c = vec2(0.5+p_o9499_cx, 0.5+p_o9499_cy);vec3 o9487_0_instance_uv = vec3(0.0);
vec4 o9487_0_rch = splatter_o9487((rotate((uv)-o9499_0_c, (o9498_rainAng)*0.01745329251)+o9499_0_c), int(p_o9487_count), o9487_0_instance_uv, vec2(float((seed_o9487+fract(_seed_variation_)))), _seed_variation_);float o9487_0_1_f = o9487_0_rch.a;
vec4 o9499_0_1_rgba = vec4(vec3(o9487_0_1_f), 1.0);
float o44287_0_1_f = o9499_0_1_rgba.r;
vec4 o38081_0 = textureLod(texture_1, (SCREEN_UV), 0.0);
float o59814_3_1_f = o38081_0.a;
float o79992_0_clamp_false = o44287_0_1_f-o59814_3_1_f;
float o79992_0_clamp_true = clamp(o79992_0_clamp_false, 0.0, 1.0);
float o79992_0_1_f = o79992_0_clamp_true;
vec4 o46537_0_1_rgba = vec4(o44287_0_1_f, o44287_0_1_f, o44287_0_1_f, o79992_0_1_f);

	vec4 color_tex = o46537_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	COLOR = color_tex;

}



