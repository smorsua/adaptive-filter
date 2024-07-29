proc hdlsimulink {args} {
set ::env(LD_PRELOAD) /cad/adi/apps/mathworks/matlab/2022b_u2/sys/os/glnxa64/libstdc++.so.6
  lappend sllibarg -64bit -loadvpi \{/cad/adi/apps/mathworks/matlab/2022b_u2/toolbox/edalink/extensions/incisive/linux64/liblfihdls_tmwgcc.so:simlinkserver\}
  set socket 35463
  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {
    set socket [lindex $args [expr {$idx + 1}]]
    set args [lreplace $args $idx [expr {$idx + 1}]]
  }
  set runmode "Batch with Xterm"
  if {$runmode == "Batch" || $runmode == "Batch with Xterm"} {
    lappend sllibarg " +batch"
    set runopt "-Batch -EXIT"
  } elseif {$runmode == "CLI"} {
    set runopt "-tcl"
  } else {
    set runopt "-gui"
  } 
  append socketarg "+socket=" "$socket"
  lappend sllibarg $socketarg
  lappend sllibarg 
  set args [linsert $args 0 exec <@stdin >@stdout  xmsim $runopt]
  lappend args [join $sllibarg]
  uplevel 1 [join $args]
}
proc hdlsimmatlab {args} {
set ::env(LD_PRELOAD) /cad/adi/apps/mathworks/matlab/2022b_u2/sys/os/glnxa64/libstdc++.so.6
  lappend mllibarg -64bit -loadcfc \{/cad/adi/apps/mathworks/matlab/2022b_u2/toolbox/edalink/extensions/incisive/linux64/liblfihdlc_tmwgcc.so:matlabclient\}
  lappend mllibarg 
  lappend mlinput  -input "{@proc nomatlabtb {args} {call nomatlabtb \$args}}" -input "{@proc matlabtb {args} {call matlabtb \$args}}" -input "{@proc matlabcp {args} {call matlabcp \$args}}" -input "{@proc matlabtbeval {args} {call matlabtbeval \$args}}" -input "{@proc notifyMatlabServer {args} {call notifyMatlabServer \$args}}"
  lappend mlinput [join $args]
  lappend mlinput [join $mllibarg]
  set runmode "Batch with Xterm"
  if {$runmode == "Batch" || $runmode == "Batch with Xterm"} {
    set runopt "-Batch -EXIT"
  } elseif {$runmode == "CLI"} {
    set runopt "-tcl"
  } else {
    set runopt "-gui"
  } 
  set mlinput [linsert $mlinput 0 exec <@stdin >@stdout  xmsim $runopt]
  uplevel 1 [join $mlinput]
}
proc hdlsimmatlabsysobj {args} {
set ::env(LD_PRELOAD) /cad/adi/apps/mathworks/matlab/2022b_u2/sys/os/glnxa64/libstdc++.so.6
  lappend sllibarg -64bit -loadvpi \{/cad/adi/apps/mathworks/matlab/2022b_u2/toolbox/edalink/extensions/incisive/linux64/liblfihdls_tmwgcc.so:matlabsysobjserver\}
  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {
    set socket [lindex $args [expr {$idx + 1}]]
    set args [lreplace $args $idx [expr {$idx + 1}]]
    append socketarg "+socket=" "$socket"
    lappend sllibarg $socketarg
  }
  set runmode "Batch with Xterm"
  if {$runmode == "Batch" || $runmode == "Batch with Xterm"} {
    lappend sllibarg " +batch"
    set runopt "-Batch -EXIT"
  } elseif {$runmode == "CLI"} {
    set runopt "-tcl"
  } else {
    set runopt "-gui"
  } 
  lappend sllibarg 
  set args [linsert $args 0 exec <@stdin >@stdout  xmsim $runopt]
  lappend args [join $sllibarg]
  uplevel 1 [join $args]
}
if { [catch {hdlsimulink -log xmsim.log  -64bit  adaptive_filter -input "exit"} errmsg] } {
    set fid [ open tp88bde992_1f40_4d40_a5f8_d8e455713574.log w];
    puts $fid "Loading simulation and HDL Verifier library failed.";
    puts $fid $errmsg;
    close $fid;
}
