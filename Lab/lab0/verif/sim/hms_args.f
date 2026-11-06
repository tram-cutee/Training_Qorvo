-64
-sv
-sysv_ext .sv,.svh,.prot
+access+rwc
+libext+.v+.sv+.prot
-timescale 1ns/100ps

hms_tb.sv

// DUT
../../rtl/hms_timer_all.sv.prot

-top hms_tb
-run -exit
