Shader "Custom/FireShader"
{
  Properties
  {
    _StepSize("Step Size", Float) = 0.01
    [Range(0,100)] _TemperatureScale("Temperature Scale", Float) = 40
    _DensityThreshold("Density Threshold", Float) = 20
    _NoiseTex("Texture", 3D) = "white" {}
  }
  SubShader
  {
    Tags { "RenderType"="Transparent" }
    Tags { "Queue" = "Transparent" }
    Blend One One
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
      float _TemperatureScale;
      float _DensityThreshold;
      float3 _BoxMin;
      float3 _BoxMax;
      sampler3D _NoiseTex;
      float4x4 _NoiseTexCoordMat;
      static const float _TemperatureMin = 450 * 0.01;
      static const float _TemperatureMax = 8000 * 0.01;
      static const float _TemperatureCount = 64;
      static const float3 _BlackbodyRadiationApproximatedLinearRGB[64] = {
        float3(4.25731075e-14f, -4.21404619e-15f, -3.37014258e-16f),
        float3(9.30209132e-10f, -7.5858666e-11f, -9.3580641e-12f),
        float3(7.49663122e-07f, -4.47255202e-08f, -9.50901138e-09f),
        float3(8.98079322e-05f, -3.11549356e-06f, -1.39219301e-06f),
        float3(0.00324919591f, -2.47546478e-05f, -5.91425203e-05f),
        float3(0.0528159707f, 0.00110197276f, -0.00108040283f),
        float3(0.490058102f, 0.0246284168f, -0.0107490692f),
        float3(3.0237439f, 0.242449751f, -0.0675275747f),
        float3(13.7385352f, 1.51616078f, -0.293851355f),
        float3(49.331405f, 6.93440205f, -0.932116419f),
        float3(147.242036f, 25.1257866f, -2.16418426f),
        float3(379.106853f, 75.9933993f, -3.29771703f),
        float3(865.743889f, 199.034866f, -0.730917513f),
        float3(1791.23283f, 463.759493f, 15.900579f),
        float3(3413.7688f, 981.147302f, 69.789809f),
        float3(6071.65869f, 1914.79683f, 205.273799f),
        float3(10183.7645f, 3490.42728f, 498.027483f),
        float3(16244.5817f, 6002.67332f, 1066.42267f),
        float3(24814.7942f, 9818.52293f, 2083.1328f),
        float3(36508.5191f, 15377.1882f, 3786.01848f),
        float3(51978.5601f, 23186.582f, 6487.42334f),
        float3(71900.9134f, 33816.8567f, 10581.2034f),
        float3(96959.5655f, 47891.6347f, 16547.0549f),
        float3(127832.379f, 66077.628f, 24951.9555f),
        float3(165178.604f, 89073.3368f, 36448.7556f),
        float3(209628.325f, 117597.451f, 51772.1396f),
        float3(261773.97f, 152377.48f, 71732.302f),
        float3(322163.845f, 194139.02f, 97206.7651f),
        float3(391297.588f, 243595.966f, 129130.798f),
        float3(469623.331f, 301441.867f, 168486.892f),
        float3(557536.366f, 368342.517f, 216293.726f),
        float3(655379.056f, 444929.835f, 273594.997f),
        float3(763441.777f, 531797.003f, 341448.454f),
        float3(881964.662f, 629494.791f, 420915.386f),
        float3(1011139.95f, 738528.988f, 513050.786f),
        float3(1151114.75f, 859358.815f, 618894.328f),
        float3(1301994.16f, 992396.204f, 739462.263f),
        float3(1463844.46f, 1138005.83f, 875740.292f),
        float3(1636696.4f, 1296505.78f, 1028677.43f),
        float3(1820548.55f, 1468168.67f, 1199180.84f),
        float3(2015370.45f, 1653223.29f, 1388111.64f),
        float3(2221105.74f, 1851856.45f, 1596281.58f),
        float3(2437675.09f, 2064215.17f, 1824450.59f),
        float3(2664978.98f, 2290408.88f, 2073325.03f),
        float3(2902900.27f, 2530511.93f, 2343556.71f),
        float3(3151306.6f, 2784565.97f, 2635742.43f),
        float3(3410052.61f, 3052582.41f, 2950424.15f),
        float3(3678981.9f, 3334544.9f, 3288089.58f),
        float3(3957928.91f, 3630411.66f, 3649173.1f),
        float3(4246720.54f, 3940117.78f, 4034057.18f),
        float3(4545177.64f, 4263577.48f, 4443073.89f),
        float3(4853116.37f, 4600686.16f, 4876506.71f),
        float3(5170349.32f, 4951322.43f, 5334592.56f),
        float3(5496686.67f, 5315349.96f, 5817523.84f),
        float3(5831936.99f, 5692619.28f, 6325450.66f),
        float3(6175908.2f, 6082969.35f, 6858483.06f),
        float3(6528408.16f, 6486229.17f, 7416693.29f),
        float3(6889245.41f, 6902219.11f, 8000118.09f),
        float3(7258229.61f, 7330752.27f, 8608760.95f),
        float3(7635172.1f, 7771635.61f, 9242594.31f),
        float3(8019886.24f, 8224671.09f, 9901561.75f),
        float3(8412187.78f, 8689656.64f, 10585580.1f),
        float3(8811895.14f, 9166387.07f, 11294541.4f),
        float3(9218829.65f, 9654654.87f, 12028315.1f),
      };

      float3 GetApproximateRadianceFromTemperature(float temperature)
      {
        float index = ((temperature - _TemperatureMin) / (_TemperatureMax - _TemperatureMin)) * _TemperatureCount;
        if (index <= 0.0f) {
          return _BlackbodyRadiationApproximatedLinearRGB[0];
        }
        if (index >= _TemperatureCount - 1) {
          return _BlackbodyRadiationApproximatedLinearRGB[63];
        }
        int index_i = int(index);
        return lerp(_BlackbodyRadiationApproximatedLinearRGB[index_i], _BlackbodyRadiationApproximatedLinearRGB[index_i+1], index - index_i);
      }

      v2f vert (appdata v)
      {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        return o;
      }

      fixed4 frag (v2f i) : SV_Target
      {
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

        float3 accumulated_color = float3(0,0,0);
        float totalDistance = 0.0f;
        float density = 0.0;

        for (int iter = 0; iter < 64; iter++)
        {
          totalDistance += _StepSize;
          if (totalDistance >= tFar - tNear)
            break;

          float3 uvw_coord = mul(_NoiseTexCoordMat, float4(rayPos,1));
          fixed4 noise = tex3D(_NoiseTex, uvw_coord);
          float3 color = GetApproximateRadianceFromTemperature(noise.x * _TemperatureScale);
          density += noise.y;
          accumulated_color += color * noise.y;
          if (density >= _DensityThreshold)
            break;

          rayPos += rayDir * _StepSize;
        }

        return float4(accumulated_color, 0.0f);
      }
    ENDCG
    }
  }
}
