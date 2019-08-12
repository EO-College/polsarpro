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
    set base .top315
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
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra29 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra29
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
    namespace eval ::widgets::$base.tit73 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd83 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd83 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra30 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra30
    namespace eval ::widgets::$site_3_0.fra22 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra22
    namespace eval ::widgets::$site_4_0.fra25 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra25
    namespace eval ::widgets::$site_5_0.che71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd73
    namespace eval ::widgets::$site_8_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd74
    namespace eval ::widgets::$site_8_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
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
            vTclWindow.top315
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
    wm geometry $top 200x200+66+66; update
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

proc vTclWindow.top315 {base} {
    if {$base == ""} {
        set base .top315
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
    wm geometry $top 500x350+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Interferogram Estimation"
    vTcl:DefineAlias "$top" "Toplevel315" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame2" vTcl:WidgetProc "Toplevel315" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame315_1" vTcl:WidgetProc "Toplevel315" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CmplxCohMasterDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry315_01" vTcl:WidgetProc "Toplevel315" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel315" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel315" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd81 \
        -ipad 0 -text {Input Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame315_2" vTcl:WidgetProc "Toplevel315" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CmplxCohSlaveDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry315_02" vTcl:WidgetProc "Toplevel315" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel315" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button35" vTcl:WidgetProc "Toplevel315" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Master-Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame315_3" vTcl:WidgetProc "Toplevel315" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CmplxCohOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry315_03" vTcl:WidgetProc "Toplevel315" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame1" vTcl:WidgetProc "Toplevel315" 1
    set site_6_0 $site_5_0.cpd95
    label $site_6_0.cpd97 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd97" "Label315_01" vTcl:WidgetProc "Toplevel315" 1
    entry $site_6_0.ent94 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CmplxCohOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.ent94" "Entry315_04" vTcl:WidgetProc "Toplevel315" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.ent94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel315" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DirName DataDirChannel1 CmplxCohOutputDir

set CmplxCohDirOutputTmp $CmplxCohOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set CmplxCohOutputDir $DirName
    } else {
    set CmplxCohOutputDir $CmplxCohDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button315_01" vTcl:WidgetProc "Toplevel315" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra29 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra29" "Frame9" vTcl:WidgetProc "Toplevel315" 1
    set site_3_0 $top.fra29
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel315" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel315" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel315" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel315" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel315" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel315" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel315" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel315" 1
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
    TitleFrame $top.tit73 \
        -text {Image 1} 
    vTcl:DefineAlias "$top.tit73" "TitleFrame3" vTcl:WidgetProc "Toplevel315" 1
    bind $top.tit73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit73 getframe]
    radiobutton $site_4_0.rad74 \
        -command {} -text HH -value HH -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.rad74" "Radiobutton1" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd75 \
        -command {} -text HV -value HV -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.cpd75" "Radiobutton2" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd76 \
        -command {} -text VV -value VV -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.cpd76" "Radiobutton3" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd77 \
        -command {} -text {HH + VV} -value HHpVV -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.cpd77" "Radiobutton4" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd79 \
        -command {} -text {HH - VV} -value HHmVV -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.cpd79" "Radiobutton5" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd80 \
        -command {} -text LL -value LL -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.cpd80" "Radiobutton6" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd81 \
        -command {} -text LR -value LR -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.cpd81" "Radiobutton7" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd82 \
        -command {} -text RR -value RR -variable CmplxCohI1 
    vTcl:DefineAlias "$site_4_0.cpd82" "Radiobutton8" vTcl:WidgetProc "Toplevel315" 1
    pack $site_4_0.rad74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd83 \
        -text {Image 2} 
    vTcl:DefineAlias "$top.cpd83" "TitleFrame4" vTcl:WidgetProc "Toplevel315" 1
    bind $top.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd83 getframe]
    radiobutton $site_4_0.rad74 \
        -command {} -text HH -value HH -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.rad74" "Radiobutton9" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd75 \
        -command {} -text HV -value HV -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.cpd75" "Radiobutton10" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd76 \
        -command {} -text VV -value VV -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.cpd76" "Radiobutton11" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd77 \
        -command {} -text {HH + VV} -value HHpVV -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.cpd77" "Radiobutton12" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd79 \
        -command {} -text {HH - VV} -value HHmVV -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.cpd79" "Radiobutton13" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd80 \
        -command {} -text LL -value LL -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.cpd80" "Radiobutton14" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd81 \
        -command {} -text LR -value LR -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.cpd81" "Radiobutton15" vTcl:WidgetProc "Toplevel315" 1
    radiobutton $site_4_0.cpd82 \
        -command {} -text RR -value RR -variable CmplxCohI2 
    vTcl:DefineAlias "$site_4_0.cpd82" "Radiobutton16" vTcl:WidgetProc "Toplevel315" 1
    pack $site_4_0.rad74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra30 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra30" "Frame149" vTcl:WidgetProc "Toplevel315" 1
    set site_3_0 $top.fra30
    frame $site_3_0.fra22 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra22" "Frame248" vTcl:WidgetProc "Toplevel315" 1
    set site_4_0 $site_3_0.fra22
    frame $site_4_0.fra25 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra25" "Frame249" vTcl:WidgetProc "Toplevel315" 1
    set site_5_0 $site_4_0.fra25
    checkbutton $site_5_0.che71 \
        \
        -command {global CmplxCohAvg FiltRow FiltCol

if {$CmplxCohAvg == "1" } {
    set FiltRow "7"; set FiltCol "7"
    $widget(TitleFrame315_4) configure -state normal; $widget(TitleFrame315_4) configure -text "Averaging Window"
    $widget(Entry315_4) configure -state normal; $widget(Entry315_4) configure -disabledbackground #FFFFFF; $widget(Label315_4) configure -state normal 
    $widget(Entry315_5) configure -state normal; $widget(Entry315_5) configure -disabledbackground #FFFFFF; $widget(Label315_5) configure -state normal 
    } else {
    set FiltRow " "; set FiltCol " "
    $widget(TitleFrame315_4) configure -state disable; $widget(TitleFrame315_4) configure -text ""
    $widget(Entry315_4) configure -state disable; $widget(Entry315_4) configure -disabledbackground $PSPBackgroundColor; $widget(Label315_4) configure -state disable 
    $widget(Entry315_5) configure -state disable; $widget(Entry315_5) configure -disabledbackground $PSPBackgroundColor; $widget(Label315_5) configure -state disable 
    }} \
        -text Averaging -variable CmplxCohAvg 
    vTcl:DefineAlias "$site_5_0.che71" "Checkbutton5" vTcl:WidgetProc "Toplevel315" 1
    TitleFrame $site_5_0.cpd75 \
        -text {Averaging Window} 
    vTcl:DefineAlias "$site_5_0.cpd75" "TitleFrame315_4" vTcl:WidgetProc "Toplevel315" 1
    bind $site_5_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    frame $site_7_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame7" vTcl:WidgetProc "Toplevel315" 1
    set site_8_0 $site_7_0.cpd73
    label $site_8_0.cpd81 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_8_0.cpd81" "Label315_4" vTcl:WidgetProc "Toplevel315" 1
    entry $site_8_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable FiltRow -width 5 
    vTcl:DefineAlias "$site_8_0.cpd82" "Entry315_4" vTcl:WidgetProc "Toplevel315" 1
    pack $site_8_0.cpd81 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_7_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd74" "Frame8" vTcl:WidgetProc "Toplevel315" 1
    set site_8_0 $site_7_0.cpd74
    label $site_8_0.cpd81 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_8_0.cpd81" "Label315_5" vTcl:WidgetProc "Toplevel315" 1
    entry $site_8_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable FiltCol -width 5 
    vTcl:DefineAlias "$site_8_0.cpd82" "Entry315_5" vTcl:WidgetProc "Toplevel315" 1
    pack $site_8_0.cpd81 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.che71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra25 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra22 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra36 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame20" vTcl:WidgetProc "Toplevel315" 1
    set site_3_0 $top.fra36
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 DirName BMPDirInput
global CmplxCohMasterDirInput CmplxCohSlaveDirInput CmplxCohDirOutput CmplxCohOutputDir CmplxCohOutputSubDir
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global CmplxCohFonc CmplxCohI1 CmplxCohI2
global FiltRow FiltCol CmplxCohAvg TMPDir TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType 

if {$OpenDirFile == 0} {

set config "false"
if {$CmplxCohI1 !=""} {set config "true"}
if {$CmplxCohI2 !=""} {set config "true"}
if {$config == "false"} {
    set VarError ""
    set ErrorMessage "SELECT THE IMAGE POLARISATION TYPE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

set config "true"
if {$CmplxCohAvg == "1"} {
    if {$FiltRow ==""} {set config "false"}
    if {$FiltRow =="?"} {set config "false"}
    if {$FiltRow =="0"} {set config "false"}
    if {$FiltRow ==""} {set config "false"}
    if {$FiltCol =="?"} {set config "false"}
    if {$FiltCol =="0"} {set config "false"}
    if {$FiltCol ==""} {set config "false"}
    }
if {$config == "false"} {
    set VarError ""
    set ErrorMessage "ENTER THE AVERAGING WINDOW SIZE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

set CmplxCohDirOutput $CmplxCohOutputDir
if {$CmplxCohOutputSubDir != ""} {append CmplxCohDirOutput "/$CmplxCohOutputSubDir"}

    #####################################################################
    #Create Directory
    set CmplxCohDirOutput [PSPCreateDirectoryMask $CmplxCohDirOutput $CmplxCohOutputDir $CmplxCohMasterDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    if {$CmplxCohAvg == "1"} {
        set RowFilt $FiltRow; set ColFilt $FiltRow
        } else {
        set RowFilt 1; set ColFilt 1
        } 

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Averaging Window - Row"; set TestVarType(4) "int"; set TestVarValue(4) $RowFilt; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Averaging Window - Col"; set TestVarType(5) "int"; set TestVarValue(5) $ColFilt; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    set TestVarName(6) "Averaging Flag"; set TestVarType(6) "int"; set TestVarValue(6) $CmplxCohAvg; set TestVarMin(6) "0"; set TestVarMax(6) "1"
    TestVar 7
    if {$TestVarError == "ok"} {

        set MaskCmd ""
        if {$CmplxCohFonc == "S2"} {
            set ConfigFile "$CmplxCohDirOutput/config.txt"
            WriteConfig
            set MaskFileOut "$CmplxCohDirOutput/mask_valid_pixels.bin"
            if [file exists $MaskFileOut] {
                set MaskCmd "-mask \x22$MaskFileOut\x22"
                } else {
                set MaskFile1 "$CmplxCohMasterDirInput/mask_valid_pixels.bin"
                set MaskFile2 "$CmplxCohSlaveDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile1] {
                    if [file exists $MaskFile2] {
                        set MaskFileOut "$CmplxCohDirOutput/mask_valid_pixels.bin"
                        set ProgressLine "0"
                        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                        update
                        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand_file.exe" "k"
                        TextEditorRunTrace "Arguments: -if1 \x22$MaskFile1\x22 -it1 float -if2 \x22$MaskFile2\x22 -it2 float -of \x22$MaskFileOut\x22 -ot float -op mulfile -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                        set f [ open "| Soft/bin/calculator/file_operand_file.exe -if1 \x22$MaskFile1\x22 -it1 float -if2 \x22$MaskFile2\x22 -it2 float -of \x22$MaskFileOut\x22 -ot float -op mulfile -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
                        EnviWriteConfig $MaskFileOut $FinalNlig $FinalNcol 4
                        if [file exists $MaskFileOut] {set MaskCmd "-mask \x22$MaskFileOut\x22"}
                        } 
                    } 
                }
            }
        if {$CmplxCohFonc == "T6"} {
            set MaskFile "$CmplxCohMasterDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-maskm \x22$MaskFile\x22"}
            }

        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Interferogram"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_dual/interferogram_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$TMPDir\x22 -iodf S2T6 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -im1 $CmplxCohI1 -im2 $CmplxCohI2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_dual/interferogram_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$TMPDir\x22 -iodf S2T6 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -im1 $CmplxCohI1 -im2 $CmplxCohI2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$TMPDir\x22 -iodf T6 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -im1 $CmplxCohI1 -im2 $CmplxCohI2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_dual/interferogram_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$TMPDir\x22 -iodf T6 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -im1 $CmplxCohI1 -im2 $CmplxCohI2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"


        set CmplxCohName "$TMPDir/cmplx_coh"
        append CmplxCohName "_$CmplxCohI1"; append CmplxCohName "_$CmplxCohI2"
        EnviWriteConfig "$CmplxCohName.bin" $FinalNlig $FinalNcol 6

        set InterferoName "$CmplxCohDirOutput/interferogram"
        append InterferoName "_$CmplxCohI1"; append InterferoName "_$CmplxCohI2"

        set CmplxFileIn "$CmplxCohName.bin"
        set CmplxFileOut "$InterferoName.bin"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -ot float -op arg -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -ot float -op arg -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          

        EnviWriteConfig "$InterferoName.bin" $FinalNlig $FinalNcol 4

        if [file exists "$InterferoName.bin"] {
            set BMPDirInput $CmplxCohDirOutput
            set BMPFileInput "$InterferoName.bin"
            set BMPFileOutput "$InterferoName.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180 180
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $InterferoName.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        if {$CmplxCohAvg == "1"} { 
            set CmplxFileIn "$CmplxCohName.bin"
            set CmplxFileOut $CmplxCohName; append CmplxFileOut "_avg.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig $CmplxFileOut $FinalNlig $FinalNcol 6

            append InterferoName "_avg"

            set CmplxFileIn $CmplxCohName; append CmplxFileIn "_avg.bin"
            set CmplxFileOut "$InterferoName.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -ot float -op arg -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -ot float -op arg -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          

            EnviWriteConfig "$InterferoName.bin" $FinalNlig $FinalNcol 4

            if [file exists "$InterferoName.bin"] {
                set BMPDirInput $CmplxCohDirOutput
                set BMPFileInput "$InterferoName.bin"
                set BMPFileOutput "$InterferoName.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180 180
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE $InterferoName.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

    }
    #TestVar
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel315); TextEditorRunTrace "Close Window Interferogram Estimation" "b"}
    }
}
}
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel315" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/InterferogramEstimation.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel315" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel315); TextEditorRunTrace "Close Window Interferogram Estimation" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel315" 1
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
    pack $top.tit73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra30 \
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
Window show .top315

main $argc $argv
