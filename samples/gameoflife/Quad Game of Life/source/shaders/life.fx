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

static const float2 Offsets[8] = 
  {
    float2(-1.0f, -1.0f),
    float2(-1.0f, 0.0f),
    float2(-1.0f, 1.0f),
    float2(0.0f, -1.0f),
    float2(0.0f, 1.0f),
    float2(1.0f, -1.0f),
    float2(1.0f, 0.0f),
    float2(1.0f, 1.0f)
  };
 
float4 std_PS(vertexOutput Input): COLOR {
  int count;
  count = 0;

  for (int i = 0; i < 8; ++i)
  {
    if (tex2D(DiffuseMap, Input.TexCoord + PixelSize * Offsets[i]).r > 0.5f)
    {
      ++count; 
    }
  }
  
  float4 result;
  result = float4(0.0f, 0.0f, 0.0f, 1.0f);
  if (tex2D(DiffuseMap, Input.TexCoord).r < 0.5f)
  {
    if (count == 3)
    {
      result = 1.0f;
    }
  }  
  else
  {  
    if ((count == 3) || (count == 2)) 
    {
      result = 1.0f;
    }
  }

  return result;
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
