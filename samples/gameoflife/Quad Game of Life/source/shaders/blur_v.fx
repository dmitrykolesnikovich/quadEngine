float4x4 VPM: register(c0);

struct appdata {
  float4 Position: POSITION;
  float4 Color: COLOR0;
  float2 UV: TEXCOORD0;
};

struct vertexOutput { 
  float4 Position: POSITION;
  float2 TexCoord: TEXCOORD0;
  float4 Color: COLOR0;
};

vertexOutput std_VS(appdata Input) {
  vertexOutput Output = (vertexOutput)0;
  Output.Position = mul(VPM, Input.Position);
  Output.TexCoord = Input.UV;
  Output.Color = Input.Color;
  return Output;
}

sampler2D DiffuseMap: register(s0);
float2 PixelSize: register(c1);

static const float2 Offsets[3] = 
  {
    float2(0.0f, 0.631579f),
    float2(0.0f, 2.307692f),
    float2(0.0f, 4.164557f)
  };

static const float Weights[3] = 
  {
    0.306152f,
    0.174561f,
    0.019287f
  };

float4 std_PS(vertexOutput Input) : COLOR {
  float4 blurSample;
  blurSample = 0.0f;
  blurSample += tex2D(DiffuseMap, Input.TexCoord + PixelSize * Offsets[2]) * Weights[2];
  blurSample += tex2D(DiffuseMap, Input.TexCoord + PixelSize * Offsets[1]) * Weights[1];
  blurSample += tex2D(DiffuseMap, Input.TexCoord + PixelSize * Offsets[0]) * Weights[0];
  blurSample += tex2D(DiffuseMap, Input.TexCoord - PixelSize * Offsets[0]) * Weights[0];
  blurSample += tex2D(DiffuseMap, Input.TexCoord - PixelSize * Offsets[1]) * Weights[1];
  blurSample += tex2D(DiffuseMap, Input.TexCoord - PixelSize * Offsets[2]) * Weights[2];
  return blurSample * Input.Color;
}


// Compiler directives
technique main
{
  pass Pass0
  {
    VertexShader = compile vs_2_0 std_VS();
    PixelShader = compile ps_2_0 std_PS();
  }
};
