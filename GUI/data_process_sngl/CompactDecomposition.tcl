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
    set base .top442
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd84
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
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd84
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
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
    namespace eval ::widgets::$base.tit66 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra37 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra37
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra40 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra40
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra47 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra47
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra48 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra48
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra43 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra43
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra45 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra45
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd73
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra46 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra46
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd74
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd69
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd70 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd70
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd71
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra55 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra55
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd84
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but442 {
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
            vTclWindow.top442
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

proc vTclWindow.top442 {base} {
    if {$base == ""} {
        set base .top442
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
    wm geometry $top 500x630+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing : Compact Decomposition"
    vTcl:DefineAlias "$top" "Toplevel442" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd84" "Frame4" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.cpd84
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel442" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CompactDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel442" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel442" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel442" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel442" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CompactOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel442" 1
    frame $site_5_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd84" "Frame1" vTcl:WidgetProc "Toplevel442" 1
    set site_6_0 $site_5_0.cpd84
    label $site_6_0.lab82 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab82" "Label1" vTcl:WidgetProc "Toplevel442" 1
    entry $site_6_0.cpd86 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CompactOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd86" "Entry1" vTcl:WidgetProc "Toplevel442" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel442" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd85 \
        \
        -command {global DirName DataDir CompactOutputDir

set CompactDirOutputTmp $CompactOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set CompactOutputDir $DirName
    } else {
    set CompactOutputDir $CompactDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd85 "$site_6_0.cpd85 Button $top all _vTclBalloon"
    bind $site_6_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra36 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame9" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra36
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel442" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel442" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel442" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel442" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel442" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel442" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel442" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel442" 1
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
    TitleFrame $top.tit66 \
        -ipad 2 -relief sunken \
        -text {Hybrid Compact - Pol Architecture  ( Orthogonal Linear H and V Receive )} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel442" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.cpd68 \
        -text {Left Handed Circular Transmit} -value LHC -variable hybrid 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel442" 1
    radiobutton $site_4_0.rad67 \
        -text {Right Handed Circular Transmit} -value RHC -variable hybrid 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel442" 1
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra37 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra37" "Frame33" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra37
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$eigenvalues"=="1"} { $widget(Checkbutton442_1) configure -state normal
} else {
$widget(Checkbutton442_1) configure -state disable
set BMPeigenvalues "0"
}} \
        -padx 1 -text {EigenValues (L1, L2) } -variable eigenvalues 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton190" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPeigenvalues 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_1" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra40 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra40" "Frame34" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra40
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$probabilities"=="1"} { $widget(Checkbutton442_2) configure -state normal 
} else {
$widget(Checkbutton442_2) configure -state disable
set BMPprobabilities "0"
}} \
        -padx 1 -text {PseudoProbabilities (p1, p2)} -variable probabilities 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton192" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPprobabilities 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_2" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra47 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra47" "Frame41" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra47
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$entropy"=="1"} { $widget(Checkbutton442_7) configure -state normal
} else {
$widget(Checkbutton442_7) configure -state disable
set BMPentropy "0"
}} \
        -padx 1 -text {Entropy  (H)} -variable entropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton202" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPentropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_7" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra48 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra48" "Frame42" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra48
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$anisotropy"=="1"} { $widget(Checkbutton442_8) configure -state normal
} else {
$widget(Checkbutton442_8) configure -state disable
set BMPanisotropy "0"
}} \
        -padx 1 \
        -text {Anisotropy  (A)  (p1,p2)    <->    Degree of Polarisation} \
        -variable anisotropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton204" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPanisotropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_8" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra41 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame35" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra41
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$mv"=="1"} { $widget(Checkbutton442_3) configure -state normal 
} else {
$widget(Checkbutton442_3) configure -state disable
set BMPmv "0"
}} \
        -padx 1 -text {Compact RVoG : mv} -variable mv 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton194" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPmv 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_3" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra43 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra43" "Frame37" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra43
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$ms"=="1"} { $widget(Checkbutton442_4) configure -state normal
} else {
$widget(Checkbutton442_4) configure -state disable
set BMPms "0"
}} \
        -padx 1 -text {Compact RVoG : ms} -variable ms 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton196" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPms 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_4" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra45 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra45" "Frame39" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra45
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$alphas"=="1"} { $widget(Checkbutton442_5) configure -state normal
} else {
$widget(Checkbutton442_5) configure -state disable
set BMPalphas "0"
}} \
        -padx 1 -text {Compact RVoG : alpha_s} -variable alphas 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton198" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPalphas 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_5" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd73 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd73" "Frame43" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.cpd73
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$phi"=="1"} { $widget(Checkbutton442_14) configure -state normal
} else {
$widget(Checkbutton442_14) configure -state disable
set BMPphi "0"
}} \
        -padx 1 -text {Compact RVoG : phi} -variable phi 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton201" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPphi 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_14" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra46 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra46" "Frame40" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra46
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$PsPdPv"=="1"} { $widget(Checkbutton442_6) configure -state normal
} else {
$widget(Checkbutton442_6) configure -state disable
set BMPPsPdPv "0"
}} \
        -padx 1 -text {Pseudo 3-Components decomposition ( Ps, Pd, Pv )} \
        -variable PsPdPv 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton200" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPPsPdPv 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_6" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd66 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame45" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.cpd66
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$sigmas"=="1"} { $widget(Checkbutton442_16) configure -state normal
} else {
$widget(Checkbutton442_16) configure -state disable
set BMPsigmas "0"
}} \
        -padx 1 -text {Cross-Pol sigma_HV} -variable sigmahv 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton205" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPsigmahv 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_16" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd74" "Frame44" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.cpd74
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$stvr"=="1"} { $widget(Checkbutton442_15) configure -state normal
} else {
$widget(Checkbutton442_15) configure -state disable
set BMPstvr "0"
}} \
        -padx 1 -text {Surface to Volume ratio} -variable stvr 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton203" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPstvr 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_15" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd69 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd69" "Frame46" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.cpd69
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$CPR"=="1"} { $widget(Checkbutton442_11) configure -state normal
} else {
$widget(Checkbutton442_11) configure -state disable
set BMPCPR "0"
}} \
        -padx 1 -text {Circular Polarization Ratio} -variable CPR 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton206" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPCPR 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_11" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd70 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd70" "Frame50" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.cpd70
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$alpha"=="1"} { $widget(Checkbutton442_12) configure -state normal
} else {
$widget(Checkbutton442_12) configure -state disable
set BMPalpha "0"
}} \
        -padx 1 -text {Mean Particule Shape} -variable alpha 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton207" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPalpha 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_12" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd71 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame51" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.cpd71
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$tau"=="1"} { $widget(Checkbutton442_13) configure -state normal
} else {
$widget(Checkbutton442_13) configure -state disable
set BMPtau "0"
}} \
        -padx 1 \
        -text {Width of the Distribution of Particule Orientation (tau)} \
        -variable tau 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton208" vTcl:WidgetProc "Toplevel442" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPtau 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton442_13" vTcl:WidgetProc "Toplevel442" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra55 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame47" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra55
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel442" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label34" vTcl:WidgetProc "Toplevel442" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinCompactL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel442" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd84 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd84" "Frame49" vTcl:WidgetProc "Toplevel442" 1
    set site_4_0 $site_3_0.cpd84
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label35" vTcl:WidgetProc "Toplevel442" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinCompactC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel442" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {set NwinCompactL "?"; set NwinCompactC "?"
set eigenvalues "1"
set probabilities "1"
set mv "1"
set ms "1"
set alphas "1"
set phi "1"
set PsPdPv "1"
set sigmahv "1"
set entropy "1"
set anisotropy "1"
set stvr "1"
set CPR "1"
set alpha "1"
set tau "1"
set BMPeigenvalues "1"
set BMPprobabilities "1"
set BMPmv "1"
set BMPms "1"
set BMPalphas "1"
set BMPphi "1"
set BMPPsPdPv "1"
set BMPsigmahv "1"
set BMPentropy "1"
set BMPanisotropy "1"
set BMPstvr "1"
set BMPCPR "1"
set BMPalpha "1"
set BMPtau "1"
$widget(Checkbutton442_1) configure -state normal
$widget(Checkbutton442_2) configure -state normal
$widget(Checkbutton442_3) configure -state normal
$widget(Checkbutton442_4) configure -state normal
$widget(Checkbutton442_5) configure -state normal
$widget(Checkbutton442_6) configure -state normal
$widget(Checkbutton442_7) configure -state normal
$widget(Checkbutton442_8) configure -state normal
$widget(Checkbutton442_11) configure -state normal
$widget(Checkbutton442_12) configure -state normal
$widget(Checkbutton442_13) configure -state normal
$widget(Checkbutton442_14) configure -state normal
$widget(Checkbutton442_15) configure -state normal
$widget(Checkbutton442_16) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel442" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {set NwinCompactL "?"; set NwinCompactC "?"
set eigenvalues "0"
set probabilities "0"
set mv "0"
set ms "0"
set alphas "0"
set phi "0"
set PsPdPv "0"
set sigmahv "0"
set entropy "0"
set anisotropy "0"
set stvr "0"
set CPR "0"
set alpha "0"
set tau "0"
set BMPeigenvalues "0"
set BMPprobabilities "0"
set BMPmv "0"
set BMPms "0"
set BMPalphas "0"
set BMPphi "0"
set BMPPsPdPv "0"
set BMPsigmahv "0"
set BMPentropy "0"
set BMPanisotropy "0"
set BMPstvr "0"
set BMPCPR "0"
set BMPalpha "0"
set BMPtau "0"
$widget(Checkbutton442_1) configure -state disable
$widget(Checkbutton442_2) configure -state disable
$widget(Checkbutton442_3) configure -state disable
$widget(Checkbutton442_4) configure -state disable
$widget(Checkbutton442_5) configure -state disable
$widget(Checkbutton442_6) configure -state disable
$widget(Checkbutton442_7) configure -state disable
$widget(Checkbutton442_8) configure -state disable
$widget(Checkbutton442_11) configure -state disable
$widget(Checkbutton442_12) configure -state disable
$widget(Checkbutton442_13) configure -state disable
$widget(Checkbutton442_14) configure -state disable
$widget(Checkbutton442_15) configure -state disable
$widget(Checkbutton442_16) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button104" vTcl:WidgetProc "Toplevel442" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 50 -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel442" 1
    set site_3_0 $top.fra59
    button $site_3_0.but442 \
        -background #ffff00 \
        -command {global CompactDirInput CompactDirOutput CompactOutputDir CompactOutputSubDir
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage
global ProgressLine CompactDecompositionFonction PSPViewGimpBMP
global BMPDirInput OpenDirFile NwinCompactL NwinCompactC PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "false"
if {"$eigenvalues"=="1"} { set config "true" }
if {"$probabilities"=="1"} { set config "true" }
if {"$mv"=="1"} { set config "true" }
if {"$ms"=="1"} { set config "true" }
if {"$alphas"=="1"} { set config "true" }
if {"$phi"=="1"} { set config "true" }
if {"$alpha"=="1"} { set config "true" }
if {"$tau"=="1"} { set config "true" }
if {"$entropy"=="1"} { set config "true" }
if {"$anisotropy"=="1"} { set config "true" }
if {"$PsPdPv"=="1"} { set config "true" }
if {"$sigmahv"=="1"} { set config "true" }
if {"$stvr"=="1"} { set config "true" }
if {"$CPR"=="1"} { set config "true" }

if {"$config"=="true"} {

    set CompactDirOutput $CompactOutputDir
    if {$CompactOutputSubDir != ""} {append CompactDirOutput "/$CompactOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set CompactDirOutput [PSPCreateDirectoryMask $CompactDirOutput $CompactOutputDir $CompactDirInput]
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
        set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinCompactL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinCompactC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
        TestVar 6
        if {$TestVarError == "ok"} {
            set Fonction "Creation of all the Binary Data Files"
            set Fonction2 "of the Compact Decomposition"
            set MaskCmd ""
            set MaskFile "$CompactDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/compact_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$CompactDirInput\x22 -od \x22$CompactDirOutput\x22 -iodf $CompactDecompositionFonction -hyb $hybrid -nwr $NwinCompactL -nwc $NwinCompactC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $eigenvalues -fl2 $probabilities -fl3 $entropy -fl4 $anisotropy -fl5 $mv -fl6 $ms -fl7 $alphas -fl8 $phi -fl9 $PsPdPv -fl10 $sigmahv -fl11 $stvr -fl12 $CPR -fl13 $alpha -fl14 $tau -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/compact_decomposition.exe -id \x22$CompactDirInput\x22 -od \x22$CompactDirOutput\x22 -iodf $CompactDecompositionFonction -hyb $hybrid -nwr $NwinCompactL -nwc $NwinCompactC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $eigenvalues -fl2 $probabilities -fl3 $entropy -fl4 $anisotropy -fl5 $mv -fl6 $ms -fl7 $alphas -fl8 $phi -fl9 $PsPdPv -fl10 $sigmahv -fl11 $stvr -fl12 $CPR -fl13 $alpha -fl14 $tau -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$eigenvalues"=="1"} {
                if [file exists "$CompactDirOutput/compact_l1.bin"] {EnviWriteConfig "$CompactDirOutput/compact_l1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$CompactDirOutput/compact_l2.bin"] {EnviWriteConfig "$CompactDirOutput/compact_l2.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$probabilities"=="1"} {
                if [file exists "$CompactDirOutput/compact_p1.bin"] {EnviWriteConfig "$CompactDirOutput/compact_p1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$CompactDirOutput/compact_p2.bin"] {EnviWriteConfig "$CompactDirOutput/compact_p2.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$entropy"=="1"} {
                if [file exists "$CompactDirOutput/compact_entropy.bin"] {EnviWriteConfig "$CompactDirOutput/compact_entropy.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$anisotropy"=="1"} {
                if [file exists "$CompactDirOutput/compact_deg_pol.bin"] {EnviWriteConfig "$CompactDirOutput/compact_deg_pol.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$mv"=="1"} {
                if [file exists "$CompactDirOutput/compact_mv.bin"] {EnviWriteConfig "$CompactDirOutput/compact_mv.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$ms"=="1"} {
                if [file exists "$CompactDirOutput/compact_ms.bin"] {EnviWriteConfig "$CompactDirOutput/compact_ms.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$alphas"=="1"} {
                if [file exists "$CompactDirOutput/compact_alpha_s.bin"] {EnviWriteConfig "$CompactDirOutput/compact_alpha_s.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$phi"=="1"} {
                if [file exists "$CompactDirOutput/compact_phi.bin"] {EnviWriteConfig "$CompactDirOutput/compact_phi.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$PsPdPv"=="1"} {
                if [file exists "$CompactDirOutput/compact_Ps.bin"] {EnviWriteConfig "$CompactDirOutput/compact_Ps.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$CompactDirOutput/compact_Pd.bin"] {EnviWriteConfig "$CompactDirOutput/compact_Pd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$CompactDirOutput/compact_Pv.bin"] {EnviWriteConfig "$CompactDirOutput/compact_Pv.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$sigmahv"=="1"} {
                if [file exists "$CompactDirOutput/compact_sigma_hv.bin"] {EnviWriteConfig "$CompactDirOutput/compact_sigma_hv.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$stvr"=="1"} {
                if [file exists "$CompactDirOutput/compact_RSoV.bin"] {EnviWriteConfig "$CompactDirOutput/compact_RSoV.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$CPR"=="1"} {
                if [file exists "$CompactDirOutput/compact_cpr.bin"] {EnviWriteConfig "$CompactDirOutput/compact_cpr.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$alpha"=="1"} {
                if [file exists "$CompactDirOutput/compact_alpha.bin"] {EnviWriteConfig "$CompactDirOutput/compact_alpha.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$tau"=="1"} {
                if [file exists "$CompactDirOutput/compact_tau.bin"] {EnviWriteConfig "$CompactDirOutput/compact_tau.bin" $FinalNlig $FinalNcol 4}
                }
            #Update the Nlig/Ncol of the new image after processing
            set NligInit 1
            set NcolInit 1
            set NligEnd $FinalNlig
            set NcolEnd $FinalNcol
            
        #####################################################################       

        set Fonction "Creation of the BMP File"

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        if {"$BMPeigenvalues"=="1"} {
            if [file exists "$CompactDirOutput/compact_l1.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_l1.bin"
                set BMPFileOutput "$CompactDirOutput/compact_l1_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_l2.bin"
                set BMPFileOutput "$CompactDirOutput/compact_l2_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPprobabilities"=="1"} {
            if [file exists "$CompactDirOutput/compact_p1.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_p1.bin"
                set BMPFileOutput "$CompactDirOutput/compact_p1.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_p2.bin"
                set BMPFileOutput "$CompactDirOutput/compact_p2.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }


        if {"$BMPmv"=="1"} {
            if [file exists "$CompactDirOutput/compact_mv.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_mv.bin"
                set BMPFileOutput "$CompactDirOutput/compact_mv_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPms"=="1"} {
            if [file exists "$CompactDirOutput/compact_ms.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_ms.bin"
                set BMPFileOutput "$CompactDirOutput/compact_ms_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPalphas"=="1"} {
            if [file exists "$CompactDirOutput/compact_alpha_s.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_alpha_s.bin"
                set BMPFileOutput "$CompactDirOutput/compact_alpha_s.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -90 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPphi"=="1"} {
            if [file exists "$CompactDirOutput/compact_phi.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_phi.bin"
                set BMPFileOutput "$CompactDirOutput/compact_phi.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPPsPdPv"=="1"} {
            if [file exists "$CompactDirOutput/compact_Ps.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_Ps.bin"
                set BMPFileOutput "$CompactDirOutput/compact_Ps_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$CompactDirOutput/compact_Pd.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_Pd.bin"
                set BMPFileOutput "$CompactDirOutput/compact_Pd_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$CompactDirOutput/compact_Pv.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_Pv.bin"
                set BMPFileOutput "$CompactDirOutput/compact_Pv_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set config "true"
            if [file exists "$CompactDirOutput/compact_Ps.bin"] { } else { set config "false" }
            if [file exists "$CompactDirOutput/compact_Pd.bin"] { } else { set config "false" }
            if [file exists "$CompactDirOutput/compact_Pv.bin"] { } else { set config "false" }
            if {$config == "true" } {
                set FileInputBlue "$CompactDirOutput/compact_Ps.bin"
                set FileInputGreen "$CompactDirOutput/compact_Pv.bin"
                set FileInputRed "$CompactDirOutput/compact_Pd.bin"
                set RGBFileOutput "$CompactDirOutput/compact_PsPdPv_RGB.bmp"
                set MaskCmd ""
                set MaskFile "$CompactDirOutput/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                set f [ open "| Soft/bmp_process/create_rgb_file.exe -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }
            }

        if {"$BMPsigmahv"=="1"} {
            if [file exists "$CompactDirOutput/compact_sigma_hv.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_sigma_hv.bin"
                set BMPFileOutput "$CompactDirOutput/compact_sigma_hv_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPstvr"=="1"} {
            if [file exists "$CompactDirOutput/compact_RSoV.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_RSoV.bin"
                set BMPFileOutput "$CompactDirOutput/compact_RSoV.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPCPR"=="1"} {
            if [file exists "$CompactDirOutput/compact_cpr.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_cpr.bin"
                set BMPFileOutput "$CompactDirOutput/compact_cpr.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPalpha"=="1"} {
            if [file exists "$CompactDirOutput/compact_alpha.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_alpha.bin"
                set BMPFileOutput "$CompactDirOutput/compact_alpha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -90 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPtau"=="1"} {
            if [file exists "$CompactDirOutput/compact_tau.bin"] {
                set BMPDirInput $CompactDirOutput
                set BMPFileInput "$CompactDirOutput/compact_tau.bin"
                set BMPFileOutput "$CompactDirOutput/compact_tau.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel442); TextEditorRunTrace "Close Window Compact Decomposition" "b"}
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but442" "Button13" vTcl:WidgetProc "Toplevel442" 1
    bindtags $site_3_0.but442 "$site_3_0.but442 Button $top all _vTclBalloon"
    bind $site_3_0.but442 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CompactDecomposition.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel442" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel442); TextEditorRunTrace "Close Window Compact Decomposition" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel442" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but442 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd84 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill none -ipadx 50 -pady 2 \
        -side top 
    pack $top.fra37 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra40 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra47 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra48 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra41 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra43 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra45 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra46 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd70 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
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
Window show .top442

main $argc $argv
