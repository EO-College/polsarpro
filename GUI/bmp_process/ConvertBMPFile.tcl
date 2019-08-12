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

        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
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
    set base .top450
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd68
    namespace eval ::widgets::$site_4_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd69
    namespace eval ::widgets::$site_4_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit70 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit70 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra71 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra71
    namespace eval ::widgets::$site_5_0.rad73 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra73
    namespace eval ::widgets::$site_7_0.but74 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra68
    namespace eval ::widgets::$site_7_0.rad69 {
        array set save {-background 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-background 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-background 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.cpd99 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.tit74 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.che79 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd69 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd70 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd85 {
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
            vTclWindow.top450
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
    wm geometry $top 200x200+50+50; update
    wm maxsize $top 3364 1032
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

proc vTclWindow.top450 {base} {
    if {$base == ""} {
        set base .top450
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
    wm geometry $top 500x410+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Convert BMP File"
    vTcl:DefineAlias "$top" "Toplevel450" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel450" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input BMP Image File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel450" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPFileInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel450" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel450" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName BMPDirInput BMPDirOutput BMPFileInput BMPFileOutput 
global VarError ErrorMessage
global NLigBMPColor NColBMPColor NColorBMPColor
global PSPBackgroundColor ReducFactor TranspColor

set BMPFileInput ""; set BMPFileOutput ""
set NLigBMPColor ""; set NColBMPColor ""; set NColorBMPColor ""

$widget(Label450_1) configure -state disable
$widget(Radiobutton450_2) configure -state disable
$widget(Radiobutton450_3) configure -state disable
$widget(Radiobutton450_4) configure -state disable
$widget(Label450_2) configure -state disable
$widget(Button450_1) configure -state disable
$widget(Button450_2) configure -state disable
$widget(Entry450_1) configure -state disable
$widget(Entry450_1) configure -disabledbackground $PSPBackgroundColor
set ReducFactor " "; set TranspColor " "; 

set BMPDirInputTmp $BMPDirInput
set BMPDirOutputTmp $BMPDirOutput

set types {
{{BMP Files}        {.bmp}        }
}
set FileName ""
OpenFile $BMPDirInput $types "INPUT BMP FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set NColBMPColor [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set NLigBMPColor [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; gets $f tmp; gets $f tmp
            if {[string first "8 bytes" $tmp] != "-1"} { set NColorBMPColor "BMP 8 Bits"; $widget(Radiobutton450_1) configure -state disable}
            if {[string first "24 bytes" $tmp] != "-1"} { set NColorBMPColor "BMP 24 Bits"; $widget(Radiobutton450_1) configure -state normal}
            set BMPDirInput [file dirname $FileName]
            set BMPDirOutput $BMPDirInput
            set BMPFileInput $FileName
            set BMPFileOutput [file rootname $BMPFileInput]; append BMPFileOutput ".bmp"
            } else {
            set ErrorMessage "NOT A PolSARpro BMP FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set BMPDirInput $BMPDirInputTmp
            set BMPDirOutput $BMPDirOutputTmp
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set BMPDirInput $BMPDirInputTmp
        set BMPDirOutput $BMPDirOutputTmp
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
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra51 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame9" vTcl:WidgetProc "Toplevel450" 1
    set site_3_0 $top.fra51
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame10" vTcl:WidgetProc "Toplevel450" 1
    set site_4_0 $site_3_0.cpd66
    label $site_4_0.lab59 \
        -padx 1 -text {N Row} 
    vTcl:DefineAlias "$site_4_0.lab59" "Label12" vTcl:WidgetProc "Toplevel450" 1
    entry $site_4_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NLigBMPColor -width 7 
    vTcl:DefineAlias "$site_4_0.ent60" "Entry8" vTcl:WidgetProc "Toplevel450" 1
    pack $site_4_0.lab59 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.ent60 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd68" "Frame11" vTcl:WidgetProc "Toplevel450" 1
    set site_4_0 $site_3_0.cpd68
    label $site_4_0.lab63 \
        -text {N Col} 
    vTcl:DefineAlias "$site_4_0.lab63" "Label16" vTcl:WidgetProc "Toplevel450" 1
    entry $site_4_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NColBMPColor -width 7 
    vTcl:DefineAlias "$site_4_0.ent64" "Entry12" vTcl:WidgetProc "Toplevel450" 1
    pack $site_4_0.lab63 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.ent64 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd69" "Frame12" vTcl:WidgetProc "Toplevel450" 1
    set site_4_0 $site_3_0.cpd69
    label $site_4_0.lab63 \
        -text {N Color} 
    vTcl:DefineAlias "$site_4_0.lab63" "Label18" vTcl:WidgetProc "Toplevel450" 1
    entry $site_4_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NColorBMPColor -width 13 
    vTcl:DefineAlias "$site_4_0.ent64" "Entry14" vTcl:WidgetProc "Toplevel450" 1
    pack $site_4_0.lab63 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.ent64 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    TitleFrame $top.tit70 \
        -text {Output Image Format} 
    vTcl:DefineAlias "$top.tit70" "TitleFrame1" vTcl:WidgetProc "Toplevel450" 1
    bind $top.tit70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit70 getframe]
    frame $site_4_0.fra71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra71" "Frame3" vTcl:WidgetProc "Toplevel450" 1
    set site_5_0 $site_4_0.fra71
    radiobutton $site_5_0.rad73 \
        \
        -command {global PSPBackgroundColor BMPFileInput BMPFileOutput
global ReducFactor TranspColor

$widget(Label450_1) configure -state normal
$widget(Radiobutton450_2) configure -state normal
$widget(Radiobutton450_3) configure -state normal
$widget(Radiobutton450_4) configure -state normal
$widget(Label450_2) configure -state normal
$widget(Button450_1) configure -state normal
$widget(Button450_2) configure -state normal
$widget(Entry450_1) configure -state disable
$widget(Entry450_1) configure -disabledbackground #FFFFFF
set BMPFileOutput [file rootname $BMPFileInput]; append BMPFileOutput ".gif"
set ReducFactor "2"; set TranspColor "2";} \
        -text GIF -value gif -variable BMPOutputFormat 
    vTcl:DefineAlias "$site_5_0.rad73" "Radiobutton7" vTcl:WidgetProc "Toplevel450" 1
    radiobutton $site_5_0.cpd74 \
        \
        -command {global PSPBackgroundColor BMPFileInput BMPFileOutput
global ReducFactor TranspColor

$widget(Label450_1) configure -state normal
$widget(Radiobutton450_2) configure -state normal
$widget(Radiobutton450_3) configure -state normal
$widget(Radiobutton450_4) configure -state normal
$widget(Label450_2) configure -state normal
$widget(Button450_1) configure -state normal
$widget(Button450_2) configure -state normal
$widget(Entry450_1) configure -state disable
$widget(Entry450_1) configure -disabledbackground #FFFFFF
set BMPFileOutput [file rootname $BMPFileInput]; append BMPFileOutput ".jpg"
set ReducFactor "2"; set TranspColor "2";} \
        -text JPEG -value jpg -variable BMPOutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd74" "Radiobutton8" vTcl:WidgetProc "Toplevel450" 1
    radiobutton $site_5_0.cpd75 \
        \
        -command {global PSPBackgroundColor BMPFileInput BMPFileOutput
global ReducFactor TranspColor

$widget(Label450_1) configure -state normal
$widget(Radiobutton450_2) configure -state normal
$widget(Radiobutton450_3) configure -state normal
$widget(Radiobutton450_4) configure -state normal
$widget(Label450_2) configure -state normal
$widget(Button450_1) configure -state normal
$widget(Button450_2) configure -state normal
$widget(Entry450_1) configure -state disable
$widget(Entry450_1) configure -disabledbackground #FFFFFF
set BMPFileOutput [file rootname $BMPFileInput]; append BMPFileOutput ".png"
set ReducFactor "2"; set TranspColor "2";} \
        -text PNG -value png -variable BMPOutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd75" "Radiobutton9" vTcl:WidgetProc "Toplevel450" 1
    radiobutton $site_5_0.cpd76 \
        \
        -command {global PSPBackgroundColor BMPFileInput BMPFileOutput
global ReducFactor TranspColor

$widget(Label450_1) configure -state normal
$widget(Radiobutton450_2) configure -state normal
$widget(Radiobutton450_3) configure -state normal
$widget(Radiobutton450_4) configure -state normal
$widget(Label450_2) configure -state normal
$widget(Button450_1) configure -state normal
$widget(Button450_2) configure -state normal
$widget(Entry450_1) configure -state disable
$widget(Entry450_1) configure -disabledbackground #FFFFFF
set BMPFileOutput [file rootname $BMPFileInput]; append BMPFileOutput ".tiff"
set ReducFactor "2"; set TranspColor "2";} \
        -text TIFF -value tif -variable BMPOutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd76" "Radiobutton10" vTcl:WidgetProc "Toplevel450" 1
    radiobutton $site_5_0.cpd77 \
        \
        -command {global PSPBackgroundColor BMPFileInput BMPFileOutput
global ReducFactor TranspColor

$widget(Label450_1) configure -state disable
$widget(Radiobutton450_2) configure -state disable
$widget(Radiobutton450_3) configure -state disable
$widget(Radiobutton450_4) configure -state disable
$widget(Label450_2) configure -state disable
$widget(Button450_1) configure -state disable
$widget(Button450_2) configure -state disable
$widget(Entry450_1) configure -state disable
$widget(Entry450_1) configure -disabledbackground $PSPBackgroundColor
set BMPFileOutput [file rootname $BMPFileInput]; append BMPFileOutput "_BMP8.bmp"
set ReducFactor " "; set TranspColor " ";} \
        -text {BMP24 >> BMP8} -value bmp248 -variable BMPOutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd77" "Radiobutton450_1" vTcl:WidgetProc "Toplevel450" 1
    pack $site_5_0.rad73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame17" vTcl:WidgetProc "Toplevel450" 1
    set site_5_0 $site_4_0.cpd72
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame28" vTcl:WidgetProc "Toplevel450" 1
    set site_6_0 $site_5_0.cpd78
    label $site_6_0.cpd76 \
        -text {Reduction Factor} 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label450_2" vTcl:WidgetProc "Toplevel450" 1
    entry $site_6_0.ent72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ReducFactor -width 5 
    vTcl:DefineAlias "$site_6_0.ent72" "Entry450_1" vTcl:WidgetProc "Toplevel450" 1
    frame $site_6_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra73" "Frame29" vTcl:WidgetProc "Toplevel450" 1
    set site_7_0 $site_6_0.fra73
    button $site_7_0.but74 \
        \
        -command {global ReducFactor

set ReducFactor [expr $ReducFactor + 1]
if  {$ReducFactor == 7}  { set ReducFactor 1 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_7_0.but74" "Button450_1" vTcl:WidgetProc "Toplevel450" 1
    button $site_7_0.but75 \
        \
        -command {global ReducFactor

set ReducFactor [expr $ReducFactor - 1]
if  {$ReducFactor < 1 }  { set ReducFactor 6 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but75" "Button450_2" vTcl:WidgetProc "Toplevel450" 1
    pack $site_7_0.but74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.but75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.ent72 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.fra73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame30" vTcl:WidgetProc "Toplevel450" 1
    set site_6_0 $site_5_0.cpd79
    label $site_6_0.cpd76 \
        -text Transparency 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label450_1" vTcl:WidgetProc "Toplevel450" 1
    frame $site_6_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra68" "Frame4" vTcl:WidgetProc "Toplevel450" 1
    set site_7_0 $site_6_0.fra68
    radiobutton $site_7_0.rad69 \
        -background #ffffff -relief ridge -value 0 -variable TranspColor 
    vTcl:DefineAlias "$site_7_0.rad69" "Radiobutton450_2" vTcl:WidgetProc "Toplevel450" 1
    radiobutton $site_7_0.cpd70 \
        -background #cccccc -relief ridge -value 1 -variable TranspColor 
    vTcl:DefineAlias "$site_7_0.cpd70" "Radiobutton450_3" vTcl:WidgetProc "Toplevel450" 1
    radiobutton $site_7_0.cpd71 \
        -background #000000 -value 2 -variable TranspColor 
    vTcl:DefineAlias "$site_7_0.cpd71" "Radiobutton450_4" vTcl:WidgetProc "Toplevel450" 1
    pack $site_7_0.rad69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -pady 3 -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra71 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame5" vTcl:WidgetProc "Toplevel450" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd99 \
        -ipad 0 -text {Output Image File} 
    vTcl:DefineAlias "$site_3_0.cpd99" "TitleFrame12" vTcl:WidgetProc "Toplevel450" 1
    bind $site_3_0.cpd99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh12" vTcl:WidgetProc "Toplevel450" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd99 \
        -in $site_3_0 -anchor center -expand 1 -fill x -pady 5 -side top 
    TitleFrame $top.tit74 \
        -text {World File Generation} 
    vTcl:DefineAlias "$top.tit74" "TitleFrame2" vTcl:WidgetProc "Toplevel450" 1
    bind $top.tit74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit74 getframe]
    checkbutton $site_4_0.che79 \
        \
        -command {global FileName BMPFileOutput BMPFileOutputWF BMPGearthPolyFile BMPConfAcqFile
global PSPBackgroundColor BMPOutputFormat BMPWorldFile

if {$BMPWorldFile == 0} {
    $widget(TitleFrame450_1) configure -state disable
    $widget(TitleFrame450_2) configure -state disable
    $widget(TitleFrame450_3) configure -state disable
    $widget(Button450_3) configure -state disable
    $widget(Button450_4) configure -state disable
    $widget(Entry450_2) configure -state disable
    $widget(Entry450_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry450_3) configure -state disable
    $widget(Entry450_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry450_4) configure -state disable
    $widget(Entry450_4) configure -disabledbackground $PSPBackgroundColor
    set BMPFileOutputWF ""; set BMPGearthPolyFile ""; set BMPConfAcqFile ""
    } else {
    if {$BMPOutputFormat != "bmp248"} {
        $widget(TitleFrame450_1) configure -state normal
        $widget(TitleFrame450_2) configure -state normal
        $widget(TitleFrame450_3) configure -state normal
        $widget(Button450_3) configure -state normal
        $widget(Button450_4) configure -state normal
        $widget(Entry450_2) configure -state disable
        $widget(Entry450_2) configure -disabledbackground #FFFFFF
        $widget(Entry450_3) configure -state disable
        $widget(Entry450_3) configure -disabledbackground #FFFFFF
        $widget(Entry450_4) configure -state disable
        $widget(Entry450_4) configure -disabledbackground #FFFFFF
        set BMPGearthPolyFile "ENTER THE GEARTH POLY FILE"
        set BMPConfAcqFile "ENTER THE CONFIG ACQUISITION FILE"
        set BMPFileOutputWF [file rootname $BMPFileOutput]
        if {$BMPOutputFormat == "gif"} {append BMPFileOutputWF ".gfw"}
        if {$BMPOutputFormat == "jpg"} {append BMPFileOutputWF ".jpw"}
        if {$BMPOutputFormat == "png"} {append BMPFileOutputWF ".pgw"}
        if {$BMPOutputFormat == "tif"} {append BMPFileOutputWF ".tfw"}
        } else {
        $widget(TitleFrame450_1) configure -state disable
        $widget(TitleFrame450_2) configure -state disable
        $widget(TitleFrame450_3) configure -state disable
        $widget(Button450_3) configure -state disable
        $widget(Button450_4) configure -state disable
        $widget(Entry450_2) configure -state disable
        $widget(Entry450_2) configure -disabledbackground $PSPBackgroundColor
        $widget(Entry450_3) configure -state disable
        $widget(Entry450_3) configure -disabledbackground $PSPBackgroundColor
        $widget(Entry450_4) configure -state disable
        $widget(Entry450_4) configure -disabledbackground $PSPBackgroundColor
        set BMPFileOutputWF ""; set BMPGearthPolyFile ""; set BMPConfAcqFile ""
        }
    }} \
        -variable BMPWorldFile 
    vTcl:DefineAlias "$site_4_0.che79" "Checkbutton1" vTcl:WidgetProc "Toplevel450" 1
    frame $site_4_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame18" vTcl:WidgetProc "Toplevel450" 1
    set site_5_0 $site_4_0.cpd78
    TitleFrame $site_5_0.cpd69 \
        -ipad 0 -text {Input GEARTH_POLY File} 
    vTcl:DefineAlias "$site_5_0.cpd69" "TitleFrame450_1" vTcl:WidgetProc "Toplevel450" 1
    bind $site_5_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd69 getframe]
    entry $site_7_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPGearthPolyFile 
    vTcl:DefineAlias "$site_7_0.cpd85" "Entry450_2" vTcl:WidgetProc "Toplevel450" 1
    frame $site_7_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame32" vTcl:WidgetProc "Toplevel450" 1
    set site_8_0 $site_7_0.cpd91
    button $site_8_0.cpd79 \
        \
        -command {global FileName BMPDirInput BMPGearthPolyFile

set GPDirInput [file dirname $BMPDirInput]

set types {
{{KML Files}        {.kml}        }
}
set FileName ""
OpenFile $GPDirInput $types "INPUT GEARTH POLY FILE" 
if {$FileName != ""} {
    set BMPGearthPolyFile $FileName
    } else {
    set BMPGearthPolyFile "ENTER THE GEARTH POLY FILE"
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd79" "Button450_3" vTcl:WidgetProc "Toplevel450" 1
    bindtags $site_8_0.cpd79 "$site_8_0.cpd79 Button $top all _vTclBalloon"
    bind $site_8_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_8_0.cpd79 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_5_0.cpd70 \
        -ipad 0 -text {Input Config Acquisition File} 
    vTcl:DefineAlias "$site_5_0.cpd70" "TitleFrame450_2" vTcl:WidgetProc "Toplevel450" 1
    bind $site_5_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd70 getframe]
    entry $site_7_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPConfAcqFile 
    vTcl:DefineAlias "$site_7_0.cpd85" "Entry450_3" vTcl:WidgetProc "Toplevel450" 1
    frame $site_7_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame33" vTcl:WidgetProc "Toplevel450" 1
    set site_8_0 $site_7_0.cpd91
    button $site_8_0.cpd79 \
        \
        -command {global FileName BMPDirInput BMPConfAcqFile

set CADirInput [file dirname $BMPDirInput]

set types {
{{TXT Files}        {.txt}        }
}
set FileName ""
OpenFile $CADirInput $types "INPUT CONFIG ACQUISITION FILE" 
if {$FileName != ""} {
    set BMPConfAcqFile $FileName
    } else {
    set BMPConfAcqFile "ENTER THE CONFIG ACQUISITION FILE"
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd79" "Button450_4" vTcl:WidgetProc "Toplevel450" 1
    bindtags $site_8_0.cpd79 "$site_8_0.cpd79 Button $top all _vTclBalloon"
    bind $site_8_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_8_0.cpd79 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_5_0.cpd76 \
        -ipad 0 -text {Output World File} 
    vTcl:DefineAlias "$site_5_0.cpd76" "TitleFrame450_3" vTcl:WidgetProc "Toplevel450" 1
    bind $site_5_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    entry $site_7_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPFileOutputWF 
    vTcl:DefineAlias "$site_7_0.cpd85" "Entry450_4" vTcl:WidgetProc "Toplevel450" 1
    pack $site_7_0.cpd85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.che79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel450" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_3_0.but93 {global BMPDirOutput BMPFileInput BMPFileOutput BMPOutputFormat
global  BMPWorldFile BMPGearthPolyFile BMPConfAcqFile BMPFileOutputWF
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global OpenDirFile ImageMagickMaker ReducFactor TranspColor DisplayGoogleEarth
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    set config "true"
    if {"$BMPFileInput"==""} {set config "false"}
    
    if {"$config"=="false"} {
        set VarError ""
        set ErrorMessage "INVALID INPUT BMP FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {"$config"=="true"} {

    set BMPDirOutput [file dirname $BMPFileOutput]
    
    #####################################################################
    #Create Directory
    set BMPDirOutput [PSPCreateDirectoryMask $BMPDirOutput $BMPDirOutput $BMPDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"

        if {$BMPOutputFormat != "bmp248"} {
            set ImageMagickCommand " $BMPFileInput"
            if {$ReducFactor == 2} { append ImageMagickCommand " -resize 50%" }
            if {$ReducFactor == 3} { append ImageMagickCommand " -resize 33%" }
            if {$ReducFactor == 4} { append ImageMagickCommand " -resize 25%" }
            if {$ReducFactor == 5} { append ImageMagickCommand " -resize 20%" }
            if {$ReducFactor == 6} { append ImageMagickCommand " -resize 17%" }
            if {$TranspColor == 0} { append ImageMagickCommand " -transparent \x22rgb(255,255,255)\x22" }
            if {$TranspColor == 1} { append ImageMagickCommand " -transparent \x22rgb(125,125,125)\x22" }
            if {$TranspColor == 2} { append ImageMagickCommand " -transparent \x22rgb(0,0,0)\x22" }
            append ImageMagickCommand " -quiet"
            append ImageMagickCommand " $BMPFileOutput"

            set Fonction "Convert a BMP File"
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ImageMagickMaker" "k"
            TextEditorRunTrace "Arguments: $ImageMagickCommand" "k"
            set f [ open "| \x22$ImageMagickMaker\x22 $ImageMagickCommand" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            if {$BMPWorldFile == 1} {
                set Fonction "Creation of the World File :"
                set Fonction2 "$BMPFileOutputWF"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/tools/create_world_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifg \x22$BMPGearthPolyFile\x22 -ifa \x22$BMPConfAcqFile\x22 -of \x22$BMPFileOutputWF\x22" "k"
                set f [ open "| Soft/bin/tools/create_world_file.exe -ifg \x22$BMPGearthPolyFile\x22 -ifa \x22$BMPConfAcqFile\x22 -of \x22$BMPFileOutputWF\x22" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"       
                }

            } else {
            set BMPFileOutputColorBIN [file rootname $BMPFileInput]; append BMPFileOutputColorBIN "_BIN.bin"
            set BMPFileOutputColorPAL [file rootname $BMPFileInput]; append BMPFileOutputColorPAL "_PAL.pal"
            set BMPFileOutputColorBMP [file rootname $BMPFileInput]; append BMPFileOutputColorBMP "_BMP8.bmp"
            set MaskFile "$BMPDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] { 
                set ValidMaskFile $MaskFile
                set MaskCmd "-mask \x22$MaskFile\x22" 
                }

            DeleteFile $BMPFileOutputColorBIN
            DeleteFile $BMPFileOutputColorPAL
            DeleteFile $BMPFileOutputColorBMP

            set Fonction "Creation of the BIN File :"
            set Fonction2 "$BMPFileOutputColorBIN"    
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/bmp_process/rgb24_to_bmp8.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -ofb \x22$BMPFileOutputColorBIN\x22 -ofc \x22$BMPFileOutputColorPAL\x22" "k"
            set f [ open "| Soft/bin/bmp_process/rgb24_to_bmp8.exe -if \x22$BMPFileInput\x22 -ofb \x22$BMPFileOutputColorBIN\x22 -ofc \x22$BMPFileOutputColorPAL\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            
            WaitUntilCreated $BMPFileOutputColorBIN
            if [file exists $BMPFileOutputColorBIN] {
                EnviWriteConfig $BMPFileOutputColorBIN $NLigBMPColor $NColBMPColor 4
                set Fonction "Creation of the BMP File :"
                set Fonction2 "$BMPFileOutputColorBMP"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                set MaskCmdMask $MaskCmd
                if {$MaskCmd != ""} { append MaskCmdMask " -mcol black" }
                set InputFormat "float"; set OutputFormat "real"
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$BMPFileOutputColorBIN\x22 -of \x22$BMPFileOutputColorBMP\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$BMPFileOutputColorPAL\x22 -nc $NColBMPColor -ofr 0 -ofc 0 -fnr $NLigBMPColor -fnc $NColBMPColor -mm 0 -min 0 -max 255 $MaskCmdMask" "k"
                set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$BMPFileOutputColorBIN\x22 -of \x22$BMPFileOutputColorBMP\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$BMPFileOutputColorPAL\x22 -nc $NColBMPColor -ofr 0 -ofc 0 -fnr $NLigBMPColor -fnc $NColBMPColor -mm 0 -min 0 -max 255 $MaskCmdMask" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }
            DeleteFile $BMPFileOutputColorBIN
            DeleteFile "$BMPFileOutputColorBIN.hdr"
            DeleteFile $BMPFileOutputColorPAL
            }
              
            Window hide $widget(Toplevel450); TextEditorRunTrace "Close Window Convert BMP File" "b"
            WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"
            } else {
            if {"$VarWarning"=="no"} {Window hide $widget(Toplevel450); TextEditorRunTrace "Close Window Convert BMP File" "b"}
            }
        }
    }}] \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel450" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CreateBMPKMLFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel450" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel450); TextEditorRunTrace "Close Window Create BMP File" "b"
if {$DisplayMainMenu == 1} {
    set DisplayMainMenu 0
    WidgetShow $widget(Toplevel2)
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel450" 1
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
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra51 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.tit70 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit74 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -side top 
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
Window show .top450

main $argc $argv
