float4x4 VPM    : register(c0);
float3 LightPos : register(c4);
float3 CamPos   : register(c5);

struct appdata {                
       float4 Color    : COLOR0;
       float4 Position : POSITION0;
       float2 UV       : TEXCOORD0;
       float3 Normal   : NORMAL0;
       float3 Tangent  : TANGENT0;
       float3 Binormal : BINORMAL0;
};

struct vertexOutput {           
       float4 Color    : COLOR0;
       float4 Position : POSITION0;
       float2 TexCoord : TEXCOORD0;
       float3 LightVec : TEXCOORD1;   
       float3 ViewVec  : TEXCOORD2;
};

vertexOutput std_VS(appdata Input) {
        vertexOutput Output = (vertexOutput)0;
//        float3 CamPos = (0.0, 0.0, 1.0);

        Input.Tangent.y = Input.Tangent.y;
        Input.Binormal.y = -Input.Binormal.y;
     //   float3 Light = float3(1.0, 1.0, 0.1);
        float3x3 RM;
        RM[0] = Input.Tangent;
        RM[1] = Input.Binormal;
        RM[2] = Input.Normal;

        Output.Position = mul(VPM, Input.Position);
        Output.TexCoord = Input.UV;
        Output.Color = Input.Color;

        Output.LightVec = mul(RM, normalize(mul(VPM, LightPos) - Output.Position));
        Output.ViewVec = mul(RM, normalize(mul(VPM, CamPos) - Output.Position));

        return Output;
}                                   

                            
float4 pos : register(c5);        
sampler2D DiffuseMap  : register(s0);   
sampler2D NormalMap   : register(s1);
sampler2D SpecularMap : register(s2);
sampler2D HeightMap   : register(s3);

float4 std_PS(vertexOutput Input) : COLOR {  
            
        float4 Output;   
                         
        float z = tex2D(HeightMap, Input.TexCoord).r;
        float3 n = tex2D(NormalMap, Input.TexCoord).rgb * 2.0 - 1.0;
        float k = max(1.0 - distance(Input.TexCoord, pos) * (2.0 / pos.a), 0.0);        
        float3 c = tex2D(DiffuseMap, Input.TexCoord).rgb * k;         
        float3 s = tex2D(SpecularMap,  Input.TexCoord).rgb;
        float3 pp = (float3(Input.TexCoord, 0.0) - pos.rgb) * z / pos.z;
        float3 l = normalize(Input.LightVec - pp); 
        float3 v = normalize(-pp);
        float3 h = normalize(l + v);
        float diff = dot(l, n);
        float3 spec = pow(max(0.2, dot(h, n)), 4.0) * k * s;
                                 
        Output = float4((diff * c) * Input.Color + spec, Input.Color.a);
        return Output;
}


technique main
{
    pass Pass0 
 {
        VertexShader = compile vs_2_0 std_VS();
        PixelShader = compile ps_2_0 std_PS();
 }
}
