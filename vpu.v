`timescale 1ns / 1ps // specify time unit and precision
    
///////////fields of IR // define fields of the instruction register (IR)
`define oper_type IR[31:27] // operation type
`define rdst      IR[26:22] // destination register
`define rsrc1     IR[21:17] // source register 1
`define imm_mode  IR[16]    // immediate mode
`define rsrc2     IR[15:11] // source register 2
`define isrc      IR[15:0]  // immediate value or source register 2 (depending on imm_mode)
    
    
////////////////arithmetic operation // define operation codes for arithmetic operations
`define movsgpr        5'b00000 // move from special register to general purpose register
`define mov            5'b00001 // move operation
`define add            5'b00010 // addition
`define sub            5'b00011 // subtraction
`define mul            5'b00100 // multiplication
    
////////////////logical operations : and or xor xnor nand nor not // define operation codes for logical operations
    
`define ror            5'b00101 // bitwise OR
`define rand           5'b00110 // bitwise AND
`define rxor           5'b00111 // bitwise XOR
`define rxnor          5'b01000 // bitwise XNOR
`define rnand          5'b01001 // bitwise NAND
`define rnor           5'b01010 // bitwise NOR
`define rnot           5'b01011 // bitwise NOT
    
    
module top(); // define top-level module
    
    
    
    
    
    
reg [31:0] IR; // instruction register
                            
reg [15:0] GPR [31:0] ; // general purpose registers (32 registers of 16 bits each)
    
    
    
reg [15:0] SGPR ; // special register for storing most significant bits of multiplication result
    
reg [31:0] mul_res; // store full 32-bit result of multiplication
    
    
    
always@(*) // always block, triggered on any signal change
begin
case(`oper_type) // case statement based on operation type
///////////////////////////////
`movsgpr: begin // move from special register to general purpose register
    
    GPR[`rdst] = SGPR; // copy value from special register to destination register
    
end
    
/////////////////////////////////
`mov : begin // move operation
    if(`imm_mode) // if immediate mode
        GPR[`rdst]  = `isrc; // copy immediate value to destination register
    else
        GPR[`rdst]   = GPR[`rsrc1]; // copy value from source register 1 to destination register
end
    
////////////////////////////////////////////////////
    
`add : begin // addition
        if(`imm_mode) // if immediate mode
        GPR[`rdst]   = GPR[`rsrc1] + `isrc; // add source register 1 and immediate value, store in destination register
        else
        GPR[`rdst]   = GPR[`rsrc1] + GPR[`rsrc2]; // add source register 1 and source register 2, store in destination register
end
    
/////////////////////////////////////////////////////////
    
`sub : begin // subtraction
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = GPR[`rsrc1] - `isrc; // subtract immediate value from source register 1, store in destination register
        else
        GPR[`rdst]   = GPR[`rsrc1] - GPR[`rsrc2]; // subtract source register 2 from source register 1, store in destination register
end
    
/////////////////////////////////////////////////////////////
    
`mul : begin // multiplication
        if(`imm_mode) // if immediate mode
        mul_res   = GPR[`rsrc1] * `isrc; // multiply source register 1 and immediate value
        else
        mul_res   = GPR[`rsrc1] * GPR[`rsrc2]; // multiply source register 1 and source register 2
        
        GPR[`rdst]   =  mul_res[15:0]; // store least significant 16 bits of result in destination register
        SGPR         =  mul_res[31:16]; // store most significant 16 bits of result in special register
end
    
///////////////////////////////////////////////////////////// bitwise or
    
`ror : begin // bitwise OR
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = GPR[`rsrc1] | `isrc; // bitwise OR source register 1 and immediate value, store in destination register
        else
        GPR[`rdst]   = GPR[`rsrc1] | GPR[`rsrc2]; // bitwise OR source register 1 and source register 2, store in destination register
end
    
////////////////////////////////////////////////////////////bitwise and
    
`rand : begin // bitwise AND
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = GPR[`rsrc1] & `isrc; // bitwise AND source register 1 and immediate value, store in destination register
        else
        GPR[`rdst]   = GPR[`rsrc1] & GPR[`rsrc2]; // bitwise AND source register 1 and source register 2, store in destination register
end
    
//////////////////////////////////////////////////////////// bitwise xor
    
`rxor : begin // bitwise XOR
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = GPR[`rsrc1] ^ `isrc; // bitwise XOR source register 1 and immediate value, store in destination register
        else
        GPR[`rdst]   = GPR[`rsrc1] ^ GPR[`rsrc2]; // bitwise XOR source register 1 and source register 2, store in destination register
end
    
//////////////////////////////////////////////////////////// bitwise xnor
    
`rxnor : begin // bitwise XNOR
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = GPR[`rsrc1] ~^ `isrc; // bitwise XNOR source register 1 and immediate value, store in destination register
        else
        GPR[`rdst]   = GPR[`rsrc1] ~^ GPR[`rsrc2]; // bitwise XNOR source register 1 and source register 2, store in destination register
end
    
//////////////////////////////////////////////////////////// bitwisw nand
    
`rnand : begin // bitwise NAND
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = ~(GPR[`rsrc1] & `isrc); // bitwise NAND source register 1 and immediate value, store in destination register
        else
        GPR[`rdst]   = ~(GPR[`rsrc1] & GPR[`rsrc2]); // bitwise NAND source register 1 and source register 2, store in destination register
end
    
////////////////////////////////////////////////////////////bitwise nor
    
`rnor : begin // bitwise NOR
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = ~(GPR[`rsrc1] | `isrc); // bitwise NOR source register 1 and immediate value, store in destination register
        else
        GPR[`rdst]   = ~(GPR[`rsrc1] | GPR[`rsrc2]); // bitwise NOR source register 1 and source register 2, store in destination register
end
    
////////////////////////////////////////////////////////////not
    
`rnot : begin // bitwise NOT
        if(`imm_mode) // if immediate mode
        GPR[`rdst]  = ~(`isrc); // bitwise NOT immediate value, store in destination register
        else
        GPR[`rdst]   = ~(GPR[`rsrc1]); // bitwise NOT source register 1, store in destination register
end
    
////////////////////////////////////////////////////////////
    
endcase
end
    
    
    
///////////////////////logic for condition flag // logic for setting condition flags (sign, zero, overflow, carry)
reg sign = 0, zero = 0, overflow = 0, carry = 0;
reg [16:0] temp_sum;
    
always@(*)
begin
    
/////////////////sign bit
if(`oper_type == `mul)
    sign = SGPR[15];
else
    sign = GPR[`rdst][15];
    
////////////////carry bit
    
if(`oper_type == `add)
    begin
        if(`imm_mode)
            begin
            temp_sum = GPR[`rsrc1] + `isrc;
            carry    = temp_sum[16]; 
            end
        else
            begin
            temp_sum = GPR[`rsrc1] + GPR[`rsrc2];
            carry    = temp_sum[16]; 
            end   end
    else
    begin
        carry  = 1'b0;
    end
    
///////////////////// zero bit
if(`oper_type == `mul)
    zero =  ~((|SGPR[15:0]) | (|GPR[`rdst]));
else
    zero =  ~(|GPR[`rdst]); 
    
    
//////////////////////overflow bit
    
if(`oper_type == `add)
        begin
        if(`imm_mode)
            overflow = ( (~GPR[`rsrc1][15] & ~IR[15] & GPR[`rdst][15] ) | (GPR[`rsrc1][15] & IR[15] & ~GPR[`rdst][15]) );
        else
            overflow = ( (~GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst][15]));
        end
    else if(`oper_type == `sub)
    begin
        if(`imm_mode)
            overflow = ( (~GPR[`rsrc1][15] & IR[15] & GPR[`rdst][15] ) | (GPR[`rsrc1][15] & ~IR[15] & ~GPR[`rdst][15]) );
        else
            overflow = ( (~GPR[`rsrc1][15] & GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & ~GPR[`rdst][15]));
    end 
    else
        begin
        overflow = 1'b0;
        end
    
end
    
    
    
endmodule
    
////////////////////////////////////////////////////////////////////////////