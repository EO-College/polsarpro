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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}

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
    set base .top361
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit69 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit69 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
    namespace eval ::widgets::$site_3_0.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd73 getframe]
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
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd66 getframe]
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
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
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
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
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
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit67 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.tit68 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd79 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.tit68 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
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
            vTclWindow.top361
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

proc vTclWindow.top361 {base} {
    if {$base == ""} {
        set base .top361
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
    wm geometry $top 500x480+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Extract DEM File"
    vTcl:DefineAlias "$top" "Toplevel361" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit69 \
        -ipad 0 -text {Input DEM Files} 
    vTcl:DefineAlias "$top.tit69" "TitleFrame17" vTcl:WidgetProc "Toplevel361" 1
    bind $top.tit69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit69 getframe]
    radiobutton $site_4_0.rad70 \
        \
        -command {global DEMInputFile1 DEMInputFile2 DEMInputFile3 DEMInputFile4

set DEMInputFile1 ""; set DEMInputFile2 ""; set DEMInputFile3 ""; set DEMInputFile4 ""

$widget(TitleFrame361_1) configure -state normal
$widget(TitleFrame361_1) configure -text "Input DEM File"
$widget(Entry361_1) configure -disabledbackground #FFFFFF
$widget(Entry361_1) configure -state disable
$widget(Button361_1) configure -state normal

$widget(TitleFrame361_2) configure -state disable
$widget(TitleFrame361_2) configure -text ""
$widget(Entry361_2) configure -disabledbackground $PSPBackgroundColor
$widget(Entry361_2) configure -state disable
$widget(Button361_2) configure -state disable

$widget(TitleFrame361_3) configure -state disable
$widget(TitleFrame361_3) configure -text ""
$widget(Entry361_3) configure -disabledbackground $PSPBackgroundColor
$widget(Entry361_3) configure -state disable
$widget(Button361_3) configure -state disable

$widget(TitleFrame361_4) configure -state disable
$widget(TitleFrame361_4) configure -text ""
$widget(Entry361_4) configure -disabledbackground $PSPBackgroundColor
$widget(Entry361_4) configure -state disable
$widget(Button361_4) configure -state disable} \
        -text {1 File} -value 1 -variable DEMNfile 
    vTcl:DefineAlias "$site_4_0.rad70" "Radiobutton1" vTcl:WidgetProc "Toplevel361" 1
    radiobutton $site_4_0.cpd71 \
        \
        -command {global DEMInputFile1 DEMInputFile2 DEMInputFile3 DEMInputFile4

set DEMInputFile1 ""; set DEMInputFile2 ""; set DEMInputFile3 ""; set DEMInputFile4 ""

$widget(TitleFrame361_1) configure -state normal
$widget(TitleFrame361_1) configure -text "Input DEM Top File"
$widget(Entry361_1) configure -disabledbackground #FFFFFF
$widget(Entry361_1) configure -state disable
$widget(Button361_1) configure -state normal

$widget(TitleFrame361_2) configure -state normal
$widget(TitleFrame361_2) configure -text "Input DEM Bottom File"
$widget(Entry361_2) configure -disabledbackground #FFFFFF
$widget(Entry361_2) configure -state disable
$widget(Button361_2) configure -state normal

$widget(TitleFrame361_3) configure -state disable
$widget(TitleFrame361_3) configure -text ""
$widget(Entry361_3) configure -disabledbackground $PSPBackgroundColor
$widget(Entry361_3) configure -state disable
$widget(Button361_3) configure -state disable

$widget(TitleFrame361_4) configure -state disable
$widget(TitleFrame361_4) configure -text ""
$widget(Entry361_4) configure -disabledbackground $PSPBackgroundColor
$widget(Entry361_4) configure -state disable
$widget(Button361_4) configure -state disable} \
        -text {2 Files (Top / Bottom )} -value 2TB -variable DEMNfile 
    vTcl:DefineAlias "$site_4_0.cpd71" "Radiobutton2" vTcl:WidgetProc "Toplevel361" 1
    radiobutton $site_4_0.cpd66 \
        \
        -command {global DEMInputFile1 DEMInputFile2 DEMInputFile3 DEMInputFile4

set DEMInputFile1 ""; set DEMInputFile2 ""; set DEMInputFile3 ""; set DEMInputFile4 ""

$widget(TitleFrame361_1) configure -state normal
$widget(TitleFrame361_1) configure -text "Input DEM Left File"
$widget(Entry361_1) configure -disabledbackground #FFFFFF
$widget(Entry361_1) configure -state disable
$widget(Button361_1) configure -state normal

$widget(TitleFrame361_2) configure -state normal
$widget(TitleFrame361_2) configure -text "Input DEM Right File"
$widget(Entry361_2) configure -disabledbackground #FFFFFF
$widget(Entry361_2) configure -state disable
$widget(Button361_2) configure -state normal

$widget(TitleFrame361_3) configure -state disable
$widget(TitleFrame361_3) configure -text ""
$widget(Entry361_3) configure -disabledbackground $PSPBackgroundColor
$widget(Entry361_3) configure -state disable
$widget(Button361_3) configure -state disable

$widget(TitleFrame361_4) configure -state disable
$widget(TitleFrame361_4) configure -text ""
$widget(Entry361_4) configure -disabledbackground $PSPBackgroundColor
$widget(Entry361_4) configure -state disable
$widget(Button361_4) configure -state disable} \
        -text {2 Files ( Left / Right )} -value 2LR -variable DEMNfile 
    vTcl:DefineAlias "$site_4_0.cpd66" "Radiobutton4" vTcl:WidgetProc "Toplevel361" 1
    radiobutton $site_4_0.cpd72 \
        \
        -command {global DEMInputFile1 DEMInputFile2 DEMInputFile3 DEMInputFile4

set DEMInputFile1 ""; set DEMInputFile2 ""; set DEMInputFile3 ""; set DEMInputFile4 ""

$widget(TitleFrame361_1) configure -state normal
$widget(TitleFrame361_1) configure -text "Input DEM Top Left File"
$widget(Entry361_1) configure -disabledbackground #FFFFFF
$widget(Entry361_1) configure -state disable
$widget(Button361_1) configure -state normal

$widget(TitleFrame361_2) configure -state normal
$widget(TitleFrame361_2) configure -text "Input DEM Top Right File"
$widget(Entry361_2) configure -disabledbackground #FFFFFF
$widget(Entry361_2) configure -state disable
$widget(Button361_2) configure -state normal

$widget(TitleFrame361_3) configure -state normal
$widget(TitleFrame361_3) configure -text "Input DEM Bottom Left File"
$widget(Entry361_3) configure -disabledbackground #FFFFFF
$widget(Entry361_3) configure -state disable
$widget(Button361_3) configure -state normal

$widget(TitleFrame361_4) configure -state normal
$widget(TitleFrame361_4) configure -text "Input DEM Bottom Right File"
$widget(Entry361_4) configure -disabledbackground #FFFFFF
$widget(Entry361_4) configure -state disable
$widget(Button361_4) configure -state normal} \
        -text {4 Files} -value 4 -variable DEMNfile 
    vTcl:DefineAlias "$site_4_0.cpd72" "Radiobutton3" vTcl:WidgetProc "Toplevel361" 1
    pack $site_4_0.rad70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame2" vTcl:WidgetProc "Toplevel361" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd73 \
        -ipad 0 -text {Input  DEM File 1} 
    vTcl:DefineAlias "$site_3_0.cpd73" "TitleFrame361_1" vTcl:WidgetProc "Toplevel361" 1
    bind $site_3_0.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd73 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DEMInputFile1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry361_1" vTcl:WidgetProc "Toplevel361" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel361" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DataDir FileName DEMInputFile1 DEMoutputDir OpenDirFile
global VarError ErrorMessage

if {$OpenDirFile == 0} {

set DEMInputFile1 ""

set types {
    {{TIF Files}        {.tif}        }
    }
set FileName ""
OpenFile $DataDir $types "INPUT DEM TIF FILE"

if {$FileName != ""} {
    set DEMInputFile1 $FileName
    set DEMoutputDir [file dirname $FileName]
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button361_1" vTcl:WidgetProc "Toplevel361" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd66 \
        -ipad 0 -text {Input  DEM File 2} 
    vTcl:DefineAlias "$site_3_0.cpd66" "TitleFrame361_2" vTcl:WidgetProc "Toplevel361" 1
    bind $site_3_0.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd66 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DEMInputFile2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry361_2" vTcl:WidgetProc "Toplevel361" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel361" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DataDir FileName DEMInputFile2 OpenDirFile
global VarError ErrorMessage

if {$OpenDirFile == 0} {

set DEMInputFile2 ""

set types {
    {{TIF Files}        {.tif}        }
    }
set FileName ""
OpenFile $DataDir $types "INPUT DEM TIF FILE"

if {$FileName != ""} {
    set DEMInputFile2 $FileName
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button361_2" vTcl:WidgetProc "Toplevel361" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd67 \
        -ipad 0 -text {Input  DEM File 3} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame361_3" vTcl:WidgetProc "Toplevel361" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DEMInputFile3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry361_3" vTcl:WidgetProc "Toplevel361" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel361" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DataDir FileName DEMInputFile3 OpenDirFile
global VarError ErrorMessage

if {$OpenDirFile == 0} {

set DEMInputFile3 ""

set types {
    {{TIF Files}        {.tif}        }
    }
set FileName ""
OpenFile $DataDir $types "INPUT DEM TIF FILE"

if {$FileName != ""} {
    set DEMInputFile3 $FileName
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button361_3" vTcl:WidgetProc "Toplevel361" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd68 \
        -ipad 0 -text {Input  DEM File 4} 
    vTcl:DefineAlias "$site_3_0.cpd68" "TitleFrame361_4" vTcl:WidgetProc "Toplevel361" 1
    bind $site_3_0.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DEMInputFile4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry361_4" vTcl:WidgetProc "Toplevel361" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel361" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DataDir FileName DEMInputFile4 OpenDirFile
global VarError ErrorMessage

if {$OpenDirFile == 0} {

set DEMInputFile4 ""

set types {
    {{TIF Files}        {.tif}        }
    }
set FileName ""
OpenFile $DataDir $types "INPUT DEM TIF FILE"

if {$FileName != ""} {
    set DEMInputFile4 $FileName
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button361_4" vTcl:WidgetProc "Toplevel361" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd73 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame362" vTcl:WidgetProc "Toplevel361" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DEMoutputDir 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry361" vTcl:WidgetProc "Toplevel361" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel361" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd72 \
        \
        -command {global DirName DataDir DEMoutputDir

if {$OpenDirFile == 0} {
set DEMoutputDir ""
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set DEMoutputDir $DirName
    } else {
    set DEMoutputDir ""
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button361" vTcl:WidgetProc "Toplevel361" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $top.cpd80 \
        -background #ffff00 \
        -command {global OpenDirFile DEMInputFile1 DEMInputFile2 DEMInputFile3 DEMInputFile4 DEMNfile DEMNlig DEMNcol
global DEMLatCenter DEMLongCenter DEMLat00 DEMLong00 DEMLat0N DEMLong0N
global DEMLatN0 DEMLongN0 DEMLatNN DEMLongNN DEMWest DEMEast DEMNorth DEMSouth
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN PSPViewGimpBMP

if {$OpenDirFile == 0} {

set config "true"
if {$DEMNfile == 1} {
    if [file exists $DEMInputFile1] { } else { set config "false" }
}
if {$DEMNfile == 2} {
    if [file exists $DEMInputFile1] { } else { set config "false" }
    if [file exists $DEMInputFile2] { } else { set config "false" }
}
if {$DEMNfile == 4} {
    if [file exists $DEMInputFile1] { } else { set config "false" }
    if [file exists $DEMInputFile2] { } else { set config "false" }
    if [file exists $DEMInputFile3] { } else { set config "false" }
    if [file exists $DEMInputFile4] { } else { set config "false" }
}

if {$config == "true"} {
    set Fonction  "Creation of the DEM File :"
    set Fonction2 "$DEMoutputDir/DEM.bin"
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    if {$DEMNfile == 1} {
        TextEditorRunTrace "Process The Function Soft/bin/data_import/extract_dem_1.exe" "k"
        TextEditorRunTrace "Arguments: -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if \x22$DEMInputFile1\x22" "k"
        set f [ open "| Soft/bin/data_import/extract_dem_1.exe -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if \x22$DEMInputFile1\x22" r]
        }
    if {$DEMNfile == "2TB"} {
        TextEditorRunTrace "Process The Function Soft/bin/data_import/extract_dem_2.exe" "k"
        TextEditorRunTrace "Arguments: -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if1 \x22$DEMInputFile1\x22 -if2 \x22$DEMInputFile2\x22 -cfg 0" "k"
        set f [ open "| Soft/bin/data_import/extract_dem_2.exe -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if1 \x22$DEMInputFile1\x22 -if2 \x22$DEMInputFile2\x22 -cfg 0" r]
        }
    if {$DEMNfile == "2LR"} {
        TextEditorRunTrace "Process The Function Soft/bin/data_import/extract_dem_2.exe" "k"
        TextEditorRunTrace "Arguments: -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if1 \x22$DEMInputFile1\x22 -if2 \x22$DEMInputFile2\x22 -cfg 1" "k"
        set f [ open "| Soft/bin/data_import/extract_dem_2.exe -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if1 \x22$DEMInputFile1\x22 -if2 \x22$DEMInputFile2\x22 -cfg 1" r]
        }
    if {$DEMNfile == 4} {
        TextEditorRunTrace "Process The Function Soft/bin/data_import/extract_dem_4.exe" "k"
        TextEditorRunTrace "Arguments: -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if1 \x22$DEMInputFile1\x22 -if2 \x22$DEMInputFile2\x22 -if3 \x22$DEMInputFile3\x22 -if4 \x22$DEMInputFile4\x22" "k"
        set f [ open "| Soft/bin/data_import/extract_dem_4.exe -la00 $GoogleLat00 -lo00 $GoogleLong00 -la0N $GoogleLat0N -lo0N $GoogleLong0N -laN0 $GoogleLatN0 -loN0 $GoogleLongN0 -laNN $GoogleLatNN -loNN $GoogleLongNN -od \x22$DEMoutputDir\x22 -if1 \x22$DEMInputFile1\x22 -if2 \x22$DEMInputFile2\x22 -if3 \x22$DEMInputFile3\x22 -if4 \x22$DEMInputFile4\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    WaitUntilCreated "$DEMoutputDir/DEM.txt"
    if [file exists "$DEMoutputDir/DEM.txt"] {
        set f [open "$DEMoutputDir/DEM.txt" r]
        gets $f tmp; gets $f DEMNlig
        gets $f tmp; gets $f DEMNcol
        gets $f tmp; gets $f DEMLatCenter
        gets $f tmp; gets $f DEMLongCenter
        gets $f tmp; gets $f DEMLat00
        gets $f tmp; gets $f DEMLong00
        gets $f tmp; gets $f DEMLat0N
        gets $f tmp; gets $f DEMLong0N
        gets $f tmp; gets $f DEMLatN0
        gets $f tmp; gets $f DEMLongN0
        gets $f tmp; gets $f DEMLatNN
        gets $f tmp; gets $f DEMLongNN
        gets $f tmp; gets $f DEMWest
        gets $f tmp; gets $f DEMEast
        gets $f tmp; gets $f DEMNorth
        gets $f tmp; gets $f DEMSouth
        close $f
        }

    WaitUntilCreated "$DEMoutputDir/DEM.bin"
    if [file exists "$DEMoutputDir/DEM.bin"] {
        set MaskCmd ""
        set MaskDir $BMPDirInput
        set MaskFile "$MaskDir/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
        set BMPDirInput $DEMoutputDir
        set BMPFileInput "$DEMoutputDir/DEM.bin"
        set BMPFileOutput "$DEMoutputDir/DEM.bmp"
        set Fonction  "Creation of the BMP File :"
        set Fonction2 $BMPFileOutput
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $DEMNcol -ofr 0 -ofc 0 -fnr $DEMNlig -fnc $DEMNcol -mm 3 -min 0 -max 0 $MaskCmd" "k"
        set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $DEMNcol -ofr 0 -ofc 0 -fnr $DEMNlig -fnc $DEMNcol -mm 3 -min 0 -max 0 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
        }

    if [file exists "$DEMoutputDir/DEM.bin"] { Dem_Kml $DEMoutputDir }
    }
}} \
        -padx 4 -pady 2 -text Extract 
    vTcl:DefineAlias "$top.cpd80" "Button361_0" vTcl:WidgetProc "Toplevel361" 1
    bindtags $top.cpd80 "$top.cpd80 Button $top all _vTclBalloon"
    bind $top.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Read GEARTH_POLY File}
    }
    TitleFrame $top.tit67 \
        -text {Latitude ( deg )} 
    vTcl:DefineAlias "$top.tit67" "TitleFrame1" vTcl:WidgetProc "Toplevel361" 1
    bind $top.tit67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit67 getframe]
    TitleFrame $site_4_0.tit68 \
        -text Center 
    vTcl:DefineAlias "$site_4_0.tit68" "TitleFrame2" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.tit68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLatCenter -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry1" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd74 \
        -text Top-Left 
    vTcl:DefineAlias "$site_4_0.cpd74" "TitleFrame3" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLat00 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry2" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd75 \
        -text Top-Right 
    vTcl:DefineAlias "$site_4_0.cpd75" "TitleFrame4" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLat0N -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry3" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd76 \
        -text Bottom-Left 
    vTcl:DefineAlias "$site_4_0.cpd76" "TitleFrame7" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLatN0 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry4" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd77 \
        -text Bottom-Right 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame8" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLatNN -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry5" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.tit68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd79 \
        -text {Longitude ( deg )} 
    vTcl:DefineAlias "$top.cpd79" "TitleFrame9" vTcl:WidgetProc "Toplevel361" 1
    bind $top.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd79 getframe]
    TitleFrame $site_4_0.tit68 \
        -text Center 
    vTcl:DefineAlias "$site_4_0.tit68" "TitleFrame10" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.tit68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLongCenter -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry10" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd74 \
        -text Top-Left 
    vTcl:DefineAlias "$site_4_0.cpd74" "TitleFrame11" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLong00 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry11" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd75 \
        -text Top-Right 
    vTcl:DefineAlias "$site_4_0.cpd75" "TitleFrame12" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLong0N -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry12" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd76 \
        -text Bottom-Left 
    vTcl:DefineAlias "$site_4_0.cpd76" "TitleFrame13" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLongN0 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry13" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd77 \
        -text Bottom-Right 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame14" vTcl:WidgetProc "Toplevel361" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DEMLongNN -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry14" vTcl:WidgetProc "Toplevel361" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.tit68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra36 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame20" vTcl:WidgetProc "Toplevel361" 1
    set site_3_0 $top.fra36
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel361); TextEditorRunTrace "Close Window Extract DEM File" "b"
}} \
        -cursor {} -padx 4 -pady 2 -text {Save & Exit} 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel361" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ExtractDEM.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel361" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global DEMLatCenter DEMLongCenter DEMLat00 DEMLong00 DEMLat0N DEMLong0N
global DEMLatN0 DEMLongN0 DEMLatNN DEMLongNN DEMWest DEMEast DEMNorth DEMSouth

if {$OpenDirFile == 0} {
set DEMLatCenter "?"
set DEMLongCenter "?"
set DEMLat00 "?"
set DEMLong00 "?"
set DEMLat0N "?"
set DEMLong0N "?"
set DEMLatN0 "?"
set DEMLongN0 "?"
set DEMLatNN "?"
set DEMLongNN "?"
set DEMWest "?"
set DEMEast "?"
set DEMNorth "?"
set DEMSouth "?"
Window hide $widget(Toplevel361); TextEditorRunTrace "Close Window Extract DEM File" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel361" 1
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
    pack $top.tit69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.tit67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd79 \
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
Window show .top361

main $argc $argv
