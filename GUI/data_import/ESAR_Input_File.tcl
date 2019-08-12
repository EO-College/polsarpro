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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images ESAR.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

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
    set base .top226
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab66 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd79
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
    namespace eval ::widgets::$site_6_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd80
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
    namespace eval ::widgets::$site_6_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd116 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd117 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd122 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra23
    namespace eval ::widgets::$site_3_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra39
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent41 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent43 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra48 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra48
    namespace eval ::widgets::$site_4_0.che53 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
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
            vTclWindow.top226
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

proc vTclWindow.top226 {base} {
    if {$base == ""} {
        set base .top226
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
    wm title $top "ESAR Input Data File"
    vTcl:DefineAlias "$top" "Toplevel226" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
        -image [vTcl:image:get_image [file join . GUI Images ESAR.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel226" 1
    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel226" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel226" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ESARDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel226" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel226" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel226" 1
    pack $site_6_0.cpd114 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd80" "Frame2" vTcl:WidgetProc "Toplevel226" 1
    set site_3_0 $top.cpd80
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel226" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputHH 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel226" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel226" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd119 \
        \
        -command {global FileName ESARDirInput FileInputHH

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $ESARDirInput $types "HH INPUT FILE (s11)"
set FileInputHH $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button21" vTcl:WidgetProc "Toplevel226" 1
    bindtags $site_6_0.cpd119 "$site_6_0.cpd119 Button $top all _vTclBalloon"
    bind $site_6_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd119 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd116 \
        -ipad 0 -text {Input Data File ( s12 )} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame8" vTcl:WidgetProc "Toplevel226" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputHV 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel226" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel226" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
        \
        -command {global FileName ESARDirInput FileInputHV

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $ESARDirInput $types "HV INPUT FILE (s12)"
set FileInputHV $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd120" "Button22" vTcl:WidgetProc "Toplevel226" 1
    bindtags $site_6_0.cpd120 "$site_6_0.cpd120 Button $top all _vTclBalloon"
    bind $site_6_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd120 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd117 \
        -ipad 0 -text {Input Data File ( s21 )} 
    vTcl:DefineAlias "$site_3_0.cpd117" "TitleFrame9" vTcl:WidgetProc "Toplevel226" 1
    bind $site_3_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputVH 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel226" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel226" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
        \
        -command {global FileName ESARDirInput FileInputVH

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $ESARDirInput $types "VH INPUT FILE (s21)"
set FileInputVH $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button23" vTcl:WidgetProc "Toplevel226" 1
    bindtags $site_6_0.cpd121 "$site_6_0.cpd121 Button $top all _vTclBalloon"
    bind $site_6_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd121 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd118 \
        -ipad 0 -text {Input Data File ( s22 )} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame10" vTcl:WidgetProc "Toplevel226" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputVV 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh10" vTcl:WidgetProc "Toplevel226" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel226" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd122 \
        \
        -command {global FileName ESARDirInput FileInputVV

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $ESARDirInput $types "VV INPUT FILE (s22)"
set FileInputVV $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd122" "Button40" vTcl:WidgetProc "Toplevel226" 1
    bindtags $site_6_0.cpd122 "$site_6_0.cpd122 Button $top all _vTclBalloon"
    bind $site_6_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd122 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd116 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd117 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit66 \
        -ipad 0 -text {ESAR Data Format} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel226" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.rad67 \
        -text {SLC Slant Range ( RGI )} -value RGI -variable ESARDataFormat 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel226" 1
    radiobutton $site_4_0.cpd68 \
        -text {SLC Geocoded Ground Range ( GTC )} -value GTC \
        -variable ESARDataFormat 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel226" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra23 \
        -borderwidth 2 -relief groove -height 76 -width 125 
    vTcl:DefineAlias "$top.fra23" "Frame65" vTcl:WidgetProc "Toplevel226" 1
    set site_3_0 $top.fra23
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame107" vTcl:WidgetProc "Toplevel226" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label226_1" vTcl:WidgetProc "Toplevel226" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry226_1" vTcl:WidgetProc "Toplevel226" 1
    label $site_4_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab42" "Label226_2" vTcl:WidgetProc "Toplevel226" 1
    entry $site_4_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent43" "Entry226_2" vTcl:WidgetProc "Toplevel226" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent41 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.lab42 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent43 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_3_0.fra48 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra48" "Frame108" vTcl:WidgetProc "Toplevel226" 1
    set site_4_0 $site_3_0.fra48
    checkbutton $site_4_0.che53 \
        \
        -command {global EsarHeader NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize

if {"$EsarHeader" == "1"} {
$widget(Label226_1) configure -state disable
$widget(Entry226_1) configure -state disable
$widget(Label226_2) configure -state disable
$widget(Entry226_2) configure -state disable
set NligFullSize ""
set NcolFullSize ""
set NligInit ""
set NligEnd ""
set NcolInit ""
set NcolEnd ""
}
if {"$EsarHeader" == "0"} {
$widget(Label226_1) configure -state normal
$widget(Entry226_1) configure -state normal
$widget(Label226_2) configure -state normal
$widget(Entry226_2) configure -state normal
set NligFullSize "?"
set NcolFullSize "?"
set NligInit "?"
set NligEnd "?"
set NcolInit "?"
set NcolEnd "?"
}} \
        -text {ESAR Data with Header} -variable EsarHeader 
    vTcl:DefineAlias "$site_4_0.che53" "Checkbutton146" vTcl:WidgetProc "Toplevel226" 1
    pack $site_4_0.che53 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side bottom 
    pack $site_3_0.fra48 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    checkbutton $top.cpd75 \
        -text {Convert Input IEEE binary Format (LE<->BE)} \
        -variable IEEEFormat 
    vTcl:DefineAlias "$top.cpd75" "Checkbutton147" vTcl:WidgetProc "Toplevel226" 1
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel226" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ESARDirOutput ESARFileInputFlag OpenDirFile
global IEEEFormat FileInputHH FileInputHV FileInputVH FileInputVV
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPEsarConfig ESARDataFormat
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set ESARFileInputFlag 0
set ESARFileFlag 0
if {$FileInputHH != ""} {incr ESARFileFlag}
if {$FileInputHV != ""} {incr ESARFileFlag}
if {$FileInputVH != ""} {incr ESARFileFlag}
if {$FileInputVV != ""} {incr ESARFileFlag}
if {$ESARFileFlag == 4} {set ESARFileInputFlag 1}

if {$ESARFileInputFlag == 1} {
    set TestVarError "ok"
    if {$EsarHeader == 0} {
        set TestVarName(0) "Initial Number of Rows"; set TestVarType(0) "int"; set TestVarValue(0) $NligFullSize; set TestVarMin(0) "0"; set TestVarMax(0) ""
        set TestVarName(1) "Initial Number of Cols"; set TestVarType(1) "int"; set TestVarValue(1) $NcolFullSize; set TestVarMin(1) "0"; set TestVarMax(1) ""
        TestVar 2
        }
    if {$TestVarError == "ok"} {
        if {$EsarHeader == 1} {
            TextEditorRunTrace "Process The Function Soft/bin/data_import/esar_header.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$FileInputHH\x22 -iee $IEEEFormat -of \x22$TMPEsarConfig\x22" "k"
            set f [ open "| Soft/bin/data_import/esar_header.exe -if \x22$FileInputHH\x22 -iee $IEEEFormat -of \x22$TMPEsarConfig\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            set NligFullSize 0
            set NcolFullSize 0
            set NligInit 0
            set NligEnd 0
            set NcolInit 0
            set NcolEnd 0
            set NligFullSizeInput 0
            set NcolFullSizeInput 0
            set ConfigFile $TMPEsarConfig
            set ErrorMessage ""
            if [file exists $ConfigFile] {
                set f [open $ConfigFile r]
                gets $f tmp
                gets $f NligFullSize
                gets $f tmp
                gets $f tmp
                gets $f NcolFullSize
                close $f
                if {$ESARDataFormat == "GTC"} { set NcolFullSize [expr $NcolFullSize / 2] }
                set NligInit 1
                set NligEnd $NligFullSize
                set NcolInit 1
                set NcolEnd $NcolFullSize
                set NligFullSizeInput $NligFullSize
                set NcolFullSizeInput $NcolFullSize
                set ErrorMessage ""
                } else {
                set ErrorMessage "NO CONFIG FILE !"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } else {
            set NligInit 1
            set NligEnd $NligFullSize
            set NcolInit 1
            set NcolEnd $NcolFullSize
            set NligFullSizeInput $NligFullSize
            set NcolFullSizeInput $NcolFullSize
            }
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel226); TextEditorRunTrace "Close Window ESAR Input File" "b"
        }
    } else {
    set ESARFileInputFlag 0
    set ErrorMessage "ENTER THE ESAR DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel226" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ESAR_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel226" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel226); TextEditorRunTrace "Close Window ESAR Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel226" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
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
    pack $top.lab66 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra23 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra71 \
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
Window show .top226

main $argc $argv
