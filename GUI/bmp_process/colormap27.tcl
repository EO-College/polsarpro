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
    set base .top254
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd76
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
    namespace eval ::widgets::$site_6_0.cpd86 {
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra35 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra35
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd73 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd75 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd76 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd79 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd80 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top254
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
    wm geometry $top 200x200+88+88; update
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

proc vTclWindow.top254 {base} {
    if {$base == ""} {
        set base .top254
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
    wm geometry $top 650x170+520+100; update
    wm maxsize $top 1284 1009
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Color Map"
    vTcl:DefineAlias "$top" "Toplevel254" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd76" "Frame2" vTcl:WidgetProc "Toplevel254" 1
    set site_3_0 $top.cpd76
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input ColorMap File} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame6" vTcl:WidgetProc "Toplevel254" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapIn 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel254" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel254" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel254" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output ColorMap File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel254" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapOut 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel254" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel254" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd87 \
        \
        -command {global FileName ColorMapOut

set ColorMapOutTmp $ColorMapOut
set types {
{{PAL Files}        {.pal}        }
}

set ColorMapOut ""
set ColorMapOut [tk_getSaveFile -initialdir "Colormap" -filetypes $types -title "OUTPUT COLORMAP FILE" -defaultextension .pal]
if {$ColorMapOut == ""} {set ColorMapOut $ColorMapOutTmp}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd87 "$site_6_0.cpd87 Button $top all _vTclBalloon"
    bind $site_6_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra35 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra35" "Frame263" vTcl:WidgetProc "Toplevel254" 1
    set site_3_0 $top.fra35
    button $site_3_0.but36 \
        \
        -command {set b .top254.fra35.but36
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(1) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(1) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(1) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 01 
    button $site_3_0.but37 \
        \
        -command {set b .top254.fra35.but37
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(2) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(2) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(2) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 02 
    button $site_3_0.but38 \
        \
        -command {set b .top254.fra35.but38
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(3) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(3) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(3) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 03 
    vTcl:DefineAlias "$site_3_0.but38" "ColorMapBut3" vTcl:WidgetProc "Toplevel254" 1
    button $site_3_0.but39 \
        \
        -command {set b .top254.fra35.but39
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(4) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(4) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(4) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 04 
    button $site_3_0.but40 \
        \
        -command {set b .top254.fra35.but40
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(5) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(5) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(5) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 05 
    button $site_3_0.but41 \
        \
        -command {set b .top254.fra35.but41
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(6) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(6) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(6) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 06 
    button $site_3_0.but42 \
        \
        -command {set b .top254.fra35.but42
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(7) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(7) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(7) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 07 
    button $site_3_0.but43 \
        \
        -command {set b .top254.fra35.but43
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(8) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(8) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(8) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 08 
    button $site_3_0.but44 \
        \
        -command {set b .top254.fra35.but44
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(9) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(9) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(9) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 09 
    button $site_3_0.but45 \
        \
        -command {set b .top254.fra35.but45
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(10) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(10) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(10) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 10 
    button $site_3_0.but46 \
        \
        -command {set b .top254.fra35.but46
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(11) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(11) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(11) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 11 
    button $site_3_0.but47 \
        \
        -command {set b .top254.fra35.but47
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(12) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(12) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(12) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 12 
    button $site_3_0.but48 \
        \
        -command {set b .top254.fra35.but48
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(13) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(13) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(13) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 13 
    button $site_3_0.but49 \
        \
        -command {set b .top254.fra35.but49
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(14) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(14) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(14) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 14 
    button $site_3_0.but50 \
        \
        -command {set b .top254.fra35.but50
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(15) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(15) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(15) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 15 
    button $site_3_0.but51 \
        \
        -command {set b .top254.fra35.but51
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(16) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(16) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(16) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 16 
    button $site_3_0.cpd71 \
        \
        -command {set b .top254.fra35.cpd71
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(17) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(17) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(17) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 17 
    button $site_3_0.cpd72 \
        \
        -command {set b .top254.fra35.cpd72
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(18) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(18) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(18) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 18 
    button $site_3_0.cpd73 \
        \
        -command {set b .top254.fra35.cpd73
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(19) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(19) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(19) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 19 
    button $site_3_0.cpd74 \
        \
        -command {set b .top254.fra35.cpd74
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(20) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(20) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(20) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 20 
    button $site_3_0.cpd75 \
        \
        -command {set b .top254.fra35.cpd75
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(21) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(21) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(21) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 21 
    button $site_3_0.cpd76 \
        \
        -command {set b .top254.fra35.cpd76
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(22) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(22) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(22) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 22 
    button $site_3_0.cpd77 \
        \
        -command {set b .top254.fra35.cpd77
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(23) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(23) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(23) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 23 
    button $site_3_0.cpd78 \
        \
        -command {set b .top254.fra35.cpd78
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(24) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(24) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(24) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 24 
    button $site_3_0.cpd79 \
        \
        -command {set b .top254.fra35.cpd79
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(25) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(25) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(25) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 25 
    button $site_3_0.cpd80 \
        \
        -command {set b .top254.fra35.cpd80
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(26) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(26) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(26) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 26 
    button $site_3_0.cpd81 \
        \
        -command {set b .top254.fra35.cpd81
set initialColor [$b cget -background]
set color [tk_chooseColor -title "Choose a color" -initialcolor $initialColor]
if {$color == ""} {set color $initialColor}
$b configure -background $color
set RedPalette(27) [expr round([lindex [winfo rgb $b $color] 0] / 256)] 
set GreenPalette(27) [expr round([lindex [winfo rgb $b $color] 1] / 256)] 
set BluePalette(27) [expr round([lindex [winfo rgb $b $color] 2] / 256)]} \
        -padx 0 -pady 0 -text 27 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra51 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame20" vTcl:WidgetProc "Toplevel254" 1
    set site_3_0 $top.fra51
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global VarColorMap ColorMapOut ColorNumber RedPalette GreenPalette BluePalette OpenDirFile

if {$OpenDirFile == 0} {

set RedPalette(0) "125"
set GreenPalette(0) "125"
set BluePalette(0) "125"

set f [open $ColorMapOut w]
puts $f "JASC-PAL"
puts $f "0100"
puts $f $ColorNumber
for {set i 0} {$i < $ColorNumber} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
close $f

set VarColorMap "ok"
.top254.fra35.but38 configure -state normal
.top254.fra35.but47 configure -state normal
.top254.fra35.cpd75 configure -state normal
Window hide $widget(Toplevel254); TextEditorRunTrace "Close Window Colormap" "b"
}} \
        -padx 4 -pady 2 -text Save 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel254" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save the ColorMap}
    }
    button $site_3_0.but71 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/bmp_process/ColorMap.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text button -width 20 
    vTcl:DefineAlias "$site_3_0.but71" "Button1" vTcl:WidgetProc "Toplevel254" 1
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global VarColorMap OpenDirFile

if {$OpenDirFile == 0} {
set VarColorMap "no"
.top254.fra35.but38 configure -state normal
.top254.fra35.but47 configure -state normal
.top254.fra35.cpd75 configure -state normal
Window hide $widget(Toplevel254); TextEditorRunTrace "Close Window Colormap" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel254" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra35 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra51 \
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
Window show .top254

main $argc $argv
