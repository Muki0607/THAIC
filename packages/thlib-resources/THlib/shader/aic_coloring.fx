//======================================
//coloring - 油漆桶着色器
//templete by Xiliusha(ETC), code by Enko
// 代码移植 by Muki
// 鬼知道我一个从没学过hlsl的人是怎么把它搬过来的（不管怎么说抄就对了
// 比起上次来说至少这次有学过一点C，看起来舒服多了
//======================================

// 引擎设置的参数，不可修改

SamplerState screen_texture_sampler : register(s4); // RenderTarget 纹理的采样器
Texture2D screen_texture            : register(t4); // RenderTarget 纹理
cbuffer engine_data : register(b1)
{
    float4 screen_texture_size; // 纹理大小
    float4 viewport;            // 视口
};

// 用户传递的浮点参数
// 由多个 float4 组成，且 float4 是最小单元，最多可传递 8 个 float4

cbuffer user_data : register(b0)
{
    float4 user_data_0;
};

// 外部参数
// 各颜色分量 (0~255)
#define A user_data_0.x //Alpha
#define R user_data_0.y //Red
#define G user_data_0.z //Green
#define B user_data_0.w //Blue

// 主函数

struct PS_Input
{
    float4 sxy : SV_Position;
    float2 uv  : TEXCOORD0;
    float4 col : COLOR0;
};
struct PS_Output
{
    float4 col : SV_Target;
};

PS_Output main(PS_Input input)
{
	//获取像素的颜色向量
    float2 uv = input.uv;
	float4 texColor = screen_texture.Sample(screen_texture_sampler, uv);
	//获取原来的Alpha
	float a = texColor.a;
	//定义输出颜色
	float4 finalColor;
	if (A<0) //视为不改变透明度
	{
		finalColor = float4(R/255.0f, G/255.0f, B/255.0f, a);
	}
	else
	{
		float reA = a * A/255.0f;
		finalColor = float4(R/255.0f, G/255.0f, B/255.0f, reA);
	}
	
    PS_Output output;
    output.col = finalColor;
    return output;
}