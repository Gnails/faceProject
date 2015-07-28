struct VSIn{
	float3 pos:POSITION;
	float2 tex:TEXCOORD;
};

struct PSIn{
	float4 pos:SV_POSITION;
	float2 tex:TEXCOORD;
};

cbuffer cbWorld{
	matrix g_mWorld;
	matrix g_mWorldViewProj;
};

cbuffer cbUser{
	float4 g_vEyePos;
	float4 g_vLightDir1;
	float4 g_vLightDir2;
	float4 g_vLightColor=float4(1.0,1.0,1.0,0.0);
};

texture2D g_txDiffuse;

sampler diffuseSamp = sampler_state{
	Texture = <g_txDiffuse>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

PSIn VSmain(VSIn input){
	PSIn output;
	output.pos=mul(float4(input.pos,1),g_mWorldViewProj);
	output.tex=input.tex;
	return output;
}

float4 PSmain(PSIn input): SV_Target{
	float4 output;
	output=tex2D(diffuseSamp,input.tex);
	//output=float4(255,255,255,255);
	return output;
}

technique T0{
	pass P0
	{
		ZENABLE = true;
		VertexShader = compile vs_2_0 VSmain();
		PixelShader  = compile ps_2_0 PSmain();
		Lighting = false;
	}
}