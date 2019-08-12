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
    set base .top66
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd81
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
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra68
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
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.che71 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che73 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.che71 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra75
    namespace eval ::widgets::$site_3_0.che71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.che71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra77 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra77
    namespace eval ::widgets::$site_3_0.che71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra78 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra78
    namespace eval ::widgets::$site_3_0.che71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra29 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra29
    namespace eval ::widgets::$site_3_0.che26 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che27 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che28 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd73
    namespace eval ::widgets::$site_3_0.che26 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.che28 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd74
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra84
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
            vTclWindow.top66
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

proc vTclWindow.top66 {base} {
    if {$base == ""} {
        set base .top66
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
    wm geometry $top 500x400+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Correlation Coefficients (4x4)"
    vTcl:DefineAlias "$top" "Toplevel66" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd81" "Frame4" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.cpd81
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel66" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RoDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel66" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel66" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button39" vTcl:WidgetProc "Toplevel66" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel66" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RoOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel66" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel66" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label14" vTcl:WidgetProc "Toplevel66" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RoOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel66" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame17" vTcl:WidgetProc "Toplevel66" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd89 \
        \
        -command {global DirName DataDir RoOutputDir

set RoDirOutputTmp $RoOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set RoOutputDir $DirName
    } else {
    set RoOutputDir $RoDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button533" vTcl:WidgetProc "Toplevel66" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra68 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra68" "Frame9" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra68
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel66" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel66" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel66" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel66" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel66" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel66" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel66" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel66" 1
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
    frame $top.fra69 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame304" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra69
    checkbutton $site_3_0.che71 \
        \
        -command {if {"$Ro12"=="1"} {
    $widget(Checkbutton66_2) configure -state normal
    $widget(Checkbutton66_3) configure -state normal
    } else {
    $widget(Checkbutton66_2) configure -state disable
    $widget(Checkbutton66_3) configure -state disable
    set BMPmodRo12 "0"
    set BMPphaRo12 "0"
    }} \
        -padx 1 -text Ro12 -variable Ro12 
    vTcl:DefineAlias "$site_3_0.che71" "Checkbutton66_1" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che73 \
        -command {} -text {BMP Phase} -variable BMPphaRo12 
    vTcl:DefineAlias "$site_3_0.che73" "Checkbutton66_3" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che72 \
        -text {BMP Modulus} -variable BMPmodRo12 
    vTcl:DefineAlias "$site_3_0.che72" "Checkbutton66_2" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.che73 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame305" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra74
    checkbutton $site_3_0.che71 \
        \
        -command {if {"$Ro13"=="1"} {
    $widget(Checkbutton66_5) configure -state normal
    $widget(Checkbutton66_6) configure -state normal
    } else {
    $widget(Checkbutton66_5) configure -state disable
    $widget(Checkbutton66_6) configure -state disable
    set BMPmodRo13 "0"
    set BMPphaRo13 "0"
    }} \
        -padx 1 -text Ro13 -variable Ro13 
    vTcl:DefineAlias "$site_3_0.che71" "Checkbutton66_4" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che73 \
        -text {BMP Phase} -variable BMPphaRo13 
    vTcl:DefineAlias "$site_3_0.che73" "Checkbutton66_6" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che72 \
        -text {BMP Modulus} -variable BMPmodRo13 
    vTcl:DefineAlias "$site_3_0.che72" "Checkbutton66_5" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.che73 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra75 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame306" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra75
    checkbutton $site_3_0.che71 \
        \
        -command {if {"$Ro14"=="1"} {
    $widget(Checkbutton66_8) configure -state normal
    $widget(Checkbutton66_9) configure -state normal
    } else {
    $widget(Checkbutton66_8) configure -state disable
    $widget(Checkbutton66_9) configure -state disable
    set BMPmodRo14 "0"
    set BMPphaRo14 "0"
    }} \
        -text Ro14 -variable Ro14 
    vTcl:DefineAlias "$site_3_0.che71" "Checkbutton66_7" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che73 \
        -text {BMP Phase} -variable BMPphaRo14 
    vTcl:DefineAlias "$site_3_0.che73" "Checkbutton66_9" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che72 \
        -text {BMP Modulus} -variable BMPmodRo14 
    vTcl:DefineAlias "$site_3_0.che72" "Checkbutton66_8" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.che73 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra76 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame307" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra76
    checkbutton $site_3_0.che71 \
        \
        -command {if {"$Ro23"=="1"} {
    $widget(Checkbutton66_11) configure -state normal
    $widget(Checkbutton66_12) configure -state normal
    } else {
    $widget(Checkbutton66_11) configure -state disable
    $widget(Checkbutton66_12) configure -state disable
    set BMPmodRo23 "0"
    set BMPphaRo23 "0"
    }} \
        -text Ro23 -variable Ro23 
    vTcl:DefineAlias "$site_3_0.che71" "Checkbutton66_10" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che73 \
        -text {BMP Phase} -variable BMPphaRo23 
    vTcl:DefineAlias "$site_3_0.che73" "Checkbutton66_12" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che72 \
        -text {BMP Modulus} -variable BMPmodRo23 
    vTcl:DefineAlias "$site_3_0.che72" "Checkbutton66_11" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.che73 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra77 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra77" "Frame308" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra77
    checkbutton $site_3_0.che71 \
        \
        -command {if {"$Ro24"=="1"} {
    $widget(Checkbutton66_14) configure -state normal
    $widget(Checkbutton66_15) configure -state normal
    } else {
    $widget(Checkbutton66_14) configure -state disable
    $widget(Checkbutton66_15) configure -state disable
    set BMPmodRo24 "0"
    set BMPphaRo24 "0"
    }} \
        -text Ro24 -variable Ro24 
    vTcl:DefineAlias "$site_3_0.che71" "Checkbutton66_13" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che73 \
        -text {BMP Phase} -variable BMPphaRo24 
    vTcl:DefineAlias "$site_3_0.che73" "Checkbutton66_15" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che72 \
        -text {BMP Modulus} -variable BMPmodRo24 
    vTcl:DefineAlias "$site_3_0.che72" "Checkbutton66_14" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.che73 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra78 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra78" "Frame309" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra78
    checkbutton $site_3_0.che71 \
        \
        -command {if {"$Ro34"=="1"} {
    $widget(Checkbutton66_17) configure -state normal
    $widget(Checkbutton66_18) configure -state normal
    } else {
    $widget(Checkbutton66_17) configure -state disable
    $widget(Checkbutton66_18) configure -state disable
    set BMPmodRo34 "0"
    set BMPphaRo34 "0"
    }} \
        -text Ro34 -variable Ro34 
    vTcl:DefineAlias "$site_3_0.che71" "Checkbutton66_16" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che73 \
        -text {BMP Phase} -variable BMPphaRo34 
    vTcl:DefineAlias "$site_3_0.che73" "Checkbutton66_18" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che72 \
        -text {BMP Modulus} -variable BMPmodRo34 
    vTcl:DefineAlias "$site_3_0.che72" "Checkbutton66_17" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.che73 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra29 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra29" "Frame440" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra29
    checkbutton $site_3_0.che26 \
        \
        -command {if {"$CCC"=="1"} {
    $widget(Checkbutton66_20) configure -state normal
    $widget(Checkbutton66_21) configure -state normal
    } else {
    $widget(Checkbutton66_20) configure -state disable
    $widget(Checkbutton66_21) configure -state disable
    set BMPmodCCC "0"
    set BMPphaCCC "0"
    }} \
        -padx 1 -text C.C.C -variable CCC 
    vTcl:DefineAlias "$site_3_0.che26" "Checkbutton66_19" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che27 \
        -text {BMP Phase} -variable BMPphaCCC 
    vTcl:DefineAlias "$site_3_0.che27" "Checkbutton66_21" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che28 \
        -padx 1 -text {BMP Modulus} -variable BMPmodCCC 
    vTcl:DefineAlias "$site_3_0.che28" "Checkbutton66_20" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che26 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.che27 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che28 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd73 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd73" "Frame441" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.cpd73
    checkbutton $site_3_0.che26 \
        \
        -command {if {"$CCCnorm"=="1"} {
    $widget(Checkbutton66_23) configure -state normal
    } else {
    $widget(Checkbutton66_23) configure -state disable
    set BMPmodCCCnorm "0"
    }} \
        -padx 1 -text {Normalized C.C.C} -variable CCCnorm 
    vTcl:DefineAlias "$site_3_0.che26" "Checkbutton66_22" vTcl:WidgetProc "Toplevel66" 1
    label $site_3_0.lab74 \
        -text {                          } 
    vTcl:DefineAlias "$site_3_0.lab74" "Label1" vTcl:WidgetProc "Toplevel66" 1
    checkbutton $site_3_0.che28 \
        -padx 1 -text {BMP Modulus} -variable BMPmodCCCnorm 
    vTcl:DefineAlias "$site_3_0.che28" "Checkbutton66_23" vTcl:WidgetProc "Toplevel66" 1
    pack $site_3_0.che26 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    pack $site_3_0.lab74 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 \
        -side right 
    pack $site_3_0.che28 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra83 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame47" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra83
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel66" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label34" vTcl:WidgetProc "Toplevel66" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinRoL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel66" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd74 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd74" "Frame49" vTcl:WidgetProc "Toplevel66" 1
    set site_4_0 $site_3_0.cpd74
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label35" vTcl:WidgetProc "Toplevel66" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinRoC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel66" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {set NwinRoL "?"; set NwinRoC "?"
set Ro12 "1"
set Ro13 "1"
set Ro14 "1"
set Ro23 "1"
set Ro24 "1"
set Ro34 "1"
set CCC "1"
set CCCnorm "1"
set BMPmodRo12 "1"
set BMPphaRo12 "1"
set BMPmodRo13 "1"
set BMPphaRo13 "1"
set BMPmodRo14 "1"
set BMPphaRo14 "1"
set BMPmodRo23 "1"
set BMPphaRo23 "1"
set BMPmodRo24 "1"
set BMPphaRo24 "1"
set BMPmodRo34 "1"
set BMPphaRo34 "1"
set BMPmodCCC "1"
set BMPphaCCC "1"
set BMPmodCCCnorm "1"
$widget(Checkbutton66_2) configure -state normal
$widget(Checkbutton66_3) configure -state normal
$widget(Checkbutton66_5) configure -state normal
$widget(Checkbutton66_6) configure -state normal
$widget(Checkbutton66_8) configure -state normal
$widget(Checkbutton66_9) configure -state normal
$widget(Checkbutton66_11) configure -state normal
$widget(Checkbutton66_12) configure -state normal
$widget(Checkbutton66_14) configure -state normal
$widget(Checkbutton66_15) configure -state normal
$widget(Checkbutton66_17) configure -state normal
$widget(Checkbutton66_18) configure -state normal
$widget(Checkbutton66_20) configure -state normal
$widget(Checkbutton66_21) configure -state normal
$widget(Checkbutton66_23) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button104" vTcl:WidgetProc "Toplevel66" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {set NwinRoL "?"; set NwinRoC "?"
set Ro12 "0"
set Ro13 "0"
set Ro14 "0"
set Ro23 "0"
set Ro24 "0"
set Ro34 "0"
set CCC "0"
set CCCnorm "0"
set BMPmodRo12 "0"
set BMPphaRo12 "0"
set BMPmodRo13 "0"
set BMPphaRo13 "0"
set BMPmodRo14 "0"
set BMPphaRo14 "0"
set BMPmodRo23 "0"
set BMPphaRo23 "0"
set BMPmodRo24 "0"
set BMPphaRo24 "0"
set BMPmodRo34 "0"
set BMPphaRo34 "0"
set BMPmodCCC "0"
set BMPphaCCC "0"
set BMPmodCCCnorm "0"
$widget(Checkbutton66_2) configure -state disable
$widget(Checkbutton66_3) configure -state disable
$widget(Checkbutton66_5) configure -state disable
$widget(Checkbutton66_6) configure -state disable
$widget(Checkbutton66_8) configure -state disable
$widget(Checkbutton66_9) configure -state disable
$widget(Checkbutton66_11) configure -state disable
$widget(Checkbutton66_12) configure -state disable
$widget(Checkbutton66_14) configure -state disable
$widget(Checkbutton66_15) configure -state disable
$widget(Checkbutton66_17) configure -state disable
$widget(Checkbutton66_18) configure -state disable
$widget(Checkbutton66_20) configure -state disable
$widget(Checkbutton66_21) configure -state disable
$widget(Checkbutton66_23) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel66" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 50 -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra84 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra84" "Frame20" vTcl:WidgetProc "Toplevel66" 1
    set site_3_0 $top.fra84
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global RoDirInput RoDirOutput RoOutputDir RoOutputSubDir
global CorrelationFonction NwinRoL NwinRoC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global BMPDirInput OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set RoDirOutput $RoOutputDir
if {$RoOutputSubDir != ""} {append RoDirOutput "/$RoOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set RoDirOutput [PSPCreateDirectoryMask $RoDirOutput $RoOutputDir $RoDirInput]
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
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinRoL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinRoC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {

    if {"$Ro12" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/Ro12.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 12 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 12 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/Ro12.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodRo12"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro12.bin"
            set BMPFileOutput "$RoDirOutput/Ro12_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPphaRo12"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro12.bin"
            set BMPFileOutput "$RoDirOutput/Ro12_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    if {"$Ro13" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/Ro13.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 13 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 13 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/Ro13.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodRo13"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro13.bin"
            set BMPFileOutput "$RoDirOutput/Ro13_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPphaRo13"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro13.bin"
            set BMPFileOutput "$RoDirOutput/Ro13_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    if {"$Ro14" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/Ro14.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 14 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 14 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/Ro14.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodRo14"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro14.bin"
            set BMPFileOutput "$RoDirOutput/Ro14_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPphaRo14"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro14.bin"
            set BMPFileOutput "$RoDirOutput/Ro14_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    if {"$Ro23" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/Ro23.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 23 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 23 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/Ro23.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodRo23"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro23.bin"
            set BMPFileOutput "$RoDirOutput/Ro23_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPphaRo23"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro23.bin"
            set BMPFileOutput "$RoDirOutput/Ro23_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    if {"$Ro24" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/Ro24.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 24 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 24 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/Ro24.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodRo24"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro24.bin"
            set BMPFileOutput "$RoDirOutput/Ro24_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPphaRo24"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro24.bin"
            set BMPFileOutput "$RoDirOutput/Ro24_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    if {"$Ro34" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/Ro34.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 34 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -elt 34 -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/Ro34.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodRo34"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro34.bin"
            set BMPFileOutput "$RoDirOutput/Ro34_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPphaRo34"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/Ro34.bin"
            set BMPFileOutput "$RoDirOutput/Ro34_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    if {"$CCC" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/CCC.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr_CCC.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr_CCC.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/CCC.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodCCC"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/CCC.bin"
            set BMPFileOutput "$RoDirOutput/CCC_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPphaCCC"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/CCC.bin"
            set BMPFileOutput "$RoDirOutput/CCC_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    if {"$CCCnorm" == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoDirOutput/CCCnorm.bin"
        set CorrelationF $CorrelationFonction; if {$CorrelationFonction == "S2"} { set CorrelationF "S2b" }
        set MaskCmd ""
        set MaskFile "$RoDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr_CCC_norm.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_corr_CCC_norm.exe -id \x22$RoDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelationF -nwr $NwinRoL -nwc $NwinRoC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoDirOutput/CCCnorm.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodCCCnorm"=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoDirOutput/CCCnorm.bin"
            set BMPFileOutput "$RoDirOutput/CCCnorm_db.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
            }
        }
    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel66); TextEditorRunTrace "Close Window Correlation Coefficients 4" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel66" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/CorrelationCoefficients4.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel66" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel66); TextEditorRunTrace "Close Window Correlation Coefficients 4" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel66" 1
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
    pack $top.cpd81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra68 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra69 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra75 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra77 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra78 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra29 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra83 \
        -in $top -anchor center -expand 1 -fill none -side top 
    pack $top.fra84 \
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
Window show .top66

main $argc $argv
