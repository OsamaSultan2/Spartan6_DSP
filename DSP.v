module DSP (
  A,B,C,D,carryin,M,P,carryout,
  carryoutF,clk,opmode,CEA,CEB,
  CEC,CECARRYIN,CEM,CED,CEOPMODE,CEP,
  RSTA,RSTB,RSTC,RSTD,RSTCARRYIN,RSTM,
  RSTOPMODE,RSTP,BCOUT,PCIN,PCOUT,BCIN,
);
//============= PARAMETERS ===============================
  parameter A0REG=1'b0;parameter A1REG=1'b1;
  parameter B0REG=1'b0;parameter B1REG=1'b1;
  parameter CREG=1'b1;parameter DREG=1'b1;
  parameter MREG=1'b1;parameter PREG=1'b1;
  parameter CARRYINREG=1'b1;parameter CARRYOUTREG=1'b1;
  parameter OPMODEREG=1'b1;parameter CARRYINSEL="OPMODE5";
  parameter B_INPUT="DIRECT";parameter RSTTYPE="SYNC";
//============== INPUTS ==================================
  input [17:0] A,B,D,BCIN;
  input [47:0] C,PCIN;
  input [7:0] opmode;
  input carryin,clk;
  input CEA,CEB,CEC,CED,CEM,CEP;
  input CECARRYIN,CEOPMODE;
  input RSTA,RSTB,RSTC,RSTD,RSTM,RSTP;
  input RSTCARRYIN,RSTOPMODE;
//============ OUTPUTS ==================================
  output[35:0] M;
  output [47:0] P , PCOUT;
  output carryout,carryoutF;
  output [17:0] BCOUT;
//============= internal signals =========================
  wire [17:0] B0_in,B0_r,D_r,A0_r,pre_add_sub,B1_in,A1_r;
  wire [7:0] opmode_r;
  wire [47:0] C_r,D_A_B_CONC,post_add_sub;
  reg [47:0] X,Z;
  wire [35:0] M_in;
  wire CYI_input,CYO_input,CYI_r;
//============ Design ===================================
assign B0_in=(B_INPUT=="DIRECT")?B:(B_INPUT=="CASCADE")?BCIN:0;
//--------------- first stage registers ------------------------
ff_mux #(.WIDTH(8),.RSTTYPE("SYNC")) opmode_reg (.D(opmode),.clk(clk),.enable(CEOPMODE),.rst(RSTOPMODE),.Q(opmode_r),.sel(OPMODEREG));
ff_mux #(.WIDTH(18),.RSTTYPE("SYNC")) D_reg (.D(D),.clk(clk),.enable(CED),.rst(RSTD),.Q(D_r),.sel(DREG));
ff_mux #(.WIDTH(18),.RSTTYPE("SYNC")) B0_reg (.D(B0_in),.clk(clk),.enable(CEB),.rst(RSTB),.Q(B0_r),.sel(B0REG));
ff_mux #(.WIDTH(48),.RSTTYPE("SYNC")) C_reg (.D(C),.clk(clk),.enable(CEC),.rst(RSTC),.Q(C_r),.sel(CREG));
ff_mux #(.WIDTH(18),.RSTTYPE("SYNC")) A0_reg (.D(A),.clk(clk),.enable(CEA),.rst(RSTA),.Q(A0_r),.sel(A0REG));
assign pre_add_sub=(opmode_r[6]==0)?D_r+B0_r:D_r-B0_r;
assign B1_in=(opmode_r[4]==0)?B0_r:pre_add_sub;
ff_mux #(.WIDTH(18),.RSTTYPE("SYNC")) B1_reg (.D(B1_in),.clk(clk),.enable(CEB),.rst(RSTB),.Q(BCOUT),.sel(B1REG));
ff_mux #(.WIDTH(18),.RSTTYPE("SYNC")) A1_reg (.D(A0_r),.clk(clk),.enable(CEA),.rst(RSTA),.Q(A1_r),.sel(A1REG));
//--------------- second stage -----------------------------------
assign M_in=BCOUT*A1_r;
ff_mux #(.WIDTH(36),.RSTTYPE("SYNC")) M_reg (.D(M_in),.clk(clk),.enable(CEM),.rst(RSTM),.Q(M),.sel(MREG));
assign D_A_B_CONC={D_r[11:0],A1_r[17:0],BCOUT[17:0]};
//------------- X MULTIPLEXER ------------------------------------
always @(*) begin
  case (opmode_r[1:0])
    2'b00:X=0; 
    2'b01:X=M; //==============>X={11'b000_0000_0000,M} 
    2'b10:X=P; 
    2'b11:X=D_A_B_CONC; 
  endcase
//-------------- Z MULTIPLEXER ------------------------------------
  case (opmode_r[3:2])
    2'b00:Z=0; 
    2'b01:Z=PCIN; 
    2'b10:Z=P; 
    2'b11:Z=C_r; 
  endcase
end
//---------------- third stage --------------------------------------
assign CYI_input=(CARRYINSEL=="CARRYIN")?carryin:(CARRYINSEL=="OPMODE5")?opmode_r[5]:0;
ff_mux #(.WIDTH(1),.RSTTYPE("SYNC")) CYI_reg (.D(CYI_input),.clk(clk),.enable(CECARRYIN),.rst(RSTCARRYIN),.Q(CYI_r),.sel(CARRYINREG));
assign {CYO_input,post_add_sub}=(opmode_r[7]==0)?(Z+X+CYI_r):(Z-(X+CYI_r));
ff_mux #(.WIDTH(1),.RSTTYPE("SYNC")) CYO_reg (.D(CYO_input),.clk(clk),.enable(CECARRYIN),.rst(RSTCARRYIN),.Q(carryout),.sel(CARRYOUTREG));
assign carryoutF=carryout;
ff_mux #(.WIDTH(48),.RSTTYPE("SYNC")) P_reg (.D(post_add_sub),.clk(clk),.enable(CEP),.rst(RSTP),.Q(P),.sel(PREG));
assign PCOUT=P;
endmodule