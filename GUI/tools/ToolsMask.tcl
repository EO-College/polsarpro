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
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top383
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd95
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
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd109 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra27 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra27
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd109 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
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
            vTclWindow.top383
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
    wm geometry $top 200x200+44+44; update
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

proc vTclWindow.top383 {base} {
    if {$base == ""} {
        set base .top383
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
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Tools - Mask"
    vTcl:DefineAlias "$top" "Toplevel383" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd95" "Frame3" vTcl:WidgetProc "Toplevel383" 1
    set site_3_0 $top.cpd95
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame6" vTcl:WidgetProc "Toplevel383" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ToolsDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel383" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel383" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button38" vTcl:WidgetProc "Toplevel383" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel383" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ToolsOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel383" 1
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame1" vTcl:WidgetProc "Toplevel383" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab73" "Label1" vTcl:WidgetProc "Toplevel383" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ToolsOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel383" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel383" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd109 \
        \
        -command {global DirName DataDir ToolsOutputDir

set ToolsDirOutputTmp $ToolsOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set ToolsOutputDir $DirName
    } else {
    set ToolsOutputDir $ToolsDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd109 "$site_6_0.cpd109 Button $top all _vTclBalloon"
    bind $site_6_0.cpd109 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd109 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra27 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra27" "Frame9" vTcl:WidgetProc "Toplevel383" 1
    set site_3_0 $top.fra27
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel383" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel383" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel383" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel383" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel383" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel383" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel383" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel383" 1
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
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Mask File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame8" vTcl:WidgetProc "Toplevel383" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ToolsMaskFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel383" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel383" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd109 \
        \
        -command {global FileName ToolsDirInput ToolsMaskFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE MASK FILE MUST HAVE THE SAME"
set WarningMessage2 "DATA SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Mask File}        {.dat}        }
{{Mask File}        {.bin}        }
}
set FileName ""
OpenFile "$ToolsDirInput" $types "MASK FILE"
if {$FileName != ""} {
    set ToolsMaskFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    bindtags $site_5_0.cpd109 "$site_5_0.cpd109 Button $top all _vTclBalloon"
    bind $site_5_0.cpd109 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd109 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra41 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame20" vTcl:WidgetProc "Toplevel383" 1
    set site_3_0 $top.fra41
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir
global ToolsOperation ToolsFormat ToolsFunction ToolsFonction ToolsErase ToolsMaskFile
global Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 ProgressLine
global NcolFullSize ConfigFile FinalNlig FinalNcol PolarCase PolarType OpenDirFile

if {$OpenDirFile == 0} {

set ToolsDirOutput $ToolsOutputDir
if {$ToolsOutputSubDir != ""} { append ToolsDirOutput "/$ToolsOutputSubDir"}

    #####################################################################
    #Create Directory
    set ToolsDirOutput [PSPCreateDirectory $ToolsDirOutput $ToolsOutputDir $ToolsFormat]
    #####################################################################       

if {"$VarWarning"=="ok"} {

    set Fonction $ToolsFonction
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    if {$ToolsFormat == "S2"} {set FormatTools "sinclair"}
    if {$ToolsFormat == "SPP"} {set FormatTools "sinclair"}
    if {$ToolsFormat == "IPP"} {set FormatTools "intensity"}
    if {$ToolsFormat == "T3"} {set FormatTools "coherency"}
    if {$ToolsFormat == "T4"} {set FormatTools "coherency"}
    if {$ToolsFormat == "T6"} {set FormatTools "coherency"}
    if {$ToolsFormat == "C2"} {set FormatTools "covariance"}
    if {$ToolsFormat == "C3"} {set FormatTools "covariance"}
    if {$ToolsFormat == "C4"} {set FormatTools "covariance"}

    if {$FormatTools == "sinclair"} {
        if [file exists "$ToolsDirInput/s11.bin"] {
            set ToolsFileInput "$ToolsDirInput/s11.bin"
            set ToolsFileOutput "$ToolsDirOutput/s11.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/s21.bin"] {
            set ToolsFileInput "$ToolsDirInput/s21.bin"
            set ToolsFileOutput "$ToolsDirOutput/s21.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/s12.bin"] {
            set ToolsFileInput "$ToolsDirInput/s12.bin"
            set ToolsFileOutput "$ToolsDirOutput/s12.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/s22.bin"] {
            set ToolsFileInput "$ToolsDirInput/s22.bin"
            set ToolsFileOutput "$ToolsDirOutput/s22.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }

        MapInfoWriteConfig $ToolsDirOutput
        set ConfigFile "$ToolsDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        EnviWriteConfigS $ToolsDirOutput $NligFullSize $NcolFullSize     
        }

    if {$FormatTools == "intensity"} {
        if [file exists "$ToolsDirInput/I11.bin"] {
            set ToolsFileInput "$ToolsDirInput/I11.bin"
            set ToolsFileOutput "$ToolsDirOutput/I11.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/I12.bin"] {
            set ToolsFileInput "$ToolsDirInput/I12.bin"
            set ToolsFileOutput "$ToolsDirOutput/I12.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/I21.bin"] {
            set ToolsFileInput "$ToolsDirInput/I21.bin"
            set ToolsFileOutput "$ToolsDirOutput/I21.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/I22.bin"] {
            set ToolsFileInput "$ToolsDirInput/I22.bin"
            set ToolsFileOutput "$ToolsDirOutput/I22.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }

        MapInfoWriteConfig $ToolsDirOutput
        set ConfigFile "$ToolsDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        EnviWriteConfigI $ToolsDirOutput $NligFullSize $NcolFullSize     
        }
        
    if {$FormatTools == "coherency"} {
        if [file exists "$ToolsDirInput/T11.bin"] {
            set ToolsFileInput "$ToolsDirInput/T11.bin"
            set ToolsFileOutput "$ToolsDirOutput/T11.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T12_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T12_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T12_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T12_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T12_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T12_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T13_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T13_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T13_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T13_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T13_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T13_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T14_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T14_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T14_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T14_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T14_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T14_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T15_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T15_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T15_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T15_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T15_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T15_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T16_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T16_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T16_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T16_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T16_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T16_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T22.bin"] {
            set ToolsFileInput "$ToolsDirInput/T22.bin"
            set ToolsFileOutput "$ToolsDirOutput/T22.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T23_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T23_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T23_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T23_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T23_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T23_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T24_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T24_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T24_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T24_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T24_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T24_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T25_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T25_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T25_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T25_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T25_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T25_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T26_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T26_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T26_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T26_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T26_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T26_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T33.bin"] {
            set ToolsFileInput "$ToolsDirInput/T33.bin"
            set ToolsFileOutput "$ToolsDirOutput/T33.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T34_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T34_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T34_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T34_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T34_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T34_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T35_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T35_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T35_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T35_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T35_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T35_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T36_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T36_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T36_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T36_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T36_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T36_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T44.bin"] {
            set ToolsFileInput "$ToolsDirInput/T44.bin"
            set ToolsFileOutput "$ToolsDirOutput/T44.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T45_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T45_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T45_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T45_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T45_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T45_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T46_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T46_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T46_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T46_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T46_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T46_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T55.bin"] {
            set ToolsFileInput "$ToolsDirInput/T55.bin"
            set ToolsFileOutput "$ToolsDirOutput/T55.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T56_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/T56_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/T56_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T56_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/T56_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/T56_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/T66.bin"] {
            set ToolsFileInput "$ToolsDirInput/T66.bin"
            set ToolsFileOutput "$ToolsDirOutput/T66.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }

        MapInfoWriteConfig $ToolsDirOutput
        set ConfigFile "$ToolsDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        EnviWriteConfigT $ToolsDirOutput $NligFullSize $NcolFullSize     
        }
    
    if {$FormatTools == "covariance"} {
        if [file exists "$ToolsDirInput/C11.bin"] {
            set ToolsFileInput "$ToolsDirInput/C11.bin"
            set ToolsFileOutput "$ToolsDirOutput/C11.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C12_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/C12_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/C12_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C12_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/C12_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/C12_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C13_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/C13_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/C13_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C13_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/C13_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/C13_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C14_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/C14_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/C14_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C14_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/C14_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/C14_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C22.bin"] {
            set ToolsFileInput "$ToolsDirInput/C22.bin"
            set ToolsFileOutput "$ToolsDirOutput/C22.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C23_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/C23_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/C23_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C23_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/C23_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/C23_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C24_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/C24_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/C24_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C24_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/C24_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/C24_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C33.bin"] {
            set ToolsFileInput "$ToolsDirInput/C33.bin"
            set ToolsFileOutput "$ToolsDirOutput/C33.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C34_real.bin"] {
            set ToolsFileInput "$ToolsDirInput/C34_real.bin"
            set ToolsFileOutput "$ToolsDirOutput/C34_real.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C34_imag.bin"] {
            set ToolsFileInput "$ToolsDirInput/C34_imag.bin"
            set ToolsFileOutput "$ToolsDirOutput/C34_imag.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if [file exists "$ToolsDirInput/C44.bin"] {
            set ToolsFileInput "$ToolsDirInput/C44.bin"
            set ToolsFileOutput "$ToolsDirOutput/C44.bin"
            set Fonction2 $ToolsFileOutput
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ToolsFunction" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| $ToolsFunction -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirOutput\x22 -if \x22$ToolsFileInput\x22 -of \x22$ToolsFileOutput\x22 -mf \x22$ToolsMaskFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }

        MapInfoWriteConfig $ToolsDirOutput
        set ConfigFile "$ToolsDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        EnviWriteConfigC $ToolsDirOutput $NligFullSize $NcolFullSize     
        }

    append DataDir "_MASK"
        
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    Window hide $widget(Toplevel383); TextEditorRunTrace "Close Window Tools - Mask" "b"
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel29); TextEditorRunTrace "Close Window Tools - Mask" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel383" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataFileManagement.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel383" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel383); TextEditorRunTrace "Close Window Tools - Mask" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel383" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
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
    pack $top.cpd95 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra27 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra41 \
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
Window show .top383

main $argc $argv
