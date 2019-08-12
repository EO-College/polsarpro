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




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif -
	.png	{return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

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
    set base .top524
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.cpd66
    set site_5_0 [$site_3_0.cpd67 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd75
    set site_4_0 [$base.cpd67 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd75
    set site_4_0 [$base.cpd71 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd75
    set site_3_0 $base.fra57
    set site_3_0 $base.cpd72
    set site_5_0 [$site_3_0.cpd88 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd73
    set site_7_0 $site_6_0.cpd49
    set site_7_0 $site_6_0.cpd50
    set site_7_0 $site_6_0.cpd51
    set site_6_0 $site_5_0.cpd74
    set site_7_0 $site_6_0.cpd52
    set site_7_0 $site_6_0.cpd53
    set site_7_0 $site_6_0.cpd48
    set site_5_0 [$site_3_0.cpd54 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd73
    set site_7_0 $site_6_0.cpd49
    set site_7_0 $site_6_0.cpd50
    set site_7_0 $site_6_0.cpd51
    set site_6_0 $site_5_0.cpd74
    set site_7_0 $site_6_0.cpd52
    set site_7_0 $site_6_0.cpd53
    set site_7_0 $site_6_0.cpd48
    set site_5_0 [$site_3_0.cpd55 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd73
    set site_7_0 $site_6_0.cpd49
    set site_7_0 $site_6_0.cpd50
    set site_7_0 $site_6_0.cpd51
    set site_6_0 $site_5_0.cpd74
    set site_7_0 $site_6_0.cpd52
    set site_7_0 $site_6_0.cpd53
    set site_7_0 $site_6_0.cpd48
    set site_3_0 $base.fra71
    set site_4_0 $site_3_0.cpd78
    set site_4_0 $site_3_0.fra72
    set site_5_0 $site_4_0.fra66
    set site_7_0 [$site_5_0.cpd82 getframe]
    set site_7_0 $site_7_0
    set site_8_0 $site_7_0.cpd75
    set site_9_0 $site_8_0.fra84
    set site_9_0 $site_8_0.fra85
    set site_7_0 [$site_5_0.cpd67 getframe]
    set site_7_0 $site_7_0
    set site_8_0 $site_7_0.cpd75
    set site_9_0 $site_8_0.fra84
    set site_9_0 $site_8_0.fra85
    set site_5_0 $site_4_0.fra69
    set site_7_0 [$site_5_0.cpd72 getframe]
    set site_7_0 $site_7_0
    set site_8_0 $site_7_0.cpd72
    set site_9_0 $site_8_0.cpd92
    set site_7_0 [$site_5_0.cpd86 getframe]
    set site_7_0 $site_7_0
    set site_8_0 $site_7_0.fra73
    set site_5_0 $site_4_0.fra87
    set site_6_0 $site_5_0.fra66
    set site_7_0 $site_6_0.cpd69
    set site_8_0 [$site_6_0.cpd70 getframe]
    set site_8_0 $site_8_0
    set site_9_0 $site_8_0.cpd75
    set site_9_0 $site_8_0.cpd71
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top524
            PTOMdefineOutputDir
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
## Procedure:  PTOMdefineOutputDir

proc ::PTOMdefineOutputDir {} {
global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM PTOMalgo
global BMPPTOMX BMPPTOMY

set PTOMOutputDir $PTOMDirInput
if {$PTOMalgo == "beam"} { 
    append PTOMOutputDir "/profile_beamformer_"
    } else {
    append PTOMOutputDir "/profile_capon_"
    }
if {$PTOMDEM == "1"} { 
    append PTOMOutputDir "DEMcomp_"
    } else {
    append PTOMOutputDir ""
    }
if {$PTOMSlice == "col"} { 
    append PTOMOutputDir "col_"
    append PTOMOutputDir $BMPPTOMX
    } else {
    append PTOMOutputDir "row_"
    append PTOMOutputDir $BMPPTOMY
    }
    
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
    wm geometry $top 200x200+242+242; update
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

proc vTclWindow.top524 {base} {
    if {$base == ""} {
        set base .top524
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
    wm geometry $top 500x470+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Polarimetric Tomography ( Pol-TomSAR ) - Generator Tomograms"
    vTcl:DefineAlias "$top" "Toplevel524" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd66 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame21" vTcl:WidgetProc "Toplevel524" 1
    set site_3_0 $top.cpd66
    TitleFrame $site_3_0.cpd67 \
		-ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame12" vTcl:WidgetProc "Toplevel524" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame54" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.cpd75
    entry $site_6_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMOutputDir 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry67" vTcl:WidgetProc "Toplevel524" 1
    entry $site_6_0.cpd69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd69" "Entry64" vTcl:WidgetProc "Toplevel524" 1
    label $site_6_0.cpd70 \
		-text / -width 2 
    vTcl:DefineAlias "$site_6_0.cpd70" "Label40" vTcl:WidgetProc "Toplevel524" 1
    pack $site_6_0.cpd71 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd69 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    pack $site_6_0.cpd70 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd75 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd67 \
		-in $site_3_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd67 \
		-ipad 0 -text {Input 2D Slant-Range DEM File} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame524_1" vTcl:WidgetProc "Toplevel524" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame70" vTcl:WidgetProc "Toplevel524" 1
    set site_5_0 $site_4_0.cpd75
    entry $site_5_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMDEMFile 
    vTcl:DefineAlias "$site_5_0.cpd71" "Entry524_1" vTcl:WidgetProc "Toplevel524" 1
    button $site_5_0.cpd70 \
		\
		-command {global FileName PTOMDirInput PTOMDEMFile PTOMDEM

set PTOMDEM 0
set types {
    {{Bin Files}        {.bin}        }
    }
set FileName ""
OpenFile "$PTOMDirInput" $types "2D SLANT-RANGE DEM FILE"
if {$FileName != ""} {
    set PTOMDEMFile $FileName
    $widget(Checkbutton524_0) configure -state normal
    } else {
    set PTOMDEMFile "Select or Generate Slant-Range DEM File"
    $widget(Checkbutton524_0) configure -state disable
    $widget(Button524_0) configure -state normal
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd70" "Button524_1" vTcl:WidgetProc "Toplevel524" 1
    pack $site_5_0.cpd71 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd70 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd71 \
		-ipad 0 -text {Input 2DSlant-Range Top Height File} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame524_2" vTcl:WidgetProc "Toplevel524" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    frame $site_4_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame71" vTcl:WidgetProc "Toplevel524" 1
    set site_5_0 $site_4_0.cpd75
    entry $site_5_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMHeightFile 
    vTcl:DefineAlias "$site_5_0.cpd71" "Entry524_2" vTcl:WidgetProc "Toplevel524" 1
    button $site_5_0.cpd70 \
		\
		-command {global FileName PTOMDirInput PTOMHeightFile

set types {
    {{Bin Files}        {.bin}        }
    }
set FileName ""
OpenFile "$PTOMDirInput" $types "2D SLANT-RANGE TOP HEIGHT FILE"
if {$FileName != ""} {
    set PTOMHeightFile $FileName
    } else {
    set PTOMHeightFile "Select or Generate Slant-Range Top Height File"
    $widget(Button524_0) configure -state normal
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd70" "Button524_2" vTcl:WidgetProc "Toplevel524" 1
    pack $site_5_0.cpd71 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd70 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra57 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra57" "Frame1" vTcl:WidgetProc "Toplevel524" 1
    set site_3_0 $top.fra57
    label $site_3_0.lab58 \
		-text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab58" "Label1" vTcl:WidgetProc "Toplevel524" 1
    entry $site_3_0.ent62 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry1" vTcl:WidgetProc "Toplevel524" 1
    label $site_3_0.cpd59 \
		-text {End Row} 
    vTcl:DefineAlias "$site_3_0.cpd59" "Label2" vTcl:WidgetProc "Toplevel524" 1
    entry $site_3_0.cpd63 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd63" "Entry2" vTcl:WidgetProc "Toplevel524" 1
    label $site_3_0.cpd60 \
		-text {Init Col} 
    vTcl:DefineAlias "$site_3_0.cpd60" "Label3" vTcl:WidgetProc "Toplevel524" 1
    entry $site_3_0.cpd64 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.cpd64" "Entry3" vTcl:WidgetProc "Toplevel524" 1
    label $site_3_0.cpd61 \
		-text {End Col} 
    vTcl:DefineAlias "$site_3_0.cpd61" "Label4" vTcl:WidgetProc "Toplevel524" 1
    entry $site_3_0.cpd65 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd65" "Entry4" vTcl:WidgetProc "Toplevel524" 1
    pack $site_3_0.lab58 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.ent62 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd59 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd63 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd60 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd64 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd61 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd65 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd72 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame22" vTcl:WidgetProc "Toplevel524" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd88 \
		-ipad 0 -text {Slant Range Row values} 
    vTcl:DefineAlias "$site_3_0.cpd88" "TitleFrame8" vTcl:WidgetProc "Toplevel524" 1
    bind $site_3_0.cpd88 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd88 getframe]
    frame $site_5_0.cpd73 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame67" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.cpd73
    frame $site_6_0.cpd49 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd49" "Frame68" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd49
    label $site_7_0.lab76 \
		-pady 0 -text {x min } 
    vTcl:DefineAlias "$site_7_0.lab76" "Label51" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.lab76 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd50 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd50" "Frame69" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd50
    label $site_7_0.cpd45 \
		-pady 0 -text {x max } 
    vTcl:DefineAlias "$site_7_0.cpd45" "Label59" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd45 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd51 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd51" "Frame73" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd51
    label $site_7_0.cpd46 \
		-pady 0 -text {x unit} 
    vTcl:DefineAlias "$site_7_0.cpd46" "Label62" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd46 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd49 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd50 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd51 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd74 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame72" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.cpd74
    frame $site_6_0.cpd52 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd52" "Frame77" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd52
    entry $site_7_0.cpd47 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMRowmin -width 12 
    vTcl:DefineAlias "$site_7_0.cpd47" "Entry82" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd47 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd53 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd53" "Frame78" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd53
    entry $site_7_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMRowmax -width 12 
    vTcl:DefineAlias "$site_7_0.ent78" "Entry83" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.ent78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side left 
    frame $site_6_0.cpd48 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd48" "Frame18" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd48
    radiobutton $site_7_0.cpd75 \
		\
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
		-text {[m]} -value m -variable PTOMRowunit 
    vTcl:DefineAlias "$site_7_0.cpd75" "Radiobutton357" vTcl:WidgetProc "Toplevel524" 1
    radiobutton $site_7_0.cpd74 \
		\
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
		-text {[bin]} -value bin -variable PTOMRowunit 
    vTcl:DefineAlias "$site_7_0.cpd74" "Radiobutton358" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd75 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd74 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd52 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd53 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd48 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd73 \
		-in $site_5_0 -anchor center -expand 0 -fill both -padx 5 -side left 
    pack $site_5_0.cpd74 \
		-in $site_5_0 -anchor center -expand 0 -fill x -padx 5 -side left 
    TitleFrame $site_3_0.cpd54 \
		-ipad 0 -text {Slant Range Col values} 
    vTcl:DefineAlias "$site_3_0.cpd54" "TitleFrame14" vTcl:WidgetProc "Toplevel524" 1
    bind $site_3_0.cpd54 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd54 getframe]
    frame $site_5_0.cpd73 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame79" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.cpd73
    frame $site_6_0.cpd49 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd49" "Frame80" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd49
    label $site_7_0.lab76 \
		-pady 0 -text {y min } 
    vTcl:DefineAlias "$site_7_0.lab76" "Label54" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.lab76 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd50 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd50" "Frame81" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd50
    label $site_7_0.cpd45 \
		-pady 0 -text {y max } 
    vTcl:DefineAlias "$site_7_0.cpd45" "Label60" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd45 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd51 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd51" "Frame82" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd51
    label $site_7_0.cpd46 \
		-pady 0 -text {y unit} 
    vTcl:DefineAlias "$site_7_0.cpd46" "Label63" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd46 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd49 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd50 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd51 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd74 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame83" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.cpd74
    frame $site_6_0.cpd52 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd52" "Frame84" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd52
    entry $site_7_0.cpd47 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMColmin -width 12 
    vTcl:DefineAlias "$site_7_0.cpd47" "Entry84" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd47 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd53 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd53" "Frame85" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd53
    entry $site_7_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMColmax -width 12 
    vTcl:DefineAlias "$site_7_0.ent78" "Entry85" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.ent78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side left 
    frame $site_6_0.cpd48 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd48" "Frame19" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd48
    radiobutton $site_7_0.cpd75 \
		\
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
		-text {[m]} -value m -variable PTOMColunit 
    vTcl:DefineAlias "$site_7_0.cpd75" "Radiobutton359" vTcl:WidgetProc "Toplevel524" 1
    radiobutton $site_7_0.cpd74 \
		\
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
		-text {[bin]} -value bin -variable PTOMColunit 
    vTcl:DefineAlias "$site_7_0.cpd74" "Radiobutton360" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd75 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd74 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd52 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd53 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd48 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd73 \
		-in $site_5_0 -anchor center -expand 0 -fill both -padx 5 -side left 
    pack $site_5_0.cpd74 \
		-in $site_5_0 -anchor center -expand 0 -fill x -padx 5 -side left 
    TitleFrame $site_3_0.cpd55 \
		-ipad 0 -text {Height (z) values} 
    vTcl:DefineAlias "$site_3_0.cpd55" "TitleFrame15" vTcl:WidgetProc "Toplevel524" 1
    bind $site_3_0.cpd55 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd55 getframe]
    frame $site_5_0.cpd73 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame86" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.cpd73
    frame $site_6_0.cpd49 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd49" "Frame87" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd49
    label $site_7_0.lab76 \
		-pady 0 -text {z min } 
    vTcl:DefineAlias "$site_7_0.lab76" "Label55" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.lab76 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd50 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd50" "Frame88" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd50
    label $site_7_0.cpd45 \
		-pady 0 -text {z max } 
    vTcl:DefineAlias "$site_7_0.cpd45" "Label61" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd45 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd51 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd51" "Frame89" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd51
    label $site_7_0.cpd46 \
		-pady 0 -text {delta z} 
    vTcl:DefineAlias "$site_7_0.cpd46" "Label64" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd46 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd49 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd50 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd51 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd74 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame90" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.cpd74
    frame $site_6_0.cpd52 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd52" "Frame91" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd52
    entry $site_7_0.cpd47 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMzmin -width 12 
    vTcl:DefineAlias "$site_7_0.cpd47" "Entry86" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd47 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd53 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd53" "Frame92" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd53
    entry $site_7_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMzmax -width 12 
    vTcl:DefineAlias "$site_7_0.ent78" "Entry87" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.ent78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side left 
    frame $site_6_0.cpd48 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd48" "Frame23" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd48
    entry $site_7_0.cpd56 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMdz -width 8 
    vTcl:DefineAlias "$site_7_0.cpd56" "Entry88" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd56 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd52 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd53 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd48 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd73 \
		-in $site_5_0 -anchor center -expand 0 -fill both -padx 5 -side left 
    pack $site_5_0.cpd74 \
		-in $site_5_0 -anchor center -expand 0 -fill x -padx 5 -side left 
    pack $site_3_0.cpd88 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd54 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd55 \
		-in $site_3_0 -anchor center -expand 1 -fill none -ipadx 5 -ipady 2 \
		-side left 
    frame $top.fra71 \
		-height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel524" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel524" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
		-borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSPTOM" vTcl:WidgetProc "Toplevel524" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    pack $site_4_0.can73 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.fra72 \
		-borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel524" 1
    set site_4_0 $site_3_0.fra72
    frame $site_4_0.fra66 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra66" "Frame6" vTcl:WidgetProc "Toplevel524" 1
    set site_5_0 $site_4_0.fra66
    TitleFrame $site_5_0.cpd82 \
		-ipad 1 -text {Mouse Position} 
    vTcl:DefineAlias "$site_5_0.cpd82" "TitleFrame7" vTcl:WidgetProc "Toplevel524" 1
    bind $site_5_0.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd82 getframe]
    frame $site_7_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame47" vTcl:WidgetProc "Toplevel524" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame48" vTcl:WidgetProc "Toplevel524" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
		-relief groove -text X -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label34" vTcl:WidgetProc "Toplevel524" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry59" vTcl:WidgetProc "Toplevel524" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame51" vTcl:WidgetProc "Toplevel524" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
		-relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label35" vTcl:WidgetProc "Toplevel524" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry60" vTcl:WidgetProc "Toplevel524" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
		-in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra85 \
		-in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_7_0.cpd75 \
		-in $site_7_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_5_0.cpd67 \
		-ipad 1 -text {Selected Pixel} 
    vTcl:DefineAlias "$site_5_0.cpd67" "TitleFrame9" vTcl:WidgetProc "Toplevel524" 1
    bind $site_5_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd67 getframe]
    frame $site_7_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame55" vTcl:WidgetProc "Toplevel524" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame56" vTcl:WidgetProc "Toplevel524" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
		-relief groove -text X -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label38" vTcl:WidgetProc "Toplevel524" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable BMPPTOMX -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry65" vTcl:WidgetProc "Toplevel524" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame64" vTcl:WidgetProc "Toplevel524" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
		-relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label42" vTcl:WidgetProc "Toplevel524" 1
    entry $site_9_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable BMPPTOMY -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry66" vTcl:WidgetProc "Toplevel524" 1
    pack $site_9_0.lab76 \
		-in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
		-in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra85 \
		-in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_7_0.cpd75 \
		-in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd82 \
		-in $site_5_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    pack $site_5_0.cpd67 \
		-in $site_5_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    frame $site_4_0.fra69 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra69" "Frame2" vTcl:WidgetProc "Toplevel524" 1
    set site_5_0 $site_4_0.fra69
    TitleFrame $site_5_0.cpd72 \
		-ipad 1 -text {Window Size} 
    vTcl:DefineAlias "$site_5_0.cpd72" "TitleFrame11" vTcl:WidgetProc "Toplevel524" 1
    bind $site_5_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd72 getframe]
    frame $site_7_0.cpd72 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame49" vTcl:WidgetProc "Toplevel524" 1
    set site_8_0 $site_7_0.cpd72
    frame $site_8_0.cpd92 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd92" "Frame50" vTcl:WidgetProc "Toplevel524" 1
    set site_9_0 $site_8_0.cpd92
    label $site_9_0.lab85 \
		-text Row 
    vTcl:DefineAlias "$site_9_0.lab85" "Label11" vTcl:WidgetProc "Toplevel524" 1
    entry $site_9_0.cpd88 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMNwinC -width 5 
    vTcl:DefineAlias "$site_9_0.cpd88" "Entry9" vTcl:WidgetProc "Toplevel524" 1
    entry $site_9_0.cpd95 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMNwinL -width 5 
    vTcl:DefineAlias "$site_9_0.cpd95" "Entry11" vTcl:WidgetProc "Toplevel524" 1
    label $site_9_0.cpd94 \
		-text {  Col} 
    vTcl:DefineAlias "$site_9_0.cpd94" "Label12" vTcl:WidgetProc "Toplevel524" 1
    pack $site_9_0.lab85 \
		-in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd88 \
		-in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd95 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd94 \
		-in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd92 \
		-in $site_8_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_7_0.cpd72 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd86 \
		-ipad 1 -text {Tomogram Along :} 
    vTcl:DefineAlias "$site_5_0.cpd86" "TitleFrame13" vTcl:WidgetProc "Toplevel524" 1
    bind $site_5_0.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    frame $site_7_0.fra73 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra73" "Frame10" vTcl:WidgetProc "Toplevel524" 1
    set site_8_0 $site_7_0.fra73
    radiobutton $site_8_0.cpd75 \
		-borderwidth 0 -command PTOMdefineOutputDir -text {Col ( X )} \
		-value col -variable PTOMSlice 
    vTcl:DefineAlias "$site_8_0.cpd75" "Radiobutton349" vTcl:WidgetProc "Toplevel524" 1
    radiobutton $site_8_0.cpd74 \
		-borderwidth 0 -command PTOMdefineOutputDir -text {Row ( Y )} \
		-value lig -variable PTOMSlice 
    vTcl:DefineAlias "$site_8_0.cpd74" "Radiobutton350" vTcl:WidgetProc "Toplevel524" 1
    pack $site_8_0.cpd75 \
		-in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd74 \
		-in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra73 \
		-in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd72 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd86 \
		-in $site_5_0 -anchor center -expand 1 -fill x -ipady 2 -side left 
    frame $site_4_0.fra87 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra87" "Frame7" vTcl:WidgetProc "Toplevel524" 1
    set site_5_0 $site_4_0.fra87
    frame $site_5_0.fra66 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra66" "Frame5" vTcl:WidgetProc "Toplevel524" 1
    set site_6_0 $site_5_0.fra66
    frame $site_6_0.cpd69 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd69" "Frame9" vTcl:WidgetProc "Toplevel524" 1
    set site_7_0 $site_6_0.cpd69
    checkbutton $site_7_0.cpd67 \
		\
		-command {global PTOMDEM PTOMDEMFile PTOMHeightFile
global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMDEM == 0} {
    if {$PTOMSlice == "col"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_col_"
        append PTOMOutputDir $BMPPTOMX
        }    
    if {$PTOMSlice == "lig"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_row_"
        append PTOMOutputDir $BMPPTOMY
        }    
    } else {
    if {$PTOMSlice == "col"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_DEMcomp_col_"
        append PTOMOutputDir $BMPPTOMX
        }    
    if {$PTOMSlice == "lig"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_DEMcomp_row_"
        append PTOMOutputDir $BMPPTOMY
        }    
    }} \
		-text {DEM compensation} -variable PTOMDEM 
    vTcl:DefineAlias "$site_7_0.cpd67" "Checkbutton524_0" vTcl:WidgetProc "Toplevel524" 1
    button $site_7_0.cpd68 \
		-background {#ffff00} \
		-command {global PTOMgeneDEM PTOMDEMFile PTOMSRunitDEM PTOMNRvalDEM PTOMFRvalDEM
global PTOMgeneHeight PTOMHeightFile PTOMSRunitHeight PTOMNRvalHeight PTOMFRvalHeight
global OpenDirFile PTOMDirInput
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType

global Load_PolarTomographyGeneratorDEMzTop PSPTopLevel

if {$OpenDirFile == 0} {

    if {$Load_PolarTomographyGeneratorDEMzTop == 0} {
        source "GUI/data_process_mult/PolarTomographyGeneratorDEMzTop.tcl"
        set Load_PolarTomographyGeneratorDEMzTop 1
        WmTransient $widget(Toplevel527) $PSPTopLevel
        }

    $widget(TitleFrame527_1) configure -state disable; $widget(TitleFrame527_2) configure -state disable; $widget(TitleFrame527_3) configure -state disable
    $widget(Radiobutton527_1) configure -state disable; $widget(Radiobutton527_2) configure -state disable
    $widget(Label527_1) configure -state disable; $widget(Label527_2) configure -state disable
    $widget(Entry527_1) configure -state disable; $widget(Entry527_2) configure -state disable
    set PTOMgeneDEM 0
    set PTOMSRunitDEM " "; set PTOMNRvalDEM " "; set PTOMFRvalDEM " "
    if [file exists $PTOMDEMFile] {
        $widget(Checkbutton527_1) configure -state disable
        } else {
        $widget(Checkbutton527_1) configure -state normal
        set PTOMDEMFile "Generate Input Slant-Range DEM File"
        }

    $widget(TitleFrame527_4) configure -state disable; $widget(TitleFrame527_5) configure -state disable; $widget(TitleFrame527_6) configure -state disable
    $widget(Radiobutton527_3) configure -state disable; $widget(Radiobutton527_4) configure -state disable
    $widget(Label527_3) configure -state disable; $widget(Label527_4) configure -state disable
    $widget(Entry527_3) configure -state disable; $widget(Entry527_4) configure -state disable
    set PTOMgeneHeight 0
    set PTOMSRunitHeight " "; set PTOMNRvalHeight " "; set PTOMFRvalHeight " "
    if [file exists $PTOMHeightFile] {
        $widget(Checkbutton527_2) configure -state disable
        } else {
        $widget(Checkbutton527_2) configure -state normal
        set PTOMHeightFile "Generate Input Slant-Range Top Height File"
        }

    WidgetShowFromMenuFix $widget(Toplevel524) $widget(Toplevel527); TextEditorRunTrace "Open Window Polarimetric Tomography - DEM & z-Top Generators" "b"
    }} \
		-padx 4 -pady 2 -text {DEM & z-Top Generators} 
    vTcl:DefineAlias "$site_7_0.cpd68" "Button524_0" vTcl:WidgetProc "Toplevel524" 1
    pack $site_7_0.cpd67 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.cpd68 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side top 
    TitleFrame $site_6_0.cpd70 \
		-ipad 0 -text Algorithm 
    vTcl:DefineAlias "$site_6_0.cpd70" "TitleFrame524" vTcl:WidgetProc "Toplevel524" 1
    bind $site_6_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd70 getframe]
    frame $site_8_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd75" "Frame41" vTcl:WidgetProc "Toplevel524" 1
    set site_9_0 $site_8_0.cpd75
    radiobutton $site_9_0.rad66 \
		-command PTOMdefineOutputDir -text {Beam Former} -value beam \
		-variable PTOMalgo 
    vTcl:DefineAlias "$site_9_0.rad66" "Radiobutton524" vTcl:WidgetProc "Toplevel524" 1
    pack $site_9_0.rad66 \
		-in $site_9_0 -anchor center -expand 0 -fill none -side left 
    frame $site_8_0.cpd71 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd71" "Frame42" vTcl:WidgetProc "Toplevel524" 1
    set site_9_0 $site_8_0.cpd71
    radiobutton $site_9_0.cpd67 \
		-command PTOMdefineOutputDir -text Capon -value capon \
		-variable PTOMalgo 
    vTcl:DefineAlias "$site_9_0.cpd67" "Radiobutton527" vTcl:WidgetProc "Toplevel524" 1
    pack $site_9_0.cpd67 \
		-in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd75 \
		-in $site_8_0 -anchor center -expand 0 -fill x -side top 
    pack $site_8_0.cpd71 \
		-in $site_8_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd69 \
		-in $site_6_0 -anchor center -expand 1 -fill both -side left 
    pack $site_6_0.cpd70 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra66 \
		-in $site_5_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.cpd72 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame24" vTcl:WidgetProc "Toplevel524" 1
    set site_5_0 $site_4_0.cpd72
    button $site_5_0.cpd67 \
		-background {#ffff00} \
		-command {global PTOMDirInput PTOMDirOutput PTOMOutputDir PTOMOutputSubDir
global PTOMNwinL PTOMNwinC PTOMDEM PTOMalgo PTOMSlice PTOMzmin PTOMzmax PTOMdz
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize
global PTOMzdim PTOMxdim PTOMzmin PTOMzmax PTOMxmin PTOMxmax 
global BMPPTOMX BMPPTOMY 
global PTOMDEMFile PTOMHeightFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType

global OpenDirFile 

if {$OpenDirFile == 0} {

    #PROCESS
    set config ""
    PTOMdefineOutputDir

    set PTOMDirOutput $PTOMOutputDir
    if {$PTOMOutputSubDir != ""} {append PTOMDirOutput "/$PTOMOutputSubDir"}
    #####################################################################
    #Create Directory
    set PTOMDirOutput [PSPCreateDirectory $PTOMDirOutput $PTOMOutputDir $PTOMDirInput]
    #####################################################################       
    if {"$VarWarning"=="ok"} { 

    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    if {$PTOMSlice == "col"} { 
        set PTOMrowcut 1; set PTOMind $BMPPTOMX
        set TestVarName(0) "Selected Pixel Col"; set TestVarType(0) "int"; set TestVarValue(0) $BMPPTOMX; set TestVarMin(0) "0"; set TestVarMax(0) $NcolFullSize
        }
    if {$PTOMSlice == "lig"} {
        set PTOMrowcut 0; set PTOMind $BMPPTOMY
        set TestVarName(0) "Selected Pixel Row"; set TestVarType(0) "int"; set TestVarValue(0) $BMPPTOMY; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
         }

    set TestVarName(1) "Window Size Row"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNwinL; set TestVarMin(1) "1"; set TestVarMax(1) "1000"
    set TestVarName(2) "Window Size Col"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNwinC; set TestVarMin(2) "1"; set TestVarMax(2) "1000"
    set TestVarName(3) "z min"; set TestVarType(3) "float"; set TestVarValue(3) $PTOMzmin; set TestVarMin(3) "-9999"; set TestVarMax(3) "9999"
    set TestVarName(4) "z max"; set TestVarType(4) "float"; set TestVarValue(4) $PTOMzmax; set TestVarMin(4) "-9999"; set TestVarMax(4) "9999"
    set TestVarName(5) "z min"; set TestVarType(5) "float"; set TestVarValue(5) $PTOMdz; set TestVarMin(5) "0"; set TestVarMax(5) "9999"
    set TestVarName(6) "Slant-Range DEM File"; set TestVarType(6) "file"; set TestVarValue(6) $PTOMDEMFile; set TestVarMin(6) ""; set TestVarMax(6) ""
    set TestVarName(7) "Slant-Range Top Height File"; set TestVarType(7) "file"; set TestVarValue(7) $PTOMHeightFile; set TestVarMin(7) ""; set TestVarMax(7) ""
    TestVar 8

    if {$TestVarError == "ok"} {
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$PTOMalgo == "beam"} {
            set Tomo_NP_exe "Soft/bin/data_process_mult/Tomo_NP_Spec_est_BF.exe"
            } else {
            set Tomo_NP_exe "Soft/bin/data_process_mult/Tomo_NP_Spec_est_Capon.exe"
            }
        TextEditorRunTrace "Process The Function $Tomo_NP_exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMDirInput\x22 -od \x22$PTOMDirOutput\x22 -dem \x22$PTOMDEMFile \x22 -th \x22$PTOMHeightFile\x22 -nwr $PTOMNwinL -nwc $PTOMNwinC -ind $PTOMind -rc $PTOMrowcut -cd $PTOMDEM -zmin $PTOMzmin -zmax $PTOMzmax -dz $PTOMdz" "k"
        set f [ open "| $Tomo_NP_exe -id \x22$PTOMDirInput\x22 -od \x22$PTOMDirOutput\x22 -dem \x22$PTOMDEMFile \x22 -th \x22$PTOMHeightFile\x22 -nwr $PTOMNwinL -nwc $PTOMNwinC -ind $PTOMind -rc $PTOMrowcut -cd $PTOMDEM -zmin $PTOMzmin -zmax $PTOMzmax -dz $PTOMdz" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"    

        set ConfigFileTomo "$PTOMDirOutput/config.txt"  
        WaitUntilCreated $ConfigFileTomo
        if [file exists $ConfigFileTomo] {
            set f [open $ConfigFileTomo r]
            gets $f tmp
            gets $f PTOMNligFullSize
            gets $f tmp
            gets $f tmp
            gets $f PTOMNcolFullSize
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f PTOMzdim
            gets $f tmp
            gets $f tmp
            gets $f PTOMxdim
            gets $f tmp
            gets $f tmp
            gets $f PTOMzmin
            gets $f tmp
            gets $f tmp
            gets $f PTOMzmax
            gets $f tmp
            gets $f tmp
            gets $f PTOMxmin
            gets $f tmp
            gets $f tmp
            gets $f PTOMxmax
            close $f
            set PTOMNligInit "1"; set PTOMNcolInit "1";
            set PTOMNligEnd $PTOMNligFullSize; set PTOMNcolEnd $PTOMNcolFullSize        
            }
            
        EnviWriteConfigT $PTOMDirOutput $PTOMNligEnd $PTOMNcolEnd
        EnviWriteConfig "$PTOMDirOutput/DEM_profile.bin" $PTOMNligEnd $PTOMNcolEnd 4            
        EnviWriteConfig "$PTOMDirOutput/z_top_profile.bin" $PTOMNligEnd $PTOMNcolEnd 4            
        }
    }
}} \
		-padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_5_0.cpd67" "Button524" vTcl:WidgetProc "Toplevel524" 1
    button $site_5_0.but23 \
		-background {#ff8000} \
		-command {HelpPdfEdit "Help/data_process_dual/DisplayPolarizationCoherenceTomography.pdf"} \
		-image [vTcl:image:get_image [file join . GUI Images help.gif]] \
		-pady 0 -width 20 
    vTcl:DefineAlias "$site_5_0.but23" "Button16" vTcl:WidgetProc "Toplevel524" 1
    bindtags $site_5_0.but23 "$site_5_0.but23 Button $top all _vTclBalloon"
    bind $site_5_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_5_0.but24 \
		-background {#ffff00} \
		-command {global OpenDirFile Load_PolarTomographyGeneratorDEMzTop

if {$OpenDirFile == 0} {
Window hide .top401tomo
ClosePSPViewer
if {$Load_PolarTomographyGeneratorDEMzTop == 1} {
    Window hide $widget(Toplevel527); TextEditorRunTrace "Close Window Polarimetric Tomography - DEM & z-Top Generator" "b"
    }
Window hide $widget(Toplevel524); TextEditorRunTrace "Close Window Polarimetric Tomography - Generator Tomograms" "b"
}} \
		-padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_5_0.but24" "Button525" vTcl:WidgetProc "Toplevel524" 1
    bindtags $site_5_0.but24 "$site_5_0.but24 Button $top all _vTclBalloon"
    bind $site_5_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_5_0.cpd67 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but23 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but24 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra66 \
		-in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.fra69 \
		-in $site_4_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $site_4_0.fra87 \
		-in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd72 \
		-in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_3_0.cpd78 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra72 \
		-in $site_3_0 -anchor center -expand 1 -fill both -side right 
    frame $top.fra70 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame12" vTcl:WidgetProc "Toplevel524" 1
    menu $top.m71 \
		-activeborderwidth 1 -borderwidth 1 -cursor {}  
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd66 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra57 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd72 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra71 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra70 \
		-in $top -anchor center -expand 0 -fill x -side top 

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
Window show .top524

main $argc $argv
