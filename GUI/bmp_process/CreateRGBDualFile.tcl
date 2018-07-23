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

        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top309
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd113 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd113
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
    namespace eval ::widgets::$site_6_0.cpd116 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd117 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra42 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra42
    namespace eval ::widgets::$site_3_0.fra38 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra38
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-anchor 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra39
    namespace eval ::widgets::$site_4_0.fra42 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra42
    namespace eval ::widgets::$site_5_0.lab47 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab48 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab49 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra43 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra43
    namespace eval ::widgets::$site_5_0.lab52 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab53 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab54 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd115 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd115
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd107 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd107 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m24 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top309
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
    wm geometry $top 200x200+154+154; update
    wm maxsize $top 1684 1035
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

proc vTclWindow.top309 {base} {
    if {$base == ""} {
        set base .top309
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
    wm geometry $top 500x330+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create RGB Dual Files"
    vTcl:DefineAlias "$top" "Toplevel309" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd113 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd113" "Frame1" vTcl:WidgetProc "Toplevel309" 1
    set site_3_0 $top.cpd113
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel309" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RGBDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel309" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame16" vTcl:WidgetProc "Toplevel309" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd116 \
        \
        -command {global DirName DataDirChannel1 BMPDirInput RGBFunction RGBDirInput RGBDirOutput ConfigFile VarError ErrorMessage

set RGBFormat ""
set RGBFunction ""
set RGBDirInput ""
set VarError ""

set RGBDirInputTmp $BMPDirInput
set DirName ""
OpenDir $DataDirChannel1 "DATA INPUT DIRECTORY"
if {$DirName != ""} {
    set RGBDirInput "$DirName/T6"
    } else {
    set RGBDirInput $RGBDirInputTmp
    } 
set RGBDirOutput $RGBDirInput

set ConfigFile "$RGBDirInput/config.txt"
set ErrorMessage ""
LoadConfig
if {"$ErrorMessage" != ""} {
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBDirInput ""
    set RGBDirOutput ""
    if {$VarError == "cancel"} {Window hide $widget(Toplevel309); TextEditorRunTrace "Close Window Create RGB Dual Files" "b"}
    } else {
    if { "$PolarType" == "full"} {
        if [file exists "$RGBDirInput/T66.bin"] {set RGBFunction "T6"}
        } else {
        set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set ErrorMessage ""
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd116" "Button36" vTcl:WidgetProc "Toplevel309" 1
    bindtags $site_6_0.cpd116 "$site_6_0.cpd116 Button $top all _vTclBalloon"
    bind $site_6_0.cpd116 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd116 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel309" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel309" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel309" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd117 \
        \
        -command {global DirName DataDirChannel1 RGBDirOutput RGBFormat RGBFileOutputT1 RGBFileOutputT2

set RGBDirOutputTmp $RGBDirOutput
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set RGBDirOutput $DirName
    } else {
    set RGBDirOutput $RGBDirOutputTmp
    }
if {$RGBFormat == "pauli"} {
    set RGBFileOutputT1 "$RGBDirOutput/PauliRGB_T1.bmp"
    set RGBFileOutputT2 "$RGBDirOutput/PauliRGB_T2.bmp"
    }
if {$RGBFormat == "sinclair"} {
    set RGBFileOutputT1 "$RGBDirOutput/SinclairRGB_T1.bmp"
    set RGBFileOutputT2 "$RGBDirOutput/SinclairRGB_T2.bmp"
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd117 "$site_6_0.cpd117 Button $top all _vTclBalloon"
    bind $site_6_0.cpd117 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd117 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra41 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame9" vTcl:WidgetProc "Toplevel309" 1
    set site_3_0 $top.fra41
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel309" 1
    entry $site_3_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel309" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel309" 1
    entry $site_3_0.ent60 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel309" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel309" 1
    entry $site_3_0.ent62 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel309" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel309" 1
    entry $site_3_0.ent64 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel309" 1
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
    frame $top.fra42 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame67" vTcl:WidgetProc "Toplevel309" 1
    set site_3_0 $top.fra42
    frame $site_3_0.fra38 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra38" "Frame85" vTcl:WidgetProc "Toplevel309" 1
    set site_4_0 $site_3_0.fra38
    radiobutton $site_4_0.rad67 \
        -anchor center \
        -command {global RGBDirOutput RGBFileOutputT1 RGBFileOutputT2 RGBFormat

set RGBFormat "pauli"
set RGBFileOutputT1 "$RGBDirOutput/PauliRGB_T1.bmp"
set RGBFileOutputT2 "$RGBDirOutput/PauliRGB_T2.bmp"} \
        -text {Pauli Composition} -value pauli -variable RGBFormat 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton35" vTcl:WidgetProc "Toplevel309" 1
    radiobutton $site_4_0.rad68 \
        \
        -command {global RGBDirOutput RGBFileOutputT1 RGBFileOutputT2 RGBFormat

set RGBFormat "sinclair"
set RGBFileOutputT1 "$RGBDirOutput/SinclairRGB_T1.bmp"
set RGBFileOutputT2 "$RGBDirOutput/SinclairRGB_T2.bmp"} \
        -text {Sinclair Composition} -value sinclair -variable RGBFormat 
    vTcl:DefineAlias "$site_4_0.rad68" "Radiobutton36" vTcl:WidgetProc "Toplevel309" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor w -expand 0 -fill none -side top 
    pack $site_4_0.rad68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame86" vTcl:WidgetProc "Toplevel309" 1
    set site_4_0 $site_3_0.fra39
    frame $site_4_0.fra42 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra42" "Frame68" vTcl:WidgetProc "Toplevel309" 1
    set site_5_0 $site_4_0.fra42
    label $site_5_0.lab47 \
        -foreground #0000ff -padx 1 -text |S11+S22| 
    vTcl:DefineAlias "$site_5_0.lab47" "Label53" vTcl:WidgetProc "Toplevel309" 1
    label $site_5_0.lab48 \
        -foreground #008000 -padx 1 -text |S12+S21| 
    vTcl:DefineAlias "$site_5_0.lab48" "Label54" vTcl:WidgetProc "Toplevel309" 1
    label $site_5_0.lab49 \
        -foreground #ff0000 -padx 1 -text |S11-S22| 
    vTcl:DefineAlias "$site_5_0.lab49" "Label55" vTcl:WidgetProc "Toplevel309" 1
    pack $site_5_0.lab47 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab48 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab49 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.fra43 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra43" "Frame69" vTcl:WidgetProc "Toplevel309" 1
    set site_5_0 $site_4_0.fra43
    label $site_5_0.lab52 \
        -foreground #0000ff -padx 1 -text |S11| 
    vTcl:DefineAlias "$site_5_0.lab52" "Label57" vTcl:WidgetProc "Toplevel309" 1
    label $site_5_0.lab53 \
        -foreground #008000 -padx 1 -text |(S12+S21)/2| 
    vTcl:DefineAlias "$site_5_0.lab53" "Label58" vTcl:WidgetProc "Toplevel309" 1
    label $site_5_0.lab54 \
        -foreground #ff0000 -padx 1 -text |S22| 
    vTcl:DefineAlias "$site_5_0.lab54" "Label59" vTcl:WidgetProc "Toplevel309" 1
    pack $site_5_0.lab52 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab53 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab54 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra42 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.fra43 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.fra38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd115 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd115" "Frame3" vTcl:WidgetProc "Toplevel309" 1
    set site_3_0 $top.cpd115
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output RGB File - [T1]} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame10" vTcl:WidgetProc "Toplevel309" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBFileOutputT1 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel309" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame23" vTcl:WidgetProc "Toplevel309" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd107 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text button 
    pack $site_6_0.cpd107 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd72 \
        -ipad 0 -text {Output RGB File - [T2]} 
    vTcl:DefineAlias "$site_3_0.cpd72" "TitleFrame11" vTcl:WidgetProc "Toplevel309" 1
    bind $site_3_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBFileOutputT2 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh10" vTcl:WidgetProc "Toplevel309" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame24" vTcl:WidgetProc "Toplevel309" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd107 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text button 
    pack $site_6_0.cpd107 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel309" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global RGBDirInput RGBFunction RGBDirOutput RGBFileOutputT1 RGBFileOutputT2 RGBFormat BMPDirInput
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile PSPMemory TMPMemoryAllocError PSPViewGimpBMP
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax NcolFullSize NligFullSize

if {$OpenDirFile == 0} {

if {"$RGBDirInput"!=""} {

    #####################################################################
    #Create Directory
    set RGBDirOutput [PSPCreateDirectoryMask $RGBDirOutput $RGBDirOutput $RGBDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
    
        if {$RGBFormat != ""} {
            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            TestVar 4
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
                if {"$RGBFunction"=="T6"} {
                    set Fonction "Creation of the RGB BMP File :"
                    set Fonction2 "$RGBFileOutputT1"    
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    set config "true"
                    set fichier "$RGBDirInput/T11.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE T11.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    set fichier "$RGBDirInput/T22.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE T22.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    set fichier "$RGBDirInput/T33.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE T33.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if {"$RGBFormat"=="sinclair"} {
                        set fichier "$RGBDirInput/T12_real.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T12_real.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        }
                    if {"$config"=="true"} {
                        set MaskCmd ""
                        set MaskDir $RGBDirInput
                        set MaskFile "$MaskDir/mask_valid_pixels.bin"
                        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                        if {"$RGBFormat"=="pauli"} {
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file_T6.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT1\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 1 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
                            set f [ open "| Soft/bmp_process/create_pauli_rgb_file_T6.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT1\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 1 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutputT1 }
                            }
                        if {"$RGBFormat"=="sinclair"} {
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_sinclair_rgb_file_T6.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT1\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 1 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
                            set f [ open "| Soft/bmp_process/create_sinclair_rgb_file_T6.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT1\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 1 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutputT1 }
                            }
                        }                 
                    set Fonction "Creation of the RGB BMP File :"
                    set Fonction2 "$RGBFileOutputT2"    
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    set config "true"
                    set fichier "$RGBDirInput/T44.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE T44.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    set fichier "$RGBDirInput/T55.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE T55.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    set fichier "$RGBDirInput/T66.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE T66.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if {"$RGBFormat"=="sinclair"} {
                        set fichier "$RGBDirInput/T45_real.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T45_real.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        }
                    if {"$config"=="true"} {
                        set MaskCmd ""
                        set MaskDir $RGBDirInput
                        set MaskFile "$MaskDir/mask_valid_pixels.bin"
                        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                        if {"$RGBFormat"=="pauli"} {
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file_T6.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT2\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 2 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
                            set f [ open "| Soft/bmp_process/create_pauli_rgb_file_T6.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT2\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 2 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutputT2 }
                            }
                        if {"$RGBFormat"=="sinclair"} {
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_sinclair_rgb_file_T6.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT2\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 2 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
                            set f [ open "| Soft/bmp_process/create_sinclair_rgb_file_T6.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutputT2\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ch 2 $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutputT2 }
                            }
                        }                 
                    }                                  
                set RGBFormat ""
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel309); TextEditorRunTrace "Close Window Create RGB Dual Files" "b"}
        }
    } else {
    set RGBFormat ""
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel309" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CreateRGBDualFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel309" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel309); TextEditorRunTrace "Close Window Create RGB Dual Files" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel309" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit  the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m24 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd113 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra41 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra42 \
        -in $top -anchor center -expand 1 -fill none -side top 
    pack $top.cpd115 \
        -in $top -anchor center -expand 1 -fill x -side top 
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
Window show .top309

main $argc $argv
