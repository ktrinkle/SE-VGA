/******************************************************************************
 * SE-VGA
 * VGA video output
 * techav
 * 2021-04-06
 ******************************************************************************
 * Fetches video data from VRAM and shifts out
 *****************************************************************************/

`include "vgashiftout.sv"

module vgaout (
    input wire          pixClock,
    input wire          nReset,
    input logic [9:0]   hCount,
    input logic [9:0]   vCount,
    input wire          hSEActive,
    input wire          vSEActive,
    input logic [7:0]   vramData,
    output logic [14:0] vramAddr,
    output wire         nvramOE,
    output wire         vidOut
);

//reg [7:0] rVid;
wire vidMuxOut;
wire vidActive; // combined active video signal

//wire vgaShiftEn; // Enable pixel shift out
wire vgaShiftL1; // Load VRAM data into register
wire vgaShiftL2; // Load VRAM data into shifter

vgaShiftOut vOut(
    .nReset(nReset),
    .clk(pixClock),
    .shiftEn(vidActive),
    .nLoad1(vgaShiftL1),
    .nLoad2(vgaShiftL2),
    .parIn(vramData),
    .out(vidMuxOut)
);

always_comb begin
    // load VRAM data into register
    if(hCount[2:0] == 0) vgaShiftL1 <= !pixClock;
    else vgaShiftL1 <= 1;

    // load VRAM data into shifter
    if(hCount[2:0] == 0) vgaShiftL2 <= !pixClock;
    else if(hCount[2:0] == 1) vgaShiftL2 <= pixClock;
    else vgaShiftL2 <= 1;

    // combined video active signal
    if(hSEActive == 1'b1 && vSEActive == 1'b1) begin
        vidActive <= 1'b1;
    end else begin
        vidActive <= 1'b0;
    end

    // video data output
    if(vidActive == 1'b1) begin
        vidOut <= vidMuxOut;
    end else begin
        vidOut <= 1'b0;
    end

    // vram read signal
    if(vidActive == 1'b1 && hCount[2:0] == 0) begin
        nvramOE <= 1'b0;
    end else begin
        nvramOE <= 1'b1;
    end

    // vram address signals
    // these will be mux'd with cpu addresses externally
    vramAddr[14:6] <= vCount[8:0];
    vramAddr[5:0]  <= hCount[8:3];
end
    
endmodule