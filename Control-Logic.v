module ControlLogic(control_word,status_byte,clk,GATE,OUT,null_count,load_new_count,count_loaded,counter_programmed,
  CR_enable,OL_enable,status_register_enable,status_latch_enable,count_enable,CR_reset,
  A,WR,RD,CS,my_address,read_count_enable,read_status_enable,
  initial_count,current_count,enableTwo);
  
  input [7:0] control_word,status_byte;
  input clk,GATE;
  output OUT,null_count,load_new_count,counter_programmed;
  input count_loaded;
  output [1:0] CR_enable,OL_enable;
  output status_register_enable,status_latch_enable,count_enable,CR_reset;
  input [1:0] A,my_address;
  input WR,RD,CS;
  output [1:0] read_count_enable;
  output read_status_enable;
  
  input [15:0] initial_count;
  input [15:0] current_count;
  output enableTwo;
  
  reg [1:0] CR_enable,OL_enable;
  reg MSB_write,MSB_read;
  reg counter_latched,status_latched;
  reg [1:0] read_count_enable;
  reg read_status_enable;
  reg CR_reset,status_latch_enable;
  reg counter_programmed;
  reg load_new_count,OUT;
  
  //joe zyadat
	reg count_enable;
	wire [2:0] mode;
	reg enableTwo;
	reg outFlag,startLoading,mode2Init;
	wire [1:0] readType; //01 lsb 10 msb 11 lsb then msb
	reg lastDigit;
	assign readType=status_byte[5:4];
	assign mode=status_byte[3:1];
	
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
			if(control_word[3:1]==0 && RD==1 && WR==0 && CS==0 && control_word[7:6]==my_address) begin //new mode zero control word loaded -> set out to zero.
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
	
	
	//mode 3 start
	
	always@(posedge clk)
	begin 
		if(mode==3) begin 
			enableTwo=1;
			load_new_count=0;
			if(lastDigit==0) begin 
				if(current_count==4) begin 
					load_new_count=1;
				end
				if(current_count==2) begin 
					OUT=~OUT;
					lastDigit=initial_count[0];
				end
			end 
			else begin 
				if(OUT) begin 
					if(current_count==2) begin 
						load_new_count=1;
					end
					if(current_count==0) begin 
						OUT=~OUT;
						lastDigit=initial_count[0];
					end
				end 
				else begin
					if(current_count==4) begin 
						load_new_count=1;
					end
					if(current_count==2) begin 
						OUT=~OUT;
						lastDigit=initial_count[0];
					end
				
				end
				
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
			lastDigit=initial_count[0];
			count_enable=1;
		end
	end
	
	
	//mode 3 end
	
	
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
			if(startLoading) begin  //new count is loading while mode is 4 
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
		
		if(control_word[3:1]==2 && RD==1 && WR==0 && CS==0 && control_word[7:6]==my_address) begin 
			mode2Init=1;
		end
	
		if(mode==2) begin
			OUT=1;
			if(startLoading && mode2Init) begin //initalizing count
				mode2Init=0;
				startLoading=0;
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
	reg strobe, is_loaded;
	
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
	
	
	
	//megz end 
	
	//farid begin
  
  assign status_register_enable = (control_word[7:6]==my_address & ~(control_word[5:4]==2'b00))? 1 : 0;
  assign null_count = (count_loaded==0)? 1 : 0;
  
  always @(count_loaded)
  if(count_loaded==0)
    counter_programmed <= 0;
  
  always @(control_word)
  begin
    if(control_word[7:6]==my_address & ~(control_word[5:4]==2'b00)) //counter programmed
    begin
      CR_reset <= 1;
      MSB_write <= 0;
      OL_enable <= 2'b11;
      status_latch_enable <= 1;
      counter_latched <= 0;
      status_latched <= 0;
      read_count_enable <= 2'b00;
      read_status_enable <= 0;
      counter_programmed <= 1;
    end
    else if(control_word[7:6]==my_address & control_word[5:4]==2'b00) //counter latch command
    begin
      OL_enable <= 2'b00;
      counter_latched <= 1;
      MSB_read <= 0;
    end
    else if(control_word[7:6]==2'b11 & control_word[my_address+1]==1) //read-back command
    begin
      if(control_word[5]==0)  //latch count
      begin
        OL_enable <= 2'b00;
        counter_latched <= 1;
        MSB_read <= 0;
      end
      if(control_word[4]==0)  //latch status
      begin
        status_latch_enable <= 0;
        status_latched <= 1;
      end
    end
  end
  
  always @(A,WR,RD,CS)
  begin
    if(A==my_address & RD==0 & WR==1 & CS==0) //read operation
    begin
      if(status_latched)  //read latched status
      begin
        read_count_enable <= 2'b00;
        read_status_enable <= 1;
        status_latch_enable <= 1;
        status_latched <= 0;
      end
      else if(counter_latched)  //read latched counter
      begin
        if(status_byte[5:4]==2'b01)
        begin
          read_count_enable <= 2'b01;
          read_status_enable <= 0;
          OL_enable <= 2'b11;
          counter_latched <= 0;
        end
        else if(status_byte[5:4]==2'b10)
        begin
          read_count_enable <= 2'b10;
          read_status_enable <= 0;
          OL_enable <= 2'b11;
          counter_latched <= 0;
        end
        else if(status_byte[5:4]==2'b11)
        begin
          if(MSB_read)
          begin
            read_count_enable <= 2'b10;
            read_status_enable <= 0;
            OL_enable[1] <= 1;
            counter_latched <= 0;
          end
          else
          begin
            read_count_enable <= 2'b01;
            read_status_enable <= 0;
            OL_enable[0] <= 1;
          end
          MSB_read <= ~MSB_read;
        end
      end
      else  //simple read
      begin
        if(status_byte[5:4]==2'b01)
        begin
          read_count_enable <= 2'b01;
          read_status_enable <= 0;
        end
        else if(status_byte[5:4]==2'b10)
        begin
          read_count_enable <= 2'b10;
          read_status_enable <= 0;
        end
        else if(status_byte[5:4]==2'b11)
        begin
          if(MSB_read)
          begin
            read_count_enable <= 2'b10;
            read_status_enable <= 0;
          end
          else
          begin
            read_count_enable <= 2'b01;
            read_status_enable <= 0;
          end
          MSB_read <= ~MSB_read;
        end
      end
    end
    else if(A==my_address & RD==1 & WR==0 & CS==0) //write operation
    begin
      CR_reset <= 0;
      if(status_byte[5:4]==2'b01)
	  begin
	    startLoading <= 1;
        CR_enable <= 2'b01;
	  end
      else if(status_byte[5:4]==2'b10)
	  begin
	    startLoading <= 1;
        CR_enable <= 2'b10;
	  end
      else if(status_byte[5:4]==2'b11)
      begin
        if(MSB_write)
		begin
	      startLoading <= 1;
          CR_enable <= 2'b10;
		end
        else
          CR_enable <= 2'b01;
        MSB_write <= ~MSB_write;
      end
    end
  end
  
  //farid end
  
endmodule
