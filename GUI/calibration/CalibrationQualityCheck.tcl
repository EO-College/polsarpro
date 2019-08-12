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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top455
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
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra67
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
    namespace eval ::widgets::$base.fra68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra68
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che69 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che78 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd68
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che69 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd69
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che69 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd72
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra77 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra77
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
            vTclWindow.top455
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

proc vTclWindow.top455 {base} {
    if {$base == ""} {
        set base .top455
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
    wm geometry $top 500x280+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Calibration : Data Quality Check"
    vTcl:DefineAlias "$top" "Toplevel455" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd73" "Frame3" vTcl:WidgetProc "Toplevel455" 1
    set site_3_0 $top.cpd73
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame6" vTcl:WidgetProc "Toplevel455" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CalibDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel455" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel455" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button38" vTcl:WidgetProc "Toplevel455" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel455" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CalibOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel455" 1
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame1" vTcl:WidgetProc "Toplevel455" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab73" "Label1" vTcl:WidgetProc "Toplevel455" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CalibOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel455" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel455" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd87 \
        \
        -command {global DirName DataDir CalibOutputDir

set CalibDirOutputTmp $CalibOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set CalibOutputDir $DirName
    } else {
    set CalibOutputDir $CalibDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd87 "$site_6_0.cpd87 Button $top all _vTclBalloon"
    bind $site_6_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra67 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame9" vTcl:WidgetProc "Toplevel455" 1
    set site_3_0 $top.fra67
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel455" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel455" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel455" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel455" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel455" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel455" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel455" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel455" 1
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
    frame $top.fra68 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra68" "Frame33" vTcl:WidgetProc "Toplevel455" 1
    set site_3_0 $top.fra68
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$Calib12"=="1"} {
    $widget(Checkbutton455_2) configure -state normal
    $widget(Checkbutton455_3) configure -state normal
    $widget(Checkbutton455_4) configure -state normal
    } else {
    $widget(Checkbutton455_2) configure -state disable
    $widget(Checkbutton455_3) configure -state disable
    $widget(Checkbutton455_4) configure -state disable
    set BMPmodCalib12 "0"
    set BMPmodCalib12b "0"
    set BMPphaCalib12 "0"
    }} \
        -padx 1 -text {Correlation HV.VH*} -variable Calib12 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton455_1" vTcl:WidgetProc "Toplevel455" 1
    checkbutton $site_3_0.che69 \
        -command {} -text {BMP Phase} -variable BMPphaCalib12 
    vTcl:DefineAlias "$site_3_0.che69" "Checkbutton455_3" vTcl:WidgetProc "Toplevel455" 1
    checkbutton $site_3_0.che78 \
        -padx 1 -text {BMP Modulus} -variable BMPmodCalib12 
    vTcl:DefineAlias "$site_3_0.che78" "Checkbutton455_2" vTcl:WidgetProc "Toplevel455" 1
    checkbutton $site_3_0.cpd66 \
        -padx 1 -text {BMP Modulus (0.8 - 1.0)} -variable BMPmodCalib12b 
    vTcl:DefineAlias "$site_3_0.cpd66" "Checkbutton455_4" vTcl:WidgetProc "Toplevel455" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side right 
    pack $site_3_0.che78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd68 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd68" "Frame34" vTcl:WidgetProc "Toplevel455" 1
    set site_3_0 $top.cpd68
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$CalibL1L2"=="1"} {
    $widget(Checkbutton455_5) configure -state normal
    } else {
    $widget(Checkbutton455_5) configure -state disable
    set BMPL1L2 "0"
    }} \
        -padx 1 -text {Eigenvalues (L1, L2)} -variable CalibL1L2 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton81" vTcl:WidgetProc "Toplevel455" 1
    checkbutton $site_3_0.che69 \
        -command {} -text BMP -variable BMPL1L2 
    vTcl:DefineAlias "$site_3_0.che69" "Checkbutton455_5" vTcl:WidgetProc "Toplevel455" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd69 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd69" "Frame35" vTcl:WidgetProc "Toplevel455" 1
    set site_3_0 $top.cpd69
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$Calibp1p2"=="1"} {
    $widget(Checkbutton455_6) configure -state normal
    } else {
    $widget(Checkbutton455_6) configure -state disable
    set BMPp1p2 "0"
    }} \
        -padx 1 -text {Normalized Eigenvalues (p1, p2)} -variable Calibp1p2 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton83" vTcl:WidgetProc "Toplevel455" 1
    checkbutton $site_3_0.che69 \
        -command {} -text BMP -variable BMPp1p2 
    vTcl:DefineAlias "$site_3_0.che69" "Checkbutton455_6" vTcl:WidgetProc "Toplevel455" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra76 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame47" vTcl:WidgetProc "Toplevel455" 1
    set site_3_0 $top.fra76
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel455" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label34" vTcl:WidgetProc "Toplevel455" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinCalibL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel455" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd72 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd72" "Frame49" vTcl:WidgetProc "Toplevel455" 1
    set site_4_0 $site_3_0.cpd72
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label35" vTcl:WidgetProc "Toplevel455" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinCalibC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel455" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {global NwinCalibL NwinCalibC Calib12 CalibL1L2 Calibp1p2 BMPmodCalib12 BMPmodCalib12b BMPphaCalib12 BMPL1L2 BMPp1p2

set NwinCalibL "7"
set NwinCalibC "7"
set Calib12 "1"
set CalibL1L2 "1"
set Calibp1p2 "1"
set BMPmodCalib12 "1"
set BMPmodCalib12b "1"
set BMPphaCalib12 "1"
set BMPL1L2 "1"
set BMPp1p2 "1"
$widget(Checkbutton455_2) configure -state normal
$widget(Checkbutton455_3) configure -state normal
$widget(Checkbutton455_4) configure -state normal
$widget(Checkbutton455_5) configure -state normal
$widget(Checkbutton455_6) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button104" vTcl:WidgetProc "Toplevel455" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {global NwinCalibL NwinCalibC Calib12 CalibL1L2 Calibp1p2 BMPmodCalib12 BMPmodCalib12b BMPphaCalib12 BMPL1L2 BMPp1p2

set NwinCalibL "?"
set NwinCalibC "?"
set Calib12 "0"
set CalibL1L2 "0"
set Calibp1p2 "0"
set BMPmodCalib12 "0"
set BMPmodCalib12b "0"
set BMPphaCalib12 "0"
set BMPL1L2 "0"
set BMPp1p2 "0"
$widget(Checkbutton455_2) configure -state disable
$widget(Checkbutton455_3) configure -state disable
$widget(Checkbutton455_4) configure -state disable
$widget(Checkbutton455_5) configure -state disable
$widget(Checkbutton455_6) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel455" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra77 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra77" "Frame20" vTcl:WidgetProc "Toplevel455" 1
    set site_3_0 $top.fra77
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global CalibDirInput CalibDirOutput CalibOutputDir CalibOutputSubDir NwinCalibL NwinCalibC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global BMPDirInput OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global NwinCalibL NwinCalibC Calib12 CalibL1L2 Calibp1p2 BMPmodCalib12 BMPmodCalib12b BMPphaCalib12 BMPL1L2 BMPp1p2

if {$OpenDirFile == 0} {

set CalibDirOutput $CalibOutputDir
if {$CalibOutputSubDir != ""} {append CalibDirOutput "/$CalibOutputSubDir"}

    #####################################################################
    #Create Directory
    set CalibDirOutput [PSPCreateDirectoryMask $CalibDirOutput $CalibOutputDir $CalibDirInput]
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
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinCalibL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinCalibC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {

    if {$Calib12 == 1} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CalibDirOutput/CorrelationHVVH.bin"
        set MaskCmd ""
        set MaskFile "$CalibDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/calibration/calibration_corr_HVVH.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CalibDirInput\x22 -od \x22$CalibDirOutput\x22 -nwr $NwinCalibL -nwc $NwinCalibC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calibration/calibration_corr_HVVH.exe -id \x22$CalibDirInput\x22 -od \x22$CalibDirOutput\x22 -nwr $NwinCalibL -nwc $NwinCalibC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CalibDirOutput/calib_corr_HVVH.bin" $FinalNlig $FinalNcol 6
        if {"$BMPmodCalib12"=="1"} {
            set BMPDirInput $CalibDirOutput
            set BMPFileInput "$CalibDirOutput/calib_corr_HVVH.bin"
            set BMPFileOutput "$CalibDirOutput/calib_corr_HVVH_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod gray $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$BMPmodCalib12b"=="1"} {
            set BMPDirInput $CalibDirOutput
            set BMPFileInput "$CalibDirOutput/calib_corr_HVVH.bin"
            set BMPFileOutput "$CalibDirOutput/calib_corr_HVVH_mod2.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod gray $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0.8 1
            }
        if {"$BMPphaCalib12"=="1"} {
            set BMPDirInput $CalibDirOutput
            set BMPFileInput "$CalibDirOutput/calib_corr_HVVH.bin"
            set BMPFileOutput "$CalibDirOutput/calib_corr_HVVH_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }
    set config "false"
    if {$CalibL1L2 == 1} { set config "true" }
    if {$Calibp1p2 == 1} { set config "true" }
    if {$config =="true"} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$CalibDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/calibration/calibration_decomp_HVVH.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CalibDirInput\x22 -od \x22$CalibDirOutput\x22 -nwr $NwinCalibL -nwc $NwinCalibC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $CalibL1L2 -fl2 $Calibp1p2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calibration/calibration_decomp_HVVH.exe -id \x22$CalibDirInput\x22 -od \x22$CalibDirOutput\x22 -nwr $NwinCalibL -nwc $NwinCalibC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $CalibL1L2 -fl2 $Calibp1p2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$CalibL1L2 == 1} {
            EnviWriteConfig "$CalibDirOutput/calib_HVVH_l1.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$CalibDirOutput/calib_HVVH_l2.bin" $FinalNlig $FinalNcol 4
            if {$BMPL1L2 == 1} {
                set BMPDirInput $CalibDirOutput
                set BMPFileInput "$CalibDirOutput/calib_HVVH_l1.bin"
                set BMPFileOutput "$CalibDirOutput/calib_HVVH_l1_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                set BMPDirInput $CalibDirOutput
                set BMPFileInput "$CalibDirOutput/calib_HVVH_l2.bin"
                set BMPFileOutput "$CalibDirOutput/calib_HVVH_l2_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                }
            }
        if {$Calibp1p2 == 1} {
            EnviWriteConfig "$CalibDirOutput/calib_HVVH_p1.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$CalibDirOutput/calib_HVVH_p2.bin" $FinalNlig $FinalNcol 4
            if {$BMPL1L2 == 1} {
                set BMPDirInput $CalibDirOutput
                set BMPFileInput "$CalibDirOutput/calib_HVVH_p1.bin"
                set BMPFileOutput "$CalibDirOutput/calib_HVVH_p1.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
                set BMPDirInput $CalibDirOutput
                set BMPFileInput "$CalibDirOutput/calib_HVVH_p2.bin"
                set BMPFileOutput "$CalibDirOutput/calib_HVVH_p2.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
                }
            }
        }
    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel455); TextEditorRunTrace "Close Window Calibration : Data Quality Check" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel455" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CalibrationQualityCheck.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel455" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel455); TextEditorRunTrace "Close Window Calibration : Data Quality Check" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel455" 1
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
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra68 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra77 \
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
Window show .top455

main $argc $argv
