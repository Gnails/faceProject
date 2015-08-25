struct VSIn{
	float3 pos:POSITION;
	float3 norm:NORMAL;
	float2 tex:TEXCOORD;
};

struct PSIn{
	float4 pos:SV_POSITION;
	float3 norm:NORMAL;
	float2 tex:TEXCOORD1;
	float3 vPos:TEXCOORD2;
};

cbuffer cbWorld{
	matrix g_mWorld;
	matrix g_mWorldViewProj;
};

cbuffer cbUser{
	float4 g_vEyePos;
	float4 g_vLightDir1;
	float4 g_vLightDir2;
	float4 g_vLightColor={1.0,1.0,1.0,0.0};
	float4 g_vDiffuseColor={0.7,0.7,0.7,1.0};
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
	output.vPos=mul(float4(input.pos,1),g_mWorld);
	output.norm = normalize(mul(input.norm,(float3x3)g_mWorld));
	output.tex=input.tex;
	return output;
}

float4 PSmain(PSIn input): SV_Target{
	float4 diffuse=tex2D(diffuseSamp,input.tex)*g_vDiffuseColor;
	float4 lighting=saturate(dot(input.norm,normalize(g_vLightDir1)))*diffuse;

	float3 eyeObj=normalize(g_vEyePos.xyz-input.vPos);
	float3 halfAngle=normalize(eyeObj+g_vLightDir1);
	float4 spec=pow(saturate(dot(halfAngle,input.norm )),32)*g_vLightColor*0.2;
	
	return lighting + spec;
}

technique T0{
	pass P0
	{
		ZENABLE = true;
		VertexShader = compile vs_3_0 VSmain();
		PixelShader  = compile ps_3_0 PSmain();
		Lighting = false;
	}
}