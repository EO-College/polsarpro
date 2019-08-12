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
    set base .top523
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
    set site_3_0 $base.fra44
    set site_3_0 $base.fra70
    set site_5_0 [$site_3_0.cpd71 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd74
    set site_6_0 $site_5_0.cpd72
    set site_5_0 [$site_3_0.cpd73 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd74
    set site_6_0 $site_5_0.cpd72
    set site_4_0 $site_3_0.fra74
    set site_3_0 $base.fra92
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top523
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
    wm geometry $top 200x200+264+264; update
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

proc vTclWindow.top523 {base} {
    if {$base == ""} {
        set base .top523
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
    wm geometry $top 500x220+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Polarimetric Tomography ( Pol-TomSAR ) - Coherence Maps"
    vTcl:DefineAlias "$top" "Toplevel523" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd66 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame21" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.cpd66
    TitleFrame $site_3_0.cpd67 \
		-ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame12" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame54" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd75
    entry $site_6_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMOutputDir 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry67" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.cpd69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd69" "Entry64" vTcl:WidgetProc "Toplevel523" 1
    label $site_6_0.cpd70 \
		-text / -width 2 
    vTcl:DefineAlias "$site_6_0.cpd70" "Label40" vTcl:WidgetProc "Toplevel523" 1
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
    vTcl:DefineAlias "$top.cpd67" "TitleFrame523_1" vTcl:WidgetProc "Toplevel523" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame70" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.cpd75
    entry $site_5_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMDEMFile 
    vTcl:DefineAlias "$site_5_0.cpd71" "Entry523_1" vTcl:WidgetProc "Toplevel523" 1
    button $site_5_0.cpd70 \
		\
		-command {global FileName PTOMDirInput PTOMDEMFile PTOMDEM

set types {
    {{Bin Files}        {.bin}        }
    }
set FileName ""
OpenFile "$PTOMDirInput" $types "2D SLANT-RANGE DEM FILE"
if {$FileName != ""} {
    set PTOMDEMFile $FileName
    set PTOMDEM 0
    $widget(Checkbutton523_0) configure -state normal
    $widget(Button523_2) configure -state disable  
    } else {
    set PTOMDEMFile "Select or Generate Slant-Range DEM File"
    $widget(Checkbutton523_0) configure -state disable
    $widget(Button523_2) configure -state normal
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd70" "Button523_1" vTcl:WidgetProc "Toplevel523" 1
    pack $site_5_0.cpd71 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd70 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra44 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra44" "Frame3" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.fra44
    label $site_3_0.lab45 \
		-text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab45" "Label1" vTcl:WidgetProc "Toplevel523" 1
    entry $site_3_0.ent49 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent49" "Entry1" vTcl:WidgetProc "Toplevel523" 1
    label $site_3_0.cpd46 \
		-text {End Row} 
    vTcl:DefineAlias "$site_3_0.cpd46" "Label2" vTcl:WidgetProc "Toplevel523" 1
    entry $site_3_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd50" "Entry2" vTcl:WidgetProc "Toplevel523" 1
    label $site_3_0.cpd47 \
		-text {Init Col} 
    vTcl:DefineAlias "$site_3_0.cpd47" "Label3" vTcl:WidgetProc "Toplevel523" 1
    entry $site_3_0.cpd51 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.cpd51" "Entry3" vTcl:WidgetProc "Toplevel523" 1
    label $site_3_0.cpd48 \
		-text {End Col} 
    vTcl:DefineAlias "$site_3_0.cpd48" "Label4" vTcl:WidgetProc "Toplevel523" 1
    entry $site_3_0.cpd52 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd52" "Entry4" vTcl:WidgetProc "Toplevel523" 1
    pack $site_3_0.lab45 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.ent49 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd46 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd50 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd47 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd51 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd48 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd52 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra70 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame1" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.fra70
    TitleFrame $site_3_0.cpd71 \
		-ipad 1 -text {Window Size} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame524" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    frame $site_5_0.cpd74 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame82" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab85 \
		-text Row 
    vTcl:DefineAlias "$site_6_0.lab85" "Label23" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.cpd95 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMCohMapNwinL -width 5 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry22" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.lab85 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd72 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame83" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd72
    entry $site_6_0.cpd88 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMCohMapNwinC -width 5 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry23" vTcl:WidgetProc "Toplevel523" 1
    label $site_6_0.cpd94 \
		-text {  Col} 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label28" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.cpd88 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_6_0.cpd94 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
		-in $site_5_0 -anchor center -expand 1 -fill none -pady 2 -side top 
    pack $site_5_0.cpd72 \
		-in $site_5_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    TitleFrame $site_3_0.cpd73 \
		-ipad 1 -text Sub-Sampling 
    vTcl:DefineAlias "$site_3_0.cpd73" "TitleFrame525" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd73 getframe]
    frame $site_5_0.cpd74 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame84" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab85 \
		-text Row 
    vTcl:DefineAlias "$site_6_0.lab85" "Label26" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.cpd95 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMCohMapSSL -width 5 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry24" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.lab85 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd72 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame85" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd72
    entry $site_6_0.cpd88 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMCohMapSSC -width 5 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry25" vTcl:WidgetProc "Toplevel523" 1
    label $site_6_0.cpd94 \
		-text {  Col} 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label29" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.cpd88 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_6_0.cpd94 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
		-in $site_5_0 -anchor center -expand 1 -fill none -pady 2 -side top 
    pack $site_5_0.cpd72 \
		-in $site_5_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_3_0.fra74 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra74" "Frame2" vTcl:WidgetProc "Toplevel523" 1
    set site_4_0 $site_3_0.fra74
    checkbutton $site_4_0.cpd75 \
		-text {DEM compensation} -variable PTOMDEM 
    vTcl:DefineAlias "$site_4_0.cpd75" "Checkbutton523_0" vTcl:WidgetProc "Toplevel523" 1
    button $site_4_0.cpd76 \
		-background {#ffff00} \
		-command {global PTOMgeneDEM PTOMDEMFile PTOMSRunitDEM PTOMNRvalDEM PTOMFRvalDEM
global OpenDirFile PTOMDirInput
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType

global Load_PolarTomographyGeneratorDEM PSPTopLevel

if {$OpenDirFile == 0} {

    if {$Load_PolarTomographyGeneratorDEM == 0} {
        source "GUI/data_process_mult/PolarTomographyGeneratorDEM.tcl"
        set Load_PolarTomographyGeneratorDEM 1
        WmTransient $widget(Toplevel526) $PSPTopLevel
        }

    $widget(TitleFrame526_1) configure -state disable; $widget(TitleFrame526_2) configure -state disable; $widget(TitleFrame526_3) configure -state disable
    $widget(Radiobutton526_1) configure -state disable; $widget(Radiobutton526_2) configure -state disable
    $widget(Label526_1) configure -state disable; $widget(Label526_2) configure -state disable
    $widget(Entry526_1) configure -state disable; $widget(Entry526_2) configure -state disable
    set PTOMgeneDEM 0
    set PTOMSRunitDEM " "; set PTOMNRvalDEM " "; set PTOMFRvalDEM " "
    if [file exists $PTOMDEMFile] {
        $widget(Checkbutton526_1) configure -state disable
        } else {
        $widget(Checkbutton526_1) configure -state normal
        set PTOMDEMFile "Generate Input Slant-Range DEM File"
        }

    WidgetShowFromMenuFix $widget(Toplevel523) $widget(Toplevel526); TextEditorRunTrace "Open Window Polarimetric Tomography - Generator DEM" "b"
    }} \
		-padx 4 -pady 2 -text {DEM Generator} 
    vTcl:DefineAlias "$site_4_0.cpd76" "Button523_2" vTcl:WidgetProc "Toplevel523" 1
    pack $site_4_0.cpd75 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd76 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_3_0.cpd71 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd73 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra74 \
		-in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra92 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.fra92
    button $site_3_0.cpd67 \
		-background {#ffff00} \
		-command {global PTOMDirInput PTOMDEM PTOMDEMFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global OpenDirFile PTOMCohMapNwinL PTOMCohMapNwinC PTOMCohMapSSL PTOMCohMapSSL

if {$OpenDirFile == 0} {
    set TestVarName(0) "Slant-Range DEM File"; set TestVarType(0) "file"; set TestVarValue(0) $PTOMDEMFile; set TestVarMin(0) ""; set TestVarMax(0) ""
    TestVar 1
    if {$TestVarError == "ok"} {
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_mult/Tomo_coh_disp.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMDirInput\x22 -dem \x22$PTOMDEMFile\x22 -nwr $PTOMCohMapNwinL -nwc $PTOMCohMapNwinC -fr $PTOMCohMapSSL -fc $PTOMCohMapSSC -cd $PTOMDEM" "k"
        set f [ open "| Soft/bin/data_process_mult/Tomo_coh_disp.exe -id \x22$PTOMDirInput\x22 -dem \x22$PTOMDEMFile\x22 -nwr $PTOMCohMapNwinL -nwc $PTOMCohMapNwinC -fr $PTOMCohMapSSL -fc $PTOMCohMapSSC -cd $PTOMDEM" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"    
        if {$PTOMDEM == 0} {
            if [file exists "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_lexico_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Space_pol_lexico_tomographic_coherences.bmp" }
            if [file exists "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences.bmp" }
            } else {
            if [file exists "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences_DEMcomp.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_lexico_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Space_pol_lexico_tomographic_coherences_DEMcomp.bmp" }
            if [file exists "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences_DEMcomp.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences_DEMcomp.bmp" }
            }
        }
    }} \
		-padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button523" vTcl:WidgetProc "Toplevel523" 1
    button $site_3_0.but23 \
		-background {#ff8000} \
		-command {HelpPdfEdit "Help/data_process_dual/DisplayPolarizationCoherenceTomography.pdf"} \
		-image [vTcl:image:get_image [file join . GUI Images help.gif]] \
		-pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel523" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
		-background {#ffff00} \
		-command {global OpenDirFile Load_PolarTomographyGeneratorDEM

if {$OpenDirFile == 0} {
if {$Load_PolarTomographyGeneratorDEM == 1} {
    Window hide $widget(Toplevel526); TextEditorRunTrace "Close Window Polarimetric Tomography Generator" "b"
    }
Window hide $widget(Toplevel523); TextEditorRunTrace "Close Window Polarimetric - Tomography Coherence Maps" "b"
}} \
		-padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button523_0" vTcl:WidgetProc "Toplevel523" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd67 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
		-activeborderwidth 1 -borderwidth 1 -cursor {}  
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd66 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra44 \
		-in $top -anchor center -expand 0 -fill both -pady 5 -side top 
    pack $top.fra70 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
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
Window show .top523

main $argc $argv
