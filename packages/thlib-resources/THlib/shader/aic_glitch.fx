// ----------------------------------------
// Glitch效果
// from 着色器从入门到放弃治疗.docx
// 代码移植 by Muki
// 鬼知道我一个从没学过hlsl的人是怎么把它搬过来的（不管怎么说抄就对了
// ----------------------------------------

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
	float4 user_data_1;
};

#define ranV user_data_0.x //外置随机变量
#define num user_data_1.x //最大位移量

// 方法

// 一个简单的一维伪随机数生成器
float Random1DTo1D(float value,float a,float b){
	float random = frac(sin(value+a)*b);
	return random;
}

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
	//获取像素的真实位置
	float2 uv = input.uv;
	float2 xy = uv * screen_texture_size.xy;
	if (xy.x < viewport.x || xy.x > viewport.z || xy.y < viewport.y || xy.y > viewport.w)
    {
        discard; // 抛弃不需要的像素，防止意外覆盖画面
    }
	
	//随机一个移动方向系数（-1或1，对应向左或向右）
	float sign = Random1DTo1D(uv[1]+ranV, 0.546f, 114514.810f)>0.5f ? 1.0f : -1.0f;

	//对横坐标部分加减
	xy[0] = xy[0] + Random1DTo1D(uv[1]+ranV, 0.546f, 114514.810f) * num * sign;
	
	//不要忘了把坐标重新变换到0~1里
	uv = xy / screen_texture_size.xy;
	
	//重新采样像素点并返回值
	float4 finalColor = screen_texture.Sample(screen_texture_sampler, uv);
	
	PS_Output output;
    output.col = finalColor;
    return output;
}