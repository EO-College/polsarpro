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
    set base .top93
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd84
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
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd84
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$base.fra37 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra37
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra40 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra40
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra43 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra43
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra45 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra45
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd73
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra46 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra46
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra47 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra47
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra48 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra48
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra26 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra26
    namespace eval ::widgets::$site_3_0.che110 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra111 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra111
    namespace eval ::widgets::$site_4_0.che112 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.che113 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra117 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra117
    namespace eval ::widgets::$site_4_0.che114 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.che115 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che116 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd74
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
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
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd84
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top93
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

proc vTclWindow.top93 {base} {
    if {$base == ""} {
        set base .top93
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
    wm title $top "Data Processing: H / A / Alpha Decomposition"
    vTcl:DefineAlias "$top" "Toplevel93" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd84" "Frame4" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.cpd84
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel93" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HAAlpDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel93" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel93" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel93" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel93" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HAAlpOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel93" 1
    frame $site_5_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd84" "Frame1" vTcl:WidgetProc "Toplevel93" 1
    set site_6_0 $site_5_0.cpd84
    label $site_6_0.lab82 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab82" "Label1" vTcl:WidgetProc "Toplevel93" 1
    entry $site_6_0.cpd86 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HAAlpOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd86" "Entry1" vTcl:WidgetProc "Toplevel93" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel93" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd85 \
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
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd85 "$site_6_0.cpd85 Button $top all _vTclBalloon"
    bind $site_6_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra36 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame9" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra36
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel93" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel93" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel93" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel93" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel93" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel93" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel93" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel93" 1
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
    frame $top.fra37 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra37" "Frame33" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra37
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$eigenvalues"=="1"} { $widget(Checkbutton93_1) configure -state normal
} else {
$widget(Checkbutton93_1) configure -state disable
set BMPeigenvalues "0"
}} \
        -padx 1 -text {EigenValues (L1, L2) } -variable eigenvalues 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton190" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPeigenvalues 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_1" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra40 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra40" "Frame34" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra40
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$probabilities"=="1"} { $widget(Checkbutton93_2) configure -state normal 
} else {
$widget(Checkbutton93_2) configure -state disable
set BMPprobabilities "0"
}} \
        -padx 1 -text {PseudoProbabilities (p1, p2)} -variable probabilities 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton192" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPprobabilities 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_2" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra41 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame35" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra41
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$alpha12"=="1"} { $widget(Checkbutton93_3) configure -state normal 
} else {
$widget(Checkbutton93_3) configure -state disable
set BMPalpha12 "0"
}} \
        -padx 1 -text {Alpha1, Alpha2} -variable alpha12 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton194" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPalpha12 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_3" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra43 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra43" "Frame37" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra43
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$delta12"=="1"} { $widget(Checkbutton93_4) configure -state normal
} else {
$widget(Checkbutton93_4) configure -state disable
set BMPdelta12 "0"
}} \
        -padx 1 -text {Delta1, Delta2} -variable delta12 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton196" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPdelta12 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_4" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra45 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra45" "Frame39" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra45
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$alpdel"=="1"} { $widget(Checkbutton93_5) configure -state normal
} else {
$widget(Checkbutton93_5) configure -state disable
set BMPalpdel "0"
}} \
        -padx 1 -text {Alpha, Delta, Lambda} -variable alpdel 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton198" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPalpdel 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_5" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd73 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd73" "Frame43" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.cpd73
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$lambda"=="1"} { $widget(Checkbutton93_14) configure -state normal
} else {
$widget(Checkbutton93_14) configure -state disable
set BMPlambda "0"
}} \
        -padx 1 -text Lambda -variable lambda 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton201" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPlambda 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_14" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra46 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra46" "Frame40" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra46
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$alpha"=="1"} { $widget(Checkbutton93_6) configure -state normal
} else {
$widget(Checkbutton93_6) configure -state disable
set BMPalpha "0"
}} \
        -padx 1 -text Alpha -variable alpha 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton200" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPalpha 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_6" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd66 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame45" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.cpd66
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$delta"=="1"} { $widget(Checkbutton93_16) configure -state normal
} else {
$widget(Checkbutton93_16) configure -state disable
set BMPdelta "0"
}} \
        -padx 1 -text Delta -variable delta 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton205" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPdelta 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_16" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra47 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra47" "Frame41" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra47
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$entropy"=="1"} { $widget(Checkbutton93_7) configure -state normal
} else {
$widget(Checkbutton93_7) configure -state disable
set BMPentropy "0"
}} \
        -padx 1 -text {Entropy  (H)} -variable entropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton202" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPentropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_7" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra48 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra48" "Frame42" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra48
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$anisotropy"=="1"} { $widget(Checkbutton93_8) configure -state normal
} else {
$widget(Checkbutton93_8) configure -state disable
set BMPanisotropy "0"
}} \
        -padx 1 \
        -text {Anisotropy  (A)  (p1,p2)    <->    Degree of Polarisation} \
        -variable anisotropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton204" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPanisotropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_8" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra26 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra26" "Frame660" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra26
    checkbutton $site_3_0.che110 \
        \
        -command {global combinationsHA CombHA CombH1mA Comb1mHA Comb1mH1mA

if {$combinationsHA == "1"} {
    $widget(Checkbutton93_9) configure -state normal
    $widget(Checkbutton93_10) configure -state normal
    $widget(Checkbutton93_11) configure -state normal
    $widget(Checkbutton93_12) configure -state normal
    $widget(Checkbutton93_13) configure -state normal
    }
if {$combinationsHA == "0"} {
    set CombHA "0"
    set CombH1mA "0"
    set Comb1mHA "0"
    set Comb1mH1mA "0"
    set BMPcombinationsHA "0"
    $widget(Checkbutton93_9) configure -state disable
    $widget(Checkbutton93_10) configure -state disable
    $widget(Checkbutton93_11) configure -state disable
    $widget(Checkbutton93_12) configure -state disable
    $widget(Checkbutton93_13) configure -state disable
    }} \
        -padx 1 -text {Combinations ( H , A )} -variable combinationsHA 
    vTcl:DefineAlias "$site_3_0.che110" "Checkbutton646" vTcl:WidgetProc "Toplevel93" 1
    frame $site_3_0.fra111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra111" "Frame661" vTcl:WidgetProc "Toplevel93" 1
    set site_4_0 $site_3_0.fra111
    checkbutton $site_4_0.che112 \
        -padx 1 -text {H A} -variable CombHA 
    vTcl:DefineAlias "$site_4_0.che112" "Checkbutton93_9" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_4_0.che113 \
        -text {H (1 - A)} -variable CombH1mA 
    vTcl:DefineAlias "$site_4_0.che113" "Checkbutton93_10" vTcl:WidgetProc "Toplevel93" 1
    pack $site_4_0.che112 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    pack $site_4_0.che113 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    frame $site_3_0.fra117 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra117" "Frame662" vTcl:WidgetProc "Toplevel93" 1
    set site_4_0 $site_3_0.fra117
    checkbutton $site_4_0.che114 \
        -text {(1 - H) A} -variable Comb1mHA 
    vTcl:DefineAlias "$site_4_0.che114" "Checkbutton93_11" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_4_0.che115 \
        -text {(1 - H) (1 - A)} -variable Comb1mH1mA 
    vTcl:DefineAlias "$site_4_0.che115" "Checkbutton93_12" vTcl:WidgetProc "Toplevel93" 1
    pack $site_4_0.che114 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    pack $site_4_0.che115 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    checkbutton $site_3_0.che116 \
        -text BMP -variable BMPcombinationsHA 
    vTcl:DefineAlias "$site_3_0.che116" "Checkbutton93_13" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che110 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.fra111 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra117 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che116 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd74" "Frame44" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.cpd74
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$shannon"=="1"} { $widget(Checkbutton93_15) configure -state normal
} else {
$widget(Checkbutton93_15) configure -state disable
set BMPshannon "0"
}} \
        -padx 1 -text {Shannon Entropy  (H = Hi + Hp)} -variable shannon 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton203" vTcl:WidgetProc "Toplevel93" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPshannon 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton93_15" vTcl:WidgetProc "Toplevel93" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra55 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame47" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra55
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel93" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label34" vTcl:WidgetProc "Toplevel93" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinHAAlpL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel93" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd84 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd84" "Frame49" vTcl:WidgetProc "Toplevel93" 1
    set site_4_0 $site_3_0.cpd84
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label35" vTcl:WidgetProc "Toplevel93" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinHAAlpC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel93" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set eigenvalues "1"
set probabilities "1"
set alpha12 "1"
set delta12 "1"
set alpdel "1"
set lambda "1"
set alpha "1"
set delta "1"
set entropy "1"
set anisotropy "1"
set combinationsHA "1"
set CombHA "1"
set CombH1mA "1"
set Comb1mHA "1"
set Comb1mH1mA "1"
set shannon "1"
set BMPeigenvalues "1"
set BMPprobabilities "1"
set BMPlambda "1"
set BMPalpha12 "1"
set BMPdelta12 "1"
set BMPalpdel "1"
set BMPalpha "1"
set BMPdelta "1"
set BMPentropy "1"
set BMPanisotropy "1"
set BMPcombinationsHA "1"
set BMPshannon "1"
$widget(Checkbutton93_1) configure -state normal
$widget(Checkbutton93_2) configure -state normal
$widget(Checkbutton93_3) configure -state normal
$widget(Checkbutton93_4) configure -state normal
$widget(Checkbutton93_5) configure -state normal
$widget(Checkbutton93_6) configure -state normal
$widget(Checkbutton93_7) configure -state normal
$widget(Checkbutton93_8) configure -state normal
$widget(Checkbutton93_9) configure -state normal
$widget(Checkbutton93_10) configure -state normal
$widget(Checkbutton93_11) configure -state normal
$widget(Checkbutton93_12) configure -state normal
$widget(Checkbutton93_13) configure -state normal
$widget(Checkbutton93_14) configure -state normal
$widget(Checkbutton93_15) configure -state normal
$widget(Checkbutton93_16) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel93" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set eigenvalues "0"
set probabilities "0"
set alpha12 "0"
set delta12 "0"
set alpdel "0"
set lambda "0"
set alpha "0"
set delta "0"
set entropy "0"
set anisotropy "0"
set combinationsHA "0"
set CombHA "0"
set CombH1mA "0"
set Comb1mHA "0"
set Comb1mH1mA "0"
set shannon "0"
set BMPeigenvalues "0"
set BMPprobabilities "0"
set BMPlambda "0"
set BMPalpha12 "0"
set BMPdelta12 "0"
set BMPalpdel "0"
set BMPalpha "0"
set BMPdelta "0"
set BMPentropy "0"
set BMPanisotropy "0"
set BMPcombinationsHA "0"
set BMPshannon "0"
$widget(Checkbutton93_1) configure -state disable
$widget(Checkbutton93_2) configure -state disable
$widget(Checkbutton93_3) configure -state disable
$widget(Checkbutton93_4) configure -state disable
$widget(Checkbutton93_5) configure -state disable
$widget(Checkbutton93_6) configure -state disable
$widget(Checkbutton93_7) configure -state disable
$widget(Checkbutton93_8) configure -state disable
$widget(Checkbutton93_9) configure -state disable
$widget(Checkbutton93_10) configure -state disable
$widget(Checkbutton93_11) configure -state disable
$widget(Checkbutton93_12) configure -state disable
$widget(Checkbutton93_13) configure -state disable
$widget(Checkbutton93_14) configure -state disable
$widget(Checkbutton93_15) configure -state disable
$widget(Checkbutton93_16) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button104" vTcl:WidgetProc "Toplevel93" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 50 -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel93" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global HAAlpDirInput HAAlpDirOutput HAAlpOutputDir HAAlpOutputSubDir
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage
global ProgressLine HAAlphaDecompositionFonction HAAlphaDecompositionFunction
global BMPDirInput OpenDirFile NwinHAAlpL NwinHAAlpC TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "false"
if {"$eigenvalues"=="1"} { set config "true" }
if {"$probabilities"=="1"} { set config "true" }
if {"$alpha12"=="1"} { set config "true" }
if {"$delta12"=="1"} { set config "true" }
if {"$alpdel"=="1"} { set config "true" }
if {"$lambda"=="1"} { set config "true" }
if {"$alpha"=="1"} { set config "true" }
if {"$delta"=="1"} { set config "true" }
if {"$entropy"=="1"} { set config "true" }
if {"$anisotropy"=="1"} { set config "true" }
if {"$combinationsHA"=="1"} { set config "true" }
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
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decompositionSPPC2.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaDecompositionFonction -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $eigenvalues -fl2 $probabilities -fl3 $alpha12 -fl4 $delta12 -fl5 $alpdel -fl6 $alpha -fl7 $delta -fl8 $lambda -fl9 $entropy -fl10 $anisotropy -fl11 $CombHA -fl12 $CombH1mA -fl13 $Comb1mHA -fl14 $Comb1mH1mA -fl15 $shannon  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decompositionSPPC2.exe -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaDecompositionFonction -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $eigenvalues -fl2 $probabilities -fl3 $alpha12 -fl4 $delta12 -fl5 $alpdel -fl6 $alpha -fl7 $delta -fl8 $lambda -fl9 $entropy -fl10 $anisotropy -fl11 $CombHA -fl12 $CombH1mA -fl13 $Comb1mHA -fl14 $Comb1mH1mA -fl15 $shannon  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$eigenvalues"=="1"} {
                if [file exists "$HAAlpDirOutput/l1.bin"] {EnviWriteConfig "$HAAlpDirOutput/l1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/l2.bin"] {EnviWriteConfig "$HAAlpDirOutput/l2.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$probabilities"=="1"} {
                if [file exists "$HAAlpDirOutput/p1.bin"] {EnviWriteConfig "$HAAlpDirOutput/p1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/p2.bin"] {EnviWriteConfig "$HAAlpDirOutput/p2.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$alpha12"=="1"} {
                if [file exists "$HAAlpDirOutput/alpha1.bin"] {EnviWriteConfig "$HAAlpDirOutput/alpha1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/alpha2.bin"] {EnviWriteConfig "$HAAlpDirOutput/alpha2.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$delta12"=="1"} {
                if [file exists "$HAAlpDirOutput/delta1.bin"] {EnviWriteConfig "$HAAlpDirOutput/delta1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/delta2.bin"] {EnviWriteConfig "$HAAlpDirOutput/delta2.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$alpdel"=="1"} {
                if [file exists "$HAAlpDirOutput/lambda.bin"] {EnviWriteConfig "$HAAlpDirOutput/lambda.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/alpha.bin"] {EnviWriteConfig "$HAAlpDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/delta.bin"] {EnviWriteConfig "$HAAlpDirOutput/delta.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$lambda"=="1"} {
                if [file exists "$HAAlpDirOutput/lambda.bin"] {EnviWriteConfig "$HAAlpDirOutput/lambda.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$alpha"=="1"} {
                if [file exists "$HAAlpDirOutput/alpha.bin"] {EnviWriteConfig "$HAAlpDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$delta"=="1"} {
                if [file exists "$HAAlpDirOutput/delta.bin"] {EnviWriteConfig "$HAAlpDirOutput/delta.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$entropy"=="1"} {
                if [file exists "$HAAlpDirOutput/entropy.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$anisotropy"=="1"} {
                if [file exists "$HAAlpDirOutput/anisotropy.bin"] {EnviWriteConfig "$HAAlpDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$combinationsHA"=="1"} {
                if [file exists "$HAAlpDirOutput/combination_HA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_HA.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/combination_H1mA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_H1mA.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/combination_1mHA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_1mHA.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/combination_1mH1mA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_1mH1mA.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$shannon"=="1"} {
                if [file exists "$HAAlpDirOutput/entropy_shannon.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_I.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_I.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_P.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_P.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_norm.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_I_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_I_norm.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/entropy_shannon_P_norm.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy_shannon_P_norm.bin" $FinalNlig $FinalNcol 4}
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
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0.5 1.0
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/p2.bin"
                set BMPFileOutput "$HAAlpDirOutput/p2.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0.0 0.5
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPalpha12"=="1"} {
            if [file exists "$HAAlpDirOutput/alpha1.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/alpha1.bin"
                set BMPFileOutput "$HAAlpDirOutput/alpha1.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/alpha2.bin"
                set BMPFileOutput "$HAAlpDirOutput/alpha2.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPdelta12"=="1"} {
            if [file exists "$HAAlpDirOutput/delta1.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/delta1.bin"
                set BMPFileOutput "$HAAlpDirOutput/delta1.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 180
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/delta2.bin"
                set BMPFileOutput "$HAAlpDirOutput/delta2.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPalpdel"=="1"} {
            if [file exists "$HAAlpDirOutput/alpha.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/alpha.bin"
                set BMPFileOutput "$HAAlpDirOutput/alpha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/delta.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/delta.bin"
                set BMPFileOutput "$HAAlpDirOutput/delta.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/lambda.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/lambda.bin"
                set BMPFileOutput "$HAAlpDirOutput/lambda_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
             
        if {"$BMPlambda"=="1"} {
            if [file exists "$HAAlpDirOutput/lambda.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/lambda.bin"
                set BMPFileOutput "$HAAlpDirOutput/lambda_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPalpha"=="1"} {
            if [file exists "$HAAlpDirOutput/alpha.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/alpha.bin"
                set BMPFileOutput "$HAAlpDirOutput/alpha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPdelta"=="1"} {
            if [file exists "$HAAlpDirOutput/delta.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/delta.bin"
                set BMPFileOutput "$HAAlpDirOutput/delta.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 +180
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
             
        if {"$BMPentropy"=="1"} {
            if [file exists "$HAAlpDirOutput/entropy.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
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

        if {"$BMPcombinationsHA"=="1"} {
            if [file exists "$HAAlpDirOutput/combination_HA.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/combination_HA.bin"
                set BMPFileOutput "$HAAlpDirOutput/combination_HA.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/combination_H1mA.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/combination_H1mA.bin"
                set BMPFileOutput "$HAAlpDirOutput/combination_H1mA.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/combination_1mHA.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/combination_1mHA.bin"
                set BMPFileOutput "$HAAlpDirOutput/combination_1mHA.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/combination_1mH1mA.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/combination_1mH1mA.bin"
                set BMPFileOutput "$HAAlpDirOutput/combination_1mH1mA.bmp"
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

        }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel93); TextEditorRunTrace "Close Window H A Alpha Decomposition 2" "b"}
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel93" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/HAAlphaDecomposition2.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel93" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel93); TextEditorRunTrace "Close Window H A Alpha Decomposition 2" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel93" 1
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
    pack $top.cpd84 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra37 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra40 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra41 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra43 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra45 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra46 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra47 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra48 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra26 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 1 -fill none -side top 
    pack $top.fra59 \
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
Window show .top93

main $argc $argv
