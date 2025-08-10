module rom(rd_data, wr_data, addr, rd_en, wr_en, clock);
	input[7:0]wr_data;
	input[6:0]addr;
	input wr_en, rd_en, clock;
	output reg[7:0]rd_data;
	reg[7:0] mem[127:0];
	always@(posedge clock)begin
		if(wr_en==1)begin
			mem[addr]=wr_data;
		end
		if(rd_en==1)begin
			rd_data = mem[addr];
		end

	end
endmodule

class common;
	static mailbox mb = new();
	static virtual rom_inf vif;
endclass

interface rom_inf(input bit clock);
	bit[7:0] wr_data, rd_data; 
	bit rd_en;
        bit wr_en;
	bit[6:0]addr;
endinterface


class tb;
	randc bit[7:0]wr_data; 
	randc bit rd_en; 
	randc bit wr_en;
	randc bit[6:0]addr;
	constraint c1{
		addr==100;
		}
	endclass

class gen;
	tb p;
	task t1;
		p = new();
		p.randomize();
		common::mb.put(p);
	endtask
endclass

class bfm;
	tb p;
	task t2;
		p = new();
		common::mb.get(p);
		common::vif.wr_data = p.wr_data;
		common::vif.wr_en = p.wr_en;
		common::vif.rd_en = p.rd_en;
		common::vif.addr = p.addr;
	endtask
endclass


module test;
	bit clock;
	initial begin
		clock = 0;
		forever #5 clock = ~clock;
	end
	gen a =new();
	bfm b  =new();
	rom_inf pvif(clock);
	rom dut(.clock(pvif.clock), .rd_data(pvif.rd_data), .wr_data(pvif.wr_data), .wr_en(pvif.wr_en), .rd_en(pvif.rd_en), .addr(pvif.addr));
	initial begin
		common::vif = pvif;
		repeat(10) begin
		a.t1;
		b.t2;
		@(posedge clock);
	end
	$finish;
end
endmodule
