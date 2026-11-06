`timescale 1ns/100ps

module hms_tb;
    logic clk = 0;
    logic rstn = 1;
    logic sel_in = 0, up_in = 0, down_in = 0;
    wire [4:0] h_out;
    wire [5:0] m_out, s_out;

    supply1 vdd;
    supply0 vss;
    supply0 vsspsub;

    logic scan_mode    = 0;
    logic scan_clk     = 0;
    logic scan_resetn  = 1;
    logic scan_en      = 0;
    logic scan_data_in = 0;
    wire  scan_data_out;

    integer error_count = 0;
    integer clk_count = 0;
    always @(posedge clk) clk_count = clk_count + 1;

    always #500 clk = ~clk;

    hms_timer dut (
        .clk    (clk),
        .rstn   (rstn),
        .sel_in (sel_in),
        .up_in  (up_in),
        .down_in(down_in),
        .h_out  (h_out),
        .m_out  (m_out),
        .s_out  (s_out),
        .VDD          (vdd),
        .VSS          (vss),
        .VSSPSUB      (vsspsub),
        .scan_mode_in (scan_mode),
        .scan_clk     (scan_clk),
        .scan_resetn  (scan_resetn),
        .scan_en_in   (scan_en),
        .scan_data_in (scan_data_in),
        .scan_data_out(scan_data_out)
    );

    task press_sel;
        begin
            @(negedge clk);
            sel_in = 1;
            repeat (3) @(posedge clk);
            @(negedge clk);
            sel_in = 0;
            repeat (8) @(posedge clk);
        end
    endtask

    task press_up;
        begin
            @(negedge clk);
            up_in = 1;
            repeat (4) @(posedge clk);
            @(negedge clk);
            up_in = 0;
            repeat (8) @(posedge clk);
        end
    endtask

    task press_down;
        begin
            @(negedge clk);
            down_in = 1;
            repeat (30) @(posedge clk);
            @(negedge clk);
            down_in = 0;
            repeat (8) @(posedge clk);
        end
    endtask

    task check_time(input [4:0] exp_h, input [5:0] exp_m, input [5:0] exp_s, input string test_name);
        begin
            @(negedge clk);
            if (h_out === exp_h && m_out === exp_m && s_out === exp_s)
                $display ("PASS %0s: %0d:%0d:%0d", test_name, h_out, m_out, s_out);
            else begin
                $display ("FAIL %0s: got %0d:%0d:%0d, expected %0d:%0d:%0d", test_name, h_out, m_out, s_out, exp_h, exp_m, exp_s);
                error_count = error_count + 1;
            end
        end
    endtask

    task apply_reset;
        begin
            rstn = 1;
            #250 rstn = 0;
            repeat (2) @(posedge clk);
            @(negedge clk) rstn = 1;
            repeat (3) @(posedge clk);
        end
    endtask

    task test_hms_select_hour_up;
        begin
            $display("\n--- test_hms_select_hour_up ---");
            apply_reset;
            check_time(0, 0, 0, "sau reset");
            press_sel;
            press_up;
            check_time(1, 0, 0, "up 1 lan, h = 1");
            press_up;
            check_time(2, 0, 0, "up lan 2, h = 2");
        end
    endtask

    task test_hms_select_hour_down;
        begin
            $display("\n--- test_hms_select_hour_down ---");
            apply_reset;
            check_time(0, 0, 0, "sau reset");
            press_sel;
            press_down;
            // press_up;
            // press_up;
            // $display("sau 2 up: h = %0d", h_out);
            check_time(23, 0, 0, "down tu 0: wrap e 23, khong borrow");
            // repeat (4) begin
            //     press_down;
            //     $display("h = %0d", h_out);
            // end
            press_down;
            check_time(22, 0, 0, "down lan 2: 22");
            //$display("sau 1 down: h = %0d", h_out);
        end
    endtask

    task test_hms_select_minute_up;
        begin
            $display("\n--- test_hms_select_minute_up ---");
            apply_reset;
            check_time(0, 0, 0, "sau reset");
            press_sel;
            press_sel;
            check_time(0, 0, 0, "vao MIN_ADJ: gia tri chua doi");
            press_up;
            check_time(0, 1, 0, "up 1 lan, m = 1, h va s giu nguyen");
            press_up;
            check_time(0, 2, 0, "up lan 2, m = 2");
        end
    endtask

    task test_hms_select_second_up;
        begin
            $display("\n--- test_hms_select_second_up ---");
            apply_reset;
            check_time(0, 0, 0, "sau reset");
            press_sel;
            press_sel;
            press_sel;
            check_time(0, 0, 0, "vao SEC_ADJ: gia tri chua doi");
            press_up;
            check_time(0, 0, 1, "up 1 lan, s = 1, h va m giu nguyen");
            press_up;
            check_time(0, 0, 2, "up lan 2, s = 2");
        end
    endtask

    task wait_time_change;
        reg [16:0] old;
        integer guard;
        begin
            old = {h_out, m_out, s_out};
            guard = 0;
            while ({h_out, m_out, s_out} === old && guard < 1_100_000) begin
                @(negedge clk);
                guard = guard + 1;
            end
            if (guard >= 1_100_000) begin
                $display("FAIL wait_time_change: thoi gian khong doi sau 1.1 trieu chu ki");
                error_count = error_count + 1;
            end
        end
    endtask

    task test_hms_second_count;
        integer t1, t2;
        begin
            $display("\n--- test_hms_second_count ---");
            apply_reset;
            check_time(0, 0, 0, "sau reset");

            wait_time_change;
            t1 = clk_count;
            check_time(0, 0, 1, "sau 1 giay: s = 1, h va m giu nguyen");

            wait_time_change;
            t2 = clk_count;
            check_time(0, 0, 2, "sau 2 giay: s = 2");

            if (t2 - t1 == 1_000_000)
                $display("PASS chu ki 1 giay = %0d clk", t2 - t1);
            else begin
                $display("FAIL chu ki 1 giay = %0d clk, expected 1000000", t2 - t1);
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        test_hms_select_hour_up;
        test_hms_select_hour_down;
        test_hms_select_minute_up;
        test_hms_select_second_up;
        test_hms_second_count;

        $display("============================");
        if (error_count == 0) $display("TEST PASSED");
        else                  $display("TEST FAILED: %0d loi", error_count);
        $finish;
    end

endmodule
