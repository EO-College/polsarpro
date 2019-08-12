#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    package require BWidget
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *ScrolledWindow.size 14
	}
    }
    
    package require Tk
    switch $tcl_platform(platform) {
	windows {
	    option add *Button.padY 0
	}
	default {
	    option add *Scrollbar.width 10
	    option add *Scrollbar.highlightThickness 0
	    option add *Scrollbar.elementBorderWidth 2
	    option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v8.6.0.5 Project
#


#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
	show {
	    if {$exists} {
		wm deiconify $newname
	    } elseif {[info procs vTclWindow$name] != ""} {
		eval "vTclWindow$name $newname $rest"
	    }
	    if {[winfo exists $newname] && [wm state $newname] == "normal"} {
		vTcl:FireEvent $newname <<Show>>
	    }
	}
	hide    {
	    if {$exists} {
		wm withdraw $newname
		vTcl:FireEvent $newname <<Hide>>
		return}
	}
	iconify { if $exists {wm iconify $newname; return} }
	destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
	interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
	set widget($top_or_alias,$alias) $target
	if {$cmdalias} {
	    interp alias {} $top_or_alias.$alias {} $widgetProc $target
	}
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
	set tag_events [bind $bindtag]
	set stop_processing 0
	foreach tag_event $tag_events {
	    if {$tag_event == $event} {
		set bind_code [bind $bindtag $tag_event]
		foreach rep "\{%W $target\} $params" {
		    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
		}
		set result [catch {uplevel #0 $bind_code} errortext]
		if {$result == 3} {
		    ## break exception, stop processing
		    set stop_processing 1
		} elseif {$result != 0} {
		    bgerror $errortext
		}
		break
	    }
	}
	if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
	## If no arguments, returns the path the alias points to
	return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top527
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.fra66
    set site_4_0 [$base.cpd67 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd75
    set site_6_0 $site_5_0.cpd68
    set site_6_0 $site_5_0.cpd69
    set site_8_0 [$site_6_0.cpd72 getframe]
    set site_8_0 $site_8_0
    set site_9_0 $site_8_0.cpd71
    set site_8_0 [$site_6_0.cpd73 getframe]
    set site_8_0 $site_8_0
    set site_9_0 $site_8_0.cpd73
    set site_9_0 $site_8_0.cpd74
    set site_4_0 [$base.cpd74 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd75
    set site_6_0 $site_5_0.cpd68
    set site_6_0 $site_5_0.cpd69
    set site_8_0 [$site_6_0.cpd72 getframe]
    set site_8_0 $site_8_0
    set site_9_0 $site_8_0.cpd71
    set site_8_0 [$site_6_0.cpd73 getframe]
    set site_8_0 $site_8_0
    set site_9_0 $site_8_0.cpd73
    set site_9_0 $site_8_0.cpd74
    set site_3_0 $base.fra92
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top527
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
## This will clean up and call exit properly on Windows.
#vTcl:WindowsCleanup
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global tk_strictMotif MouseInitX MouseInitY MouseEndX MouseEndY BMPMouseX BMPMouseY

catch {package require unsafe}
set tk_strictMotif 1
global TrainingAreaTool; 
global x;
global y;

set TrainingAreaTool rect
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 200x200+88+88; update
    wm maxsize $top 3844 1065
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top527 {base} {
    if {$base == ""} {
        set base .top527
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-menu "$top.m71" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x240+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Polarimetric Tomography ( Pol-TomSAR ) - Generators DEM & z-Top"
    vTcl:DefineAlias "$top" "Toplevel527" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra66 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame1" vTcl:WidgetProc "Toplevel527" 1
    set site_3_0 $top.fra66
    label $site_3_0.lab67 \
		-text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab67" "Label1" vTcl:WidgetProc "Toplevel527" 1
    entry $site_3_0.ent71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent71" "Entry1" vTcl:WidgetProc "Toplevel527" 1
    label $site_3_0.cpd68 \
		-text {End Row} 
    vTcl:DefineAlias "$site_3_0.cpd68" "Label2" vTcl:WidgetProc "Toplevel527" 1
    entry $site_3_0.cpd72 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd72" "Entry2" vTcl:WidgetProc "Toplevel527" 1
    label $site_3_0.cpd69 \
		-text {Init Col} 
    vTcl:DefineAlias "$site_3_0.cpd69" "Label3" vTcl:WidgetProc "Toplevel527" 1
    entry $site_3_0.cpd73 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.cpd73" "Entry3" vTcl:WidgetProc "Toplevel527" 1
    label $site_3_0.cpd70 \
		-text {End Col} 
    vTcl:DefineAlias "$site_3_0.cpd70" "Label4" vTcl:WidgetProc "Toplevel527" 1
    entry $site_3_0.cpd74 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd74" "Entry4" vTcl:WidgetProc "Toplevel527" 1
    pack $site_3_0.lab67 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.ent71 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd72 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd73 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd67 \
		-ipad 2 -text {Input 2D Slant-Range DEM File} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame527_1" vTcl:WidgetProc "Toplevel527" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    checkbutton $site_4_0.cpd67 \
		\
		-command {global PTOMgeneDEM PTOMDEMFile PTOMSRunitDEM PTOMNRvalDEM PTOMFRvalDEM PTOMDirInput

if {$PTOMgeneDEM == 1} {
    set PTOMDEMFile "$PTOMDirInput/DEM.bin"
    set PTOMSRunitDEM "col"; set PTOMNRvalDEM "100"; set PTOMFRvalDEM "150"
    $widget(TitleFrame527_1) configure -state normal; $widget(TitleFrame527_2) configure -state normal; $widget(TitleFrame527_3) configure -state normal
    $widget(Radiobutton527_1) configure -state normal; $widget(Radiobutton527_2) configure -state normal
    $widget(Label527_1) configure -state normal; $widget(Label527_2) configure -state normal
    $widget(Entry527_1) configure -state normal; $widget(Entry527_2) configure -state normal
    } else {
    set PTOMDEMFile "Generate Input Slant-Range DEM File"
    set PTOMSRunitDEM " "; set PTOMNRvalDEM " "; set PTOMFRvalDEM " "
    $widget(TitleFrame527_1) configure -state disable; $widget(TitleFrame527_2) configure -state disable; $widget(TitleFrame527_3) configure -state disable
    $widget(Radiobutton527_1) configure -state disable; $widget(Radiobutton527_2) configure -state disable
    $widget(Label527_1) configure -state disable; $widget(Label527_2) configure -state disable
    $widget(Entry527_1) configure -state disable; $widget(Entry527_2) configure -state disable
    }} \
		-variable PTOMgeneDEM 
    vTcl:DefineAlias "$site_4_0.cpd67" "Checkbutton527_1" vTcl:WidgetProc "Toplevel527" 1
    frame $site_4_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame70" vTcl:WidgetProc "Toplevel527" 1
    set site_5_0 $site_4_0.cpd75
    frame $site_5_0.cpd68 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame77" vTcl:WidgetProc "Toplevel527" 1
    set site_6_0 $site_5_0.cpd68
    entry $site_6_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMDEMFile 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry527_01" vTcl:WidgetProc "Toplevel527" 1
    pack $site_6_0.cpd71 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side left 
    frame $site_5_0.cpd69 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd69" "Frame78" vTcl:WidgetProc "Toplevel527" 1
    set site_6_0 $site_5_0.cpd69
    TitleFrame $site_6_0.cpd72 \
		-ipad 2 -text {Slant-Range axis} 
    vTcl:DefineAlias "$site_6_0.cpd72" "TitleFrame527_2" vTcl:WidgetProc "Toplevel527" 1
    bind $site_6_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd72 getframe]
    frame $site_8_0.cpd71 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd71" "Frame23" vTcl:WidgetProc "Toplevel527" 1
    set site_9_0 $site_8_0.cpd71
    radiobutton $site_9_0.cpd75 \
		-borderwidth 0 \
		-command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "col"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "col_"
    append PTOMOutputDir $BMPPTOMX
    }} \
		-text Row -value row -variable PTOMSRunitDEM 
    vTcl:DefineAlias "$site_9_0.cpd75" "Radiobutton527_1" vTcl:WidgetProc "Toplevel527" 1
    radiobutton $site_9_0.cpd74 \
		-borderwidth 0 \
		-command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "lig"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "row_"
    append PTOMOutputDir $BMPPTOMY
    }} \
		-text Col -value col -variable PTOMSRunitDEM 
    vTcl:DefineAlias "$site_9_0.cpd74" "Radiobutton527_2" vTcl:WidgetProc "Toplevel527" 1
    pack $site_9_0.cpd75 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd74 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd71 \
		-in $site_8_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_6_0.cpd73 \
		-ipad 2 -text {Slant-Range values} 
    vTcl:DefineAlias "$site_6_0.cpd73" "TitleFrame527_3" vTcl:WidgetProc "Toplevel527" 1
    bind $site_6_0.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd73 getframe]
    frame $site_8_0.cpd73 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd73" "Frame76" vTcl:WidgetProc "Toplevel527" 1
    set site_9_0 $site_8_0.cpd73
    label $site_9_0.lab76 \
		-text {Near Range} 
    vTcl:DefineAlias "$site_9_0.lab76" "Label527_1" vTcl:WidgetProc "Toplevel527" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMNRvalDEM -width 7 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry527_1" vTcl:WidgetProc "Toplevel527" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.cpd74 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd74" "Frame79" vTcl:WidgetProc "Toplevel527" 1
    set site_9_0 $site_8_0.cpd74
    label $site_9_0.lab76 \
		-text {Far Range} 
    vTcl:DefineAlias "$site_9_0.lab76" "Label527_2" vTcl:WidgetProc "Toplevel527" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMFRvalDEM -width 7 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry527_2" vTcl:WidgetProc "Toplevel527" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.cpd73 \
		-in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd74 \
		-in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd72 \
		-in $site_6_0 -anchor center -expand 1 -fill none -ipadx 5 -side left 
    pack $site_6_0.cpd73 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd68 \
		-in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd69 \
		-in $site_5_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $site_4_0.cpd67 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd74 \
		-ipad 2 -text {Input 2DSlant-Range Top Height File} 
    vTcl:DefineAlias "$top.cpd74" "TitleFrame527_4" vTcl:WidgetProc "Toplevel527" 1
    bind $top.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd74 getframe]
    checkbutton $site_4_0.cpd67 \
		\
		-command {global PTOMgeneHeight PTOMHeightFile PTOMSRunitHeight PTOMNRvalHeight PTOMFRvalHeight PTOMDirInput

if {$PTOMgeneHeight == 1} {
    set PTOMHeightFile "$PTOMDirInput/z_top.bin"
    set PTOMSRunitHeight "col"; set PTOMNRvalHeight "100"; set PTOMFRvalHeight "150"
    $widget(TitleFrame527_4) configure -state normal; $widget(TitleFrame527_5) configure -state normal; $widget(TitleFrame527_6) configure -state normal
    $widget(Radiobutton527_3) configure -state normal; $widget(Radiobutton527_4) configure -state normal
    $widget(Label527_3) configure -state normal; $widget(Label527_4) configure -state normal
    $widget(Entry527_3) configure -state normal; $widget(Entry527_4) configure -state normal 
    } else {
    set PTOMHeightFile "Generate Input Slant-Range Top Height File"
    set PTOMSRunitHeight " "; set PTOMNRvalHeight " "; set PTOMFRvalHeight " "
    $widget(TitleFrame527_4) configure -state disable; $widget(TitleFrame527_5) configure -state disable; $widget(TitleFrame527_6) configure -state disable
    $widget(Radiobutton527_3) configure -state disable; $widget(Radiobutton527_4) configure -state disable
    $widget(Label527_3) configure -state disable; $widget(Label527_4) configure -state disable
    $widget(Entry527_3) configure -state disable; $widget(Entry527_4) configure -state disable 
    }} \
		-variable PTOMgeneHeight 
    vTcl:DefineAlias "$site_4_0.cpd67" "Checkbutton527_2" vTcl:WidgetProc "Toplevel527" 1
    frame $site_4_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame72" vTcl:WidgetProc "Toplevel527" 1
    set site_5_0 $site_4_0.cpd75
    frame $site_5_0.cpd68 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame80" vTcl:WidgetProc "Toplevel527" 1
    set site_6_0 $site_5_0.cpd68
    entry $site_6_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMHeightFile 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry527_02" vTcl:WidgetProc "Toplevel527" 1
    pack $site_6_0.cpd71 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side left 
    frame $site_5_0.cpd69 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd69" "Frame81" vTcl:WidgetProc "Toplevel527" 1
    set site_6_0 $site_5_0.cpd69
    TitleFrame $site_6_0.cpd72 \
		-ipad 2 -text {Slant-Range axis} 
    vTcl:DefineAlias "$site_6_0.cpd72" "TitleFrame527_5" vTcl:WidgetProc "Toplevel527" 1
    bind $site_6_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd72 getframe]
    frame $site_8_0.cpd71 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd71" "Frame24" vTcl:WidgetProc "Toplevel527" 1
    set site_9_0 $site_8_0.cpd71
    radiobutton $site_9_0.cpd75 \
		-borderwidth 0 \
		-command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "col"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "col_"
    append PTOMOutputDir $BMPPTOMX
    }} \
		-text Row -value row -variable PTOMSRunitHeight 
    vTcl:DefineAlias "$site_9_0.cpd75" "Radiobutton527_3" vTcl:WidgetProc "Toplevel527" 1
    radiobutton $site_9_0.cpd74 \
		-borderwidth 0 \
		-command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "lig"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "row_"
    append PTOMOutputDir $BMPPTOMY
    }} \
		-text Col -value col -variable PTOMSRunitHeight 
    vTcl:DefineAlias "$site_9_0.cpd74" "Radiobutton527_4" vTcl:WidgetProc "Toplevel527" 1
    pack $site_9_0.cpd75 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd74 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd71 \
		-in $site_8_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_6_0.cpd73 \
		-ipad 2 -text {Slant-Range values} 
    vTcl:DefineAlias "$site_6_0.cpd73" "TitleFrame527_6" vTcl:WidgetProc "Toplevel527" 1
    bind $site_6_0.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd73 getframe]
    frame $site_8_0.cpd73 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd73" "Frame82" vTcl:WidgetProc "Toplevel527" 1
    set site_9_0 $site_8_0.cpd73
    label $site_9_0.lab76 \
		-text {Near Range} 
    vTcl:DefineAlias "$site_9_0.lab76" "Label527_3" vTcl:WidgetProc "Toplevel527" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMNRvalHeight -width 7 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry527_3" vTcl:WidgetProc "Toplevel527" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.cpd74 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd74" "Frame83" vTcl:WidgetProc "Toplevel527" 1
    set site_9_0 $site_8_0.cpd74
    label $site_9_0.lab76 \
		-text {Far Range} 
    vTcl:DefineAlias "$site_9_0.lab76" "Label527_4" vTcl:WidgetProc "Toplevel527" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMFRvalHeight -width 7 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry527_4" vTcl:WidgetProc "Toplevel527" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.cpd73 \
		-in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd74 \
		-in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd72 \
		-in $site_6_0 -anchor center -expand 1 -fill none -ipadx 5 -side left 
    pack $site_6_0.cpd73 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd68 \
		-in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd69 \
		-in $site_5_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $site_4_0.cpd67 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra92 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel527" 1
    set site_3_0 $top.fra92
    button $site_3_0.cpd67 \
		-background {#ffff00} \
		-command {global PTOMgeneDEM PTOMDEMFile PTOMSRunitDEM PTOMNRvalDEM PTOMFRvalDEM
global PTOMgeneHeight PTOMHeightFile PTOMSRunitHeight PTOMNRvalHeight PTOMFRvalHeight
global OpenDirFile PTOMDirInput PTOMDEM
global NligEnd NligInit NcolEnd NcolInit

if {$OpenDirFile == 0} {

set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

if {$PTOMgeneDEM == "1"} {
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_nonull_file.exe" "k"
    TextEditorRunTrace "Arguments: -of \x22$PTOMDEMFile\x22 -fnr $FinalNlig -fnc $FinalNcol -axe $PTOMSRunitDEM -min $PTOMNRvalDEM -max $PTOMFRvalDEM" "k"
    set f [ open "| Soft/bin/bmp_process/create_nonull_file.exe -of \x22$PTOMDEMFile\x22 -fnr $FinalNlig -fnc $FinalNcol -axe $PTOMSRunitDEM -min $PTOMNRvalDEM -max $PTOMFRvalDEM" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"    
    WaitUntilCreated $PTOMDEMFile
    EnviWriteConfig $PTOMDEMFile $FinalNlig $FinalNcol 4
    $widget(Checkbutton524_0) configure -state normal
    set PTOMDEM 0
    }
if {$PTOMgeneHeight == "1"} {
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_nonull_file.exe" "k"
    TextEditorRunTrace "Arguments: -of \x22$PTOMHeightFile\x22 -fnr $FinalNlig -fnc $FinalNcol -axe $PTOMSRunitHeight -min $PTOMNRvalHeight -max $PTOMFRvalHeight" "k"
    set f [ open "| Soft/bin/bmp_process/create_nonull_file.exe -of \x22$PTOMHeightFile\x22 -fnr $FinalNlig -fnc $FinalNcol -axe $PTOMSRunitHeight -min $PTOMNRvalHeight -max $PTOMFRvalHeight" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"    
    WaitUntilCreated $PTOMHeightFile
    EnviWriteConfig $PTOMHeightFile $FinalNlig $FinalNcol 4
    }
Window hide $widget(Toplevel527); TextEditorRunTrace "Close Window Polarimetric Tomography - Generator DEM & z-Top" "b"    
}} \
		-padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button523_3" vTcl:WidgetProc "Toplevel527" 1
    pack $site_3_0.cpd67 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
		-activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra66 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd74 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra92 \
		-in $top -anchor center -expand 1 -fill x -side top 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
}

Window show .
Window show .top527

main $argc $argv
