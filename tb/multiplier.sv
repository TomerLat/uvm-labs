`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////////////////

class transaction extends uvm_sequence_item;

    `uvm_object_utils(transaction)
    
    rand bit [3:0] a, b;
    bit [7:0] y;
    
    function new(input string path = "transaction");
        super.new(path);
    endfunction
    
endclass

///////////////////////////////////////

class sequence1 extends uvm_sequence #(transaction);
    `uvm_object_utils(sequence1)
    
    transaction tr;
    
    function new(input string path = "sequence1");
        super.new(path);
    endfunction
    
    virtual task body();
        repeat(15) begin
            tr = transaction::type_id::create("tr");
            start_item(tr);
                assert(tr.randomize());
                `uvm_info("SEQ", $sformatf("a : %0d, b : %0d, y : %0d", tr.a, tr.b, tr.y), UVM_NONE);

            finish_item(tr);
        end
    endtask
endclass 

///////////////////////////////////////

// Class Driver
class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver) // UVM Component macro
    
    transaction tr;
    virtual mul_if vif;
    
    function new (input string path = "driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual mul_if)::get(this, "", "vif", vif))
            `uvm_error("driver", "Unable to access interface") // uvm_test_top.env.agent.drv.vif
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        tr = transaction::type_id::create("tr");
        forever begin
            seq_item_port.get_next_item(tr);
            vif.a <= tr.a;
            vif.b <= tr.b;
            `uvm_info("DRV", $sformatf("a : %0d, b : %0d, y: %0d", tr.a, tr.b, tr.y), UVM_NONE)
            seq_item_port.item_done();
            #20;
        end
    endtask
endclass 

///////////////////////////////////////
class monitor extends uvm_monitor;

    `uvm_component_utils(monitor)
    
    uvm_analysis_port #(transaction) send;
    transaction tr;
    virtual mul_if vif;
    
    function new (input string inst = "monitor", uvm_component parent = null);
        super.new(inst, parent);    
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("tr");
        send = new("send", this);
        if(!uvm_config_db #(virtual mul_if)::get(this, "", "vif", vif)) // uvm_test_top.env.agent.drv.vif
            `uvm_error("monitor", "Unable to access interface")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            #20;
            tr.a = vif.a;
            tr.b = vif.b;
            tr.y = vif.y;
            `uvm_info("MON", $sformatf("a : %0d, b : %0d, y : %0d", tr.a, tr.b, tr.y), UVM_NONE);
            send.write(tr);
        end
    endtask
endclass

///////////////////////////////////////
// Scoreboard class
class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)
    uvm_analysis_imp #(transaction, scoreboard) recv;
    
    function new(input string inst = "scoreboard", uvm_component parent = null);
        super.new(inst, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("recv", this);
    endfunction
    
    virtual function void write(transaction tr);
        if(tr.y == (tr.a * tr.b))
            `uvm_info("SCO", $sformatf("Test Passed --> a: %0d, b : %0d, y : %0d", tr.a, tr.b, tr.y), UVM_NONE)
        else
            `uvm_error("SCO", $sformatf("Test Failed --> a: %0d, b : %0d, y : %0d", tr.a, tr.b, tr.y))
        $display("--------------------------------------------------------------------");

    endfunction
    
endclass

///////////////////////////////////////

// Agent Class
class agent extends uvm_agent;
    
    `uvm_component_utils(agent)
    
    function new(input string inst = "agent", uvm_component parent = null);
        super.new(inst, parent);
    endfunction
    
    driver d;
    uvm_sequencer #(transaction) seqr;
    monitor m;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        d = driver::type_id::create("d", this);
        m = monitor::type_id::create("m", this);
        seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
    endfunction
    
    virtual function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        d.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass
///////////////////////////////////////

class environment extends uvm_env;

    `uvm_component_utils(environment)
    
    function new(input string inst = "environment", uvm_component c);
        super.new(inst, c);
    endfunction
    
    agent a;
    scoreboard s;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a = agent::type_id::create("a", this);
        s = scoreboard::type_id::create("s", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.m.send.connect(s.recv);
    endfunction
endclass

///////////////////////////////////////

class test extends uvm_test;
    `uvm_component_utils(test)
    
    function new(input string inst = "test", uvm_component c);
        super.new(inst, c);
    endfunction
    
    environment e;
    sequence1 seq;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e = environment::type_id::create("environment", this);
        seq = sequence1::type_id::create("sequence1", this);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
            seq.start(e.a.seqr);
            #20;
        phase.drop_objection(this);
    endtask
    
endclass
///////////////////////////////////////

module tb();

    mul_if vif();
    top dut(vif.dut);
    
    initial begin
        uvm_config_db #(virtual mul_if)::set(null, "*", "vif", vif);
        run_test("test");
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
endmodule
