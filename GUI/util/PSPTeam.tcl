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

        {{[file join . GUI Images 0UR1.gif]} {user image} user {}}
        {{[file join . GUI Images 0esa.gif]} {user image} user {}}
        {{[file join . GUI Images 0ietr.gif]} {user image} user {}}

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
    set base .top239
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-background 1 -foreground 1 -ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-background 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.lab68 {
        array set save {-background 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra66 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra66
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-activebackground 1 -background 1 -foreground 1 -justify 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd70 {
        array set save {-background 1 -foreground 1 -ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.cpd70 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-background 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra74 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra74
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-background 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-activebackground 1 -background 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$base.fra102 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra102
    namespace eval ::widgets::$site_3_0.lab103 {
        array set save {-background 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but106 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-background 1 -command 1 -foreground 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top239
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
    wm geometry $top 200x200+250+250; update
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

proc vTclWindow.top239 {base} {
    if {$base == ""} {
        set base .top239
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -background #ffffff 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x310+84+59; update
    wm maxsize $top 1604 1185
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSarPro v.5 Team"
    vTcl:DefineAlias "$top" "Toplevel239" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit66 \
        -background #ffffff -foreground #0000ff -ipad 2 -relief raised \
        -text Contractor 
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel239" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    label $site_4_0.lab68 \
        -background #ffffff \
        -image [vTcl:image:get_image [file join . GUI Images 0esa.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.lab68" "Label27" vTcl:WidgetProc "Toplevel239" 1
    frame $site_4_0.fra66 \
        -borderwidth 2 -background #ffffff -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra66" "Frame1" vTcl:WidgetProc "Toplevel239" 1
    set site_5_0 $site_4_0.fra66
    label $site_5_0.cpd67 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {ESA / ESRIN - Science Application and Future Technologies Dept} 
    vTcl:DefineAlias "$site_5_0.cpd67" "Label1" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd68 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {Research & Development Section ( Y.L. Desnos )} 
    vTcl:DefineAlias "$site_5_0.cpd68" "Label2" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd69 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -justify left -text {T. Pearson (PolSARpro v.2)} 
    vTcl:DefineAlias "$site_5_0.cpd69" "Label8" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd71 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {A. Minchella (PolSARpro v.3 - v.4 - v.5)} 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label10" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd70 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {C. Stewart - M. Foumelis (PolSARpro v.5.1)} 
    vTcl:DefineAlias "$site_5_0.cpd70" "Label9" vTcl:WidgetProc "Toplevel239" 1
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.lab68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd70 \
        -background #ffffff -foreground #0000ff -ipad 2 -relief raised \
        -text {Principal Investigator} 
    vTcl:DefineAlias "$top.cpd70" "TitleFrame2" vTcl:WidgetProc "Toplevel239" 1
    bind $top.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd70 getframe]
    frame $site_4_0.fra74 \
        -borderwidth 2 -background #ffffff -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra74" "Frame3" vTcl:WidgetProc "Toplevel239" 1
    set site_5_0 $site_4_0.fra74
    label $site_5_0.cpd75 \
        -background #ffffff \
        -image [vTcl:image:get_image [file join . GUI Images 0ietr.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd75" "Label29" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd76 \
        -background #ffffff \
        -image [vTcl:image:get_image [file join . GUI Images 0UR1.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd76" "Label31" vTcl:WidgetProc "Toplevel239" 1
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd69 \
        -borderwidth 2 -background #ffffff -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame2" vTcl:WidgetProc "Toplevel239" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.cpd67 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {I.E.T.R - UMR CNRS 6164 - University of Rennes 1} 
    vTcl:DefineAlias "$site_5_0.cpd67" "Label3" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd77 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {Campus de Beaulieu - Batiment 11D} 
    vTcl:DefineAlias "$site_5_0.cpd77" "Label5" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd78 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {263 avenue General Leclerc} 
    vTcl:DefineAlias "$site_5_0.cpd78" "Label6" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd79 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {F-35042 Rennes cedex - France} 
    vTcl:DefineAlias "$site_5_0.cpd79" "Label7" vTcl:WidgetProc "Toplevel239" 1
    label $site_5_0.cpd68 \
        -activebackground #ffffff -background #ffffff -foreground #0000ff \
        -text {E. Pottier (eric.pottier@univ-rennes1.fr)} 
    vTcl:DefineAlias "$site_5_0.cpd68" "Label4" vTcl:WidgetProc "Toplevel239" 1
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.fra74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra102 \
        -borderwidth 2 -background #ffffff -height 75 -width 125 
    vTcl:DefineAlias "$top.fra102" "Frame426" vTcl:WidgetProc "Toplevel239" 1
    set site_3_0 $top.fra102
    label $site_3_0.lab103 \
        -background #ffffff -text {(January 2015)} 
    vTcl:DefineAlias "$site_3_0.lab103" "Label436" vTcl:WidgetProc "Toplevel239" 1
    button $site_3_0.but106 \
        -background #ffff00 \
        -command {Window hide $widget(Toplevel239); TextEditorRunTrace "Close Window PolSARpro v5.0 Team" "b"} \
        -padx 4 -pady 2 -text Exit -width 4 
    vTcl:DefineAlias "$site_3_0.but106" "Button35" vTcl:WidgetProc "Toplevel239" 1
    bindtags $site_3_0.but106 "$site_3_0.but106 Button $top all _vTclBalloon"
    bind $site_3_0.but106 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    button $site_3_0.but73 \
        -background #ffffff \
        -command {global PSPContributors PSPTopLevel

if {$Load_PSPContributors == 0} {
    source "GUI/util/PSPContributors.tcl"
    set Load_PSPContributors 1
    WmTransient $widget(Toplevel256) $PSPTopLevel
    }
Window hide $widget(Toplevel239); TextEditorRunTrace "Close Window PolSARpro v5.0 Team" "b"
WidgetShow $widget(Toplevel256); TextEditorRunTrace "Open Window PolSARpro v5.0 Contributors" "b"} \
        -foreground #0000ff -pady 0 \
        -text {See the PolSARpro v.5 Contributors} 
    vTcl:DefineAlias "$site_3_0.but73" "Button1" vTcl:WidgetProc "Toplevel239" 1
    pack $site_3_0.lab103 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.but106 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd70 \
        -in $top -anchor center -expand 1 -fill none -side top 
    pack $top.fra102 \
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
Window show .top239

main $argc $argv
