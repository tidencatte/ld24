effects = {
		simple = [[
			extern vec4 color2;

			vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
				return (color2 * Texel(texture, tc)) / 255;
			}
		]],

		palette = [[
		extern vec4 palette[16];
		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
			vec3 nc = dot(Texel(texture, tc).rgb, vec3(0.333));
			if (Texel(texture, tc).a == 0.0) {
				return Texel(texture, tc);
			}
			int id = int(trunc(max(nc.r, max(nc.g, nc.b))*16));
			return palette[id];
		}
		]]
}


function tintor(effect)
	return love.graphics.newPixelEffect(effects[effect])
end
