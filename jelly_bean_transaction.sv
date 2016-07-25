//package jelly_bean_pkg;
class jelly_bean_transaction extends uvm_sequence_item;
	typedef enum bit[2:0] {NO_FLAVOR, APPLE, BLUEBERRY, BUBBLE_GUM, CHOCOLATE} flavor_e;
	typedef enum bit[1:0] { RED, GREEN, BLUE } color_e;
	typedef enum bit[1:0] {UNKNOWN,YUMMY,YUCKY} taste_e;

	rand flavor_e flavor;
	rand color_e color;
	rand bit sugar_free;
	rand bit sour;
	taste_e taste;

	constraint flavor_color_con {
		flavor !=NO_FLAVOR;
		flavor ==APPLE -> color !=BLUE;
		flavor ==BLUEBERRY-> color ==BLUE;
	}

	function new(string name="");
		super.new(name);
	endfunction

	`uvm_object_utils_begin(jelly_bean_transaction)
		`uvm_field_enum(flavor_e,flavor,UVM_ALL_ON)
		`uvm_field_enum(color_e,color,UVM_ALL_ON)
		`uvm_field_enum(taste_e,taste,UVM_ALL_ON)
		`uvm_field_int(sugar_free, UVM_ALL_ON)
		`uvm_field_int(sour, UVM_ALL_ON)
	`uvm_object_utils_end
endclass:jelly_bean_transaction  

class sugar_free_jelly_bean_transaction extends jelly_bean_transaction;
	`uvm_object_utils(sugar_free_jelly_bean_transaction)
	constraint sugar_free_con {
		sugar_free == 1;
	}

	function new(string name="");
		super.new(name);
	endfunction
endclass
class one_jelly_bean_sequence extends uvm_sequence#(jelly_bean_transaction);
	`uvm_object_utils(one_jelly_bean_sequence)
	function new(string name="");
		super.new(name);
	endfunction
	task body();
		jelly_bean_transaction jb_tx;
		jb_tx=jelly_bean_transaction::type_id::create(.name("jb_tx"),.contxt(get_full_name()));
		start_item(jb_tx);
		assert(jb_tx.randomize());
		finish_item(jb_tx);
	endtask: body
endclass: one_jelly_bean_sequence
	
class same_flavored_jelly_beans_sequence extends uvm_sequence#(jelly_bean_transaction);
	rand int unsigned num_jelly_beans;
	constraint num_jelly_beans_con { num_jelly_beans inside {[2:4]}; }
	`uvm_object_utils_begin(same_flavored_jelly_beans_sequence)
		`uvm_field_int(num_jelly_beans,UVM_ALL_ON)
	`uvm_object_utils_end
	function new(string name="");
		super.new(name);
	endfunction
	task body();
		jelly_bean_transaction 		 jb_tx;
		jelly_bean_transaction::flavor_e jb_flavor;
		jb_tx=jelly_bean_transaction::type_id::create(.name("jb_tx"),.contxt(get_full_name()));
		assert(jb_tx.randomize());
		jb_flavor= jb_tx.flavor;
		repeat (num_jelly_beans) begin
			jb_tx=jelly_bean_transaction::type_id::create(.name("jb_tx"),.contxt(get_full_name()));
			start_item(jb_tx);
			assert(jb_tx.randomize() with {jb_tx.flavor == jb_flavor;});
			finish_item(jb_tx);
		end
	endtask: body

endclass
class gift_boxed_jelly_beans_sequence extends uvm_sequence#(jelly_bean_transaction);
	rand int unsigned num_jelly_bean_flavors;
	constraint num_jelly_bean_flavors_con { num_jelly_bean_flavors inside {[2:3]}; }
	`uvm_object_utils_begin(gift_boxed_jelly_beans_sequence)
		`uvm_field_int(num_jelly_bean_flavors,UVM_ALL_ON)
	`uvm_object_utils_end
	function new(string name="");
		super.new(name);
	endfunction
	task body();
		same_flavored_jelly_beans_sequence jb_seq;	
		repeat (num_jelly_bean_flavors) begin
			jb_seq=same_flavored_jelly_beans_sequence::type_id::create(.name("jb_seq"),.contxt(get_full_name()));
			assert(jb_seq.randomize());
			jb_seq.start(.sequencer(m_sequencer), .parent_sequence(this));
		end
	endtask: body

endclass
//endpackage: jelly_bean_pkg
