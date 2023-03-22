module m_2x2_rtl(A, B, Res, clk, rst_n);

    //input and output ports.
    //The size 32 bits which is 2*2=4 elements,each of which is 8 bits wide.    
    input clk;
    input rst_n;	
    input [31:0] A;
    input [31:0] B;
    output reg [31:0] Res;
    //internal variables    
    reg [7:0] A1 [0:1][0:1];
    reg [7:0] B1 [0:1][0:1];
    reg [7:0] Res1 [0:1][0:1]; 

	reg f1_data_in ;
	reg [1:0] y ; // 0,1,2,3
	always@ (posedge clk or negedge rst_n) begin
		//flag_data
		if (!rst_n) begin
			f1_data_in <= 1'd0;
		end else if (&y) begin                      //need ?
			f1_data_in <= 1'd0;
		end else if ( (A||B) != 32'd0 ) begin
			f1_data_in <= 1'd1;	
		end else begin
			f1_data_in <= f1_data_in ;
		end
	end
	
	always@ (posedge clk or negedge rst_n) begin 
	//counter_y for input 1d to 2d
		if (!rst_n) begin
			y <= 2'd0;
		end else if (&y) begin
			y <= y;
		end else if (f1_data_in) begin
			y <= y + 2'd1;
		end else begin
			y <= y;
		end
	end


	wire i1 = y[1] ;
	wire j1 = y[0] ;
	wire [1:0] noty = ~y ;
	always@ (posedge clk or negedge rst_n) begin
	//Initialize the matrices-convert 1 D to 3D arrays
		if (!rst_n) begin
			A1[i1][j1]   <= 8'd0 ;
			B1[i1][j1]   <= 8'd0 ;
			Res1[i1][j1] <= 8'd0 ;
		end else if (f1_data_in) begin
		//The left number is always the starting index. 
		//The right number is the width, so must be a positive constant. 
		//The + and - indicates to select the bits of a higher or lower index value then the starting index.
			A1[i1][j1]   <= A[8*(noty)+7 -:8] ; //MSB
			B1[i1][j1]   <= B[8*(noty)+7 -:8] ;	
			Res1[i1][j1] <= 8'd0 ;
		end else begin
			A1[i1][j1]   <=  A1[i1][j1]   ;
			B1[i1][j1]   <=  B1[i1][j1]   ;
			Res1[i1][j1] <=  Res1[i1][j1] ;
		end		
	end
	
	//test
    //always@ (posedge clk or negedge rst_n) begin
	////Initialize the matrices-convert 1 D to 3D arrays
	//if (!rst_n) begin
	//	{A1[0][0],A1[0][1],A1[1][0],A1[1][1]} <= 32'd0;
	//	{B1[0][0],B1[0][1],B1[1][0],B1[1][1]} <= 32'd0;
	//	{Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} <= 32'd0; //??
	//end else begin
	//	{A1[0][0],A1[0][1],A1[1][0],A1[1][1]} <= A ;
	//	{B1[0][0],B1[0][1],B1[1][0],B1[1][1]} <= B ;
	//	{Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} <= {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} ;
	//end
	//end
	
	reg f2_data_packed ;
	always@ (posedge clk or negedge rst_n) begin
		//flag_packed
		if (!rst_n) begin
			f2_data_packed 	<= 1'd0;
		end else if ( ((A1[1][1]) || (B1[1][1])) != 8'd0) begin //need to change
			f2_data_packed 	<= 1'd1;	
		end else begin
			f2_data_packed 	<= f2_data_packed ;
		end
	end


	reg [2:0] x ; // 0,1, 2, ... 7
	always@ (posedge clk or negedge rst_n) begin
	//counter_x for multiplication
		if (!rst_n) begin
			x <= 3'd0;
		end else if (&x) begin
			x <= x;
		end else if (f2_data_packed) begin
			x <= x + 3'd1;
		end else begin
			x <= x ;
		end
	end
	
	reg [2:0] x_d1 ;
	always@(posedge clk or negedge rst_n)begin
		if (!rst_n) begin
			x_d1 <= 3'd0;
		end else begin	
			x_d1 <= x;  
		end
	end
	
	reg x_done ;
	reg x_done_d1 ;
	always@ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			x_done 	   <= 1'd0;
			x_done_d1  <= 1'd0;
		end else if (&x) begin
			x_done <= 1'd1;
			x_done_d1  <= x_done;
		end else begin
			x_done 	   <= x_done ;
			x_done_d1  <= x_done_d1; //need?
		end
	end	
	
	wire i = x_d1[0] ;
	wire j = x_d1[1] ;
	wire k = x_d1[2] ;
    always@(x or x_d1)begin
		if (x_done_d1) begin
			Res1[i][j] <= Res1[i][j]  ; //A1[i][k] * B1[k][j]
		end else begin	
			Res1[i][j] <= Res1[i][j] + (A1[i][k] * B1[k][j]);  
		end
	end


    /*always@ (i or j or k)begin
    	if (!rst_n) begin
			for(i=0; i<2; i=i+1)begin
				for(j=0; j<2 ;j=j+1)begin
					Res1[i][j] <= 8'b0 ; 
				end
			end	
		end 
		else begin
			for(i=0; i<2; i=i+1)begin
				for(j=0; j<2 ;j=j+1)begin
					for(k=0; k<2; k=k+1)begin
						Res1[i][j] <= Res1[i][j] + (A1[i][k] * B1[k][j]); 
				    end 
				end 
			end		
		end
	end */

	reg [1:0] z ;
	always@ (posedge clk or negedge rst_n) begin
	//counter_Z for output 2d to 1d
		if (!rst_n) begin
			z <= 2'd0;
		end else if (&z) begin
			z <= z;
		end else if (x_done_d1) begin
			z <= z + 2'd1;
		end else begin
			z <= z ;
		end
	end
	
	reg [1:0] z_d1 ;
	always@(posedge clk or negedge rst_n)begin
		if (!rst_n) begin
			z_d1 <= 2'd0;
		end else begin	
			z_d1 <= z;  
		end
	end

	reg [31:0] Res_pre ;
	wire z1 = z_d1[1] ;
	wire z2 = z_d1[0] ;
    always@ (z or z_d1) begin
			Res_pre <= {Res_pre[23:0], Res1[z1][z2]} ;                    
	end

    always@(posedge clk or negedge rst_n)begin
		if (!rst_n) begin
			Res <= 32'd0 ;
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