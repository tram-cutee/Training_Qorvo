-64
-sv
-sysv_ext .sv,.svh,.prot

// uncomment for gui
//-gui
+access+rwc
+libext+.v+.sv+.prot

// default timescale
-timescale 1ns/100ps

// debug options

// options

// include directories

// compile files
../tb/top_tb.sv.prot

// virtual interfaces

// DUT
../../rtl/hms_timer_all.sv.prot

-top top_tb
+SVSEED=random

//-coverage U -covoverwrite
-input probe.tcl
-run -exit
