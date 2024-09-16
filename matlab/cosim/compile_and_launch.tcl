proc hdlsimulink {args} {
set ::env(LD_PRELOAD) /cad/adi/apps/mathworks/matlab/2022b_u2/sys/os/glnxa64/libstdc++.so.6
  lappend sllibarg -64bit -loadvpi \{/cad/adi/apps/mathworks/matlab/2022b_u2/toolbox/edalink/extensions/incisive/linux64/liblfihdls_tmwgcc.so:simlinkserver\}
  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {
    set socket [lindex $args [expr {$idx + 1}]]
    set args [lreplace $args $idx [expr {$idx + 1}]]
    append socketarg "+socket=" "$socket"
    lappend sllibarg $socketarg
  }
  set runmode "GUI"
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
proc hdlsimmatlab {args} {
set ::env(LD_PRELOAD) /cad/adi/apps/mathworks/matlab/2022b_u2/sys/os/glnxa64/libstdc++.so.6
  lappend mllibarg -64bit -loadcfc \{/cad/adi/apps/mathworks/matlab/2022b_u2/toolbox/edalink/extensions/incisive/linux64/liblfihdlc_tmwgcc.so:matlabclient\}
  lappend mllibarg 
  lappend mlinput  -input "{@proc nomatlabtb {args} {call nomatlabtb \$args}}" -input "{@proc matlabtb {args} {call matlabtb \$args}}" -input "{@proc matlabcp {args} {call matlabcp \$args}}" -input "{@proc matlabtbeval {args} {call matlabtbeval \$args}}" -input "{@proc notifyMatlabServer {args} {call notifyMatlabServer \$args}}"
  lappend mlinput [join $args]
  lappend mlinput [join $mllibarg]
  set runmode "GUI"
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
  set runmode "GUI"
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
exec xmelab  -64bit -access +wc  -File parameter_adaptive_filter.cfg adaptive_filter
hdlsimmatlabsysobj adaptive_filter  -64bit  -socket 36549 -input "{@simvision {set w \[waveform new\]}}" -input "{@simvision {waveform add -using \$w -signals adaptive_filter}}" -input "{@probe -create -shm adaptive_filter}" -input "{@database -open waves -into waves.shm -default}"

