
struct VSInput
{
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};

struct PSInput
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};

Texture2D g_texture : register(t0);
SamplerState g_sampler : register(s0);

cbuffer Params : register(b0)
{
    float angle;
    float aspect;
    float2 center;

    float time;
    float pulse;
    float scroll;
    float pad;
};

PSInput VSMain(VSInput input)
{
    PSInput result;

    float s, c;
    sincos(angle, s, c);

    // Пульсация
    float scale = 1.0f + pulse * sin(time * 4.0f);

    // Вершины построены вокруг (0,0), в C++ Y уже умножен на aspect.
    // Возвращаем Y в «равное» пространство, масштабируем, вращаем.
    float2 p = float2(input.position.x, input.position.y / max(aspect, 0.0001f)) * scale;

    float2 rotated;
    rotated.x = p.x * c - p.y * s;
    rotated.y = p.x * s + p.y * c;

    // Сначала сдвиг на центр, потом коррекция пропорций
    result.position = float4(rotated.x + center.x,
                             (rotated.y + center.y) * aspect,
                             input.position.z,
                             1.0f);

    result.uv = input.uv;
    result.color = input.color;
    return result;
}
float4 PSMain(PSInput input) : SV_TARGET
{
    float2 uv = input.uv + float2(time * scroll, 0.0f);

    return g_texture.Sample(g_sampler, uv) * input.color;
}
