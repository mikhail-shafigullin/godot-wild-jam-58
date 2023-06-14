shader_type canvas_item;

uniform sampler2D rainMask;

void fragment(){
	
	COLOR = vec4(vec3(float(texture(rainMask, UV).a > 0.05)), 1);
}