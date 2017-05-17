`include "Control-Logic.v"
`include "Counting Element.v"
module testb(control_word,clk,GATE,OUT,myAddress,selectedAddress,statusByte);
	
	input [7:0] control_word;
	//// input [15:0] current_count;
	input clk,GATE;
	input [1:0] myAddress,selectedAddress;
	output [7:0] statusByte;
	output OUT;
	wire[15:0] initial_count, current_count;
	wire count_enable,load_new_count,BCD,RW;
	
	ControlLogic cl(control_word,initial_count,current_count,
	clk,GATE,OUT,null_count,
	CRM_enable,CRL_enable,OLM_enable,OLL_enable,status_register_enable,status_latch_enable,count_enable,load_new_count,myAddress,selectedAddress,statusByte,0,1,0);
	CountingElement ce(initial_count,current_count,clk,count_enable,load_new_count,BCD,RW);
endmodule