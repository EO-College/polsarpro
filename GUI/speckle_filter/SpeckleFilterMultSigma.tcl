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
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}

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
    set base .top503
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent94 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra29 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra29
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.lab75 {
        array set save {-activebackground 1 -background 1 -disabledforeground 1 -foreground 1 -relief 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra74
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra77
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd85
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra77
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd86
    namespace eval ::widgets::$site_4_0.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra74
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra77
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd85
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra77
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top503
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
    wm geometry $top 200x200+100+100; update
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

proc vTclWindow.top503 {base} {
    if {$base == ""} {
        set base .top503
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
    wm geometry $top 500x230+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Speckle Filter"
    vTcl:DefineAlias "$top" "Toplevel503" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame2" vTcl:WidgetProc "Toplevel503" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel503" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FilterDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel503" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel503" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FilterOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel503" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame1" vTcl:WidgetProc "Toplevel503" 1
    set site_6_0 $site_5_0.cpd95
    label $site_6_0.cpd97 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd97" "Label2" vTcl:WidgetProc "Toplevel503" 1
    entry $site_6_0.ent94 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FilterOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.ent94" "Entry1" vTcl:WidgetProc "Toplevel503" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.ent94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra29 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra29" "Frame9" vTcl:WidgetProc "Toplevel503" 1
    set site_3_0 $top.fra29
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel503" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel503" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel503" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel503" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel503" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel503" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel503" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel503" 1
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
    label $top.lab75 \
        -activebackground #ffffff -background #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -relief sunken \
        -state disabled -textvariable FilterFonction -width 50 
    vTcl:DefineAlias "$top.lab75" "Label1" vTcl:WidgetProc "Toplevel503" 1
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel503" 1
    set site_3_0 $top.fra71
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel503" 1
    set site_4_0 $site_3_0.fra72
    frame $site_4_0.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra74" "Frame6" vTcl:WidgetProc "Toplevel503" 1
    set site_5_0 $site_4_0.fra74
    label $site_5_0.cpd76 \
        -padx 1 -text {Number of Looks} 
    vTcl:DefineAlias "$site_5_0.cpd76" "Label503" vTcl:WidgetProc "Toplevel503" 1
    frame $site_5_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra77" "Frame8" vTcl:WidgetProc "Toplevel503" 1
    set site_6_0 $site_5_0.fra77
    entry $site_6_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NlookSigma -width 5 
    vTcl:DefineAlias "$site_6_0.cpd78" "Entry503" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd83 \
        \
        -command {global NlookSigma

set NlookSigma [expr $NlookSigma + 1]
if {$NlookSigma == 5} { set NlookSigma 1 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd83" "Button3" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd84 \
        \
        -command {global NlookSigma

set NlookSigma [expr $NlookSigma - 1]
if {$NlookSigma == 0} { set NlookSigma 4 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button4" vTcl:WidgetProc "Toplevel503" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd85" "Frame7" vTcl:WidgetProc "Toplevel503" 1
    set site_5_0 $site_4_0.cpd85
    label $site_5_0.cpd76 \
        -padx 1 -text {Window Size (Target)} 
    vTcl:DefineAlias "$site_5_0.cpd76" "Label353" vTcl:WidgetProc "Toplevel503" 1
    frame $site_5_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra77" "Frame11" vTcl:WidgetProc "Toplevel503" 1
    set site_6_0 $site_5_0.fra77
    entry $site_6_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NwinTgt -width 5 
    vTcl:DefineAlias "$site_6_0.cpd78" "Entry353" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd83 \
        \
        -command {global NwinTgt

set NwinTgt [expr $NwinTgt + 2]
if {$NwinTgt == 7} { set NwinTgt 3 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd83" "Button5" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd84 \
        \
        -command {global NwinTgt

set NwinTgt [expr $NwinTgt - 2]
if {$NwinTgt == 1} { set NwinTgt 5 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button6" vTcl:WidgetProc "Toplevel503" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd86" "Frame5" vTcl:WidgetProc "Toplevel503" 1
    set site_4_0 $site_3_0.cpd86
    frame $site_4_0.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra74" "Frame10" vTcl:WidgetProc "Toplevel503" 1
    set site_5_0 $site_4_0.fra74
    label $site_5_0.cpd76 \
        -padx 1 -text Sigma 
    vTcl:DefineAlias "$site_5_0.cpd76" "Label354" vTcl:WidgetProc "Toplevel503" 1
    frame $site_5_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra77" "Frame12" vTcl:WidgetProc "Toplevel503" 1
    set site_6_0 $site_5_0.fra77
    entry $site_6_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Sigma -width 5 
    vTcl:DefineAlias "$site_6_0.cpd78" "Entry354" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd83 \
        \
        -command {global Sigma

set Sigma [expr $Sigma + 0.1]
if {$Sigma == 1.0} { set Sigma 0.5 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd83" "Button7" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd84 \
        \
        -command {global Sigma

set Sigma [expr $Sigma - 0.1]
if {$Sigma == 0.4} { set Sigma 0.9 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button8" vTcl:WidgetProc "Toplevel503" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd85" "Frame15" vTcl:WidgetProc "Toplevel503" 1
    set site_5_0 $site_4_0.cpd85
    label $site_5_0.cpd76 \
        -padx 1 -text {Window Size (Filter)} 
    vTcl:DefineAlias "$site_5_0.cpd76" "Label355" vTcl:WidgetProc "Toplevel503" 1
    frame $site_5_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra77" "Frame16" vTcl:WidgetProc "Toplevel503" 1
    set site_6_0 $site_5_0.fra77
    entry $site_6_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NwinFilter -width 5 
    vTcl:DefineAlias "$site_6_0.cpd78" "Entry355" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd83 \
        \
        -command {global NwinFilter

set NwinFilter [expr $NwinFilter + 2]
if {$NwinFilter == 13} { set NwinFilter 7 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd83" "Button9" vTcl:WidgetProc "Toplevel503" 1
    button $site_6_0.cpd84 \
        \
        -command {global NwinFilter

set NwinFilter [expr $NwinFilter - 2]
if {$NwinFilter == 5} { set NwinFilter 11 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button10" vTcl:WidgetProc "Toplevel503" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra36 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame20" vTcl:WidgetProc "Toplevel503" 1
    set site_3_0 $top.fra36
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirMult NDataDirMult DirName FilterDirInput FilterDirOutput FilterOutputDir
global FilterOutputSubDir FilterFonction FilterFunction 
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType 
global NligFullSize NcolFullSize TMPMemoryAllocError DataFormatActive 
global OpenDirFile FilterFonc NlookSigma Sigma NwinTgt NwinFilter
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set FilterDirOutput $FilterOutputDir
if {$FilterOutputSubDir != ""} {append FilterDirOutput "/$FilterOutputSubDir"}

    #####################################################################
    #Create Directory
    set FilterDirOutput [PSPCreateDirectory $FilterDirOutput $FilterOutputDir $FilterFonc]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
       
        if {$Sigma == 0.5} { set Sigma0 5 }
        if {$Sigma == 0.6} { set Sigma0 6 }
        if {$Sigma == 0.7} { set Sigma0 7 }
        if {$Sigma == 0.8} { set Sigma0 8 }
        if {$Sigma == 0.9} { set Sigma0 9 }

        for {set ii 1} {$ii <= $NDataDirMult} {incr ii} {
            set FilterDirInput $DataDirMult($ii)
            if {"$FilterFonc" ==  "C2"} {append FilterDirInput "/C2"}
            if {"$FilterFonc" ==  "T3"} {append FilterDirInput "/T3"}

            set FilterOutputDir $DataDirMult($ii)
            append FilterOutputDir "_SIG"
            set FilterDirOutput $FilterOutputDir
            if {$FilterOutputSubDir != ""} {append FilterDirOutput "/$FilterOutputSubDir"}

            #Create Directory
            set FilterDirOutput [PSPCreateDirectoryMult $FilterDirOutput $FilterDirOutput $FilterFonc]

            set ConfigFile "$FilterDirOutput/config.txt"
            WriteConfig
    
            set MaskCmd ""
            set MaskFile "$FilterDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

            set Fonction $FilterFonction
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/speckle_filter/lee_sigma_filter.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$FilterDirInput\x22 -od \x22$FilterDirOutput\x22 -iodf $FilterFonc -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nlk $NlookSigma -sig $Sigma0 -nwe $NwinFilter -nwt $NwinTgt" "k"
            set f [ open "| Soft/bin/speckle_filter/lee_sigma_filter.exe -id \x22$FilterDirInput\x22 -od \x22$FilterDirOutput\x22 -iodf $FilterFonc -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nlk $NlookSigma -sig $Sigma0 -nwe $NwinFilter -nwt $NwinTgt" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                
            if {"$FilterFonc" ==  "S2T3"} {EnviWriteConfigT $FilterDirOutput $FinalNlig $FinalNcol}
            if {"$FilterFonc" ==  "T3"} {EnviWriteConfigT $FilterDirOutput $FinalNlig $FinalNcol}
            if {"$FilterFonc" ==  "C2"} {EnviWriteConfigC $FilterDirOutput $FinalNlig $FinalNcol}
            if {"$FilterFonc" ==  "SPP"} {EnviWriteConfigC $FilterDirOutput $FinalNlig $FinalNcol}
    
            set DataDirMult($ii) $FilterOutputDir
            }
        WriteConfigMult
        if {"$FilterFonc" ==  "S2T3"} {
            set DataFormatActive "T3"
            set WarningMessage "THE DATA FORMAT TO BE PROCESSED IS NOW:"
            set WarningMessage2 "3x3 COHERENCY MATRIX - T3"
            set VarAdvice ""
            Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
            tkwait variable VarAdvice
            }
        if {"$FilterFonc" ==  "SPP"} {
            set DataFormatActive "C2"
            set WarningMessage "THE DATA FORMAT TO BE PROCESSED IS NOW:"
            set WarningMessage2 "2x2 COVARIANCE MATRIX - C2"
            set VarAdvice ""
            Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
            tkwait variable VarAdvice
            }

        Window hide $widget(Toplevel503); TextEditorRunTrace "Close Window Speckle Filter Mult" "b"
        }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel503); TextEditorRunTrace "Close Window Speckle Filter Mult" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel503" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SpeckleFilterMultSigma.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel503" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel503); TextEditorRunTrace "Close Window Speckle Filter Mult" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel503" 1
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
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra29 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.lab75 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
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
Window show .top503

main $argc $argv
