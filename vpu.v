`timescale 1ns / 1ps

// fields of IR
`define oper_type IR[31:27]
`define rdst IR[26:22]
`define rsrc1 IR[21:17]
`define imm_mode IR[16]
`define rsrc2 IR[15:11]
`define isrc IR[15:0]

// arith ops
`define movsgpr 5'b00000
`define mov 5'b00001
`define add 5'b00010
`define sub 5'b00011
`define mul 5'b00100

// logical ops
// we use ror, since 'or' is already a keyword
`define ror 5'b00101
`define rand 5'b00110
`define rxor 5'b00111
`define rxnor 5'b01000
`define rnand 5'b01001
`define rnor 5'b01010
`define rnot 5'b01011

module top();
    reg [31:0] IR; // instruction register
    // fields: [31:27]-[26:22]-[21:17]-[16] -[15:11]- [10:0]
    // oper rdest rsrc1 modesel rsrc2 unusued
    // oper rdest rsrc1 modesel immediate

    // note that bit 16 tells us if we shall be using the immediate or rsrc2
    // this is not great design, but simple enough to implement
    // our registers can only store 16 bit in this architecture
    reg [31:0] GPR [31:0]; // general purpose register
    // gpr[0] ... gpr[31]
    // since we chose 5 bits for rdest, we need 32 (2^5) gprs
    reg [31:0] SGPR; // mul_out(31:16) MSB 16 bit MSB 16 bit MSB 16 bit MSB 16 bit
    // RDST = mul_out(15:0) LSB 16 bit
    reg [63:0] mul_res;

    always @(*) // asterisk indicates that as soon as any value of a variable changes, we re-evaluate
    begin
        // do a case statement on operation type
        case (`oper_type)
            `movsgpr: 
                begin
                    GPR[`rdst] = SGPR; // if movsgpr, need to store the value of SGPR into GPR
                end
            `mov: 
                begin
                    if (`imm_mode)
                        GPR[`rdst] = `isrc; // if imm_mode 1, then need an immediate
                    else
                        GPR[`rdst] = GPR[`rsrc1];
                end
            `add: 
                begin
                    if (`imm_mode)
                        GPR[`rdst] = GPR[`rsrc1] + `isrc;
                    else
                        GPR[`rdst] = GPR[`rsrc1] + GPR[`rsrc2];
                end
            `sub: 
                begin
                    if (`imm_mode)
                        GPR[`rdst] = GPR[`rsrc1] - `isrc;
                    else
                        GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2];
                end
            `mul: 
                begin
                    if (`imm_mode)
                        mul_res = GPR[`rsrc2] * `isrc;
                    else
                        mul_res = GPR[`rsrc1] * GPR[`rsrc2];
                    GPR[`rdst] = mul_res[31:0];
                    SGPR = mul_res[63:32];
                end
            `ror: 
                begin
                    if(`imm_mode)
                        GPR[`rdst] = GPR[`rsrc1] | `isrc;
                    else
                        GPR[`rdst] = GPR[`rsrc1] | GPR[`rsrc2];
                end
            `rand:
                begin
                    if(`imm_mode)
                        GPR[`rdst] = GPR[`rsrc1] & `isrc;
                    else
                        GPR[`rdst] = GPR[`rsrc1] & GPR[`rsrc2];
                end
            `rxor: 
                begin
                    if(`imm_mode)
                        GPR[`rdst] = GPR[`rsrc1] ^ `isrc;
                    else   
                        GPR[`rdst] = GPR[`rsrc1] ^ GPR[`rsrc2];
                end
            `rxnor:
                begin
                    if(`imm_mode)
                        GPR[`rdst] = GPR[`rsrc1] ~^ `isrc;
                    else
                        GPR[`rdst] = GPR[`rsrc1] ~^ GPR[`rsrc2];
                end
            `rnand:
                begin
                    if(`imm_mode)
                        GPR[`rdst] = ~(GPR[`rsrc1] & `isrc);
                    else
                        GPR[`rdst] = ~(GPR[`rsrc1] & GPR[`rsrc2]);
                end
            `rnor:
                begin
                    if(`imm_mode)
                        GPR[`rdst] = ~(GPR[`rsrc1] | `isrc);
                    else
                        GPR[`rdst] = ~(GPR[`rsrc1] | GPR[`rsrc2]);
                end
            `rnot:
                begin
                    if(`imm_mode)
                        GPR[`rdst] = ~(`isrc);
                    else
                        GPR[`rdst] = ~(GPR[`rsrc1]);
                end
        endcase
    end
endmodule