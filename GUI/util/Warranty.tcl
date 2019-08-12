#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

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

        {{[file join . GUI Images logo_univ2.gif]} {user image} user {}}
        {{[file join . GUI Images logo_ietr2.gif]} {user image} user {}}
        {{[file join . GUI Images logo_saphir2.gif]} {user image} user {}}
        {{[file join . GUI Images esa2002.gif]} {user image} user {}}

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
    set base .top88
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.fra89
    set site_3_0 $base.fra90
    set site_4_0 $site_3_0.cpd85
    set site_3_0 $base.fra44
    set site_4_0 $site_3_0.cpd45
    set site_4_0 $site_3_0.cpd47
    set site_4_0 $site_3_0.cpd48
    set site_3_0 $base.fra91
    set site_4_0 $site_3_0.cpd90
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top88
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
    wm geometry $top 200x200+104+104; update
    wm maxsize $top 1924 1181
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top88 {base} {
    if {$base == ""} {
        set base .top88
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-background {#ffffff} 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 450x500+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSarPro Disclaimer of Warranty"
    vTcl:DefineAlias "$top" "Toplevel88" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    frame $top.fra89 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra89" "Frame428" vTcl:WidgetProc "Toplevel88" 1
    set site_3_0 $top.fra89
    label $site_3_0.lab96 \
		-background {#ffffff} \
		-image [vTcl:image:get_image [file join . GUI Images logo_univ2.gif]] \
		-text label 
    vTcl:DefineAlias "$site_3_0.lab96" "Label452" vTcl:WidgetProc "Toplevel88" 1
    label $site_3_0.lab97 \
		-background {#ffffff} \
		-image [vTcl:image:get_image [file join . GUI Images logo_ietr2.gif]] \
		-text label 
    vTcl:DefineAlias "$site_3_0.lab97" "Label453" vTcl:WidgetProc "Toplevel88" 1
    label $site_3_0.lab98 \
		-background {#ffffff} \
		-image [vTcl:image:get_image [file join . GUI Images logo_saphir2.gif]] \
		-text label 
    vTcl:DefineAlias "$site_3_0.lab98" "Label454" vTcl:WidgetProc "Toplevel88" 1
    pack $site_3_0.lab96 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab97 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab98 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra90 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 211 
    vTcl:DefineAlias "$top.fra90" "Frame416" vTcl:WidgetProc "Toplevel88" 1
    set site_3_0 $top.fra90
    label $site_3_0.lab23 \
		-activebackground {#ffffff} -background {#ffffff} \
		-foreground {#ff0000} -relief raised -text {DISCLAIMER OF WARRANTY} 
    vTcl:DefineAlias "$site_3_0.lab23" "Label445" vTcl:WidgetProc "Toplevel88" 1
    frame $site_3_0.cpd85 \
		-borderwidth 2 -relief raised -background {#ffffff} -height 75 \
		-width 125 
    vTcl:DefineAlias "$site_3_0.cpd85" "Frame417" vTcl:WidgetProc "Toplevel88" 1
    set site_4_0 $site_3_0.cpd85
    text $site_4_0.tex87 \
		-background white -height 10 -relief flat -width 50 
    vTcl:DefineAlias "$site_4_0.tex87" "TextWarranty" vTcl:WidgetProc "Toplevel88" 1
    pack $site_4_0.tex87 \
		-in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_3_0.lab23 \
		-in $site_3_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd85 \
		-in $site_3_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra44 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra44" "Frame1" vTcl:WidgetProc "Toplevel88" 1
    set site_3_0 $top.fra44
    frame $site_3_0.cpd45 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd45" "Frame2" vTcl:WidgetProc "Toplevel88" 1
    set site_4_0 $site_3_0.cpd45
    button $site_4_0.cpd46 \
		-background {#ffffff} \
		-command {#UTIL
global Load_TextEdit PSPTopLevel 
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

TextEditorFromWidget .top88 "License/PolSARpro_v6.0_Biomass_Edition_LICENSE.txt"
.top95.fra97.tex100 configure -wrap word} \
		-foreground {#ff0000} -pady 0 \
		-text {EDIT PolSARpro v6.0 (Biomass Edition) : LICENSE} 
    vTcl:DefineAlias "$site_4_0.cpd46" "Button2" vTcl:WidgetProc "Toplevel88" 1
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd47 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd47" "Frame3" vTcl:WidgetProc "Toplevel88" 1
    set site_4_0 $site_3_0.cpd47
    button $site_4_0.cpd46 \
		-background {#ffffff} \
		-command {#UTIL
global Load_TextEdit PSPTopLevel 
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

TextEditorFromWidget .top88 "License/PolSARpro_v6.0_Biomass_Edition_LEGAL.txt"
.top95.fra97.tex100 configure -wrap word} \
		-foreground {#ff0000} -pady 0 \
		-text {EDIT PolSARpro v6.0 (Biomass Edition) : LEGAL} 
    vTcl:DefineAlias "$site_4_0.cpd46" "Button3" vTcl:WidgetProc "Toplevel88" 1
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd48 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd48" "Frame4" vTcl:WidgetProc "Toplevel88" 1
    set site_4_0 $site_3_0.cpd48
    button $site_4_0.cpd46 \
		-background {#ffffff} \
		-command {#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

TextEditorFromWidget .top88 "License/PolSARpro_v6.0_Biomass_Edition_CREDITS.txt"
.top95.fra97.tex100 configure -wrap word} \
		-foreground {#ff0000} -pady 0 \
		-text {EDIT PolSARpro v6.0 (Biomass Edition) : CREDITS} 
    vTcl:DefineAlias "$site_4_0.cpd46" "Button4" vTcl:WidgetProc "Toplevel88" 1
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd45 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd47 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd48 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra91 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra91" "Frame426" vTcl:WidgetProc "Toplevel88" 1
    set site_3_0 $top.fra91
    frame $site_3_0.cpd90 \
		-borderwidth 2 -background {#ffffff} -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd90" "Frame427" vTcl:WidgetProc "Toplevel88" 1
    set site_4_0 $site_3_0.cpd90
    label $site_4_0.lab103 \
		-background {#ffffff} -text {Copyright (c) } 
    vTcl:DefineAlias "$site_4_0.lab103" "Label437" vTcl:WidgetProc "Toplevel88" 1
    label $site_4_0.lab88 \
		-background {#ffffff} \
		-image [vTcl:image:get_image [file join . GUI Images esa2002.gif]] \
		-text label 
    vTcl:DefineAlias "$site_4_0.lab88" "Label2" vTcl:WidgetProc "Toplevel88" 1
    pack $site_4_0.lab103 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.lab88 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.but106 \
		-background {#ffff00} \
		-command {global OpenDirFile
if {$OpenDirFile == 0} {
.top95.fra97.tex100 delete 1.0 end
wm title .top95 ""
Window hide $widget(Toplevel95); TextEditorRunTrace "Close Window Text Editor" "b"
Window hide $widget(Toplevel88); TextEditorRunTrace "Close Window Warranty" "b"
}} \
		-padx 4 -pady 2 -text Exit -width 4 
    vTcl:DefineAlias "$site_3_0.but106" "Button35" vTcl:WidgetProc "Toplevel88" 1
    bindtags $site_3_0.but106 "$site_3_0.but106 Button $top all _vTclBalloon"
    bind $site_3_0.but106 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd90 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but106 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra89 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra90 \
		-in $top -anchor center -expand 1 -fill y -pady 10 -side top 
    pack $top.fra44 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra91 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 

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
Window show .top88

main $argc $argv
