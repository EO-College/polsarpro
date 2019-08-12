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

        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

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
    set base .top334
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra56 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra56
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit74 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra80 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra80
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra75 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra75
    namespace eval ::widgets::$site_5_0.tit76 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit76 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-borderwidth 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-borderwidth 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd82 {
        array set save {-borderwidth 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd66
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd69
    namespace eval ::widgets::$site_7_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent86 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd70
    namespace eval ::widgets::$site_7_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent86 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd79 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-borderwidth 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-borderwidth 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -anchor 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m71 {
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
            vTclWindow.top334
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
    wm geometry $top 200x200+25+25; update
    wm maxsize $top 3360 1028
    wm minsize $top 116 1
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

proc vTclWindow.top334 {base} {
    if {$base == ""} {
        set base .top334
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
    wm geometry $top 500x380+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Compact Polarimetric Mode"
    vTcl:DefineAlias "$top" "Toplevel334" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame1" vTcl:WidgetProc "Toplevel334" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel334" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HybridDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel334" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel334" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel334" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel334" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable HybridOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel334" 1
    frame $site_5_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame2" vTcl:WidgetProc "Toplevel334" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.lab74 \
        -text {/ } 
    vTcl:DefineAlias "$site_6_0.lab74" "Label1" vTcl:WidgetProc "Toplevel334" 1
    entry $site_6_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HybridOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd76" "Entry1" vTcl:WidgetProc "Toplevel334" 1
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel334" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd87 \
        \
        -command {global DirName DataDir HybridOutputDir
global VarWarning WarningMessage WarningMessage2

set HybridDirOutputTmp $HybridOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set HybridOutputDir $DirName
        } else {
        set HybridOutputDir $HybridDirOutputTmp
        }
    } else {
    set HybridOutputDir $HybridDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd87 "$site_6_0.cpd87 Button $top all _vTclBalloon"
    bind $site_6_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra56 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra56" "Frame9" vTcl:WidgetProc "Toplevel334" 1
    set site_3_0 $top.fra56
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel334" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel334" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel334" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel334" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel334" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel334" 1
    label $site_3_0.lab63 \
        -padx 1 -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel334" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel334" 1
    pack $site_3_0.lab57 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent58 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab59 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent60 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab61 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent62 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab63 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_3_0.ent64 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit74 \
        -ipad 2 -text {Compact Polarimetric Mode - Rx = ( H , V )} 
    vTcl:DefineAlias "$top.tit74" "TitleFrame2" vTcl:WidgetProc "Toplevel334" 1
    bind $top.tit74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit74 getframe]
    radiobutton $site_4_0.rad75 \
        -command {$widget(Checkbutton334_1) configure -state normal} \
        -text {Tx = Linear +45° } -value pi4 -variable HybridMode 
    vTcl:DefineAlias "$site_4_0.rad75" "Radiobutton1" vTcl:WidgetProc "Toplevel334" 1
    radiobutton $site_4_0.cpd76 \
        -command {$widget(Checkbutton334_1) configure -state normal} \
        -text {Tx = Left Circular} -value lhv -variable HybridMode 
    vTcl:DefineAlias "$site_4_0.cpd76" "Radiobutton2" vTcl:WidgetProc "Toplevel334" 1
    radiobutton $site_4_0.cpd77 \
        -command {$widget(Checkbutton334_1) configure -state normal} \
        -text {Tx = Right Circular} -value rhv -variable HybridMode 
    vTcl:DefineAlias "$site_4_0.cpd77" "Radiobutton3" vTcl:WidgetProc "Toplevel334" 1
    pack $site_4_0.rad75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd74 \
        -ipad 2 -text {Reconstructed Pseudo Full - Polar Data} 
    vTcl:DefineAlias "$top.cpd74" "TitleFrame1" vTcl:WidgetProc "Toplevel334" 1
    bind $top.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd74 getframe]
    frame $site_4_0.fra80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra80" "Frame4" vTcl:WidgetProc "Toplevel334" 1
    set site_5_0 $site_4_0.fra80
    checkbutton $site_5_0.cpd81 \
        \
        -command {global HybridMode HybridConstruct HybridOutputFormat HybridMethod
global PSPBackgroundColor NwinHybridL NwinHybridC

if {$HybridMode != ""} {
if {$HybridConstruct == 0} {
    set HybridOutputFormat ""
    set HybridMethod ""
    $widget(TitleFrame334_1) configure -state disable
    $widget(TitleFrame334_2) configure -state disable
    $widget(Radiobutton334_1) configure -state disable
    $widget(Radiobutton334_2) configure -state disable
    $widget(Radiobutton334_3) configure -state disable
    $widget(Radiobutton334_4) configure -state disable
    $widget(Radiobutton334_5) configure -state disable
    $widget(Label334_1) configure -state disable
    $widget(Label334_2) configure -state disable
    $widget(Entry334_1) configure -state disable
    $widget(Entry334_2) configure -state disable
    $widget(Entry334_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry334_2) configure -disabledbackground $PSPBackgroundColor
    set NwinHybridL ""; set NwinHybridC ""
    }
if {$HybridConstruct == 1} {
    set HybridOutputFormat "C3"
    set HybridMethod "polar"
    $widget(TitleFrame334_1) configure -state normal
    $widget(TitleFrame334_2) configure -state normal
    $widget(Radiobutton334_1) configure -state normal
    if {$HybridMode == "pi4"} { $widget(Radiobutton334_2) configure -state normal }
    $widget(Radiobutton334_3) configure -state normal
    $widget(Radiobutton334_4) configure -state normal
    $widget(Radiobutton334_5) configure -state normal
    $widget(Label334_1) configure -state normal
    $widget(Label334_2) configure -state normal
    $widget(Entry334_1) configure -state normal
    $widget(Entry334_2) configure -state normal
    $widget(Entry334_1) configure -disabledbackground #FFFFFF
    $widget(Entry334_2) configure -disabledbackground #FFFFFF
    set NwinHybridL "7"; set NwinHybridC "7"
    }
} else {
set HybridConstruct 0
}} \
        -variable HybridConstruct 
    vTcl:DefineAlias "$site_5_0.cpd81" "Checkbutton334_1" vTcl:WidgetProc "Toplevel334" 1
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.fra75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra75" "Frame3" vTcl:WidgetProc "Toplevel334" 1
    set site_5_0 $site_4_0.fra75
    TitleFrame $site_5_0.tit76 \
        -text {Reconstruction Method} 
    vTcl:DefineAlias "$site_5_0.tit76" "TitleFrame334_1" vTcl:WidgetProc "Toplevel334" 1
    bind $site_5_0.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit76 getframe]
    radiobutton $site_7_0.cpd77 \
        -borderwidth 0 -text {Polar State Extrapolation} -value polar \
        -variable HybridMethod 
    vTcl:DefineAlias "$site_7_0.cpd77" "Radiobutton334_1" vTcl:WidgetProc "Toplevel334" 1
    radiobutton $site_7_0.cpd78 \
        -borderwidth 0 -text {Rotation Symmetry} -value rotsym \
        -variable HybridMethod 
    vTcl:DefineAlias "$site_7_0.cpd78" "Radiobutton334_2" vTcl:WidgetProc "Toplevel334" 1
    radiobutton $site_7_0.cpd82 \
        -borderwidth 0 -text {Rotation & Reflection Symmetry} \
        -value rotrefsym -variable HybridMethod 
    vTcl:DefineAlias "$site_7_0.cpd82" "Radiobutton334_3" vTcl:WidgetProc "Toplevel334" 1
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd82 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd66" "Frame10" vTcl:WidgetProc "Toplevel334" 1
    set site_6_0 $site_5_0.cpd66
    frame $site_6_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd69" "Frame13" vTcl:WidgetProc "Toplevel334" 1
    set site_7_0 $site_6_0.cpd69
    label $site_7_0.lab85 \
        -text {Window Size Row} 
    vTcl:DefineAlias "$site_7_0.lab85" "Label334_1" vTcl:WidgetProc "Toplevel334" 1
    entry $site_7_0.ent86 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NwinHybridL -width 3 
    vTcl:DefineAlias "$site_7_0.ent86" "Entry334_1" vTcl:WidgetProc "Toplevel334" 1
    pack $site_7_0.lab85 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_7_0.ent86 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd70" "Frame14" vTcl:WidgetProc "Toplevel334" 1
    set site_7_0 $site_6_0.cpd70
    label $site_7_0.lab85 \
        -text {Window Size Col} 
    vTcl:DefineAlias "$site_7_0.lab85" "Label334_2" vTcl:WidgetProc "Toplevel334" 1
    entry $site_7_0.ent86 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NwinHybridC -width 3 
    vTcl:DefineAlias "$site_7_0.ent86" "Entry334_2" vTcl:WidgetProc "Toplevel334" 1
    pack $site_7_0.lab85 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_7_0.ent86 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd79 \
        -text {Output Polarimetric Data Format} 
    vTcl:DefineAlias "$site_5_0.cpd79" "TitleFrame334_2" vTcl:WidgetProc "Toplevel334" 1
    bind $site_5_0.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd79 getframe]
    radiobutton $site_7_0.cpd77 \
        -borderwidth 0 -text {3x3 Covariance Matrix C3} -value C3 \
        -variable HybridOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd77" "Radiobutton334_4" vTcl:WidgetProc "Toplevel334" 1
    radiobutton $site_7_0.cpd78 \
        -borderwidth 0 -text {3x3 Coherency Matrix T3} -value T3 \
        -variable HybridOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd78" "Radiobutton334_5" vTcl:WidgetProc "Toplevel334" 1
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.tit76 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra80 \
        -in $site_4_0 -anchor center -expand 0 -fill both -side left 
    pack $site_4_0.fra75 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel334" 1
    set site_3_0 $top.fra92
    button $site_3_0.but93 \
        -anchor center -background #ffff00 \
        -command {global DirHybridChange HybridDirInput HybridDirOutput
global HybridFunction HybridFonction HybridMode HybridMethod TMPMemoryAllocError
global HybridConstruct HybridOutputFormat DataFormatActive NwinHybridL NwinHybridC
global Fonction Fonction2 ProgressLine VarFunction
global VarWarning WarningMessage WarningMessage2 PSPViewGimpBMP
global ConfigFile FinalNlig FinalNcol PolarCase PolarType OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax PSPViewGimpBMP

if {$OpenDirFile == 0} {

set HybridDirOutput $HybridOutputDir
if {$HybridOutputSubDir != ""} {append HybridDirOutput "/$HybridOutputSubDir"}
 
    #####################################################################
    #Create Directory
    set HybridDirOutput [PSPCreateDirectory $HybridDirOutput $HybridOutputDir "C2"]
    #####################################################################       
    
    if {"$VarWarning"=="ok"} {

        if {$HybridConstruct == "1"} {
            set HybridDirOutput $HybridOutputDir
            append HybridDirOutput "/$HybridOutputFormat"

            #####################################################################
            #Create Directory
            set HybridDirOutput [PSPCreateDirectory $HybridDirOutput $HybridOutputDir $HybridOutputFormat]
            #####################################################################       
            }

        if {"$VarWarning"=="ok"} {

            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            if {$HybridConstruct == "0"} {
                TestVar 4
                } else {
                set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinHybridL; set TestVarMin(4) "1"; set TestVarMax(4) "100"
                set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinHybridC; set TestVarMin(5) "1"; set TestVarMax(5) "100"
                TestVar 6
                }

            if {$TestVarError == "ok"} {
                set Fonction "Creation of the Binary Data Files"
                set Fonction2 "of a Compact Polarimetric Mode"
            
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]


                set MaskCmd ""
                set MaskFile "$HybridDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        
                if {$HybridConstruct == "0"} { set HybridMethod "NO"; set HybridOutputFormat "NO" }

                if {$HybridFonction == "S2"} {
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    set ProgressLine "0"
                    update
                    set ConvertOutputFormat "S2SPP"; append ConvertOutputFormat $HybridMode
                    TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$HybridDirInput\x22 -od \x22$HybridOutputDir\x22 -iodf $ConvertOutputFormat -sym 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nlr 1 -nlc 1 -ssr 1 -ssc 1  -errf \x22$TMPMemoryAllocError\x22" "k"
                    set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$HybridDirInput\x22 -od \x22$HybridOutputDir\x22 -iodf $ConvertOutputFormat -sym 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nlr 1 -nlc 1 -ssr 1 -ssc 1  -errf \x22$TMPMemoryAllocError\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    MapInfoWriteConfig $HybridOutputDir
                    EnviWriteConfigS $HybridOutputDir $FinalNlig $FinalNcol

                    set RGBDirInput $HybridOutputDir
                    set RGBFileOutput "$RGBDirInput/RGB1.bmp"
                    set Fonction "Creation of the RGB BMP File :"
                    set Fonction2 "$RGBFileOutput"    
                    set MaskCmd ""
                    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                    }

                set HybridDirOutput $HybridOutputDir; append HybridDirOutput "/C2"

                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                set ProgressLine "0"
                update
                if {$HybridFonction == "S2"} { set ConvertOutputFormat "S2C2" }
                if {$HybridFonction == "C3"} { set ConvertOutputFormat "C3C2" }
                if {$HybridFonction == "T3"} { set ConvertOutputFormat "T3C2" }
                append ConvertOutputFormat $HybridMode
                TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$HybridDirInput\x22 -od \x22$HybridDirOutput\x22 -iodf $ConvertOutputFormat -sym 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nlr 1 -nlc 1 -ssr 1 -ssc 1  -errf \x22$TMPMemoryAllocError\x22" "k"
                set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$HybridDirInput\x22 -od \x22$HybridDirOutput\x22 -iodf $ConvertOutputFormat -sym 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nlr 1 -nlc 1 -ssr 1 -ssc 1  -errf \x22$TMPMemoryAllocError\x22" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                MapInfoWriteConfig $HybridDirOutput
                EnviWriteConfigC $HybridDirOutput $FinalNlig $FinalNcol

                set RGBDirInput "$HybridOutputDir/C2"
                set RGBFileOutput "$RGBDirInput/RGB1.bmp"
                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set MaskCmd ""
                set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }


                if {$HybridConstruct == "1"} {
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    set ProgressLine "0"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/hybrid_polar.exe" "k"
                    TextEditorRunTrace "Arguments: -iod $HybridOutputDir -odf $HybridOutputFormat -nwr $NwinHybridL -nwc $NwinHybridC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mod $HybridMode -recm $HybridMethod  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/bin/data_process_sngl/hybrid_polar.exe -iod $HybridOutputDir -odf $HybridOutputFormat -nwr $NwinHybridL -nwc $NwinHybridC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mod $HybridMode -recm $HybridMethod  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                    MapInfoWriteConfig $HybridDirOutput

                    set HybridDirOutput $HybridOutputDir; append HybridDirOutput "/$HybridOutputFormat"
                    if {$HybridOutputFormat == "T3"} {EnviWriteConfigT $HybridDirOutput $FinalNlig $FinalNcol }
                    if {$HybridOutputFormat == "C3"} {EnviWriteConfigC $HybridDirOutput $FinalNlig $FinalNcol }

                    if {$HybridOutputFormat == "T3"} {set RGBDirInput "$HybridOutputDir/T3" }
                    if {$HybridOutputFormat == "C3"} {set RGBDirInput "$HybridOutputDir/C3" }
                    set RGBFileOutput "$RGBDirInput/PauliRGB.bmp"
                    set Fonction "Creation of the RGB BMP File :"
                    set Fonction2 "$RGBFileOutput"    
                    set MaskCmd ""
                    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $HybridOutputFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $HybridOutputFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                    }

                if {$HybridConstruct == "1"} {
                    set DataFormatActive $HybridOutputFormat
                    } else {
                    set DataFormatActive "C2"
                    }

                set BMPDirInput $HybridOutputDir
                set DataDir $HybridOutputDir
                Window hide $widget(Toplevel334); TextEditorRunTrace "Close Window Compact Polarimetric Mode" "b"
                }
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel334); TextEditorRunTrace "Close Window Compact Polarimetric Mode" "b"}
        }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel334" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CompactPolarimetricMode.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel334" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel334); TextEditorRunTrace "Close Window Compact Polarimetric Mode" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel334" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra56 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.tit74 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 1 -fill both -side top 
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
Window show .top334

main $argc $argv
