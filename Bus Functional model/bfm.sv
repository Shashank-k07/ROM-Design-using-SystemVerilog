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

