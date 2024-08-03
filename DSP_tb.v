module DSP_tb();
  reg carryin,clk,CEA,CEB,CEC,CED,CEM,CEP;
  reg CECARRYIN,CEOPMODE,RSTA,RSTB,RSTC,RSTD,RSTM;
  reg RSTP,RSTCARRYIN,RSTOPMODE;
  reg [17:0] A,B,D,BCIN;
  reg [47:0] C,PCIN;
  reg [7:0] opmode;
  wire [35:0] M;
  wire [47:0] P , PCOUT;
  wire carryout,carryoutF;
  wire [17:0] BCOUT;
//======= DUT INIT. =====================
  DSP dut (.carryin(carryin),.clk(clk),.CEA(CEA),.CEB(CEB),.CEC(CEC),.CED(CED),
  .CEM(CEM),.CEP(CEP),.CECARRYIN(CECARRYIN),.CEOPMODE(CEOPMODE),.RSTA(RSTA),.RSTB(RSTB),
  .RSTC(RSTC),.RSTD(RSTD),.RSTM(RSTM),.RSTP(RSTP),.RSTCARRYIN(RSTCARRYIN),.RSTOPMODE(RSTOPMODE),
  .A(A),.B(B),.D(D),.BCIN(BCIN),.C(C),.PCIN(PCIN),.opmode(opmode),.M(M),.P(P),.PCOUT(PCOUT),
  .carryout(carryout),.carryoutF(carryoutF),.BCOUT(BCOUT));
//====== clock generation =================
initial begin
  clk=0;
  forever begin
  #1 clk =~clk;
  end
end
//=============== testbench ===============

/*- wait clock cycle for BCOUT
  - wait two clock cycle for M
  - wait one - two - three clock cycles for the output depends on X and Z */


initial begin
  CEA=1; CEB=1; CEC=1; CED=1; CEM=1; CEP=1;
  CECARRYIN=1; CEOPMODE=1; RSTA=1; RSTB=1; RSTC=1; RSTD=1; RSTM=1;
  RSTP=1; RSTCARRYIN=1; RSTOPMODE=1;
  A=0; B=0; C=0; D=0; BCIN=0;
  PCIN=0; opmode=0; carryin=0;
  @(negedge clk);
  RSTA=0; RSTB=0; RSTC=0; RSTD=0; RSTM=0;
  RSTP=0; RSTCARRYIN=0; RSTOPMODE=0;
//----------------mathemtical operations check----------------------  
  A=0; B=2; C=3; D=0; BCIN=5;
  PCIN=1; opmode=0; carryin=0;
    @(negedge clk); 
  
  A=1; B=3; C=4 ; D=5; BCIN=5;
  PCIN=15; opmode='b0000_0001; carryin=0; 
  @(negedge clk);
  
  A=4; B=4; C=9 ; D=10; BCIN=5;
  PCIN=15; opmode='b0_1_1_0_00_10; carryin=0;
    @(negedge clk);
  A=90; B=40; C=90 ; D=150; BCIN=12;
  PCIN=15; opmode='b0_0_0_0_00_11; carryin=1;
    @(negedge clk);
  A=10; B=40; C=20 ; D=90; BCIN=25;
  PCIN=15; opmode='b0_0_0_0_01_00; carryin=1;
    @(negedge clk);
  A=3; B=2; C=1 ; D=9; BCIN=30;
  PCIN=20; opmode='b0_0_0_0_01_01; carryin=1;
    @(negedge clk);
    A=3; B=2; C=1 ; D=9; BCIN=30;
  PCIN=20; opmode='b0_0_0_0_01_01; carryin=1;
    repeat(3) begin
    @(negedge clk);
  end 
    A=5; B=15; C=1 ; D=30; BCIN=30;
  PCIN=20; opmode='b0_0_0_0_10_01; carryin=1;
    @(negedge clk);
    A=5; B=15; C=10 ; D=30; BCIN=30;
  PCIN=20; opmode='b0_0_0_0_11_01; carryin=1;
    @(negedge clk);
  A=5; B=15; C=12 ; D=30; BCIN=30;
  PCIN=20; opmode='b0_0_0_1_11_01; carryin=1;
    @(negedge clk);
  A=5; B=15; C=9 ; D=30; BCIN=30;
  PCIN=20; opmode='b0_0_1_0_11_01; carryin=1;
    @(negedge clk);
  A=5; B=15; C=3; D=30; BCIN=30;
  PCIN=20; opmode='b0_1_0_0_11_01; carryin=1;
    @(negedge clk);
  A=5; B=15; C=6 ; D=30; BCIN=30;
  PCIN=20; opmode='b1_0_0_0_11_01; carryin=1;
    @(negedge clk);
$stop;
end
endmodule