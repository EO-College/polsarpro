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
# Visual Tcl v1.60 Project
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
        .gif    {return photo}
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
    set base .top385
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra70
    namespace eval ::widgets::$site_3_0.che71 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.rad67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd68
    namespace eval ::widgets::$site_4_0.che71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad69 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd72
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.fra68 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra68
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$base.m66 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top385
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
    wm geometry $top 200x200+22+22; update
    wm maxsize $top 1284 785
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

proc vTclWindow.top385 {base} {
    if {$base == ""} {
        set base .top385
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m66" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x260+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "MapReady - Terrain Correction"
    vTcl:DefineAlias "$top" "Toplevel385" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd66 \
        -ipad 0 -text {Input DEM File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame385" vTcl:WidgetProc "Toplevel385" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapReadyDEMFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh5" vTcl:WidgetProc "Toplevel385" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame14" vTcl:WidgetProc "Toplevel385" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -command {global FileName MapReadyDirInput MapReadyDEMFile
global ErrorMessage VarError

set types {
    {{Tif Files}        {.tif}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $MapReadyDirInput $types "INPUT DEM FILE"
set MapReadyDEMFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button4" vTcl:WidgetProc "Toplevel385" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame3" vTcl:WidgetProc "Toplevel385" 1
    set site_3_0 $top.fra70
    checkbutton $site_3_0.che71 \
        -text {Fill DEM holes with interpolated values} \
        -variable MapReadyTerrainSmooth 
    vTcl:DefineAlias "$site_3_0.che71" "Checkbutton1" vTcl:WidgetProc "Toplevel385" 1
    pack $site_3_0.che71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame2" vTcl:WidgetProc "Toplevel385" 1
    set site_3_0 $top.fra66
    radiobutton $site_3_0.rad67 \
        \
        -command {global MapReadyTerrainAutoMask MapReadyTerrainMask
global MapReadyMaskFile MapReadyTerrainInterp MapReadyTerrainSave
global MapReadyTerrainRadio MapReadyTerrainSkip

set MapReadyTerrainAutoMask "0"; set MapReadyTerrainMask ""
set MapReadyMaskFile ""; set MapReadyTerrainInterp "0"; set MapReadyTerrainSave "0"
set MapReadyTerrainRadio "0"; set MapReadyTerrainSkip "0"

$widget(Checkbutton385_1) configure -state disable
$widget(Checkbutton385_2) configure -state disable
$widget(Checkbutton385_3) configure -state disable
$widget(Checkbutton385_4) configure -state disable
$widget(Checkbutton385_5) configure -state disable
$widget(Radiobutton385_1) configure -state disable
$widget(Radiobutton385_2) configure -state disable
$widget(TitleFrame385_1) configure -state disable
$widget(Entry385_1) configure -state disable
$widget(Entry385_1) configure -disabledbackground $PSPBackgroundColor
$widget(Button385_1) configure -state disable} \
        -text {Refine Geolocation Only} -value geo \
        -variable MapReadyTerrainGeo 
    vTcl:DefineAlias "$site_3_0.rad67" "Radiobutton385_3" vTcl:WidgetProc "Toplevel385" 1
    radiobutton $site_3_0.cpd68 \
        \
        -command {global MapReadyTerrainAutoMask MapReadyTerrainMask
global MapReadyMaskFile MapReadyTerrainInterp MapReadyTerrainSave
global MapReadyTerrainRadio MapReadyTerrainSkip

set MapReadyTerrainAutoMask "0"; set MapReadyTerrainMask ""
set MapReadyMaskFile ""; set MapReadyTerrainInterp "1"; set MapReadyTerrainSave "1"
set MapReadyTerrainRadio "0"; set MapReadyTerrainSkip "0"

$widget(Checkbutton385_1) configure -state normal
$widget(Checkbutton385_2) configure -state normal
$widget(Checkbutton385_3) configure -state normal
$widget(Checkbutton385_4) configure -state normal
$widget(Checkbutton385_5) configure -state normal
$widget(Radiobutton385_1) configure -state disable
$widget(Radiobutton385_2) configure -state disable
$widget(TitleFrame385_1) configure -state disable
$widget(Entry385_1) configure -state disable
$widget(Entry385_1) configure -disabledbackground $PSPBackgroundColor
$widget(Button385_1) configure -state disable} \
        -text {Apply Terrain Correction} -value correc \
        -variable MapReadyTerrainGeo 
    vTcl:DefineAlias "$site_3_0.cpd68" "Radiobutton385_4" vTcl:WidgetProc "Toplevel385" 1
    pack $site_3_0.rad67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame1" vTcl:WidgetProc "Toplevel385" 1
    set site_3_0 $top.fra67
    frame $site_3_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd68" "Frame4" vTcl:WidgetProc "Toplevel385" 1
    set site_4_0 $site_3_0.cpd68
    checkbutton $site_4_0.che71 \
        \
        -command {global MapReadyTerrainAutoMask MapReadyTerrainMask
global MapReadyMaskFile

if {$MapReadyTerrainAutoMask == 1} {
    set MapReadyTerrainMask "auto"
    set MapReadyMaskFile ""
    $widget(Radiobutton385_1) configure -state normal
    $widget(Radiobutton385_2) configure -state normal
    $widget(TitleFrame385_1) configure -state disable
    $widget(Entry385_1) configure -state disable
    $widget(Entry385_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button385_1) configure -state disable
    }
if {$MapReadyTerrainAutoMask == 0} {
    set MapReadyTerrainMask ""
    set MapReadyMaskFile ""
    $widget(Radiobutton385_1) configure -state disable
    $widget(Radiobutton385_2) configure -state disable
    $widget(TitleFrame385_1) configure -state disable
    $widget(Entry385_1) configure -state disable
    $widget(Entry385_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button385_1) configure -state disable
    }} \
        -text {Apply a User Mask} -variable MapReadyTerrainAutoMask 
    vTcl:DefineAlias "$site_4_0.che71" "Checkbutton385_1" vTcl:WidgetProc "Toplevel385" 1
    radiobutton $site_4_0.rad69 \
        \
        -command {global MapReadyMaskFile

set MapReadyMaskFile ""
$widget(TitleFrame385_1) configure -state disable
$widget(Entry385_1) configure -state disable
$widget(Entry385_1) configure -disabledbackground $PSPBackgroundColor
$widget(Button385_1) configure -state disable} \
        -text {Automatically Mask} -value auto -variable MapReadyTerrainMask 
    vTcl:DefineAlias "$site_4_0.rad69" "Radiobutton385_1" vTcl:WidgetProc "Toplevel385" 1
    radiobutton $site_4_0.cpd70 \
        \
        -command {global MapReadyMaskFile

set MapReadyMaskFile ""
$widget(TitleFrame385_1) configure -state normal
$widget(Entry385_1) configure -state normal
$widget(Entry385_1) configure -disabledbackground #FFFFFF
$widget(Button385_1) configure -state normal} \
        -text {Mask from File} -value file -variable MapReadyTerrainMask 
    vTcl:DefineAlias "$site_4_0.cpd70" "Radiobutton385_2" vTcl:WidgetProc "Toplevel385" 1
    pack $site_4_0.che71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.rad69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Input Mask File} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame385_1" vTcl:WidgetProc "Toplevel385" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapReadyMaskFile 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry385_1" vTcl:WidgetProc "Toplevel385" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel385" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global FileName MapReadyDirInput MapReadyMaskFile
global ErrorMessage VarError

set types {
    {{Img Files}        {.img}        }
    {{Tif Files}        {.tif}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $MapReadyDirInput $types "INPUT MASK FILE"
set MapReadyMaskFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button385_1" vTcl:WidgetProc "Toplevel385" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd72" "Frame5" vTcl:WidgetProc "Toplevel385" 1
    set site_4_0 $site_3_0.cpd72
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame9" vTcl:WidgetProc "Toplevel385" 1
    set site_5_0 $site_4_0.cpd66
    frame $site_5_0.fra68 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra68" "Frame10" vTcl:WidgetProc "Toplevel385" 1
    set site_6_0 $site_5_0.fra68
    checkbutton $site_6_0.cpd69 \
        -text {Skip Co-Registration (if it fails)} \
        -variable MapReadyTerrainSkip 
    vTcl:DefineAlias "$site_6_0.cpd69" "Checkbutton385_2" vTcl:WidgetProc "Toplevel385" 1
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame11" vTcl:WidgetProc "Toplevel385" 1
    set site_6_0 $site_5_0.cpd70
    checkbutton $site_6_0.cpd69 \
        -text {Apply Radiometric Terrain Correction} \
        -variable MapReadyTerrainRadio 
    vTcl:DefineAlias "$site_6_0.cpd69" "Checkbutton385_3" vTcl:WidgetProc "Toplevel385" 1
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra68 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame13" vTcl:WidgetProc "Toplevel385" 1
    set site_5_0 $site_4_0.cpd67
    frame $site_5_0.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame18" vTcl:WidgetProc "Toplevel385" 1
    set site_6_0 $site_5_0.cpd71
    checkbutton $site_6_0.cpd69 \
        -text {Interpolate Layover / Shadow Regions} \
        -variable MapReadyTerrainInterp 
    vTcl:DefineAlias "$site_6_0.cpd69" "Checkbutton385_4" vTcl:WidgetProc "Toplevel385" 1
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame17" vTcl:WidgetProc "Toplevel385" 1
    set site_6_0 $site_5_0.cpd70
    checkbutton $site_6_0.cpd69 \
        -text {Save Layover / Shadow Mask} -variable MapReadyTerrainSave 
    vTcl:DefineAlias "$site_6_0.cpd69" "Checkbutton385_5" vTcl:WidgetProc "Toplevel385" 1
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel385" 1
    set site_3_0 $top.fra59
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit ""} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel385" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m66 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra70 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra59 \
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
Window show .top385

main $argc $argv
