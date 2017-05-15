<<<<<<< HEAD
module ControlLogic(control_word,initial_count,//current_count,
CLK,GATE,OUT,null_count,
  CRM_enable,CRL_enable,OLM_enable,OLL_enable,status_register_enable,status_latch_enable,count_enable,load_new_count );
  
  input [7:0] control_word;
  input [15:0] initial_count;
 //// input [15:0] current_count;
  input CLK,GATE;
  output OUT,null_count;
  input CRM_enable,CRL_enable,OLM_enable,OLL_enable,status_register_enable,status_latch_enable;
  output count_enable;
  output load_new_count ;
  reg OUT;
  reg strobe;
   reg is_loaded;
  reg prev_gate;
 reg current_count;
  reg load_new_count ;
  //assign strobe_wire=0;
  initial
  begin
  strobe<=0;
  is_loaded<=0;
  OUT<=1;

  end
  always@(CLK)
  begin
  ////////////////////////////////// el 3'aly 
 
  if (control_word[2:0]==3'b000) //mode 0
  begin
  
  end
  
   if (control_word[2:0]==3'b001) //mode 1
  begin
  
  end
  ///////////////////////////////
  
  
   if (control_word[1:0]==2'b10) //mode 2
  begin
  
  end
  if (control_word[1:0]==2'b11) //mode 3
  begin
  if (initial_count[0]==1'b1)
  begin
  
  end
  else if (initial_count[0]==1'b0)
  begin
  end
  end 
  if (control_word[2:0]==3'b100) //mode 4
  begin
  
  end
  
  if (control_word[2:0]==3'b101) //mode 5
  begin

 if({prev_gate,GATE} ==2'b01)
  begin
  is_loaded<=1;
  end

  if (is_loaded==1'b1)
  begin
  load_new_count<=1;
  current_count<=initial_count; //to be removed
  end
  if (current_count>0)
  begin
  current_count<=current_count-1; //to be removed
  end
  if (current_count==0)
  begin
  OUT<=1;
  strobe<=1;
  end
 if (strobe==1'b1)
  begin
  OUT<=0;
  strobe<=0;
  end
 OUT<=~strobe;
 end
 prev_gate<=GATE;
end
endmodule

=======
test
>>>>>>> origin/master
