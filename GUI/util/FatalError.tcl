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

        {{[file join . GUI Images RunError.gif]} {user image} user {}}
        {{[file join . GUI Images advice.gif]} {user image} user {}}

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
    set base .top236
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra33 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra33
    namespace eval ::widgets::$site_3_0.fra35 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra35
    namespace eval ::widgets::$site_4_0.lab37 {
        array set save {-background 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra36 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra36
    namespace eval ::widgets::$site_4_0.lab38 {
        array set save {-background 1 -foreground 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$base.fra34 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra34
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra66 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra66
    namespace eval ::widgets::$site_4_0.fra67 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra67
    namespace eval ::widgets::$site_5_0.lab68 {
        array set save {-background 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-background 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -relief 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -relief 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.but76 {
        array set save {-background 1 -command 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-_tooltip 1 -background 1 -borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top236
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
    wm geometry $top 200x200+110+110; update
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

proc vTclWindow.top236 {base} {
    if {$base == ""} {
        set base .top236
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -background #ff0000 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x100+200+200; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "FATAL  ERROR"
    vTcl:DefineAlias "$top" "Toplevel236" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra33 \
        -borderwidth 2 -background #ff0000 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra33" "Frame77" vTcl:WidgetProc "Toplevel236" 1
    set site_3_0 $top.fra33
    frame $site_3_0.fra35 \
        -borderwidth 2 -background #ff0000 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra35" "Frame79" vTcl:WidgetProc "Toplevel236" 1
    set site_4_0 $site_3_0.fra35
    label $site_4_0.lab37 \
        -background #ff0000 \
        -image [vTcl:image:get_image [file join . GUI Images RunError.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.lab37" "Label65" vTcl:WidgetProc "Toplevel236" 1
    pack $site_4_0.lab37 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.fra36 \
        -borderwidth 2 -background #ff0000 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra36" "Frame80" vTcl:WidgetProc "Toplevel236" 1
    set site_4_0 $site_3_0.fra36
    label $site_4_0.lab38 \
        -background #ffff00 -foreground #ff0000 -text ok \
        -textvariable FatalErrorMessage 
    vTcl:DefineAlias "$site_4_0.lab38" "Label66" vTcl:WidgetProc "Toplevel236" 1
    label $site_4_0.cpd71 \
        -background #ffff00 -foreground #ff0000 \
        -text {FATAL ERROR - ABNORMAL TERMINATION OF PolSARpro v5.0} 
    vTcl:DefineAlias "$site_4_0.cpd71" "Label67" vTcl:WidgetProc "Toplevel236" 1
    pack $site_4_0.lab38 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra35 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra36 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra34 \
        -borderwidth 2 -background #ff0000 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra34" "Frame78" vTcl:WidgetProc "Toplevel236" 1
    set site_3_0 $top.fra34
    button $site_3_0.but41 \
        \
        -command {global VarQuestion QuestionMessage
global SessionNameLogFid
global wshTutorial wshHelp
global VarFatalError

set VarFatalError "OK"
Window hide $widget(Toplevel236); TextEditorRunTrace "Close Window Fatal Error" "b"
CloseAllWidget
ClosePSPViewer
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
set Fonction "UNLOAD CONFIGURATION"
set Fonction2 "POLSARPRO v5.0"
set ProgressLine "100"
TextEditorRunTrace "Unload PolSARpro v5.0 Configuration" "r"
Window show $widget(Toplevel345); TextEditorRunTrace "Open Window Close PSP" "b"
update
set f [ open "| Soft/tools/unload_config.exe" r]
OpenCloseProgressBar $f
Window hide $widget(Toplevel345); TextEditorRunTrace "Close Window Close PSP" "b"
set Fonction ""; set Fonction2 ""

CleanTMPDirectory

#Close Log File
TextEditorRunTrace "Close Log File" "k"
catch "close $SessionNameLogFid"

Window hide $widget(Toplevel2); TextEditorRunTrace "Close Window PolSARpro v5.0 Main Menu" "b"
exit} \
        -pady 0 -text OK -width 10 
    vTcl:DefineAlias "$site_3_0.but41" "Button25" vTcl:WidgetProc "Toplevel236" 1
    frame $site_3_0.fra66 \
        -borderwidth 2 -background #ff0000 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra66" "Frame1" vTcl:WidgetProc "Toplevel236" 1
    set site_4_0 $site_3_0.fra66
    frame $site_4_0.fra67 \
        -borderwidth 2 -background #ff0000 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra67" "Frame2" vTcl:WidgetProc "Toplevel236" 1
    set site_5_0 $site_4_0.fra67
    label $site_5_0.lab68 \
        -background #ff0000 -text { } 
    vTcl:DefineAlias "$site_5_0.lab68" "Label236_1" vTcl:WidgetProc "Toplevel236" 1
    label $site_5_0.cpd70 \
        -background #ff0000 -text { } 
    vTcl:DefineAlias "$site_5_0.cpd70" "Label236_2" vTcl:WidgetProc "Toplevel236" 1
    pack $site_5_0.lab68 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd72 \
        -borderwidth 2 -background #ff0000 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame3" vTcl:WidgetProc "Toplevel236" 1
    set site_5_0 $site_4_0.cpd72
    entry $site_5_0.cpd74 \
        -background #ffffff -disabledbackground #ff0000 \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -relief flat -state disabled -textvariable geoscreenwidth -width 7 
    vTcl:DefineAlias "$site_5_0.cpd74" "Entry236_1" vTcl:WidgetProc "Toplevel236" 1
    entry $site_5_0.cpd75 \
        -background #ffffff -disabledbackground #ff0000 \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -relief flat -state disabled -textvariable geoscreenheight -width 7 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry236_2" vTcl:WidgetProc "Toplevel236" 1
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    button $site_4_0.but76 \
        -background #ff0000 \
        -command {global geoscreenwidth geoscreenheight CONFIGDir

set f [open "$CONFIGDir/ScreenSize.txt" w]
puts $f $geoscreenwidth
puts $f $geoscreenheight
close $f

$widget(Label236_1) configure -text ""
$widget(Label236_2) configure -text ""
$widget(Entry236_1) configure -state disable
$widget(Entry236_1) configure -relief flat
$widget(Entry236_2) configure -state disable
$widget(Entry236_2) configure -relief flat
$widget(Button236_1) configure -text ""
$widget(Button236_1) configure -state disable
$widget(Button236_1) configure -relief flat} \
        -pady 0 -relief flat -state disabled -text { } 
    vTcl:DefineAlias "$site_4_0.but76" "Button236_1" vTcl:WidgetProc "Toplevel236" 1
    pack $site_4_0.fra67 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.but76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    button $site_3_0.cpd68 \
        -background #ff0000 -borderwidth 0 \
        -command {$widget(Label236_1) configure -text "Screen Size Width"
$widget(Label236_2) configure -text "Screen Size Height"
$widget(Entry236_1) configure -state normal
$widget(Entry236_1) configure -relief sunken
$widget(Entry236_2) configure -state normal
$widget(Entry236_2) configure -relief sunken
$widget(Button236_1) configure -text "Save"
$widget(Button236_1) configure -state normal
$widget(Button236_1) configure -relief raised} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images advice.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_3_0.cpd68" "Button236_0" vTcl:WidgetProc "Toplevel236" 1
    bindtags $site_3_0.cpd68 "$site_3_0.cpd68 Button $top all _vTclBalloon"
    bind $site_3_0.cpd68 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Solve the Fatal error}
    }
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.fra66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra33 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.fra34 \
        -in $top -anchor center -expand 1 -fill x -side bottom 

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
Window show .top236

main $argc $argv
