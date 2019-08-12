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
    set base .top521
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
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
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra56 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra56
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd69
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
    namespace eval ::widgets::$base.fra78 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra78
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.rad71 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra82
    namespace eval ::widgets::$site_4_0.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra83
    namespace eval ::widgets::$site_5_0.lab84 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent85 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd86
    namespace eval ::widgets::$site_5_0.lab84 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent85 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.che87 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -anchor 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m71 {
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
            vTclWindow.top521
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
    wm geometry $top 200x200+66+66; update
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

proc vTclWindow.top521 {base} {
    if {$base == ""} {
        set base .top521
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m71" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x250+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing : Change Detector"
    vTcl:DefineAlias "$top" "Toplevel521" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame1" vTcl:WidgetProc "Toplevel521" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Reference Input File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel521" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ChangeDetectorInputFile1 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel521" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel521" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd87 \
        \
        -command {global ChangeDetectorInputFile1
global NligInitFile1 NligEndFile1 NcolInitFile1 NcolEndFile1
global FileName VarError ErrorMessage

set NligInitFile1 ""
set NligEndFile1 ""
set NcolInitFile1 ""
set NcolEndFile1 ""
set ChangeDetectorInputFile1 ""

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $ChangeDetectorDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set NcolEndFile1 [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set NligEndFile1 [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            set ChangeDetectorInputFile1 $FileName
            set NligInitFile1 1
            set NcolInitFile1 1
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp != "data type = 4"} {
                set config "false"
                set ErrorMessage "THE INPUT FILE FORMAT MUST BE FLOAT FORMAT"
                WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set NligInitFile1 ""; set NligEndFile1 ""
                set NcolInitFile1 ""; set NcolEndFile1 ""
                set ChangeDetectorInputFile1 ""             
                }
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE"
            WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            if {$VarError == "cancel"} {Window hide $widget(Toplevel521); TextEditorRunTrace "Close Window Change Detector File" "b"}
            set ChangeDetectorInputFile1 ""
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel521); TextEditorRunTrace "Close Window Change Detector File" "b"}
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd87 "$site_6_0.cpd87 Button $top all _vTclBalloon"
    bind $site_6_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra56 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra56" "Frame9" vTcl:WidgetProc "Toplevel521" 1
    set site_3_0 $top.fra56
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel521" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInitFile1 -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel521" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel521" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEndFile1 -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel521" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel521" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInitFile1 -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel521" 1
    label $site_3_0.lab63 \
        -padx 1 -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel521" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEndFile1 -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel521" 1
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
    frame $top.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd69" "Frame3" vTcl:WidgetProc "Toplevel521" 1
    set site_3_0 $top.cpd69
    TitleFrame $site_3_0.cpd98 \
        -ipad 2 -text {Output File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel521" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ChangeDetectorOutputFile 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel521" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra78" "Frame4" vTcl:WidgetProc "Toplevel521" 1
    set site_3_0 $top.fra78
    TitleFrame $site_3_0.cpd81 \
        -text {Change Detector} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame2" vTcl:WidgetProc "Toplevel521" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    frame $site_5_0.cpd75
    set site_6_0 $site_5_0.cpd75
    radiobutton $site_6_0.rad71 \
        \
        -command {global ChangeDetectorOutputFile ChangeDetectorInputFile1

set ChangeDetectorOutputFile [file rootname $ChangeDetectorInputFile1]
append ChangeDetectorOutputFile "_1_2_CD_MRD.bin"} \
        -text {Mean Ratio Detector (MRD)} -value mrd \
        -variable ChangeDetectorName 
    vTcl:DefineAlias "$site_6_0.rad71" "Radiobutton5" vTcl:WidgetProc "Toplevel521" 1
    pack $site_6_0.rad71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd76
    set site_6_0 $site_5_0.cpd76
    radiobutton $site_6_0.cpd72 \
        \
        -command {global ChangeDetectorOutputFile ChangeDetectorInputFile1

set ChangeDetectorOutputFile [file rootname $ChangeDetectorInputFile1]
append ChangeDetectorOutputFile "_1_2_CD_GKLD.bin"} \
        -text {Gaussian Kullback Liebler Detector (GKLD)} -value gkld \
        -variable ChangeDetectorName 
    vTcl:DefineAlias "$site_6_0.cpd72" "Radiobutton9" vTcl:WidgetProc "Toplevel521" 1
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd77
    set site_6_0 $site_5_0.cpd77
    radiobutton $site_6_0.cpd74 \
        \
        -command {global ChangeDetectorOutputFile ChangeDetectorInputFile1

set ChangeDetectorOutputFile [file rootname $ChangeDetectorInputFile1]
append ChangeDetectorOutputFile "_1_2_CD_CKLD.bin"} \
        -text {Cumulant Kullback Liebler Detector (CKLD)} -value ckld \
        -variable ChangeDetectorName 
    vTcl:DefineAlias "$site_6_0.cpd74" "Radiobutton13" vTcl:WidgetProc "Toplevel521" 1
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.fra82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra82" "Frame5" vTcl:WidgetProc "Toplevel521" 1
    set site_4_0 $site_3_0.fra82
    frame $site_4_0.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra83" "Frame6" vTcl:WidgetProc "Toplevel521" 1
    set site_5_0 $site_4_0.fra83
    label $site_5_0.lab84 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_5_0.lab84" "Label1" vTcl:WidgetProc "Toplevel521" 1
    entry $site_5_0.ent85 \
        -background white -foreground #ff0000 -justify center \
        -textvariable ChangeDetectorNwinL -width 5 
    vTcl:DefineAlias "$site_5_0.ent85" "Entry1" vTcl:WidgetProc "Toplevel521" 1
    pack $site_5_0.lab84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    frame $site_4_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd86" "Frame7" vTcl:WidgetProc "Toplevel521" 1
    set site_5_0 $site_4_0.cpd86
    label $site_5_0.lab84 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_5_0.lab84" "Label2" vTcl:WidgetProc "Toplevel521" 1
    entry $site_5_0.ent85 \
        -background white -foreground #ff0000 -justify center \
        -textvariable ChangeDetectorNwinC -width 5 
    vTcl:DefineAlias "$site_5_0.ent85" "Entry2" vTcl:WidgetProc "Toplevel521" 1
    pack $site_5_0.lab84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    checkbutton $site_4_0.che87 \
        -text BMP -variable ChangeDetectorBMP 
    vTcl:DefineAlias "$site_4_0.che87" "Checkbutton1" vTcl:WidgetProc "Toplevel521" 1
    pack $site_4_0.fra83 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.che87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra82 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel521" 1
    set site_3_0 $top.fra92
    button $site_3_0.but93 \
        -anchor center -background #ffff00 \
        -command {global ChangeDetectorDirOutput ChangeDetectorOutputFile
global ChangeDetectorInputFile1 ChangeDetectorInputFile2
global ChangeDetectorName ChangeDetectorNwinL ChangeDetectorNwinC
global NligInitFile1 NligEndFile1 NcolInitFile1 NcolEndFile1
global NligInitFile2 NligEndFile2 NcolInitFile2 NcolEndFile2
global TMPMemoryAllocError ChangeDetectorBMP
global DataDirMult NDataDirMult DataFormatActive

if {$OpenDirFile == 0} {

set config "true"
if {$ChangeDetectorInputFile1 == ""} { set config "false" }
if {$config == "true"} {

    #####################################################################
    #Create Directory
    set ChangeDetectorDirOutput [PSPCreateDirectoryMask $ChangeDetectorDirOutput $ChangeDetectorDirOutput $ChangeDetectorDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {

    set TestVarName(0) "Window Size Row"; set TestVarType(0) "int"; set TestVarValue(0) $ChangeDetectorNwinL; set TestVarMin(0) "1"; set TestVarMax(0) "100"
    set TestVarName(1) "Window Size Col"; set TestVarType(1) "int"; set TestVarValue(1) $ChangeDetectorNwinC; set TestVarMin(1) "1"; set TestVarMax(1) "100"
    TestVar 2
    if {$TestVarError == "ok"} {

        set FinalNlig [expr $NligEndFile1 - $NligInitFile1 + 1]
        set FinalNcol [expr $NcolEndFile1 - $NcolInitFile1 + 1]
        set MaskCmd ""
        set MaskFile [file dirname $ChangeDetectorInputFile1]
        append MaskFile "/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"

###############################################################################

        for {set ii 2} {$ii <= $NDataDirMult} {incr ii} {

            if {$DataFormatActive == "S2"} { set ChangeDetectorInputFile2 "$DataDirMult($ii)/" }
            if {$DataFormatActive == "C2"} { set ChangeDetectorInputFile2 "$DataDirMult($ii)/C2/" }
            if {$DataFormatActive == "T3"} { set ChangeDetectorInputFile2 "$DataDirMult($ii)/T3/" }
            if {$DataFormatActive == "SPP"} { set ChangeDetectorInputFile2 "$DataDirMult($ii)/" }
            append ChangeDetectorInputFile2 [file tail $ChangeDetectorInputFile1]

            set ChangeDetectorOutputFile [file rootname $ChangeDetectorInputFile1]
            append ChangeDetectorOutputFile "_1_$ii"
            if { $ChangeDetectorName == "mrd" } {append ChangeDetectorOutputFile "_CD_MRD.bin"}
            if { $ChangeDetectorName == "gkld" } {append ChangeDetectorOutputFile "_CD_GKLD.bin"}
            if { $ChangeDetectorName == "ckld" } {append ChangeDetectorOutputFile "_CD_CKLD.bin"}

            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/change_detector.exe" "k"
            TextEditorRunTrace "Arguments: -if1 \x22$ChangeDetectorInputFile1\x22 -if2 \x22$ChangeDetectorInputFile2\x22 -of \x22$ChangeDetectorOutputFile\x22 -det $ChangeDetectorName -nwr $ChangeDetectorNwinL -nwc $ChangeDetectorNwinC -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -inc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/change_detector.exe -if1 \x22$ChangeDetectorInputFile1\x22 -if2 \x22$ChangeDetectorInputFile2\x22 -of \x22$ChangeDetectorOutputFile\x22 -det $ChangeDetectorName -nwr $ChangeDetectorNwinL -nwc $ChangeDetectorNwinC -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -inc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            if [file exists $ChangeDetectorOutputFile] {EnviWriteConfig $ChangeDetectorOutputFile $FinalNlig $FinalNcol 4}

            if {$ChangeDetectorBMP == "1"} {
                if [file exists $ChangeDetectorOutputFile] {
                    set BMPFileInput $ChangeDetectorOutputFile
                    set BMPFileOutput [file rootname $ChangeDetectorOutputFile]; append BMPFileOutput ".bmp"
                    set BMPDirInput [file dirname $ChangeDetectorOutputFile]
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }

###############################################################################
            }
            #ii

        WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"
        Window hide $widget(Toplevel521); TextEditorRunTrace "Close Window Change Detector File" "b"
        }
    }


    } else {
    set ErrorMessage "ENTER THE INPUT FILES FIRST"
    WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ChangeDetectorInputFile1 ""; set ChangeDetectorInputFile2 ""
    set NligInitFile1 ""; set NligEndFile1 ""; set NcolInitFile1 ""; set NcolEndFile1 ""
    set NligInitFile2 ""; set NligEndFile2 ""; set NcolInitFile2 ""; set NcolEndFile2 ""
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel521" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Valid the Selection}
    }
    button $site_3_0.but24 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ChangeDetectorFileMult.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -padx 4 -pady 2 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel521" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    button $site_3_0.cpd68 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel521); TextEditorRunTrace "Close Window Change Detector File" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.cpd68" "Button17" vTcl:WidgetProc "Toplevel521" 1
    bindtags $site_3_0.cpd68 "$site_3_0.cpd68 Button $top all _vTclBalloon"
    bind $site_3_0.cpd68 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra56 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra78 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra92 \
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
Window show .top521

main $argc $argv
