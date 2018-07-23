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

        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
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
    set base .top98
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd90 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd90
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra100 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra100
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
    namespace eval ::widgets::$base.ent101 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd93
    namespace eval ::widgets::$site_5_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent44 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd94
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd96
    namespace eval ::widgets::$site_5_0.but67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but68 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but22 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent69 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd70
    namespace eval ::widgets::$site_4_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent69 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra103 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra103
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m22 {
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
            vTclWindow.top98
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
    wm geometry $top 200x200+25+25; update
    wm maxsize $top 3360 1028
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

proc vTclWindow.top98 {base} {
    if {$base == ""} {
        set base .top98
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m22" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x290+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: O.P.C.E"
    vTcl:DefineAlias "$top" "Toplevel98" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd90 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd90" "Frame4" vTcl:WidgetProc "Toplevel98" 1
    set site_3_0 $top.cpd90
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel98" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable OPCEDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel98" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel98" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel98" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel98" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable OPCEOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel98" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel98" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel98" 1
    entry $site_6_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable OPCEOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd72" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel98" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame18" vTcl:WidgetProc "Toplevel98" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd91 \
        \
        -command {global DirName DataDir OPCEDirOutput OPCEOutputDir OPCEOutputSubDir OPCEFileTrainingArea OPCEFileTrainingSet
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol CONFIGDir

set OPCEDirOutputTmp $OPCEOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set OPCEOutputDir $DirName
    } else {
    set OPCEOutputDir $OPCEDirOutputTmp
    }

set OPCEDirOutput $OPCEOutputDir
if {$OPCEOutputSubDir != ""} {append OPCEDirOutput "/$OPCEOutputSubDir"}

set OPCEFileTrainingSet "$OPCEDirOutput/OPCEtraining_cluster_centers.bin"
    
if [file exists "$OPCEDirOutput/OPCE_areas.txt"] {
    set OPCEFileTrainingArea "$OPCEDirOutput/OPCE_areas.txt"
    } else {
    set OPCEFileTrainingArea "$CONFIGDir/OPCE_areas.txt"
    } 
WaitUntilCreated $OPCEFileTrainingArea 
set f [open $OPCEFileTrainingArea r]
gets $f tmp
gets $f NTrainingAreaClass
gets $f tmp
for {set i 1} {$i <= $NTrainingAreaClass} {incr i} {
    gets $f tmp
    gets $f tmp
    gets $f NTrainingArea($i)
    gets $f tmp
    for {set j 1} {$j <= $NTrainingArea($i)} {incr j} {
        gets $f tmp
        gets $f NAreaPoint
        set Argument [expr (100*$i + $j)]
        set AreaPoint($Argument) $NAreaPoint
        for {set k 1} {$k <= $NAreaPoint} {incr k} {
            gets $f tmp
            set Argument1 [expr (10000*$i + 100*$j + $k)]
            gets $f tmp
            gets $f AreaPointLig($Argument1)
            gets $f tmp
            gets $f AreaPointCol($Argument1)
            }
        gets $f tmp
        }
    }
close $f
set AreaClassN 1
set AreaN 1} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button82" vTcl:WidgetProc "Toplevel98" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra100 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra100" "Frame9" vTcl:WidgetProc "Toplevel98" 1
    set site_3_0 $top.fra100
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel98" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel98" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel98" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel98" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel98" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel98" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel98" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel98" 1
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
    entry $top.ent101 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Fonction -width 44 
    vTcl:DefineAlias "$top.ent101" "Entry138" vTcl:WidgetProc "Toplevel98" 1
    TitleFrame $top.tit92 \
        -ipad 0 -text {Target / Clutter Areas} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame1" vTcl:WidgetProc "Toplevel98" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    frame $site_4_0.cpd93 \
        -relief groove -height 77 -width 437 
    vTcl:DefineAlias "$site_4_0.cpd93" "Frame270" vTcl:WidgetProc "Toplevel98" 1
    set site_5_0 $site_4_0.cpd93
    label $site_5_0.lab42 \
        -text {Areas File  } 
    vTcl:DefineAlias "$site_5_0.lab42" "Label275" vTcl:WidgetProc "Toplevel98" 1
    entry $site_5_0.ent44 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable OPCEFileTrainingArea 
    vTcl:DefineAlias "$site_5_0.ent44" "Entry188" vTcl:WidgetProc "Toplevel98" 1
    frame $site_5_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd94" "Frame17" vTcl:WidgetProc "Toplevel98" 1
    set site_6_0 $site_5_0.cpd94
    button $site_6_0.cpd95 \
        \
        -command {global FileName OPCEDirInput OPCEFileTrainingArea
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol

set OPCEFileTrainingAreaTmp $OPCEFileTrainingArea

set types {
{{TXT Files}        {.txt}        }
}
set FileName ""
OpenFile "$OPCEDirInput" $types "OPCE AREAS FILE"
if {$FileName != ""} {
    set OPCEFileTrainingArea $FileName
    }

WaitUntilCreated $OPCEFileTrainingArea 
if [file exists $OPCEFileTrainingArea] {
    set f [open $OPCEFileTrainingArea r]
    gets $f tmp
    if {$tmp == "NB_TRAINING_TARGET_CLUTTER_CLASSES"} {
        gets $f NTrainingAreaClass
        gets $f tmp
        for {set i 1} {$i <= $NTrainingAreaClass} {incr i} {
            gets $f tmp
            gets $f tmp
            gets $f NTrainingArea($i)
            gets $f tmp
            for {set j 1} {$j <= $NTrainingArea($i)} {incr j} {
                gets $f tmp
                gets $f NAreaPoint
                set Argument [expr (100*$i + $j)]
                set AreaPoint($Argument) $NAreaPoint
                for {set k 1} {$k <= $NAreaPoint} {incr k} {
                    gets $f tmp
                    set Argument1 [expr (10000*$i + 100*$j + $k)]
                    gets $f tmp
                    gets $f AreaPointLig($Argument1)
                    gets $f tmp
                    gets $f AreaPointCol($Argument1)
                    }
                gets $f tmp
                }
            }
        close $f
        set AreaClassN 1
        set AreaN 1
        } else {
        set ErrorMessage "OPCE AREAS FILE NOT VALID"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set OPCEFileTrainingArea $OPCEFileTrainingAreaTmp
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd95" "Button147" vTcl:WidgetProc "Toplevel98" 1
    bindtags $site_6_0.cpd95 "$site_6_0.cpd95 Button $top all _vTclBalloon"
    bind $site_6_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.lab42 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent44 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd96 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd96" "Frame474" vTcl:WidgetProc "Toplevel98" 1
    set site_5_0 $site_4_0.cpd96
    button $site_5_0.but67 \
        -background #ffff00 \
        -command {global VarOPCEArea NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint AreaPointN
global BMPDirInput rect_color OpenDirFile
global MouseInitX MouseInitY MouseEndX MouseEndY MouseNlig MouseNcol TrainingAreaToolLine

if {$OpenDirFile == 0} {

ClosePSPViewer

set WarningMessage "OPEN A BMP FILE TO SELECT"
set WarningMessage2 "THE TARGET / CLUTTER AREAS"
set VarWarning ""
Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
tkwait variable VarWarning

if {$VarWarning == "ok"} {

LoadPSPViewer

set NTrainingAreaClassTmp $NTrainingAreaClass
for {set i 1} {$i <= $NTrainingAreaClass} {incr i} {
    set NTrainingAreaTmp($i) $NTrainingArea($i)
    for {set j 1} {$j <= $NTrainingArea($i)} {incr j} {
        set Argument [expr (100*$i + $j)]
        set AreaPointTmp($Argument) $AreaPoint($Argument)
        set NAreaPoint $AreaPoint($Argument)
        for {set k 1} {$k <= $NAreaPoint} {incr k} {
            set Argument [expr (10000*$i + 100*$j + $k)]
            set AreaPointLigTmp($Argument) $AreaPointLig($Argument)
            set AreaPointColTmp($Argument) $AreaPointCol($Argument)
            }
        }
    }

set BMPDirInput $OPCEDirInput
Window show $widget(Toplevel64); TextEditorRunTrace "Open Window PolSARpro Viewer" "b"

set MouseInitX $AreaPointCol(10101)
set MouseInitY $AreaPointLig(10101)
set MouseEndX [expr $AreaPointCol(10101) + $MouseInitX -1]
set MouseEndY [expr $AreaPointLig(10101) + $MouseInitY -1]
set MouseNlig [expr abs($MouseEndY - $MouseInitY) +1]
set MouseNcol [expr abs($MouseEndX - $MouseInitX) +1]
set AreaClassN 1
set AreaN 1
set AreaPointN ""
set TrainingAreaToolLine "false"

set rect_color "white"

set VarOPCEArea "no"
WidgetShowFromWidget $widget(Toplevel98) $widget(Toplevel96); TextEditorRunTrace "Open Window O.P.C.E Graphic Editor" "b"
tkwait variable VarOPCEArea

#Return after Graphic Editor Exit
if {"$VarOPCEArea"=="no"} {
    set NTrainingAreaClass $NTrainingAreaClassTmp
    for {set i 1} {$i <= $NTrainingAreaClass} {incr i} {
        set NTrainingArea($i) $NTrainingAreaTmp($i)
        for {set j 1} {$j <= $NTrainingArea($i)} {incr j} {
            set Argument [expr (100*$i + $j)]
            set AreaPoint($Argument) $AreaPointTmp($Argument)
            set NAreaPoint $AreaPointTmp($Argument)          
            for {set k 1} {$k <= $NAreaPoint} {incr k} {
                set Argument [expr (10000*$i + 100*$j + $k)]
                set AreaPointLig($Argument) $AreaPointLigTmp($Argument)
                set AreaPointCol($Argument) $AreaPointColTmp($Argument)
                }
            }
        }
    set AreaClassN 1
    set AreaN 1
    }

set BMPTrainingRect "0"
MouseActiveFunction ""

}
}} \
        -padx 4 -pady 2 -text {Graphic Editor} 
    vTcl:DefineAlias "$site_5_0.but67" "Button642" vTcl:WidgetProc "Toplevel98" 1
    bindtags $site_5_0.but67 "$site_5_0.but67 Button $top all _vTclBalloon"
    bind $site_5_0.but67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target / Clutter Areas Graphic Editor}
    }
    button $site_5_0.but68 \
        -background #ffff00 \
        -command {global OPCEFileTrainingArea OpenDirFile
#UTIL
global Load_TextEdit PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

TextEditorFromWidget .top98 $OPCEFileTrainingArea
}} \
        -padx 4 -pady 2 -text {Text Editor} 
    vTcl:DefineAlias "$site_5_0.but68" "Button643" vTcl:WidgetProc "Toplevel98" 1
    bindtags $site_5_0.but68 "$site_5_0.but68 Button $top all _vTclBalloon"
    bind $site_5_0.but68 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target / Clutter Areas Text Editor}
    }
    button $site_5_0.but22 \
        -background #ffff00 \
        -command {global OPCEFileResults OpenDirFile
#UTIL
global Load_TextEdit PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

TextEditorFromWidget .top98 $OPCEFileResults
}} \
        -padx 4 -pady 2 -text {Edit OPCE Results} 
    vTcl:DefineAlias "$site_5_0.but22" "Button98_1" vTcl:WidgetProc "Toplevel98" 1
    bindtags $site_5_0.but22 "$site_5_0.but22 Button $top all _vTclBalloon"
    bind $site_5_0.but22 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit OPCE Results}
    }
    pack $site_5_0.but67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but22 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame1" vTcl:WidgetProc "Toplevel98" 1
    set site_3_0 $top.fra66
    frame $site_3_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame2" vTcl:WidgetProc "Toplevel98" 1
    set site_4_0 $site_3_0.fra67
    label $site_4_0.lab68 \
        -text {Window Size Row} 
    vTcl:DefineAlias "$site_4_0.lab68" "Label1" vTcl:WidgetProc "Toplevel98" 1
    entry $site_4_0.ent69 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinOPCEL -width 5 
    vTcl:DefineAlias "$site_4_0.ent69" "Entry1" vTcl:WidgetProc "Toplevel98" 1
    pack $site_4_0.lab68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd70" "Frame3" vTcl:WidgetProc "Toplevel98" 1
    set site_4_0 $site_3_0.cpd70
    label $site_4_0.lab68 \
        -text {Window Size Col} 
    vTcl:DefineAlias "$site_4_0.lab68" "Label2" vTcl:WidgetProc "Toplevel98" 1
    entry $site_4_0.ent69 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinOPCEC -width 5 
    vTcl:DefineAlias "$site_4_0.ent69" "Entry2" vTcl:WidgetProc "Toplevel98" 1
    pack $site_4_0.lab68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra103 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra103" "Frame20" vTcl:WidgetProc "Toplevel98" 1
    set site_3_0 $top.fra103
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OPCEDirInput OPCEDirOutput OPCEOutputDir OPCEOutputSubDir
global OPCEFonction OPCEFunction OPCEFileTrainingArea OPCEFileResults
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "true"

if {$NwinOPCEL == ""} {set config "false"}
if {$NwinOPCEL == "0"} {set config "false"}
if {$NwinOPCEL == "?"} {set config "false"}
if {$NwinOPCEC == ""} {set config "false"}
if {$NwinOPCEC == "0"} {set config "false"}
if {$NwinOPCEC == "?"} {set config "false"}

if {$config == "true"} {

    set OPCEDirOutput $OPCEOutputDir
    if {$OPCEOutputSubDir != ""} {append OPCEDirOutput "/$OPCEOutputSubDir"}

    #####################################################################
    #Create Directory
    set OPCEDirOutput [PSPCreateDirectoryMask $OPCEDirOutput $OPCEOutputDir $OPCEDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Areas File"; set TestVarType(4) "file"; set TestVarValue(4) $OPCEFileTrainingArea; set TestVarMin(4) ""; set TestVarMax(4) ""
    set TestVarName(5) "Window Size Row"; set TestVarType(5) "int"; set TestVarValue(5) $NwinOPCEL; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    set TestVarName(6) "Window Size Col"; set TestVarType(6) "int"; set TestVarValue(6) $NwinOPCEC; set TestVarMin(6) "1"; set TestVarMax(6) "1000"
    TestVar 7
    if {$TestVarError == "ok"} {

    set OPCEFileResults "$OPCEDirOutput/OPCE_results.txt"

    DeleteFile $OPCEFileResults
    DeleteFile "$OPCEDirOutput/OPCE.bin"

    set Fonction ""
    set Fonction2 ""
    set MaskCmd ""
    set MaskFile "$OPCEDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/data_process_sngl/OPCE.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$OPCEDirInput\x22 -od \x22$OPCEDirOutput\x22 -iodf $OPCEFonction -af \x22$OPCEFileTrainingArea\x22 -nwr $NwinOPCEL -nwc $NwinOPCEC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/data_process_sngl/OPCE.exe -id \x22$OPCEDirInput\x22 -od \x22$OPCEDirOutput\x22 -iodf $OPCEFonction -af \x22$OPCEFileTrainingArea\x22 -nwr $NwinOPCEL -nwc $NwinOPCEC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    if [file exists "$OPCEDirOutput/OPCE.bin"] {EnviWriteConfig "$OPCEDirOutput/OPCE.bin" $FinalNlig $FinalNcol 4}
    
    if [file exists $OPCEFileResults] {$widget(Button98_1) configure -state normal}
    
    if [file exists "$OPCEDirOutput/OPCE.bin"] {
        set BMPFileInput "$OPCEDirOutput/OPCE.bin"
        set BMPFileOutput "$OPCEDirOutput/OPCE_db.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
        }
    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel98); TextEditorRunTrace "Close Window O.P.C.E" "b"}
    }
}
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel98" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/OPCE.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel98" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global BMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

if {$BMPImageOpen == 1} {
    ClosePSPViewer
    Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
    }
if {$BMPImageOpen == 0} {
    Window hide $widget(Toplevel96); TextEditorRunTrace "Close Window O.P.C.E Graphic Editor" "b"
    Window hide $widget(Toplevel98); TextEditorRunTrace "Close Window O.P.C.E" "b"
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel98" 1
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
    menu $top.m22 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd90 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra100 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.ent101 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra103 \
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
Window show .top98

main $argc $argv
