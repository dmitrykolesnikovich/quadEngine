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

float4 std_PS(vertexOutput Input) : COLOR {
  float2 dist;
  dist = Input.TexCoord - 0.5f;
  dist = abs(dist) * dist * 4.0f * PixelSize;

  float4 output;
  output = tex2D(DiffuseMap, Input.TexCoord);
  float4 color_1;
  float4 color_2;
  float4 color_3;
  float4 color_4;
  color_1 = tex2D(DiffuseMap, Input.TexCoord + dist);
  color_2 = tex2D(DiffuseMap, Input.TexCoord - dist);
  color_3 = tex2D(DiffuseMap, Input.TexCoord + 2.24731f * dist);
  color_4 = tex2D(DiffuseMap, Input.TexCoord - 2.24731f * dist);
  output.r = output.r * 0.5f + color_1.r * 0.3f + color_3.r * 0.2f;
  output.b = output.b * 0.5f + color_2.b * 0.3f + color_4.b * 0.2f;
  return output * Input.Color;
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
