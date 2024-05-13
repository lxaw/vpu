// testbench for vpu
module tb;
    integer i = 0; // keep track of element number
    top dut();

    // update all gpr to some known value, we choose 2
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            dut.GPR[i] = 2;
        end
    end

    initial begin
        $display("-----------------------------------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 2;
        dut.`rsrc1 = 2;///gpr[2] = 2
        dut.`rdst  = 0;///gpr[0]
        dut.`isrc = 4;
        #10;
        $display("OP:ADI Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR[2], dut.`isrc, dut.GPR[0]);
        $display("-----------------------------------------------------------------");
        ////////////register add op
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 2;
        dut.`rsrc1 = 4;
        dut.`rsrc2 = 5;
        dut.`rdst  = 0;
        #10;
        $display("OP:ADD Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR[4], dut.GPR[5], dut.GPR[0] );
        $display("-----------------------------------------------------------------");
        
        //////////////////////immediate mov op
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 1;
        dut.`rdst = 4;///gpr[4]
        dut.`isrc = 55;
        #10;
        $display("OP:MOVI Rdst:%0d  imm_data:%0d",dut.GPR[4],dut.`isrc  );
        $display("-----------------------------------------------------------------");
        
        //////////////////register mov
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 1;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;//gpr[7]
        #10;
        $display("OP:MOV Rdst:%0d  Rsrc1:%0d",dut.GPR[4],dut.GPR[7] );
        $display("-----------------------------------------------------------------");
        
        //////////////////////logical and imm
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 6;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;//gpr[7]
        dut.`isrc = 56;
        #10;
        $display("OP:ANDI Rdst:%8b  Rsrc1:%8b imm_d :%8b",dut.GPR[4],dut.GPR[7],dut.`isrc );
        $display("-----------------------------------------------------------------");
        
        ///////////////////logical or imm
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 7;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;//gpr[7]
        dut.`isrc = 56;
        #10;
        $display("OP:XORI Rdst:%8b  Rsrc1:%8b imm_d :%8b",dut.GPR[4],dut.GPR[7],dut.`isrc );
        $display("-----------------------------------------------------------------");
        // immediate add op
        $display("------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1; // immediate addressing mode
        dut.`oper_type = 2; // addition code
        dut.`rsrc1 = 2; // gpr[2] should have value of 2 in beginning
        dut.`rdst = 0; // gpr[0]
        dut.`isrc = 4;
        #10
        $display("OP:ADI Rsrc1: %0d Rsrc2:%0d Rdst:%0d", dut.GPR[2], dut.`isrc, dut.GPR[0]);
        $display("------------------------------");

        // register add op
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 2;
        dut.`rsrc1 = 4;
        dut.`rsrc2 = 5;
        dut.`rdst = 0;
        #10
        $display("OP:ADD Rsrc1:%0d Rsrc2:%0d Rdst:%0d", dut.GPR[4], dut.GPR[5], dut.GPR[0]);
        $display("------------------------------");

        // immediate mov op
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 1; // val for move type is 1
        dut.`rdst = 4; // GPR[4]
        dut.`isrc = 55;
        #10
        $display("OP:MOVI Rdst:%0d imm_data:%0d", dut.GPR[4], dut.`isrc);
        $display("------------------------------");

        // register mov
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 1;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        #10
        $display("OP:MOV Rdst:%0d Rsrc1:%0d", dut.GPR[4], dut.GPR[7]);
        $display("------------------------------");
    end
endmodule