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

        {{[file join . GUI Images OpenDir.gif]} {file not found!} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images TANDEMX.gif]} {user image} user {}}

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
    set base .top437
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab72 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.lab75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.lab75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra27 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra27
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
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra96 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra96
    namespace eval ::widgets::$site_3_0.fra97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra97
    namespace eval ::widgets::$site_4_0.fra102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra102
    namespace eval ::widgets::$site_5_0.cpd105 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra103 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra103
    namespace eval ::widgets::$site_5_0.cpd106 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd98
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd111
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1}
    }
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1}
    }
    namespace eval ::widgets::$site_4_0.cpd109 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd109
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent26 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra68
    namespace eval ::widgets::$site_3_0.che70 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
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
            vTclWindow.top437
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
    wm geometry $top 200x200+250+250; update
    wm maxsize $top 3364 1032
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

proc vTclWindow.top437 {base} {
    if {$base == ""} {
        set base .top437
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
    wm geometry $top 500x440+10+100; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "TANDEM-X Extract Data"
    vTcl:DefineAlias "$top" "Toplevel437" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab72 \
        -image [vTcl:image:get_image [file join . GUI Images TANDEMX.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$top.lab72" "Label3" vTcl:WidgetProc "Toplevel437" 1
    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel437" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel437" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable EOSIDirInputMaster 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel437" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel437" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel437" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel437" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable EOSIOutputDirMaster 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel437" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel437" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab75 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab75" "Label1" vTcl:WidgetProc "Toplevel437" 1
    entry $site_6_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable EOSIOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry1" vTcl:WidgetProc "Toplevel437" 1
    pack $site_6_0.lab75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel437" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd95 \
        \
        -command {global DirName DataDir EOSIOutputDirMaster EOSIOutputDirBisMaster EOSIOutputSubDir
global VarWarning WarningMessage WarningMessage2

set EOSIOutputDirTmp $EOSIOutputDirMaster
set DirName ""
OpenDir $DataDir "DATA OUTPUT MASTER DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set EOSIOutputDirMaster $DirName
        set EOSIOutputDirBisMaster $EOSIOutputDirMaster
        set EOSIExtractFonction "Full"
        set EOSIConvertMLKName 0
        set MultiLookCol " "
        set MultiLookRow " "
        set SubSampCol " "
        set SubSampRow " "
        $widget(Label437_1) configure -state disable
        $widget(Label437_2) configure -state disable
        $widget(Entry437_1) configure -state disable
        $widget(Entry437_2) configure -state disable
        } else {
        set EOSIOutputDirMaster $EOSIOutputDirTmp
        set EOSIOutputDirBisMaster $EOSIOutputDirMaster
        }
    } else {
    set EOSIOutputDirMaster $EOSIOutputDirTmp
    set EOSIOutputDirBisMaster $EOSIOutputDirMaster
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd95 "$site_6_0.cpd95 Button $top all _vTclBalloon"
    bind $site_6_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Input Slave Directory} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame6" vTcl:WidgetProc "Toplevel437" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable EOSIDirInputSlave 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel437" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel437" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd86" "Button35" vTcl:WidgetProc "Toplevel437" 1
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd67 \
        -ipad 0 -text {Output Slave Directory} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame7" vTcl:WidgetProc "Toplevel437" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable EOSIOutputDirSlave 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel437" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame8" vTcl:WidgetProc "Toplevel437" 1
    set site_5_0 $site_4_0.cpd74
    label $site_5_0.lab75 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab75" "Label2" vTcl:WidgetProc "Toplevel437" 1
    entry $site_5_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable EOSIOutputSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd77" "Entry2" vTcl:WidgetProc "Toplevel437" 1
    pack $site_5_0.lab75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel437" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd95 \
        \
        -command {global DirName DataDir EOSIOutputDirSlave EOSIOutputDirBisSlave EOSIOutputSubDir
global VarWarning WarningMessage WarningMessage2

set EOSIOutputDirTmp $EOSIOutputDirSlave
set DirName ""
OpenDir $DataDir "DATA OUTPUT SLAVE DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set EOSIOutputDirSlave $DirName
        set EOSIOutputDirBisSlave $EOSIOutputDirSlave
        set EOSIExtractFonction "Full"
        set EOSIConvertMLKName 0
        set MultiLookCol " "
        set MultiLookRow " "
        set SubSampCol " "
        set SubSampRow " "
        $widget(Label437_1) configure -state disable
        $widget(Label437_2) configure -state disable
        $widget(Entry437_1) configure -state disable
        $widget(Entry437_2) configure -state disable
        } else {
        set EOSIOutputDirSlave $EOSIOutputDirTmp
        set EOSIOutputDirBisSlave $EOSIOutputDirSlave
        }
    } else {
    set EOSIOutputDirSlave $EOSIOutputDirTmp
    set EOSIOutputDirBisSlave $EOSIOutputDirSlave
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_5_0.cpd95 "$site_5_0.cpd95 Button $top all _vTclBalloon"
    bind $site_5_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra27 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra27" "Frame9" vTcl:WidgetProc "Toplevel437" 1
    set site_3_0 $top.fra27
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel437" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel437" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel437" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel437" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel437" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel437" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel437" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel437" 1
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
    frame $top.fra96 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra96" "Frame3" vTcl:WidgetProc "Toplevel437" 1
    set site_3_0 $top.fra96
    frame $site_3_0.fra97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra97" "Frame4" vTcl:WidgetProc "Toplevel437" 1
    set site_4_0 $site_3_0.fra97
    frame $site_4_0.fra102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra102" "Frame6" vTcl:WidgetProc "Toplevel437" 1
    set site_5_0 $site_4_0.fra102
    radiobutton $site_5_0.cpd105 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " "
set MultiLookRow " "
set SubSampCol " "
set SubSampRow " "
$widget(Label437_1) configure -state disable
$widget(Label437_2) configure -state disable
$widget(Entry437_1) configure -state disable
$widget(Entry437_2) configure -state disable} \
        -text {Full Resolution} -value Full -variable EOSIExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd105" "Radiobutton4" vTcl:WidgetProc "Toplevel437" 1
    pack $site_5_0.cpd105 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra103 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra103" "Frame7" vTcl:WidgetProc "Toplevel437" 1
    set site_5_0 $site_4_0.fra103
    radiobutton $site_5_0.cpd106 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " "
set MultiLookRow " "
set SubSampCol " ? "
set SubSampRow " ? "
$widget(Label437_1) configure -state normal
$widget(Label437_2) configure -state normal
$widget(Entry437_1) configure -state normal
$widget(Entry437_2) configure -state normal} \
        -text {Sub Sampling} -value SubSamp -variable EOSIExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd106" "Radiobutton5" vTcl:WidgetProc "Toplevel437" 1
    pack $site_5_0.cpd106 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_4_0.fra102 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra103 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $site_3_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd98" "Frame5" vTcl:WidgetProc "Toplevel437" 1
    set site_4_0 $site_3_0.cpd98
    frame $site_4_0.cpd111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd111" "Frame153" vTcl:WidgetProc "Toplevel437" 1
    set site_5_0 $site_4_0.cpd111
    label $site_5_0.lab23 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab23" "Label203" vTcl:WidgetProc "Toplevel437" 1
    label $site_5_0.lab25 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab25" "Label204" vTcl:WidgetProc "Toplevel437" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_4_0.cpd109 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd109" "Frame154" vTcl:WidgetProc "Toplevel437" 1
    set site_5_0 $site_4_0.cpd109
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label437_2" vTcl:WidgetProc "Toplevel437" 1
    entry $site_5_0.ent26 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubSampRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry437_2" vTcl:WidgetProc "Toplevel437" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label437_1" vTcl:WidgetProc "Toplevel437" 1
    entry $site_5_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubSampCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry437_1" vTcl:WidgetProc "Toplevel437" 1
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd109 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra97 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra68 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra68" "Frame10" vTcl:WidgetProc "Toplevel437" 1
    set site_3_0 $top.fra68
    checkbutton $site_3_0.che70 \
        -text {Bistatic Configuration Correction} \
        -variable TANDEMXBistaticCorrection 
    vTcl:DefineAlias "$site_3_0.che70" "Checkbutton1" vTcl:WidgetProc "Toplevel437" 1
    pack $site_3_0.che70 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra41 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame20" vTcl:WidgetProc "Toplevel437" 1
    set site_3_0 $top.fra41
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir ActiveProgram OpenDirFile DataFormatActive
global EOSIDirInputMaster EOSIDirOutputMaster EOSIOutputDirMaster
global EOSIDirInputSlave EOSIDirOutputSlave EOSIOutputDirSlave
global EOSIOutputSubDir EOSIExtractFonction TANDEMXBistaticCorrection
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global ProgressLine ConfigFile FinalNlig FinalNcol PolarCase PolarType 
global TMPTANDEMXConfigMaster TMPTANDEMXConfigSlave

global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global MultiLookSubSamp SubSampCol SubSampRow MultiLookCol MultiLookRow TMPMemoryAllocError

global DataDirTmp1 DataDirChannel1 DataDirTmp2 DataDirChannel2 PSPViewGimpBMP 

if {$OpenDirFile == 0} {

    set configerror "false"

    set NligInitTmp $NligInit; set NligEndTmp $NligEnd; set NligFullSizeTmp $NligFullSize
    set NcolInitTmp $NcolInit; set NcolEndTmp $NcolEnd; set NcolFullSizeTmp $NcolFullSize
    
    set EOSIDirOutputSlave $EOSIOutputDirSlave
            
    #####################################################################
    #Create Directory
    set EOSIDirOutputSlave [PSPCreateDirectory $EOSIDirOutputSlave $EOSIOutputDirSlave "NO"]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$EOSIExtractFonction == "Full"} {TestVar 4}
        if {$EOSIExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Col"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampCol; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Row"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampRow; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {

            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction $ActiveProgram; append Fonction " Convert Input Data File"
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update

            if {$EOSIExtractFonction == "Full"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr 1 -ssc 1 " }
            if {$EOSIExtractFonction == "SubSamp"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol " }

            append MultiLookSubSamp " -errf \x22$TMPMemoryAllocError\x22 "

            set Symmetrie 1

            if {$PolarType == "full"} {
                TextEditorRunTrace "Process The Function Soft/bin/data_import/tandemx_convert_ssc_quad.exe" "k"
                TextEditorRunTrace "Arguments: -if1 \x22$FileInput5\x22 -if2 \x22$FileInput6\x22 -if3 \x22$FileInput7\x22 -if4 \x22$FileInput8\x22 -od \x22$EOSIDirOutputSlave\x22 -odf S2 -bpc $TANDEMXBistaticCorrection -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigSlave\x22 -pp $PolarType $MultiLookSubSamp" "k"
                set f [ open "| Soft/bin/data_import/tandemx_convert_ssc_quad.exe -if1 \x22$FileInput5\x22 -if2 \x22$FileInput6\x22 -if3 \x22$FileInput7\x22 -if4 \x22$FileInput8\x22 -od \x22$EOSIDirOutputSlave\x22 -odf S2 -bpc $TANDEMXBistaticCorrection -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigSlave\x22 -pp $PolarType $MultiLookSubSamp" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
    
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
                set ConfigFile "$EOSIDirOutputSlave/config.txt"
                set ErrorMessage ""
                LoadConfig
                if {"$ErrorMessage" == ""} {
                    EnviWriteConfigS $EOSIDirOutputSlave $NligFullSize $NcolFullSize
                    set MaskCmd ""
                    set MaskFile "$EOSIDirOutputSlave/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    
                    set DataFormatActive "S2"
                    set RGBDirInput $EOSIDirOutputSlave
                    set RGBDirOutput $EOSIDirOutputSlave
                    set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
                    set Fonction "Creation of the Pauli BMP File :"
                    set Fonction2 "$RGBFileOutput"    
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    set BMPDirInput $RGBDirOutput
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                    } else {
                    append ErrorMessage " -> An ERROR occured during the Data Extraction"
                    set VarError ""
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    set ErrorMessage ""
                    set configerror "true"
                    }    
                } else {
                TextEditorRunTrace "Process The Function Soft/bin/data_import/tandemx_convert_ssc_dual.exe" "k"
                TextEditorRunTrace "Arguments: -if1 \x22$FileInput3\x22 -if2 \x22$FileInput4\x22 -od \x22$EOSIDirOutputSlave\x22 -odf SPP -bpc $TANDEMXBistaticCorrection -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigSlave\x22 -pp $PolarType $MultiLookSubSamp" "k"
                set f [ open "| Soft/bin/data_import/tandemx_convert_ssc_dual.exe -if1 \x22$FileInput3\x22 -if2 \x22$FileInput4\x22 -od \x22$EOSIDirOutputSlave\x22 -odf SPP -bpc $TANDEMXBistaticCorrection -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigSlave\x22 -pp $PolarType $MultiLookSubSamp" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
    
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
                set ConfigFile "$EOSIDirOutputSlave/config.txt"
                set ErrorMessage ""
                LoadConfig
                if {"$ErrorMessage" == ""} {
                    EnviWriteConfigS $EOSIDirOutputSlave $NligFullSize $NcolFullSize
                    set MaskCmd ""
                    set MaskFile "$EOSIDirOutputSlave/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    
                    set DataFormatActive "SPP"
                    set RGBDirInput $EOSIDirOutputSlave
                    set RGBDirOutput $EOSIDirOutputSlave
                    set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
                    set Fonction "Creation of the RGB BMP File :"
                    set Fonction2 "$RGBFileOutput"    
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 -rgbf RGB1 $MaskCmd -auto 1" "k"
                    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 -rgbf RGB1 $MaskCmd -auto 1" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    set BMPDirInput $RGBDirOutput
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                    } else {
                    append ErrorMessage " -> An ERROR occured during the Data Extraction"
                    set VarError ""
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    set ErrorMessage ""
                    set configerror "true"
                    }    
                }

            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel437); TextEditorRunTrace "Close Window TANDEMX Extract Data" "b"}
        }

    set NligInit $NligInitTmp; set NligEnd $NligEndTmp; set NligFullSize $NligFullSizeTmp
    set NcolInit $NcolInitTmp; set NcolEnd $NcolEndTmp; set NcolFullSize $NcolFullSizeTmp

    set EOSIDirOutputMaster $EOSIOutputDirMaster
            
    #####################################################################
    #Create Directory
    set EOSIDirOutputMaster [PSPCreateDirectory $EOSIDirOutputMaster $EOSIOutputDirMaster "NO"]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$EOSIExtractFonction == "Full"} {TestVar 4}
        if {$EOSIExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Col"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampCol; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Row"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampRow; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {

            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction $ActiveProgram; append Fonction " Convert Input Data File"
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update

            if {$EOSIExtractFonction == "Full"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr 1 -ssc 1 " }
            if {$EOSIExtractFonction == "SubSamp"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol " }

            append MultiLookSubSamp " -errf \x22$TMPMemoryAllocError\x22 "

            if {$PolarType == "full"} {
                TextEditorRunTrace "Process The Function Soft/bin/data_import/tandemx_convert_ssc_quad.exe" "k"
                TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$EOSIDirOutputMaster\x22 -odf S2 -bpc 0 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigMaster\x22 -pp $PolarType $MultiLookSubSamp" "k"
                set f [ open "| Soft/bin/data_import/tandemx_convert_ssc_quad.exe -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$EOSIDirOutputMaster\x22 -odf S2 -bpc 0 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigMaster\x22 -pp $PolarType $MultiLookSubSamp" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
        
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
                set ConfigFile "$EOSIDirOutputMaster/config.txt"
                set ErrorMessage ""
                LoadConfig
                if {"$ErrorMessage" == ""} {
                    EnviWriteConfigS $EOSIDirOutputMaster $NligFullSize $NcolFullSize
                    set MaskCmd ""
                    set MaskFile "$EOSIDirOutputMaster/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    
                    set DataFormatActive "S2"
                    set RGBDirInput $EOSIDirOutputSlave
                    set RGBDirOutput $EOSIDirOutputSlave
                    set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
                    set Fonction "Creation of the Pauli BMP File :"
                    set Fonction2 "$RGBFileOutput"    
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    } else {
                    append ErrorMessage " -> An ERROR occured during the Data Extraction"
                    set VarError ""
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    set ErrorMessage ""
                    set configerror "true"
                    }    
                } else {
                TextEditorRunTrace "Process The Function Soft/bin/data_import/tandemx_convert_ssc_dual.exe" "k"
                TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$EOSIDirOutputMaster\x22 -odf SPP -bpc 0 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigMaster\x22 -pp $PolarType $MultiLookSubSamp" "k"
                set f [ open "| Soft/bin/data_import/tandemx_convert_ssc_dual.exe -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$EOSIDirOutputMaster\x22 -odf SPP -bpc 0 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTANDEMXConfigMaster\x22 -pp $PolarType $MultiLookSubSamp" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    
                set ConfigFile "$EOSIDirOutputMaster/config.txt"
                set ErrorMessage ""
                LoadConfig
                if {"$ErrorMessage" == ""} {
                    EnviWriteConfigS $EOSIDirOutputMaster $NligFullSize $NcolFullSize
                    set MaskCmd ""
                    set MaskFile "$EOSIDirOutputMaster/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    
                    set DataFormatActive "SPP"
                    set RGBDirInput $EOSIDirOutputMaster
                    set RGBDirOutput $EOSIDirOutputMaster
                    set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
                    set Fonction "Creation of the RGB BMP File :"
                    set Fonction2 "$RGBFileOutput"    
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 -rgbf RGB1 $MaskCmd -auto 1" "k"
                    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 -rgbf RGB1 $MaskCmd -auto 1" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    set BMPDirInput $RGBDirOutput
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                    } else {
                    append ErrorMessage " -> An ERROR occured during the Data Extraction"
                    set VarError ""
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    set ErrorMessage ""
                    set configerror "true"
                    }    
                }
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel437); TextEditorRunTrace "Close Window TANDEM-X Extract Data" "b"}
        }

    if {$configerror == "false"} {
        Window hide $widget(Toplevel437); TextEditorRunTrace "Close Window TANDEM-X Extract Data" "b"
        MenuRAZ
        CloseAllWidget

        set ActiveProgram "POLINSAR"
        set ActiveImportData ""
        MenuEnv
        InitDataDir

        MenuOff
        set DataDirChannel1 $EOSIDirOutputMaster
        CheckEnvBinData
        MenuOff
        set DataDirChannel2 $EOSIDirOutputSlave
        CheckEnvBinData
        CheckEnvironnement
        set DataDirTmp1 $DataDirChannel1
        set DataDirTmp2 $DataDirChannel2
        set BMPDirInput $DataDirChannel1
        TextEditorRunTrace "Open PolSARpro v5.0 Dual" "b"
        }

    }} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel437" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/EOSI_TDX_Extract_Data.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel437" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global ActiveProgram OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel437); TextEditorRunTrace "Close Window TANDEM-X Extract Data" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel437" 1
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
    pack $top.lab72 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra27 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra96 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra68 \
        -in $top -anchor center -expand 1 -fill none -side top 
    pack $top.fra41 \
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
Window show .top437

main $argc $argv
