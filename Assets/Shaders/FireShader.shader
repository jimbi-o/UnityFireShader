Shader "Custom/FireShader"
{
  Properties
  {
    _StepSize("Step Size", Float) = 0.01
    _Density("Density", Float) = 0.1
    _Color("Color", Color) = (1, 1, 1, 1)
  }
  SubShader
  {
    Tags { "RenderType"="Transparent" }
    Tags { "Queue" = "Transparent" }
    Blend SrcAlpha OneMinusSrcAlpha
    LOD 100

    Pass
    {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f
      {
        float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
      };

      float _StepSize;
      float _Density;
      fixed4 _Color;
      float3 _BoxMin;
      float3 _BoxMax;

      v2f vert (appdata v)
      {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        return o;
      }

      fixed4 frag (v2f i) : SV_Target
      {
        float4 col = _Color;
        float3 rayDir = normalize(i.worldPos - _WorldSpaceCameraPos);
        float3 rayPos = i.worldPos;

        // AABB intersection test
        float3 tMin = (_BoxMin - rayPos) / rayDir;
        float3 tMax = (_BoxMax - rayPos) / rayDir;
        float3 t1 = min(tMin, tMax);
        float3 t2 = max(tMin, tMax);
        float tNear = max(max(t1.x, t1.y), t1.z);
        float tFar = min(min(t2.x, t2.y), t2.z);


        if (tNear > tFar || tFar < 0.0)
          discard;

        rayPos += rayDir * tNear;

        float totalDistance = 0.0f;
        float alpha = 0.0;

        for (int iter = 0; iter < 100; iter++)
        {
          totalDistance += _StepSize;
          if (totalDistance >= tFar - tNear)
            break;

          alpha += _Density;
          if (alpha >= 0.99)
            break;

          rayPos += rayDir * _StepSize;
        }

        col.a = alpha;
        return col;
      }
    ENDCG
    }
  }
}
