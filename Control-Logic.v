
module ControlLogic(control_word,initial_count,current_count,
clk,GATE,OUT,null_count,
CRM_enable,CRL_enable,OLM_enable,OLL_enable,status_register_enable,status_latch_enable,count_enable,load_new_count,myAddress,selectedAddress,statusByte,WR,RD,CS,enableTwo);

	input [7:0] control_word;
	input [15:0] initial_count;
	input [15:0] current_count;
	input clk,GATE;
	output OUT,null_count;
	input CRM_enable,CRL_enable,OLM_enable,OLL_enable,status_register_enable,status_latch_enable;
	output count_enable;
	output load_new_count ;
	reg OUT;
	reg strobe;
	reg is_loaded;
	reg prev_gate;
	reg load_new_count ;
	input WR,RD,CS;
	
	
	//joe zyadat
	input [1:0] myAddress,selectedAddress;
	output enableTwo;
	reg count_enable;
	output [7:0] statusByte;
	reg [7:0] statusByte;
	wire [2:0] mode;
	reg enableTwo;
	assign mode=statusByte[3:1];
	reg outFlag,startLoading,mode2Init;
	wire [1:0] readType; //01 lsb 10 msb 11 lsb then msb 
	assign readType=statusByte[5:4];
	always@(posedge clk)
	begin 
		if(myAddress==control_word[7:6]) begin 
			statusByte[5:0]=control_word[5:0];
		end
		statusByte[7]=OUT;
		//statusByte[6] hatb2a el null_count
	end
	
	//mode 0 start
	
	always@(posedge clk)
	begin 
		if(mode!=3) begin 
			enableTwo=0;
		end 
	end 
	
	
	always@(GATE or clk)
	begin 
		if(mode==0) begin 
			count_enable<=GATE;
		end
	end 
	always@(posedge clk)
	begin 
		load_new_count=0;
		if(startLoading && mode==0) begin  //new count is loading while mode is zero -> set out to zero.
			OUT=0;
			startLoading=0;
			load_new_count=1;
	
		end
		else begin
			if(control_word[3:1]==0 && RD==1 && WR==0 && CS==0 && control_word[7:6]==myAddress) begin //new mode zero control word loaded -> set out to zero.
					OUT=0;
			end 
			
			else begin 
				if(current_count<=1 && mode==0) begin 
					OUT=1;
				end
			end 
		
		end
		
	end
	
	//mode 0 end.
	
	
	
	//mode 1 start
	always@(posedge GATE)
	begin 
		if(mode==1) begin 
			load_new_count=1;
			outFlag=1;
			count_enable=1;
		end 
	
	end
	
	always@(posedge clk)
	begin
		if(mode==1) begin
			load_new_count=0;
			if(current_count==1) begin 
				OUT=1;
			end 
			if(outFlag) begin 
				OUT=0;
				outFlag=0;
			end
		end
		
	end
	
	//mode 1 end
	
	//mode 4 start
	
	always@(GATE or clk)
	begin 
		if(mode==4) begin 
			count_enable<=GATE;
		end
	end 
	
	always@(posedge clk)
	begin 
		if(mode==4) begin 
			load_new_count=0;
			OUT=1;
			if(startLoading) begin  //new count is loading while mode is zero -> set out to zero.
				startLoading=0;
				load_new_count=1;
			end
			if(current_count==1) begin 
					OUT=0;
			end
				
		end 
	end 
	//mode 4 end
	
	//mode 2 start
	
	
	always@(negedge GATE)
	begin
		if(mode==2) begin 
			OUT=1;
			count_enable=0;
		end
	end
	
	always@(posedge GATE)
	begin 
		if(mode==2) begin 
			load_new_count=1;
			count_enable=1;
		end
	end
	
	always@(posedge clk)
	begin
		
		if(control_word[3:1]==2 && RD==1 && WR==0 && CS==0 && control_word[7:6]==myAddress) begin 
			mode2Init=1;
		end
	
		if(mode==2) begin
			OUT=1;
			if(startLoading && mode2Init) begin //initalizing count
				mode2Init=0;
				load_new_count=1;
			end
			if(current_count==2) begin 
				load_new_count=1;
				OUT=0;
			
			end
		
		
		end
		
	
	end
	
	//mode 2 end
	
	//joe zyadat
	
	
	
	
	
	//hagt megz
	reg init_done;
	reg strobe_effect;
	reg check_state;
	reg [4:0]tester;
	reg mode_5_zero_flag;
	reg mode_3_zero_flag;
	reg mode_3_odd_flag;
	reg mode_3_high_flag;
	reg mode_3_low_flag;
	reg  mode_3_init_done;
	reg [15:0] mode_3_init_temp;
	
	
	initial
	begin
	strobe<=0;
	is_loaded<=0;
	OUT<=1;
	init_done<=0;
	load_new_count<=0;
	mode_5_zero_flag<=0;
	mode_3_init_done<=0;
	if (control_word[1:0]==2'b11) //mode 3
	begin
	if (initial_count[0]==1'b1)
	begin
	//mode_3_init_temp<=initial_count-1;
	
	mode_3_odd_flag<=1;
	end
	else if (initial_count[0]==1'b0)
	begin
	mode_3_init_temp<=initial_count;
	mode_3_odd_flag<=0;
	end
	end
	end
	
	always@(negedge GATE)
	begin
		if(mode==3) begin 
			OUT=1;
			count_enable=0;
		end
	end
	
	always@(posedge GATE)
	begin 
		if(mode==3) begin 
			load_new_count=1;
			count_enable=1;
		end
	end
	
	
	
	always@(posedge clk) /////////////////////////////// mode 3 -not sure at all about it -
 if (mode==3)
 begin
	enableTwo=1;
   if ({GATE,mode_3_zero_flag}==2'b11|| ((mode_3_high_flag==1'b1||mode_3_low_flag==1'b1)&&mode_3_init_done==1'b0))
  begin
 // OUT<=1;
  mode_3_zero_flag<=0;
  load_new_count<=1;
  mode_3_init_done<=1;
  if (initial_count[0]==1'b1)
  begin
  //current_count<=initial_count-1;
  end
  else if(initial_count[0]==1'b0)
  begin
  //current_count<=initial_count; //to be removed
  end
  if ({GATE,mode_3_zero_flag}==2'b11)
  begin
  mode_3_high_flag<=1;
  mode_3_low_flag<=0;
  end
  end
  
  
  if (initial_count[0]==1'b1)
  begin
  if (mode_3_init_done==1'b1)
  begin
  load_new_count<=0;
    count_enable<=1;
  if (mode_3_high_flag==1'b1)
  begin
  if (current_count>2)
  begin
  //current_count<=current_count-2; //to be removed
  OUT<=1;
  end
  else if (current_count==2)
  begin
 // OUT<=0;
  //current_count<=current_count-2; //to be removed
  mode_3_low_flag<=1;
   mode_3_high_flag<=0;
  mode_3_init_done<=0;
  end
  end
  
 else if (mode_3_low_flag==1'b1)
  begin
  if (current_count>4)
  begin
  //current_count<=current_count-2; //to be removed
  OUT<=0;
  end
  else if (current_count==4)
  begin
 // OUT<=1;
  //current_count<=current_count-2; //to be removed
  mode_3_high_flag<=1;
  mode_3_low_flag<=0;
  mode_3_init_done<=0;
  end
  end
  
  end
  
  end
  


  
  else if(initial_count[0]==1'b0)
  begin
   if (mode_3_init_done==1'b1)
  begin
  load_new_count<=0;
    count_enable<=1;
  if (mode_3_high_flag==1'b1)
  begin
  if (current_count>4)
  begin
  //current_count<=current_count-2; //to be removed
  OUT<=1;
  end
  else if (current_count==4)
  begin
 // OUT<=0;
  //current_count<=current_count-2; //to be removed
  mode_3_low_flag<=1;
   mode_3_high_flag<=0;
  mode_3_init_done<=0;
  end
  end
  
 else if (mode_3_low_flag==1'b1)
  begin
  if (current_count>4)
  begin
  //current_count<=current_count-2; //to be removed
  OUT<=0;
  end
  else if (current_count==4)
  begin
 // OUT<=1;
  //current_count<=current_count-2; //to be removed
  mode_3_high_flag<=1;
  mode_3_low_flag<=0;
  mode_3_init_done<=0;
  end
  end
  
  end
  end
  
  
  if (GATE==1'b0)
  begin
  mode_3_zero_flag<=1;
  count_enable<=0;
  //current_count<=current_count;
  end
  end
  
  
  //mode 5
  always @(posedge GATE)
  begin
	if(mode==5) begin 
		load_new_count=1;
		init_done=1;
	end
  end
  
  
  
  always @(posedge clk) 
begin
if (mode==3'b101)
begin
count_enable<=1;
if ({GATE,mode_5_zero_flag}==2'b11)
begin
//current_count<=initial_count;
mode_5_zero_flag<=0;
end
else if ({load_new_count,is_loaded,strobe,init_done}==4'b0000||GATE==1'b0)
begin
OUT<=1;
init_done<=0;
end
/*else if ({load_new_count,is_loaded,strobe,init_done}==4'b1000)
begin
current_count<=initial_count; //to be removed after getting it from counting element
OUT<=1;
load_new_count<=1'b0;
init_done<=1;
end*/
else if ({load_new_count,is_loaded,strobe,init_done}==4'b0001 ||{load_new_count,is_loaded,strobe,init_done}==4'b1001)
begin
if (GATE==1'b1)
mode_5_zero_flag<=0;
load_new_count<=1'b0;
begin
if (current_count>1)
begin
//current_count<=current_count-1; // //to be removed after getting it from counting element
OUT<=1;
end
else if (current_count==1)
begin
//current_count<=current_count-1;
OUT<=0;
//strobe<=1; 
init_done<=0;
//set counter to FFFF incase of binary or 9999 incase of BCD
end
end
end
/*else if ({load_new_count,is_loaded,strobe,init_done}==4'b0010)
begin
OUT<=0;
//strobe <=1'b0;
init_done<=1'b0;
//set counter to FFFF incase of binary or 9999 incase of BCD
end*/
if (GATE==1'b0)
begin
strobe<=0;
 is_loaded<=0;
 OUT<=1;
init_done<=0;
mode_5_zero_flag<=1;
//current_count<=current_count;
end
end
end
endmodule
	
	
	
	//megz end 
	
	
 

