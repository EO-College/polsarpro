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
    set base .top210
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd77
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
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra88 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra88
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
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
    namespace eval ::widgets::$base.fra90 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra90
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad24 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra91 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra91
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad25 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad29 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad26 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad30 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra95 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra95
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad27 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad31 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd72
    namespace eval ::widgets::$site_4_0.lab47 {
        array set save {-cursor 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd74
    namespace eval ::widgets::$site_4_0.lab47 {
        array set save {-cursor 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra96 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra96
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-cursor 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra94 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra94
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
            vTclWindow.top210
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

proc vTclWindow.top210 {base} {
    if {$base == ""} {
        set base .top210
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
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Intensities Elements"
    vTcl:DefineAlias "$top" "Toplevel210" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame4" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel210" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable IntDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel210" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel210" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel210" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel210" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable IntDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel210" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel210" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd78 \
        \
        -command {global DirName DataDir IntDirOutput

set IntDirOutputTmp $IntDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set IntDirOutput $DirName
    } else {
    set IntDirOutput $IntDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd78 "$site_6_0.cpd78 Button $top all _vTclBalloon"
    bind $site_6_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra88 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra88" "Frame9" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra88
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel210" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel210" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel210" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel210" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel210" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel210" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel210" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel210" 1
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
    frame $top.fra90 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra90" "Frame430" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra90
    label $site_3_0.lab47 \
        -padx 1 -text I11 
    vTcl:DefineAlias "$site_3_0.lab47" "Label210_1" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton210_1) configure -state normal} -padx 1 \
        -text A11 -value A -variable IntI11 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton210_1" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPIntI11 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton210_1" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad24 \
        -command {$widget(Checkbutton210_1) configure -state normal} -padx 1 \
        -text I11 -value I -variable IntI11 
    vTcl:DefineAlias "$site_3_0.rad24" "Radiobutton210_2" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad28 \
        -command {$widget(Checkbutton210_1) configure -state normal} -padx 1 \
        -text {A11 (dB) = I11 (dB)} -value Idb -variable IntI11 
    vTcl:DefineAlias "$site_3_0.rad28" "Radiobutton210_3" vTcl:WidgetProc "Toplevel210" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.rad24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad28 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra91 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra91" "Frame431" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra91
    label $site_3_0.lab47 \
        -padx 1 -text I21 
    vTcl:DefineAlias "$site_3_0.lab47" "Label210_2" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton210_2) configure -state normal} -padx 1 \
        -text A21 -value A -variable IntI21 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton210_5" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad25 \
        -command {$widget(Checkbutton210_2) configure -state normal} -padx 1 \
        -text I21 -value I -variable IntI21 
    vTcl:DefineAlias "$site_3_0.rad25" "Radiobutton210_6" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad29 \
        -command {$widget(Checkbutton210_2) configure -state normal} -padx 1 \
        -text {A21 (dB) = I21 (dB)} -value Idb -variable IntI21 
    vTcl:DefineAlias "$site_3_0.rad29" "Radiobutton210_7" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPIntI21 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton210_2" vTcl:WidgetProc "Toplevel210" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad29 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra92 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame432" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra92
    label $site_3_0.lab47 \
        -text I12 
    vTcl:DefineAlias "$site_3_0.lab47" "Label210_3" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton210_3) configure -state normal} -padx 1 \
        -text A12 -value A -variable IntI12 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton210_9" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad26 \
        -command {$widget(Checkbutton210_3) configure -state normal} -padx 1 \
        -text I12 -value I -variable IntI12 
    vTcl:DefineAlias "$site_3_0.rad26" "Radiobutton210_10" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad30 \
        -command {$widget(Checkbutton210_3) configure -state normal} -padx 1 \
        -text {A12 (dB) = I12 (dB)} -value Idb -variable IntI12 
    vTcl:DefineAlias "$site_3_0.rad30" "Radiobutton210_11" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_3_0.che51 \
        -text BMP -variable BMPIntI12 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton210_3" vTcl:WidgetProc "Toplevel210" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad26 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad30 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra95 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra95" "Frame433" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra95
    label $site_3_0.lab47 \
        -text I22 
    vTcl:DefineAlias "$site_3_0.lab47" "Label210_4" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton210_4) configure -state normal} -padx 1 \
        -text A22 -value A -variable IntI22 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton210_13" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad27 \
        -command {$widget(Checkbutton210_4) configure -state normal} -padx 1 \
        -text I22 -value I -variable IntI22 
    vTcl:DefineAlias "$site_3_0.rad27" "Radiobutton210_14" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad31 \
        -command {$widget(Checkbutton210_4) configure -state normal} -padx 1 \
        -text {A22 (dB) = I22 (dB)} -value Idb -variable IntI22 
    vTcl:DefineAlias "$site_3_0.rad31" "Radiobutton210_15" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_3_0.che51 \
        -text BMP -variable BMPIntI22 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton210_4" vTcl:WidgetProc "Toplevel210" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad31 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame1" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd72" "Frame435" vTcl:WidgetProc "Toplevel210" 1
    set site_4_0 $site_3_0.cpd72
    label $site_4_0.lab47 \
        -cursor {} -padx 1 -text Contrast1 
    vTcl:DefineAlias "$site_4_0.lab47" "Label210_6" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_4_0.che51 \
        -padx 1 -text BMP -variable BMPIntContrast1 
    vTcl:DefineAlias "$site_4_0.che51" "Checkbutton210_7" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_4_0.cpd73 \
        \
        -command {global IntContrast1 BMPIntContrast1

if {$IntContrast1 == 1} {
    $widget(Checkbutton210_7) configure -state normal
    } else {
    $widget(Checkbutton210_7) configure -state disable
    set BMPIntContrast1 0
    }} \
        -padx 1 -text {g1 / g0} -variable IntContrast1 
    vTcl:DefineAlias "$site_4_0.cpd73" "Checkbutton210_6" vTcl:WidgetProc "Toplevel210" 1
    pack $site_4_0.lab47 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_4_0.che51 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side top 
    frame $site_3_0.cpd74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd74" "Frame436" vTcl:WidgetProc "Toplevel210" 1
    set site_4_0 $site_3_0.cpd74
    label $site_4_0.lab47 \
        -cursor {} -padx 1 -text Contrast2 
    vTcl:DefineAlias "$site_4_0.lab47" "Label210_7" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_4_0.che51 \
        -padx 1 -text BMP -variable BMPIntContrast2 
    vTcl:DefineAlias "$site_4_0.che51" "Checkbutton210_9" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_4_0.cpd73 \
        \
        -command {global IntContrast2 BMPIntContrast2

if {$IntContrast2 == 1} {
    $widget(Checkbutton210_9) configure -state normal
    } else {
    $widget(Checkbutton210_9) configure -state disable
    set BMPIntContrast2 0
    }} \
        -padx 1 -text {g1 / g0} -variable IntContrast2 
    vTcl:DefineAlias "$site_4_0.cpd73" "Checkbutton210_8" vTcl:WidgetProc "Toplevel210" 1
    pack $site_4_0.lab47 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_4_0.che51 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side top 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra96 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra96" "Frame434" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra96
    label $site_3_0.lab47 \
        -cursor {} -padx 1 -text Span 
    vTcl:DefineAlias "$site_3_0.lab47" "Label210_5" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton210_5) configure -state normal} -padx 1 \
        -text Linear -value lin -variable IntSpan 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton210_17" vTcl:WidgetProc "Toplevel210" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton210_5) configure -state normal} -padx 1 \
        -text {DeciBel = 10log(Span)} -value db -variable IntSpan 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton210_18" vTcl:WidgetProc "Toplevel210" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPIntSpan 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton210_5" vTcl:WidgetProc "Toplevel210" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 6 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 60 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    button $top.but93 \
        -background #ffff00 \
        -command {set IntI11 0
set IntI21 0
set IntI12 0
set IntI22 0
set IntSpan 0
set IntContrast1 0
set IntContrast2 0
set BMPIntI11 0
set BMPIntI21 0
set BMPIntI12 0
set BMPIntI22 0
set BMPIntSpan 0
set BMPIntContrast1 0
set BMPIntContrast2 0
$widget(Checkbutton210_1) configure -state disable
$widget(Checkbutton210_2) configure -state disable
$widget(Checkbutton210_3) configure -state disable
$widget(Checkbutton210_4) configure -state disable
$widget(Checkbutton210_5) configure -state disable
$widget(Checkbutton210_7) configure -state disable
$widget(Checkbutton210_9) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$top.but93" "Button586" vTcl:WidgetProc "Toplevel210" 1
    bindtags $top.but93 "$top.but93 Button $top all _vTclBalloon"
    bind $top.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    frame $top.fra94 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra94" "Frame20" vTcl:WidgetProc "Toplevel210" 1
    set site_3_0 $top.fra94
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global IntDirInput IntDirOutput
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global BMPDirInput OpenDirFile PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {
    
    #####################################################################
    #Create Directory
    set IntDirOutput [PSPCreateDirectorymask $IntDirOutput $IntDirOutput $IntDirInput]
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
    TestVar 4
    if {$TestVarError == "ok"} {

    if {"$IntI11" != 0} {
        if {"$IntI11" != "I"} {
            set Fonction "Creation of the Binary Data File :"
            if {"$IntI11"=="A"} {set Fonction2 "$IntDirOutput/A11.bin"}
            if {"$IntI11"=="Adb"} {set Fonction2 "$IntDirOutput/A11_db.bin"}
            if {"$IntI11"=="Idb"} {set Fonction2 "$IntDirOutput/I11_db.bin"}
            set MaskCmd ""
            set MaskFile "$IntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 11 -fmt $IntI11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 11 -fmt $IntI11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        if {"$IntI11"=="A"} {EnviWriteConfig "$IntDirOutput/A11.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI11"=="Adb"} {EnviWriteConfig "$IntDirOutput/A11_db.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI11"=="I"} {EnviWriteConfig "$IntDirOutput/I11.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI11"=="Idb"} {EnviWriteConfig "$IntDirOutput/I11_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPIntI11"=="1"} {
            if {"$IntI11"=="A"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A11.bin"
                set BMPFileOutput "$IntDirOutput/A11.bmp"
                }
            if {"$IntI11"=="Adb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A11_db.bin"
                set BMPFileOutput "$IntDirOutput/A11_db.bmp"
                }
            if {"$IntI11"=="I"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I11.bin"
                set BMPFileOutput "$IntDirOutput/I11.bmp"
                }
            if {"$IntI11"=="Idb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I11_db.bin"
                set BMPFileOutput "$IntDirOutput/I11_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
        
    if {"$IntI21" != 0} {
        if {"$IntI21" != "I"} {
            set Fonction "Creation of the Binary Data File :"
            if {"$IntI21"=="A"} {set Fonction2 "$IntDirOutput/A21.bin"}
            if {"$IntI21"=="Adb"} {set Fonction2 "$IntDirOutput/A21_db.bin"}
            if {"$IntI21"=="Idb"} {set Fonction2 "$IntDirOutput/I21_db.bin"}
            set MaskCmd ""
            set MaskFile "$IntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 21 -fmt $IntI21 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 21 -fmt $IntI21 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        if {"$IntI21"=="A"} {EnviWriteConfig "$IntDirOutput/A21.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI21"=="Adb"} {EnviWriteConfig "$IntDirOutput/A21_db.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI21"=="I"} {EnviWriteConfig "$IntDirOutput/I21.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI21"=="Idb"} {EnviWriteConfig "$IntDirOutput/I21_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPIntI21"=="1"} {
            if {"$IntI21"=="A"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A21.bin"
                set BMPFileOutput "$IntDirOutput/A21.bmp"
                }
            if {"$IntI21"=="Adb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A21_db.bin"
                set BMPFileOutput "$IntDirOutput/A21_db.bmp"
                }
            if {"$IntI21"=="I"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I21.bin"
                set BMPFileOutput "$IntDirOutput/I21.bmp"
                }
            if {"$IntI21"=="Idb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I21_db.bin"
                set BMPFileOutput "$IntDirOutput/I21_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
    
    if {"$IntI12" != 0} {
        if {"$IntI12" != "I"} {
            set Fonction "Creation of the Binary Data File :"
            if {"$IntI12"=="A"} {set Fonction2 "$IntDirOutput/A12.bin"}
            if {"$IntI12"=="Adb"} {set Fonction2 "$IntDirOutput/A12_db.bin"}
            if {"$IntI12"=="Idb"} {set Fonction2 "$IntDirOutput/I12_db.bin"}
            set MaskCmd ""
            set MaskFile "$IntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 12 -fmt $IntI12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 12 -fmt $IntI12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        if {"$IntI12"=="A"} {EnviWriteConfig "$IntDirOutput/A12.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI12"=="Adb"} {EnviWriteConfig "$IntDirOutput/A12_db.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI12"=="I"} {EnviWriteConfig "$IntDirOutput/I12.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI12"=="Idb"} {EnviWriteConfig "$IntDirOutput/I12_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPIntI12"=="1"} {
            if {"$IntI12"=="A"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A12.bin"
                set BMPFileOutput "$IntDirOutput/A12.bmp"
                }
            if {"$IntI12"=="Adb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A12_db.bin"
                set BMPFileOutput "$IntDirOutput/A12_db.bmp"
                }
            if {"$IntI12"=="I"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I12.bin"
                set BMPFileOutput "$IntDirOutput/I12.bmp"
                }
            if {"$IntI12"=="Idb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I12_db.bin"
                set BMPFileOutput "$IntDirOutput/I12_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$IntI22"!= 0} {
        if {"$IntI22" != "I"} {
            set Fonction "Creation of the Binary Data File :"
            if {"$IntI22"=="A"} {set Fonction2 "$IntDirOutput/A22.bin"}
            if {"$IntI22"=="Adb"} {set Fonction2 "$IntDirOutput/A22_db.bin"}
            if {"$IntI22"=="Idb"} {set Fonction2 "$IntDirOutput/I22_db.bin"}
            set MaskCmd ""
            set MaskFile "$IntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 22 -fmt $IntI22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -elt 22 -fmt $IntI22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        if {"$IntI22"=="A"} {EnviWriteConfig "$IntDirOutput/A22.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI22"=="Adb"} {EnviWriteConfig "$IntDirOutput/A22_db.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI22"=="I"} {EnviWriteConfig "$IntDirOutput/I22.bin" $FinalNlig $FinalNcol 4}
        if {"$IntI22"=="Idb"} {EnviWriteConfig "$IntDirOutput/I22_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPIntI22"=="1"} {
            if {"$IntI22"=="A"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A22.bin"
                set BMPFileOutput "$IntDirOutput/A22.bmp"
                }
            if {"$IntI22"=="Adb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/A22_db.bin"
                set BMPFileOutput "$IntDirOutput/A22_db.bmp"
                }
            if {"$IntI22"=="I"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I22.bin"
                set BMPFileOutput "$IntDirOutput/I22.bmp"
                }
            if {"$IntI22"=="Idb"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/I22_db.bin"
                set BMPFileOutput "$IntDirOutput/I22_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$IntSpan" != 0} {
        set Fonction "Creation of the Binary Data File :"
        if {"$IntSpan"=="lin"} {set Fonction2 "$IntDirOutput/span.bin"}
        if {"$IntSpan"=="db"} {set Fonction2 "$IntDirOutput/span_db.bin"}
        set MaskCmd ""
        set MaskFile "$IntDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fmt $IntSpan -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_span.exe -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -iodf IPP -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fmt $IntSpan -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$IntSpan"=="lin"} {EnviWriteConfig "$IntDirOutput/span.bin" $FinalNlig $FinalNcol 4}
        if {"$IntSpan"=="db"} {EnviWriteConfig "$IntDirOutput/span_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPIntSpan"=="1"} {
            if {"$IntSpan"=="lin"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/span.bin"
                set BMPFileOutput "$IntDirOutput/span.bmp"
                }
            if {"$IntSpan"=="db"} {
                set BMPDirInput $IntDirOutput
                set BMPFileInput "$IntDirOutput/span_db.bin"
                set BMPFileOutput "$IntDirOutput/span_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
        
    if {"$IntContrast1" == "1"} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$IntDirOutput/Intensities_Contrast1.bin"
        set MaskCmd ""
        set MaskFile "$IntDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_contrast_IPP.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ind 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_contrast_IPP.exe -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ind 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$IntDirOutput/Intensities_Contrast1.bin" $FinalNlig $FinalNcol 4
        if {"$BMPIntContrast1"=="1"} {
            set BMPDirInput $IntDirOutput
            set BMPFileInput "$IntDirOutput/Intensities_Contrast1.bin"
            set BMPFileOutput "$IntDirOutput/Intensities_Contrast1.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -1 1
            }
        }
        
    if {"$IntContrast2" == "1"} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$IntDirOutput/Intensities_Contrast2.bin"
        set MaskCmd ""
        set MaskFile "$IntDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_contrast_IPP.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ind 2 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_contrast_IPP.exe -id \x22$IntDirInput\x22 -od \x22$IntDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ind 2 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$IntDirOutput/Intensities_Contrast2.bin" $FinalNlig $FinalNcol 4
        if {"$BMPIntContrast2"=="1"} {
            set BMPDirInput $IntDirOutput
            set BMPFileInput "$IntDirOutput/Intensities_Contrast2.bin"
            set BMPFileOutput "$IntDirOutput/Intensities_Contrast2.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -1 1
            }
        }
    }        
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel210); TextEditorRunTrace "Close Window Sinclair Elements" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel210" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/IntensitiesElements.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel210" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel210); TextEditorRunTrace "Close Window Sinclair Elements" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel210" 1
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
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra88 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra90 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra91 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra92 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra95 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra96 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.but93 \
        -in $top -anchor center -expand 1 -fill none -side top 
    pack $top.fra94 \
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
Window show .top210

main $argc $argv
