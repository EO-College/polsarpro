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

        {{[file join . GUI Images SIRC.gif]} {user image} user {}}
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
    set base .top222
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab49 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd78
    namespace eval ::widgets::$site_3_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra39
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent41 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd85
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.men90 {
        array set save {-_tooltip 1 -background 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.men90.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd79
    namespace eval ::widgets::$site_3_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra39
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd85
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd86
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra57 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra57
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
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
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
            vTclWindow.top222
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

proc vTclWindow.top222 {base} {
    if {$base == ""} {
        set base .top222
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
    wm geometry $top 500x380+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "SIRC Input Data File"
    vTcl:DefineAlias "$top" "Toplevel222" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab49 \
        -image [vTcl:image:get_image [file join . GUI Images SIRC.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab49" "Label73" vTcl:WidgetProc "Toplevel222" 1
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel222" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel222" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SIRCDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel222" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel222" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel222" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame5" vTcl:WidgetProc "Toplevel222" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable SIRCDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel222" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel222" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global DirName DataDir SIRCDirOutput
global VarWarning WarningMessage WarningMessage2

set SIRCOutputDirTmp $SIRCDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set SIRCDirOutput $DirName
        } else {
        set SIRCDirOutput $SIRCOutputDirTmp
        }
    } else {
    set SIRCDirOutput $SIRCOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button2" vTcl:WidgetProc "Toplevel222" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd78 \
        -borderwidth 2 -relief groove -height 76 -width 200 
    vTcl:DefineAlias "$top.cpd78" "Frame2" vTcl:WidgetProc "Toplevel222" 1
    set site_3_0 $top.cpd78
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame109" vTcl:WidgetProc "Toplevel222" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {SIRC Processing Run Number} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label224" vTcl:WidgetProc "Toplevel222" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SIRCRunNumber -width 10 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry222_5" vTcl:WidgetProc "Toplevel222" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent41 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side bottom 
    frame $top.cpd85 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd85" "Frame21" vTcl:WidgetProc "Toplevel222" 1
    set site_3_0 $top.cpd85
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global SIRCDirInput SIRCDirOutput SIRCFileInputFlag
global SIRCRunNumber SIRCDataFormat SIRCFormat SIRCFileType SIRCPolMode SIRCDataFormatPol
global SIRCfgdcFile SIRCleaderFile SIRCtrailerFile SIRCimageFile FileInputSIRC
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPSIRCConfig OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "true"
if {$SIRCRunNumber == "?????"} { set config "false" }
if {$SIRCRunNumber == ""} { set config "false" }

if {$config == "true"} {

#####################################################################
#Create Directory
set SIRCDirOutput [PSPCreateDirectoryMask $SIRCDirOutput $SIRCDirOutput $SIRCDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPSIRCConfig

TextEditorRunTrace "Process The Function Soft/data_import/sirc_header.exe" "k"
TextEditorRunTrace "Arguments: -id \x22$SIRCDirInput\x22 -od \x22$SIRCDirOutput\x22 -pro $SIRCRunNumber -ocf \x22$TMPSIRCConfig\x22" "k"
set f [ open "| Soft/data_import/sirc_header.exe -id \x22$SIRCDirInput\x22 -od \x22$SIRCDirOutput\x22 -pro $SIRCRunNumber -ocf \x22$TMPSIRCConfig\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError

set SIRCFileInputFlag 0
set datalevelerror 0
    
set NligFullSize 0
set NcolFullSize 0
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set NligFullSizeInput 0
set NcolFullSizeInput 0
set ConfigFile $TMPSIRCConfig
set ErrorMessage ""
WaitUntilCreated $ConfigFile
if [file exists $ConfigFile] {
    set f [open $ConfigFile r]
    gets $f tmp
    gets $f NligFullSize
    gets $f tmp
    gets $f tmp
    gets $f NcolFullSize
    gets $f tmp
    gets $f tmp
    gets $f SIRCDataFormat
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f SIRCFormat
    gets $f tmp
    gets $f tmp
    gets $f SIRCFileType
    gets $f tmp
    gets $f tmp
    gets $f SIRCPolMode
    close $f
    if {$SIRCDataFormatPol == "quad"} {
        if {$SIRCDataFormat == 2 } { set datalevelerror 0 }
        if {$SIRCDataFormat == 3 } { set datalevelerror 1 }
        if {$SIRCDataFormat == 4 } { set datalevelerror 0 }
        if {$SIRCDataFormat == 6 } { set datalevelerror 1 }
        }
    if {$SIRCDataFormatPol == "dual"} {
        if {$SIRCDataFormat == 2 } { set datalevelerror 1 }
        if {$SIRCDataFormat == 3 } { set datalevelerror 0 }
        if {$SIRCDataFormat == 4 } { set datalevelerror 1 }
        if {$SIRCDataFormat == 6 } { set datalevelerror 0 }
        }
    if {$datalevelerror == 0} {
        set TestVarName(0) "Initial Number of Rows"; set TestVarType(0) "int"; set TestVarValue(0) $NligFullSize; set TestVarMin(0) "0"; set TestVarMax(0) ""
        set TestVarName(1) "Initial Number of Cols"; set TestVarType(1) "int"; set TestVarValue(1) $NcolFullSize; set TestVarMin(1) "0"; set TestVarMax(1) ""
        TestVar 2
        if {$TestVarError == "ok"} {
            set SIRCFileInputFlag 1
            if {$SIRCDataFormat == 2 } { set SIRCDataFormat "MLCquad" }
            if {$SIRCDataFormat == 3 } { set SIRCDataFormat "MLCdual" }
            if {$SIRCDataFormat == 4 } { set SIRCDataFormat "SLCquad" }
            if {$SIRCDataFormat == 6 } { set SIRCDataFormat "SLCdual" }
            set NligInit 1
            set NligEnd $NligFullSize
            set NcolInit 1
            set NcolEnd $NcolFullSize
            set NligFullSizeInput $NligFullSize
            set NcolFullSizeInput $NcolFullSize
            set SIRCfgdcFile0 "$SIRCDirInput/pr"; append SIRCfgdcFile0 $SIRCRunNumber; append SIRCfgdcFile0 ".fgdc"
            set SIRCfgdcFile "$SIRCDirOutput/pr"; append SIRCfgdcFile $SIRCRunNumber; append SIRCfgdcFile ".fgdc.txt"
            CopyFile $SIRCfgdcFile0 $SIRCfgdcFile
            set SIRCleaderFile "$SIRCDirOutput/pr"; append SIRCleaderFile $SIRCRunNumber; append SIRCleaderFile "_leader_ceos.txt"
            set SIRCtrailerFile "$SIRCDirOutput/pr"; append SIRCtrailerFile $SIRCRunNumber; append SIRCtrailerFile "_trailer_ceos.txt"
            set SIRCimageFile "$SIRCDirOutput/pr"; append SIRCimageFile $SIRCRunNumber; append SIRCimageFile "_image_ceos.txt"
            set FileInputSIRC "$SIRCDirInput/pr"; append FileInputSIRC $SIRCRunNumber; append FileInputSIRC "_img_ceos"
            set config 0
            if [file exists $SIRCleaderFile] { incr config }
            if [file exists $SIRCimageFile] { incr config }
            if [file exists $SIRCtrailerFile] { incr config }
            if { $config == 3 } {
                $widget(Menubutton222_1) configure -state normal
                $widget(Button222_10) configure -state normal
                } else {
                set ErrorMessage "HEADER EXTRACTION ERROR"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } else {
            set ErrorMessage "ROWS / COLS EXTRACTION ERROR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        } else {
        set ErrorMessage "ERROR IN THE SIR-C DATA FORMAT (DUAL - QUAD)"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set SIRCFileInputFlag 0
        set SIRCDataFormat ""; set SIRCFormat ""; set SIRCFileType ""; set SIRCPolMode ""
        set SIRCfgdcFile ""; set SIRCleaderFile ""; set SIRCtrailerFile ""; set SIRCimageFile ""; set SIRCdataFile ""
        }
    } else {
    set ErrorMessage "HEADER EXTRACTION ERROR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set SIRCFileInputFlag 0
    set SIRCDataFormat ""; set SIRCFormat ""; set SIRCFileType ""; set SIRCPolMode ""
    set SIRCfgdcFile ""; set SIRCleaderFile ""; set SIRCtrailerFile ""; set SIRCimageFile ""; set SIRCdataFile ""
    set NligInit ""; set NligEnd ""; set NligFullSize ""; set NcolInit ""; set NcolEnd ""; set NcolFullSize ""; set NligFullSizeInput ""; set NcolFullSizeInput ""
    $widget(Menubutton222_1) configure -state disable; $widget(Button222_10) configure -state disable
    }
if {$datalevelerror == 1} {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    if {$SIRCDataFormatPol == "quad" } { 
        TextEditorRunTrace "Close EO-SI" "b"
        set SIRCDataFormatPol "dual" 
        } else {
        TextEditorRunTrace "Close EO-SI Dual Pol" "b"
        set SIRCDataFormatPol "quad"
        }
    if {$ActiveProgram == "SIRC"} {
        if {$SIRCDataFormatPol == "dual" } { TextEditorRunTrace "Open EO-SI Dual Pol" "b" }
        if {$SIRCDataFormatPol == "quad" } { TextEditorRunTrace "Open EO-SI" "b" }
        $widget(MenubuttonSPACEBORNE) configure -background #FFFF00
        MenuEnvImp
        InitDataDir
        CheckEnvironnement
        }
    Window hide $widget(Toplevel222); TextEditorRunTrace "Close Window SIRC Input File" "b"
    }
   }
  }
}} \
        -cursor {} -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.but93" "Button222_9" vTcl:WidgetProc "Toplevel222" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Read Header Files}
    }
    menubutton $site_3_0.men90 \
        -background #ffff00 -menu "$site_3_0.men90.m" -padx 5 -pady 4 \
        -relief raised -text {Edit Header} 
    vTcl:DefineAlias "$site_3_0.men90" "Menubutton222_1" vTcl:WidgetProc "Toplevel222" 1
    bindtags $site_3_0.men90 "$site_3_0.men90 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men90 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Header Files}
    }
    menu $site_3_0.men90.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global SIRCfgdcFile
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $SIRCfgdcFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top222 $SIRCfgdcFile
    }} \
        -label FGDC 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global SIRCleaderFile
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $SIRCleaderFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top222 $SIRCleaderFile
    }} \
        -label {Leader Header} 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global SIRCtrailerFile 
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $SIRCtrailerFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top222 $SIRCtrailerFile
    }} \
        -label {Trailer Header} 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global SIRCimageFile 
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $SIRCimageFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top222 $SIRCimageFile
    }} \
        -label {Image Header} 
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.men90 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd79 \
        -borderwidth 2 -height 76 -width 200 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel222" 1
    set site_3_0 $top.cpd79
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame110" vTcl:WidgetProc "Toplevel222" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {SIRC Data Format} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label225" vTcl:WidgetProc "Toplevel222" 1
    entry $site_4_0.cpd83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SIRCFormat -width 50 
    vTcl:DefineAlias "$site_4_0.cpd83" "Entry227" vTcl:WidgetProc "Toplevel222" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $site_3_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd85" "Frame111" vTcl:WidgetProc "Toplevel222" 1
    set site_4_0 $site_3_0.cpd85
    label $site_4_0.lab40 \
        -text {SIRC Data Type} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label226" vTcl:WidgetProc "Toplevel222" 1
    entry $site_4_0.cpd83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SIRCFileType -width 50 
    vTcl:DefineAlias "$site_4_0.cpd83" "Entry228" vTcl:WidgetProc "Toplevel222" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $site_3_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd86" "Frame112" vTcl:WidgetProc "Toplevel222" 1
    set site_4_0 $site_3_0.cpd86
    label $site_4_0.lab40 \
        -text {SIRC Polarization Mode} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label227" vTcl:WidgetProc "Toplevel222" 1
    entry $site_4_0.cpd83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SIRCPolMode -width 50 
    vTcl:DefineAlias "$site_4_0.cpd83" "Entry229" vTcl:WidgetProc "Toplevel222" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.cpd85 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd86 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra57 \
        -borderwidth 2 -relief groove -height 76 -width 200 
    vTcl:DefineAlias "$top.fra57" "Frame" vTcl:WidgetProc "Toplevel222" 1
    set site_3_0 $top.fra57
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame107" vTcl:WidgetProc "Toplevel222" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label222_1" vTcl:WidgetProc "Toplevel222" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry222_1" vTcl:WidgetProc "Toplevel222" 1
    label $site_4_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab42" "Label222_2" vTcl:WidgetProc "Toplevel222" 1
    entry $site_4_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent43" "Entry222_2" vTcl:WidgetProc "Toplevel222" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent41 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.lab42 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent43 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side bottom 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel222" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile SIRCFileInputFlag
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError

if {$OpenDirFile == 0} {
    if {$SIRCFileInputFlag == 1} {
        set ErrorMessage ""
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel222); TextEditorRunTrace "Close Window SIRC Input File" "b"
        }
    }} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button222_10" vTcl:WidgetProc "Toplevel222" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SIRC_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel222" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel222); TextEditorRunTrace "Close Window SIRC Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel222" 1
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
    pack $top.lab49 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd78 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.cpd85 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
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
Window show .top222

main $argc $argv
