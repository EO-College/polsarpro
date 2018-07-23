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

        {{[file join . GUI Images PISAR.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top227
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab47 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd133 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd133
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
    namespace eval ::widgets::$site_6_0.cpd140 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.fra31 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra31
    namespace eval ::widgets::$site_6_0.che49 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra34 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra34
    namespace eval ::widgets::$site_6_0.lab35 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.fra31 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra31
    namespace eval ::widgets::$site_6_0.che50 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.lab33 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra34 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra34
    namespace eval ::widgets::$site_6_0.lab35 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.lab36 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd131 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd131
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd116 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd117 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra26 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra26
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top227
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

proc vTclWindow.top227 {base} {
    if {$base == ""} {
        set base .top227
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x530+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PISAR Input Data File"
    vTcl:DefineAlias "$top" "Toplevel227" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab47 \
        -image [vTcl:image:get_image [file join . GUI Images PISAR.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab47" "Label72" vTcl:WidgetProc "Toplevel227" 1
    frame $top.cpd133 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd133" "Frame1" vTcl:WidgetProc "Toplevel227" 1
    set site_3_0 $top.cpd133
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel227" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PISARDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel227" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd140 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd140" "Button37" vTcl:WidgetProc "Toplevel227" 1
    pack $site_6_0.cpd140 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit71 \
        -ipad 0 -text {PISAR Data Format} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel227" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame648" vTcl:WidgetProc "Toplevel227" 1
    set site_5_0 $site_4_0.cpd72
    frame $site_5_0.fra31 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra31" "Frame646" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.fra31
    checkbutton $site_6_0.che49 \
        \
        -command {global PISARDataFormat PISAR_MGPC PISAR_MGPSSC
if {$PISAR_MGPC == "1"} {
    set PISARDataFormat "MGPC"
    set PISAR_MGPSSC "0"
    $widget(Entry227_1) configure -disabledbackground #FFFFFF
    $widget(Button227_1) configure -state normal
    $widget(Entry227_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_2) configure -state disable
    $widget(Entry227_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_3) configure -state disable
    $widget(Entry227_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_4) configure -state disable
    $widget(Entry227_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_5) configure -state disable
    }
if {$PISAR_MGPC == "0"} {
    set PISARDataFormat "MGPSSC"
    set PISAR_MGPSSC "1"
    $widget(Entry227_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_1) configure -state disable
    $widget(Entry227_2) configure -disabledbackground #FFFFFF
    $widget(Button227_2) configure -state normal
    $widget(Entry227_3) configure -disabledbackground #FFFFFF
    $widget(Button227_3) configure -state normal
    $widget(Entry227_4) configure -disabledbackground #FFFFFF
    $widget(Button227_4) configure -state normal
    $widget(Entry227_5) configure -disabledbackground #FFFFFF
    $widget(Button227_5) configure -state normal
    }} \
        -text {MGP-C Data File} -variable PISAR_MGPC 
    vTcl:DefineAlias "$site_6_0.che49" "Checkbutton608" vTcl:WidgetProc "Toplevel227" 1
    pack $site_6_0.che49 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra34 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra34" "Frame647" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.fra34
    label $site_6_0.lab35 \
        -text {(Multi-look Ground Range - Compressed PolSar Data)} 
    vTcl:DefineAlias "$site_6_0.lab35" "Label513" vTcl:WidgetProc "Toplevel227" 1
    pack $site_6_0.lab35 \
        -in $site_6_0 -anchor e -expand 1 -fill none -side top 
    pack $site_5_0.fra31 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra34 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame653" vTcl:WidgetProc "Toplevel227" 1
    set site_5_0 $site_4_0.cpd73
    frame $site_5_0.fra31 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra31" "Frame651" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.fra31
    checkbutton $site_6_0.che50 \
        \
        -command {global PISARDataFormat PISAR_MGPC PISAR_MGPSSC
if {$PISAR_MGPSSC == "0"} {
    set PISARDataFormat "MGPC"
    set PISAR_MGPC "1"
    $widget(Entry227_1) configure -disabledbackground #FFFFFF
    $widget(Button227_1) configure -state normal
    $widget(Entry227_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_2) configure -state disable
    $widget(Entry227_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_3) configure -state disable
    $widget(Entry227_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_4) configure -state disable
    $widget(Entry227_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_5) configure -state disable
    }
if {$PISAR_MGPSSC == "1"} {
    set PISARDataFormat "MGPSSC"
    set PISAR_MGPC "0"
    $widget(Entry227_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button227_1) configure -state disable
    $widget(Entry227_2) configure -disabledbackground #FFFFFF
    $widget(Button227_2) configure -state normal
    $widget(Entry227_3) configure -disabledbackground #FFFFFF
    $widget(Button227_3) configure -state normal
    $widget(Entry227_4) configure -disabledbackground #FFFFFF
    $widget(Button227_4) configure -state normal
    $widget(Entry227_5) configure -disabledbackground #FFFFFF
    $widget(Button227_5) configure -state normal
    }} \
        -text {SSC or MGP Data Files} -variable PISAR_MGPSSC 
    vTcl:DefineAlias "$site_6_0.che50" "Checkbutton609" vTcl:WidgetProc "Toplevel227" 1
    label $site_6_0.lab33 \
        -text { } 
    vTcl:DefineAlias "$site_6_0.lab33" "Label515" vTcl:WidgetProc "Toplevel227" 1
    pack $site_6_0.che50 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.lab33 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra34 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra34" "Frame652" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.fra34
    label $site_6_0.lab35 \
        -text {(Single-look Slant Range Complex PolSar Data)} 
    vTcl:DefineAlias "$site_6_0.lab35" "Label516" vTcl:WidgetProc "Toplevel227" 1
    label $site_6_0.lab36 \
        -text {(Multi-look Ground Range PolSar Data)} 
    vTcl:DefineAlias "$site_6_0.lab36" "Label517" vTcl:WidgetProc "Toplevel227" 1
    pack $site_6_0.lab35 \
        -in $site_6_0 -anchor e -expand 1 -fill none -side top 
    pack $site_6_0.lab36 \
        -in $site_6_0 -anchor e -expand 1 -fill none -side top 
    pack $site_5_0.fra31 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra34 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame3" vTcl:WidgetProc "Toplevel227" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input MGP-C Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame11" vTcl:WidgetProc "Toplevel227" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputPISAR 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry227_1" vTcl:WidgetProc "Toplevel227" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd76 \
        \
        -command {global FileName PISARDirInput FileInputPISAR

set types {
    {{MGP_C Files}        {.MGP_C}   }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $PISARDirInput $types "INPUT FILE"
set FileInputPISAR $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd76" "Button227_1" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_6_0.cpd76 "$site_6_0.cpd76 Button $top all _vTclBalloon"
    bind $site_6_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd131 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd131" "Frame2" vTcl:WidgetProc "Toplevel227" 1
    set site_3_0 $top.cpd131
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel227" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputHH 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry227_2" vTcl:WidgetProc "Toplevel227" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd71 \
        \
        -command {global FileName PISARDirInput FileInputHH

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $PISARDirInput $types "HH INPUT FILE (s11)"
set FileInputHH $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button227_2" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_6_0.cpd71 "$site_6_0.cpd71 Button $top all _vTclBalloon"
    bind $site_6_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd116 \
        -ipad 0 -text {Input Data File ( s12 )} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame8" vTcl:WidgetProc "Toplevel227" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputHV 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry227_3" vTcl:WidgetProc "Toplevel227" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global FileName PISARDirInput FileInputHV

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $PISARDirInput $types "HV INPUT FILE (s12)"
set FileInputHV $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button227_3" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd117 \
        -ipad 0 -text {Input Data File ( s21 )} 
    vTcl:DefineAlias "$site_3_0.cpd117" "TitleFrame9" vTcl:WidgetProc "Toplevel227" 1
    bind $site_3_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputVH 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry227_4" vTcl:WidgetProc "Toplevel227" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd73 \
        \
        -command {global FileName PISARDirInput FileInputVH

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $PISARDirInput $types "VH INPUT FILE (s21)"
set FileInputVH $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd73" "Button227_4" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_6_0.cpd73 "$site_6_0.cpd73 Button $top all _vTclBalloon"
    bind $site_6_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd118 \
        -ipad 0 -text {Input Data File ( s22 )} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame10" vTcl:WidgetProc "Toplevel227" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputVV 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry227_5" vTcl:WidgetProc "Toplevel227" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel227" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd74 \
        \
        -command {global FileName PISARDirInput FileInputVV

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $PISARDirInput $types "VV INPUT FILE (s22)"
set FileInputVV $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd74" "Button227_5" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_6_0.cpd74 "$site_6_0.cpd74 Button $top all _vTclBalloon"
    bind $site_6_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd116 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd117 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    checkbutton $top.cpd71 \
        -text {Convert Input IEEE binary Format (LE<->BE)} \
        -variable IEEEFormat 
    vTcl:DefineAlias "$top.cpd71" "Checkbutton46" vTcl:WidgetProc "Toplevel227" 1
    frame $top.fra26 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra26" "Frame20" vTcl:WidgetProc "Toplevel227" 1
    set site_3_0 $top.fra26
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global PISARDirOutput PISARFileInputFlag
global IEEEFormat FileInputHH FileInputHV FileInputVH FileInputVV FileInputPISAR PISARDataFormat PISAROffset
global VarWarning VarWarning WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPPisarConfig OpenDirFile

if {$OpenDirFile == 0} {

set PISARFileInputFlag 0
if {$PISARDataFormat == "MGPC"} {
    if {$FileInputPISAR != ""} {set PISARFileInputFlag 1}
    }
if {$PISARDataFormat == "MGPSSC"} {
    set PISARFileFlag 0
    if {$FileInputHH != ""} {incr PISARFileFlag}
    if {$FileInputHV != ""} {incr PISARFileFlag}
    if {$FileInputVH != ""} {incr PISARFileFlag}
    if {$FileInputVV != ""} {incr PISARFileFlag}
    if {$PISARFileFlag == 4} {set PISARFileInputFlag 1}
    }
if {$PISARFileInputFlag == 1} {
    set ConfigFile $TMPPisarConfig
    DeleteFile  $ConfigFile

    if {$PISARDataFormat == "MGPC"} {
        TextEditorRunTrace "Process The Function Soft/data_import/pisar_header.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileInputPISAR\x22 -iee $IEEEFormat -df $PISARDataFormat -of \x22$TMPPisarConfig\x22" "k"
        set f [ open "| Soft/data_import/pisar_header.exe -if \x22$FileInputPISAR\x22 -iee $IEEEFormat -df $PISARDataFormat -of \x22$TMPPisarConfig\x22" r]
        }
    if {$PISARDataFormat == "MGPSSC"} {
        TextEditorRunTrace "Process The Function Soft/data_import/pisar_header.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileInputHH\x22 -iee $IEEEFormat -df $PISARDataFormat -of \x22$TMPPisarConfig\x22" "k"
        set f [ open "| Soft/data_import/pisar_header.exe -if \x22$FileInputHH\x22 -iee $IEEEFormat -df $PISARDataFormat -of \x22$TMPPisarConfig\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError

    set NligFullSize 0
    set NcolFullSize 0
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set ErrorMessage ""
    WaitUntilCreated $ConfigFile
    if [file exists $ConfigFile] {
        set f [open $ConfigFile r]
        gets $f tmp
        gets $f NligFullSize
        gets $f tmp
        gets $f tmp
        gets $f NcolFullSize
        gets $f tmp
        gets $f tmp
        gets $f PISAROffset
        gets $f tmp
        gets $f tmp
        gets $f PolarPISAR
        close $f
        if {"$PolarPISAR" == "good"} {
            set NligInit 1
            set NligEnd $NligFullSize
            set NcolInit 1
            set NcolEnd $NcolFullSize
            set NligFullSizeInput $NligFullSize
            set NcolFullSizeInput $NcolFullSize
            set ErrorMessage ""
            } else {
            if {$PISARDataFormat == "MGPC"} {
                set WarningMessage $FileInputPISAR
                set WarningMessage2 "is not a MGP-C Data File"
                }
            if {$PISARDataFormat == "MGPSSC"} {
                set WarningMessage $FileInputPISARHH
                set WarningMessage2 "is not a MGP-SSC Data File"
                }
            Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
            tkwait variable VarWarning
            } 
        } else {
        set ErrorMessage "NO CONFIG FILE !"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel227); TextEditorRunTrace "Close Window PISAR Input File" "b"
    } else {
    set PISARFileInputFlag 0
    set ErrorMessage "ENTER THE PISAR DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PISAR_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel227); TextEditorRunTrace "Close Window PISAR Data Import" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel227" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab47 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd133 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd131 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra26 \
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
Window show .top227

main $argc $argv
