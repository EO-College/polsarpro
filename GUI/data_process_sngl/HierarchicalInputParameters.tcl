#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

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
    set base .top264
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd85 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd86 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra75
    namespace eval ::widgets::$site_3_0.fra77 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra77
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra79
    namespace eval ::widgets::$site_5_0.but80 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.but81 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd83
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd84
    namespace eval ::widgets::$site_3_0.lab42 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.ent44 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd94
    namespace eval ::widgets::$site_4_0.cpd105 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top264
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

proc vTclWindow.top264 {base} {
    if {$base == ""} {
        set base .top264
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
    wm geometry $top 500x120+200+380; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Hierarchical Classification : Input Parameters Definition"
    vTcl:DefineAlias "$top" "Toplevel264" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel264" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TreeNum VarError ErrorMessage
global TreeParaLabel TreeInputParaLabel
global TreeParaFile TreeInputParaFile


if {$TreeParaLabel == "?"} {
    set VarError ""
    set ErrorMessage "ENTER THE PARAMETER LABEL" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set TreeInputParaLabel($TreeNum) $TreeParaLabel
    }
if {$TreeParaFile == "" } {
    set VarError ""
    set ErrorMessage "ENTER THE PARAMETER FILE NAME" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set TreeInputParaFile($TreeNum) $TreeParaFile
    }} \
        -padx 4 -pady 2 -text Enter 
    vTcl:DefineAlias "$site_3_0.but93" "Button264_2" vTcl:WidgetProc "Toplevel264" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Enter}
    }
    button $site_3_0.cpd85 \
        -background #ffff00 \
        -command {global TreeNum TreeInputNum
global TreeParaLabel TreeInputParaLabel
global TreeParaFile TreeInputParaFile

$widget(Label264_1) configure -state normal
$widget(Entry264_1) configure -state normal
$widget(Entry264_1) configure -disabledbackground #FFFFFF
$widget(Label264_2) configure -state normal
$widget(Entry264_2) configure -state disable
$widget(Entry264_2) configure -disabledbackground #FFFFFF
$widget(Button264_1) configure -state normal
$widget(Button264_2) configure -state normal
$widget(Button264_3) configure -state normal

set TreeInputNum [expr $TreeInputNum + 1]
set TreeNum $TreeInputNum

set TreeParaLabel "?"
set TreeInputParaLabel($TreeNum) "XX"
set TreeParaFile ""
set TreeInputParaFile($TreeNum) "XX"} \
        -padx 4 -pady 2 -relief sunken -text New 
    vTcl:DefineAlias "$site_3_0.cpd85" "Button264" vTcl:WidgetProc "Toplevel264" 1
    bindtags $site_3_0.cpd85 "$site_3_0.cpd85 Button $top all _vTclBalloon"
    bind $site_3_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {New Parameter}
    }
    button $site_3_0.cpd86 \
        -background #ffff00 \
        -command {global TreeNum TreeInputNum
global TreeParaLabel TreeInputParaLabel
global TreeParaFile TreeInputParaFile

set TreeParaLabel "?"
set TreeParaFile ""
for {set i 1} {$i <= 100} {incr i} {
    set TreeInputParaLabel($i) "XX"
    set TreeInputParaFile($i) "XX"
    }
set TreeInputNum 1
set TreeNum $TreeInputNum} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd86" "Button264_3" vTcl:WidgetProc "Toplevel264" 1
    bindtags $site_3_0.cpd86 "$site_3_0.cpd86 Button $top all _vTclBalloon"
    bind $site_3_0.cpd86 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/HierarchicalInputParameters.pdf" } \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel264" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global HierarchicalDirOutput HierarchicalOutputDir HierarchicalOutputSubDir
global TreeInputParameterFile TreeInputNum
global TreeInputParaLabel TreeInputParaFile
global WarningMessage WarningMessage2 VarWarning

if {$OpenDirFile == 0} {

if {$TreeInputNum != 0} {
    set config "true"
    for {set i 1} {$i <= $TreeInputNum} {incr i} {
        if {$TreeInputParaLabel($i) == "XX"} { set config "false" }
        if {$TreeInputParaFile($i) == "XX"} { set config "false" }
        }
    if {$config == "false"} {
        set TreeInputNum 0
        set WarningMessage "WRONG INPUT PARAMETERS : IMPOSSIBLE TO SAVE"
        set WarningMessage2 "EXIT WITHOUT SAVING ?"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {Window hide $widget(Toplevel264); TextEditorRunTrace "Close Window Hierarchical Classification - Input Parameters Definition" "b"}
        } else {
        set HierarchicalDirOutput $HierarchicalOutputDir
        if {$HierarchicalOutputSubDir != ""} {append HierarchicalDirOutput "/$HierarchicalOutputSubDir"}

    #####################################################################
    #Create Directory
    set HierarchicalDirOutput [PSPCreateDirectoryMask $HierarchicalDirOutput $HierarchicalOutputDir $HierarchicalDirInput]
    #####################################################################       

        if {"$VarWarning"=="ok"} {
            set TreeInputParameterFile "$HierarchicalDirOutput/tree_parameters_list.txt"
            set f [open $TreeInputParameterFile w]
            puts $f "TREE INPUT PARAMETERS"
            puts $f $TreeInputNum
            for {set i 1} {$i <= $TreeInputNum} {incr i} {
                puts $f $TreeInputParaLabel($i)
                puts $f $TreeInputParaFile($i)
                }
            close $f
            }
        Window hide $widget(Toplevel264); TextEditorRunTrace "Close Window Hierarchical Classification - Input Parameters Definition" "b"
        }
    }    
}} \
        -padx 4 -pady 2 -text {Save & Exit} 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel264" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame1" vTcl:WidgetProc "Toplevel264" 1
    set site_3_0 $top.fra75
    frame $site_3_0.fra77 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra77" "Frame3" vTcl:WidgetProc "Toplevel264" 1
    set site_4_0 $site_3_0.fra77
    label $site_4_0.cpd82 \
        -text Parameter 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label1" vTcl:WidgetProc "Toplevel264" 1
    entry $site_4_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable TreeNum -width 5 
    vTcl:DefineAlias "$site_4_0.ent78" "Entry1" vTcl:WidgetProc "Toplevel264" 1
    frame $site_4_0.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra79" "Frame4" vTcl:WidgetProc "Toplevel264" 1
    set site_5_0 $site_4_0.fra79
    button $site_5_0.but80 \
        \
        -command {global TreeNum TreeInputNum
global TreeInputParaLabel TreeParaLabel
global TreeInputParaFile TreeParaFile

set TreeNum [expr $TreeNum + 1]
if {$TreeNum > $TreeInputNum} {set TreeNum 1}

if {$TreeInputParaLabel($TreeNum) == "XX"} {
    set TreeParaLabel "?"
    } else {
    set TreeParaLabel $TreeInputParaLabel($TreeNum)
    }
if {$TreeInputParaFile($TreeNum) == "XX"} {
    set TreeParaFile ""
    } else {
    set TreeParaFile $TreeInputParaFile($TreeNum)
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_5_0.but80" "Button2" vTcl:WidgetProc "Toplevel264" 1
    button $site_5_0.but81 \
        \
        -command {global TreeNum TreeInputNum
global TreeInputParaLabel TreeParaLabel
global TreeInputParaFile TreeParaFile

set TreeNum [expr $TreeNum - 1]
if {$TreeNum == 0 } {set TreeNum $TreeInputNum}

if {$TreeInputParaLabel($TreeNum) == "XX"} {
    set TreeParaLabel "?"
    } else {
    set TreeParaLabel $TreeInputParaLabel($TreeNum)
    }
if {$TreeInputParaFile($TreeNum) == "XX"} {
    set TreeParaFile ""
    } else {
    set TreeParaFile $TreeInputParaFile($TreeNum)
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but81" "Button3" vTcl:WidgetProc "Toplevel264" 1
    pack $site_5_0.but80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.but81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_4_0.fra79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_3_0.cpd83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd83" "Frame5" vTcl:WidgetProc "Toplevel264" 1
    set site_4_0 $site_3_0.cpd83
    label $site_4_0.cpd82 \
        -text {Parameter Label} 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label264_1" vTcl:WidgetProc "Toplevel264" 1
    entry $site_4_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable TreeParaLabel -width 30 
    vTcl:DefineAlias "$site_4_0.ent78" "Entry264_1" vTcl:WidgetProc "Toplevel264" 1
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd84 \
        -relief groove -height 77 -width 437 
    vTcl:DefineAlias "$top.cpd84" "Frame273" vTcl:WidgetProc "Toplevel264" 1
    set site_3_0 $top.cpd84
    label $site_3_0.lab42 \
        -text {Parameters File} -width 12 
    vTcl:DefineAlias "$site_3_0.lab42" "Label264_2" vTcl:WidgetProc "Toplevel264" 1
    entry $site_3_0.ent44 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TreeParaFile 
    vTcl:DefineAlias "$site_3_0.ent44" "Entry264_2" vTcl:WidgetProc "Toplevel264" 1
    frame $site_3_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd94" "Frame25" vTcl:WidgetProc "Toplevel264" 1
    set site_4_0 $site_3_0.cpd94
    button $site_4_0.cpd105 \
        \
        -command {global FileName HierarchicalDirInput TreeParaFile

set TreeParaFileTmp $TreeParaFile

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$HierarchicalDirInput" $types "INPUT PARAMETERS FILE"
if {$FileName != ""} {
    set TreeParaFile $FileName
    } else {
    set TreeParaFile $TreeParaFileTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd105" "Button264_1" vTcl:WidgetProc "Toplevel264" 1
    bindtags $site_4_0.cpd105 "$site_4_0.cpd105 Button $top all _vTclBalloon"
    bind $site_4_0.cpd105 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_4_0.cpd105 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.lab42 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_3_0.ent44 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd94 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.fra75 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd84 \
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
Window show .top264

main $argc $argv
