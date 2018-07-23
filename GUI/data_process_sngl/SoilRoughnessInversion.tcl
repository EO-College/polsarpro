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

        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}

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
    set base .top447
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit76 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
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
    namespace eval ::widgets::$base.cpd74 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.tit72 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.tit72 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd67
    namespace eval ::widgets::$site_4_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad71 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent66 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.che69 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd76 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.che69 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.che69 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top447
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

proc vTclWindow.top447 {base} {
    if {$base == ""} {
        set base .top447
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
    wm geometry $top 500x470+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Process : SoilRoughness Parameter Data Inversion"
    vTcl:DefineAlias "$top" "Toplevel447" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel447" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SoilRoughnessDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry447_149" vTcl:WidgetProc "Toplevel447" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel447" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel447" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -text {Output Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel447" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable SoilRoughnessOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry447_73" vTcl:WidgetProc "Toplevel447" 1
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel447" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel447" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SoilRoughnessOutputSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel447" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel447" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName DataDir SoilRoughnessOutputDir
global VarWarning WarningMessage WarningMessage2

set SoilRoughnessDirOutputTmp $SoilRoughnessOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set SoilRoughnessOutputDir $DirName
        } else {
        set SoilRoughnessOutputDir $SoilRoughnessDirOutputTmp
        }
    } else {
    set SoilRoughnessOutputDir $SoilRoughnessDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button447_92" vTcl:WidgetProc "Toplevel447" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel447" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label447_01" vTcl:WidgetProc "Toplevel447" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry447_01" vTcl:WidgetProc "Toplevel447" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label447_02" vTcl:WidgetProc "Toplevel447" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry447_02" vTcl:WidgetProc "Toplevel447" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label447_03" vTcl:WidgetProc "Toplevel447" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry447_03" vTcl:WidgetProc "Toplevel447" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label447_04" vTcl:WidgetProc "Toplevel447" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry447_04" vTcl:WidgetProc "Toplevel447" 1
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
    TitleFrame $top.cpd74 \
        -text {Local Incidence Angle File} 
    vTcl:DefineAlias "$top.cpd74" "TitleFrame3" vTcl:WidgetProc "Toplevel447" 1
    bind $top.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd74 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -textvariable LIAFile 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry447" vTcl:WidgetProc "Toplevel447" 1
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame3" vTcl:WidgetProc "Toplevel447" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global FileName SoilRoughnessDirInput LIAFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D LOCAL INCIDENCE ANGLE FILE MUST HAVE THE"
set WarningMessage2 "SAME DATA SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{BIN Files}        {.bin}        }
{{DAT Files}        {.dat}        }
}
set FileName ""
OpenFile "$SoilRoughnessDirInput" $types "LOCAL INCIDENCE ANGLE FILE"
if {$FileName != ""} {
    set LIAFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button447" vTcl:WidgetProc "Toplevel447" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame4" vTcl:WidgetProc "Toplevel447" 1
    set site_3_0 $top.fra71
    TitleFrame $site_3_0.tit72 \
        -text {Local Incidence Angle Unit} 
    vTcl:DefineAlias "$site_3_0.tit72" "TitleFrame4" vTcl:WidgetProc "Toplevel447" 1
    bind $site_3_0.tit72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit72 getframe]
    radiobutton $site_5_0.cpd74 \
        -text Degree -value 0 -variable LIAangle 
    vTcl:DefineAlias "$site_5_0.cpd74" "Radiobutton1" vTcl:WidgetProc "Toplevel447" 1
    radiobutton $site_5_0.cpd75 \
        -text Radian -value 1 -variable LIAangle 
    vTcl:DefineAlias "$site_5_0.cpd75" "Radiobutton2" vTcl:WidgetProc "Toplevel447" 1
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_3_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd67" "Frame10" vTcl:WidgetProc "Toplevel447" 1
    set site_4_0 $site_3_0.cpd67
    label $site_4_0.lab74 \
        -text {Window Size : Row} 
    vTcl:DefineAlias "$site_4_0.lab74" "Label254" vTcl:WidgetProc "Toplevel447" 1
    entry $site_4_0.ent75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SoilRoughnessNwinL -width 5 
    vTcl:DefineAlias "$site_4_0.ent75" "Entry255" vTcl:WidgetProc "Toplevel447" 1
    label $site_4_0.cpd71 \
        -text {Window Size : Col} 
    vTcl:DefineAlias "$site_4_0.cpd71" "Label255" vTcl:WidgetProc "Toplevel447" 1
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SoilRoughnessNwinC -width 5 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry256" vTcl:WidgetProc "Toplevel447" 1
    pack $site_4_0.lab74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_4_0.ent75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_3_0.tit72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit92 \
        -ipad 2 -text {Model of Vegetation} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame5" vTcl:WidgetProc "Toplevel447" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    radiobutton $site_4_0.cpd73 \
        \
        -command {global SoilRoughnessModel SoilRoughnessRho

$widget(Label447_1) configure -state normal
$widget(Entry447_1) configure -state normal
$widget(Entry447_1) configure -disabledbackground #FFFFFF
set SoilRoughnessRho "?"} \
        -text {Volume 1} -value 1 -variable SoilRoughnessModel 
    vTcl:DefineAlias "$site_4_0.cpd73" "Radiobutton5" vTcl:WidgetProc "Toplevel447" 1
    radiobutton $site_4_0.rad71 \
        \
        -command {global SoilRoughnessModel SoilRoughnessRho

$widget(Label447_1) configure -state disable
$widget(Entry447_1) configure -state disable
$widget(Entry447_1) configure -disabledbackground $PSPBackgroundColor
set SoilRoughnessRho ""} \
        -text {Volume 2} -value 2 -variable SoilRoughnessModel 
    vTcl:DefineAlias "$site_4_0.rad71" "Radiobutton3" vTcl:WidgetProc "Toplevel447" 1
    radiobutton $site_4_0.cpd72 \
        \
        -command {global SoilRoughnessModel SoilRoughnessRho

$widget(Label447_1) configure -state disable
$widget(Entry447_1) configure -state disable
$widget(Entry447_1) configure -disabledbackground $PSPBackgroundColor
set SoilRoughnessRho ""} \
        -text {Volume 3} -value 3 -variable SoilRoughnessModel 
    vTcl:DefineAlias "$site_4_0.cpd72" "Radiobutton4" vTcl:WidgetProc "Toplevel447" 1
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame8" vTcl:WidgetProc "Toplevel447" 1
    set site_5_0 $site_4_0.cpd66
    label $site_5_0.lab74 \
        -text {Rho parameter} 
    vTcl:DefineAlias "$site_5_0.lab74" "Label447_1" vTcl:WidgetProc "Toplevel447" 1
    entry $site_5_0.ent66 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SoilRoughnessRho -width 5 
    vTcl:DefineAlias "$site_5_0.ent66" "Entry447_1" vTcl:WidgetProc "Toplevel447" 1
    pack $site_5_0.lab74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.ent66 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -ipad 2 -text {Ground to Volume ratio} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame447_3" vTcl:WidgetProc "Toplevel447" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    checkbutton $site_4_0.che69 \
        \
        -command {global SoilRoughnessGtoVS SoilRoughnessGtoVD SoilRoughnessGtoVC SoilRoughnessGtoVBMP

if {$SoilRoughnessGtoVS == 1 || $SoilRoughnessGtoVD == 1 || $SoilRoughnessGtoVC == 1} {
    $widget(Checkbutton447_1) configure -state normal
    }
if {$SoilRoughnessGtoVS == 0 & $SoilRoughnessGtoVD == 0 & $SoilRoughnessGtoVC == 0} {
    $widget(Checkbutton447_1) configure -state disable
    set $SoilRoughnessGtoVBMP 0
    }} \
        -text {GtoV ratio Surface} -variable SoilRoughnessGtoVS 
    vTcl:DefineAlias "$site_4_0.che69" "Checkbutton1" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd71 \
        \
        -command {global SoilRoughnessGtoVS SoilRoughnessGtoVD SoilRoughnessGtoVC SoilRoughnessGtoVBMP

if {$SoilRoughnessGtoVS == 1 || $SoilRoughnessGtoVD == 1 || $SoilRoughnessGtoVC == 1} {
    $widget(Checkbutton447_1) configure -state normal
    }
if {$SoilRoughnessGtoVS == 0 & $SoilRoughnessGtoVD == 0 & $SoilRoughnessGtoVC == 0} {
    $widget(Checkbutton447_1) configure -state disable
    set $SoilRoughnessGtoVBMP 0
    }} \
        -text {GtoV ratio Dihedral} -variable SoilRoughnessGtoVD 
    vTcl:DefineAlias "$site_4_0.cpd71" "Checkbutton2" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd72 \
        \
        -command {global SoilRoughnessGtoVS SoilRoughnessGtoVD SoilRoughnessGtoVC SoilRoughnessGtoVBMP

if {$SoilRoughnessGtoVS == 1 || $SoilRoughnessGtoVD == 1 || $SoilRoughnessGtoVC == 1} {
    $widget(Checkbutton447_1) configure -state normal
    }
if {$SoilRoughnessGtoVS == 0 & $SoilRoughnessGtoVD == 0 & $SoilRoughnessGtoVC == 0} {
    $widget(Checkbutton447_1) configure -state disable
    set $SoilRoughnessGtoVBMP 0
    }} \
        -text {GtoV ratio Combined} -variable SoilRoughnessGtoVC 
    vTcl:DefineAlias "$site_4_0.cpd72" "Checkbutton3" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd73 \
        -text BMP -variable SoilRoughnessGtoVBMP 
    vTcl:DefineAlias "$site_4_0.cpd73" "Checkbutton447_1" vTcl:WidgetProc "Toplevel447" 1
    pack $site_4_0.che69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd76 \
        -ipad 2 -text {Surface Roughness estimation} 
    vTcl:DefineAlias "$top.cpd76" "TitleFrame254" vTcl:WidgetProc "Toplevel447" 1
    bind $top.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd76 getframe]
    checkbutton $site_4_0.che69 \
        \
        -command {global SoilRoughnessByGtoVS SoilRoughnessByA SoilRoughnessByCC SoilRoughnessByBMP

if {$SoilRoughnessByGtoV == 1 || $SoilRoughnessByA == 1 || $SoilRoughnessByCC == 1} {
    $widget(Checkbutton447_2) configure -state normal
    }
if {$SoilRoughnessByGtoV == 0 & $SoilRoughnessByA == 0 & $SoilRoughnessByCC == 0} {
    $widget(Checkbutton447_2) configure -state disable
    set SoilRoughnessByBMP 0
    }} \
        -text {by GtoV ratio} -variable SoilRoughnessByGtoV 
    vTcl:DefineAlias "$site_4_0.che69" "Checkbutton5" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd71 \
        \
        -command {global SoilRoughnessByGtoVS SoilRoughnessByA SoilRoughnessByCC SoilRoughnessByBMP

if {$SoilRoughnessByGtoV == 1 || $SoilRoughnessByA == 1 || $SoilRoughnessByCC == 1} {
    $widget(Checkbutton447_2) configure -state normal
    }
if {$SoilRoughnessByGtoV == 0 & $SoilRoughnessByA == 0 & $SoilRoughnessByCC == 0} {
    $widget(Checkbutton447_2) configure -state disable
    set SoilRoughnessByBMP 0
    }} \
        -text {by Anisotropy} -variable SoilRoughnessByA 
    vTcl:DefineAlias "$site_4_0.cpd71" "Checkbutton6" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd72 \
        \
        -command {global SoilRoughnessByGtoVS SoilRoughnessByA SoilRoughnessByCC SoilRoughnessByBMP

if {$SoilRoughnessByGtoV == 1 || $SoilRoughnessByA == 1 || $SoilRoughnessByCC == 1} {
    $widget(Checkbutton447_2) configure -state normal
    }
if {$SoilRoughnessByGtoV == 0 & $SoilRoughnessByA == 0 & $SoilRoughnessByCC == 0} {
    $widget(Checkbutton447_2) configure -state disable
    set SoilRoughnessByBMP 0
    }} \
        -text {by Cicular Coherence} -variable SoilRoughnessByCC 
    vTcl:DefineAlias "$site_4_0.cpd72" "Checkbutton7" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd73 \
        -text BMP -variable SoilRoughnessByBMP 
    vTcl:DefineAlias "$site_4_0.cpd73" "Checkbutton447_2" vTcl:WidgetProc "Toplevel447" 1
    pack $site_4_0.che69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd77 \
        -ipad 2 -text {Soil Moisture estimation ( % )} 
    vTcl:DefineAlias "$top.cpd77" "TitleFrame255" vTcl:WidgetProc "Toplevel447" 1
    bind $top.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd77 getframe]
    checkbutton $site_4_0.che69 \
        \
        -command {global SoilRoughnessFromX SoilRoughnessFromS SoilRoughnessFromD SoilRoughnessFromBMP

if {$SoilRoughnessFromX == 1 || $SoilRoughnessFromS == 1 || $SoilRoughnessFromD == 1} {
    $widget(Checkbutton447_3) configure -state normal
    }
if {$SoilRoughnessFromX == 0 & $SoilRoughnessFromS == 0 & $SoilRoughnessFromD == 0} {
    $widget(Checkbutton447_3) configure -state disable
    set $SoilRoughnessFromBMP 0
    }} \
        -text {from X-Bragg model} -variable SoilRoughnessFromX 
    vTcl:DefineAlias "$site_4_0.che69" "Checkbutton9" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd71 \
        \
        -command {global SoilRoughnessFromX SoilRoughnessFromS SoilRoughnessFromD SoilRoughnessFromBMP

if {$SoilRoughnessFromX == 1 || $SoilRoughnessFromS == 1 || $SoilRoughnessFromD == 1} {
    $widget(Checkbutton447_3) configure -state normal
    }
if {$SoilRoughnessFromX == 0 & $SoilRoughnessFromS == 0 & $SoilRoughnessFromD == 0} {
    $widget(Checkbutton447_3) configure -state disable
    set $SoilRoughnessFromBMP 0
    }} \
        -text {from Surface component} -variable SoilRoughnessFromS 
    vTcl:DefineAlias "$site_4_0.cpd71" "Checkbutton10" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd72 \
        \
        -command {global SoilRoughnessFromX SoilRoughnessFromS SoilRoughnessFromD SoilRoughnessFromBMP

if {$SoilRoughnessFromX == 1 || $SoilRoughnessFromS == 1 || $SoilRoughnessFromD == 1} {
    $widget(Checkbutton447_3) configure -state normal
    }
if {$SoilRoughnessFromX == 0 & $SoilRoughnessFromS == 0 & $SoilRoughnessFromD == 0} {
    $widget(Checkbutton447_3) configure -state disable
    set $SoilRoughnessFromBMP 0
    }} \
        -text {from Dihedral component} -variable SoilRoughnessFromD 
    vTcl:DefineAlias "$site_4_0.cpd72" "Checkbutton11" vTcl:WidgetProc "Toplevel447" 1
    checkbutton $site_4_0.cpd73 \
        -text BMP -variable SoilRoughnessFromBMP 
    vTcl:DefineAlias "$site_4_0.cpd73" "Checkbutton447_3" vTcl:WidgetProc "Toplevel447" 1
    pack $site_4_0.che69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel447" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir DirName SoilRoughnessDirInput SoilRoughnessDirOutput SoilRoughnessOutputDir SoilRoughnessOutputSubDir 
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType
global SoilRoughnessModel LIAFile LIAangle SoilRoughnessRho
global SoilRoughnessNwinL SoilRoughnessNwinC
global SoilRoughnessGtoVS SoilRoughnessGtoVD SoilRoughnessGtoVC SoilRoughnessGtoVBMP
global SoilRoughnessByGtoV SoilRoughnessByA SoilRoughnessByCC SoilRoughnessByBMP
global SoilRoughnessFromX SoilRoughnessFromS SoilRoughnessFromD SoilRoughnessFromBMP
global PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set SoilRoughnessDirOutput $SoilRoughnessOutputDir
if {$SoilRoughnessOutputSubDir != ""} {append SoilRoughnessDirOutput "/$SoilRoughnessOutputSubDir"}

    #####################################################################
    #Create Directory
    set SoilRoughnessDirOutput [PSPCreateDirectoryMask $SoilRoughnessDirOutput $SoilRoughnessDirOutput $SoilRoughnessDirInput]
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
    set TestVarName(4) "Local Incidence Angle File"; set TestVarType(4) "file"; set TestVarValue(4) $LIAFile; set TestVarMin(4) ""; set TestVarMax(4) ""
    set TestVarName(5) "Window Size Row"; set TestVarType(5) "int"; set TestVarValue(5) $SoilRoughnessNwinL; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    set TestVarName(6) "Window Size Col"; set TestVarType(6) "int"; set TestVarValue(6) $SoilRoughnessNwinC; set TestVarMin(6) "1"; set TestVarMax(6) "1000"
    TestVar 7
    set SoilRoughRho "0"
    if {$SoilRoughnessModel == "1"} {
        set TestVarName(7) "Rho parameter"; set TestVarType(7) "float"; set TestVarValue(7) $SoilRoughnessRho; set TestVarMin(7) "0.33"; set TestVarMax(7) "1."
        set SoilRoughRho $SoilRoughnessRho
        TestVar 8
        }

    if {$TestVarError == "ok"} {
        set SoilRoughnessFonction ""
        set Fonction "SOIL - ROUGHNESS INVERSION"
        set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$SoilRoughnessDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$SoilRoughnessOutputSubDir == ""} {set SoilRoughnessF "S2"}
        if {$SoilRoughnessOutputSubDir == "T3"} {set SoilRoughnessF "T3"}
        if {$SoilRoughnessOutputSubDir == "T4"} {set SoilRoughnessF "T4"}
        if {$SoilRoughnessOutputSubDir == "C3"} {set SoilRoughnessF "C3"}
        if {$SoilRoughnessOutputSubDir == "C4"} {set SoilRoughnessF "C4"}
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/soil_roughness_inversion.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SoilRoughnessDirInput\x22 -od \x22$SoilRoughnessDirOutput\x22 -iodf $SoilRoughnessF -ang \x22$LIAFile\x22 -un $LIAangle -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nwr $SoilRoughnessNwinL -nwc $SoilRoughnessNwinC -fl1 $SoilRoughnessGtoVS -fl2 $SoilRoughnessGtoVD -fl3 $SoilRoughnessGtoVC -fl4 $SoilRoughnessByGtoV -fl5 $SoilRoughnessByA -fl6 $SoilRoughnessByCC -fl7 $SoilRoughnessFromX -fl8 $SoilRoughnessFromS -fl9 $SoilRoughnessFromD -fl10 $SoilRoughnessModel -fl11 $SoilRoughRho -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/soil_roughness_inversion.exe -id \x22$SoilRoughnessDirInput\x22 -od \x22$SoilRoughnessDirOutput\x22 -iodf $SoilRoughnessF -ang \x22$LIAFile\x22 -un $LIAangle -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nwr $SoilRoughnessNwinL -nwc $SoilRoughnessNwinC -fl1 $SoilRoughnessGtoVS -fl2 $SoilRoughnessGtoVD -fl3 $SoilRoughnessGtoVC -fl4 $SoilRoughnessByGtoV -fl5 $SoilRoughnessByA -fl6 $SoilRoughnessByCC -fl7 $SoilRoughnessFromX -fl8 $SoilRoughnessFromS -fl9 $SoilRoughnessFromD -fl10 $SoilRoughnessModel -fl11 $SoilRoughRho -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists "$SoilRoughnessDirOutput/GtoVratio_surface.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/GtoVratio_surface.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/GtoVratio_dihedral.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/GtoVratio_dihedral.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/GtoVratio_combined.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/GtoVratio_combined.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/roughness_gtov.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/roughness_gtov.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/roughness_anisotropy.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/roughness_anisotropy.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/roughness_circular_corr.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/roughness_circular_corr.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/soil_xbragg.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/soil_xbragg.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/soil_surface.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/soil_surface.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SoilRoughnessDirOutput/soil_dihedral.bin"] {EnviWriteConfig "$SoilRoughnessDirOutput/soil_dihedral.bin" $FinalNlig $FinalNcol 4}

        set Fonction "Creation of the BMP File"
        if {$SoilRoughnessGtoVBMP == 1} {
            if [file exists "$SoilRoughnessDirOutput/GtoVratio_surface.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/GtoVratio_surface.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/GtoVratio_surface.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "THE FILE GtoVratio_surface.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$SoilRoughnessDirOutput/GtoVratio_dihedral.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/GtoVratio_dihedral.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/GtoVratio_dihedral.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "THE FILE GtoVratio_dihedral.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$SoilRoughnessDirOutput/GtoVratio_combined.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/GtoVratio_combined.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/GtoVratio_combined.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "THE FILE GtoVratio_combined.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {$SoilRoughnessByBMP == 1} {
            if [file exists "$SoilRoughnessDirOutput/roughness_gtov.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/roughness_gtov.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/roughness_gtov.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "THE FILE roughness_gtov.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$SoilRoughnessDirOutput/roughness_anisotropy.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/roughness_anisotropy.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/roughness_anisotropy.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "THE FILE roughness_anisotropy.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$SoilRoughnessDirOutput/roughness_circular_corr.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/roughness_circular_corr.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/roughness_circular_corr.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "THE FILE roughness_circular_corr.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {$SoilRoughnessFromBMP == 1} {
            if [file exists "$SoilRoughnessDirOutput/soil_xbragg.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/soil_xbragg.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/soil_xbragg.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 100
                } else {
                set VarError ""
                set ErrorMessage "THE FILE soil_xbragg.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$SoilRoughnessDirOutput/soil_surface.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/soil_surface.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/soil_surface.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 100
                } else {
                set VarError ""
                set ErrorMessage "THE FILE soil_surface.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$SoilRoughnessDirOutput/soil_dihedral.bin"] {
                set BMPFileInput "$SoilRoughnessDirOutput/soil_dihedral.bin"
                set BMPFileOutput "$SoilRoughnessDirOutput/soil_dihedral.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 100
                } else {
                set VarError ""
                set ErrorMessage "THE FILE soil_dihedral.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        }

    } else {
    if {"$VarWarning"=="no"} { Window hide $widget(Toplevel447); TextEditorRunTrace "Close Window Soil Roughness Parameter Data Inversion" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel447" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SoilRoughnessInversion.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel447" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel447); TextEditorRunTrace "Close Window Soil Roughness Parameter Data Inversion" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel447" 1
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
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra83 \
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
Window show .top447

main $argc $argv
