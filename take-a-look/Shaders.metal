#include <metal_stdlib>
using namespace metal;

// ---- Vertex Output 구조체 ---- //
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// ---- Fullscreen Quad Vertex Shader ---- //
vertex VertexOut vertexShader(uint vertexID [[ vertex_id ]]) {
    float2 pos[4] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2( 1.0,  1.0)
    };

    float2 uv[4] = {
        float2(0.0, 1.0),
        float2(1.0, 1.0),
        float2(0.0, 0.0),
        float2(1.0, 0.0)
    };

    VertexOut out;
    out.position = float4(pos[vertexID], 0.0, 1.0);
    out.texCoord = uv[vertexID];
    return out;
}

fragment float4 warpFragmentShader(VertexOut in [[stage_in]],
                                   texture2d<float> inputTexture [[ texture(0) ]],
                                   constant float *uniforms [[ buffer(0) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float2 uv = in.texCoord;

    float rotation = uniforms[0];
    float time = uniforms[1];

    // distortion strength increases over time
    float strength = min(time * 0.3, 1.0); // 0~1 based on time
    float warpAmount = sin(uv.y * 40.0 + rotation * 0.2) * 0.03 * (rotation / 45.0);
    warpAmount *= strength * 1.5; // strength based on time

    // blur effect: random horizontal shake
    float noise = sin((uv.y + rotation * 0.1) * 100.0) * 0.002 * strength;
    uv.x += warpAmount + noise;

    return inputTexture.sample(s, uv);
}
