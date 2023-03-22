module m_2x2_rtl(F, W, Res, clk, rst_n);

    //input and output ports.
    //The size 32 bits which is 2*2=4 elements,each of which is 8 bits wide.    
    input clk;
    input rst_n;	
    input [2879:0] F;
    input [1439:0] W;
    output reg [305:0] Res;
    //internal variables    
    reg [4:0] F1 [0:95][0:2]; 
	reg [4:0] F2 [0:95][0:2]; 
    reg [4:0] W1 [0:95][0:2];
    reg [16:0] Res1 [0:2][0:2]; 
	reg [16:0] Res2 [0:2][0:2]; 
	
	reg [1439:0] FU ;
	reg [1439:0] FD ;
	reg [1439:0] WD  ;
	always@ (posedge clk or negedge rst_n) begin
		//flag_data
		if (!rst_n) begin
			FU   <= 1440'd0;
			FD   <= 1440'd0 ;
			WD   <= 1440'd0 ;
		end else begin
			FU   <= F[2879:1440] ; //
			FD   <= F[1439:0] ;
			WD   <= W ;
		end
	end
	
	
	reg f1_data_in ;
	reg [6:0] x1 ; // 0,1,2,...95
	reg [1:0] x2 ; // 0,1,2
	always@ (posedge clk or negedge rst_n) begin
		//flag_data
		if (!rst_n) begin
			f1_data_in <= 1'd0;
		// end else if () begin                //need ?
			// f1_data_in <= 1'd0;
		end else if ((FU||FD||WD != 1440'd0)) begin //change?	
			f1_data_in <= 1'd1;	
		end else begin
			f1_data_in <= f1_data_in ;
		end
	end
	
	always@ (posedge clk or negedge rst_n) begin 
	//counter_x1 for input 1d to 2d: row =96
		if (!rst_n) begin
			x1 <= 7'd0;
		end else if (x1==7'd95 && x2==2'd2) begin
			x1 <= x1;
		end else if (x1==7'd95) begin
			x1 <= 7'd0;
		end else if (f1_data_in) begin
			x1 <= x1 + 7'd1;
		end else begin
			x1 <= x1;
		end
	end
	
	always@ (posedge clk or negedge rst_n) begin //can be combine with x1?
	//counter_x2 for input 1d to 2d: colu =3
		if (!rst_n) begin
			x2 <= 2'd0;
		end else if (x2==2'd2) begin
			x2 <= x2;
		end else if (f1_data_in) begin
			x2 <= x2 + 2'd1;
		end else begin
			x2 <= x2;
		end
	end

	//Initialize the matrices-convert 1 D to 2D arrays
	always@ (x1 or x2) begin // lost 1st ?
			F1[x1][x2]  <= FU[4:0] ; //LSB
			FU 			<= {5'd0,FU[1439:5]} ;																
			F2[x1][x2]  <= FD[4:0] ; //LSB
			FD 			<= {5'd0,FD[1439:5]} ;
			W1[x1][x2]  <= WD[4:0] ;	
			WD 		<= {5'd0, WD[1439:5]} ;
			Res1[x1][x2]<= 17'd0 ;	
			Res2[x1][x2]<= 17'd0 ;
	end
	
	
	//test
    //always@ (posedge clk or negedge rst_n) begin
	////Initialize the matrices-convert 1 D to 3D arrays
		//if (!rst_n) begin
		//	{F1[0][0],F1[0][1],F1[1][0],F1[1][1]} <= 32'd0;
		//	{W1[0][0],W1[0][1],W1[1][0],W1[1][1]} <= 32'd0;
		//	{Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} <= 32'd0; //??
		//end else begin
		//	{F1[0][0],F1[0][1],F1[1][0],F1[1][1]} <= F ;
		//	{W1[0][0],W1[0][1],W1[1][0],W1[1][1]} <= W ;
		//	{Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} <= {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} ;
		//end
	//end
	
	reg f2_data_packed ;
	always@ (posedge clk or negedge rst_n) begin
		//flag_packed
		if (!rst_n) begin
			f2_data_packed 	<= 1'd0;
		end else if ( ((F1[95][2]) || F1[95][2] || (W1[95][2])) != 8'd0) begin //need to change?
			f2_data_packed 	<= 1'd1;	
		end else begin
			f2_data_packed 	<= f2_data_packed ;
		end
	end


	// always@ (posedge clk or negedge rst_n) begin 
	////counter_x1 for input 1d to 2d: row =96
		// if (!rst_n) begin
			// x1 <= 2'd0;
		// end else if (x1==7'd95 && x2==2'd2) begin
			// x1 <= x1;
		// end else if (x1==7'd95) begin
			// x1 <= 7'd0;
		// end else if (f1_data_in) begin
			// x1 <= x1 + 2'd1;
		// end else begin
			// x1 <= x1;
		// end
	// end
	
	// always@ (posedge clk or negedge rst_n) begin //can be combine with x1?
	////counter_x2 for input 1d to 2d: colu =3
		// if (!rst_n) begin
			// x2 <= 2'd0;
		// end else if (x2==2'd2) begin
			// x2 <= x2;
		// end else if (f1_data_in) begin
			// x2 <= x2 + 2'd1;
		// end else begin
			// x2 <= x2;
		// end
	// end
	
	
	reg [6:0] y1 ; // 0,1, 2, ... 7   //can definity combine with counter x
	reg [1:0] y2 ;
	always@ (posedge clk or negedge rst_n) begin
	//counter_y1 for multiplication
		if (!rst_n) begin
			y1 <= 3'd0;
		end else if (y1==7'd95&& y2==2'd2) begin
			y1 <= y1;
		end else if (y1==7'd95) begin
			y1 <= 7'd0;
		end else if (f2_data_packed) begin
			y1 <= y1 + 3'd1;
		end else begin
			y1 <= y1 ;
		end
	end
	
	
	always@ (posedge clk or negedge rst_n) begin //can be combine with x1?
	//counter_y2 for input 1d to 2d: colu =3
		if (!rst_n) begin
			y2 <= 2'd0;
		end else if (y2==2'd2) begin
			y2 <= y2;
		end else if (y1==7'd95) begin
			y2 <= y2 + 2'd1;
		end else begin
			y2 <= y2;
		end
	end
	
	reg [1:0] y3 ;
	always@ (posedge clk or negedge rst_n) begin //can be combine with x1?
	//counter_y2 for input 1d to 2d: colu =3
		if (!rst_n) begin
			y3 <= 2'd0;
		end else if (y3==2'd2) begin
			y3 <= y3;
		end else if (y2==2'd2) begin
			y3 <= y2 + 2'd1;
		end else begin
			y3 <= y3;
		end
	end
	
	reg [2:0] y1_d1 ;
	reg [2:0] y2_d1 ;
	always@(posedge clk or negedge rst_n)begin
		if (!rst_n) begin
			y1_d1 <= 3'd0;
			y2_d1 <= 3'd0;
		end else begin	
			y1_d1 <= y1;  
			y2_d1 <= y2;
		end
	end
	
	reg y1_done ;
	reg y1_done_d1 ;
	always@ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			y1_done 	<= 1'd0;
			y1_done_d1   <= 1'd0;
		end else if (y1==7'd95) begin
			y1_done 	<= 1'd1;
			y1_done_d1  <= y1_done;
		end else begin
			y1_done 	<= y1_done ;
			y1_done_d1  <= y1_done_d1; //need?
		end
	end	
	
    always@(y1 or y1_d1)begin
		if (y1_done_d1) begin
			Res1[y3][y2] <= Res1[y3][y2]  ; 
			Res2[y3][y2] <= Res1[y3][y2]  ;
		end else begin	
			Res1[y3][y2] <= Res1[y3][y2] + (F1[y1][y3] * W1[y1][y2]);   //?
			Res2[y3][y2] <= Res2[y3][y2] + (F2[y1][y3] * W1[y1][y2]); 
		end
	end
	
	reg [6:0] z1 ;
	reg [1:0] z2 ; 
	always@ (posedge clk or negedge rst_n) begin //can combine with counter x?
	//counter_Z1 for output 2d to 1d
		if (!rst_n) begin
			z1 <= 2'd0;
		end else if (y1==7'd95&& y2==2'd2) begin
			z1 <= z1;
		end else if (y1==7'd95) begin
			z1 <= 7'd0;
		end else if (y1_done_d1) begin
			z1 <= z1 + 2'd1;
		end else begin
			z1 <= z1 ;
		end
	end
	
	always@ (posedge clk or negedge rst_n) begin //can be combine with x1?
	//counter_z2 for input 1d to 2d: colu =3
		if (!rst_n) begin
			z2 <= 2'd0;
		end else if (z2==2'd2) begin
			z2 <= z2;
		end else if (y1_done_d1) begin
			z2 <= z2 + 2'd1;
		end else begin
			z2 <= z2;
		end
	end
	
	reg [2:0] z1_d1 ;
	reg [2:0] z2_d1 ;
	always@(posedge clk or negedge rst_n)begin
		if (!rst_n) begin
			z1_d1<= 3'd0;
			z2_d1 <= 3'd0;
		end else begin	
			z1_d1 <= z1;  
			z2_d1 <= z2;
		end
	end
	

	reg [305:0] Res_pre ;
    always@ (z1 or z1_d1) begin
			Res_pre <= {Res_pre[305:0], Res1[z1_d1][z2_d1]} ; //Res2?                    
	end

    always@(posedge clk or negedge rst_n)begin
		if (!rst_n) begin
			Res <= 306'd0 ;
		end else begin	
			Res <= Res_pre;  
		end
	end

	//output test
    // always@(posedge clk or negedge rst_n)begin
		// if (!rst_n) begin
			// Res <= 32'd0 ;
		// end else begin	
			// Res <= {Res1[0][0], Res1[0][1], Res1[1][0], Res1[1][1]};  
		// end
	// end

endmodule