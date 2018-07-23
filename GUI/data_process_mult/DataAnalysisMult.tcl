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
        {{[file join . GUI Images help.gif]} {user image} user {}}
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
    set base .top512
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
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
    namespace eval ::widgets::$base.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra88
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra90
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd82
    namespace eval ::widgets::$site_3_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd83
    namespace eval ::widgets::$site_3_0.fra70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra70
    namespace eval ::widgets::$site_4_0.lab71 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.lab71 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.che74 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top512
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

proc vTclWindow.top512 {base} {
    if {$base == ""} {
        set base .top512
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
    wm geometry $top 500x310+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Analysis"
    vTcl:DefineAlias "$top" "Toplevel512" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel512" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MultDataDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry512_149" vTcl:WidgetProc "Toplevel512" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel512" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel512" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel512" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label512_01" vTcl:WidgetProc "Toplevel512" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry512_01" vTcl:WidgetProc "Toplevel512" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label512_02" vTcl:WidgetProc "Toplevel512" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry512_02" vTcl:WidgetProc "Toplevel512" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label512_03" vTcl:WidgetProc "Toplevel512" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry512_03" vTcl:WidgetProc "Toplevel512" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label512_04" vTcl:WidgetProc "Toplevel512" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry512_04" vTcl:WidgetProc "Toplevel512" 1
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
    TitleFrame $top.cpd81 \
        -ipad 0 -text {Input Binary File} 
    vTcl:DefineAlias "$top.cpd81" "TitleFrame6" vTcl:WidgetProc "Toplevel512" 1
    bind $top.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd81 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame112" vTcl:WidgetProc "Toplevel512" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame18" vTcl:WidgetProc "Toplevel512" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MultDataBinFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry234" vTcl:WidgetProc "Toplevel512" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame19" vTcl:WidgetProc "Toplevel512" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName MultDataDirInput MultDataBinFile
global NDataDirMult DataDirMult MultDataFonction
global MultDataFormatIn MultDataFormatOut
global WarningMessage WarningMessage2 VarAdvice

$widget(Button512_0) configure -state disable
$widget(Radiobutton512_1) configure -state disable
$widget(Radiobutton512_2) configure -state disable
$widget(Radiobutton512_3) configure -state disable
$widget(Radiobutton512_4) configure -state disable
$widget(Radiobutton512_5) configure -state disable

set WarningMessage "THE DATA BINARY FILE (FLOAT VALUES) MUST HAVE"
set WarningMessage2 "THE SAME DATA SIZE IN ALL DIRECTORIES"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Bin Files}        {.bin}        }
}
set MultDataBinFile ""
set FileName ""
OpenFile "$MultDataDirInput" $types "DATA BINARY FILE"
if {$FileName != ""} {
    set config "true"
    for {set ii 1} {$ii <= $NDataDirMult} {incr ii} {
        set MultDataBinFileTmp "$DataDirMult($ii)/"
        if {$MultDataFonction == "T3"} {append MultDataBinFileTmp "T3/" }
        if {$MultDataFonction == "C2"} {append MultDataBinFileTmp "C2/" }
        append MultDataBinFileTmp [file tail $FileName]
        if [file exists $MultDataBinFileTmp] {
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE DATA BINARY FILE $MultDataBinFileTmp DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }
    if {$config == "true"} {
        set MultDataBinFile [file tail $FileName]
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; gets $f tmp
            gets $f tmp; gets $f tmp
            gets $f tmp; gets $f tmp
            if {$tmp == "data type = 2"} {
                set MultDataFormatIn "int"; set MultDataFormatOut "real"
                $widget(Radiobutton512_1) configure -state normal
                $widget(Radiobutton512_2) configure -state normal
                $widget(Radiobutton512_3) configure -state disable
                $widget(Radiobutton512_4) configure -state normal
                $widget(Radiobutton512_5) configure -state disable
                }
            if {$tmp == "data type = 4"} {
                set MultDataFormatIn "float"; set MultDataFormatOut "real"
                $widget(Radiobutton512_1) configure -state normal
                $widget(Radiobutton512_2) configure -state normal
                $widget(Radiobutton512_3) configure -state disable
                $widget(Radiobutton512_4) configure -state normal
                $widget(Radiobutton512_5) configure -state disable
                }
            if {$tmp == "data type = 6"} {
                set MultDataFormatIn "cmplx"; set MultDataFormatOut "mod"
                $widget(Radiobutton512_1) configure -state normal
                $widget(Radiobutton512_2) configure -state normal
                $widget(Radiobutton512_3) configure -state normal
                $widget(Radiobutton512_4) configure -state normal
                $widget(Radiobutton512_5) configure -state normal
                }
                        $widget(Button512_0) configure -state normal
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
                        set MultDataBinFile ""; set FileName ""
                        set MultDataFormatIn ""; set MultDataFormatOut ""
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
                set MultDataBinFile ""
                set FileName ""
                set MultDataFormatIn ""; set MultDataFormatOut ""
        }    
        } else {
        set MultDataBinFile ""
        $widget(Button512_0) configure -state disable
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button4" vTcl:WidgetProc "Toplevel512" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.tit66 \
        -ipad 0 -text {Input Data Format} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame2" vTcl:WidgetProc "Toplevel512" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.cpd69 \
        \
        -command {global MultDataFormatOut
set MultDataFormatOut ""
$widget(Radiobutton512_1) configure -state normal
$widget(Radiobutton512_2) configure -state normal
$widget(Radiobutton512_3) configure -state normal
$widget(Radiobutton512_4) configure -state normal
$widget(Radiobutton512_5) configure -state normal} \
        -text Complex -value cmplx -variable MultDataFormatIn 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton3" vTcl:WidgetProc "Toplevel512" 1
    radiobutton $site_4_0.rad67 \
        \
        -command {global MultDataFormatOut
set MultDataFormatOut ""
$widget(Radiobutton512_1) configure -state normal
$widget(Radiobutton512_2) configure -state normal
$widget(Radiobutton512_3) configure -state disable
$widget(Radiobutton512_4) configure -state normal
$widget(Radiobutton512_5) configure -state disable} \
        -text Float -value float -variable MultDataFormatIn 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel512" 1
    radiobutton $site_4_0.cpd68 \
        \
        -command {global MultDataFormatOut
set MultDataFormatOut ""
$widget(Radiobutton512_1) configure -state normal
$widget(Radiobutton512_2) configure -state normal
$widget(Radiobutton512_3) configure -state disable
$widget(Radiobutton512_4) configure -state normal
$widget(Radiobutton512_5) configure -state disable} \
        -text Integer -value int -variable MultDataFormatIn 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel512" 1
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Processing Format} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame3" vTcl:WidgetProc "Toplevel512" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    radiobutton $site_4_0.rad67 \
        -text Amplitude -value mod -variable MultDataFormatOut 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton512_1" vTcl:WidgetProc "Toplevel512" 1
    radiobutton $site_4_0.cpd68 \
        -text Intensity -value mod2 -variable MultDataFormatOut 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton512_2" vTcl:WidgetProc "Toplevel512" 1
    radiobutton $site_4_0.cpd69 \
        -text Phase -value pha -variable MultDataFormatOut 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton512_3" vTcl:WidgetProc "Toplevel512" 1
    radiobutton $site_4_0.cpd66 \
        -text Real -value real -variable MultDataFormatOut 
    vTcl:DefineAlias "$site_4_0.cpd66" "Radiobutton512_4" vTcl:WidgetProc "Toplevel512" 1
    radiobutton $site_4_0.cpd67 \
        -text Imag -value imag -variable MultDataFormatOut 
    vTcl:DefineAlias "$site_4_0.cpd67" "Radiobutton512_5" vTcl:WidgetProc "Toplevel512" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd82 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd82" "Frame5" vTcl:WidgetProc "Toplevel512" 1
    set site_3_0 $top.cpd82
    checkbutton $site_3_0.che78 \
        -text Mean -variable MultDataAvg 
    vTcl:DefineAlias "$site_3_0.che78" "Checkbutton1" vTcl:WidgetProc "Toplevel512" 1
    checkbutton $site_3_0.cpd67 \
        -text {Standard Deviation} -variable MultDataStd 
    vTcl:DefineAlias "$site_3_0.cpd67" "Checkbutton2" vTcl:WidgetProc "Toplevel512" 1
    checkbutton $site_3_0.cpd68 \
        -text {Coefficient of Variation} -variable MultDataCV 
    vTcl:DefineAlias "$site_3_0.cpd68" "Checkbutton3" vTcl:WidgetProc "Toplevel512" 1
    pack $site_3_0.che78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd83" "Frame3" vTcl:WidgetProc "Toplevel512" 1
    set site_3_0 $top.cpd83
    frame $site_3_0.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra70" "Frame4" vTcl:WidgetProc "Toplevel512" 1
    set site_4_0 $site_3_0.fra70
    label $site_4_0.lab71 \
        -text {Spatial Window Size Row} 
    vTcl:DefineAlias "$site_4_0.lab71" "Label1" vTcl:WidgetProc "Toplevel512" 1
    entry $site_4_0.ent72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable MultDataNwinL -width 5 
    vTcl:DefineAlias "$site_4_0.ent72" "Entry1" vTcl:WidgetProc "Toplevel512" 1
    pack $site_4_0.lab71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame6" vTcl:WidgetProc "Toplevel512" 1
    set site_4_0 $site_3_0.cpd66
    label $site_4_0.lab71 \
        -text {Spatial Window Size Col} 
    vTcl:DefineAlias "$site_4_0.lab71" "Label2" vTcl:WidgetProc "Toplevel512" 1
    entry $site_4_0.ent72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable MultDataNwinC -width 5 
    vTcl:DefineAlias "$site_4_0.ent72" "Entry2" vTcl:WidgetProc "Toplevel512" 1
    pack $site_4_0.lab71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipadx 5 -side left 
    pack $site_4_0.ent72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    checkbutton $site_3_0.che74 \
        -text BMP -variable MultDataBMP 
    vTcl:DefineAlias "$site_3_0.che74" "Checkbutton4" vTcl:WidgetProc "Toplevel512" 1
    pack $site_3_0.fra70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 5 -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel512" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirMult MultDataDirInput MultDataBinFile
global MultDataAvg MultDataStd MultDataCV MultDataNwinL MultDataNwinC MultDataBMP
global MultDataFormatIn MultDataFormatOut MultDataFonction PSPMemory TMPMemoryAllocError
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType OpenDirFile FlatEarthFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    #####################################################################
    #Create Directory
    set MultDataDirInput [PSPCreateDirectoryMask $MultDataDirInput $MultDataDirInput $MultDataDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $MultDataNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "100"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $MultDataNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "100"
    TestVar 6
    if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
        
        set Fonction "Mult Time / Freq Data Analysis"
        set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$MultDataDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_mult/data_analysis_mult.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$DataDirMult(1)\x22 -iodf $MultDataFonction -if \x22$MultDataBinFile\x22 -idf $MultDataFormatIn -odf $MultDataFormatOut -nwr $MultDataNwinL -nwc $MultDataNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $MultDataAvg -fl2 $MultDataStd -fl3 $MultDataCV $MaskCmd" "k"
        set f [ open "| Soft/data_process_mult/data_analysis_mult.exe -id \x22$DataDirMult(1)\x22 -iodf $MultDataFonction -if \x22$MultDataBinFile\x22 -idf $MultDataFormatIn -odf $MultDataFormatOut -nwr $MultDataNwinL -nwc $MultDataNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $MultDataAvg -fl2 $MultDataStd -fl3 $MultDataCV $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        
        set DataMultFileOutputTmp "$MultDataDirInput/"
        append DataMultFileOutputTmp $MultDataBinFile
        set DataMultFileOutput [file rootname $DataMultFileOutputTmp]
        append DataMultFileOutput "_mean.bin"
        if [file exists $DataMultFileOutput] {EnviWriteConfig $DataMultFileOutput $FinalNlig $FinalNcol 4}
        set DataMultFileOutput [file rootname $DataMultFileOutputTmp]
        append DataMultFileOutput "_std.bin"
        if [file exists $DataMultFileOutput] {EnviWriteConfig $DataMultFileOutput $FinalNlig $FinalNcol 4}
        set DataMultFileOutput [file rootname $DataMultFileOutputTmp]
        append DataMultFileOutput "_CV.bin"
        if [file exists $DataMultFileOutput] {EnviWriteConfig $DataMultFileOutput $FinalNlig $FinalNcol 4}

        if {$MultDataBMP == 1} {
            if {$MultDataAvg == 1} {
                set DataMultFileOutput [file rootname $DataMultFileOutputTmp]
                append DataMultFileOutput "_mean"
                set BMPFileInput "$DataMultFileOutput.bin"
                set BMPFileOutput "$DataMultFileOutput.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0				
                }
            if {$MultDataStd == 1} {
                set DataMultFileOutput [file rootname $DataMultFileOutputTmp]
                append DataMultFileOutput "_std"
                set BMPFileInput "$DataMultFileOutput.bin"
                set BMPFileOutput "$DataMultFileOutput.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            if {$MultDataCV == 1} {
                set DataMultFileOutput [file rootname $DataMultFileOutputTmp]
                append DataMultFileOutput "_CV"
                set BMPFileInput "$DataMultFileOutput.bin"
                set BMPFileOutput "$DataMultFileOutput.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            set BMPDirInput $MultDataDirInput
            }

        }
        #TestVar
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel512); TextEditorRunTrace "Close Window Mult Data Analysis" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button512_0" vTcl:WidgetProc "Toplevel512" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataAnalysisMult.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel512" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel512); TextEditorRunTrace "Close Window Mult Data Analysis" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel512" 1
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
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd81 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd83 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra83 \
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
Window show .top512

main $argc $argv
