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
    set base .top002
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-_tooltip 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.rad66 {
        array set save {-_tooltip 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-_tooltip 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-_tooltip 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top002
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
    wm geometry $top 200x200+175+175; update
    wm maxsize $top 1916 1054
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

proc vTclWindow.top002 {base} {
    if {$base == ""} {
        set base .top002
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
    wm geometry $top 250x40+30+70; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Polarimetric Data Format"
    vTcl:DefineAlias "$top" "Toplevel002" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    radiobutton $top.cpd66 \
        \
        -command {global DataDirChannel1 DataDirChannel2 DataFormatActive
global ConfigFile VarError ErrorMessage WindowShowDataFormatDual 

set Fonction ""; set Fonction2 ""
set ConfigFile ""

set config ""
if [file exists "$DataDirChannel1/config.txt"] {
set conf "false"
if [file exists "$DataDirChannel1/s11.bin"] {set conf "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set conf "true"}
if {$conf == "true"} {
    set ConfigFile "$DataDirChannel1/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if { "$PolarType" != "full"} {
            set config "master"
            set configmaster "D"
            if { "$PolarType" == "pp1"} {
                if [file exists "$DataDirChannel1/s11.bin"] {append configmaster "1"}
                if [file exists "$DataDirChannel1/s21.bin"] {append configmaster "2"}
                }
            if { "$PolarType" == "pp2"} {
                if [file exists "$DataDirChannel1/s12.bin"] {append configmaster "1"}
                if [file exists "$DataDirChannel1/s22.bin"] {append configmaster "2"}
                }
            if { "$PolarType" == "pp3"} {
                if [file exists "$DataDirChannel1/s11.bin"] {append configmaster "1"}
                if [file exists "$DataDirChannel1/s22.bin"] {append configmaster "2"}
                }
            set NligFullSizeMaster $NligFullSize
            set NcolFullSizeMaster $NcolFullSize
            set PolarCaseMaster $PolarCase
            set PolarTypeMaster $PolarType
            } else {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            set DataFormatActive "---"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    
if [file exists "$DataDirChannel2/config.txt"] {
set conf "false"
if [file exists "$DataDirChannel2/s11.bin"] {set conf "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set conf "true"}
if {$conf == "true"} {
    set ConfigFile "$DataDirChannel2/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if { "$PolarType" != "full"} {
            append config "slave"
            set configslave "D"
            if { "$PolarType" == "pp1"} {
                if [file exists "$DataDirChannel2/s11.bin"] {append configslave "1"}
                if [file exists "$DataDirChannel2/s21.bin"] {append configslave "2"}
                }
            if { "$PolarType" == "pp2"} {
                if [file exists "$DataDirChannel2/s12.bin"] {append configslave "1"}
                if [file exists "$DataDirChannel2/s22.bin"] {append configslave "2"}
                }
            if { "$PolarType" == "pp3"} {
                if [file exists "$DataDirChannel2/s11.bin"] {append configslave "1"}
                if [file exists "$DataDirChannel2/s22.bin"] {append configslave "2"}
                }
            set NligFullSizeSlave $NligFullSize
            set NcolFullSizeSlave $NcolFullSize
            set PolarCaseSlave $PolarCase
            set PolarTypeSlave $PolarType
            } else {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    
if {$config == "masterslave"} {
    set config "0"
    if {$configmaster == "D12"} {append config "1"}
    if {$configslave == "D12"} {append config "2"}
    if {$config == "012"} {
        set configmasterslave "0"
        if {$NligFullSizeMaster == $NligFullSizeSlave} {append configmasterslave "1"}
        if {$NcolFullSizeMaster == $NcolFullSizeSlave} {append configmasterslave "2"}
        if {$PolarCaseMaster == $PolarCaseSlave} {append configmasterslave "3"}
        if {$PolarTypeMaster == $PolarTypeSlave} {append configmasterslave "4"}
        if {$configmasterslave == "01234"} {
            set DataFormatActive "SPP"
            EnviWriteConfigCheck $DataDirChannel1 $NligFullSizeMaster $NcolFullSizeMaster $DataFormatActive
            EnviWriteConfigCheck $DataDirChannel2 $NligFullSizeSlave $NcolFullSizeSlave $DataFormatActive
            } else {
            set ErrorMessage "INPUT DATA MUST HAVE THE SAME SIZE AND TYPE"
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            set DataFormatActive "---"
            } 
        }
    }
set WindowShowDataFormatDual 0
    
Window hide $widget(Toplevel002); TextEditorRunTrace "Close Window Polarimetric Data Format" "b"} \
        -text {(Sxx, Sxy )} -value SPP -variable DataFormatActive 
    vTcl:DefineAlias "$top.cpd66" "Radiobutton2" vTcl:WidgetProc "Toplevel002" 1
    bindtags $top.cpd66 "$top.cpd66 Radiobutton $top all _vTclBalloon"
    bind $top.cpd66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dual-Pol Sinclair Channels}
    }
    radiobutton $top.rad66 \
        \
        -command {global DataDirChannel1 DataDirChannel2 DataFormatActive
global ConfigFile VarError ErrorMessage WindowShowDataFormatDual 

set Fonction ""; set Fonction2 ""
set ConfigFile ""

set config ""
if [file exists "$DataDirChannel1/config.txt"] {
if [file exists "$DataDirChannel1/s11.bin"] {
    set ConfigFile "$DataDirChannel1/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if { "$PolarType" == "full"} {
            set config "master"
            set configmaster "0"
            if [file exists "$DataDirChannel1/s11.bin"] {append configmaster "1"}
            if [file exists "$DataDirChannel1/s12.bin"] {append configmaster "2"}
            if [file exists "$DataDirChannel1/s21.bin"] {append configmaster "3"}
            if [file exists "$DataDirChannel1/s22.bin"] {append configmaster "4"}
            set NligFullSizeMaster $NligFullSize
            set NcolFullSizeMaster $NcolFullSize
            set PolarCaseMaster $PolarCase
            set PolarTypeMaster $PolarType
            set DataFormatActive "S2"
            } else {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            set DataFormatActive "---"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    
if [file exists "$DataDirChannel2/config.txt"] {
if [file exists "$DataDirChannel2/s11.bin"] {
    set ConfigFile "$DataDirChannel2/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if { "$PolarType" == "full"} {
            append config "slave"
            set configslave "0"
            if [file exists "$DataDirChannel2/s11.bin"] {append configslave "1"}
            if [file exists "$DataDirChannel2/s12.bin"] {append configslave "2"}
            if [file exists "$DataDirChannel2/s21.bin"] {append configslave "3"}
            if [file exists "$DataDirChannel2/s22.bin"] {append configslave "4"}
            set NligFullSizeSlave $NligFullSize
            set NcolFullSizeSlave $NcolFullSize
            set PolarCaseSlave $PolarCase
            set PolarTypeSlave $PolarType
            } else {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    
if {$config == "masterslave"} {
    set config "0"
    if {$configmaster == "01234"} {append config "1"}
    if {$configslave == "01234"} {append config "2"}
    if {$config == "012"} {
        set configmasterslave "0"
        if {$NligFullSizeMaster == $NligFullSizeSlave} {append configmasterslave "1"}
        if {$NcolFullSizeMaster == $NcolFullSizeSlave} {append configmasterslave "2"}
        if {$PolarCaseMaster == $PolarCaseSlave} {append configmasterslave "3"}
        if {$PolarTypeMaster == $PolarTypeSlave} {append configmasterslave "4"}
        if {$configmasterslave == "01234"} {
            set DataFormatActive "S2"
            EnviWriteConfigCheck $DataDirChannel1 $NligFullSizeMaster $NcolFullSizeMaster $DataFormatActive
            EnviWriteConfigCheck $DataDirChannel2 $NligFullSizeSlave $NcolFullSizeSlave $DataFormatActive
            } else {
            set ErrorMessage "INPUT DATA MUST HAVE THE SAME SIZE AND TYPE"
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            } 
        }
    }
set WindowShowDataFormatDual 0
    
Window hide $widget(Toplevel002); TextEditorRunTrace "Close Window Polarimetric Data Format" "b"} \
        -text {[S2]} -value S2 -variable DataFormatActive 
    vTcl:DefineAlias "$top.rad66" "Radiobutton1" vTcl:WidgetProc "Toplevel002" 1
    bindtags $top.rad66 "$top.rad66 Radiobutton $top all _vTclBalloon"
    bind $top.rad66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {2x2 Sinclair Matrix}
    }
    radiobutton $top.cpd67 \
        \
        -command {global DataDirChannel1 DataFormatActive
global ConfigFile VarError ErrorMessage WindowShowDataFormatDual 

set Fonction ""; set Fonction2 ""
set ConfigFile ""

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ConfigFile "$DataDirChannel1/T4/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set DataFormatActive "T4"
        EnviWriteConfigCheck "$DataDirChannel1/T4" $NligFullSize $NcolFullSize $DataFormatActive
        } else {
        set DataFormatActive "---"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set WindowShowDataFormatDual 0
    
Window hide $widget(Toplevel002); TextEditorRunTrace "Close Window Polarimetric Data Format" "b"} \
        -text {[T4]} -value T4 -variable DataFormatActive 
    vTcl:DefineAlias "$top.cpd67" "Radiobutton10" vTcl:WidgetProc "Toplevel002" 1
    bindtags $top.cpd67 "$top.cpd67 Radiobutton $top all _vTclBalloon"
    bind $top.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {4x4 Coherency Matrix}
    }
    radiobutton $top.cpd74 \
        \
        -command {global DataDirChannel1 DataFormatActive
global ConfigFile VarError ErrorMessage WindowShowDataFormatDual 

set Fonction ""; set Fonction2 ""
set ConfigFile ""

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ConfigFile "$DataDirChannel1/T6/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set DataFormatActive "T6"
        EnviWriteConfigCheck "$DataDirChannel1/T6" $NligFullSize $NcolFullSize $DataFormatActive
        } else {
        set DataFormatActive "---"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set WindowShowDataFormatDual 0
    
Window hide $widget(Toplevel002); TextEditorRunTrace "Close Window Polarimetric Data Format" "b"} \
        -text {[T6]} -value T6 -variable DataFormatActive 
    vTcl:DefineAlias "$top.cpd74" "Radiobutton9" vTcl:WidgetProc "Toplevel002" 1
    bindtags $top.cpd74 "$top.cpd74 Radiobutton $top all _vTclBalloon"
    bind $top.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {6x6 Coherency Matrix}
    }
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd66 \
        -in $top -anchor center -expand 1 -fill none -side left 
    pack $top.rad66 \
        -in $top -anchor center -expand 1 -fill none -side left 
    pack $top.cpd67 \
        -in $top -anchor center -expand 1 -fill none -side left 
    pack $top.cpd74 \
        -in $top -anchor center -expand 1 -fill none -side left 

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
Window show .top002

main $argc $argv
