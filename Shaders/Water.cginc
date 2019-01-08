#define GOLDEN_ANGLE_RADIAN 2.39996


float wave(float2 uv, float2 emitter, float speed, float phase, float time){
	float dst = distance(uv, emitter);
	return pow((0.5 + 0.5 * sin(dst * phase - time * speed)), 5.0);
}


float getwaves(float2 uv, float time){
	float w = 0.0;
	float sw = 0.0;
	float iter = 0.0;
	float ww = 1.0;
    uv += time * 0.5;
    
	// it seems its absolutely fastest way for water height function that looks real
	for(int i=0;i<6;i++){
		w += ww * wave(uv * 0.06 , float2(sin(iter), cos(iter)) * 10.0, 2.0 + iter * 0.08, 2.0 + iter * 3.0, time);
		sw += ww;
		ww = lerp(ww, 0.0115, 0.4);
		iter += GOLDEN_ANGLE_RADIAN;
	}
	
	return w / sw;
}

float getwavesHI(float2 uv, float time){
	float w = 0.0;
	float sw = 0.0;
	float iter = 0.0;
	float ww = 1.0;
    uv += time * 0.5;
	// it seems its absolutely fastest way for water height function that looks real
	for(int i=0;i<24;i++){
		w += ww * wave(uv * 0.06 , float2(sin(iter), cos(iter)) * 10.0, 2.0 + iter * 0.08, 2.0 + iter * 3.0, time);
		sw += ww;
		ww = lerp(ww, 0.0115, 0.4);
		iter += GOLDEN_ANGLE_RADIAN;
	}
	
	return w / sw;
}