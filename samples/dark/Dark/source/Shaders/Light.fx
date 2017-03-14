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
  float4 Position : POSITION;        
  float2 TexCoord : TEXCOORD0;
  float4 TexColor : COLOR0;
};

vertexOutput std_VS(appdata Input){
  vertexOutput Output = (vertexOutput)0;

  return Output;
}

// Pixel shader code
sampler2D DiffuseMap : register(s0);   
sampler2D LightMap   : register(s1);   
float3 Params        : register(c0);
//float3 Color         : register(c1);
          
float4 std_PS(vertexOutput Input) : COLOR {
  float4 Output;
                    
  float4 LightColor = tex2D(LightMap, Input.TexCoord);                          
  float2 vec = (Input.TexCoord.xy - Params.xy) / 24.0;   
              
  float2 pos = Input.TexCoord;
  float sum = 0.0;   
  float4 tex;
  for (int i = 0; i < 24; i++)
  {    
    pos -= vec;
    tex = tex2D(DiffuseMap, pos);
    sum += tex.r; 
  }                                                     
  float4 tmpColor = Input.TexColor;                         
  Output = LightColor * floor(sum / 24.0); 
  //Output.rgb *= Color.rgb;
  Output.rgb *= Input.TexColor.rgb;

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
