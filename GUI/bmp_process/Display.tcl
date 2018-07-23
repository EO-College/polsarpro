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
    set base .top71
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit70 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit70 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab32 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab72 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.lab32 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab74 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd76 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.fra78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra78
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd81
    namespace eval ::widgets::$site_6_0.lab32 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.but73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd69 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.fra78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra78
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd81
    namespace eval ::widgets::$site_6_0.lab32 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.but73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$base.fra31 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra31
    namespace eval ::widgets::$site_3_0.but69 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but32 {
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
            vTclWindow.top71
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
    wm geometry $top 200x200+75+75; update
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

proc vTclWindow.top71 {base} {
    if {$base == ""} {
        set base .top71
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
    wm geometry $top 130x240+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Display"
    vTcl:DefineAlias "$top" "Toplevel71" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit70 \
        -ipad 0 -text Screen 
    vTcl:DefineAlias "$top.tit70" "TitleFrame1" vTcl:WidgetProc "Toplevel71" 1
    bind $top.tit70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit70 getframe]
    frame $site_4_0.cpd71 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame162" vTcl:WidgetProc "Toplevel71" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab32 \
        -relief sunken -text R -width 2 
    vTcl:DefineAlias "$site_5_0.lab32" "Label270" vTcl:WidgetProc "Toplevel71" 1
    label $site_5_0.lab72 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable HeightBMPNew -width 4 
    vTcl:DefineAlias "$site_5_0.lab72" "Label1" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.lab72 "$site_5_0.lab72 Label $top all _vTclBalloon"
    bind $site_5_0.lab72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display Screen Height}
    }
    button $site_5_0.but73 \
        \
        -command {global HeightBMPNew BMPImageOpen WarningMessage WarningMessage2 

if { $BMPImageOpen == 1 } {
    #####################################################################
        set WarningMessage "BMP IMAGE MUST BE CLOSED"
        set WarningMessage2 "BEFORE CHANGING SCREEN SIZE"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        } else {
        set HeightTMP [expr $HeightBMPNew +100]
        set HeightMax [lindex [wm maxsize $widget(Toplevel71)] 0 ]
        if {$HeightTMP < $HeightMax } {
            set HeightBMPNew $HeightTMP
            }
        }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but73" "Button541" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but73 "$site_5_0.but73 Button $top all _vTclBalloon"
    bind $site_5_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Up}
    }
    button $site_5_0.but74 \
        \
        -command {global HeightBMPNew BMPImageOpen WarningMessage WarningMessage2 

if { $BMPImageOpen == 1 } {
    #####################################################################
        set WarningMessage "BMP IMAGE MUST BE CLOSED"
        set WarningMessage2 "BEFORE CHANGING SCREEN SIZE"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        } else {
        set HeightTMP [expr $HeightBMPNew -100]
        if {$HeightTMP > 0 } {
            set HeightBMPNew $HeightTMP
            }
        }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but74" "Button557" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but74 "$site_5_0.but74 Button $top all _vTclBalloon"
    bind $site_5_0.but74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Down}
    }
    pack $site_5_0.lab32 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame392" vTcl:WidgetProc "Toplevel71" 1
    set site_5_0 $site_4_0.cpd73
    label $site_5_0.lab32 \
        -relief sunken -text C -width 2 
    vTcl:DefineAlias "$site_5_0.lab32" "Label423" vTcl:WidgetProc "Toplevel71" 1
    label $site_5_0.lab74 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable WidthBMPNew -width 4 
    vTcl:DefineAlias "$site_5_0.lab74" "Label2" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.lab74 "$site_5_0.lab74 Label $top all _vTclBalloon"
    bind $site_5_0.lab74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display Screen Width}
    }
    button $site_5_0.but73 \
        \
        -command {global WidthBMPNew BMPImageOpen WarningMessage WarningMessage2 

if { $BMPImageOpen == 1 } {
    #####################################################################
        set WarningMessage "BMP IMAGE MUST BE CLOSED"
        set WarningMessage2 "BEFORE CHANGING SCREEN SIZE"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        } else {
            set WidthTMP [expr $WidthBMPNew +100]
            set WidthMax [lindex [wm maxsize $widget(Toplevel71)] 0 ]
            if {$WidthTMP < $WidthMax } {
            set WidthBMPNew $WidthTMP
            }
        }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but73" "Button558" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but73 "$site_5_0.but73 Button $top all _vTclBalloon"
    bind $site_5_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Up}
    }
    button $site_5_0.but74 \
        \
        -command {global WidthBMPNew BMPImageOpen WarningMessage WarningMessage2 

if { $BMPImageOpen == 1 } {
    #####################################################################
        set WarningMessage "BMP IMAGE MUST BE CLOSED"
        set WarningMessage2 "BEFORE CHANGING SCREEN SIZE"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        } else {
            set WidthTMP [expr $WidthBMPNew -100]
            if {$WidthTMP > 0 } {
            set WidthBMPNew $WidthTMP
            }
        }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but74" "Button559" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but74 "$site_5_0.but74 Button $top all _vTclBalloon"
    bind $site_5_0.but74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Down}
    }
    pack $site_5_0.lab32 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd76 \
        -ipad 0 -text Lens 
    vTcl:DefineAlias "$top.cpd76" "TitleFrame2" vTcl:WidgetProc "Toplevel71" 1
    bind $top.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd76 getframe]
    frame $site_4_0.cpd71 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame163" vTcl:WidgetProc "Toplevel71" 1
    set site_5_0 $site_4_0.cpd71
    frame $site_5_0.fra78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra78" "Frame1" vTcl:WidgetProc "Toplevel71" 1
    set site_6_0 $site_5_0.fra78
    label $site_6_0.cpd79 \
        -relief sunken -text R -width 2 
    vTcl:DefineAlias "$site_6_0.cpd79" "Label271" vTcl:WidgetProc "Toplevel71" 1
    label $site_6_0.cpd80 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SizeLens -width 4 
    vTcl:DefineAlias "$site_6_0.cpd80" "Label3" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_6_0.cpd80 "$site_6_0.cpd80 Label $top all _vTclBalloon"
    bind $site_6_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display Screen Height}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd81 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd81" "Frame394" vTcl:WidgetProc "Toplevel71" 1
    set site_6_0 $site_5_0.cpd81
    label $site_6_0.lab32 \
        -relief sunken -text C -width 2 
    vTcl:DefineAlias "$site_6_0.lab32" "Label425" vTcl:WidgetProc "Toplevel71" 1
    label $site_6_0.lab74 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SizeLens -width 4 
    vTcl:DefineAlias "$site_6_0.lab74" "Label5" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_6_0.lab74 "$site_6_0.lab74 Label $top all _vTclBalloon"
    bind $site_6_0.lab74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display Screen Width}
    }
    pack $site_6_0.lab32 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame393" vTcl:WidgetProc "Toplevel71" 1
    set site_5_0 $site_4_0.cpd73
    button $site_5_0.but73 \
        \
        -command {global BMPImageLens BMPImageOpen BMPLensFlag ZoomLensBMP
global RectLens SizeRect SizeLens RectLensCenter
global BMPWidthSource BMPHeightSource LensX1 LensY1
global MouseActiveButton

if {"$BMPImageOpen" == "1"} {
    if {"$MouseActiveButton" == "Lens"} {

        $widget(CANVASBMPLENS) dtag $RectLensCenter
        $widget(CANVASBMPLENS) create image 0 0 -anchor nw -image BMPImageLens

        if {$BMPWidthSource <= $BMPHeightSource} {
            set SizeMax $BMPWidthSource
            } else {
            set SizeMax $BMPHeightSource
            } 
        set SizeLensTMP [expr $SizeLens + 50]
        if {$SizeLensTMP <= $SizeMax } { set SizeLens $SizeLensTMP }       
   
        set Num1 ""
        set Num2 ""
        set Num1 [string index $ZoomLensBMP 0]
        set Num2 [string index $ZoomLensBMP 1]
        if {$Num2 == ":"} {
            set Num $Num1
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 2]
            set Den2 [string index $ZoomLensBMP 3]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            } else {
            set Num [expr 10*$Num1 + $Num2]
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 3]
            set Den2 [string index $ZoomLensBMP 4]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            }

        if {$Num >= $Den} {
            set BMPZoomLens $Num
            if {$BMPZoomLens > 99} {
                #warning
                } else {
                #process
                set ZoomLensBMP "$BMPZoomLens:1"
                set SizeRect [expr round($SizeLens / $BMPZoomLens)]
                }
            } else {
            set BMPSampleLens $Den
            set ZoomLensBMP "1:$BMPSampleLens"
            set SizeRect [expr round($SizeLens * $BMPSampleLens)]
            }
        set RectLensX1 [expr [lindex $RectLensCenter 0] - round($SizeRect / 2 / $BMPSampleSource)]
        set RectLensY1 [expr [lindex $RectLensCenter 1] - round($SizeRect / 2 / $BMPSampleSource)]
        set RectLensX2 [expr $RectLensX1 + round($SizeRect / $BMPSampleSource)]
        set RectLensY2 [expr $RectLensY1 + round($SizeRect / $BMPSampleSource)]

        set BMPTitleLens "Zoom "
        append BMPTitleLens $ZoomLensBMP
        wm title $widget(VIEWLENS) [file tail $BMPTitleLens]

        set config "true"
        if { $RectLensX1 < 0 } {set config "false"}
        if { $RectLensX1 > $BMPWidthSource } {set config "false"}
        if { $RectLensX2 < 0 } {set config "false"}
        if { $RectLensX2 > $BMPWidthSource } {set config "false"}
        if { $RectLensY1 < 0 } {set config "false"}
        if { $RectLensY1 > $BMPHeightSource } {set config "false"}
        if { $RectLensY2 < 0 } {set config "false"}
        if { $RectLensY2 > $BMPHeightSource } {set config "false"}
    
        if { "$config" == "true" } {
            set RectLens [$widget(CANVASBMPLENS) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
            $widget(CANVASBMPLENS) addtag RectLensCenter withtag $RectLens
    
            set LensX1 [expr round($RectLensX1*$BMPSampleSource)]
            set LensY1 [expr round($RectLensY1*$BMPSampleSource)]
        
        set Num1 ""
        set Num2 ""
        set Num1 [string index $ZoomLensBMP 0]
        set Num2 [string index $ZoomLensBMP 1]
        if {$Num2 == ":"} {
            set Num $Num1
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 2]
            set Den2 [string index $ZoomLensBMP 3]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            } else {
            set Num [expr 10*$Num1 + $Num2]
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 3]
            set Den2 [string index $ZoomLensBMP 4]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            }

            if {$Den >= $Num} {
                set BMPSampleLens $Den
                set LensSize [expr round($SizeLens * $BMPSampleLens)]
                set LensX2 [expr $LensX1 + $LensSize]
                set LensY2 [expr $LensY1 + $LensSize]
                BMPLens blank
                BMPLens copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2 -subsample $BMPSampleLens $BMPSampleLens
                set LensSize [expr round($LensSize / $BMPSampleLens)]
                }
            if {$Den < $Num} {
                set BMPZoomLens $Num
                set LensSize [expr round($SizeLens / $BMPZoomLens)]
                set LensX2 [expr $LensX1 + $LensSize]
                set LensY2 [expr $LensY1 + $LensSize]
                BMPLens blank
                BMPLens copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2 -zoom $BMPZoomLens $BMPZoomLens
                set LensSize [expr round($LensSize * $BMPZoomLens)]
                }
            $widget(CANVASLENS) configure -width $LensSize -height $LensSize
            $widget(CANVASLENS) itemconfigure current -image BMPLens
            }
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but73" "Button561" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but73 "$site_5_0.but73 Button $top all _vTclBalloon"
    bind $site_5_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Up}
    }
    button $site_5_0.but74 \
        \
        -command {global BMPImageLens BMPImageOpen BMPLensFlag ZoomLensBMP
global RectLens SizeRect SizeLens RectLensCenter
global BMPWidthSource BMPHeightSource LensX1 LensY1
global MouseActiveButton

if {"$BMPImageOpen" == "1"} {
    if {"$MouseActiveButton" == "Lens"} {

        $widget(CANVASBMPLENS) dtag $RectLensCenter
        $widget(CANVASBMPLENS) create image 0 0 -anchor nw -image BMPImageLens

        set SizeLensTMP [expr $SizeLens - 50]
        if {$SizeLensTMP > 199 } { set SizeLens $SizeLensTMP }
                        
        set Num1 ""
        set Num2 ""
        set Num1 [string index $ZoomLensBMP 0]
        set Num2 [string index $ZoomLensBMP 1]
        if {$Num2 == ":"} {
            set Num $Num1
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 2]
            set Den2 [string index $ZoomLensBMP 3]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            } else {
            set Num [expr 10*$Num1 + $Num2]
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 3]
            set Den2 [string index $ZoomLensBMP 4]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            }

        if {$Den >= $Num} {
            set BMPSampleLens $Den
            if {$BMPSampleLens > 99} {
                #warning
                } else {
                #process
                set ZoomLensBMP "1:$BMPSampleLens"
                set SizeRect [expr round($SizeLens * $BMPSampleLens)]                
                }
            } else {
            set BMPZoomLens $Num
            set ZoomLensBMP "$BMPZoomLens:1"
            set SizeRect [expr round($SizeLens / $BMPZoomLens)]            
            }
        set RectLensX1 [expr [lindex $RectLensCenter 0] - round($SizeRect / 2 / $BMPSampleSource)]
        set RectLensY1 [expr [lindex $RectLensCenter 1] - round($SizeRect / 2 / $BMPSampleSource)]
        set RectLensX2 [expr $RectLensX1 + round($SizeRect / $BMPSampleSource)]
        set RectLensY2 [expr $RectLensY1 + round($SizeRect / $BMPSampleSource)]

        set BMPTitleLens "Zoom "
        append BMPTitleLens $ZoomLensBMP
        wm title $widget(VIEWLENS) [file tail $BMPTitleLens]

        set config "true"
        if { $RectLensX1 < 0 } {set config "false"}
        if { $RectLensX1 > $BMPWidthSource } {set config "false"}
        if { $RectLensX2 < 0 } {set config "false"}
        if { $RectLensX2 > $BMPWidthSource } {set config "false"}
        if { $RectLensY1 < 0 } {set config "false"}
        if { $RectLensY1 > $BMPHeightSource } {set config "false"}
        if { $RectLensY2 < 0 } {set config "false"}
        if { $RectLensY2 > $BMPHeightSource } {set config "false"}
    
        if { "$config" == "true" } {
            set RectLens [$widget(CANVASBMPLENS) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
            $widget(CANVASBMPLENS) addtag RectLensCenter withtag $RectLens
    
            set LensX1 [expr round($RectLensX1*$BMPSampleSource)]
            set LensY1 [expr round($RectLensY1*$BMPSampleSource)]
        
        set Num1 ""
        set Num2 ""
        set Num1 [string index $ZoomLensBMP 0]
        set Num2 [string index $ZoomLensBMP 1]
        if {$Num2 == ":"} {
            set Num $Num1
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 2]
            set Den2 [string index $ZoomLensBMP 3]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            } else {
            set Num [expr 10*$Num1 + $Num2]
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomLensBMP 3]
            set Den2 [string index $ZoomLensBMP 4]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            }

            if {$Den >= $Num} {
                set BMPSampleLens $Den
                set LensSize [expr round($SizeLens * $BMPSampleLens)]
                set LensX2 [expr $LensX1 + $LensSize]
                set LensY2 [expr $LensY1 + $LensSize]
                BMPLens blank
                BMPLens copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2 -subsample $BMPSampleLens $BMPSampleLens
                set LensSize [expr round($LensSize / $BMPSampleLens)]
                }
            if {$Den < $Num} {
                set BMPZoomLens $Num
                set LensSize [expr round($SizeLens / $BMPZoomLens)]
                set LensX2 [expr $LensX1 + $LensSize]
                set LensY2 [expr $LensY1 + $LensSize]
                BMPLens blank
                BMPLens copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2 -zoom $BMPZoomLens $BMPZoomLens
                set LensSize [expr round($LensSize * $BMPZoomLens)]
                }
            $widget(CANVASLENS) configure -width $LensSize -height $LensSize
            $widget(CANVASLENS) itemconfigure current -image BMPLens
            }

        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but74" "Button562" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but74 "$site_5_0.but74 Button $top all _vTclBalloon"
    bind $site_5_0.but74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Down}
    }
    pack $site_5_0.but73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $top.cpd69 \
        -ipad 0 -text Overview 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame3" vTcl:WidgetProc "Toplevel71" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    frame $site_4_0.cpd71 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame164" vTcl:WidgetProc "Toplevel71" 1
    set site_5_0 $site_4_0.cpd71
    frame $site_5_0.fra78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra78" "Frame2" vTcl:WidgetProc "Toplevel71" 1
    set site_6_0 $site_5_0.fra78
    label $site_6_0.cpd79 \
        -relief sunken -text R -width 2 
    vTcl:DefineAlias "$site_6_0.cpd79" "Label272" vTcl:WidgetProc "Toplevel71" 1
    label $site_6_0.cpd80 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SizeBMPOverview -width 4 
    vTcl:DefineAlias "$site_6_0.cpd80" "Label4" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_6_0.cpd80 "$site_6_0.cpd80 Label $top all _vTclBalloon"
    bind $site_6_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display Screen Height}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd81 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd81" "Frame395" vTcl:WidgetProc "Toplevel71" 1
    set site_6_0 $site_5_0.cpd81
    label $site_6_0.lab32 \
        -relief sunken -text C -width 2 
    vTcl:DefineAlias "$site_6_0.lab32" "Label426" vTcl:WidgetProc "Toplevel71" 1
    label $site_6_0.lab74 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SizeBMPOverview -width 4 
    vTcl:DefineAlias "$site_6_0.lab74" "Label6" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_6_0.lab74 "$site_6_0.lab74 Label $top all _vTclBalloon"
    bind $site_6_0.lab74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display Screen Width}
    }
    pack $site_6_0.lab32 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame396" vTcl:WidgetProc "Toplevel71" 1
    set site_5_0 $site_4_0.cpd73
    button $site_5_0.but73 \
        \
        -command {global BMPImageOpen WidthBMP HeightBMP SizeBMPOverview SourceWidth SourceHeight BMPSampleOverview 
global ZoomBMP SizeLensOverview SizeRect SizeOverviewWidth SizeOverviewHeight RectLensCenter RectLens
global LensX1 LensY1 BMPViewFileInput BMPOverview BMPImageOverview
global MouseActiveButton

if {"$BMPImageOpen" == "1"} {
    if {"$MouseActiveButton" == "Overview"} {

        $widget(CANVASOVERVIEW) dtag RectLensCenter
        $widget(CANVASOVERVIEW) create image 0 0 -anchor nw -image BMPOverview

        if {$WidthBMP <= $HeightBMP} {
            set SizeMax $WidthBMP
            } else {
            set SizeMax $HeightBMP
            } 
        set SizeBMPOverviewTMP [expr $SizeBMPOverview + 50]
        if {$SizeBMPOverviewTMP <= $SizeMax } { set SizeBMPOverview $SizeBMPOverviewTMP }       
        
        set Num1 ""
        set Num2 ""
        set Num1 [string index $ZoomBMP 0]
        set Num2 [string index $ZoomBMP 1]
        if {$Num2 == ":"} {
            set Num $Num1
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomBMP 2]
            set Den2 [string index $ZoomBMP 3]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            } else {
            set Num [expr 10*$Num1 + $Num2]
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomBMP 3]
            set Den2 [string index $ZoomBMP 4]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            }
        set BMPZoom $Num
        set SizeLensOverview $SizeBMPOverview
        if {[expr round($SourceWidth * $BMPZoom)] <= $SizeLens} {set SizeLensOverview [expr round($SourceWidth * $BMPZoom)]}
        if {[expr round($SourceHeight * $BMPZoom)] <= $SizeLens} {set SizeLensOverview [expr round($SourceHeight * $BMPZoom)]}
        set SizeRect [expr round($SizeLensOverview / $BMPZoom)]
               
        set RectLensX1 [expr [lindex $RectLensCenter 0] - round($SizeRect / 2 / $BMPSampleOverview)]
        set RectLensY1 [expr [lindex $RectLensCenter 1] - round($SizeRect / 2 / $BMPSampleOverview)]
        set RectLensX2 [expr $RectLensX1 + round($SizeRect / $BMPSampleOverview)]
        set RectLensY2 [expr $RectLensY1 + round($SizeRect / $BMPSampleOverview)]

        set config "true"
        if { $RectLensX1 < 0 } {set config "false"}
        if { $RectLensX1 > $SizeOverviewWidth } {set config "false"}
        if { $RectLensX2 < 0 } {set config "false"}
        if { $RectLensX2 > $SizeOverviewWidth } {set config "false"}
        if { $RectLensY1 < 0 } {set config "false"}
        if { $RectLensY1 > $SizeOverviewHeight } {set config "false"}
        if { $RectLensY2 < 0 } {set config "false"}
        if { $RectLensY2 > $SizeOverviewHeight } {set config "false"}

        if { "$config" == "true" } {
            set RectLens [$widget(CANVASOVERVIEW) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
            $widget(CANVASOVERVIEW) addtag RectLensCenter withtag $RectLens
        
            set LensX1 [expr round($RectLensX1*$BMPSampleOverview)]
            set LensY1 [expr round($RectLensY1*$BMPSampleOverview)]
            set LensX2 [expr $LensX1 + $SizeRect]
            set LensY2 [expr $LensY1 + $SizeRect]
            BMPImageOverview blank
            BMPImageOverview copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2 -zoom $BMPZoom $BMPZoom
            $widget(CANVASBMPOVERVIEW) configure -width $SizeLensOverview -height $SizeLensOverview
            $widget(CANVASBMPOVERVIEW) create image 0 0 -anchor nw -image BMPImageOverview
            catch {wm geometry $widget(VIEWBMPOVERVIEW) {}} 
            wm title $widget(VIEWBMPOVERVIEW) [file tail $BMPViewFileInput]
            }
        }
        
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but73" "Button563" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but73 "$site_5_0.but73 Button $top all _vTclBalloon"
    bind $site_5_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Up}
    }
    button $site_5_0.but74 \
        \
        -command {global BMPImageOpen WidthBMP HeightBMP SizeBMPOverview SourceWidth SourceHeight BMPSampleOverview 
global ZoomBMP SizeLensOverview SizeRect SizeOverviewWidth SizeOverviewHeight RectLensCenter RectLens
global LensX1 LensY1 BMPViewFileInput BMPOverview BMPImageOverview
global MouseActiveButton

if {"$BMPImageOpen" == "1"} {
    if {"$MouseActiveButton" == "Overview"} {

        $widget(CANVASOVERVIEW) dtag RectLensCenter
        $widget(CANVASOVERVIEW) create image 0 0 -anchor nw -image BMPOverview

        if {$WidthBMP <= $HeightBMP} {
            set SizeMax $WidthBMP
            } else {
            set SizeMax $HeightBMP
            } 
        set SizeBMPOverviewTMP [expr $SizeBMPOverview - 50]
        if {$SizeBMPOverviewTMP <= $SizeMax } { set SizeBMPOverview $SizeBMPOverviewTMP }       
        
        set Num1 ""
        set Num2 ""
        set Num1 [string index $ZoomBMP 0]
        set Num2 [string index $ZoomBMP 1]
        if {$Num2 == ":"} {
            set Num $Num1
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomBMP 2]
            set Den2 [string index $ZoomBMP 3]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            } else {
            set Num [expr 10*$Num1 + $Num2]
            set Den1 ""
            set Den2 ""
            set Den1 [string index $ZoomBMP 3]
            set Den2 [string index $ZoomBMP 4]
            if {$Den2 == ""} {
                set Den $Den1
                } else {
                set Den [expr 10*$Den1 + $Den2]
                }
            }
        set BMPZoom $Num
        set SizeLensOverview $SizeBMPOverview
        if {[expr round($SourceWidth * $BMPZoom)] <= $SizeLensOverview} {set SizeLensOverview [expr round($SourceWidth * $BMPZoom)]}
        if {[expr round($SourceHeight * $BMPZoom)] <= $SizeLensOverview} {set SizeLensOverview [expr round($SourceHeight * $BMPZoom)]}
        set SizeRect [expr round($SizeLensOverview / $BMPZoom)]
               
        set RectLensX1 [expr [lindex $RectLensCenter 0] - round($SizeRect / 2 / $BMPSampleOverview)]
        set RectLensY1 [expr [lindex $RectLensCenter 1] - round($SizeRect / 2 / $BMPSampleOverview)]
        set RectLensX2 [expr $RectLensX1 + round($SizeRect / $BMPSampleOverview)]
        set RectLensY2 [expr $RectLensY1 + round($SizeRect / $BMPSampleOverview)]

        set config "true"
        if { $RectLensX1 < 0 } {set config "false"}
        if { $RectLensX1 > $SizeOverviewWidth } {set config "false"}
        if { $RectLensX2 < 0 } {set config "false"}
        if { $RectLensX2 > $SizeOverviewWidth } {set config "false"}
        if { $RectLensY1 < 0 } {set config "false"}
        if { $RectLensY1 > $SizeOverviewHeight } {set config "false"}
        if { $RectLensY2 < 0 } {set config "false"}
        if { $RectLensY2 > $SizeOverviewHeight } {set config "false"}

        if { "$config" == "true" } {
            set RectLens [$widget(CANVASOVERVIEW) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
            $widget(CANVASOVERVIEW) addtag RectLensCenter withtag $RectLens
        
            set LensX1 [expr round($RectLensX1*$BMPSampleOverview)]
            set LensY1 [expr round($RectLensY1*$BMPSampleOverview)]
            set LensX2 [expr $LensX1 + $SizeRect]
            set LensY2 [expr $LensY1 + $SizeRect]
            BMPImageOverview blank
            BMPImageOverview copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2 -zoom $BMPZoom $BMPZoom
            $widget(CANVASBMPOVERVIEW) configure -width $SizeLensOverview -height $SizeLensOverview
            $widget(CANVASBMPOVERVIEW) create image 0 0 -anchor nw -image BMPImageOverview
            catch {wm geometry $widget(VIEWBMPOVERVIEW) {}} 
            wm title $widget(VIEWBMPOVERVIEW) [file tail $BMPViewFileInput]
            }
        }
        
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.but74" "Button564" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_5_0.but74 "$site_5_0.but74 Button $top all _vTclBalloon"
    bind $site_5_0.but74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Size Down}
    }
    pack $site_5_0.but73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra31 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra31" "Frame414" vTcl:WidgetProc "Toplevel71" 1
    set site_3_0 $top.fra31
    button $site_3_0.but69 \
        -background #ffff00 \
        -command {global ViewerName WidthBMP HeightBMP WidthBMPNew HeightBMPNew CONFIGDir

set WidthBMP $WidthBMPNew
set HeightBMP $HeightBMPNew

set f [open "$CONFIGDir/Viewer.txt" w]
puts $f $ViewerName
puts $f "Width"
puts $f $WidthBMP
puts $f "Height"
puts $f $HeightBMP
close $f} \
        -padx 4 -pady 2 -text Save 
    vTcl:DefineAlias "$site_3_0.but69" "Button1" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_3_0.but69 "$site_3_0.but69 Button $top all _vTclBalloon"
    bind $site_3_0.but69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save the Display Configuration}
    }
    button $site_3_0.but32 \
        -background #ffff00 \
        -command {global ViewerName WidthBMP HeightBMP WidthBMPNew HeightBMPNew CONFIGDir

set HeightWidthBMPChange 0
set VarWarning ""
if {$WidthBMPNew != $WidthBMP } {set HeightWidthBMPChange 1}
if {$HeightBMPNew != $HeightBMP } {set HeightWidthBMPChange 1}
if {$HeightWidthBMPChange == 1 } {
    #####################################################################
    set WarningMessage "SCREEN SIZE HAS CHANGED"
    set WarningMessage2 "DO YOU WISH TO SAVE ?"
    set VarWarning ""
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set WidthBMP $WidthBMPNew
        set HeightBMP $HeightBMPNew
        set f [open "$CONFIGDir/Viewer.txt" w]
        puts $f $ViewerName
        puts $f "Width"
        puts $f $WidthBMP
        puts $f "Height"
        puts $f $HeightBMP
        close $f
        } else {
        set WidthBMPNew $WidthBMP
        set HeightBMPNew $HeightBMP
        }
    set HeightWidthBMPChange 0
    ##################################################################### 
    }    
if {"$VarWarning"==""} {
    Window hide $widget(Toplevel71); TextEditorRunTrace "Close Window Display" "b"
    } else {
    if {"$VarWarning"!="cancel"} {Window hide $widget(Toplevel71); TextEditorRunTrace "Close Window Display" "b"}
    }} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but32" "Button67" vTcl:WidgetProc "Toplevel71" 1
    bindtags $site_3_0.but32 "$site_3_0.but32 Button $top all _vTclBalloon"
    bind $site_3_0.but32 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but32 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.tit70 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd76 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra31 \
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
Window show .top71

main $argc $argv
