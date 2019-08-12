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
    set base .top409
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit67 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd69 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra67
    namespace eval ::widgets::$site_5_0.but68 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad72 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.but70 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd81 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra77
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd79 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m82 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
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

proc ::main {argc argv} {}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

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

proc vTclWindow.top409 {base} {
    if {$base == ""} {
        set base .top409
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m82" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x250+160+100; update
    wm maxsize $top 1284 785
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Map Info Update"
    vTcl:DefineAlias "$top" "Toplevel409" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit67 \
        -text {Input Directory} 
    vTcl:DefineAlias "$top.tit67" "TitleFrame1" vTcl:WidgetProc "Toplevel409" 1
    bind $top.tit67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit67 getframe]
    entry $site_4_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapInfoDirOutput 
    vTcl:DefineAlias "$site_4_0.ent68" "Entry1" vTcl:WidgetProc "Toplevel409" 1
    pack $site_4_0.ent68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd69 \
        -text {Input Hdr File} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame2" vTcl:WidgetProc "Toplevel409" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    entry $site_4_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapInfoHdrFile 
    vTcl:DefineAlias "$site_4_0.ent68" "Entry2" vTcl:WidgetProc "Toplevel409" 1
    frame $site_4_0.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra67" "Frame2" vTcl:WidgetProc "Toplevel409" 1
    set site_5_0 $site_4_0.fra67
    button $site_5_0.but68 \
        \
        -command {global FileName MapInfoDirOutput MapInfoHdrFile

set types {
{{HDR Files}        {.hdr}        }
}
set FileName ""
OpenFile $MapInfoDirOutput $types "INPUT HDR FILE"
    
if {$FileName != ""} {
    set MapInfoHdrFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but68" "Button2" vTcl:WidgetProc "Toplevel409" 1
    pack $site_5_0.but68 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.ent68 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra67 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd71 \
        -text Sensor 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame3" vTcl:WidgetProc "Toplevel409" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    radiobutton $site_4_0.rad72 \
        -text Unknown -value Unknown -variable MapInfoSensor 
    vTcl:DefineAlias "$site_4_0.rad72" "Radiobutton1" vTcl:WidgetProc "Toplevel409" 1
    radiobutton $site_4_0.cpd73 \
        -text ALOS -value ALOS -variable MapInfoSensor 
    vTcl:DefineAlias "$site_4_0.cpd73" "Radiobutton2" vTcl:WidgetProc "Toplevel409" 1
    radiobutton $site_4_0.cpd74 \
        -text RADARSAT-2 -value RS2 -variable MapInfoSensor 
    vTcl:DefineAlias "$site_4_0.cpd74" "Radiobutton3" vTcl:WidgetProc "Toplevel409" 1
    radiobutton $site_4_0.cpd75 \
        -text TerraSAR-X -value TSX -variable MapInfoSensor 
    vTcl:DefineAlias "$site_4_0.cpd75" "Radiobutton4" vTcl:WidgetProc "Toplevel409" 1
    radiobutton $site_4_0.cpd76 \
        -text Other -value Other -variable MapInfoSensor 
    vTcl:DefineAlias "$site_4_0.cpd76" "Radiobutton5" vTcl:WidgetProc "Toplevel409" 1
    pack $site_4_0.rad72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    button $top.but70 \
        -background #ffff00 \
        -command {global MapInfoDirOutput MapInfoHdrFile MapInfoSensor 
global MapInfoMaskPolFormat MapInfoPolarType
global MapInfoActive MapInfoMapInfo MapInfoProjInfo MapInfoUnit
global ConfigFile VarError ErrorMessage Fonction

TextEditorRunTrace "Process The Function Soft/bin/tools/mapinfo_config_file.exe" "k"
TextEditorRunTrace "Arguments: -id \x22$MapInfoDirOutput\x22 -if \x22$MapInfoHdrFile\x22 -ss $MapInfoSensor -pp $MapInfoPolarType" "k"
set f [ open "| Soft/bin/tools/mapinfo_config_file.exe -id \x22$MapInfoDirOutput\x22 -if \x22$MapInfoHdrFile\x22 -ss $MapInfoSensor -pp $MapInfoPolarType" r]
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
           
set MapInfoConfigFile "$MapInfoDirOutput/config_mapinfo.txt" 

WaitUntilCreated $MapInfoConfigFile

if [file exists $MapInfoConfigFile] {
    MapInfoReadConfig $MapInfoConfigFile
    $widget(Button409_1) configure -state normal
    } else {
    set ErrorMessage "THE config_mapinfo.txt FILE IS NOT CREATED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -padx 4 -pady 2 -text Read 
    vTcl:DefineAlias "$top.but70" "Button1" vTcl:WidgetProc "Toplevel409" 1
    TitleFrame $top.cpd81 \
        -text {Map Info} 
    vTcl:DefineAlias "$top.cpd81" "TitleFrame4" vTcl:WidgetProc "Toplevel409" 1
    bind $top.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd81 getframe]
    entry $site_4_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapInfoMapInfo 
    vTcl:DefineAlias "$site_4_0.ent68" "Entry3" vTcl:WidgetProc "Toplevel409" 1
    pack $site_4_0.ent68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra77" "Frame1" vTcl:WidgetProc "Toplevel409" 1
    set site_3_0 $top.fra77
    button $site_3_0.cpd78 \
        -background #ffff00 \
        -command {global MapInfoDirOutput 
global MapInfoMaskPolFormat MapInfoPolarType

set ConfigFile "$MapInfoDirOutput/config.txt"
set ErrorMessage ""
LoadConfig

if {$MapInfoMaskPolFormat == "C2"} {EnviWriteConfigC $MapInfoDirOutput $NligFullSize $NcolFullSize}
if {$MapInfoMaskPolFormat == "C3"} {EnviWriteConfigC $MapInfoDirOutput $NligFullSize $NcolFullSize}
if {$MapInfoMaskPolFormat == "C4"} {EnviWriteConfigC $MapInfoDirOutput $NligFullSize $NcolFullSize}

if {$MapInfoMaskPolFormat == "T3"} {EnviWriteConfigT $MapInfoDirOutput $NligFullSize $NcolFullSize}
if {$MapInfoMaskPolFormat == "T4"} {EnviWriteConfigT $MapInfoDirOutput $NligFullSize $NcolFullSize}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.cpd78" "Button409_1" vTcl:WidgetProc "Toplevel409" 1
    button $site_3_0.cpd79 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel409); TextEditorRunTrace "Close Window Map Info Update" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.cpd79" "Button3" vTcl:WidgetProc "Toplevel409" 1
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m82 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.tit67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.but70 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.cpd81 \
        -in $top -anchor center -expand 0 -fill x -side top 
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

Window show .
Window show .top409

main $argc $argv
