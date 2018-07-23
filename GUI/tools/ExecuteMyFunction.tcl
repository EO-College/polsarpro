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
    set base .top130
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd88
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
    namespace eval ::widgets::$site_6_0.cpd98 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit99 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit99 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.lab80 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd81
    namespace eval ::widgets::$site_7_0.but37 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but38 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra86
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd87
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_8_0 [$site_6_0.cpd82 getframe]
    namespace eval ::widgets::$site_8_0 {
        array set save {}
    }
    set site_8_0 $site_8_0
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-ipad 1 -text 1}
    }
    set site_8_0 [$site_6_0.cpd83 getframe]
    namespace eval ::widgets::$site_8_0 {
        array set save {}
    }
    set site_8_0 $site_8_0
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-ipad 1 -text 1}
    }
    set site_8_0 [$site_6_0.cpd89 getframe]
    namespace eval ::widgets::$site_8_0 {
        array set save {}
    }
    set site_8_0 $site_8_0
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd88 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd85 {
        array set save {}
    }
    set site_8_0 $site_7_0.cpd85
    namespace eval ::widgets::$site_8_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd91
    namespace eval ::widgets::$site_9_0.cpd98 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd90
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd119 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd120 {
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
            vTclWindow.top130
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

proc vTclWindow.top130 {base} {
    if {$base == ""} {
        set base .top130
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
    wm geometry $top 500x220+160+100; update
    wm maxsize $top 1284 1008
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Execute My Function"
    vTcl:DefineAlias "$top" "Toplevel130" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame3" vTcl:WidgetProc "Toplevel130" 1
    set site_3_0 $top.cpd88
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Function Name} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel130" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MyFunctionFullName 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel130" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel130" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd98 \
        \
        -command {global FileName MyFunctionFullName MyFunctionName MyFunctionVar
global MyFunctionVarN MyFunctionVarName MyFunctionVarType MyFunctionVarValue CONFIGDir
global VarName VarType VarValue1 VarValue2
global VarMyFunction VarError ErrorMessage

set MyFunctionVar ""
set VarName ""
set VarType ""
set VarValue1 ""
set VarValue2 ""

set types {
{{EXE Files}        {.exe}        }
{{All Files}        *        }
}
set FileName ""
OpenFile "Soft/tools/MyRoutines/" $types "MY FUNCTION NAME "
if {$FileName != ""} {
    set MyFunctionFullName $FileName
    set MyFunctionName [file tail $FileName]
    set MyFunctionName [file rootname $MyFunctionName]
    set MyFunctionConfigFile "$CONFIGDir/MyRoutines/"
    append MyFunctionConfigFile $MyFunctionName
    append MyFunctionConfigFile ".txt"    
    set f [open $MyFunctionConfigFile r]
    gets $f MyFunctionNameTmp
    if {$MyFunctionName == $MyFunctionNameTmp} {
        gets $f MyFunctionVarN
        gets $f Tmp
        for {set i 1} {$i <= $MyFunctionVarN} {incr i} {
            gets $f MyFunctionVarName($i)
            gets $f MyFunctionVarType($i)
            gets $f Tmp
            set MyFunctionVarValue($i) "?"
            }
        if {$MyFunctionVarN != "0"} {
            $widget(TitleFrame130_0) configure -state normal
            $widget(TitleFrame130_1) configure -state normal
            $widget(TitleFrame130_2) configure -state normal
            $widget(Entry130_1) configure -state normal
            $widget(Entry130_1) configure -disabledbackground #FFFFFF
            $widget(Entry130_2) configure -state normal
            $widget(Entry130_2) configure -disabledbackground #FFFFFF
            $widget(Button130_1) configure -state normal
            $widget(Button130_2) configure -state normal
            $widget(Entry130_3) configure -state normal
            $widget(Entry130_3) configure -disabledbackground #FFFFFF
            $widget(Entry130_4) configure -state normal
            $widget(Entry130_4) configure -disabledbackground #FFFFFF
            set MyFunctionVar "1"
            set VarName $MyFunctionVarName($MyFunctionVar)    
            set VarType $MyFunctionVarType($MyFunctionVar)
            if {$VarType != "path"} {
                set VarValue1 $MyFunctionVarValue($MyFunctionVar); set VarValue2 ""
                $widget(TitleFrame130_3) configure -state normal
                $widget(TitleFrame130_4) configure -state disable
                $widget(Entry130_5) configure -state normal
                $widget(Entry130_5) configure -disabledbackground #FFFFFF
                $widget(Entry130_6) configure -state disable
                $widget(Entry130_6) configure -disabledbackground $PSPBackgroundColor
                $widget(Button130_3) configure -state disable
                } else {
                set VarValue1 ""; set VarValue2 $MyFunctionVarValue($MyFunctionVar)
                $widget(TitleFrame130_3) configure -state disable
                $widget(TitleFrame130_4) configure -state normal
                $widget(Entry130_5) configure -state disable
                $widget(Entry130_5) configure -disabledbackground $PSPBackgroundColor
                $widget(Entry130_6) configure -state normal
                $widget(Entry130_6) configure -disabledbackground #FFFFFF
                $widget(Button130_3) configure -state normal
                }
            } else {
            set MyFunctionVar "0"
            $widget(TitleFrame130_0) configure -state disable
            $widget(TitleFrame130_1) configure -state disable
            $widget(TitleFrame130_2) configure -state disable
            $widget(Entry130_1) configure -state disable
            $widget(Entry130_1) configure -disabledbackground $PSPBackgroundColor
            $widget(Entry130_2) configure -state disable
            $widget(Entry130_2) configure -disabledbackground $PSPBackgroundColor
            $widget(Button130_1) configure -state disable
            $widget(Button130_2) configure -state disable
            $widget(Entry130_3) configure -state disable
            $widget(Entry130_3) configure -disabledbackground $PSPBackgroundColor
            $widget(Entry130_4) configure -state disable
            $widget(Entry130_4) configure -disabledbackground $PSPBackgroundColor
            $widget(TitleFrame130_3) configure -state disable
            $widget(TitleFrame130_4) configure -state disable
            $widget(Entry130_5) configure -state disable
            $widget(Entry130_5) configure -disabledbackground $PSPBackgroundColor
            $widget(Entry130_6) configure -state disable
            $widget(Entry130_6) configure -disabledbackground $PSPBackgroundColor
            $widget(Button130_3) configure -state disable
            }                
        } else {
        set ErrorMessage "NOT A VALID FUNCTION"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    close $f
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd98" "Button83" vTcl:WidgetProc "Toplevel130" 1
    pack $site_6_0.cpd98 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit99 \
        -ipad 2 -text {Parameters Definition} 
    vTcl:DefineAlias "$top.tit99" "TitleFrame130_0" vTcl:WidgetProc "Toplevel130" 1
    bind $top.tit99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit99 getframe]
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame7" vTcl:WidgetProc "Toplevel130" 1
    set site_5_0 $site_4_0.cpd73
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame10" vTcl:WidgetProc "Toplevel130" 1
    set site_6_0 $site_5_0.cpd76
    entry $site_6_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable MyFunctionVar -width 3 
    vTcl:DefineAlias "$site_6_0.cpd78" "Entry130_1" vTcl:WidgetProc "Toplevel130" 1
    label $site_6_0.lab80 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab80" "Label1" vTcl:WidgetProc "Toplevel130" 1
    entry $site_6_0.cpd79 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable MyFunctionVarN -width 3 
    vTcl:DefineAlias "$site_6_0.cpd79" "Entry130_2" vTcl:WidgetProc "Toplevel130" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.lab80 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame11" vTcl:WidgetProc "Toplevel130" 1
    set site_6_0 $site_5_0.cpd77
    frame $site_6_0.cpd81 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd81" "Frame463" vTcl:WidgetProc "Toplevel130" 1
    set site_7_0 $site_6_0.cpd81
    button $site_7_0.but37 \
        \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType MyFunctionVarValue
global VarName VarType VarValue1 VarValue2

if {$MyFunctionVar != "0"} {
    if {$VarType != "path"} {
        set MyFunctionVarValue($MyFunctionVar) $VarValue1
        } else {
        set MyFunctionVarValue($MyFunctionVar) $VarValue2
        }
    }

if {$MyFunctionVar < $MyFunctionVarN} {
    incr MyFunctionVar    
    set VarName $MyFunctionVarName($MyFunctionVar)
    set VarType $MyFunctionVarType($MyFunctionVar)
    if {$VarType != "path"} {
        set VarValue1 $MyFunctionVarValue($MyFunctionVar); set VarValue2 ""
        $widget(TitleFrame130_3) configure -state normal
        $widget(TitleFrame130_4) configure -state disable
        $widget(Entry130_5) configure -state normal
        $widget(Entry130_5) configure -disabledbackground #FFFFFF
        $widget(Entry130_6) configure -state disable
        $widget(Entry130_6) configure -disabledbackground $PSPBackgroundColor
        $widget(Button130_3) configure -state disable
        } else {
        set VarValue1 ""; set VarValue2 $MyFunctionVarValue($MyFunctionVar)
        $widget(TitleFrame130_3) configure -state disable
        $widget(TitleFrame130_4) configure -state normal
        $widget(Entry130_5) configure -state disable
        $widget(Entry130_5) configure -disabledbackground $PSPBackgroundColor
        $widget(Entry130_6) configure -state disable
        $widget(Entry130_6) configure -disabledbackground #FFFFFF
        $widget(Button130_3) configure -state normal
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.but37" "Button130_1" vTcl:WidgetProc "Toplevel130" 1
    bindtags $site_7_0.but37 "$site_7_0.but37 Button $top all _vTclBalloon"
    bind $site_7_0.but37 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Move Up in the Class List}
    }
    button $site_7_0.but38 \
        \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType MyFunctionVarValue
global VarName VarType VarValue1 VarValue2

if {$MyFunctionVar != "0"} {
    if {$VarType != "path"} {
        set MyFunctionVarValue($MyFunctionVar) $VarValue1
        } else {
        set MyFunctionVarValue($MyFunctionVar) $VarValue2
        }
    }

if {$MyFunctionVar > "1"} {
    set MyFunctionVar [expr $MyFunctionVar - 1]
    set VarName $MyFunctionVarName($MyFunctionVar)
    set VarType $MyFunctionVarType($MyFunctionVar)
    if {$VarType != "path"} {
        set VarValue1 $MyFunctionVarValue($MyFunctionVar); set VarValue2 ""
        $widget(TitleFrame130_3) configure -state normal
        $widget(TitleFrame130_4) configure -state disable
        $widget(Entry130_5) configure -state normal
        $widget(Entry130_5) configure -disabledbackground #FFFFFF
        $widget(Entry130_6) configure -state disable
        $widget(Entry130_6) configure -disabledbackground $PSPBackgroundColor
        $widget(Button130_3) configure -state disable
        } else {
        set VarValue1 ""; set VarValue2 $MyFunctionVarValue($MyFunctionVar)
        $widget(TitleFrame130_3) configure -state disable
        $widget(TitleFrame130_4) configure -state normal
        $widget(Entry130_5) configure -state disable
        $widget(Entry130_5) configure -disabledbackground $PSPBackgroundColor
        $widget(Entry130_6) configure -state disable
        $widget(Entry130_6) configure -disabledbackground #FFFFFF
        $widget(Button130_3) configure -state normal
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but38" "Button130_2" vTcl:WidgetProc "Toplevel130" 1
    bindtags $site_7_0.but38 "$site_7_0.but38 Button $top all _vTclBalloon"
    bind $site_7_0.but38 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Move Down in the Class List}
    }
    pack $site_7_0.but37 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side left 
    pack $site_7_0.but38 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side left 
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra86" "Frame1" vTcl:WidgetProc "Toplevel130" 1
    set site_5_0 $site_4_0.fra86
    frame $site_5_0.cpd87 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd87" "Frame8" vTcl:WidgetProc "Toplevel130" 1
    set site_6_0 $site_5_0.cpd87
    TitleFrame $site_6_0.cpd82 \
        -ipad 5 -text {Variable Name} 
    vTcl:DefineAlias "$site_6_0.cpd82" "TitleFrame130_1" vTcl:WidgetProc "Toplevel130" 1
    bind $site_6_0.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd82 getframe]
    entry $site_8_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable VarName 
    vTcl:DefineAlias "$site_8_0.cpd77" "Entry130_3" vTcl:WidgetProc "Toplevel130" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_6_0.cpd83 \
        -ipad 5 -text {Variable Value} 
    vTcl:DefineAlias "$site_6_0.cpd83" "TitleFrame130_3" vTcl:WidgetProc "Toplevel130" 1
    bind $site_6_0.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd83 getframe]
    entry $site_8_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable VarValue1 
    vTcl:DefineAlias "$site_8_0.cpd77" "Entry130_5" vTcl:WidgetProc "Toplevel130" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_6_0.cpd89 \
        -ipad 5 -text {Variable Type} 
    vTcl:DefineAlias "$site_6_0.cpd89" "TitleFrame130_2" vTcl:WidgetProc "Toplevel130" 1
    bind $site_6_0.cpd89 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd89 getframe]
    entry $site_8_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable VarType 
    vTcl:DefineAlias "$site_8_0.cpd77" "Entry130_4" vTcl:WidgetProc "Toplevel130" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_5_0.cpd88 \
        -ipad 5 -text {Variable Value} 
    vTcl:DefineAlias "$site_5_0.cpd88" "TitleFrame130_4" vTcl:WidgetProc "Toplevel130" 1
    bind $site_5_0.cpd88 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd88 getframe]
    frame $site_7_0.cpd85
    set site_8_0 $site_7_0.cpd85
    entry $site_8_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable VarValue2 
    vTcl:DefineAlias "$site_8_0.cpd85" "Entry130_6" vTcl:WidgetProc "Toplevel130" 1
    frame $site_8_0.cpd91 \
        -borderwidth 1 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel130" 1
    set site_9_0 $site_8_0.cpd91
    button $site_9_0.cpd98 \
        \
        -command {global DirName DataDir VarValue2

set DirName ""
OpenDir $DataDir "INPUT PATH VARIABLE"
set VarValue2 $DirName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd98" "Button130_3" vTcl:WidgetProc "Toplevel130" 1
    pack $site_9_0.cpd98 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    pack $site_8_0.cpd85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.cpd91 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra86 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    frame $top.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd90" "Frame6" vTcl:WidgetProc "Toplevel130" 1
    set site_3_0 $top.cpd90
    button $site_3_0.cpd118 \
        -background #ffff00 \
        -command {global MyFunctionFullName MyFunctionName MyFunctionVar
global MyFunctionVarN MyFunctionVarName MyFunctionVarType MyFunctionVarValue
global VarName VarType VarValue1 VarValue2
global VarMyFunction VarError ErrorMessage

if {$MyFunctionName != ""} {
    set config "ok"
    if {$MyFunctionVarN != "0"} {
        for {set i 1} {$i <= $MyFunctionVarN} {incr i} {
            if {$MyFunctionVarValue($i) == "?"} {
                set config "no"
                set ErrorMessage "VARIABLE $i NOT DEFINED"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }                
        }
    if {$config == "ok"} {
        if {$MyFunctionVarN != "0"} {
            for {set i 0} {$i < $MyFunctionVarN} {incr i} {
                set TestVarName($i) ""; set TestVarMin($i) ""; set TestVarMax($i) ""; set TestVarValue($i) $MyFonctionVarValue($i)
                if {$MyFonctionVarType($i) == "float"} { set TestVarType($i) "float" }
                if {$MyFonctionVarType($i) == "integer"} { set TestVarType($i) "int" }
                if {$MyFonctionVarType($i) == "ascii"} { set TestVarType($i) "ascii" }
                if {$MyFonctionVarType($i) == "path"} { set TestVarType($i) "path" }
                }
            }
        TestVar $MyFunctionVarN
        if {$TestVarError == "ok"} {
            TextEditorRunTrace "Process The Function $MyFunctionFullName" "k"
            set ExtractCommand ""
            if {$MyFunctionVarN != "0"} {
                for {set i 1} {$i <= $MyFunctionVarN} {incr i} {
                    if {$MyFonctionVarType($i) == "float"} {append ExtractCommand "$MyFonctionVarValue($i) "}
                    if {$MyFonctionVarType($i) == "integer"} {append ExtractCommand "$MyFonctionVarValue($i) "}
                    if {$MyFonctionVarType($i) == "ascii"} {append ExtractCommand "\x22$MyFonctionVarValue($i)\x22 "}
                    if {$MyFonctionVarType($i) == "path"} {append ExtractCommand "\x22$MyFonctionVarValue($i)\x22 "}
                    }
                }                
            TextEditorRunTrace "Arguments: $ExtractCommand" "k"
            set f [ open "| $MyFunctionFullName $ExtractCommand" r]
            PsPprogressBar $f
            }
        }
    set VarMyFunction "ok"
    Window hide $widget(Toplevel130); TextEditorRunTrace "Close Window Execute My Function" "b"
    }} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.cpd118" "Button639" vTcl:WidgetProc "Toplevel130" 1
    bindtags $site_3_0.cpd118 "$site_3_0.cpd118 Button $top all _vTclBalloon"
    bind $site_3_0.cpd118 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save the Training Area List}
    }
    button $site_3_0.cpd119 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/tools/ExecuteMyFunction.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.cpd119" "Button17" vTcl:WidgetProc "Toplevel130" 1
    bindtags $site_3_0.cpd119 "$site_3_0.cpd119 Button $top all _vTclBalloon"
    bind $site_3_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.cpd120 \
        -background #ffff00 \
        -command {global VarMyFunction

set VarMyFunction $VarMyFunction

Window hide $widget(Toplevel130); TextEditorRunTrace "Close Window Execute My Function" "b"} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.cpd120" "Button640" vTcl:WidgetProc "Toplevel130" 1
    bindtags $site_3_0.cpd120 "$site_3_0.cpd120 Button $top all _vTclBalloon"
    bind $site_3_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd119 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd120 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit99 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd90 \
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
Window show .top130

main $argc $argv
