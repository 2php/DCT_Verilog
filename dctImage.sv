module dctImage(
   output reg [6:0] HEX0, HEX1, HEX2, HEX3, //HEX4, HEX5,
	input CLOCK_50,
	output reg [9:0] LEDR,
	input [9:0] SW
);
reg unsigned [7:0] dIN[7:0][7:0];
reg signed [31:0] dataOut[7:0][7:0]; reg signed [11:0] dataIn[7:0][7:0];
reg signed [31:0] d_Out[7:0][7:0];
reg signed [16:0] T[7:0][7:0]; reg signed [16:0] T_t[7:0][7:0];
reg signed [63:0] DCT_out[7:0][7:0]; reg signed [63:0] q_result[7:0][7:0];
reg signed [7:0] qt_50[7:0][7:0]; reg signed [15:0] qtf_50[7:0][7:0];
reg signed [11:0] RLcode[128];
integer temp_k = 0, k = 0, counter, count = 25000000, zeroCount = 0, zeroes_16 = 0;
reg [3:0] state = 4'b0000;
reg [0:0] run = 1'b1;
reg [3:0] i = 4'b0, j = 4'b0;

assign dIN[0][0] = 8'd154, dIN[0][1] = 8'd123, dIN[0][2] = 8'd123, dIN[0][3] = 8'd123;
assign dIN[0][4] = 8'd123, dIN[0][5] = 8'd123, dIN[0][6] = 8'd123, dIN[0][7] = 8'd136;

assign dIN[1][0] = 8'd192, dIN[1][1] = 8'd180, dIN[1][2] = 8'd136, dIN[1][3] = 8'd154;
assign dIN[1][4] = 8'd154, dIN[1][5] = 8'd154, dIN[1][6] = 8'd136, dIN[1][7] = 8'd110;

assign dIN[2][0] = 8'd254, dIN[2][1] = 8'd198, dIN[2][2] = 8'd154, dIN[2][3] = 8'd154;
assign dIN[2][4] = 8'd180, dIN[2][5] = 8'd154, dIN[2][6] = 8'd123, dIN[2][7] = 8'd123;

assign dIN[3][0] = 8'd239, dIN[3][1] = 8'd180, dIN[3][2] = 8'd136, dIN[3][3] = 8'd180;
assign dIN[3][4] = 8'd180, dIN[3][5] = 8'd166, dIN[3][6] = 8'd123, dIN[3][7] = 8'd123;

assign dIN[4][0] = 8'd180, dIN[4][1] = 8'd154, dIN[4][2] = 8'd136, dIN[4][3] = 8'd167;
assign dIN[4][4] = 8'd166, dIN[4][5] = 8'd149, dIN[4][6] = 8'd136, dIN[4][7] = 8'd136;

assign dIN[5][0] = 8'd128, dIN[5][1] = 8'd136, dIN[5][2] = 8'd123, dIN[5][3] = 8'd136;
assign dIN[5][4] = 8'd154, dIN[5][5] = 8'd180, dIN[5][6] = 8'd198, dIN[5][7] = 8'd154;

assign dIN[6][0] = 8'd123, dIN[6][1] = 8'd105, dIN[6][2] = 8'd110, dIN[6][3] = 8'd149;
assign dIN[6][4] = 8'd136, dIN[6][5] = 8'd136, dIN[6][6] = 8'd180, dIN[6][7] = 8'd166;

assign dIN[7][0] = 8'd110, dIN[7][1] = 8'd136, dIN[7][2] = 8'd123, dIN[7][3] = 8'd123;
assign dIN[7][4] = 8'd123, dIN[7][5] = 8'd136, dIN[7][6] = 8'd154, dIN[7][7] = 8'd136;

//quantization table in decimal point

assign qtf_50[0][0] = 16'd4096; assign qtf_50[0][1] = 16'd5957; assign qtf_50[0][2] = 16'd6553; assign qtf_50[0][3] = 16'd4096;
assign qtf_50[0][4] = 16'd2730; assign qtf_50[0][5] = 16'd1638; assign qtf_50[0][6] = 16'd1285; assign qtf_50[0][7] = 16'd1074;

assign qtf_50[1][0] = 16'd5461; assign qtf_50[1][1] = 16'd5461; assign qtf_50[1][2] = 16'd4681; assign qtf_50[1][3] = 16'd3449;
assign qtf_50[1][4] = 16'd2520; assign qtf_50[1][5] = 16'd1129; assign qtf_50[1][6] = 16'd1092; assign qtf_50[1][7] = 16'd1191;

assign qtf_50[2][0] = 16'd4681; assign qtf_50[2][1] = 16'd5041; assign qtf_50[2][2] = 16'd4096; assign qtf_50[2][3] = 16'd2730;
assign qtf_50[2][4] = 16'd1638; assign qtf_50[2][5] = 16'd1149; assign qtf_50[2][6] = 16'd949; assign qtf_50[2][7] = 16'd1170;

assign qtf_50[3][0] = 16'd4681; assign qtf_50[3][1] = 16'd3855; assign qtf_50[3][2] = 16'd2978; assign qtf_50[3][3] = 16'd2259;
assign qtf_50[3][4] = 16'd1285; assign qtf_50[3][5] = 16'd753; assign qtf_50[3][6] = 16'd819; assign qtf_50[3][7] = 16'd1057;

assign qtf_50[4][0] = 16'd3640; assign qtf_50[4][1] = 16'd2978; assign qtf_50[4][2] = 16'd1771; assign qtf_50[4][3] = 16'd1170;
assign qtf_50[4][4] = 16'd963; assign qtf_50[4][5] = 16'd601; assign qtf_50[4][6] = 16'd636; assign qtf_50[4][7] = 16'd851;

assign qtf_50[5][0] = 16'd2730; assign qtf_50[5][1] = 16'd1872; assign qtf_50[5][2] = 16'd1191; assign qtf_50[5][3] = 16'd1024;
assign qtf_50[5][4] = 16'd809; assign qtf_50[5][5] = 16'd630; assign qtf_50[5][6] = 16'd579; assign qtf_50[5][7] = 16'd712;

assign qtf_50[6][0] = 16'd1337; assign qtf_50[6][1] = 16'd1024; assign qtf_50[6][2] = 16'd840; assign qtf_50[6][3] = 16'd753;
assign qtf_50[6][4] = 16'd636; assign qtf_50[6][5] = 16'd541; assign qtf_50[6][6] = 16'd546; assign qtf_50[6][7] = 16'd648;

assign qtf_50[7][0] = 16'd910; assign qtf_50[7][1] = 16'd712; assign qtf_50[7][2] = 16'd689; assign qtf_50[7][3] = 16'd668;
assign qtf_50[7][4] = 16'd585; assign qtf_50[7][5] = 16'd655; assign qtf_50[7][6] = 16'd636; assign qtf_50[7][7] = 16'd661;

//quantization table for middle level
assign qt_50[0][0] = 8'd16; assign qt_50[0][1] = 8'd11; assign qt_50[0][2] = 8'd10; assign qt_50[0][3] = 8'd16;
assign qt_50[0][4] = 8'd24; assign qt_50[0][5] = 8'd40; assign qt_50[0][6] = 8'd51; assign qt_50[0][7] = 8'd61;

assign qt_50[1][0] = 8'd12; assign qt_50[1][1] = 8'd12; assign qt_50[1][2] = 8'd14; assign qt_50[1][3] = 8'd19;
assign qt_50[1][4] = 8'd26; assign qt_50[1][5] = 8'd58; assign qt_50[1][6] = 8'd60; assign qt_50[1][7] = 8'd55;

assign qt_50[2][0] = 8'd14; assign qt_50[2][1] = 8'd13; assign qt_50[2][2] = 8'd16; assign qt_50[2][3] = 8'd24;
assign qt_50[2][4] = 8'd40; assign qt_50[2][5] = 8'd57; assign qt_50[2][6] = 8'd69; assign qt_50[2][7] = 8'd56;

assign qt_50[3][0] = 8'd14; assign qt_50[3][1] = 8'd17; assign qt_50[3][2] = 8'd22; assign qt_50[3][3] = 8'd29;
assign qt_50[3][4] = 8'd51; assign qt_50[3][5] = 8'd87; assign qt_50[3][6] = 8'd80; assign qt_50[3][7] = 8'd62;

assign qt_50[4][0] = 8'd18; assign qt_50[4][1] = 8'd22; assign qt_50[4][2] = 8'd37; assign qt_50[4][3] = 8'd56;
assign qt_50[4][4] = 8'd68; assign qt_50[4][5] = 8'd109; assign qt_50[4][6] = 8'd103; assign qt_50[4][7] = 8'd77;

assign qt_50[5][0] = 8'd24; assign qt_50[5][1] = 8'd35; assign qt_50[5][2] = 8'd55; assign qt_50[5][3] = 8'd64;
assign qt_50[5][4] = 8'd81; assign qt_50[5][5] = 8'd104; assign qt_50[5][6] = 8'd113; assign qt_50[5][7] = 8'd92;

assign qt_50[6][0] = 8'd49; assign qt_50[6][1] = 8'd64; assign qt_50[6][2] = 8'd78; assign qt_50[6][3] = 8'd87;
assign qt_50[6][4] = 8'd103; assign qt_50[6][5] = 8'd121; assign qt_50[6][6] = 8'd120; assign qt_50[6][7] = 8'd101;

assign qt_50[7][0] = 8'd72; assign qt_50[7][1] = 8'd92; assign qt_50[7][2] = 8'd95; assign qt_50[7][3] = 8'd98;
assign qt_50[7][4] = 8'd112; assign qt_50[7][5] = 8'd100; assign qt_50[7][6] = 8'd103; assign qt_50[7][7] = 8'd99;

// DCT Coefficient

assign T[0][0] = 17'd23173;assign T[0][1] = 17'd23173;assign T[0][2] = 17'd23173;assign T[0][3] = 17'd23173;
assign T[0][4] = 17'd23173;assign T[0][5] = 17'd23173;assign T[0][6] = 17'd23173;assign T[0][7] = 17'd23173;

assign T[1][0] = 17'd32138;assign T[1][1] = 17'd27243;assign T[1][2] = 17'd18205;assign T[1][3] = 17'd6389;
assign T[1][4] = -(17'd6389);assign T[1][5] = -(17'd18205);assign T[1][6] = -(17'd27243);assign T[1][7] = -(17'd32138);

assign T[2][0] = 17'd30271;assign T[2][1] = 17'd12537;assign T[2][2] = -(17'd12537);assign T[2][3] = -(17'd30271);
assign T[2][4] = -(17'd30271);assign T[2][5] = -(17'd12537);assign T[2][6] = 17'd12537;assign T[2][7] = 17'd30271;

assign T[3][0] = 17'd27243;assign T[3][1] = -(17'd6389);assign T[3][2] = -(17'd32138);assign T[3][3] = -(17'd18205);
assign T[3][4] = 17'd18205;assign T[3][5] = 17'd32138;assign T[3][6] = 17'd6389;assign T[3][7] = -(17'd27243);

assign T[4][0] = 17'd23173;assign T[4][1] = -(17'd23173);assign T[4][2] = -(17'd23173);assign T[4][3] = 17'd23173;
assign T[4][4] = 17'd23173;assign T[4][5] = -(17'd23173);assign T[4][6] = -(17'd23173);assign T[4][7] = 17'd23173;

assign T[5][0] = 17'd18205;assign T[5][1] = -(17'd32138);assign T[5][2] = 17'd6389;assign T[5][3] = 17'd27243;
assign T[5][4] = -(17'd27243);assign T[5][5] = -(17'd6389);assign T[5][6] = 17'd32138;assign T[5][7] = -(17'd18205);

assign T[6][0] = 17'd12537;assign T[6][1] = -(17'd30271);assign T[6][2] = 17'd30271;assign T[6][3] = -(17'd12537);
assign T[6][4] = -(17'd12537);assign T[6][5] = 17'd30271;assign T[6][6] = -(17'd30271);assign T[6][7] = 17'd12537;

assign T[7][0] = 17'd6389;assign T[7][1] = -(17'd18205);assign T[7][2] = 17'd27243;assign T[7][3] = -(17'd32138);
assign T[7][4] = 17'd32138;assign T[7][5] = -(17'd27243);assign T[7][6] = 17'd18205;assign T[7][7] = -(17'd6389);

//DCT coefficient (transpose)

assign T_t[0][0] = 17'd23173;assign T_t[1][0] = 17'd23173;assign T_t[2][0] = 17'd23173;assign T_t[3][0] = 17'd23173;
assign T_t[4][0] = 17'd23173;assign T_t[5][0] = 17'd23173;assign T_t[6][0] = 17'd23173;assign T_t[7][0] = 17'd23173;

assign T_t[0][1] = 17'd32138;assign T_t[1][1] = 17'd27243;assign T_t[2][1] = 17'd18205;assign T_t[3][1] = 17'd6389;
assign T_t[4][1] = -(17'd6389);assign T_t[5][1] = -(17'd18205);assign T_t[6][1] = -(17'd27243);assign T_t[7][1] = -(17'd32138);

assign T_t[0][2] = 17'd30271;assign T_t[1][2] = 17'd12537;assign T_t[2][2] = -(17'd12537);assign T_t[3][2] = -(17'd30271);
assign T_t[4][2] = -(17'd30271);assign T_t[5][2] = -(17'd12537);assign T_t[6][2] = 17'd12537;assign T_t[7][2] = 17'd30271;

assign T_t[0][3] = 17'd27243;assign T_t[1][3] = -(17'd6389);assign T_t[2][3] = -(17'd32138);assign T_t[3][3] = -(17'd18205);
assign T_t[4][3] = 17'd18205;assign T_t[5][3] = 17'd32138;assign T_t[6][3] = 17'd6389;assign T_t[7][3] = -(17'd27243);

assign T_t[0][4] = 17'd23173;assign T_t[1][4] = -(17'd23173);assign T_t[2][4] = -(17'd23173);assign T_t[3][4] = 17'd23173;
assign T_t[4][4] = 17'd23173;assign T_t[5][4] = -(17'd23173);assign T_t[6][4] = -(17'd23173);assign T_t[7][4] = 17'd23173;

assign T_t[0][5] = 17'd18205;assign T_t[1][5] = -(17'd32138);assign T_t[2][5] = 17'd6389;assign T_t[3][5] = 17'd27243;
assign T_t[4][5] = -(17'd27243);assign T_t[5][5] = -(17'd6389);assign T_t[6][5] = 17'd32138;assign T_t[7][5] = -(17'd18205);

assign T_t[0][6] = 17'd12537;assign T_t[1][6] = -(17'd30271);assign T_t[2][6] = 17'd30271;assign T_t[3][6] = -(17'd12537);
assign T_t[4][6] = -(17'd12537);assign T_t[5][6] = 17'd30271;assign T_t[6][6] = -(17'd30271);assign T_t[7][6] = 17'd12537;

assign T_t[0][7] = 17'd6389;assign T_t[1][7] = -(17'd18205);assign T_t[2][7] = 17'd27243;assign T_t[3][7] = -(17'd32138);
assign T_t[4][7] = 17'd32138;assign T_t[5][7] = -(17'd27243);assign T_t[6][7] = 17'd18205;assign T_t[7][7] = -(17'd6389);

always@(posedge CLOCK_50)begin
	case(state)
		4'd0: begin //Normalize
					if(j<8)begin
						if(i<8)begin
							normalize(dIN[j][i],dataIn[j][i]);
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd1; end end
		4'd1: begin // dataOut = T*dataIn
					if(j<8)begin
						if(i<8)begin
							matrixMultiply(T[j][0],T[j][1],T[j][2],T[j][3],T[j][4],T[j][5],T[j][6],T[j][7],dataIn[0][i],dataIn[1][i],dataIn[2][i],dataIn[3][i],dataIn[4][i],dataIn[5][i],dataIn[6][i],dataIn[7][i],dataOut[j][i]);
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd2; end end
		4'd2: begin //DCT result
					if(j<8)begin
						if(i<8)begin
							matrixMultiply(dataOut[j][0],dataOut[j][1],dataOut[j][2],dataOut[j][3],dataOut[j][4],dataOut[j][5],dataOut[j][6],dataOut[j][7],T_t[0][i],T_t[1][i],T_t[2][i],T_t[3][i],T_t[4][i],T_t[5][i],T_t[6][i],T_t[7][i],DCT_out[j][i]);
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd3; end end
		4'd3: begin //Quantization
					if(j<8)begin
						if(i<8)begin
							quantization(DCT_out[j][i][43:16],qtf_50[j][i],q_result[j][i]);
							if(q_result[j][i][31] == 1)begin
								q_result[j][i][43:32] = q_result[j][i][43:32] + 12'b1;
							end
							q_result[j][i] = q_result[j][i] >> 32;
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd4; end end
		4'd4: begin //Zig-Zag
            dataIn[0][0] = q_result[0][0]; dataIn[0][1] = q_result[0][1]; dataIn[0][2] = q_result[1][0]; dataIn[0][3] = q_result[2][0];
            dataIn[0][4] = q_result[1][1]; dataIn[0][5] = q_result[0][2]; dataIn[0][6] = q_result[0][3]; dataIn[0][7] = q_result[1][2];
            dataIn[1][0] = q_result[2][1]; dataIn[1][1] = q_result[3][0]; dataIn[1][2] = q_result[4][0]; dataIn[1][3] = q_result[3][1];
            dataIn[1][4] = q_result[2][2]; dataIn[1][5] = q_result[1][3]; dataIn[1][6] = q_result[0][4]; dataIn[1][7] = q_result[0][5];
            dataIn[2][0] = q_result[1][4]; dataIn[2][1] = q_result[2][3]; dataIn[2][2] = q_result[3][2]; dataIn[2][3] = q_result[4][1];
            dataIn[2][4] = q_result[5][0]; dataIn[2][5] = q_result[6][0]; dataIn[2][6] = q_result[5][1]; dataIn[2][7] = q_result[4][2];
            dataIn[3][0] = q_result[3][3]; dataIn[3][1] = q_result[2][4]; dataIn[3][2] = q_result[1][5]; dataIn[3][3] = q_result[0][6];
            dataIn[3][4] = q_result[0][7]; dataIn[3][5] = q_result[1][6]; dataIn[3][6] = q_result[2][5]; dataIn[3][7] = q_result[3][4];
            dataIn[4][0] = q_result[4][3]; dataIn[4][1] = q_result[5][2]; dataIn[4][2] = q_result[6][1]; dataIn[4][3] = q_result[7][0];
            dataIn[4][4] = q_result[7][1]; dataIn[4][5] = q_result[6][2]; dataIn[4][6] = q_result[5][3]; dataIn[4][7] = q_result[4][4];
            dataIn[5][0] = q_result[3][5]; dataIn[5][1] = q_result[2][6]; dataIn[5][2] = q_result[1][7]; dataIn[5][3] = q_result[2][7];
            dataIn[5][4] = q_result[3][6]; dataIn[5][5] = q_result[4][5]; dataIn[5][6] = q_result[5][4]; dataIn[5][7] = q_result[6][3];
            dataIn[6][0] = q_result[7][2]; dataIn[6][1] = q_result[7][3]; dataIn[6][2] = q_result[6][4]; dataIn[6][3] = q_result[5][5];
            dataIn[6][4] = q_result[4][6]; dataIn[6][5] = q_result[3][7]; dataIn[6][6] = q_result[4][7]; dataIn[6][7] = q_result[5][6];
            dataIn[7][0] = q_result[6][5]; dataIn[7][1] = q_result[7][4]; dataIn[7][2] = q_result[7][5]; dataIn[7][3] = q_result[6][6];
            dataIn[7][4] = q_result[5][7]; dataIn[7][5] = q_result[6][7]; dataIn[7][6] = q_result[7][6]; dataIn[7][7] = q_result[7][7];
            state = 4'd5; end
		4'd5: begin //RunLength
					if(j<8) begin
						if(i<8) begin
							if(dataIn[j][i] == 0)
								begin zeroCount = zeroCount + 1; i = i+4'b1; end
							else begin
								if(zeroes_16 >0)begin
									zeroes_16 = zeroes_16 - 1;
									RLcode[k] = 15; k=k+1;
									RLcode[k] = 0; k=k+1;
								end
								else begin
									RLcode[k] = zeroCount; k = k+1; zeroCount = 0; RLcode[k] = dataIn[j][i]; k = k+1; i = i+4'b1;
								end
							end
							if(zeroCount > 15) begin
								zeroes_16 = zeroes_16 + 1; zeroCount = 0;
							end
						end
						else
							begin i = 4'b0; j = j+4'b1; end
					end
					else begin i = 4'b0; j = 4'b0; state = 4'd6; temp_k = k; k = 0; zeroCount = 0; end   
				end
		4'd6: begin
            dataIn[0][0] =  0; dataIn[0][1] =  0; dataIn[0][2] =  0; dataIn[0][3] =  0;
            dataIn[0][4] =  0; dataIn[0][5] =  0; dataIn[0][6] =  0; dataIn[0][7] =  0;
            dataIn[1][0] =  0; dataIn[1][1] =  0; dataIn[1][2] =  0; dataIn[1][3] =  0;
            dataIn[1][4] =  0; dataIn[1][5] =  0; dataIn[1][6] =  0; dataIn[1][7] =  0;
            dataIn[2][0] =  0; dataIn[2][1] =  0; dataIn[2][2] =  0; dataIn[2][3] =  0;
            dataIn[2][4] =  0; dataIn[2][5] =  0; dataIn[2][6] =  0; dataIn[2][7] =  0;
            dataIn[3][0] =  0; dataIn[3][1] =  0; dataIn[3][2] =  0; dataIn[3][3] =  0;
            dataIn[3][4] =  0; dataIn[3][5] =  0; dataIn[3][6] =  0; dataIn[3][7] =  0;
            dataIn[4][0] =  0; dataIn[4][1] =  0; dataIn[4][2] =  0; dataIn[4][3] =  0;
            dataIn[4][4] =  0; dataIn[4][5] =  0; dataIn[4][6] =  0; dataIn[4][7] =  0;
            dataIn[5][0] =  0; dataIn[5][1] =  0; dataIn[5][2] =  0; dataIn[5][3] =  0;
            dataIn[5][4] =  0; dataIn[5][5] =  0; dataIn[5][6] =  0; dataIn[5][7] =  0;
            dataIn[6][0] =  0; dataIn[6][1] =  0; dataIn[6][2] =  0; dataIn[6][3] =  0;
            dataIn[6][4] =  0; dataIn[6][5] =  0; dataIn[6][6] =  0; dataIn[6][7] =  0;
            dataIn[7][0] =  0; dataIn[7][1] =  0; dataIn[7][2] =  0; dataIn[7][3] =  0;
            dataIn[7][4] =  0; dataIn[7][5] =  0; dataIn[7][6] =  0; dataIn[7][7] =  0;
				state = 4'd7; end
		4'd7: begin //
					if(zeroCount > 0)begin
					  dataIn[j][i] = 0; i = i+4'b1; zeroCount = zeroCount - 1; end
					else begin
					  if(k<temp_k) begin
						 if(run == 1'b0)begin //come to check run
							zeroCount = RLcode[k]; k = k+1; run = 1'b1;
						 end
						 else if(run == 1'b1)begin  //come to check symbol
							dataIn[j][i] = RLcode[k];
							run = 1'b0; k = k + 1; i = i+4'b1;
						 end
					  end
					  else begin
						state = 4'd8; LEDR[8]=1'b1; i = 4'b0; j = 4'b0;end
					end
								 
					if(j<8) begin
						if(i>7) begin
							i = 4'b0; j = j+4'b1;
						end
					end
				end
		4'd8: begin // De Zig Zag
            q_result[0][0] = dataIn[0][0]; q_result[0][1] = dataIn[0][1]; q_result[1][0] = dataIn[0][2]; q_result[2][0] = dataIn[0][3];
            q_result[1][1] = dataIn[0][4]; q_result[0][2] = dataIn[0][5]; q_result[0][3] = dataIn[0][6]; q_result[1][2] = dataIn[0][7];
            q_result[2][1] = dataIn[1][0]; q_result[3][0] = dataIn[1][1]; q_result[4][0] = dataIn[1][2]; q_result[3][1] = dataIn[1][3];
            q_result[2][2] = dataIn[1][4]; q_result[1][3] = dataIn[1][5]; q_result[0][4] = dataIn[1][6]; q_result[0][5] = dataIn[1][7];
            q_result[1][4] = dataIn[2][0]; q_result[2][3] = dataIn[2][1]; q_result[3][2] = dataIn[2][2]; q_result[4][1] = dataIn[2][3];
            q_result[5][0] = dataIn[2][4]; q_result[6][0] = dataIn[2][5]; q_result[5][1] = dataIn[2][6]; q_result[4][2] = dataIn[2][7];
            q_result[3][3] = dataIn[3][0]; q_result[2][4] = dataIn[3][1]; q_result[1][5] = dataIn[3][2]; q_result[0][6] = dataIn[3][3];
            q_result[0][7] = dataIn[3][4]; q_result[1][6] = dataIn[3][5]; q_result[2][5] = dataIn[3][6]; q_result[3][4] = dataIn[3][7];
            q_result[4][3] = dataIn[4][0]; q_result[5][2] = dataIn[4][1]; q_result[6][1] = dataIn[4][2]; q_result[7][0] = dataIn[4][3];
            q_result[7][1] = dataIn[4][4]; q_result[6][2] = dataIn[4][5]; q_result[5][3] = dataIn[4][6]; q_result[4][4] = dataIn[4][7];
            q_result[3][5] = dataIn[5][0]; q_result[2][6] = dataIn[5][1]; q_result[1][7] = dataIn[5][2]; q_result[2][7] = dataIn[5][3];
            q_result[3][6] = dataIn[5][4]; q_result[4][5] = dataIn[5][5]; q_result[5][4] = dataIn[5][6]; q_result[6][3] = dataIn[5][7];
            q_result[7][2] = dataIn[6][0]; q_result[7][3] = dataIn[6][1]; q_result[6][4] = dataIn[6][2]; q_result[5][5] = dataIn[6][3];
            q_result[4][6] = dataIn[6][4]; q_result[3][7] = dataIn[6][5]; q_result[4][7] = dataIn[6][6]; q_result[5][6] = dataIn[6][7];
            q_result[6][5] = dataIn[7][0]; q_result[7][4] = dataIn[7][1]; q_result[7][5] = dataIn[7][2]; q_result[6][6] = dataIn[7][3];
            q_result[5][7] = dataIn[7][4]; q_result[6][7] = dataIn[7][5]; q_result[7][6] = dataIn[7][6]; q_result[7][7] = dataIn[7][7];
				state = 4'd9; end
		4'd9: begin //de-Quantization
					if(j<8)begin
						if(i<8)begin
							dequantization(q_result[j][i],qt_50[j][i], dataIn[j][i]);
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd10; end end
		4'd10: begin //IDCT 1st MUL
					if(j<8)begin
						if(i<8)begin
							matrixMultiply(T_t[j][0],T_t[j][1],T_t[j][2],T_t[j][3],T_t[j][4],T_t[j][5],T_t[j][6],T_t[j][7],dataIn[0][i],dataIn[1][i],dataIn[2][i],dataIn[3][i],dataIn[4][i],dataIn[5][i],dataIn[6][i],dataIn[7][i],dataOut[j][i]);
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd11; end end
		4'd11: begin //IDCT result
					if(j<8)begin
						if(i<8)begin
							matrixMultiply(dataOut[j][0],dataOut[j][1],dataOut[j][2],dataOut[j][3],dataOut[j][4],dataOut[j][5],dataOut[j][6],dataOut[j][7],T[0][i],T[1][i],T[2][i],T[3][i],T[4][i],T[5][i],T[6][i],T[7][i],DCT_out[j][i]);
							d_Out[j][i][31:0] = DCT_out[j][i][63:0]>>32;
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd12; end end
		4'd12: begin //denormalize
					if(j<8)begin
						if(i<8)begin
							denormalize(d_Out[j][i][11:0],dataIn[j][i]);
							i = i+4'b1; end
						else begin i = 4'b0; j = j+4'b1; end
					end else begin i = 4'b0; j = 4'b0; state = 4'd13; end 
				 end
		default: begin if(counter==count) begin LEDR[9]=~LEDR[9]; counter =0; state = 4'd13; end else counter=counter+1; end
	endcase
	LEDR[4:0] = 5'd0;
	LEDR[8:5] = state[3:0];
	//LEDR[3:0] = DCT_out[SW[5:3]][SW[2:0]][43:40];
	//dispDecoder(DCT_out[SW[5:3]][SW[2:0]][19:16],HEX0);
	//dispDecoder(DCT_out[SW[5:3]][SW[2:0]][23:20],HEX1);
	//dispDecoder(DCT_out[SW[5:3]][SW[2:0]][27:24],HEX2);
	//dispDecoder(DCT_out[SW[5:3]][SW[2:0]][31:28],HEX3);
	//dispDecoder(DCT_out[SW[5:3]][SW[2:0]][35:32],HEX4);
	//dispDecoder(DCT_out[SW[5:3]][SW[2:0]][39:36],HEX5);
	//LEDR[3:0] = q_result[SW[5:3]][SW[2:0]][27:24];
	//LEDR[3:0] = d_Out[SW[5:3]][SW[2:0]][31:28];
	//dispDecoder(d_Out[SW[5:3]][SW[2:0]][27:24],HEX5);
	//dispDecoder(d_Out[SW[5:3]][SW[2:0]][7:4],HEX0);
	//dispDecoder(d_Out[SW[5:3]][SW[2:0]][11:8],HEX1);
	//dispDecoder(d_Out[SW[5:3]][SW[2:0]][15:12],HEX2);
	//dispDecoder(d_Out[SW[5:3]][SW[2:0]][19:16],HEX3);
	//dispDecoder(d_Out[SW[5:3]][SW[2:0]][23:20],HEX4);
	dispDecoder(dataIn[SW[5:3]][SW[2:0]][3:0],HEX0);
	dispDecoder(dataIn[SW[5:3]][SW[2:0]][7:4],HEX1);
	dispDecoder(dIN[SW[5:3]][SW[2:0]][3:0],HEX2);
	dispDecoder(dIN[SW[5:3]][SW[2:0]][7:4],HEX3);
	//dispDecoder(q_result[SW[5:3]][SW[2:0]][19:16],HEX0);
	//dispDecoder(q_result[SW[5:3]][SW[2:0]][23:20],HEX1);
	//dispDecoder(q_result[SW[5:3]][SW[2:0]][27:24],HEX2);
	//dispDecoder(q_result[SW[5:3]][SW[2:0]][31:28],HEX3);
	//dispDecoder(q_result[SW[5:3]][SW[2:0]][35:32],HEX4);
	//dispDecoder(q_result[SW[5:3]][SW[2:0]][39:36],HEX5);
	//LEDR[3:0] = q_result[SW[5:3]][SW[2:0]][43:40];
	//dispDecoder(RLcode[SW[7:0]][3:0],HEX0);
	//dispDecoder(RLcode[SW[7:0]][7:4],HEX1);
	//dispDecoder(RLcode[SW[7:0]][11:8],HEX2);
end

task dispDecoder(
	input [3:0] dispVal,
	output reg [6:0] LED
);
/* LED diagram ("1"->Off, "0"->On)
		a
	f		b
		g
	e		c
		d
*/
	casex(dispVal)
		4'b0000: LED = 7'b1000000; //0
		4'b0001: LED = 7'b1111001; //1
		4'b0010: LED = 7'b0100100; //2
		4'b0011: LED = 7'b0110000; //3
		4'b0100: LED = 7'b0011001; //4
		4'b0101: LED = 7'b0010010; //5
		4'b0110: LED = 7'b0000010; //6
		4'b0111: LED = 7'b1111000; //7
		4'b1000: LED = 7'b0000000; //8
		4'b1001: LED = 7'b0011000; //9
		4'b1010: LED = 7'b0001000; //A
		4'b1011: LED = 7'b0000011; //B
		4'b1100: LED = 7'b0100111; //C
		4'b1101: LED = 7'b0100001; //D
		4'b1110: LED = 7'b0000110; //E
		4'b1111: LED = 7'b0001110; //F
	endcase

endtask

task normalize(
	input unsigned [7:0] A1,
	output signed [11:0] B1
);

	B1 = A1 - 8'd128;
endtask

task denormalize(
	input unsigned [11:0] A1,
	output signed [11:0] B1
);

	B1 = A1 + 8'd128;
endtask

task matrixMultiply(
	input signed [31:0] A1, A2, A3, A4, A5, A6, A7, A8,
	input signed [31:0] B1, B2, B3, B4, B5, B6, B7, B8,
	output signed [63:0] d_out
);

	d_out = (A1*B1) + (A2*B2) + (A3*B3) + (A4*B4) + (A5*B5) + (A6*B6) + (A7*B7) + (A8*B8); 

endtask

task quantization(
	input signed [27:0] A1,
	input signed [16:0] B1,
	output signed [63:0] quantize_result
);
	quantize_result = A1*B1;
endtask

task dequantization(
	input signed [11:0] A1,
	input signed [8:0] B1,
	output signed [31:0] dequantize_result
);
	dequantize_result = A1*B1;
endtask
endmodule

