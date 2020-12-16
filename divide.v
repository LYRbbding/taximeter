//divide.v  时钟分频模块
module divide #
(
  parameter	WIDTH	=	32,         //计数器的位数，计数的最大值为 2**(WIDTH-1)
  parameter	N		=	50_000_000    //分频系数，确保 N<2**(WIDTH-1)，否则计数会溢出
)
(
  input   clk,                  //clk分频输入信号
  input   rst_n,                //复位信号，高电平有效
  output  clkout                //输出信号，分频后的输出
);

  //cnt_p为上升沿触发时的计数器，cnt_n为下降沿触发时的计数器
  reg	[WIDTH-1:0]	cnt_p,cnt_n;
  //clk_p为上升沿触发时分频时钟，clk_n为下降沿触发时分频时钟
  reg	clk_p,clk_n;
  
  /*****************上升沿触发部分*****************/
  //上升沿触发时计数器的控制
  always @(posedge clk or posedge rst_n) begin
      if(rst_n)                   cnt_p <= 1'b0;
      else if(cnt_p == (N-1))     cnt_p <= 1'b0;
      else                        cnt_p <= cnt_p + 1'b1;
      //计数器一直计数，当计数到N-1的时候清零，这是一个模N的计数器
  end
  
  //上升沿触发的分频时钟输出
  //如果N为奇数得到的时钟占空比不是50%
  //如果N为偶数得到的时钟占空比为50%
  always @(posedge clk or posedge rst_n) begin
      if(rst_n)                   clk_p <= 1'b0;
      else if(cnt_p < (N>>1))     clk_p <= 1'b0;
      else                        clk_p <= 1'b1;
      //得到的分频时钟正周期比负周期多一个clk时钟
  end
  
  /*****************下降沿触发部分*****************/
  //下降沿触发时计数器的控制
  always @(negedge clk or posedge rst_n) begin
      if(rst_n)                   cnt_n <= 1'b0;
      else if(cnt_n == (N-1))     cnt_n <= 1'b0;
      else                        cnt_n <= cnt_n + 1'b1;
  end

  //下降沿触发的分频时钟输出，和clk_p相差半个clk时钟
  always @(negedge clk or posedge rst_n) begin
      if(rst_n)                   clk_n <= 1'b0;
      else if(cnt_n < (N>>1))     clk_n <= 1'b0;
      else                        clk_n <= 1'b1;
      //得到的分频时钟正周期比负周期多一个clk时钟
  end
  
  /*************************************************************************/
  wire clk1 = clk;            //当N=1时，直接输出clk
  wire clk2 = clk_p;          //当N为偶数也就是N的最低位为0，N[0]=0，输出clk_p
  wire clk3 = clk_p & clk_n;
  //当N为奇数也就是N最低位为1，N[0]=1，输出clk_p&clk_n。正周期多所以是相与

  assign clkout = (N==1)? clk1:(N[0]? clk3:clk2);	//条件判断表达式
  
endmodule
