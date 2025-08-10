class gen;
	tb p;
	task t1;
		p = new();
		p.randomize();
		common::mb.put(p);
	endtask
endclass
