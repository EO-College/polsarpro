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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}

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
    set base .top435
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd73
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
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd74 {
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
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd68 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.rad70 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd76
    namespace eval ::widgets::$site_4_0.fra435 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra435
    namespace eval ::widgets::$site_5_0.lab28 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent29 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.lab435 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd66
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.ent26 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.rad81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad82 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
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
            vTclWindow.top435
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

proc vTclWindow.top435 {base} {
    if {$base == ""} {
        set base .top435
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
    wm geometry $top 500x370+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Speckle Filter"
    vTcl:DefineAlias "$top" "Toplevel435" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd73 \
        -height 75 -width 1435 
    vTcl:DefineAlias "$top.cpd73" "Frame2" vTcl:WidgetProc "Toplevel435" 1
    set site_3_0 $top.cpd73
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel435" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FilterScattModelBasedDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel435" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel435" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel435" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel435" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable FilterScattModelBasedOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel435" 1
    frame $site_5_0.cpd73 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame1" vTcl:WidgetProc "Toplevel435" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.lab72 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab72" "Label2" vTcl:WidgetProc "Toplevel435" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FilterScattModelBasedOutputSubDir \
        -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel435" 1
    pack $site_6_0.lab72 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel435" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd74 \
        \
        -command {global DirName DataDir FilterScattModelBasedOutputDir
global VarWarning WarningMessage WarningMessage2

set FilterScattModelBasedDirOutputTmp $FilterScattModelBasedOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set FilterScattModelBasedOutputDir $DirName
        } else {
        set FilterScattModelBasedOutputDir $FilterScattModelBasedDirOutputTmp
        }
    } else {
    set FilterScattModelBasedOutputDir $FilterScattModelBasedDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd74 "$site_6_0.cpd74 Button $top all _vTclBalloon"
    bind $site_6_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
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
    frame $top.fra29 \
        -borderwidth 2 -relief groove -height 75 -width 1435 
    vTcl:DefineAlias "$top.fra29" "Frame9" vTcl:WidgetProc "Toplevel435" 1
    set site_3_0 $top.fra29
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel435" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel435" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel435" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel435" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel435" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel435" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel435" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel435" 1
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
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Single Bounce Scattering File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame6" vTcl:WidgetProc "Toplevel435" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FilterScattModelBasedSBFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel435" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel435" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd74 \
        \
        -command {global FilterScattModelBasedDirInput FilterScattModelBasedSBFile

set FilterScattModelBasedSBFile ""
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $FilterScattModelBasedDirInput $types "INPUT SB FILE"
    
if {$FileName != ""} {
    set FilterScattModelBasedSBFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_5_0.cpd74 "$site_5_0.cpd74 Button $top all _vTclBalloon"
    bind $site_5_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd67 \
        -ipad 0 -text {Double Bounce Scattering File} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame7" vTcl:WidgetProc "Toplevel435" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FilterScattModelBasedDBFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel435" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel435" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd74 \
        \
        -command {global FilterScattModelBasedDirInput FilterScattModelBasedDBFile

set FilterScattModelBasedDBFile ""
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $FilterScattModelBasedDirInput $types "INPUT DB FILE"
    
if {$FileName != ""} {
    set FilterScattModelBasedDBFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_5_0.cpd74 "$site_5_0.cpd74 Button $top all _vTclBalloon"
    bind $site_5_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd68 \
        -ipad 0 -text {Random / Volume Scattering File} 
    vTcl:DefineAlias "$top.cpd68" "TitleFrame8" vTcl:WidgetProc "Toplevel435" 1
    bind $top.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd68 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FilterScattModelBasedRVFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel435" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel435" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd74 \
        \
        -command {global FilterScattModelBasedDirInput FilterScattModelBasedRVFile

set FilterScattModelBasedRVFile ""
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $FilterScattModelBasedDirInput $types "INPUT RV FILE"
    
if {$FileName != ""} {
    set FilterScattModelBasedRVFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_5_0.cpd74 "$site_5_0.cpd74 Button $top all _vTclBalloon"
    bind $site_5_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame3" vTcl:WidgetProc "Toplevel435" 1
    set site_3_0 $top.fra66
    TitleFrame $site_3_0.cpd68 \
        -ipad 0 -text Type 
    vTcl:DefineAlias "$site_3_0.cpd68" "TitleFrame2" vTcl:WidgetProc "Toplevel435" 1
    bind $site_3_0.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    radiobutton $site_5_0.rad70 \
        -text {Box Car} -value box -variable FilterScattModelBasedType 
    vTcl:DefineAlias "$site_5_0.rad70" "Radiobutton3" vTcl:WidgetProc "Toplevel435" 1
    radiobutton $site_5_0.cpd71 \
        -text M.M.S.E -value mmse -variable FilterScattModelBasedType 
    vTcl:DefineAlias "$site_5_0.cpd71" "Radiobutton4" vTcl:WidgetProc "Toplevel435" 1
    pack $site_5_0.rad70 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    frame $site_3_0.cpd76 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_3_0.cpd76" "Frame250" vTcl:WidgetProc "Toplevel435" 1
    set site_4_0 $site_3_0.cpd76
    frame $site_4_0.fra435 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_4_0.fra435" "Frame251" vTcl:WidgetProc "Toplevel435" 1
    set site_5_0 $site_4_0.fra435
    label $site_5_0.lab28 \
        -padx 1 -text {Number of Looks} 
    vTcl:DefineAlias "$site_5_0.lab28" "Label435" vTcl:WidgetProc "Toplevel435" 1
    entry $site_5_0.ent29 \
        -background white -foreground #ff0000 -justify center \
        -textvariable Nlook -width 5 
    vTcl:DefineAlias "$site_5_0.ent29" "Entry435" vTcl:WidgetProc "Toplevel435" 1
    pack $site_5_0.lab28 \
        -in $site_5_0 -anchor center -expand 0 -fill none -ipadx 5 -side left 
    pack $site_5_0.ent29 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame4351" vTcl:WidgetProc "Toplevel435" 1
    set site_5_0 $site_4_0.cpd66
    label $site_5_0.lab435 \
        -padx 1 -text {Window Size Row / Col} 
    vTcl:DefineAlias "$site_5_0.lab435" "Label436" vTcl:WidgetProc "Toplevel435" 1
    frame $site_5_0.cpd66 \
        -borderwidth 2 -height 75 -width 1435 
    vTcl:DefineAlias "$site_5_0.cpd66" "Frame4352" vTcl:WidgetProc "Toplevel435" 1
    set site_6_0 $site_5_0.cpd66
    button $site_6_0.cpd70 \
        \
        -command {global FilterScattModelBasedNwinL

set FilterScattModelBasedNwinL [expr $FilterScattModelBasedNwinL + 2]
if {$FilterScattModelBasedNwinL == 17} { set FilterScattModelBasedNwinL 7}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd70" "Button5" vTcl:WidgetProc "Toplevel435" 1
    button $site_6_0.cpd71 \
        \
        -command {global FilterScattModelBasedNwinL

set FilterScattModelBasedNwinL [expr $FilterScattModelBasedNwinL - 2]
if {$FilterScattModelBasedNwinL == 5} { set FilterScattModelBasedNwinL 15}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button6" vTcl:WidgetProc "Toplevel435" 1
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    entry $site_5_0.ent26 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FilterScattModelBasedNwinL -width 5 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry436" vTcl:WidgetProc "Toplevel435" 1
    pack $site_5_0.lab435 \
        -in $site_5_0 -anchor center -expand 0 -fill none -ipadx 5 -side left 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent26 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra435 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_3_0.cpd67 \
        -text {Output Format} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame435_1" vTcl:WidgetProc "Toplevel435" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    radiobutton $site_5_0.rad81 \
        \
        -command {global FilterScattModelBasedOutputSubDir

set FilterScattModelBasedOutputSubDir "T3"
} \
        -text {[S2] >> [T3]} -value S2T3 -variable FilterScattModelBasedFonc 
    vTcl:DefineAlias "$site_5_0.rad81" "Radiobutton435_1" vTcl:WidgetProc "Toplevel435" 1
    radiobutton $site_5_0.rad82 \
        \
        -command {global FilterScattModelBasedOutputSubDir

set FilterScattModelBasedOutputSubDir "C3"
} \
        -text {[S2] >> [C3]} -value S2C3 -variable FilterScattModelBasedFonc 
    vTcl:DefineAlias "$site_5_0.rad82" "Radiobutton435_2" vTcl:WidgetProc "Toplevel435" 1
    pack $site_5_0.rad81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.rad82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra36 \
        -relief groove -height 35 -width 1435 
    vTcl:DefineAlias "$top.fra36" "Frame20" vTcl:WidgetProc "Toplevel435" 1
    set site_3_0 $top.fra36
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir DirName OpenDirFile COLORMAPDir
global FilterScattModelBasedDirInput FilterScattModelBasedDirOutput FilterScattModelBasedOutputDir FilterScattModelBasedOutputSubDir
global FilterScattModelBasedSBFile FilterScattModelBasedDBFile FilterScattModelBasedRVFile
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType FilterScattModelBasedNwinL
global NligFullSize NcolFullSize TMPDirectory FilterScattModelBasedType
global FilterScattModelBasedFonc PSPMemory TMPMemoryAllocError DataFormatActive
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set FilterScattModelBasedDirOutput $FilterScattModelBasedOutputDir
if {$FilterScattModelBasedOutputSubDir != ""} {append FilterScattModelBasedDirOutput "/$FilterScattModelBasedOutputSubDir"}

    #####################################################################
    #Create Directory
    set FilterScattModelBasedDirOutput [PSPCreateDirectory $FilterScattModelBasedDirOutput $FilterScattModelBasedOutputDir $FilterScattModelBasedFonc]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Number of Looks"; set TestVarType(4) "int"; set TestVarValue(4) $Nlook; set TestVarMin(4) "1"; set TestVarMax(4) "100"
    TestVar 5
    if {$TestVarError == "ok"} {
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        set config "true"
        if {$FilterScattModelBasedSBFile == ""} {
            set config "false"
            set VarError ""
            set ErrorMessage "THE Single Bounce Scattering File DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } 
        if {$FilterScattModelBasedDBFile == ""} {
            set config "false"
            set VarError ""
            set ErrorMessage "THE Double Bounce Scattering File DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } 
        if {$FilterScattModelBasedRVFile == ""} {
            set config "false"
            set VarError ""
            set ErrorMessage "THE Random / Volume Scattering File DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } 
        if {"$config"=="true"} {

            set Fonction ""
            set Fonction2 ""
            set MaskCmd ""
            set MaskFile "$FilterScattModelBasedDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
    
            if {$FilterScattModelBasedNwinL == 7} { set FilterScattModelBasedClusterFin 5 }
            if {$FilterScattModelBasedNwinL == 9} { set FilterScattModelBasedClusterFin 5 }
            if {$FilterScattModelBasedNwinL == 11} { set FilterScattModelBasedClusterFin 7 }
            if {$FilterScattModelBasedNwinL == 13} { set FilterScattModelBasedClusterFin 7 }
            if {$FilterScattModelBasedNwinL == 15} { set FilterScattModelBasedClusterFin 9 }

            set FilterScattModelBasedColorMapFile "$COLORMAPDir/ColorMap_OCEAN.pal"

            TextEditorRunTrace "Process The Function Soft/data_process_sngl/lee_scattering_model_based_classification.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$FilterScattModelBasedDirInput\x22 -od \x22$FilterScattModelBasedDirInput\x22 -isf \x22$FilterScattModelBasedSBFile\x22 -idf \x22$FilterScattModelBasedDBFile\x22 -irf \x22$FilterScattModelBasedRVFile\x22 -iodf $DataFormatActive -nwr $FilterScattModelBasedNwinL -nwc $FilterScattModelBasedNwinL -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct 10 -nit 10 -bmp 0 -ncl 30 -mct -1 -fscn $FilterScattModelBasedClusterFin -fdcn $FilterScattModelBasedClusterFin -fvcn $FilterScattModelBasedClusterFin -cms \x22$FilterScattModelBasedColorMapFile\x22 -cmd \x22$FilterScattModelBasedColorMapFile\x22 -cmr \x22$FilterScattModelBasedColorMapFile\x22 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/lee_scattering_model_based_classification.exe -id \x22$FilterScattModelBasedDirInput\x22 -od \x22$FilterScattModelBasedDirInput\x22 -isf \x22$FilterScattModelBasedSBFile\x22 -idf \x22$FilterScattModelBasedDBFile\x22 -irf \x22$FilterScattModelBasedRVFile\x22 -iodf $DataFormatActive -nwr $FilterScattModelBasedNwinL -nwc $FilterScattModelBasedNwinL -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct 10 -nit 10 -bmp 0 -ncl 30 -mct -1 -fscn $FilterScattModelBasedClusterFin -fdcn $FilterScattModelBasedClusterFin -fvcn $FilterScattModelBasedClusterFin -cms \x22$FilterScattModelBasedColorMapFile\x22 -cmd \x22$FilterScattModelBasedColorMapFile\x22 -cmr \x22$FilterScattModelBasedColorMapFile\x22 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            set ClassificationFile "$FilterScattModelBasedDirInput/scattering_model_based_classification_"
            append ClassificationFile $FilterScattModelBasedNwinL; append ClassificationFile "x"; append ClassificationFile $FilterScattModelBasedNwinL
            set ClassificationInputFile "$ClassificationFile.bin"
            if [file exists $ClassificationInputFile] {EnviWriteConfig $ClassificationInputFile $FinalNlig $FinalNcol 4}

  
            set ConfigFile "$FilterScattModelBasedDirOutput/config.txt"
            WriteConfig

            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/speckle_filter/lee_scattering_model_based_filter.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$FilterScattModelBasedDirInput\x22 -od \x22$FilterScattModelBasedDirOutput\x22 -icf \x22$ClassificationInputFile\x22 -iodf $FilterScattModelBasedFonc -typ $FilterScattModelBasedType -nc $FilterScattModelBasedClusterFin -nw $FilterScattModelBasedNwinL -nlk $Nlook -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/speckle_filter/lee_scattering_model_based_filter.exe -id \x22$FilterScattModelBasedDirInput\x22 -od \x22$FilterScattModelBasedDirOutput\x22 -icf \x22$ClassificationInputFile\x22 -iodf $FilterScattModelBasedFonc -typ $FilterScattModelBasedType -nc $FilterScattModelBasedClusterFin -nw $FilterScattModelBasedNwinL -nlk $Nlook -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            
            if {"$FilterScattModelBasedFonc" ==  "T3"} {EnviWriteConfigT $FilterScattModelBasedDirOutput $FinalNlig $FinalNcol}
            if {"$FilterScattModelBasedFonc" ==  "C3"} {EnviWriteConfigC $FilterScattModelBasedDirOutput $FinalNlig $FinalNcol}
            if {"$FilterScattModelBasedFonc" ==  "S2T3"} {EnviWriteConfigT $FilterScattModelBasedDirOutput $FinalNlig $FinalNcol}
            if {"$FilterScattModelBasedFonc" ==  "S2C3"} {EnviWriteConfigC $FilterScattModelBasedDirOutput $FinalNlig $FinalNcol}
    
            set DataDir $FilterScattModelBasedOutputDir

            if {$DataFormatActive == "S2"} {
                set WarningMessage "THE DATA FORMAT TO BE PROCESSED IS NOW:"
                if {$FilterScattModelBasedFonc == "S2T3"} {set WarningMessage2 "3x3 COHERENCY MATRIX - T3"; set DataFormatActive "T3"}
                if {$FilterScattModelBasedFonc == "S2C3"} {set WarningMessage2 "3x3 COVARIANCE MATRIX - C3"; set DataFormatActive "C3"}
                set VarAdvice ""
                Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
                tkwait variable VarAdvice
                }
           
            Window hide $widget(Toplevel435); TextEditorRunTrace "Close Window Scattering Model Based Speckle Filter" "b"
            }
        }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel435); TextEditorRunTrace "Close Window Scattering Model Based Speckle Filter" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel435" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SpeckleFilterScattModelBased.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel435" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel435); TextEditorRunTrace "Close Window Scattering Model Based Speckle Filter" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel435" 1
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
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra29 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
        -in $top -anchor center -expand 1 -fill x -side bottom 

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
Window show .top435

main $argc $argv
