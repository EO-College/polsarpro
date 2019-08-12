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

        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}

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
    set base .top252
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd79
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
    namespace eval ::widgets::$site_6_0.cpd84 {
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra28 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra28
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
    namespace eval ::widgets::$base.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd66
    namespace eval ::widgets::$site_6_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd82 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra90
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.but78 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit84 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit84 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra90
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.cpd99 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.but79 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra42 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra42
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m102 {
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
            vTclWindow.top252
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

proc vTclWindow.top252 {base} {
    if {$base == ""} {
        set base .top252
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
    wm geometry $top 500x330+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Basic Scattering Mechanism Identification"
    vTcl:DefineAlias "$top" "Toplevel252" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel252" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel252" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable IdentDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel252" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button42" vTcl:WidgetProc "Toplevel252" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel252" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable IdentOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel252" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel252" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable IdentOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd74" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel252" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd80 \
        \
        -command {global DirName DataDir IdentOutputDir

set IdentDirOutputTmp $IdentOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set IdentOutputDir $DirName
    } else {
    set IdentOutputDir $IdentDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd80 "$site_6_0.cpd80 Button $top all _vTclBalloon"
    bind $site_6_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra28 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra28" "Frame9" vTcl:WidgetProc "Toplevel252" 1
    set site_3_0 $top.fra28
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel252" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel252" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel252" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel252" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel252" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel252" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel252" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel252" 1
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
    TitleFrame $top.cpd73 \
        -ipad 0 -text {H / A / alpha Decomposition Files} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame3" vTcl:WidgetProc "Toplevel252" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame69" vTcl:WidgetProc "Toplevel252" 1
    set site_5_0 $site_4_0.cpd74
    checkbutton $site_5_0.cpd83 \
        -text Entropy -variable entropy 
    vTcl:DefineAlias "$site_5_0.cpd83" "Checkbutton634" vTcl:WidgetProc "Toplevel252" 1
    checkbutton $site_5_0.cpd84 \
        -text Anisotropy -variable anisotropy 
    vTcl:DefineAlias "$site_5_0.cpd84" "Checkbutton635" vTcl:WidgetProc "Toplevel252" 1
    checkbutton $site_5_0.cpd85 \
        -text {Alpha1, Alpha2} -variable alpha12 
    vTcl:DefineAlias "$site_5_0.cpd85" "Checkbutton636" vTcl:WidgetProc "Toplevel252" 1
    checkbutton $site_5_0.cpd86 \
        -text {Beta1, Beta2} -variable beta12 
    vTcl:DefineAlias "$site_5_0.cpd86" "Checkbutton637" vTcl:WidgetProc "Toplevel252" 1
    checkbutton $site_5_0.cpd87 \
        -text {p1, p2} -variable probabilities 
    vTcl:DefineAlias "$site_5_0.cpd87" "Checkbutton638" vTcl:WidgetProc "Toplevel252" 1
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame70" vTcl:WidgetProc "Toplevel252" 1
    set site_5_0 $site_4_0.cpd78
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame54" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.cpd76
    label $site_6_0.lab35 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_6_0.lab35" "Label42" vTcl:WidgetProc "Toplevel252" 1
    entry $site_6_0.cpd77 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable IdentNwinL -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry27" vTcl:WidgetProc "Toplevel252" 1
    pack $site_6_0.lab35 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd66 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.cpd66" "Frame55" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.cpd66
    label $site_6_0.lab35 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_6_0.lab35" "Label43" vTcl:WidgetProc "Toplevel252" 1
    entry $site_6_0.cpd77 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable IdentNwinC -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry28" vTcl:WidgetProc "Toplevel252" 1
    pack $site_6_0.lab35 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    TitleFrame $top.cpd82 \
        -ipad 0 -text {Classification / Segmentation File} 
    vTcl:DefineAlias "$top.cpd82" "TitleFrame4" vTcl:WidgetProc "Toplevel252" 1
    bind $top.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd82 getframe]
    frame $site_4_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra90" "Frame7" vTcl:WidgetProc "Toplevel252" 1
    set site_5_0 $site_4_0.fra90
    frame $site_5_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame11" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.cpd77
    button $site_6_0.but78 \
        \
        -command {global FileName IdentDirInput IdentFile

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$IdentDirInput" $types "INPUT CLASSIFICATION / SEGMENTATION FILE"
if {$FileName != ""} {
    set IdentFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but78" "Button3" vTcl:WidgetProc "Toplevel252" 1
    bindtags $site_6_0.but78 "$site_6_0.but78 Button $top all _vTclBalloon"
    bind $site_6_0.but78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.but78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame12" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable IdentFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd96" "Entry54" vTcl:WidgetProc "Toplevel252" 1
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra90 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.tit84 \
        -ipad 0 -text {ColorMap 16} 
    vTcl:DefineAlias "$top.tit84" "TitleFrame2" vTcl:WidgetProc "Toplevel252" 1
    bind $top.tit84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit84 getframe]
    frame $site_4_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra90" "Frame1" vTcl:WidgetProc "Toplevel252" 1
    set site_5_0 $site_4_0.fra90
    frame $site_5_0.fra92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame3" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.fra92
    button $site_6_0.cpd99 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd99 {global ColorMapWishart16 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 16
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapWishart16] {
    set f [open $ColorMapWishart16 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMapWishart16
set ColorMapOut $ColorMapWishart16
WidgetShowFromWidget $widget(Toplevel252) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapWishart16 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd99" "Button41" vTcl:WidgetProc "Toplevel252" 1
    bindtags $site_6_0.cpd99 "$site_6_0.cpd99 Button $top all _vTclBalloon"
    bind $site_6_0.cpd99 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.cpd99 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame6" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.cpd77
    button $site_6_0.but79 \
        \
        -command {global FileName IdentDirInput ColorMapWishart16

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$IdentDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapWishart16 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but79" "Button2" vTcl:WidgetProc "Toplevel252" 1
    bindtags $site_6_0.but79 "$site_6_0.but79 Button $top all _vTclBalloon"
    bind $site_6_0.but79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.but79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame5" vTcl:WidgetProc "Toplevel252" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapWishart16 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd97" "Entry53" vTcl:WidgetProc "Toplevel252" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra90 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra42 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame20" vTcl:WidgetProc "Toplevel252" 1
    set site_3_0 $top.fra42
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global IdentDirInput IdentDirOutput IdentOutputDir IdentOutputSubDir IdentDecompositionFonction
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine
global BMPDirInput OpenDirFile IdentFile TMPMemoryAllocError
global ColorMap9 ColorMapWishart16
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set IdentDirOutput $IdentOutputDir
if {$IdentOutputSubDir != ""} {append IdentDirOutput "/$IdentOutputSubDir"}

set config "false"
if {"$probabilities"=="1"} { set config "true" }
if {"$alpha12"=="1"} { set config "true" }
if {"$beta12"=="1"} { set config "true" }
if {"$entropy"=="1"} { set config "true" }
if {"$anisotropy"=="1"} { set config "true" }

if {"$config"=="true"} {

    #####################################################################
    #Create Directory
    set IdentDirOutput [PSPCreateDirectoryMask $IdentDirOutput $IdentOutputDir $IdentDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $IdentNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $IdentNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
        TestVar 6
        if {$TestVarError == "ok"} {

            set config "false"
            if {"$entropy"=="1"} { set config "true" }
            if {"$anisotropy"=="1"} { set config "true" }
            if {"$config"=="true"} {
                if {$IdentDecompositionFonction == "S2m"} { set DecompFunct "S2T3" }
                if {$IdentDecompositionFonction == "S2b"} { set DecompFunct "S2T4" }
                if {$IdentDecompositionFonction == "T3"} { set DecompFunct "T3" }
                if {$IdentDecompositionFonction == "C3"} { set DecompFunct "T3C3" }
                if {$IdentDecompositionFonction == "T4"} { set DecompFunct "T4" }                
                if {$IdentDecompositionFonction == "C4"} { set DecompFunct "C4T4" }   
                set DecompString "-fl1 0 -fl2 0 -fl3 0 -fl4 $entropy -fl5 $anisotropy -fl6 0 -fl7 0 -fl8 0 -fl9 0"       
                set MaskCmd ""
                set MaskFile "$IdentDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set Fonction "Creation of all the Binary Data Files"
                set Fonction2 "of the H / A / Alpha Decomposition Parameters"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -iodf $DecompFunct -nwr $IdentNwinL -nwc $IdentNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $DecompString  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -iodf $DecompFunct -nwr $IdentNwinL -nwc $IdentNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $DecompString  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }

            set config "false"
            if {"$probabilities"=="1"} { set config "true" }
            if {"$config"=="true"} {
                if {$IdentDecompositionFonction == "S2m"} { set DecompFunct "S2T3" }
                if {$IdentDecompositionFonction == "S2b"} { set DecompFunct "S2T4" }
                if {$IdentDecompositionFonction == "T3"} { set DecompFunct "T3" }
                if {$IdentDecompositionFonction == "C3"} { set DecompFunct "T3C3" }
                if {$IdentDecompositionFonction == "T4"} { set DecompFunct "T4" }                
                if {$IdentDecompositionFonction == "C4"} { set DecompFunct "C4T4" }   
                set DecompString "-fl1 0 -fl2 $probabilities -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0"       
                set MaskCmd ""
                set MaskFile "$IdentDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set Fonction "Creation of all the Binary Data Files"
                set Fonction2 "of the H / A / Alpha EigenValues Parameters"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -iodf $DecompFunct -nwr $IdentNwinL -nwc $IdentNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $DecompString  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -iodf $DecompFunct -nwr $IdentNwinL -nwc $IdentNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $DecompString  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }

            set config "false"
            if {"$alpha12"=="1"} { set config "true" }
            if {"$beta12"=="1"} { set config "true" }
            if {"$config"=="true"} {
                if {$IdentDecompositionFonction == "S2m"} { set DecompFunct "S2T3" }
                if {$IdentDecompositionFonction == "S2b"} { set DecompFunct "S2T4" }
                if {$IdentDecompositionFonction == "T3"} { set DecompFunct "T3" }
                if {$IdentDecompositionFonction == "C3"} { set DecompFunct "T3C3" }
                if {$IdentDecompositionFonction == "T4"} { set DecompFunct "T4" }                
                if {$IdentDecompositionFonction == "C4"} { set DecompFunct "C4T4" }   
                set DecompString "-fl1 0 -fl2 $alpha12 -fl3 $beta12 -fl4 0 -fl5 0 -fl6 0 -fl7 0"       
                set MaskCmd ""
                set MaskFile "$IdentDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set Fonction "Creation of all the Binary Data Files"
                set Fonction2 "of the H / A / Alpha EigenVectors Parameters"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvector_set.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -iodf $DecompFunct -nwr $IdentNwinL -nwc $IdentNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $DecompString  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvector_set.exe -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -iodf $DecompFunct -nwr $IdentNwinL -nwc $IdentNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $DecompString  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }

            if [file exists "$IdentDirOutput/p1.bin"] {EnviWriteConfig "$IdentDirOutput/p1.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/p2.bin"] {EnviWriteConfig "$IdentDirOutput/p2.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/p3.bin"] {EnviWriteConfig "$IdentDirOutput/p3.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/alpha1.bin"] {EnviWriteConfig "$IdentDirOutput/alpha1.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/alpha2.bin"] {EnviWriteConfig "$IdentDirOutput/alpha2.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/alpha3.bin"] {EnviWriteConfig "$IdentDirOutput/alpha3.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/beta1.bin"] {EnviWriteConfig "$IdentDirOutput/beta1.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/beta2.bin"] {EnviWriteConfig "$IdentDirOutput/beta2.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/beta3.bin"] {EnviWriteConfig "$IdentDirOutput/beta3.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/entropy.bin"] {EnviWriteConfig "$IdentDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$IdentDirOutput/anisotropy.bin"] {EnviWriteConfig "$IdentDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
            #Update the Nlig/Ncol of the new image after processing
            set NligInit 1
            set NcolInit 1
            set NligEnd $FinalNlig
            set NcolEnd $FinalNcol
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel74); TextEditorRunTrace "Close Window H A Alpha Classification" "b"}
        } 
    }

    set conf "true"
    if [file exists "$IdentDirOutput/p1.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE p1 DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      } 
    if [file exists "$IdentDirOutput/p2.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE p2 DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      } 
    if [file exists "$IdentDirOutput/alpha1.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE alpha1 DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      } 
    if [file exists "$IdentDirOutput/alpha2.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE alpha2 DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      } 
    if [file exists "$IdentDirOutput/beta1.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE beta1 DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      } 
    if [file exists "$IdentDirOutput/beta2.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE beta2 DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      } 
    if [file exists "$IdentDirOutput/entropy.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      }
    if [file exists "$IdentDirOutput/anisotropy.bin"] {
      } else {
      set conf "false"
      set VarError ""
      set ErrorMessage "THE FILE anisotropy DOES NOT EXIST" 
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      }
 
  if {"$conf"=="true"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Segmentation File"; set TestVarType(4) "file"; set TestVarValue(4) $IdentFile; set TestVarMin(4) ""; set TestVarMax(4) ""
    set TestVarName(5) "ColorMap9"; set TestVarType(5) "file"; set TestVarValue(5) $ColorMap9; set TestVarMin(5) ""; set TestVarMax(5) ""
    set TestVarName(6) "ColorMap16"; set TestVarType(6) "file"; set TestVarValue(6) $ColorMapWishart16; set TestVarMin(6) ""; set TestVarMax(6) ""
    TestVar 7
    if {$TestVarError == "ok"} {
        set MaskCmd ""
        set MaskFile "$IdentDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction "BASIC SCATTERING MECHANISM IDENTIFICATION"
        set Fonction2 "and the associated BMP files"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/id_class_gen.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -if $IdentFile -clm \x22$ColorMapWishart16\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/id_class_gen.exe -id \x22$IdentDirInput\x22 -od \x22$IdentDirOutput\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -if $IdentFile -clm \x22$ColorMapWishart16\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists "$IdentDirOutput/vol_class.bin"] {EnviWriteConfigClassif "$IdentDirOutput/vol_class.bin" $FinalNlig $FinalNcol 4 $ColorMap9 9}
        if [file exists "$IdentDirOutput/sgl_class.bin"] {EnviWriteConfigClassif "$IdentDirOutput/sgl_class.bin" $FinalNlig $FinalNcol 4 $ColorMap9 9}
        if [file exists "$IdentDirOutput/dbl_class.bin"] {EnviWriteConfigClassif "$IdentDirOutput/dbl_class.bin" $FinalNlig $FinalNcol 4 $ColorMap9 9}
        if [file exists "$IdentDirOutput/id_class.bin"] {EnviWriteConfigClassif "$IdentDirOutput/id_class.bin" $FinalNlig $FinalNcol 4 $ColorMapWishart16 16}
        }
    }

}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel252" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/ClassificationIdentification.pdf" } \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel252" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel252); TextEditorRunTrace "Close Window Basic Scattering Mechanism Identification" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel252" 1
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
    menu $top.m102 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra28 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit84 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra42 \
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
Window show .top252

main $argc $argv
