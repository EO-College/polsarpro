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
    set base .top384
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd80 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd69 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.fra38 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra38
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
            vTclWindow.top384
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

proc vTclWindow.top384 {base} {
    if {$base == ""} {
        set base .top384
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
    wm geometry $top 500x390+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create Gray & Color BMP File"
    vTcl:DefineAlias "$top" "Toplevel384" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd67 \
        -ipad 0 -text {Input 8-bits BMP Gray Scale File} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame10" vTcl:WidgetProc "Toplevel384" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd78
    set site_5_0 $site_4_0.cpd78
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPFileInputGray 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh12" vTcl:WidgetProc "Toplevel384" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global DataDir FileName BMPDirInput BMPFileInputGray OpenDirFile
global NColorBMPGray NLigBMPGray NColBMPGray

if {$OpenDirFile == 0} {

set BMPFileInputGray ""
set NColorBMPGray ""; set NLigBMPGray ""; set NColBMPGray ""
$widget(Button384_1) configure -state disable

if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
set types {
    {{BMP Files}        {.bmp}        }
    }
set FileName ""
OpenFile $BMPDirInput $types "INPUT BMP GRAY FILE"

if {$FileName != ""} {
    set BMPFileInputGray $FileName
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd79 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame9" vTcl:WidgetProc "Toplevel384" 1
    set site_5_0 $site_4_0.cpd79
    frame $site_5_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra72" "Frame10" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.fra72
    label $site_6_0.lab73 \
        -text {N Row} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label7" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NLigBMPGray -width 5 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry7" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame11" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd75
    label $site_6_0.lab73 \
        -text {N Col} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label8" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NColBMPGray -width 5 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry8" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame12" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd76
    label $site_6_0.lab73 \
        -text {N Color} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label9" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NColorBMPGray -width 7 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry9" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    TitleFrame $top.cpd80 \
        -ipad 0 -text {Input 8-bits BMP Color Scale File} 
    vTcl:DefineAlias "$top.cpd80" "TitleFrame12" vTcl:WidgetProc "Toplevel384" 1
    bind $top.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd80 getframe]
    frame $site_4_0.cpd78
    set site_5_0 $site_4_0.cpd78
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPFileInputColor 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh14" vTcl:WidgetProc "Toplevel384" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global DataDir FileName BMPDirInput BMPFileInputColor OpenDirFile
global NColorBMPColor NLigBMPColor NColBMPColor

if {$OpenDirFile == 0} {

set BMPFileInputColor ""
set NColorBMPColor ""; set NLigBMPColor ""; set NColBMPColor ""
$widget(Button384_1) configure -state disable

if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
set types {
    {{BMP Files}        {.bmp}        }
    }
set FileName ""
OpenFile $BMPDirInput $types "INPUT BMP COLOR FILE"

if {$FileName != ""} {
    set BMPFileInputColor $FileName
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd79 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame13" vTcl:WidgetProc "Toplevel384" 1
    set site_5_0 $site_4_0.cpd79
    frame $site_5_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra72" "Frame14" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.fra72
    label $site_6_0.lab73 \
        -text {N Row} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label10" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NLigBMPColor -width 5 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry10" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame15" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd75
    label $site_6_0.lab73 \
        -text {N Col} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label11" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NColBMPColor -width 5 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry11" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame16" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd76
    label $site_6_0.lab73 \
        -text {N Color} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label12" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NColorBMPColor -width 7 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry12" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    TitleFrame $top.cpd81 \
        -ipad 0 -text {Input Mask File} 
    vTcl:DefineAlias "$top.cpd81" "TitleFrame14" vTcl:WidgetProc "Toplevel384" 1
    bind $top.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd81 getframe]
    frame $site_4_0.cpd78
    set site_5_0 $site_4_0.cpd78
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPFileInputMask 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh15" vTcl:WidgetProc "Toplevel384" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global DataDir FileName BMPDirInput BMPFileInputMask OpenDirFile
global NLigBMPMask NColBMPMask BMPInvertMask

if {$OpenDirFile == 0} {

set BMPFileInputMask ""
set NLigBMPMask ""; set NColBMPMask ""; set BMPInvertMask 0
$widget(Button384_1) configure -state disable

if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
set types {
    {{BIN Files}        {.bin}        }
    }
set FileName ""
OpenFile $BMPDirInput $types "INPUT MASK FILE"

if {$FileName != ""} {
    set BMPFileInputMask $FileName
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd79 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame17" vTcl:WidgetProc "Toplevel384" 1
    set site_5_0 $site_4_0.cpd79
    frame $site_5_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra72" "Frame18" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.fra72
    label $site_6_0.lab73 \
        -text {N Row} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label13" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NLigBMPMask -width 5 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry13" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame19" vTcl:WidgetProc "Toplevel384" 1
    set site_6_0 $site_5_0.cpd75
    label $site_6_0.lab73 \
        -text {N Col} 
    vTcl:DefineAlias "$site_6_0.lab73" "Label14" vTcl:WidgetProc "Toplevel384" 1
    entry $site_6_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NColBMPMask -width 5 
    vTcl:DefineAlias "$site_6_0.ent74" "Entry14" vTcl:WidgetProc "Toplevel384" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    checkbutton $site_5_0.cpd67 \
        -text {Invert Mask} -variable BMPInvertMask 
    vTcl:DefineAlias "$site_5_0.cpd67" "Checkbutton1" vTcl:WidgetProc "Toplevel384" 1
    pack $site_5_0.fra72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    button $top.cpd82 \
        -background #ffff00 \
        -command {global ColorNumber NColorBMPGray NColorBMPColor
global NligEnd NcolEnd NLigBMPGray NLigBMPColor NLigBMPMask NColBMPGray NColBMPColor NColBMPMask
global TMPBmpTmpHeaderGray TMPBmpTmpDataGray TMPBmp24TmpDataGray TMPBmpTmpColormapGray TMPBmpColorBarGray TMPColorMapBMPGray
global TMPBmpTmpHeaderColor TMPBmpTmpDataColor TMPBmp24TmpDataColor TMPBmpTmpColormapColor TMPBmpColorBarColor TMPColorMapBMPColor
global BMPFileInputGray BMPFileInputColor BMPFileInputMask
global VarError ErrorMessage OpenDirFile

if {$OpenDirFile == 0} {

set NLigBMPGray ""; set NLigBMPColor ""; set NLigBMPMask ""; set NColBMPGray ""; set NColBMPColor ""; set NColBMPMask ""
set NColorBMPGray ""; set NColorBMPColor ""

#BMP GRAY IMAGE
DeleteFile $TMPColorMapBMPGray
DeleteFile $TMPBmpColorBarGray

TextEditorRunTrace "Process The Function Soft/bmp_process/extract_bmp_colormap.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$BMPFileInputGray\x22 -ofh \x22$TMPBmpTmpHeaderGray\x22 -ofd \x22$TMPBmpTmpDataGray\x22 -ofd24 \x22$TMPBmp24TmpDataGray\x22 -ofcm \x22$TMPBmpTmpColormapGray\x22 -ofcb \x22$TMPBmpColorBarGray\x22 -ocf \x22$TMPColorMapBMPGray\x22" "k"
set f [ open "| Soft/bmp_process/extract_bmp_colormap.exe -if \x22$BMPFileInputGray\x22 -ofh \x22$TMPBmpTmpHeaderGray\x22 -ofd \x22$TMPBmpTmpDataGray\x22 -ofd24 \x22$TMPBmp24TmpDataGray\x22 -ofcm \x22$TMPBmpTmpColormapGray\x22 -ofcb \x22$TMPBmpColorBarGray\x22 -ocf \x22$TMPColorMapBMPGray\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError

WaitUntilCreated $TMPBmpTmpHeaderGray
if [file exists $TMPBmpTmpHeaderGray] {
    set f [open $TMPBmpTmpHeaderGray r]
    gets $f NColBMPGray
    gets $f NLigBMPGray
    gets $f tmp
    gets $f tmp
    gets $f ColorNumber
    close $f

    if {$ColorNumber == "BMP 24 Bits"} {
        set NColorBMPGray "24Bits"
        } else {
        set NColorBMPGray $ColorNumber
        }
    }

#BMP COLOR IMAGE
DeleteFile $TMPColorMapBMPColor
DeleteFile $TMPBmpColorBarColor

TextEditorRunTrace "Process The Function Soft/bmp_process/extract_bmp_colormap.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$BMPFileInputColor\x22 -ofh \x22$TMPBmpTmpHeaderColor\x22 -ofd \x22$TMPBmpTmpDataColor\x22 -ofd24 \x22$TMPBmp24TmpDataColor\x22 -ofcm \x22$TMPBmpTmpColormapColor\x22 -ofcb \x22$TMPBmpColorBarColor\x22 -ocf \x22$TMPColorMapBMPColor\x22" "k"
set f [ open "| Soft/bmp_process/extract_bmp_colormap.exe -if \x22$BMPFileInputColor\x22 -ofh \x22$TMPBmpTmpHeaderColor\x22 -ofd \x22$TMPBmpTmpDataColor\x22 -ofd24 \x22$TMPBmp24TmpDataColor\x22 -ofcm \x22$TMPBmpTmpColormapColor\x22 -ofcb \x22$TMPBmpColorBarColor\x22 -ocf \x22$TMPColorMapBMPColor\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError

WaitUntilCreated $TMPBmpTmpHeaderColor
if [file exists $TMPBmpTmpHeaderColor] {
    set f [open $TMPBmpTmpHeaderColor r]
    gets $f NColBMPColor
    gets $f NLigBMPColor
    gets $f tmp
    gets $f tmp
    gets $f ColorNumber
    close $f

    if {$ColorNumber == "BMP 24 Bits"} {
        set NColorBMPColor "24Bits"
        } else {
        set NColorBMPColor $ColorNumber
        }
    }

set NLigBMPMask $NligEnd
set NColBMPMask $NcolEnd

set config "true"

if {$NColorBMPGray == "24Bits"} {
    set VarError ""
    set ErrorMessage "THE FILE $BMPFileInputGray IS NOT A 8-Bits BMP FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$NColorBMPColor == "24Bits"} {
    set VarError ""
    set ErrorMessage "THE FILE $BMPFileInputColor IS NOT A 8-Bits BMP FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$NLigBMPGray != $NLigBMPColor} {
    set VarError ""
    set ErrorMessage "THE 2 BMP FILES HAVE NOT THE SAME NUMBER OF ROWS"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$NColBMPGray != $NColBMPColor} {
    set VarError ""
    set ErrorMessage "THE 2 BMP FILES HAVE NOT THE SAME NUMBER OF COLUMNS"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$NLigBMPGray != $NLigBMPMask} {
    set VarError ""
    set ErrorMessage "THE BMP AND THE MASK FILES HAVE NOT THE SAME NUMBER OF ROWS"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$NColBMPGray != $NColBMPMask} {
    set VarError ""
    set ErrorMessage "THE BMP AND THE MASK FILES HAVE NOT THE SAME NUMBER OF COLUMNS"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }

if {$config == "false"} {
    $widget(Button384_1) configure -state disable
    set BMPFileInputGray ""; set BMPFileInputColor ""; set BMPFileInputMask ""
    set NLigBMPGray ""; set NLigBMPColor ""; set NLigBMPMask ""; set NColBMPGray ""; set NColBMPColor ""; set NColBMPMask ""
    set NColorBMPGray ""; set NColorBMPColor ""
    } else {
    set BMPDirOutput [file dirname $BMPFileInputColor]
    set BMPFileOutput [file rootname $BMPFileInputColor]
    append BMPFileOutput "_"
    set BMPFileTmp [file tail $BMPFileInputGray]
    append BMPFileOutput "$BMPFileTmp"
    $widget(Button384_1) configure -state normal
    }

}} \
        -padx 4 -pady 2 -text {Check Files} 
    vTcl:DefineAlias "$top.cpd82" "Button14" vTcl:WidgetProc "Toplevel384" 1
    bindtags $top.cpd82 "$top.cpd82 Button $top all _vTclBalloon"
    bind $top.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    TitleFrame $top.cpd68 \
        -ipad 0 -text {Output BMP Directory} 
    vTcl:DefineAlias "$top.cpd68" "TitleFrame11" vTcl:WidgetProc "Toplevel384" 1
    bind $top.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd68 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh11" vTcl:WidgetProc "Toplevel384" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame24" vTcl:WidgetProc "Toplevel384" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd79 \
        \
        -command {global DirName DataDir BMPDirOutput BMPFileOutput

set BMPDirOutputTmp $BMPDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set BMPDirOutput $DirName
    } else {
    set BMPDirOutput $BMPDirOutputTmp
    }
set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileOutput]
set BMPFileOutput $FileTmp} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_5_0.cpd79 "$site_5_0.cpd79 Button $top all _vTclBalloon"
    bind $site_5_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd69 \
        -ipad 0 -text {Output BMP File} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame13" vTcl:WidgetProc "Toplevel384" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPFileOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh13" vTcl:WidgetProc "Toplevel384" 1
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel384" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ColorNumber NColorBMPGray NColorBMPColor
global NligEnd NcolEnd NLigBMPGray NLigBMPColor NLigBMPMask NColBMPGray NColBMPColor NColBMPMask
global TMPBmpTmpHeaderGray TMPBmpTmpDataGray TMPBmp24TmpDataGray TMPBmpTmpColormapGray TMPBmpColorBarGray TMPColorMapBMPGray
global TMPBmpTmpHeaderColor TMPBmpTmpDataColor TMPBmp24TmpDataColor TMPBmpTmpColormapColor TMPBmpColorBarColor TMPColorMapBMPColor
global BMPFileInputGray BMPFileInputColor BMPFileInputMask BMPInvertMask TMPBmpTmpColormapGrayColor
global VarError ErrorMessage OpenDirFile

if {$OpenDirFile == 0} {

DeleteFile $TMPBmpTmpColormapGrayColor

TextEditorRunTrace "Process The Function Soft/bmp_process/create_gray_color_bmp_file.exe" "k"
TextEditorRunTrace "Arguments: -of \x22$BMPFileOutput\x22 -msk \x22$BMPFileInputMask\x22 -imsk $BMPInvertMask -nl $NLigBMPMask -nc $NColBMPMask -ifhg \x22$TMPBmpTmpHeaderGray\x22 -ifhc \x22$TMPBmpTmpHeaderColor\x22 -ifdg \x22$TMPBmpTmpDataGray\x22 -ifdc \x22$TMPBmpTmpDataColor\x22 -ifcg \x22$TMPBmpTmpColormapGray\x22 -ifcc \x22$TMPBmpTmpColormapColor\x22 -ofcg \x22$TMPBmpTmpColormapGrayColor\x22" "k"
set f [ open "| Soft/bmp_process/create_gray_color_bmp_file.exe -of \x22$BMPFileOutput\x22 -msk \x22$BMPFileInputMask\x22 -imsk $BMPInvertMask -nl $NLigBMPMask -nc $NColBMPMask -ifhg \x22$TMPBmpTmpHeaderGray\x22 -ifhc \x22$TMPBmpTmpHeaderColor\x22 -ifdg \x22$TMPBmpTmpDataGray\x22 -ifdc \x22$TMPBmpTmpDataColor\x22 -ifcg \x22$TMPBmpTmpColormapGray\x22 -ifcc \x22$TMPBmpTmpColormapColor\x22 -ofcg \x22$TMPBmpTmpColormapGrayColor\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError

}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button384_1" vTcl:WidgetProc "Toplevel384" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ColorGrayColorBMPFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel384" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel384); TextEditorRunTrace "Close Window Create Gray & Color BMP File" "b"
if {$DisplayMainMenu == 1} {
    set DisplayMainMenu 0
    WidgetShow $widget(Toplevel2)
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel384" 1
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
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra38 \
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
Window show .top384

main $argc $argv
