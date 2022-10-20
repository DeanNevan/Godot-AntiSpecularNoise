shader_type canvas_item;
render_mode blend_mix;

uniform bool enable = true;
uniform bool debug_draw = false;

uniform int scan_level = 3;						// 对周围多少圈的相邻点进行扫描
uniform float luminance_threshold = 0.3;		// 亮度大于多少判定为亮点
uniform int noise_points_count_threshold = 30;	// 扫描时，相邻点为亮点的数量小于多少才认定为杂点

uniform int blur_count = 16;					// 与周围多少个相邻点计算色彩均值

float get_luminance(vec3 color) {
	return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
}

void fragment() {
	
	vec4 col = texture(TEXTURE, UV);
	if (!enable) {
		COLOR = col;
	}
	else {
		vec2 ps = TEXTURE_PIXEL_SIZE;
		bool is_noise = true;
		if (get_luminance(col.rgb) < luminance_threshold) is_noise = false;
		if (is_noise) {
			int count = 0;
			for (int level = 1; level <= scan_level; level++) {
				float x_from = UV.x - float(level) * ps.x;
				float x_to = UV.x + float(level) * ps.x;
				float y_from = UV.y - float(level) * ps.y;
				float y_to = UV.y + float(level) * ps.y;
				int times = 2 * level;
				float x_step = (x_to - x_from) / float(times);
				float y_step = (y_to - y_from) / float(times);
				for (int x_time = 0; x_time <= times; x_time++) {
					for (int y_time = 0; y_time <= times; y_time++) {
						float x = x_from + x_step * float(x_time);
						float y = y_from + y_step * float(y_time);
						vec4 offset_color = texture(TEXTURE, vec2(x, y));
						if (get_luminance(offset_color.rgb) >= luminance_threshold) {
							count += 1;
							if (count >= noise_points_count_threshold) {
								is_noise = false;
								break;
							}
						}
					}
					if (!is_noise) {
						break;
					}
				}
				if (!is_noise) {
					break;
				}
			}
		}
		
		if (is_noise) {
			if (debug_draw) {
				COLOR = vec4(1.0, 0.0, 0.0, 1.0);
			}
			else {
				int count = 0;
				for (int level = 1; level > 0; level++) {
					float x_from = UV.x - float(level) * ps.x;
					float x_to = UV.x + float(level) * ps.x;
					float y_from = UV.y - float(level) * ps.y;
					float y_to = UV.y + float(level) * ps.y;
					int times = 2 * level;
					float x_step = (x_to - x_from) / float(times);
					float y_step = (y_to - y_from) / float(times);
					for (int x_time = 0; x_time <= times; x_time++) {
						for (int y_time = 0; y_time <= times; y_time++) {
							float x = x_from + x_step * float(x_time);
							float y = y_from + y_step * float(y_time);
							col += texture(TEXTURE, vec2(x, y));
							count += 1;
							if (count >= blur_count) break;
						}
						if (count >= blur_count) break;
					}
					if (count >= blur_count) break;
				}
				col /= float(blur_count + 1);
				COLOR = col;
			}
		}
		else{
			COLOR = col;
		}
	}
}
