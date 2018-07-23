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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}

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
    set base .top101
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
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd84 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd89 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd89
    namespace eval ::widgets::$site_6_0.cpd98 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit99 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit99 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd100
    namespace eval ::widgets::$site_5_0.cpd112 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd110 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd110
    namespace eval ::widgets::$site_6_0.tit75 {
        array set save {-ipad 1 -text 1}
    }
    set site_8_0 [$site_6_0.tit75 getframe]
    namespace eval ::widgets::$site_8_0 {
        array set save {}
    }
    set site_8_0 $site_8_0
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    set site_8_0 [$site_6_0.cpd76 getframe]
    namespace eval ::widgets::$site_8_0 {
        array set save {}
    }
    set site_8_0 $site_8_0
    namespace eval ::widgets::$site_8_0.cpd80 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd81 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd83 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd101
    namespace eval ::widgets::$site_5_0.cpd113 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd114 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd115 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd115
    namespace eval ::widgets::$site_6_0.but37 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but38 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd116 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd117 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top101
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

proc vTclWindow.top101 {base} {
    if {$base == ""} {
        set base .top101
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
    wm geometry $top 500x250+160+100; update
    wm maxsize $top 1284 1008
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create My Function"
    vTcl:DefineAlias "$top" "Toplevel101" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame3" vTcl:WidgetProc "Toplevel101" 1
    set site_3_0 $top.cpd88
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Function Name} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel101" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MyFunctionFullName 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel101" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel101" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd98 \
        \
        -command {global FileName DataDir MyFunctionFullName MyFunctionName MyFunctionPath MyFunctionVar

set types {
{{EXE Files}        {.exe}        }
{{All Files}        *        }
}
set FileName ""
OpenFile $DataDir $types "MY FUNCTION NAME "
if {$FileName != ""} {
    set MyFunctionFullName $FileName
    set MyFunctionName [file tail $FileName]
    set MyFunctionName [file rootname $MyFunctionName]
    set MyFunctionPath "Soft/tools/MyRoutines/"
    append MyFunctionPath $MyFunctionName
    append MyFunctionPath ".exe"  
    $widget(TitleFrame101_1) configure -state normal
    $widget(Entry101_1) configure -state normal
    $widget(Entry101_1) configure -disabledbackground #FFFFFF
    $widget(Button101_1) configure -state normal
    $widget(Button101_7) configure -state normal
    set MyFunctionVar "0"  
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd98" "Button83" vTcl:WidgetProc "Toplevel101" 1
    pack $site_6_0.cpd98 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd84 \
        -ipad 0 -text {Function Path} 
    vTcl:DefineAlias "$site_3_0.cpd84" "TitleFrame8" vTcl:WidgetProc "Toplevel101" 1
    bind $site_3_0.cpd84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd84 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MyFunctionPath 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel101" 1
    frame $site_5_0.cpd89 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd89" "Frame15" vTcl:WidgetProc "Toplevel101" 1
    set site_6_0 $site_5_0.cpd89
    button $site_6_0.cpd98 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd98" "Button84" vTcl:WidgetProc "Toplevel101" 1
    pack $site_6_0.cpd98 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd89 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.tit99 \
        -text {Parameters Definition} 
    vTcl:DefineAlias "$top.tit99" "TitleFrame101_1" vTcl:WidgetProc "Toplevel101" 1
    bind $top.tit99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit99 getframe]
    frame $site_4_0.cpd100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd100" "Frame1" vTcl:WidgetProc "Toplevel101" 1
    set site_5_0 $site_4_0.cpd100
    entry $site_5_0.cpd112 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable MyFunctionVar -width 3 
    vTcl:DefineAlias "$site_5_0.cpd112" "Entry101_1" vTcl:WidgetProc "Toplevel101" 1
    frame $site_5_0.cpd110 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd110" "Frame476" vTcl:WidgetProc "Toplevel101" 1
    set site_6_0 $site_5_0.cpd110
    TitleFrame $site_6_0.tit75 \
        -ipad 5 -text {Variable Name} 
    vTcl:DefineAlias "$site_6_0.tit75" "TitleFrame101_2" vTcl:WidgetProc "Toplevel101" 1
    bind $site_6_0.tit75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.tit75 getframe]
    entry $site_8_0.cpd77 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable VarName 
    vTcl:DefineAlias "$site_8_0.cpd77" "Entry101_2" vTcl:WidgetProc "Toplevel101" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_6_0.cpd76 \
        -text {Variable Type} 
    vTcl:DefineAlias "$site_6_0.cpd76" "TitleFrame101_3" vTcl:WidgetProc "Toplevel101" 1
    bind $site_6_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd76 getframe]
    radiobutton $site_8_0.cpd80 \
        -text integer -value integer -variable VarType 
    vTcl:DefineAlias "$site_8_0.cpd80" "Radiobutton101_1" vTcl:WidgetProc "Toplevel101" 1
    radiobutton $site_8_0.cpd81 \
        -text float -value float -variable VarType 
    vTcl:DefineAlias "$site_8_0.cpd81" "Radiobutton101_2" vTcl:WidgetProc "Toplevel101" 1
    radiobutton $site_8_0.cpd82 \
        -text {ascii / string} -value ascii -variable VarType 
    vTcl:DefineAlias "$site_8_0.cpd82" "Radiobutton101_3" vTcl:WidgetProc "Toplevel101" 1
    radiobutton $site_8_0.cpd83 \
        -text {path / file} -value path -variable VarType 
    vTcl:DefineAlias "$site_8_0.cpd83" "Radiobutton101_4" vTcl:WidgetProc "Toplevel101" 1
    pack $site_8_0.cpd80 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd81 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd83 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.tit75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd112 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd110 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side right 
    frame $site_4_0.cpd101 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd101" "Frame2" vTcl:WidgetProc "Toplevel101" 1
    set site_5_0 $site_4_0.cpd101
    button $site_5_0.cpd113 \
        -background #ffff00 \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType VarName VarType

if {$MyFunctionVar != "0"} {
    set MyFunctionVarName($MyFunctionVar) $VarName
    set MyFunctionVarType($MyFunctionVar) $VarType
    }
if {$MyFunctionVar < "20"} {
    incr MyFunctionVar
    incr MyFunctionVarN
    set VarName "?"
    set VarType ""
    $widget(TitleFrame101_2) configure -state normal
    $widget(TitleFrame101_3) configure -state normal
    $widget(Entry101_2) configure -state normal
    $widget(Entry101_2) configure -disabledbackground #FFFFFF
    $widget(Radiobutton101_1) configure -state normal
    $widget(Radiobutton101_2) configure -state normal
    $widget(Radiobutton101_3) configure -state normal
    $widget(Radiobutton101_4) configure -state normal
    $widget(Button101_2) configure -state normal
    $widget(Button101_3) configure -state normal
    $widget(Button101_4) configure -state normal
    $widget(Button101_5) configure -state normal
    $widget(Button101_6) configure -state normal
    }} \
        -padx 4 -pady 2 -text New 
    vTcl:DefineAlias "$site_5_0.cpd113" "Button101_1" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_5_0.cpd113 "$site_5_0.cpd113 Button $top all _vTclBalloon"
    bind $site_5_0.cpd113 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Create a new Class}
    }
    button $site_5_0.cpd114 \
        -background #ffff00 \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType VarName VarType

if {$MyFunctionVarN != "1"} {
    for {set i $MyFunctionVar} {$i < $MyFunctionVarN} {incr i} {
        set ip1 [expr $i + 1]
        set MyFunctionVarName($i) $MyFunctionVarName($ip1)
        set MyFunctionVarType($i) $MyFunctionVarType($ip1)
        }
    set MyFunctionVarName($MyFunctionVarN) ""
    set MyFunctionVarType($MyFunctionVarN) ""
    set MyFunctionVarN [expr $MyFunctionVarN - 1]
    set VarName $MyFunctionVarName($MyFunctionVar)
    set VarType $MyFunctionVarType($MyFunctionVar)
    } else {
    set MyFunctionVarN "0"
    set MyFunctionVar "0"
    set VarName "?"
    set VarType ""
    }} \
        -padx 4 -pady 2 -text Del 
    vTcl:DefineAlias "$site_5_0.cpd114" "Button101_2" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_5_0.cpd114 "$site_5_0.cpd114 Button $top all _vTclBalloon"
    bind $site_5_0.cpd114 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Delete the Class}
    }
    frame $site_5_0.cpd115 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd115" "Frame461" vTcl:WidgetProc "Toplevel101" 1
    set site_6_0 $site_5_0.cpd115
    button $site_6_0.but37 \
        \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType VarName VarType

if {$MyFunctionVar != "0"} {
    set MyFunctionVarName($MyFunctionVar) $VarName
    set MyFunctionVarType($MyFunctionVar) $VarType
    }

if {$MyFunctionVar < $MyFunctionVarN} {
    incr MyFunctionVar    
    set VarName $MyFunctionVarName($MyFunctionVar)
    set VarType $MyFunctionVarType($MyFunctionVar)
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_6_0.but37" "Button101_3" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_6_0.but37 "$site_6_0.but37 Button $top all _vTclBalloon"
    bind $site_6_0.but37 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Move Up in the Class List}
    }
    button $site_6_0.but38 \
        \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType VarName VarType

if {$MyFunctionVar != "0"} {
    set MyFunctionVarName($MyFunctionVar) $VarName
    set MyFunctionVarType($MyFunctionVar) $VarType
    }

if {$MyFunctionVar > "1"} {
    set MyFunctionVar [expr $MyFunctionVar - 1]
    set VarName $MyFunctionVarName($MyFunctionVar)
    set VarType $MyFunctionVarType($MyFunctionVar)
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but38" "Button101_4" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_6_0.but38 "$site_6_0.but38 Button $top all _vTclBalloon"
    bind $site_6_0.but38 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Move Down in the Class List}
    }
    pack $site_6_0.but37 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side left 
    pack $site_6_0.but38 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side left 
    button $site_5_0.cpd116 \
        -background #ffff00 \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType VarName VarType

set MyFunctionVarName($MyFunctionVar) ""
set MyFunctionVarType($MyFunctionVar) ""
set VarName "?"
set VarType ""} \
        -padx 4 -pady 2 -text Clear 
    vTcl:DefineAlias "$site_5_0.cpd116" "Button101_5" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_5_0.cpd116 "$site_5_0.cpd116 Button $top all _vTclBalloon"
    bind $site_5_0.cpd116 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Clear the Contours on the BMP image}
    }
    button $site_5_0.cpd117 \
        -background #ffff00 \
        -command {global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType VarName VarType

set MyFunctionVar "0"
set MyFunctionVarN "0"
for {set i 0} {$i <= 20} {incr i} {
    set MyFunctionVarName($i) ""
    set MyFunctionVarType($i) ""
    }
set VarName ""
set VarType ""
$widget(TitleFrame101_2) configure -state disable
$widget(TitleFrame101_3) configure -state disable
$widget(Entry101_2) configure -state disable
$widget(Entry101_2) configure -disabledbackground $PSPBackgroundColor
$widget(Radiobutton101_1) configure -state disable
$widget(Radiobutton101_2) configure -state disable
$widget(Radiobutton101_3) configure -state disable
$widget(Radiobutton101_4) configure -state disable
$widget(Button101_2) configure -state disable
$widget(Button101_3) configure -state disable
$widget(Button101_4) configure -state disable
$widget(Button101_5) configure -state disable
$widget(Button101_6) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_5_0.cpd117" "Button101_6" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_5_0.cpd117 "$site_5_0.cpd117 Button $top all _vTclBalloon"
    bind $site_5_0.cpd117 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Delete all the Training Areas from the List}
    }
    pack $site_5_0.cpd113 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd114 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd115 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd116 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd117 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd90" "Frame6" vTcl:WidgetProc "Toplevel101" 1
    set site_3_0 $top.cpd90
    button $site_3_0.cpd118 \
        -background #ffff00 \
        -command {global MyFunctionName MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType CONFIGDir
global VarMyFunction

if {$MyFunctionName != ""} {

if {$MyFunctionVar != "0"} {
    set MyFunctionVarName($MyFunctionVar) $VarName
    set MyFunctionVarType($MyFunctionVar) $VarType
    }

CopyFile $MyFunctionFullName $MyFunctionPath

set MyFunctionConfigFile "$CONFIGDir/MyRoutines/"
append MyFunctionConfigFile $MyFunctionName
append MyFunctionConfigFile ".txt"    

set f [open $MyFunctionConfigFile w]
puts $f $MyFunctionName
puts $f $MyFunctionVarN
puts $f "--------------"
for {set i 1} {$i <= $MyFunctionVarN} {incr i} {
    puts $f $MyFunctionVarName($i)
    puts $f $MyFunctionVarType($i)
    puts $f "--------------"
    }
close $f

set VarMyFunction "ok"
}

Window hide $widget(Toplevel101); TextEditorRunTrace "Close Window Create My Function" "b"} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.cpd118" "Button101_7" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_3_0.cpd118 "$site_3_0.cpd118 Button $top all _vTclBalloon"
    bind $site_3_0.cpd118 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save the Training Area List}
    }
    button $site_3_0.cpd119 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/tools/MyFunctionCreate.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.cpd119" "Button17" vTcl:WidgetProc "Toplevel101" 1
    bindtags $site_3_0.cpd119 "$site_3_0.cpd119 Button $top all _vTclBalloon"
    bind $site_3_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.cpd120 \
        -background #ffff00 \
        -command {global VarMyFunction

set VarMyFunction $VarMyFunction

Window hide $widget(Toplevel101); TextEditorRunTrace "Close Window Create My Function" "b"} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.cpd120" "Button640" vTcl:WidgetProc "Toplevel101" 1
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
Window show .top101

main $argc $argv
