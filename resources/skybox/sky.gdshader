shader_type sky;
render_mode use_half_res_pass;


// Sky Gradients
uniform vec3 day_bottom_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 day_top_color : source_color = vec3(1.0, 1.0, 1.0);

uniform vec3 sunset_bottom_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 sunset_top_color : source_color = vec3(0.0, 0.0, 0.0);

uniform vec3 night_bottom_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 night_top_color : source_color = vec3(0.0, 0.0, 0.0);


// Horizon Stuff
uniform vec3 horizon_color_day : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 horizon_color_sunset : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 horizon_color_night : source_color = vec3(0.0, 0.8, 1.0);
uniform float horizon_falloff: hint_range(0.0, 1.0, 0.1);


// Sun Stuff
uniform vec3 sun_col: source_color = vec3(1.0);
uniform float sun_size: hint_range(0.01, 1.0) = 1.0;
uniform float sun_blur: hint_range(0.01, 1.0) = 0.01;


// Moon Stuff
uniform vec3 moon_col: source_color = vec3(1.0);
uniform float moon_size: hint_range(0.01, 1.0) = 1.0;
uniform float moon_crescent_offset: hint_range(-1.0, 1.0) = 0.5;


// Clouds Stuff
uniform sampler2D clouds_texture: filter_linear_mipmap;
uniform sampler2D clouds_distort_texture: filter_linear_mipmap;
uniform sampler2D clouds_noise_texture: filter_linear_mipmap;
uniform vec3 clouds_main_color: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 clouds_edge_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float clouds_speed: hint_range(0.0, 0.1, 0.01);
uniform float clouds_scale: hint_range(0.0, 1.0, 0.01);
uniform float clouds_cutoff: hint_range(0.0, 1.0, 0.01);
uniform float clouds_fuzziness: hint_range(0.0, 1.0, 0.01);


// Star Stuff
uniform sampler2D stars_texture: filter_linear_mipmap;
uniform float stars_cutoff;
uniform float stars_speed: hint_range(0.0, 0.1);
uniform float stars_visibility_factor;

uniform float progress: hint_range(0.0, 1.0, 0.01);

void sky() {
	vec2 sky_uv = EYEDIR.xz / EYEDIR.y;
	
    float player_progress = 1.0 - (progress * 2.0);
    
	float day_amount = clamp(player_progress, 0.0, 1.0);
	vec3 gradient_day = mix(day_bottom_color, day_top_color, clamp(EYEDIR.y, 0.0, 1.0)) * day_amount;
	
	float sunset_amount = clamp(1.0 - abs(player_progress), 0.0, 1.0);
	vec3 gradient_sunset = mix(sunset_bottom_color, sunset_top_color, clamp(EYEDIR.y, 0.0, 1.0)) * sunset_amount;
	
	float night_amount = clamp(-player_progress, 0.0, 1.0);
	vec3 gradient_night = mix(night_bottom_color, night_top_color, clamp(EYEDIR.y, 0.0, 1.0)) * night_amount;
	
	vec3 sky_gradients = gradient_day + gradient_sunset + gradient_night;
	
    
	float horizon = 1.0 - abs(EYEDIR.y + horizon_falloff);
	
	vec3 horizon_glow_amount_day = clamp(horizon * clamp(player_progress, 0.0, 1.0), 0.0, 1.0) * horizon_color_day;
	vec3 horizon_glow_amount_sunset = clamp(horizon * clamp(1.0 - abs(player_progress), 0.0, 1.0), 0.0, 1.0) * horizon_color_sunset;
	vec3 horizon_glow_night = clamp(horizon * clamp(-player_progress, 0.0, 1.0), 0.0, 1.0) * horizon_color_night;
	
	vec3 horizon_glow = horizon_glow_amount_day + horizon_glow_amount_sunset + horizon_glow_night;
	
    
    
    vec3 light_dir = normalize(vec3(0.0, player_progress, sqrt(1.0 - player_progress * player_progress)));
    
    float sun_distance = distance(EYEDIR.xyz, light_dir);
	float sun_power = 1.0 - clamp(sun_distance / sun_size, 0.0, 1.0);
	float sun_disc = clamp(sun_power / sun_blur, sun_power, 1.0);
	vec3 sun = sun_col * sun_disc;

    float moon_distance = distance(EYEDIR.xyz, -light_dir);
	float moon_power = 1.0 - clamp(moon_distance / moon_size, 0.0, 1.0);
	float moon_disc = clamp(moon_power / 0.01, moon_power, 1.0);
	
	vec3 moon = moon_col * moon_disc;
	
	
	vec3 stars = texture(stars_texture, sky_uv + (stars_speed * TIME)).rgb;
    stars = vec3(1.0) - stars;
    float star_visibility = smoothstep(0.0, 1.0, (1.0 - player_progress) * stars_visibility_factor);
    
    float star_horizon_falloff = smoothstep(-1,-0.5, EYEDIR.y);
    
	stars *= star_visibility * star_horizon_falloff;
    
	stars = step(stars_cutoff, stars);
	
	
	vec3 sun_moon = sun + moon;
	sun_moon = clamp(sun_moon, 0.0, 1.0);
	
	sky_gradients = clamp(sky_gradients, 0.0, 1.0);
	
    
	vec3 sky = horizon_glow + sky_gradients + sun_moon + stars;
	
	COLOR = sky;
}