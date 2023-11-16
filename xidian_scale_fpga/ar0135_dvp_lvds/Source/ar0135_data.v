`timescale      1ns/1ns

module  ar0135_data(
	//sys
	input			  s_rst_n		,
	//ov5640          
	input			  ar0135_pclk	,
	input			  ar0135_href	,
	input			  ar0135_vsync	,
	input	   [7:0]  ar0135_data	,
	//user            
	output reg [15:0] m_data		,	
	output reg        m_wr_en		 	
);


wire    		ar0135_vsync_pos   ;   //  
reg     		ar0135_vsync_r1    ;   //
		
reg				byte_flag	  ;	//表示接收到的数据那个为高 0:高第一个字节  1：低第二个字节
reg    [ 3:0]   frame_cnt  	  ;	//丢弃前十帧计数器
wire            frame_vaild	  ;


always  @(posedge ar0135_pclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
			m_data	<=	'h0	;
		else if(byte_flag == 1'b1)
			m_data	<=	{m_data[15:8] , ar0135_data};
		else
			m_data	<=	{ar0135_data , m_data[7:0]};
			
end

always  @(posedge ar0135_pclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
			byte_flag	<=	1'b0	;
		else if(ar0135_href == 1'b1)
			byte_flag	<=	~byte_flag	;
		else
			byte_flag	<=	1'b0	;
end

always  @(posedge ar0135_pclk) begin
        ar0135_vsync_r1	<=	ar0135_vsync;
end

always  @(posedge ar0135_pclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
            frame_cnt	<=	'd0	;
        else if(frame_vaild == 1'b0 && ar0135_vsync_pos == 1'b1)
            frame_cnt	<=	frame_cnt + 1'b1	;
end

always  @(posedge ar0135_pclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
            m_wr_en <=	1'b0	;
        else if(frame_vaild == 1'b1 && byte_flag == 1'b1)
            m_wr_en <=	1'b1	;
        else
            m_wr_en <=	1'b0	;
end

assign  frame_vaild             =       (frame_cnt >= 'd10) ? 1'b1 : 1'b0;
assign  ar0135_vsync_pos        =       ar0135_vsync & ~ar0135_vsync_r1;

endmodule