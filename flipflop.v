module ff_mux (D,clk,rst,enable,Q,sel);
parameter WIDTH =18;
parameter RSTTYPE="SYNC";
input [WIDTH-1:0] D;
output [WIDTH-1:0] Q;
reg[WIDTH-1:0] Q_r;
input rst,clk,enable,sel;
generate
  if (RSTTYPE=="SYNC") begin
    always @(posedge clk) begin
      if (rst) begin
        Q_r<=0;
      end
      else if (enable) begin
        Q_r<=D;
      end
    end
  end
  else if (RSTTYPE=="ASYNC") begin
    always @(posedge clk or posedge rst) begin
      if (rst) begin
        Q_r<=0;
      end
      else if (enable) begin
        Q_r<=D;
      end
    end
  end
endgenerate
assign Q=(sel)?Q_r:D;
endmodule



//========= verification ====================
module ff_mux_tb ();
  reg rst,clk,enable,sel;
  reg [17:0] D;
  wire [17:0] Q;
//======== DUT INIT. ========================
  ff_mux dut (.D(D),.rst(rst),.Q(Q),.clk(clk),.enable(enable),.sel(sel));
//========= clock generation ================
  initial begin
    clk=0;
    forever begin
      #5 clk =~clk; //increasing delay to ensure the operation of mux later
    end
  end
//======== testbench ========================
initial begin
  rst=1;
  D=0;
  enable=0;
  sel=1;
  @(negedge clk);
  rst=1;
  repeat(20) begin
    enable=$random;
    D=$random;
    @(negedge clk);
  end
  rst=0;enable=1;
  repeat(30) begin
    D=$random;
    @(negedge clk);
  end
  //========= continues assignemnt checking ============
  rst=1;sel=0;
  repeat(20) begin
    enable=$random;
    D=$random;
  #2;
  end
  rst=0;enable=0;
  repeat(30) begin
    D=$random;
  #2;
  end
  enable=1;
  repeat(30) begin
    D=$random;
  #2;
  end
$stop;
end
endmodule