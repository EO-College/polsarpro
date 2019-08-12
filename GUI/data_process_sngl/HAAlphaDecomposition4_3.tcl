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
    set base .top325
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd88
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
    namespace eval ::widgets::$site_5_0.cpd325 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd325
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
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
    namespace eval ::widgets::$base.cpd76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd76
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra48 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra48
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra30 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra30
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra22 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra22
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra23
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd78
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd74
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd75
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd73
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra55 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra55
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
    namespace eval ::widgets::$site_3_0.cpd104 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd104
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd103 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd103
    namespace eval ::widgets::$site_3_0.fra78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra78
    namespace eval ::widgets::$site_4_0.che80 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
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
            vTclWindow.top325
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

proc vTclWindow.top325 {base} {
    if {$base == ""} {
        set base .top325
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
    wm geometry $top 500x560+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: H / A / Alpha Eigenvalue Set Parameters"
    vTcl:DefineAlias "$top" "Toplevel325" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame4" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd88
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel325" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HAAlpDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel325" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel325" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel325" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel325" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HAAlpOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel325" 1
    frame $site_5_0.cpd325 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd325" "Frame16" vTcl:WidgetProc "Toplevel325" 1
    set site_6_0 $site_5_0.cpd325
    label $site_6_0.cpd78 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd78" "Label14" vTcl:WidgetProc "Toplevel325" 1
    entry $site_6_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HAAlpOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel325" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame17" vTcl:WidgetProc "Toplevel325" 1
    set site_6_0 $site_5_0.cpd76
    button $site_6_0.cpd89 \
        \
        -command {global DirName DataDir HAAlpOutputDir

set HAAlpDirOutputTmp $HAAlpOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set HAAlpOutputDir $DirName
    } else {
    set HAAlpOutputDir $HAAlpDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd325 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra36 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame9" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.fra36
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel325" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel325" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel325" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel325" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel325" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel325" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel325" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel325" 1
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
    frame $top.cpd76 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd76" "Frame328" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd76
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$eigenvalues"=="1"} {
    $widget(Checkbutton325_1) configure -state normal
    } else {
    $widget(Checkbutton325_1) configure -state disable
    set BMPeigenvalues "0"
    }} \
        -text {Eigenvalues ( L1 , L2 , L3 , L4 )} -variable eigenvalues 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton167" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPeigenvalues 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_1" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd77 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame329" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd77
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$probabilities"=="1"} {
    $widget(Checkbutton325_2) configure -state normal 
    } else {
    $widget(Checkbutton325_2) configure -state disable
    set BMPprobabilities "0"
    }} \
        -text {Pseudo Probabilities ( p1 , p2 , p3 , p4 )} \
        -variable probabilities 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton168" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPprobabilities 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_2" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra48 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra48" "Frame42" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.fra48
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$anisotropy"=="1"} {
    $widget(Checkbutton325_3) configure -state normal
    } else {
    $widget(Checkbutton325_3) configure -state disable
    set BMPanisotropy "0"
    }} \
        -text {Anisotropy  ( A )  ( p2 , p3 )} -variable anisotropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton172" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -text BMP -variable BMPanisotropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_3" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra30 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    set site_3_0 $top.fra30
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$anisotropy12"=="1"} {
    $widget(Checkbutton325_4) configure -state normal
    } else {
    $widget(Checkbutton325_4) configure -state disable
    set BMPanisotropy12 "0"
    }} \
        -text {Anisotropy12  ( A12 )  ( p1 , p2 )} -variable anisotropy12 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton174" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -text BMP -variable BMPanisotropy12 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_4" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra92 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame269" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.fra92
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$anisotropy34"=="1"} {
    $widget(Checkbutton325_5) configure -state normal
    } else {
    $widget(Checkbutton325_5) configure -state disable
    set BMPanisotropy34 "0"
    }} \
        -padx 1 -text {Anisotropy34  ( A34 )  ( p3 , p4 )} \
        -variable anisotropy34 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton176" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPanisotropy34 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_5" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame43" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd72
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$erd"=="1"} {
    $widget(Checkbutton325_6) configure -state normal
    } else {
    $widget(Checkbutton325_6) configure -state disable
    set BMPerd "0"
    }} \
        -text {EigenValues Relative Difference ( E.R.D )} -variable erd 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton173" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -text BMP -variable BMPerd 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_6" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra22 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra22" "Frame319" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.fra22
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$polarisationasymetry"=="1"} {
    $widget(Checkbutton325_7) configure -state normal
    } else {
    $widget(Checkbutton325_7) configure -state disable
    set BMPpolarisationasymetry "0"
    }} \
        -padx 1 -text {Polarisation Asymmetry  ( p1 - p2 , 1 - 3(p3+p4) )} \
        -variable polarisationasymetry 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton178" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPpolarisationasymetry 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_7" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra23 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra23" "Frame320" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.fra23
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$polarisationfraction"=="1"} {
    $widget(Checkbutton325_8) configure -state normal
    } else {
    $widget(Checkbutton325_8) configure -state disable
    set BMPpolarisationfraction "0"
    }} \
        -padx 1 -text {Polarisation Fraction  ( 1 - 3(p3+p4) )} \
        -variable polarisationfraction 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton180" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPpolarisationfraction 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_8" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd78 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd78" "Frame331" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd78
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$lueneburganisotropy"=="1"} {
    $widget(Checkbutton325_15) configure -state normal
    } else {
    $widget(Checkbutton325_15) configure -state disable
    set BMPlueneburganisotropy "0"
    }} \
        -padx 1 -text {Lueneburg Anisotropy} -variable lueneburganisotropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton163" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPlueneburganisotropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_15" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd74" "Frame326" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd74
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$vanzylrvi"=="1"} {
    $widget(Checkbutton325_11) configure -state normal
    } else {
    $widget(Checkbutton325_11) configure -state disable
    set BMPvanzylrvi "0"
    }} \
        -text {Radar Vegetation Index ( R.V.I )} -variable vanzylrvi 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton165" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPvanzylrvi 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_11" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd75 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame327" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd75
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$vanzylpedestal"=="1"} {
    $widget(Checkbutton325_12) configure -state normal
    } else {
    $widget(Checkbutton325_12) configure -state disable
    set BMPvanzylpedestal "0"
    }} \
        -text {Pedestal Height} -variable vanzylpedestal 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton166" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPvanzylpedestal 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_12" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd73 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd73" "Frame330" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd73
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$shannon"=="1"} {
    $widget(Checkbutton325_14) configure -state normal
    } else {
    $widget(Checkbutton325_14) configure -state disable
    set BMPshannon "0"
    }} \
        -text {Shannon Entropy (H = Hi + Hp)} -variable shannon 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton169" vTcl:WidgetProc "Toplevel325" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPshannon 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton325_14" vTcl:WidgetProc "Toplevel325" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra55 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame47" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.fra55
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel325" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label34" vTcl:WidgetProc "Toplevel325" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinHAAlpL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel325" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd104 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd104" "Frame49" vTcl:WidgetProc "Toplevel325" 1
    set site_4_0 $site_3_0.cpd104
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label35" vTcl:WidgetProc "Toplevel325" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinHAAlpC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel325" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.cpd72 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set eigenvalues "1"
set probabilities "1"
set anisotropy "1"
set anisotropy12 "1"
set anisotropy34 "1"
set erd "1"
set polarisationasymetry "1"
set polarisationfraction "1"
set lueneburganisotropy "1"
set vanzylrvi "1"
set vanzylpedestal "1"
set shannon "1"
set BMPeigenvalues "1"
set BMPprobabilities "1"
set BMPanisotropy "1"
set BMPanisotropy12 "1"
set BMPanisotropy34 "1"
set BMPerd "1"
set BMPpolarisationasymetry "1"
set BMPpolarisationfraction "1"
set BMPlueneburganisotropy "1"
set BMPvanzylrvi "1"
set BMPvanzylpedestal "1"
set BMPshannon "1"
$widget(Checkbutton325_1) configure -state normal
$widget(Checkbutton325_2) configure -state normal
$widget(Checkbutton325_3) configure -state normal
$widget(Checkbutton325_4) configure -state normal
$widget(Checkbutton325_5) configure -state normal
$widget(Checkbutton325_6) configure -state normal
$widget(Checkbutton325_7) configure -state normal
$widget(Checkbutton325_8) configure -state normal
$widget(Checkbutton325_11) configure -state normal
$widget(Checkbutton325_12) configure -state normal
$widget(Checkbutton325_14) configure -state normal
$widget(Checkbutton325_15) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd72" "Button104" vTcl:WidgetProc "Toplevel325" 1
    bindtags $site_3_0.cpd72 "$site_3_0.cpd72 Button $top all _vTclBalloon"
    bind $site_3_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set eigenvalues "0"
set probabilities "0"
set anisotropy "0"
set anisotropy12 "0"
set anisotropy34 "0"
set erd "0"
set polarisationasymetry "0"
set polarisationfraction "0"
set lueneburganisotropy "0"
set vanzylrvi "0"
set vanzylpedestal "0"
set shannon "0"
set BMPeigenvalues "0"
set BMPprobabilities "0"
set BMPanisotropy "0"
set BMPanisotropy12 "0"
set BMPanisotropy34 "0"
set BMPerd "0"
set BMPpolarisationasymetry "0"
set BMPpolarisationfraction "0"
set BMPlueneburganisotropy "0"
set BMPvanzylrvi "0"
set BMPvanzylpedestal "0"
set BMPshannon "0"
$widget(Checkbutton325_1) configure -state disable
$widget(Checkbutton325_2) configure -state disable
$widget(Checkbutton325_3) configure -state disable
$widget(Checkbutton325_4) configure -state disable
$widget(Checkbutton325_5) configure -state disable
$widget(Checkbutton325_6) configure -state disable
$widget(Checkbutton325_7) configure -state disable
$widget(Checkbutton325_8) configure -state disable
$widget(Checkbutton325_11) configure -state disable
$widget(Checkbutton325_12) configure -state disable
$widget(Checkbutton325_14) configure -state disable
$widget(Checkbutton325_15) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel325" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd104 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 20 -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.cpd103 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd103" "Frame1" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.cpd103
    frame $site_3_0.fra78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra78" "Frame2" vTcl:WidgetProc "Toplevel325" 1
    set site_4_0 $site_3_0.fra78
    checkbutton $site_4_0.che80 \
        -text {Equivalence between [ T ] and  [ C ] eigen-decompositions.} \
        -variable EquivHAAlpDecomp 
    vTcl:DefineAlias "$site_4_0.che80" "Checkbutton325_13" vTcl:WidgetProc "Toplevel325" 1
    pack $site_4_0.che80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra78 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel325" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global HAAlpDirInput HAAlpDirOutput HAAlpOutputDir HAAlpOutputSubDir
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine
global HAAlphaDecompositionFonction EquivHAAlpDecomp NwinHAAlpL NwinHAAlpC
global BMPDirInput OpenDirFile TMPMemoryAllocError

if {$OpenDirFile == 0} {

set config "false"
if {"$eigenvalues"=="1"} { set config "true" }
if {"$probabilities"=="1"} { set config "true" }
if {"$anisotropy"=="1"} { set config "true" }
if {"$anisotropy12"=="1"} { set config "true" }
if {"$anisotropy34"=="1"} { set config "true" }
if {"$erd"=="1"} { set config "true" }
if {"$polarisationasymetry"=="1"} { set config "true" }
if {"$polarisationfraction"=="1"} { set config "true" }
if {"$lueneburganisotropy"=="1"} { set config "true" }
if {"$vanzylrvi"=="1"} { set config "true" }
if {"$vanzylpedestal"=="1"} { set config "true" }
if {"$shannon"=="1"} { set config "true" }

if {"$config"=="true"} {

    set HAAlpDirOutput $HAAlpOutputDir
    if {$HAAlpOutputSubDir != ""} {append HAAlpDirOutput "/$HAAlpOutputSubDir"}

    #####################################################################
    #Create Directory
    set HAAlpDirOutput [PSPCreateDirectoryMask $HAAlpDirOutput $HAAlpOutputDir $HAAlpDirInput]
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
        set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinHAAlpL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinHAAlpC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
        TestVar 6
        if {$TestVarError == "ok"} {
            set Fonction "Creation of all the Binary Data Files"
            set Fonction2 "of the H / A / Alpha Decomposition"
            set MaskCmd ""
            set MaskFile "$HAAlpDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set HAAlphaDecompositionF $HAAlphaDecompositionFonction
            if {"$HAAlphaDecompositionFonction" == "S2"} { set HAAlphaDecompositionF "S2T4" }
            if {"$HAAlphaDecompositionFonction" == "C4"} {
                if {$EquivHAAlpDecomp == "1"} { set HAAlphaDecompositionF "C4T4" }
                }
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaDecompositionF -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $eigenvalues -fl2 $probabilities -fl3 $anisotropy -fl4 $anisotropy12 -fl5 $anisotropy34 -fl6 $polarisationasymetry -fl7 $polarisationfraction -fl8 $erd -fl9 $vanzylrvi -fl10 $vanzylpedestal -fl11 $shannon -fl12 $lueneburganisotropy  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaDecompositionF -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $eigenvalues -fl2 $probabilities -fl3 $anisotropy -fl4 $anisotropy12 -fl5 $anisotropy34 -fl6 $polarisationasymetry -fl7 $polarisationfraction -fl8 $erd -fl9 $vanzylrvi -fl10 $vanzylpedestal -fl11 $shannon -fl12 $lueneburganisotropy  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            if {"$eigenvalues"=="1"} {
                if [file exists "$HAAlpDirOutput/l1.bin"] {EnviWriteConfig "$HAAlpDirOutput/l1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/l2.bin"] {EnviWriteConfig "$HAAlpDirOutput/l2.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/l3.bin"] {EnviWriteConfig "$HAAlpDirOutput/l3.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/l4.bin"] {EnviWriteConfig "$HAAlpDirOutput/l4.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$probabilities"=="1"} {
                if [file exists "$HAAlpDirOutput/p1.bin"] {EnviWriteConfig "$HAAlpDirOutput/p1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/p2.bin"] {EnviWriteConfig "$HAAlpDirOutput/p2.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/p3.bin"] {EnviWriteConfig "$HAAlpDirOutput/p3.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/p4.bin"] {EnviWriteConfig "$HAAlpDirOutput/p4.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$anisotropy"=="1"} {
                if [file exists "$HAAlpDirOutput/anisotropy.bin"] {EnviWriteConfig "$HAAlpDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$anisotropy12"=="1"} { 
                if [file exists "$HAAlpDirOutput/anisotropy12.bin"] {EnviWriteConfig "$HAAlpDirOutput/anisotropy12.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$anisotropy34"=="1"} {
                if [file exists "$HAAlpDirOutput/anisotropy34.bin"] {EnviWriteConfig "$HAAlpDirOutput/anisotropy34.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$erd"=="1"} {
                if [file exists "$HAAlpDirOutput/serd.bin"] {EnviWriteConfig "$HAAlpDirOutput/serd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/derd.bin"] {EnviWriteConfig "$HAAlpDirOutput/derd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/serd_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/serd_norm.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/derd_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/derd_norm.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$polarisationasymetry"=="1"} {
                if [file exists "$HAAlpDirOutput/asymetry.bin"] {EnviWriteConfig "$HAAlpDirOutput/asymetry.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$polarisationfraction"=="1"} {
                if [file exists "$HAAlpDirOutput/polarisation_fraction.bin"] {EnviWriteConfig "$HAAlpDirOutput/polarisation_fraction.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$vanzylrvi"=="1"} {
                if [file exists "$HAAlpDirOutput/rvi.bin"] {EnviWriteConfig "$HAAlpDirOutput/rvi.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$vanzylpedestal"=="1"} {
                if [file exists "$HAAlpDirOutput/pedestal.bin"] {EnviWriteConfig "$HAAlpDirOutput/pedestal.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$shannon"=="1"} {
                if [file exists "$HAAlpDirOutput/entropy_shannon.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_I.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_I.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_P.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_P.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_norm.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_I_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_I_norm.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_P_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_P_norm.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$lueneburganisotropy"=="1"} {
                if [file exists "$HAAlpDirOutput/anisotropy_lueneburg.bin"] {EnviWriteConfig "$HAAlpDirOutput/anisotropy_lueneburg.bin" $FinalNlig $FinalNcol 4}
                }
            #Update the Nlig/Ncol of the new image after processing
            set NligInit 1
            set NcolInit 1
            set NligEnd $FinalNlig
            set NcolEnd $FinalNcol
            
        #####################################################################       

        set Fonction "Creation of the BMP File"

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        if {"$BMPeigenvalues"=="1"} {
            if [file exists "$HAAlpDirOutput/l1.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/l1.bin"
                set BMPFileOutput "$HAAlpDirOutput/l1_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/l2.bin"
                set BMPFileOutput "$HAAlpDirOutput/l2_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/l3.bin"
                set BMPFileOutput "$HAAlpDirOutput/l3_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/l4.bin"
                set BMPFileOutput "$HAAlpDirOutput/l4_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPprobabilities"=="1"} {
            if [file exists "$HAAlpDirOutput/p1.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/p1.bin"
                set BMPFileOutput "$HAAlpDirOutput/p1.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0.25 1.0
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/p2.bin"
                set BMPFileOutput "$HAAlpDirOutput/p2.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 0.5
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/p3.bin"
                set BMPFileOutput "$HAAlpDirOutput/p3.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 0.33
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/p4.bin"
                set BMPFileOutput "$HAAlpDirOutput/p4.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 0.25
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPanisotropy"=="1"} {
            if [file exists "$HAAlpDirOutput/anisotropy.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/anisotropy.bin"
                set BMPFileOutput "$HAAlpDirOutput/anisotropy.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPerd"=="1"} {
            if [file exists "$HAAlpDirOutput/serd.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/serd.bin"
                set BMPFileOutput "$HAAlpDirOutput/serd.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -1 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/derd.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/derd.bin"
                set BMPFileOutput "$HAAlpDirOutput/derd.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -1 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/serd_norm.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/serd_norm.bin"
                set BMPFileOutput "$HAAlpDirOutput/serd_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/derd_norm.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/derd_norm.bin"
                set BMPFileOutput "$HAAlpDirOutput/derd_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPanisotropy12"=="1"} {
            if [file exists "$HAAlpDirOutput/anisotropy12.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/anisotropy12.bin"
                set BMPFileOutput "$HAAlpDirOutput/anisotropy12.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPanisotropy34"=="1"} {
            if [file exists "$HAAlpDirOutput/anisotropy34.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/anisotropy34.bin"
                set BMPFileOutput "$HAAlpDirOutput/anisotropy34.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        
        if {"$BMPpolarisationasymetry"=="1"} {
            if [file exists "$HAAlpDirOutput/asymetry.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/asymetry.bin"
                set BMPFileOutput "$HAAlpDirOutput/asymetry.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPpolarisationfraction"=="1"} {
            if [file exists "$HAAlpDirOutput/polarisation_fraction.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/polarisation_fraction.bin"
                set BMPFileOutput "$HAAlpDirOutput/polarisation_fraction.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPvanzylrvi"=="1"} {
            if [file exists "$HAAlpDirOutput/rvi.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/rvi.bin"
                set BMPFileOutput "$HAAlpDirOutput/rvi.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPvanzylpedestal"=="1"} {
            if [file exists "$HAAlpDirOutput/pedestal.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/pedestal.bin"
                set BMPFileOutput "$HAAlpDirOutput/pedestal.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPshannon"=="1"} {
            if [file exists "$HAAlpDirOutput/entropy_shannon.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy_shannon.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy_shannon.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/entropy_shannon_I.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy_shannon_I.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy_shannon_I.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/entropy_shannon_P.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy_shannon_P.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy_shannon_P.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/entropy_shannon_norm.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy_shannon_norm.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy_shannon_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/entropy_shannon_I_norm.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy_shannon_I_norm.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy_shannon_I_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/entropy_shannon_P_norm.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy_shannon_P_norm.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy_shannon_P_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPlueneburganisotropy"=="1"} {
            if [file exists "$HAAlpDirOutput/anisotropy_lueneburg.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/anisotropy_lueneburg.bin"
                set BMPFileOutput "$HAAlpDirOutput/anisotropy_lueneburg.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel325); TextEditorRunTrace "Close Window H A Alpha Eigenvalue Set Parameters 4" "b"}
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel325" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/HAAlphaDecomposition4_3.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel325" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel325); TextEditorRunTrace "Close Window H A Alpha Eigenvalue Set Parameters 4" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel325" 1
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
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd76 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra48 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra30 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra92 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra22 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra23 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd78 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd103 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -pady 5 -side top 

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
Window show .top325

main $argc $argv
