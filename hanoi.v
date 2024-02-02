module hanoi
	#(parameter S = 4)
	(
	input clk,
	input rst,
	input [1:0] fr,
	input [1:0] to
	);
	
	logic [$clog2(S)-1:0] stick0;
	logic [$clog2(S)-1:0] stick1;
	logic [$clog2(S)-1:0] stick2;
	
	logic [$clog2(S)-1:0] cnt0;
	logic [$clog2(S)-1:0] cnt1;
	logic [$clog2(S)-1:0] cnt2;
	
	logic [1:0] f;
	logic [1:0] t;
	
	logic [1:0] tmp0;
	logic [1:0] tmp1;
	logic [1:0] tmp2;
	
	always_ff @(posedge clk)
		begin
			if(rst)
				begin
					cnt0 <= '1;
					cnt1 <= '0;
					cnt2 <= '0;
					
					stick0 <= '1;
					stick1 <= '0;
					stick2 <= '0;
					f <= '0;
					t <= '0;
						
				end
			else
				begin
					f <= fr;
					t <= to;
				
					if(f == "00" && t == "01")							
						cnt0 <= cnt0 - 1'b1; //smanjujem brojac od stapa0
						tmp0 <= stick0[cnt0+1]; //vrednost tmp0  koja se prenosi
											
						cnt1 <= cnt1 + 1'b1; // povecavam brojac od stapa1
						stick1[cnt1] <= tmp0; //upisujem na poziciju cnt1 vrednost tmp0
						
					
					if(f == "00" && t == "10")							
						cnt0 <= cnt0 - 1'b1; //smanjujem brojac od stapa0
						tmp0 <= stick0[cnt0+1]; //vrednost tmp0  koja se prenosi
											
						cnt2 <= cnt2 + 1'b1; // povecavam brojac od stapa2
						stick2[cnt2] <= tmp0; //upisujem na poziciju cnt2 vrednost tmp0
						
					if(f == "01" && t == "00")							
						cnt1 <= cnt1 - 1'b1; //smanjujem brojac od stapa1
						tmp1 <= stick1[cnt1+1]; //vrednost tmp1  koja se prenosi
											
						cnt0 <= cnt0 + 1'b1; // povecavam brojac od stapa0
						stick0[cnt0] <= tmp1; //upisujem na poziciju cnt0 vrednost tmp1
						
					if(f == "01" && t == "10")						
						cnt1 <= cnt1 - 1'b1; //smanjujem brojac od stapa1
						tmp1 <= stick1[cnt1+1]; //vrednost tmp1  koja se prenosi
											
						cnt2 <= cnt2 + 1'b1; // povecavam brojac od stapa2
						stick2[cnt2] <= tmp1; //upisujem na poziciju cnt2 vrednost tmp1
						
					if(f == "10" && t == "00")
						cnt2 <= cnt2 - 1'b1; //smanjujem brojac od stapa2
						tmp2 <= stick2[cnt2+1]; //vrednost tmp2  koja se prenosi
											
						cnt0 <= cnt0 + 1'b1; // povecavam brojac od stapa0
						stick0[cnt0] <= tmp2; //upisujem na poziciju cnt0 vrednost tmp1
						
					if(f == "10" && t == "01")						
						cnt2 <= cnt2 - 1'b1; //smanjujem brojac od stapa2
						tmp2 <= stick2[cnt2+1]; //vrednost tmp2  koja se prenosi
											
						cnt1 <= cnt1 + 1'b1; // povecavam brojac od stapa1
						stick1[cnt1] <= tmp2; //upisujem na poziciju cnt1 vrednost tmp2					
				end
		end
	
	logic legal;
	always_comb begin	
		legal = 1'b0; //kada je legal=0, potez je invalid. kada je legal=1, potez je validan.
		if (f == "11" || t == "11") legal = 1'b0;
		if (f == "01" && t == "01") legal = 1'b0;
		if (f == "10" && t == "10") legal = 1'b0;
		if (f == "00" && t == "01" && (tmp0<tmp1)) legal = 1'b1; //disk koji se prenosi (tmp0) ne sme biti veci od diska na koji se prenosi (tmp1)
		if (f == "00" && t == "01" && (tmp0>tmp1)) legal = 1'b0;
		if (f == "00" && t == "10" && (tmp0<tmp2)) legal = 1'b1;
		if (f == "00" && t == "10" && (tmp0>tmp2)) legal = 1'b0;
		if (f == "01" && t == "00" && (tmp1<tmp0)) legal = 1'b1;
		if (f == "01" && t == "00" && (tmp1>tmp0)) legal = 1'b0;
		if (f == "01" && t == "10" && (tmp1<tmp2)) legal = 1'b1;
		if (f == "01" && t == "10" && (tmp1>tmp2)) legal = 1'b0;
		if (f == "10" && t == "00" && (tmp2<tmp0)) legal = 1'b1;
		if (f == "10" && t == "00" && (tmp2>tmp0)) legal = 1'b0;
		if (f == "10" && t == "01" && (tmp2<tmp1)) legal = 1'b1;
		if (f == "10" && t == "01" && (tmp2>tmp1)) legal = 1'b0;
	end

	default clocking
		@(posedge clk);
	endclocking
	
	default disable iff(rst);
	
	assume_legal_move: assume property(legal == 1'b1);
	cover_cnt2: cover property(cnt2 == '1);
	cover_cnt0_empty: cover property(cnt0 == '0);
	cover_cnt1_empty: cover property(cnt1 == '0);
	cover_cnt2_empty: cover property(cnt2 == '0);

endmodule
