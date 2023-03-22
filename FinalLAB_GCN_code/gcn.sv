`include "params.vh"

module gcn (
    input logic clk,
    input logic rst_n,
    input logic start,
    input  [num_of_rows_fm-1:0] [num_of_elements_in_row*BW-1:0] row_features, // Port for feature matrix -> // [6][96*5]
    input  [num_of_rows_wm-1:0] [num_of_elements_in_row*BW-1:0] row_weights, // Port for weight matrix -> // [3][96*5]
    input   [1:0] [17:0] COO_mat,
    output reg [num_of_outs-1:0] [2:0] y,
    output reg input_re,
    output reg [num_of_rows_wm-1:0] [1:0] input_addr_wm,  //[3][2bits]
    output reg [num_of_cols_fm-1:0] [2:0] input_addr_fm_row, //[6][3bits]?
    output reg output_we,
    output reg [num_of_outs-1:0] [2:0] output_addr,
    //output logic Aggregated_out,
    //output logic Aggregated_address,
    output reg done
);

    reg [num_of_rows_fm-1:0] [num_of_elements_in_row*BW-1:0] in_row_features;
    reg [num_of_rows_wm-1:0] [num_of_elements_in_row*BW-1:0] in_row_weights;
    reg [1:0] [17:0] in_COO_mat;
    reg in_start ;
    reg in_start_d1 ;

    reg [14:0]feature_trans[5:0][2:0];
    reg [5:0][2:0] output_pre;
   
    //reg adjacent[5:0][5:0] ; //logic?
	reg adjacent[5:0][5:0] ;    
    integer /*i,j,*/k,res1,res2,l; //
    
    reg [6:0] cnt_for_all;
    reg [14:0] output_matrix[5:0][2:0];
    

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		in_row_features  <= 'd0;
		in_row_weights   <= 'd0;
		in_COO_mat 	<= 'd0;
		in_start        <= 'd0;
		in_start_d1     <= 'd0;
	end else begin
		in_row_features  <= row_features;
		in_row_weights   <= row_weights;
		in_COO_mat       <= COO_mat;
		in_start        <= start;	
		in_start_d1     <= in_start;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt_for_all <= 7'd0;
	end else if (done) begin
		cnt_for_all <= cnt_for_all;
	end else begin
		cnt_for_all <= cnt_for_all+7'd1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		input_re  <= 1'd0;
         	input_addr_fm_row[0]  <= 3'd0;
        	input_addr_fm_row[1]  <= 3'd0;
         	input_addr_fm_row[2]  <= 3'd0;
        	input_addr_fm_row[3]  <= 3'd0;
         	input_addr_fm_row[4]  <= 3'd0;
         	input_addr_fm_row[5]  <= 3'd0;
         	input_addr_wm[0] <= 3'd0;
         	input_addr_wm[1] <= 3'd0;
         	input_addr_wm[2] <= 3'd0;
		//adjacent <= {6'd0,6'd0,6'd0,6'd0,6'd0,6'd0}; 
	end else begin
		input_re  <= 1'd1;
         	input_addr_fm_row[0]  <= 3'd0;
        	input_addr_fm_row[1]  <= 3'd1;
         	input_addr_fm_row[2]  <= 3'd2;
        	input_addr_fm_row[3]  <= 3'd3;
         	input_addr_fm_row[4]  <= 3'd4;
         	input_addr_fm_row[5]  <= 3'd5;
         	input_addr_wm[0] <= 3'd0;
         	input_addr_wm[1] <= 3'd1;
         	input_addr_wm[2] <= 3'd2;
		//adjacent <= adjacent;
	end
end
/*
reg [2:0] coo_cnt ;
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)begin
		coo_cnt <= 0; 
	end else if (coo_cnt == 3'd5) begin
		coo_cnt <= coo_cnt; 
	end else if (in_start_d1) begin
		coo_cnt <= coo_cnt + 3'd1; 
	end else begin
		coo_cnt <= coo_cnt; 
	end
end*/

reg [2:0] v1;
reg [2:0] v2;
//wire [2:0] v3 = v1 -1;
//wire [2:0] v4 = v2 -1;
//should combine with i
always @(posedge clk) begin
	if(cnt_for_all<7'd15) begin
		adjacent = {default : 'd0};//?
		for(l=0;l<6;l++)begin
         		v1 = in_COO_mat[0][3*l+:3];
         		v2 = in_COO_mat[1][3*l+:3];
         		adjacent[v1-1][v2-1] =1;
         		adjacent[v2-1][v1-1] =1;
		end
	end
end
/*
always @(posedge clk) begin

     if(cnt_for_all<8) begin
         input_re = 1'b1;
         input_addr_fm_row[0]  = 3'd0;
         input_addr_fm_row[1]  = 3'd1;
         input_addr_fm_row[2]  = 3'd2;
         input_addr_fm_row[3]  = 3'd3;
         input_addr_fm_row[4]  = 3'd4;
         input_addr_fm_row[5]  = 3'd5;

         input_addr_wm[0] = 3'd0;
         input_addr_wm[1] = 3'd1;
         input_addr_wm[2]  = 3'd2;

	adjacent = {default : 'd0};
			
       for(l=0;l<6;l++)begin
       
         v1 = in_COO_mat[0][3*l+:3];
         v2 = in_COO_mat[1][3*l+:3];
         
         adjacent[v1-1][v2-1]=1;
         adjacent[v2-1][v1-1]=1;
      end

end
end*/

/*
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
         	v1 <= 3'd0;
         	v2 <= 3'd0;
		adjacent[v3][v4] <= 0 ;
 		adjacent[v4][v3] <= 0 ;
	end else if (in_start && cnt_for_all<7'd11) begin
         	v1 <= in_COO_mat[0][3*coo_cnt+:3] ;
         	v2 <= in_COO_mat[1][3*coo_cnt+:3] ;
		adjacent[v3][v4] <= 1 ;
 		adjacent[v4][v3] <= 1 ; 
	end
end*/


//wire start_multi_flag = (cnt_for_all>7'd11);

reg [2:0] i ;
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)begin
		i <= 0; 
	end else if (done) begin
		i <= i ;
	end else if (i == 3'd5) begin
		i <= 0; 
	end else if (in_start_d1) begin
		i <= i + 3'd1;  
	end else begin
		i <= i; 
	end
end

reg [1:0] j ;
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)begin
		j <= 0; 
	end else if (done) begin
		j <= j ; 
	end else if (j == 2'd2 && i == 3'd5) begin
		j <= 0; 
	end else if (i == 3'd5) begin
		j <= j + 3'd1; 
	end else begin
		j <= j; 
	end
end
/*
always @(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		res1 <= 0; 
		feature_trans[i][j] <= 0;
	end else if(cnt_for_all>7'd29 && cnt_for_all< 7'd49)begin    
		for(k=0;k<96;k=k+1)begin   
			res1 <= res1 + (in_row_features[i][k*5+:5] * in_row_weights[j][k*5+:5]);              
		end                  
          	feature_trans[i][j] <= res1;
		res1 <= 0;//??
	end else begin
		res1 <= res1; 
		feature_trans[i][j] <= feature_trans[i][j];
	end
end*/

//timing??
always @(posedge clk )begin
	if(cnt_for_all>7'd9 /*&& cnt_for_all< 7'd29*/)begin
		//for(i=0;i<6;i=i+1 )begin      
			//for(j=0;j<3;j=j+1)begin      
				for(k=0;k<96;k=k+1)begin   
				res1 = res1 + (in_row_features[i][k*5+:5] * in_row_weights[j][k*5+:5]);              
				end                  
          		feature_trans[i][j] = res1;
          		res1 = 0;
        		//end
		//end
	end
end

always @(posedge clk)begin
	if(cnt_for_all>7'd29 /*&& cnt_for_all<7'd49*/)begin
		//for(i=0;i<6;i++)begin
      			//for(j=0;j<3;j++)begin
        			for(k=0;k<6;k++)begin
          			res2 = res2 + (adjacent[i][k] * feature_trans[k][j]) ;
        			end
        		output_matrix[i][j] = res2;
        		res2 = 0;
      			//end
    		//end
	//$display("%p", output_matrix); 1
	end
end

reg done_pre ;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n ) begin
   		done_pre  <= 1'd0;
		done 	  <= 1'd0;
		output_we <= 1'd0;
	end else if (cnt_for_all>7'd49) begin
   		done_pre  <= 1'd1;   		
		done      <= done_pre;
		output_we <= 1'd1;
	end
end

//6loops in 1T
/*
always @(posedge clk or negedge rst_n) begin
	if(!rst_n ) begin
		for(l=0;l<6;l=l+1)begin
		output_pre[l] = 'd0;
		end
	end else if (done_pre) begin
		for(l=0;l<6;l=l+1)begin
    			if((output_matrix[l][0] > output_matrix[l][1]) && (output_matrix[l][0] > output_matrix[l][2]))begin
      				output_pre[l] = 0;
			end else if(output_matrix[l][1]>output_matrix[l][0] && output_matrix[l][1]>output_matrix[l][2])begin
       				output_pre[l] = 1;
			end else begin
     				output_pre[l] = 2;
			end
		end
	end	
end
*/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n ) begin
		for(k=0;k<6;k=k+1)begin
		output_pre[k] = 'd0;
		end
	end else if (done_pre) begin
		for(k=0;k<6;k=k+1)begin
    			if((output_matrix[k][0] > output_matrix[k][1]) && (output_matrix[k][0] > output_matrix[k][2]))begin
      				output_pre[k] = 0;
			end else if(output_matrix[k][1]>output_matrix[k][0] && output_matrix[k][1]>output_matrix[k][2])begin
       				output_pre[k] = 1;
			end else begin
     				output_pre[k] = 2;
			end
		end
	end	
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		y <= 'd0;
	end else if (done) begin
		y <= output_pre;
	end else begin
		y <= y;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		output_addr[0] <= 3'd0;
		output_addr[1] <= 3'd0;
		output_addr[2] <= 3'd0;
		output_addr[3] <= 3'd0;
		output_addr[4] <= 3'd0;
		output_addr[5] <= 3'd0;
	end else begin
		output_addr[0] <= output_pre[5];
		output_addr[1] <= output_pre[4];
		output_addr[2] <= output_pre[3];
		output_addr[3] <= output_pre[2];
		output_addr[4] <= output_pre[1];
		output_addr[5] <= output_pre[0];
	end
end

endmodule
