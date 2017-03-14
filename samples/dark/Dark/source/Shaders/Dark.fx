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
};

vertexOutput std_VS(appdata Input){
  vertexOutput Output = (vertexOutput)0;

  return Output;
}

// Pixel shader code             
sampler2D MMap : register(s0);    
sampler2D DMap : register(s1);      
sampler2D TMap : register(s2);  
float2 Coord  : register(c0); 
 
float4 std_PS(vertexOutput Input) : COLOR {
  float4 Output;
              
  float2 Pos = Input.TexCoord;
                                              
  float4 Diff = tex2D(DMap, Input.TexCoord * 10.0 + Coord);  
  Pos.y += Diff.r * 0.025 - 0.025;  
  float4 Mask = tex2D(MMap, Pos);
  float4 Text = tex2D(TMap, Pos * 10.0 + Coord); 
                                   
  Output = Text;
  Output.a = Mask.a; 
                                        
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
