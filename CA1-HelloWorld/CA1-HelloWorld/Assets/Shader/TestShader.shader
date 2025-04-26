Shader "Custom/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowSmooth ("Shadow Smooth", Range(0.0,1.0)) = 0.1
        _ShadowRange ("Shadow Range", Range(0.0,1.0)) = 0.1
        _ShadowColor ("Shadow color", Color) = (.25, .25, .25, 1)
        _BaseColor ("Base color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Back

        Pass
        {
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
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float4 viewPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _ShadowSmooth;
            float _ShadowRange;

            float4 _BaseColor;
            float4 _ShadowColor;

            v2f vert (appdata v)
            {
                v2f o; 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewPos = mul(UNITY_MATRIX_MV,v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texCol = tex2D(_MainTex, i.uv);
                float3 worldLight = _WorldSpaceLightPos0.xyz;
                float3 normal = i.normal;

                // Ramp
                float NdotL = dot(worldLight,normal);
                float halfLambert = NdotL * 0.5 + 0.5;
                float ramp = smoothstep(0.0,_ShadowSmooth,halfLambert-_ShadowRange);
                float4 color = lerp(_ShadowColor,_BaseColor,ramp);

                // Rim
                float f = saturate(dot(-normalize(i.viewPos.xyz),i.normal));
                float rimBloom = pow(f,5.0) * max(0.0,NdotL) * 15.0;
                float rimPower = f * rimBloom;
                
                color *= texCol;
                return fixed4(1,1,1,1)*f;
            }
            ENDCG
        }
    }
}
