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
float Highpass: register(c1);

float4 std_PS(vertexOutput Input) : COLOR {
  float4 output;
  output = tex2D( DiffuseMap, Input.TexCoord );
  float4 color;
  color = output - Highpass;
  color = clamp(color, 0.0f, 1.0f);
  if ((color.r + color.g + color.b) > 0.0f)
  {
    return output;
  }
  else
  {
    return float4(0.0f, 0.0f, 0.0f, 1.0f);
  }
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
