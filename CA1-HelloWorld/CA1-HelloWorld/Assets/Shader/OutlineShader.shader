Shader "Custom/Outline"
{
    Properties
    {
        _OutlineOffset ("Outline Offset",Range(0.000, 0.01)) = 0.001
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Front

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float _OutlineOffset;
            
            v2f vert (appdata v)
            {
                v2f o;
                float4 vtx;
                vtx = UnityObjectToClipPos(v.vertex);

                float3 viewNormal = normalize (mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                float3 clipNormal = TransformViewToProjection(viewNormal).xyz;
                o.vertex = vtx;
                o.vertex.xy +=  clipNormal * _OutlineOffset;
                
                o.uv = float2(1.0,1.0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed4(0.0,0.0,0.0,0.0);
                return col;
            }
            ENDCG
        }
    }
}
