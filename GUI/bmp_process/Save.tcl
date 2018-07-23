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
    set base .top82
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.but83 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.but84 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.but85 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.but86 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.but87 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.but89 {
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
            vTclWindow.top82
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
    wm geometry $top 200x200+198+198; update
    wm maxsize $top 1604 1185
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

proc vTclWindow.top82 {base} {
    if {$base == ""} {
        set base .top82
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
    wm geometry $top 120x180+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Save"
    vTcl:DefineAlias "$top" "Toplevel82" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    button $top.but83 \
        \
        -command {global DataDir FileName BMPDirInput BMPViewFileInput BMPViewFileOutput BMPChange
global TMPBmpTmp OpenDirFile

if {$OpenDirFile == 0} {

if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
set Types {
    {{BMP Files}        {.bmp}        }
    }

set BMPViewFileTmp [file tail $BMPViewFileInput]
set len [expr [string length $BMPViewFileTmp] - 5]
set BMPViewFileOutput [string range $BMPViewFileTmp 0 $len]
append BMPViewFileOutput ".bmp"
set FileName ""
set FileName [tk_getSaveFile -initialdir $BMPDirInput -filetypes $Types -title "BMP OUTPUT FILE" -defaultextension .bmp -initialfile $BMPViewFileOutput]
if {"$FileName" != ""} {
    if {$BMPChange == 1} {
        CopyFile $TMPBmpTmp $FileName
        set BMPChange "0"
        } else {
        CopyFile $BMPViewFileInput $FileName
        }        
    }
}} \
        -padx 4 -pady 2 -text {BMP Format} 
    vTcl:DefineAlias "$top.but83" "Button573" vTcl:WidgetProc "Toplevel82" 1
    button $top.but84 \
        \
        -command {global DataDir FileName BMPDirInput BMPViewFileInput ImageSource BMPChange ColorNumber
global ErrorMessage VarError OpenDirFile

if {$OpenDirFile == 0} {

if {$ColorNumber != "BMP 24 Bits"} {
    if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
    set Types {
        {{GIF Files}        {.gif}        }
        }
    
    set BMPViewFileTmp [file tail $BMPViewFileInput]
    set len [expr [string length $BMPViewFileTmp] - 5]
    set BMPViewFileOutput [string range $BMPViewFileTmp 0 $len]
    append BMPViewFileOutput ".gif"
    set FileName ""
    set FileName [tk_getSaveFile -initialdir $BMPDirInput -filetypes $Types -title "GIF OUTPUT FILE" -defaultextension .gif -initialfile $BMPViewFileOutput]
    if {"$FileName" != ""} {
        ImageSource write $FileName -format gif
        set BMPChange "0"
        }
    } else {
    set ErrorMessage "IMPOSSIBLE TO SAVE A GIF - 24 Bits" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text {GIF Format} 
    vTcl:DefineAlias "$top.but84" "Button574" vTcl:WidgetProc "Toplevel82" 1
    button $top.but85 \
        \
        -command {global DataDir FileName BMPDirInput BMPViewFileInput ImageSource BMPChange OpenDirFile

if {$OpenDirFile == 0} {

if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
set Types {
    {{JPG Files}        {.jpg}        }
    }

set BMPViewFileTmp [file tail $BMPViewFileInput]
set len [expr [string length $BMPViewFileTmp] - 5]
set BMPViewFileOutput [string range $BMPViewFileTmp 0 $len]
append BMPViewFileOutput ".jpg"
set FileName ""
set FileName [tk_getSaveFile -initialdir $BMPDirInput -filetypes $Types -title "JPG OUTPUT FILE" -defaultextension .jpg -initialfile $BMPViewFileOutput]
if {"$FileName" != ""} {
    ImageSource write $FileName -format jpeg
    set BMPChange "0"
    }
}} \
        -padx 4 -pady 2 -text {JPG Format} 
    vTcl:DefineAlias "$top.but85" "Button575" vTcl:WidgetProc "Toplevel82" 1
    button $top.but86 \
        \
        -command {global DataDir FileName BMPDirInput BMPViewFileInput ImageSource BMPChange OpenDirFile

if {$OpenDirFile == 0} {

if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
set Types {
    {{TIF Files}        {.tif}        }
    }

set BMPViewFileTmp [file tail $BMPViewFileInput]
set len [expr [string length $BMPViewFileTmp] - 5]
set BMPViewFileOutput [string range $BMPViewFileTmp 0 $len]
append BMPViewFileOutput ".tif"
set FileName ""
set FileName [tk_getSaveFile -initialdir $BMPDirInput -filetypes $Types -title "TIF OUTPUT FILE" -defaultextension .tif -initialfile $BMPViewFileOutput]
if {"$FileName" != ""} {
    ImageSource write $FileName -format tiff
    set BMPChange "0"
    }
}} \
        -padx 4 -pady 2 -text {TIF Format} 
    vTcl:DefineAlias "$top.but86" "Button576" vTcl:WidgetProc "Toplevel82" 1
    button $top.but87 \
        \
        -command {global DataDir FileName BMPDirInput BMPViewFileInput ImageSource BMPChange
global ColorNumber ErrorMessage VarError OpenDirFile

if {$OpenDirFile == 0} {

if {$ColorNumber != "BMP 24 Bits"} {
    if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
    set Types {
        {{PS Files}        {.ps}        }
        }

    set BMPViewFileTmp [file tail $BMPViewFileInput]
    set len [expr [string length $BMPViewFileTmp] - 5]
    set BMPViewFileOutput [string range $BMPViewFileTmp 0 $len]
    append BMPViewFileOutput ".ps"
    set FileName ""
    set FileName [tk_getSaveFile -initialdir $BMPDirInput -filetypes $Types -title "PS OUTPUT FILE" -defaultextension .ps -initialfile $BMPViewFileOutput]
    if {"$FileName" != ""} {
        ImageSource write $FileName -format postscript
        set BMPChange "0"
        }
    } else {
    set ErrorMessage "IMPOSSIBLE TO SAVE A PS - 24 Bits" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text {PS Format} 
    vTcl:DefineAlias "$top.but87" "Button577" vTcl:WidgetProc "Toplevel82" 1
    button $top.but89 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel82); TextEditorRunTrace "Close Window Save" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$top.but89" "Button67" vTcl:WidgetProc "Toplevel82" 1
    bindtags $top.but89 "$top.but89 Button $top all _vTclBalloon"
    bind $top.but89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.but83 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.but84 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.but85 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.but86 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.but87 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.but89 \
        -in $top -anchor center -expand 1 -fill none -side bottom 

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
Window show .top82

main $argc $argv
