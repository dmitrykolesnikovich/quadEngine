// Basic HLSL shader
// Author : autogenegated with quadshade
// Date : 11.09.2012
//

// Vertex shader code
struct appdata {
  float4 Position : POSITION;
  float2 UV : TEXCOORD0;
};

struct vertexOutput {
  float4	Position : POSITION;
  float2	TexCoord : TEXCOORD0;
};

vertexOutput std_VS(appdata Input){
  vertexOutput Output = (vertexOutput)0;

  return Output;
}

// Pixel shader code
sampler2D DiffuseMap : register(s0);

float4 std_PS(vertexOutput Input) : COLOR {
  float4 Output;

  float4 tex_diff = tex2D(DiffuseMap, Input.TexCoord);
  Output = tex_diff;

  return Output;
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