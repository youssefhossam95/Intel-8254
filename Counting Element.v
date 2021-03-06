 module CountingElement(initial_count,current_count,CLK,count_enable,load_new_count,count_loaded,counter_programmed,BCD,RW,enableTwo);
  
  input [15:0] initial_count;
  output [15:0] current_count;
  input CLK,count_enable,load_new_count,BCD,enableTwo;
  output count_loaded;
  input counter_programmed;
  input [1:0] RW;
  reg [15:0] current_count;
  reg count_loaded;
  wire[7:0] subtractValue;
  
  assign subtractValue = 
(enableTwo) ? 8'b00000010:8'b00000001;

  always @(counter_programmed)
    if(counter_programmed)
      count_loaded <= 0;
  
  always @(posedge CLK) //lessa hazawed mawdoo3 hay3ed 3ala anhy byte(s)
  begin
	
	if(load_new_count) begin
		count_loaded <= 1;
		if(enableTwo && initial_count[0]==1) begin //odd count and mode 3 
			current_count <= initial_count-1;
		end 
		else begin 
			current_count <= initial_count;
		end
	end
	else begin 
		if(count_enable)
		  begin
			if(RW==2'b01)
			  begin
				if(BCD & current_count[7:0]==8'h00)
				  current_count[7:0] <= 8'h99;
				else
				  current_count[7:0] <= current_count[7:0] - subtractValue;
			  end
			else if(RW==2'b10)
			  begin
				if(BCD & current_count[15:8]==8'h00)
				  current_count[15:8] <= 8'h99;
				else
				  current_count[15:8] <= current_count[15:8] - subtractValue;
			  end
			else
			  begin
				if(BCD & current_count==16'h0000)
				  current_count <= 16'h9999;
				else
				  current_count <= current_count - {8'b00000000,subtractValue};
			  end
			
		  end
	end
  end
  
endmodule

