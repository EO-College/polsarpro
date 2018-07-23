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

        {{[file join . GUI Images calculator2.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
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
    set base .top600
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.lab78 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra79 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra79
    namespace eval ::widgets::$site_4_0.fra80 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra80
    namespace eval ::widgets::$site_5_0.ent81 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -relief 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra122 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra122
    namespace eval ::widgets::$site_6_0.lab125 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd124 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.ent81 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -relief 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra66 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra66
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-font 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.ent81 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -relief 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd126 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd126
    namespace eval ::widgets::$site_6_0.lab125 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd124 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra66
    namespace eval ::widgets::$site_4_0.tit67 {
        array set save {-foreground 1 -text 1}
    }
    set site_6_0 [$site_4_0.tit67 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.but68 {
        array set save {-command 1 -foreground 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-command 1 -foreground 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-command 1 -foreground 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-command 1 -foreground 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-command 1 -foreground 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra73 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra73
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-background 1 -command 1 -foreground 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -command 1 -foreground 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-activeforeground 1 -background 1 -command 1 -foreground 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-background 1 -command 1 -foreground 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.tit86 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit86 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd89 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd96
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd95
    namespace eval ::widgets::$site_7_0.tit97 {
        array set save {-ipad 1 -text 1}
    }
    set site_9_0 [$site_7_0.tit97 getframe]
    namespace eval ::widgets::$site_9_0 {
        array set save {}
    }
    set site_9_0 $site_9_0
    namespace eval ::widgets::$site_9_0.ent98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.lab99 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent100 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd102 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd105 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd103 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd106 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd104 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd107 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd108 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd108 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd89 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd96
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd95
    namespace eval ::widgets::$site_7_0.tit97 {
        array set save {-ipad 1 -text 1}
    }
    set site_9_0 [$site_7_0.tit97 getframe]
    namespace eval ::widgets::$site_9_0 {
        array set save {}
    }
    set site_9_0 $site_9_0
    namespace eval ::widgets::$site_9_0.ent98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.lab99 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent100 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd102 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd105 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd103 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd106 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd104 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd107 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra109 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra109
    namespace eval ::widgets::$site_4_0.tit110 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.tit110 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.rad112 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd113 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd114 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd111 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd115 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd115
    namespace eval ::widgets::$site_7_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd116 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd66 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.fra71 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra71
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.rad85 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd86 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd87 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd77
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd80
    namespace eval ::widgets::$site_8_0.fra89 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra89
    namespace eval ::widgets::$site_9_0.cpd106 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd94
    namespace eval ::widgets::$site_9_0.cpd105 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd95
    namespace eval ::widgets::$site_9_0.cpd104 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd96
    namespace eval ::widgets::$site_9_0.cpd103 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd119 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd119
    namespace eval ::widgets::$site_8_0.fra89 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra89
    namespace eval ::widgets::$site_9_0.cpd106 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd94
    namespace eval ::widgets::$site_9_0.cpd105 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd95
    namespace eval ::widgets::$site_9_0.cpd104 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd96
    namespace eval ::widgets::$site_9_0.cpd103 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd120 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd120
    namespace eval ::widgets::$site_8_0.fra89 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra89
    namespace eval ::widgets::$site_9_0.cpd106 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd94
    namespace eval ::widgets::$site_9_0.cpd105 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd95
    namespace eval ::widgets::$site_9_0.cpd104 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd96
    namespace eval ::widgets::$site_9_0.cpd103 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd121 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd121
    namespace eval ::widgets::$site_8_0.fra89 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra89
    namespace eval ::widgets::$site_9_0.cpd106 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd94
    namespace eval ::widgets::$site_9_0.cpd105 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd95
    namespace eval ::widgets::$site_9_0.cpd104 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd96
    namespace eval ::widgets::$site_9_0.cpd103 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent90 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd91 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd121 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd121
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd111 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd115 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd115
    namespace eval ::widgets::$site_7_0.ent90 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-background 1 -image 1 -padx 1 -pady 1 -takefocus 1}
    }
    namespace eval ::widgets::$site_5_0.cpd120 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd68
    namespace eval ::widgets::$site_3_0.tit69 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.tit69 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd97 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd97
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd98 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd98
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd99 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd99
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd97 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd97
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd98 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd98
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd100 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd100
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd97 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd97
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd98 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd98
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd101
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd97 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd97
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd98 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd98
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.but84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd99 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd99
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd100 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd100
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -state 1 -takefocus 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd101
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -state 1 -takefocus 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.but84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd99 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd99
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd100 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd100
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd101
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd95
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.but84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd99 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd99
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd100 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd100
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd101
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd91
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd93
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd94
    namespace eval ::widgets::$site_8_0.rad73 {
        array set save {-borderwidth 1 -command 1 -takefocus 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.but84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            PSPCalcRAZ
            PSPCalcOperatorFileOFF
            PSPCalcOperatorMatSOFF
            PSPCalcOperatorMatMOFF
            PSPCalcOperatorMatXOFF
            PSPCalcCreateMatXOFF
            PSPCalcRAZButton
            PSPCalcRAZButtonMemory
            PSPCalcInputFileOFF
            PSPCalcInputDirMatOFF
            PSPCalcInputValueOFF
            PSPCalcOutputValueOFF
            PSPCalcInputFileON
            PSPCalcInputDirMatON
            PSPCalcCreateMatXON
            PSPCalcCreateMatXRAZ
            PSPCalcCreateMatXInitCmplx
            PSPCalcCreateMatXInitFltInt
            PSPCalcCreateMatXInitHerm
            PSPCalcTestSU
            PSPCalcOperatorFileON
            PSPCalcOperatorMatMON
            PSPCalcOperatorMatSON
            PSPCalcOperatorMatXON
            PSPCalcInputValueON
            PSPCalcInitOperand2
            PSPCalcRunFile
            PSPCalcRunMatM
            PSPCalcRunMatS
            PSPCalcCleanResultDir
            PSPCalcDefineOutput
            PSPCalcLoadConfig
            PSPCalcEnviWriteConfig
            PSPCalcEnviWriteConfigS
            PSPCalcEnviWriteConfigC
            PSPCalcEnviWriteConfigT
            PSPCalcEnviWriteConfigCheck
            PSPCalcMapInfoReadConfig
            PSPCalcOutputValueON
            PSPCalcRunMatX
            PSPCalcOperatorFileRAZ
            PSPCalcOperatorMatSRAZ
            PSPCalcOperatorMatMRAZ
            PSPCalcOperatorMatXRAZ
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

proc ::main {argc argv} {}
#############################################################################
## Procedure:  PSPCalcRAZ

proc ::PSPCalcRAZ {} {
global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global PSPCalcRes1Name PSPCalcOperandRes1 PSPCalcRes1Type PSPCalcRes1Format PSPCalcRes1PolarCase PSPCalcRes1PolarType PSPCalcRes1MatDim PSPCalcRes1FileInput PSPCalcRes1MatDirInput
global PSPCalcRes2Name PSPCalcOperandRes2 PSPCalcRes2Type PSPCalcRes2Format PSPCalcRes2PolarCase PSPCalcRes2PolarType PSPCalcRes2MatDim PSPCalcRes2FileInput PSPCalcRes2MatDirInput
global PSPCalcRes3Name PSPCalcOperandRes3 PSPCalcRes3Type PSPCalcRes3Format PSPCalcRes3PolarCase PSPCalcRes3PolarType PSPCalcRes3MatDim PSPCalcRes3FileInput PSPCalcRes3MatDirInput
global PSPCalcMemName PSPCalcOperandMem PSPCalcMemType PSPCalcMemFormat PSPCalcMemPolarCase PSPCalcMemPolarType PSPCalcMemMatDim
global PSPCalcMemFileInput PSPCalcMemMatDirInput
global PSPCalcOperand PSPCalcOperatorF PSPCalcOperatorM PSPCalcOperatorS PSPCalcOperatorX PSPCalcOperatorName
global PSPCalcInputFile PSPCalcInputFileFormat PSPCalcInputDirMat PSPCalcInputDirMatFormat
global PSPCalcOutputFile PSPCalcOutputFileFormat PSPCalcOutputDirMat PSPCalcOutputDirMatFormat
global PSPCalcMapInfoActive PSPCalcMapInfoMapInfo PSPCalcMapInfoProjInfo PSPCalcMapInfoUnit
global PSPCalcOutput PSPCalcOutputTab PSPCalcMemory PSPCalcNwinL PSPCalcNwinC PSPCalcNlook PSPCalcFilter
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global NligInitRes1 NligEndRes1 NcolInitRes1 NcolEndRes1
global NligInitRes2 NligEndRes2 NcolInitRes2 NcolEndRes2
global NligInitRes3 NligEndRes3 NcolInitRes3 NcolEndRes3
global NligInitMem NligEndMem NcolInitMem NcolEndMem
global PSPBackgroundColor

set PSPCalcOp1Name "Select Operand #1"; set PSPCalcOperand1 "---"; set PSPCalcOp1Type ""; set PSPCalcOp1Format ""
set PSPCalcOp1PolarCase ""; set PSPCalcOp1PolarType ""; set PSPCalcOp1MatDim ""
set PSPCalcOp1FileInput ""; set PSPCalcOp1MatDirInput ""
set PSPCalcOp2Name ""; set PSPCalcOperand2 ""; set PSPCalcOp2Type ""; set PSPCalcOp2Format ""
set PSPCalcOp2PolarCase ""; set PSPCalcOp2PolarType ""; set PSPCalcOp2MatDim ""
set PSPCalcOp2FileInput ""; set PSPCalcOp2MatDirInput ""
set PSPCalcOp2ValueInputReal ""; set PSPCalcOp2ValueInputImag ""
set PSPCalcRes1Name ""; set PSPCalcOperandRes1 ""; set PSPCalcRes1Type ""; set PSPCalcRes1Format ""
set PSPCalcRes1PolarCase ""; set PSPCalcRes1PolarType ""; set PSPCalcRes1MatDim ""
set PSPCalcRes1FileInput ""; set PSPCalcRes1MatDirInput ""
set PSPCalcRes2Name ""; set PSPCalcOperandRes2 ""; set PSPCalcRes2Type ""; set PSPCalcRes2Format ""
set PSPCalcRes2PolarCase ""; set PSPCalcRes2PolarType ""; set PSPCalcRes2MatDim ""
set PSPCalcRes2FileInput ""; set PSPCalcRes2MatDirInput ""
set PSPCalcRes3Name ""; set PSPCalcOperandRes3 ""; set PSPCalcRes3Type ""; set PSPCalcRes3Format ""
set PSPCalcRes3PolarCase ""; set PSPCalcRes3PolarType ""; set PSPCalcRes3MatDim ""
set PSPCalcRes3FileInput ""; set PSPCalcRes3MatDirInput ""
set PSPCalcMemName ""; set PSPCalcOperandMem ""; set PSPCalcMemType ""; set PSPCalcMemFormat ""
set PSPCalcMemPolarCase ""; set PSPCalcMemPolarType ""; set PSPCalcMemMatDim ""
set PSPCalcMemFileInput ""; set PSPCalcMemMatDirInput ""
set PSPCalcNwinL ""; set PSPCalcNwinC ""; set PSPCalcNlook ""; set PSPCalcFilter ""

set PSPCalcOperand ""; set PSPCalcOperatorName ""
set PSPCalcOperatorF ""; set PSPCalcOperatorS ""; set PSPCalcOperatorM ""; set PSPCalcOperatorX ""

set PSPCalcInputFile ""; set PSPCalcInputFileFormat ""; set PSPCalcInputDirMat ""; set PSPCalcInputDirMatFormat ""
set PSPCalcOutputFile ""; set PSPCalcOutputFileFormat ""; set PSPCalcOutputDirMat ""; set PSPCalcOutputDirMatFormat ""

set PSPCalcMapInfoActive ""
set PSPCalcMapInfoMapInfo ""
set PSPCalcMapInfoProjInfo ""
set PSPCalcMapInfoUnit ""

set PSPCalcOutput ""; set PSPCalcMemory ""
for {set i 0} {$i <= 3} {incr i} { set PSPCalcOutputTab($i) $i }

set NligInitOp1 ""; set NligEndOp1 ""; set NcolInitOp1 ""; set NcolEndOp1 ""
set NligInitOp2 ""; set NligEndOp2 ""; set NcolInitOp2 ""; set NcolEndOp2 ""
set NligInitRes1 ""; set NligEndRes1 ""; set NcolInitRes1 ""; set NcolEndRes1 ""
set NligInitRes2 ""; set NligEndRes2 ""; set NcolInitRes2 ""; set NcolEndRes2 ""
set NligInitMem ""; set NligEndMem ""; set NcolInitMem ""; set NcolEndMem ""

Window hide .top601
Window hide .top602
Window hide .top603
PSPCalcRAZButton
PSPCalcRAZButtonMemory
PSPCalcOperatorFileOFF
PSPCalcOperatorMatSOFF
PSPCalcOperatorMatMOFF
PSPCalcOperatorMatXOFF
PSPCalcCreateMatXOFF
PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcOutputValueOFF
}
#############################################################################
## Procedure:  PSPCalcOperatorFileOFF

proc ::PSPCalcOperatorFileOFF {} {
global PSPCalcOperatorF PSPBackgroundColor
global PSPCalcOperatorFileTitleFrame PSPCalcOperatorFileButtonOK
global PSPCalcOperatorFileRadio11 PSPCalcOperatorFileRadio12 PSPCalcOperatorFileRadio13 PSPCalcOperatorFileRadio14
global PSPCalcOperatorFileRadio15 PSPCalcOperatorFileRadio16 PSPCalcOperatorFileRadio17 PSPCalcOperatorFileRadio18
global PSPCalcOperatorFileRadio21 PSPCalcOperatorFileRadio22 PSPCalcOperatorFileRadio23 PSPCalcOperatorFileRadio24
global PSPCalcOperatorFileRadio25 PSPCalcOperatorFileRadio26 PSPCalcOperatorFileRadio27 PSPCalcOperatorFileRadio28
global PSPCalcOperatorFileRadio31 PSPCalcOperatorFileRadio32 PSPCalcOperatorFileRadio33 PSPCalcOperatorFileRadio34
global PSPCalcOperatorFileRadio35 PSPCalcOperatorFileRadio36 PSPCalcOperatorFileRadio37 PSPCalcOperatorFileRadio38
global PSPCalcOperatorFileRadio41 PSPCalcOperatorFileRadio42 PSPCalcOperatorFileRadio43 PSPCalcOperatorFileRadio44
global PSPCalcOperatorFileRadio45 PSPCalcOperatorFileRadio46 PSPCalcOperatorFileRadio47 PSPCalcOperatorFileRadio48

set PSPCalcOperatorFileTitleFrame .top600.cpd68.tit69
set PSPCalcOperatorFileButtonOK .top600.cpd68.tit69.f.cpd71.but84
set PSPCalcOperatorFileRadio11 .top600.cpd68.tit69.f.cpd70.cpd72.cpd88.rad73
set PSPCalcOperatorFileRadio12 .top600.cpd68.tit69.f.cpd70.cpd72.cpd91.rad73
set PSPCalcOperatorFileRadio13 .top600.cpd68.tit69.f.cpd70.cpd72.cpd93.rad73
set PSPCalcOperatorFileRadio14 .top600.cpd68.tit69.f.cpd70.cpd72.cpd94.rad73
set PSPCalcOperatorFileRadio15 .top600.cpd68.tit69.f.cpd70.cpd72.cpd95.rad73
set PSPCalcOperatorFileRadio16 .top600.cpd68.tit69.f.cpd70.cpd72.cpd96.rad73
set PSPCalcOperatorFileRadio17 .top600.cpd68.tit69.f.cpd70.cpd72.cpd97.rad73
set PSPCalcOperatorFileRadio18 .top600.cpd68.tit69.f.cpd70.cpd72.cpd98.rad73
set PSPCalcOperatorFileRadio21 .top600.cpd68.tit69.f.cpd70.cpd99.cpd88.rad73
set PSPCalcOperatorFileRadio22 .top600.cpd68.tit69.f.cpd70.cpd99.cpd91.rad73
set PSPCalcOperatorFileRadio23 .top600.cpd68.tit69.f.cpd70.cpd99.cpd93.rad73
set PSPCalcOperatorFileRadio24 .top600.cpd68.tit69.f.cpd70.cpd99.cpd94.rad73
set PSPCalcOperatorFileRadio25 .top600.cpd68.tit69.f.cpd70.cpd99.cpd95.rad73
set PSPCalcOperatorFileRadio26 .top600.cpd68.tit69.f.cpd70.cpd99.cpd96.rad73
set PSPCalcOperatorFileRadio27 .top600.cpd68.tit69.f.cpd70.cpd99.cpd97.rad73
set PSPCalcOperatorFileRadio28 .top600.cpd68.tit69.f.cpd70.cpd99.cpd98.rad73
set PSPCalcOperatorFileRadio31 .top600.cpd68.tit69.f.cpd70.cpd100.cpd88.rad73
set PSPCalcOperatorFileRadio32 .top600.cpd68.tit69.f.cpd70.cpd100.cpd91.rad73
set PSPCalcOperatorFileRadio33 .top600.cpd68.tit69.f.cpd70.cpd100.cpd93.rad73
set PSPCalcOperatorFileRadio34 .top600.cpd68.tit69.f.cpd70.cpd100.cpd94.rad73
set PSPCalcOperatorFileRadio35 .top600.cpd68.tit69.f.cpd70.cpd100.cpd95.rad73
set PSPCalcOperatorFileRadio36 .top600.cpd68.tit69.f.cpd70.cpd100.cpd96.rad73
set PSPCalcOperatorFileRadio37 .top600.cpd68.tit69.f.cpd70.cpd100.cpd97.rad73
set PSPCalcOperatorFileRadio38 .top600.cpd68.tit69.f.cpd70.cpd100.cpd98.rad73
set PSPCalcOperatorFileRadio41 .top600.cpd68.tit69.f.cpd70.cpd101.cpd88.rad73
set PSPCalcOperatorFileRadio42 .top600.cpd68.tit69.f.cpd70.cpd101.cpd91.rad73
set PSPCalcOperatorFileRadio43 .top600.cpd68.tit69.f.cpd70.cpd101.cpd93.rad73
set PSPCalcOperatorFileRadio44 .top600.cpd68.tit69.f.cpd70.cpd101.cpd94.rad73
set PSPCalcOperatorFileRadio45 .top600.cpd68.tit69.f.cpd70.cpd101.cpd95.rad73
set PSPCalcOperatorFileRadio46 .top600.cpd68.tit69.f.cpd70.cpd101.cpd96.rad73
set PSPCalcOperatorFileRadio47 .top600.cpd68.tit69.f.cpd70.cpd101.cpd97.rad73
set PSPCalcOperatorFileRadio48 .top600.cpd68.tit69.f.cpd70.cpd101.cpd98.rad73

set PSPCalcOperatorF ""
$PSPCalcOperatorFileTitleFrame configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorFileButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorFileRadio11 configure -state disable; $PSPCalcOperatorFileRadio12 configure -state disable;
$PSPCalcOperatorFileRadio13 configure -state disable; $PSPCalcOperatorFileRadio14 configure -state disable;
$PSPCalcOperatorFileRadio15 configure -state disable; $PSPCalcOperatorFileRadio16 configure -state disable; 
$PSPCalcOperatorFileRadio17 configure -state disable; $PSPCalcOperatorFileRadio18 configure -state disable;
$PSPCalcOperatorFileRadio21 configure -state disable; $PSPCalcOperatorFileRadio22 configure -state disable; 
$PSPCalcOperatorFileRadio23 configure -state disable; $PSPCalcOperatorFileRadio24 configure -state disable;
$PSPCalcOperatorFileRadio25 configure -state disable; $PSPCalcOperatorFileRadio26 configure -state disable; 
$PSPCalcOperatorFileRadio27 configure -state disable; $PSPCalcOperatorFileRadio28 configure -state disable;
$PSPCalcOperatorFileRadio31 configure -state disable; $PSPCalcOperatorFileRadio32 configure -state disable; 
$PSPCalcOperatorFileRadio33 configure -state disable; $PSPCalcOperatorFileRadio34 configure -state disable;
$PSPCalcOperatorFileRadio35 configure -state disable; $PSPCalcOperatorFileRadio36 configure -state disable; 
$PSPCalcOperatorFileRadio37 configure -state disable; $PSPCalcOperatorFileRadio38 configure -state disable;
$PSPCalcOperatorFileRadio41 configure -state disable; $PSPCalcOperatorFileRadio42 configure -state disable; 
$PSPCalcOperatorFileRadio43 configure -state disable; $PSPCalcOperatorFileRadio44 configure -state disable;
$PSPCalcOperatorFileRadio45 configure -state disable; $PSPCalcOperatorFileRadio46 configure -state disable; 
$PSPCalcOperatorFileRadio47 configure -state disable; $PSPCalcOperatorFileRadio48 configure -state disable;
}
#############################################################################
## Procedure:  PSPCalcOperatorMatSOFF

proc ::PSPCalcOperatorMatSOFF {} {
global PSPCalcOperatorS PSPBackgroundColor
global PSPCalcOperatorMatSTitleFrame PSPCalcOperatorMatSButtonOK
global PSPCalcOperatorMatSRadio11 PSPCalcOperatorMatSRadio12 PSPCalcOperatorMatSRadio13 PSPCalcOperatorMatSRadio14
global PSPCalcOperatorMatSRadio15 PSPCalcOperatorMatSRadio16 
global PSPCalcOperatorMatSRadio21 PSPCalcOperatorMatSRadio22 PSPCalcOperatorMatSRadio23 PSPCalcOperatorMatSRadio24
global PSPCalcOperatorMatSRadio25 PSPCalcOperatorMatSRadio26 
global PSPCalcOperatorMatSRadio31 PSPCalcOperatorMatSRadio32 PSPCalcOperatorMatSRadio33 PSPCalcOperatorMatSRadio34
global PSPCalcOperatorMatSRadio35 PSPCalcOperatorMatSRadio36 
global PSPCalcOperatorMatSRadio41 PSPCalcOperatorMatSRadio42 PSPCalcOperatorMatSRadio43 PSPCalcOperatorMatSRadio44
global PSPCalcOperatorMatSRadio45 PSPCalcOperatorMatSRadio46 

set PSPCalcOperatorMatSTitleFrame .top600.cpd68.cpd67
set PSPCalcOperatorMatSButtonOK .top600.cpd68.cpd67.f.cpd71.but84
set PSPCalcOperatorMatSRadio11 .top600.cpd68.cpd67.f.cpd70.cpd72.cpd88.rad73
set PSPCalcOperatorMatSRadio12 .top600.cpd68.cpd67.f.cpd70.cpd72.cpd91.rad73
set PSPCalcOperatorMatSRadio13 .top600.cpd68.cpd67.f.cpd70.cpd72.cpd93.rad73
set PSPCalcOperatorMatSRadio14 .top600.cpd68.cpd67.f.cpd70.cpd72.cpd94.rad73
set PSPCalcOperatorMatSRadio15 .top600.cpd68.cpd67.f.cpd70.cpd72.cpd95.rad73
set PSPCalcOperatorMatSRadio16 .top600.cpd68.cpd67.f.cpd70.cpd72.cpd96.rad73
set PSPCalcOperatorMatSRadio21 .top600.cpd68.cpd67.f.cpd70.cpd99.cpd88.rad73
set PSPCalcOperatorMatSRadio22 .top600.cpd68.cpd67.f.cpd70.cpd99.cpd91.rad73
set PSPCalcOperatorMatSRadio23 .top600.cpd68.cpd67.f.cpd70.cpd99.cpd93.rad73
set PSPCalcOperatorMatSRadio24 .top600.cpd68.cpd67.f.cpd70.cpd99.cpd94.rad73
set PSPCalcOperatorMatSRadio25 .top600.cpd68.cpd67.f.cpd70.cpd99.cpd95.rad73
set PSPCalcOperatorMatSRadio26 .top600.cpd68.cpd67.f.cpd70.cpd99.cpd96.rad73
set PSPCalcOperatorMatSRadio31 .top600.cpd68.cpd67.f.cpd70.cpd100.cpd88.rad73
set PSPCalcOperatorMatSRadio32 .top600.cpd68.cpd67.f.cpd70.cpd100.cpd91.rad73
set PSPCalcOperatorMatSRadio33 .top600.cpd68.cpd67.f.cpd70.cpd100.cpd93.rad73
set PSPCalcOperatorMatSRadio34 .top600.cpd68.cpd67.f.cpd70.cpd100.cpd94.rad73
set PSPCalcOperatorMatSRadio35 .top600.cpd68.cpd67.f.cpd70.cpd100.cpd95.rad73
set PSPCalcOperatorMatSRadio36 .top600.cpd68.cpd67.f.cpd70.cpd100.cpd96.rad73
set PSPCalcOperatorMatSRadio41 .top600.cpd68.cpd67.f.cpd70.cpd101.cpd88.rad73
set PSPCalcOperatorMatSRadio42 .top600.cpd68.cpd67.f.cpd70.cpd101.cpd91.rad73
set PSPCalcOperatorMatSRadio43 .top600.cpd68.cpd67.f.cpd70.cpd101.cpd93.rad73
set PSPCalcOperatorMatSRadio44 .top600.cpd68.cpd67.f.cpd70.cpd101.cpd94.rad73
set PSPCalcOperatorMatSRadio45 .top600.cpd68.cpd67.f.cpd70.cpd101.cpd95.rad73
set PSPCalcOperatorMatSRadio46 .top600.cpd68.cpd67.f.cpd70.cpd101.cpd96.rad73

set PSPCalcOperatorS ""
$PSPCalcOperatorMatSTitleFrame configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorMatSButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorMatSRadio11 configure -state disable; $PSPCalcOperatorMatSRadio12 configure -state disable;
$PSPCalcOperatorMatSRadio13 configure -state disable; $PSPCalcOperatorMatSRadio14 configure -state disable;
$PSPCalcOperatorMatSRadio15 configure -state disable; $PSPCalcOperatorMatSRadio16 configure -state disable;
$PSPCalcOperatorMatSRadio21 configure -state disable; $PSPCalcOperatorMatSRadio22 configure -state disable; 
$PSPCalcOperatorMatSRadio23 configure -state disable; $PSPCalcOperatorMatSRadio24 configure -state disable;
$PSPCalcOperatorMatSRadio25 configure -state disable; $PSPCalcOperatorMatSRadio26 configure -state disable;
$PSPCalcOperatorMatSRadio31 configure -state disable; $PSPCalcOperatorMatSRadio32 configure -state disable; 
$PSPCalcOperatorMatSRadio33 configure -state disable; $PSPCalcOperatorMatSRadio34 configure -state disable;
$PSPCalcOperatorMatSRadio35 configure -state disable; $PSPCalcOperatorMatSRadio36 configure -state disable;
$PSPCalcOperatorMatSRadio41 configure -state disable; $PSPCalcOperatorMatSRadio42 configure -state disable; 
$PSPCalcOperatorMatSRadio43 configure -state disable; $PSPCalcOperatorMatSRadio44 configure -state disable;
$PSPCalcOperatorMatSRadio45 configure -state disable; $PSPCalcOperatorMatSRadio46 configure -state disable;
}
#############################################################################
## Procedure:  PSPCalcOperatorMatMOFF

proc ::PSPCalcOperatorMatMOFF {} {
global PSPCalcOperatorM PSPBackgroundColor
global PSPCalcOperatorMatMTitleFrame PSPCalcOperatorMatMButtonOK
global PSPCalcOperatorMatMRadio11 PSPCalcOperatorMatMRadio12 PSPCalcOperatorMatMRadio13 PSPCalcOperatorMatMRadio14
global PSPCalcOperatorMatMRadio15 
global PSPCalcOperatorMatMRadio21 PSPCalcOperatorMatMRadio22 PSPCalcOperatorMatMRadio23 PSPCalcOperatorMatMRadio24
global PSPCalcOperatorMatMRadio25 
global PSPCalcOperatorMatMRadio31 PSPCalcOperatorMatMRadio32 PSPCalcOperatorMatMRadio33 PSPCalcOperatorMatMRadio34
global PSPCalcOperatorMatMRadio35 
global PSPCalcOperatorMatMRadio41 PSPCalcOperatorMatMRadio42 PSPCalcOperatorMatMRadio43 PSPCalcOperatorMatMRadio44
global PSPCalcOperatorMatMRadio45 

set PSPCalcOperatorMatMTitleFrame .top600.cpd68.cpd68
set PSPCalcOperatorMatMButtonOK .top600.cpd68.cpd68.f.cpd71.but84
set PSPCalcOperatorMatMRadio11 .top600.cpd68.cpd68.f.cpd70.cpd72.cpd88.rad73
set PSPCalcOperatorMatMRadio12 .top600.cpd68.cpd68.f.cpd70.cpd72.cpd91.rad73
set PSPCalcOperatorMatMRadio13 .top600.cpd68.cpd68.f.cpd70.cpd72.cpd93.rad73
set PSPCalcOperatorMatMRadio14 .top600.cpd68.cpd68.f.cpd70.cpd72.cpd94.rad73
set PSPCalcOperatorMatMRadio15 .top600.cpd68.cpd68.f.cpd70.cpd72.cpd95.rad73
set PSPCalcOperatorMatMRadio21 .top600.cpd68.cpd68.f.cpd70.cpd99.cpd88.rad73
set PSPCalcOperatorMatMRadio22 .top600.cpd68.cpd68.f.cpd70.cpd99.cpd91.rad73
set PSPCalcOperatorMatMRadio23 .top600.cpd68.cpd68.f.cpd70.cpd99.cpd93.rad73
set PSPCalcOperatorMatMRadio24 .top600.cpd68.cpd68.f.cpd70.cpd99.cpd94.rad73
set PSPCalcOperatorMatMRadio25 .top600.cpd68.cpd68.f.cpd70.cpd99.cpd95.rad73
set PSPCalcOperatorMatMRadio31 .top600.cpd68.cpd68.f.cpd70.cpd100.cpd88.rad73
set PSPCalcOperatorMatMRadio32 .top600.cpd68.cpd68.f.cpd70.cpd100.cpd91.rad73
set PSPCalcOperatorMatMRadio33 .top600.cpd68.cpd68.f.cpd70.cpd100.cpd93.rad73
set PSPCalcOperatorMatMRadio34 .top600.cpd68.cpd68.f.cpd70.cpd100.cpd94.rad73
set PSPCalcOperatorMatMRadio35 .top600.cpd68.cpd68.f.cpd70.cpd100.cpd95.rad73
set PSPCalcOperatorMatMRadio41 .top600.cpd68.cpd68.f.cpd70.cpd101.cpd88.rad73
set PSPCalcOperatorMatMRadio42 .top600.cpd68.cpd68.f.cpd70.cpd101.cpd91.rad73
set PSPCalcOperatorMatMRadio43 .top600.cpd68.cpd68.f.cpd70.cpd101.cpd93.rad73
set PSPCalcOperatorMatMRadio44 .top600.cpd68.cpd68.f.cpd70.cpd101.cpd94.rad73
set PSPCalcOperatorMatMRadio45 .top600.cpd68.cpd68.f.cpd70.cpd101.cpd95.rad73

set PSPCalcOperatorM ""
$PSPCalcOperatorMatMTitleFrame configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorMatMButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorMatMRadio11 configure -state disable; $PSPCalcOperatorMatMRadio12 configure -state disable;
$PSPCalcOperatorMatMRadio13 configure -state disable; $PSPCalcOperatorMatMRadio14 configure -state disable;
$PSPCalcOperatorMatMRadio15 configure -state disable;
$PSPCalcOperatorMatMRadio21 configure -state disable; $PSPCalcOperatorMatMRadio22 configure -state disable; 
$PSPCalcOperatorMatMRadio23 configure -state disable; $PSPCalcOperatorMatMRadio24 configure -state disable;
$PSPCalcOperatorMatMRadio25 configure -state disable;
$PSPCalcOperatorMatMRadio31 configure -state disable; $PSPCalcOperatorMatMRadio32 configure -state disable; 
$PSPCalcOperatorMatMRadio33 configure -state disable; $PSPCalcOperatorMatMRadio34 configure -state disable;
$PSPCalcOperatorMatMRadio35 configure -state disable;
$PSPCalcOperatorMatMRadio41 configure -state disable; $PSPCalcOperatorMatMRadio42 configure -state disable; 
$PSPCalcOperatorMatMRadio43 configure -state disable; $PSPCalcOperatorMatMRadio44 configure -state disable;
$PSPCalcOperatorMatMRadio45 configure -state disable;
}
#############################################################################
## Procedure:  PSPCalcOperatorMatXOFF

proc ::PSPCalcOperatorMatXOFF {} {
global PSPCalcOperatorX PSPBackgroundColor
global PSPCalcOperatorMatXTitleFrame PSPCalcOperatorMatXButtonOK
global PSPCalcOperatorMatXRadio11 PSPCalcOperatorMatXRadio12 PSPCalcOperatorMatXRadio13 PSPCalcOperatorMatXRadio14
global PSPCalcOperatorMatXRadio21 PSPCalcOperatorMatXRadio22 PSPCalcOperatorMatXRadio23 PSPCalcOperatorMatXRadio24
global PSPCalcOperatorMatXRadio31 PSPCalcOperatorMatXRadio32 PSPCalcOperatorMatXRadio33 PSPCalcOperatorMatXRadio34
global PSPCalcOperatorMatXRadio41 PSPCalcOperatorMatXRadio42 PSPCalcOperatorMatXRadio43 PSPCalcOperatorMatXRadio44

set PSPCalcOperatorMatXTitleFrame .top600.cpd68.cpd69
set PSPCalcOperatorMatXButtonOK .top600.cpd68.cpd69.f.cpd71.but84
set PSPCalcOperatorMatXRadio11 .top600.cpd68.cpd69.f.cpd70.cpd72.cpd88.rad73
set PSPCalcOperatorMatXRadio12 .top600.cpd68.cpd69.f.cpd70.cpd72.cpd91.rad73
set PSPCalcOperatorMatXRadio13 .top600.cpd68.cpd69.f.cpd70.cpd72.cpd93.rad73
set PSPCalcOperatorMatXRadio14 .top600.cpd68.cpd69.f.cpd70.cpd72.cpd94.rad73
set PSPCalcOperatorMatXRadio21 .top600.cpd68.cpd69.f.cpd70.cpd99.cpd88.rad73
set PSPCalcOperatorMatXRadio22 .top600.cpd68.cpd69.f.cpd70.cpd99.cpd91.rad73
set PSPCalcOperatorMatXRadio23 .top600.cpd68.cpd69.f.cpd70.cpd99.cpd93.rad73
set PSPCalcOperatorMatXRadio24 .top600.cpd68.cpd69.f.cpd70.cpd99.cpd94.rad73
set PSPCalcOperatorMatXRadio31 .top600.cpd68.cpd69.f.cpd70.cpd100.cpd88.rad73
set PSPCalcOperatorMatXRadio32 .top600.cpd68.cpd69.f.cpd70.cpd100.cpd91.rad73
set PSPCalcOperatorMatXRadio33 .top600.cpd68.cpd69.f.cpd70.cpd100.cpd93.rad73
set PSPCalcOperatorMatXRadio34 .top600.cpd68.cpd69.f.cpd70.cpd100.cpd94.rad73
set PSPCalcOperatorMatXRadio41 .top600.cpd68.cpd69.f.cpd70.cpd101.cpd88.rad73
set PSPCalcOperatorMatXRadio42 .top600.cpd68.cpd69.f.cpd70.cpd101.cpd91.rad73
set PSPCalcOperatorMatXRadio43 .top600.cpd68.cpd69.f.cpd70.cpd101.cpd93.rad73
set PSPCalcOperatorMatXRadio44 .top600.cpd68.cpd69.f.cpd70.cpd101.cpd94.rad73

set PSPCalcOperatorX ""
$PSPCalcOperatorMatXTitleFrame configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorMatXButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcOperatorMatXRadio11 configure -state disable; $PSPCalcOperatorMatXRadio12 configure -state disable;
$PSPCalcOperatorMatXRadio13 configure -state disable; $PSPCalcOperatorMatXRadio14 configure -state disable;
$PSPCalcOperatorMatXRadio21 configure -state disable; $PSPCalcOperatorMatXRadio22 configure -state disable; 
$PSPCalcOperatorMatXRadio23 configure -state disable; $PSPCalcOperatorMatXRadio24 configure -state disable;
$PSPCalcOperatorMatXRadio31 configure -state disable; $PSPCalcOperatorMatXRadio32 configure -state disable; 
$PSPCalcOperatorMatXRadio33 configure -state disable; $PSPCalcOperatorMatXRadio34 configure -state disable;
$PSPCalcOperatorMatXRadio41 configure -state disable; $PSPCalcOperatorMatXRadio42 configure -state disable; 
$PSPCalcOperatorMatXRadio43 configure -state disable; $PSPCalcOperatorMatXRadio44 configure -state disable;
}
#############################################################################
## Procedure:  PSPCalcCreateMatXOFF

proc ::PSPCalcCreateMatXOFF {} {
global PSPBackgroundColor PSPCalcCreateMatXType
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i

global PSPCalcCreateMatXTitleFrame PSPCalcCreateMatXButtonOK PSPCalcCreateMatXButtonLoad PSPCalcCreateMatXButtonSave
global PSPCalcCreateMatXRadioCmplx PSPCalcCreateMatXRadioFloat PSPCalcCreateMatXRadioHerm PSPCalcCreateMatXRadioSU
global PSPCalcLabelMat11 PSPCalcEntryMat11r PSPCalcLabelMat11j PSPCalcEntryMat11i 
global PSPCalcLabelMat21 PSPCalcEntryMat21r PSPCalcLabelMat21j PSPCalcEntryMat21i 
global PSPCalcLabelMat31 PSPCalcEntryMat31r PSPCalcLabelMat31j PSPCalcEntryMat31i 
global PSPCalcLabelMat41 PSPCalcEntryMat41r PSPCalcLabelMat41j PSPCalcEntryMat41i 
global PSPCalcLabelMat12 PSPCalcEntryMat12r PSPCalcLabelMat12j PSPCalcEntryMat12i 
global PSPCalcLabelMat22 PSPCalcEntryMat22r PSPCalcLabelMat22j PSPCalcEntryMat22i 
global PSPCalcLabelMat32 PSPCalcEntryMat32r PSPCalcLabelMat32j PSPCalcEntryMat32i 
global PSPCalcLabelMat42 PSPCalcEntryMat42r PSPCalcLabelMat42j PSPCalcEntryMat42i 
global PSPCalcLabelMat13 PSPCalcEntryMat13r PSPCalcLabelMat13j PSPCalcEntryMat13i 
global PSPCalcLabelMat23 PSPCalcEntryMat23r PSPCalcLabelMat23j PSPCalcEntryMat23i 
global PSPCalcLabelMat33 PSPCalcEntryMat33r PSPCalcLabelMat33j PSPCalcEntryMat33i 
global PSPCalcLabelMat43 PSPCalcEntryMat43r PSPCalcLabelMat43j PSPCalcEntryMat43i 
global PSPCalcLabelMat14 PSPCalcEntryMat14r PSPCalcLabelMat14j PSPCalcEntryMat14i 
global PSPCalcLabelMat24 PSPCalcEntryMat24r PSPCalcLabelMat24j PSPCalcEntryMat24i 
global PSPCalcLabelMat34 PSPCalcEntryMat34r PSPCalcLabelMat34j PSPCalcEntryMat34i 
global PSPCalcLabelMat44 PSPCalcEntryMat44r PSPCalcLabelMat44j PSPCalcEntryMat44i 

set PSPCalcCreateMatXTitleFrame .top600.fra67.cpd66
set PSPCalcCreateMatXButtonOK .top600.fra67.cpd66.f.fra71.cpd81
set PSPCalcCreateMatXButtonLoad .top600.fra67.cpd66.f.fra71.cpd82
set PSPCalcCreateMatXButtonSave .top600.fra67.cpd66.f.fra71.cpd83
set PSPCalcCreateMatXRadioCmplx .top600.fra67.cpd66.f.cpd72.cpd75.rad85 
set PSPCalcCreateMatXRadioFloat .top600.fra67.cpd66.f.cpd72.cpd75.cpd86
set PSPCalcCreateMatXRadioHerm .top600.fra67.cpd66.f.cpd72.cpd75.cpd87
set PSPCalcCreateMatXRadioSU .top600.fra67.cpd66.f.cpd72.cpd75.cpd88

set PSPCalcLabelMat11 .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.fra89.cpd106
set PSPCalcEntryMat11r .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.fra89.ent90
set PSPCalcLabelMat11j .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.fra89.cpd93
set PSPCalcEntryMat11i .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.fra89.cpd91
set PSPCalcLabelMat21 .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd94.cpd105
set PSPCalcEntryMat21r .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd94.ent90
set PSPCalcLabelMat21j .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd94.cpd93
set PSPCalcEntryMat21i .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd94.cpd91
set PSPCalcLabelMat31 .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd95.cpd104
set PSPCalcEntryMat31r .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd95.ent90
set PSPCalcLabelMat31j .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd95.cpd93
set PSPCalcEntryMat31i .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd95.cpd91
set PSPCalcLabelMat41 .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd96.cpd103
set PSPCalcEntryMat41r .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd96.ent90
set PSPCalcLabelMat41j .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd96.cpd93
set PSPCalcEntryMat41i .top600.fra67.cpd66.f.cpd72.cpd77.cpd80.cpd96.cpd91

set PSPCalcLabelMat12 .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.fra89.cpd106
set PSPCalcEntryMat12r .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.fra89.ent90
set PSPCalcLabelMat12j .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.fra89.cpd93
set PSPCalcEntryMat12i .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.fra89.cpd91
set PSPCalcLabelMat22 .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd94.cpd105
set PSPCalcEntryMat22r .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd94.ent90
set PSPCalcLabelMat22j .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd94.cpd93
set PSPCalcEntryMat22i .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd94.cpd91
set PSPCalcLabelMat32 .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd95.cpd104
set PSPCalcEntryMat32r .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd95.ent90
set PSPCalcLabelMat32j .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd95.cpd93
set PSPCalcEntryMat32i .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd95.cpd91
set PSPCalcLabelMat42 .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd96.cpd103
set PSPCalcEntryMat42r .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd96.ent90
set PSPCalcLabelMat42j .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd96.cpd93
set PSPCalcEntryMat42i .top600.fra67.cpd66.f.cpd72.cpd77.cpd119.cpd96.cpd91

set PSPCalcLabelMat13 .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.fra89.cpd106
set PSPCalcEntryMat13r .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.fra89.ent90
set PSPCalcLabelMat13j .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.fra89.cpd93
set PSPCalcEntryMat13i .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.fra89.cpd91
set PSPCalcLabelMat23 .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd94.cpd105
set PSPCalcEntryMat23r .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd94.ent90
set PSPCalcLabelMat23j .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd94.cpd93
set PSPCalcEntryMat23i .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd94.cpd91
set PSPCalcLabelMat33 .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd95.cpd104
set PSPCalcEntryMat33r .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd95.ent90
set PSPCalcLabelMat33j .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd95.cpd93
set PSPCalcEntryMat33i .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd95.cpd91
set PSPCalcLabelMat43 .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd96.cpd103
set PSPCalcEntryMat43r .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd96.ent90
set PSPCalcLabelMat43j .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd96.cpd93
set PSPCalcEntryMat43i .top600.fra67.cpd66.f.cpd72.cpd77.cpd120.cpd96.cpd91

set PSPCalcLabelMat14 .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.fra89.cpd106
set PSPCalcEntryMat14r .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.fra89.ent90
set PSPCalcLabelMat14j .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.fra89.cpd93
set PSPCalcEntryMat14i .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.fra89.cpd91
set PSPCalcLabelMat24 .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd94.cpd105
set PSPCalcEntryMat24r .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd94.ent90
set PSPCalcLabelMat24j .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd94.cpd93
set PSPCalcEntryMat24i .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd94.cpd91
set PSPCalcLabelMat34 .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd95.cpd104
set PSPCalcEntryMat34r .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd95.ent90
set PSPCalcLabelMat34j .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd95.cpd93
set PSPCalcEntryMat34i .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd95.cpd91
set PSPCalcLabelMat44 .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd96.cpd103
set PSPCalcEntryMat44r .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd96.ent90
set PSPCalcLabelMat44j .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd96.cpd93
set PSPCalcEntryMat44i .top600.fra67.cpd66.f.cpd72.cpd77.cpd121.cpd96.cpd91

set PSPCalcCreateMatXType ""
set PSPCalcCreateMat11r ""; set PSPCalcCreateMat11i ""
set PSPCalcCreateMat21r ""; set PSPCalcCreateMat21i ""
set PSPCalcCreateMat31r ""; set PSPCalcCreateMat31i ""
set PSPCalcCreateMat41r ""; set PSPCalcCreateMat41i ""
set PSPCalcCreateMat12r ""; set PSPCalcCreateMat12i ""
set PSPCalcCreateMat22r ""; set PSPCalcCreateMat22i ""
set PSPCalcCreateMat32r ""; set PSPCalcCreateMat32i ""
set PSPCalcCreateMat42r ""; set PSPCalcCreateMat42i ""
set PSPCalcCreateMat13r ""; set PSPCalcCreateMat13i ""
set PSPCalcCreateMat23r ""; set PSPCalcCreateMat23i ""
set PSPCalcCreateMat33r ""; set PSPCalcCreateMat33i ""
set PSPCalcCreateMat43r ""; set PSPCalcCreateMat43i ""
set PSPCalcCreateMat14r ""; set PSPCalcCreateMat14i ""
set PSPCalcCreateMat24r ""; set PSPCalcCreateMat24i ""
set PSPCalcCreateMat34r ""; set PSPCalcCreateMat34i ""
set PSPCalcCreateMat44r ""; set PSPCalcCreateMat44i ""

$PSPCalcCreateMatXTitleFrame configure -state disable
$PSPCalcCreateMatXButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcCreateMatXButtonLoad configure -state disable -background $PSPBackgroundColor
$PSPCalcCreateMatXButtonSave configure -state disable -background $PSPBackgroundColor
$PSPCalcCreateMatXRadioCmplx configure -state disable
$PSPCalcCreateMatXRadioFloat configure -state disable
$PSPCalcCreateMatXRadioHerm configure -state disable
$PSPCalcCreateMatXRadioSU configure -state disable

$PSPCalcLabelMat11 configure -state disable
$PSPCalcEntryMat11r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat11j configure -state disable
$PSPCalcEntryMat11i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat21 configure -state disable
$PSPCalcEntryMat21r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat21j configure -state disable
$PSPCalcEntryMat21i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat31 configure -state disable
$PSPCalcEntryMat31r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat31j configure -state disable
$PSPCalcEntryMat31i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat41 configure -state disable
$PSPCalcEntryMat41r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat41j configure -state disable
$PSPCalcEntryMat41i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat12 configure -state disable
$PSPCalcEntryMat12r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat12j configure -state disable
$PSPCalcEntryMat12i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat22 configure -state disable
$PSPCalcEntryMat22r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat22j configure -state disable
$PSPCalcEntryMat22i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat32 configure -state disable
$PSPCalcEntryMat32r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat32j configure -state disable
$PSPCalcEntryMat32i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat42 configure -state disable
$PSPCalcEntryMat42r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat42j configure -state disable
$PSPCalcEntryMat42i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat13 configure -state disable
$PSPCalcEntryMat13r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat13j configure -state disable
$PSPCalcEntryMat13i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat23 configure -state disable
$PSPCalcEntryMat23r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat23j configure -state disable
$PSPCalcEntryMat23i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat33 configure -state disable
$PSPCalcEntryMat33r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat33j configure -state disable
$PSPCalcEntryMat33i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat43 configure -state disable
$PSPCalcEntryMat43r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat43j configure -state disable
$PSPCalcEntryMat43i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat14 configure -state disable
$PSPCalcEntryMat14r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat14j configure -state disable
$PSPCalcEntryMat14i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat24 configure -state disable
$PSPCalcEntryMat24r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat24j configure -state disable
$PSPCalcEntryMat24i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat34 configure -state disable
$PSPCalcEntryMat34r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat34j configure -state disable
$PSPCalcEntryMat34i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat44 configure -state disable
$PSPCalcEntryMat44r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat44j configure -state disable
$PSPCalcEntryMat44i configure -disabledbackground $PSPBackgroundColor -state disable
}
#############################################################################
## Procedure:  PSPCalcRAZButton

proc ::PSPCalcRAZButton {} {
global PSPBackgroundColor
global PSPCalcOperand2Label PSPCalcOperand2Entry PSPCalcRunButton PSPCalcSaveButton
global PSPCalcOperatorName PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOperatorNameEntry PSPCalcOp2NameEntry

set PSPCalcOperatorName ""; set PSPCalcOp2Name ""; set PSPCalcOperand2 ""

set PSPCalcOperatorNameEntry .top600.fra67.fra79.cpd83.ent81

set PSPCalcOp2NameEntry .top600.fra67.fra79.cpd84.ent81
set PSPCalcOperand2Label .top600.fra67.fra79.cpd84.cpd126.lab125
set PSPCalcOperand2Entry .top600.fra67.fra79.cpd84.cpd126.cpd124

set PSPCalcRunButton .top600.fra67.cpd121.cpd66.cpd81
set PSPCalcSaveButton .top600.fra67.cpd121.cpd66.cpd83

$PSPCalcOperatorNameEntry configure -state disable -disabledbackground $PSPBackgroundColor

$PSPCalcOp2NameEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcOperand2Label configure -state disable
$PSPCalcOperand2Entry configure -state disable -disabledbackground $PSPBackgroundColor

#Run
$PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
#Save
$PSPCalcSaveButton configure -state disable -background $PSPBackgroundColor
}
#############################################################################
## Procedure:  PSPCalcRAZButtonMemory

proc ::PSPCalcRAZButtonMemory {} {
global PSPBackgroundColor
global PSPCalcStoButton PSPCalcRclButton PSPCalcMcButton

set PSPCalcStoButton .top600.fra67.fra66.fra73.but74
set PSPCalcRclButton .top600.fra67.fra66.fra73.cpd75
set PSPCalcMcButton .top600.fra67.fra66.fra73.cpd76

#Memory
$PSPCalcStoButton configure -state disable
$PSPCalcRclButton configure -state disable
$PSPCalcMcButton configure -state disable
}
#############################################################################
## Procedure:  PSPCalcInputFileOFF

proc ::PSPCalcInputFileOFF {} {
global PSPCalcInputFormat PSPCalcInputFileFormat PSPCalcInputFile
global NligInitFile NligEndFile NcolInitFile NcolEndFile 
global PSPBackgroundColor
global PSPCalcInputFileFrameTitle PSPCalcInputFileEntry PSPCalcInputFileButtonFile PSPCalcInputFileButtonOK
global PSPCalcInputFileFormatFrameTitle PSPCalcInputFileFormatEntry
global PSPCalcInputFileInitRowLabel PSPCalcInputFileInitRowEntry PSPCalcInputFileEndRowLabel PSPCalcInputFileEndRowEntry
global PSPCalcInputFileInitColLabel PSPCalcInputFileInitColEntry PSPCalcInputFileEndColLabel PSPCalcInputFileEndColEntry

set PSPCalcInputFileFrameTitle .top600.fra67.tit86
set PSPCalcInputFileEntry .top600.fra67.tit86.f.cpd92.cpd96.cpd93
set PSPCalcInputFileButtonFile .top600.fra67.tit86.f.cpd92.cpd96.cpd94
set PSPCalcInputFileButtonOK .top600.fra67.tit86.f.cpd89
set PSPCalcInputFileFormatFrameTitle .top600.fra67.tit86.f.cpd92.cpd95.tit97
set PSPCalcInputFileFormatEntry .top600.fra67.tit86.f.cpd92.cpd95.tit97.f.ent98
set PSPCalcInputFileInitRowLabel .top600.fra67.tit86.f.cpd92.cpd95.lab99
set PSPCalcInputFileInitRowEntry .top600.fra67.tit86.f.cpd92.cpd95.ent100
set PSPCalcInputFileEndRowLabel .top600.fra67.tit86.f.cpd92.cpd95.cpd102
set PSPCalcInputFileEndRowEntry .top600.fra67.tit86.f.cpd92.cpd95.cpd105
set PSPCalcInputFileInitColLabel .top600.fra67.tit86.f.cpd92.cpd95.cpd103
set PSPCalcInputFileInitColEntry .top600.fra67.tit86.f.cpd92.cpd95.cpd106
set PSPCalcInputFileEndColLabel .top600.fra67.tit86.f.cpd92.cpd95.cpd104
set PSPCalcInputFileEndColEntry .top600.fra67.tit86.f.cpd92.cpd95.cpd107

$PSPCalcInputFileFrameTitle configure -state disable
$PSPCalcInputFileEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputFileButtonFile configure -state disable
$PSPCalcInputFileButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcInputFileFormatFrameTitle configure -state disable
$PSPCalcInputFileFormatEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputFileInitRowLabel configure -state disable
$PSPCalcInputFileInitRowEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputFileEndRowLabel configure -state disable
$PSPCalcInputFileEndRowEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputFileInitColLabel configure -state disable
$PSPCalcInputFileInitColEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputFileEndColLabel configure -state disable
$PSPCalcInputFileEndColEntry configure -state disable -disabledbackground $PSPBackgroundColor

set NligInitFile ""
set NligEndFile ""
set NcolInitFile ""
set NcolEndFile ""
set PSPCalcInputFormat ""
set PSPCalcInputFileFormat ""
set PSPCalcInputFile ""
}
#############################################################################
## Procedure:  PSPCalcInputDirMatOFF

proc ::PSPCalcInputDirMatOFF {} {
global PSPCalcInputFormat PSPCalcInputDirFormat PSPCalcInputDirMat PSPCalcInputDirMatFormat
global NligInitMat NligEndMat NcolInitMat NcolEndMat 
global PSPBackgroundColor
global PSPCalcInputDirMatFrameTitle PSPCalcInputDirMatEntry PSPCalcInputDirMatButtonFile PSPCalcInputDirMatButtonOK
global PSPCalcInputDirMatFormatFrameTitle PSPCalcInputDirMatFormatEntry
global PSPCalcInputDirMatInitRowLabel PSPCalcInputDirMatInitRowEntry PSPCalcInputDirMatEndRowLabel PSPCalcInputDirMatEndRowEntry
global PSPCalcInputDirMatInitColLabel PSPCalcInputDirMatInitColEntry PSPCalcInputDirMatEndColLabel PSPCalcInputDirMatEndColEntry

set PSPCalcInputDirMatFrameTitle .top600.fra67.cpd108
set PSPCalcInputDirMatEntry .top600.fra67.cpd108.f.cpd92.cpd96.cpd93
set PSPCalcInputDirMatButtonFile .top600.fra67.cpd108.f.cpd92.cpd96.cpd94
set PSPCalcInputDirMatButtonOK .top600.fra67.cpd108.f.cpd89
set PSPCalcInputDirMatFormatFrameTitle .top600.fra67.cpd108.f.cpd92.cpd95.tit97
set PSPCalcInputDirMatFormatEntry .top600.fra67.cpd108.f.cpd92.cpd95.tit97.f.ent98
set PSPCalcInputDirMatInitRowLabel .top600.fra67.cpd108.f.cpd92.cpd95.lab99
set PSPCalcInputDirMatInitRowEntry .top600.fra67.cpd108.f.cpd92.cpd95.ent100
set PSPCalcInputDirMatEndRowLabel .top600.fra67.cpd108.f.cpd92.cpd95.cpd102
set PSPCalcInputDirMatEndRowEntry .top600.fra67.cpd108.f.cpd92.cpd95.cpd105
set PSPCalcInputDirMatInitColLabel .top600.fra67.cpd108.f.cpd92.cpd95.cpd103
set PSPCalcInputDirMatInitColEntry .top600.fra67.cpd108.f.cpd92.cpd95.cpd106
set PSPCalcInputDirMatEndColLabel .top600.fra67.cpd108.f.cpd92.cpd95.cpd104
set PSPCalcInputDirMatEndColEntry .top600.fra67.cpd108.f.cpd92.cpd95.cpd107

$PSPCalcInputDirMatFrameTitle configure -state disable
$PSPCalcInputDirMatEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputDirMatButtonFile configure -state disable
$PSPCalcInputDirMatButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcInputDirMatFormatFrameTitle configure -state disable
$PSPCalcInputDirMatFormatEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputDirMatInitRowLabel configure -state disable
$PSPCalcInputDirMatInitRowEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputDirMatEndRowLabel configure -state disable
$PSPCalcInputDirMatEndRowEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputDirMatInitColLabel configure -state disable
$PSPCalcInputDirMatInitColEntry configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputDirMatEndColLabel configure -state disable
$PSPCalcInputDirMatEndColEntry configure -state disable -disabledbackground $PSPBackgroundColor

set NligInitMat ""
set NligEndMat ""
set NcolInitMat ""
set NcolEndMat ""
set PSPCalcInputFormat ""
set PSPCalcInputDirFormat ""
set PSPCalcInputDirMat ""
set PSPCalcInputDirMatFormat ""
}
#############################################################################
## Procedure:  PSPCalcInputValueOFF

proc ::PSPCalcInputValueOFF {} {
global PSPCalcValueFormat PSPCalcValueInputReal PSPCalcValueInputImag
global PSPBackgroundColor
global PSPCalcInputValueTypeFrameTitle PSPCalcInputValueRadioCmplx PSPCalcInputValueRadioFloat PSPCalcInputValueRadioInt
global PSPCalcInputValueButtonOK
global PSPCalcInputValueFrameTitle PSPCalcInputValueEntryReal PSPCalcInputValueEntryImag PSPCalcInputValueLabelJ

set PSPCalcInputValueTypeFrameTitle .top600.fra67.fra109.tit110
set PSPCalcInputValueRadioCmplx .top600.fra67.fra109.tit110.f.rad112
set PSPCalcInputValueRadioFloat .top600.fra67.fra109.tit110.f.cpd113
set PSPCalcInputValueRadioInt .top600.fra67.fra109.tit110.f.cpd114
set PSPCalcInputValueButtonOK .top600.fra67.fra109.cpd116
set PSPCalcInputValueFrameTitle .top600.fra67.fra109.cpd111
set PSPCalcInputValueEntryReal .top600.fra67.fra109.cpd111.f.cpd115.ent90
set PSPCalcInputValueLabelJ .top600.fra67.fra109.cpd111.f.cpd115.cpd93
set PSPCalcInputValueEntryImag .top600.fra67.fra109.cpd111.f.cpd115.cpd91

$PSPCalcInputValueTypeFrameTitle configure -state disable
$PSPCalcInputValueRadioCmplx configure -state disable
$PSPCalcInputValueRadioFloat configure -state disable
$PSPCalcInputValueRadioInt configure -state disable
$PSPCalcInputValueButtonOK configure -state disable -background $PSPBackgroundColor
$PSPCalcInputValueFrameTitle configure -state disable
$PSPCalcInputValueEntryReal configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcInputValueLabelJ configure -state disable
$PSPCalcInputValueEntryImag configure -state disable -disabledbackground $PSPBackgroundColor

set PSPCalcValueFormat ""
set PSPCalcValueInputReal ""
set PSPCalcValueInputImag ""
}
#############################################################################
## Procedure:  PSPCalcOutputValueOFF

proc ::PSPCalcOutputValueOFF {} {
global PSPCalcValueOutputReal PSPCalcValueOutputImag
global PSPBackgroundColor
global PSPCalcOutputValueFrameTitle PSPCalcOutputValueEntryReal PSPCalcOutputValueEntryImag PSPCalcOutputValueLabelJ

set PSPCalcOutputValueFrameTitle .top600.fra67.cpd121.cpd111
set PSPCalcOutputValueEntryReal .top600.fra67.cpd121.cpd111.f.cpd115.ent90
set PSPCalcOutputValueLabelJ .top600.fra67.cpd121.cpd111.f.cpd115.cpd93
set PSPCalcOutputValueEntryImag .top600.fra67.cpd121.cpd111.f.cpd115.cpd91

$PSPCalcOutputValueFrameTitle configure -state disable
$PSPCalcOutputValueEntryReal configure -state disable -disabledbackground $PSPBackgroundColor
$PSPCalcOutputValueLabelJ configure -state disable
$PSPCalcOutputValueEntryImag configure -state disable -disabledbackground $PSPBackgroundColor

set PSPCalcValueOutputReal ""
set PSPCalcValueOutputImag ""
}
#############################################################################
## Procedure:  PSPCalcInputFileON

proc ::PSPCalcInputFileON {} {
global PSPCalcInputFormat PSPCalcInputFileFormat PSPCalcInputFile
global NligInitFile NligEndFile NcolInitFile NcolEndFile 
global PSPBackgroundColor
global PSPCalcInputFileFrameTitle PSPCalcInputFileEntry PSPCalcInputFileButtonFile PSPCalcInputFileButtonOK
global PSPCalcInputFileFormatFrameTitle PSPCalcInputFileFormatEntry
global PSPCalcInputFileInitRowLabel PSPCalcInputFileInitRowEntry PSPCalcInputFileEndRowLabel PSPCalcInputFileEndRowEntry
global PSPCalcInputFileInitColLabel PSPCalcInputFileInitColEntry PSPCalcInputFileEndColLabel PSPCalcInputFileEndColEntry

$PSPCalcInputFileFrameTitle configure -state normal
$PSPCalcInputFileEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputFileButtonFile configure -state normal
$PSPCalcInputFileButtonOK configure -state normal -background #FFFF00
$PSPCalcInputFileFormatFrameTitle configure -state normal
$PSPCalcInputFileFormatEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputFileInitRowLabel configure -state normal
$PSPCalcInputFileInitRowEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputFileEndRowLabel configure -state normal
$PSPCalcInputFileEndRowEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputFileInitColLabel configure -state normal
$PSPCalcInputFileInitColEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputFileEndColLabel configure -state normal
$PSPCalcInputFileEndColEntry configure -state disable -disabledbackground #FFFFFF

set NligInitFile "?"
set NligEndFile "?"
set NcolInitFile "?"
set NcolEndFile "?"
set PSPCalcInputFormat ""
set PSPCalcInputFileFormat ""
set PSPCalcInputFile "SELECT THE INPUT BINARY DATA FILE"
}
#############################################################################
## Procedure:  PSPCalcInputDirMatON

proc ::PSPCalcInputDirMatON {} {
global PSPCalcInputFormat PSPCalcInputDirFormat PSPCalcInputDirMat PSPCalcInputDirMatFormat
global NligInitMat NligEndMat NcolInitMat NcolEndMat 
global PSPBackgroundColor
global PSPCalcInputDirMatFrameTitle PSPCalcInputDirMatEntry PSPCalcInputDirMatButtonFile PSPCalcInputDirMatButtonOK
global PSPCalcInputDirMatFormatFrameTitle PSPCalcInputDirMatFormatEntry
global PSPCalcInputDirMatInitRowLabel PSPCalcInputDirMatInitRowEntry PSPCalcInputDirMatEndRowLabel PSPCalcInputDirMatEndRowEntry
global PSPCalcInputDirMatInitColLabel PSPCalcInputDirMatInitColEntry PSPCalcInputDirMatEndColLabel PSPCalcInputDirMatEndColEntry

$PSPCalcInputDirMatFrameTitle configure -state normal
$PSPCalcInputDirMatEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputDirMatButtonFile configure -state normal
$PSPCalcInputDirMatButtonOK configure -state normal -background #FFFF00
$PSPCalcInputDirMatFormatFrameTitle configure -state normal
$PSPCalcInputDirMatFormatEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputDirMatInitRowLabel configure -state normal
$PSPCalcInputDirMatInitRowEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputDirMatEndRowLabel configure -state normal
$PSPCalcInputDirMatEndRowEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputDirMatInitColLabel configure -state normal
$PSPCalcInputDirMatInitColEntry configure -state disable -disabledbackground #FFFFFF
$PSPCalcInputDirMatEndColLabel configure -state normal
$PSPCalcInputDirMatEndColEntry configure -state disable -disabledbackground #FFFFFF

set NligInitMat "?"
set NligEndMat "?"
set NcolInitMat "?"
set NcolEndMat "?"
set PSPCalcInputDirMat "SELECT THE INPUT POLARIMETRIC BINARY DATA DIRECTORY (MATRIX : S2, C2, C3, C4, T2, T3, T4)"
}
#############################################################################
## Procedure:  PSPCalcCreateMatXON

proc ::PSPCalcCreateMatXON {FlagCmplx FlagFloat FlagHerm FlagSU} {
global PSPBackgroundColor PSPCalcCreateMatXType
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i

global PSPCalcCreateMatXTitleFrame PSPCalcCreateMatXButtonOK PSPCalcCreateMatXButtonLoad PSPCalcCreateMatXButtonSave
global PSPCalcCreateMatXRadioCmplx PSPCalcCreateMatXRadioFloat PSPCalcCreateMatXRadioHerm PSPCalcCreateMatXRadioSU

PSPCalcCreateMatXRAZ
set PSPCalcCreateMatXType ""
set PSPCalcCreateMat11r ""; set PSPCalcCreateMat11i ""
set PSPCalcCreateMat21r ""; set PSPCalcCreateMat21i ""
set PSPCalcCreateMat31r ""; set PSPCalcCreateMat31i ""
set PSPCalcCreateMat41r ""; set PSPCalcCreateMat41i ""
set PSPCalcCreateMat12r ""; set PSPCalcCreateMat12i ""
set PSPCalcCreateMat22r ""; set PSPCalcCreateMat22i ""
set PSPCalcCreateMat32r ""; set PSPCalcCreateMat32i ""
set PSPCalcCreateMat42r ""; set PSPCalcCreateMat42i ""
set PSPCalcCreateMat13r ""; set PSPCalcCreateMat13i ""
set PSPCalcCreateMat23r ""; set PSPCalcCreateMat23i ""
set PSPCalcCreateMat33r ""; set PSPCalcCreateMat33i ""
set PSPCalcCreateMat43r ""; set PSPCalcCreateMat43i ""
set PSPCalcCreateMat14r ""; set PSPCalcCreateMat14i ""
set PSPCalcCreateMat24r ""; set PSPCalcCreateMat24i ""
set PSPCalcCreateMat34r ""; set PSPCalcCreateMat34i ""
set PSPCalcCreateMat44r ""; set PSPCalcCreateMat44i ""

$PSPCalcCreateMatXTitleFrame configure -state normal
$PSPCalcCreateMatXButtonOK configure -state normal -background #FFFF00
$PSPCalcCreateMatXButtonLoad configure -state normal -background #FFFF00
$PSPCalcCreateMatXButtonSave configure -state normal -background #FFFF00
if {$FlagCmplx == "cmplx"} { 
    $PSPCalcCreateMatXRadioCmplx configure -state normal
    } else {
    $PSPCalcCreateMatXRadioCmplx configure -state disable
    }
if {$FlagFloat == "float"} { 
    $PSPCalcCreateMatXRadioFloat configure -state normal
    } else {
    $PSPCalcCreateMatXRadioFloat configure -state disable
    }
if {$FlagHerm == "herm"} { 
    $PSPCalcCreateMatXRadioHerm configure -state normal
    } else {
    $PSPCalcCreateMatXRadioHerm configure -state disable
    }
if {$FlagSU == "SU"} { 
    $PSPCalcCreateMatXRadioSU configure -state normal
    } else {
    $PSPCalcCreateMatXRadioSU configure -state disable
    }
    
}
#############################################################################
## Procedure:  PSPCalcCreateMatXRAZ

proc ::PSPCalcCreateMatXRAZ {} {
global PSPBackgroundColor PSPCalcCreateMatXType
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i

global PSPCalcLabelMat11 PSPCalcEntryMat11r PSPCalcLabelMat11j PSPCalcEntryMat11i 
global PSPCalcLabelMat21 PSPCalcEntryMat21r PSPCalcLabelMat21j PSPCalcEntryMat21i 
global PSPCalcLabelMat31 PSPCalcEntryMat31r PSPCalcLabelMat31j PSPCalcEntryMat31i 
global PSPCalcLabelMat41 PSPCalcEntryMat41r PSPCalcLabelMat41j PSPCalcEntryMat41i 
global PSPCalcLabelMat12 PSPCalcEntryMat12r PSPCalcLabelMat12j PSPCalcEntryMat12i 
global PSPCalcLabelMat22 PSPCalcEntryMat22r PSPCalcLabelMat22j PSPCalcEntryMat22i 
global PSPCalcLabelMat32 PSPCalcEntryMat32r PSPCalcLabelMat32j PSPCalcEntryMat32i 
global PSPCalcLabelMat42 PSPCalcEntryMat42r PSPCalcLabelMat42j PSPCalcEntryMat42i 
global PSPCalcLabelMat13 PSPCalcEntryMat13r PSPCalcLabelMat13j PSPCalcEntryMat13i 
global PSPCalcLabelMat23 PSPCalcEntryMat23r PSPCalcLabelMat23j PSPCalcEntryMat23i 
global PSPCalcLabelMat33 PSPCalcEntryMat33r PSPCalcLabelMat33j PSPCalcEntryMat33i 
global PSPCalcLabelMat43 PSPCalcEntryMat43r PSPCalcLabelMat43j PSPCalcEntryMat43i 
global PSPCalcLabelMat14 PSPCalcEntryMat14r PSPCalcLabelMat14j PSPCalcEntryMat14i 
global PSPCalcLabelMat24 PSPCalcEntryMat24r PSPCalcLabelMat24j PSPCalcEntryMat24i 
global PSPCalcLabelMat34 PSPCalcEntryMat34r PSPCalcLabelMat34j PSPCalcEntryMat34i 
global PSPCalcLabelMat44 PSPCalcEntryMat44r PSPCalcLabelMat44j PSPCalcEntryMat44i 

set PSPCalcCreateMat11r ""; set PSPCalcCreateMat11i ""
set PSPCalcCreateMat21r ""; set PSPCalcCreateMat21i ""
set PSPCalcCreateMat31r ""; set PSPCalcCreateMat31i ""
set PSPCalcCreateMat41r ""; set PSPCalcCreateMat41i ""
set PSPCalcCreateMat12r ""; set PSPCalcCreateMat12i ""
set PSPCalcCreateMat22r ""; set PSPCalcCreateMat22i ""
set PSPCalcCreateMat32r ""; set PSPCalcCreateMat32i ""
set PSPCalcCreateMat42r ""; set PSPCalcCreateMat42i ""
set PSPCalcCreateMat13r ""; set PSPCalcCreateMat13i ""
set PSPCalcCreateMat23r ""; set PSPCalcCreateMat23i ""
set PSPCalcCreateMat33r ""; set PSPCalcCreateMat33i ""
set PSPCalcCreateMat43r ""; set PSPCalcCreateMat43i ""
set PSPCalcCreateMat14r ""; set PSPCalcCreateMat14i ""
set PSPCalcCreateMat24r ""; set PSPCalcCreateMat24i ""
set PSPCalcCreateMat34r ""; set PSPCalcCreateMat34i ""
set PSPCalcCreateMat44r ""; set PSPCalcCreateMat44i ""

$PSPCalcLabelMat11 configure -state disable
$PSPCalcEntryMat11r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat11j configure -state disable
$PSPCalcEntryMat11i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat21 configure -state disable
$PSPCalcEntryMat21r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat21j configure -state disable
$PSPCalcEntryMat21i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat31 configure -state disable
$PSPCalcEntryMat31r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat31j configure -state disable
$PSPCalcEntryMat31i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat41 configure -state disable
$PSPCalcEntryMat41r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat41j configure -state disable
$PSPCalcEntryMat41i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat12 configure -state disable
$PSPCalcEntryMat12r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat12j configure -state disable
$PSPCalcEntryMat12i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat22 configure -state disable
$PSPCalcEntryMat22r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat22j configure -state disable
$PSPCalcEntryMat22i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat32 configure -state disable
$PSPCalcEntryMat32r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat32j configure -state disable
$PSPCalcEntryMat32i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat42 configure -state disable
$PSPCalcEntryMat42r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat42j configure -state disable
$PSPCalcEntryMat42i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat13 configure -state disable
$PSPCalcEntryMat13r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat13j configure -state disable
$PSPCalcEntryMat13i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat23 configure -state disable
$PSPCalcEntryMat23r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat23j configure -state disable
$PSPCalcEntryMat23i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat33 configure -state disable
$PSPCalcEntryMat33r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat33j configure -state disable
$PSPCalcEntryMat33i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat43 configure -state disable
$PSPCalcEntryMat43r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat43j configure -state disable
$PSPCalcEntryMat43i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat14 configure -state disable
$PSPCalcEntryMat14r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat14j configure -state disable
$PSPCalcEntryMat14i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat24 configure -state disable
$PSPCalcEntryMat24r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat24j configure -state disable
$PSPCalcEntryMat24i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat34 configure -state disable
$PSPCalcEntryMat34r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat34j configure -state disable
$PSPCalcEntryMat34i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat44 configure -state disable
$PSPCalcEntryMat44r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat44j configure -state disable
$PSPCalcEntryMat44i configure -disabledbackground $PSPBackgroundColor -state disable
}
#############################################################################
## Procedure:  PSPCalcCreateMatXInitCmplx

proc ::PSPCalcCreateMatXInitCmplx {DimMatX} {
global PSPBackgroundColor PSPCalcCreateMatXType
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i

global PSPCalcLabelMat11 PSPCalcEntryMat11r PSPCalcLabelMat11j PSPCalcEntryMat11i 
global PSPCalcLabelMat21 PSPCalcEntryMat21r PSPCalcLabelMat21j PSPCalcEntryMat21i 
global PSPCalcLabelMat31 PSPCalcEntryMat31r PSPCalcLabelMat31j PSPCalcEntryMat31i 
global PSPCalcLabelMat41 PSPCalcEntryMat41r PSPCalcLabelMat41j PSPCalcEntryMat41i 
global PSPCalcLabelMat12 PSPCalcEntryMat12r PSPCalcLabelMat12j PSPCalcEntryMat12i 
global PSPCalcLabelMat22 PSPCalcEntryMat22r PSPCalcLabelMat22j PSPCalcEntryMat22i 
global PSPCalcLabelMat32 PSPCalcEntryMat32r PSPCalcLabelMat32j PSPCalcEntryMat32i 
global PSPCalcLabelMat42 PSPCalcEntryMat42r PSPCalcLabelMat42j PSPCalcEntryMat42i 
global PSPCalcLabelMat13 PSPCalcEntryMat13r PSPCalcLabelMat13j PSPCalcEntryMat13i 
global PSPCalcLabelMat23 PSPCalcEntryMat23r PSPCalcLabelMat23j PSPCalcEntryMat23i 
global PSPCalcLabelMat33 PSPCalcEntryMat33r PSPCalcLabelMat33j PSPCalcEntryMat33i 
global PSPCalcLabelMat43 PSPCalcEntryMat43r PSPCalcLabelMat43j PSPCalcEntryMat43i 
global PSPCalcLabelMat14 PSPCalcEntryMat14r PSPCalcLabelMat14j PSPCalcEntryMat14i 
global PSPCalcLabelMat24 PSPCalcEntryMat24r PSPCalcLabelMat24j PSPCalcEntryMat24i 
global PSPCalcLabelMat34 PSPCalcEntryMat34r PSPCalcLabelMat34j PSPCalcEntryMat34i 
global PSPCalcLabelMat44 PSPCalcEntryMat44r PSPCalcLabelMat44j PSPCalcEntryMat44i 


set PSPCalcCreateMat11r "?"; set PSPCalcCreateMat11i "?"
set PSPCalcCreateMat12r "?"; set PSPCalcCreateMat12i "?"
set PSPCalcCreateMat21r "?"; set PSPCalcCreateMat21i "?"
set PSPCalcCreateMat22r "?"; set PSPCalcCreateMat22i "?"

if {$DimMatX == 3 || $DimMatX == 4} {
set PSPCalcCreateMat13r "?"; set PSPCalcCreateMat13i "?"
set PSPCalcCreateMat23r "?"; set PSPCalcCreateMat23i "?"
set PSPCalcCreateMat31r "?"; set PSPCalcCreateMat31i "?"
set PSPCalcCreateMat32r "?"; set PSPCalcCreateMat32i "?"
set PSPCalcCreateMat33r "?"; set PSPCalcCreateMat33i "?"
}

if {$DimMatX == 4} {
set PSPCalcCreateMat41r "?"; set PSPCalcCreateMat41i "?"
set PSPCalcCreateMat42r "?"; set PSPCalcCreateMat42i "?"
set PSPCalcCreateMat43r "?"; set PSPCalcCreateMat43i "?"
set PSPCalcCreateMat14r "?"; set PSPCalcCreateMat14i "?"
set PSPCalcCreateMat24r "?"; set PSPCalcCreateMat24i "?"
set PSPCalcCreateMat34r "?"; set PSPCalcCreateMat34i "?"
set PSPCalcCreateMat44r "?"; set PSPCalcCreateMat44i "?"
}

$PSPCalcLabelMat11 configure -state normal
$PSPCalcEntryMat11r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat11j configure -state normal
$PSPCalcEntryMat11i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat21 configure -state normal
$PSPCalcEntryMat21r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat21j configure -state normal
$PSPCalcEntryMat21i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat12 configure -state normal
$PSPCalcEntryMat12r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat12j configure -state normal
$PSPCalcEntryMat12i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat22 configure -state normal
$PSPCalcEntryMat22r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat22j configure -state normal
$PSPCalcEntryMat22i configure -disabledbackground #FFFFFF -state normal

if {$DimMatX == 3 || $DimMatX == 4} {
$PSPCalcLabelMat13 configure -state normal
$PSPCalcEntryMat13r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat13j configure -state normal
$PSPCalcEntryMat13i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat23 configure -state normal
$PSPCalcEntryMat23r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat23j configure -state normal
$PSPCalcEntryMat23i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat31 configure -state normal
$PSPCalcEntryMat31r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat31j configure -state normal
$PSPCalcEntryMat31i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat32 configure -state normal
$PSPCalcEntryMat32r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat32j configure -state normal
$PSPCalcEntryMat32i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat33 configure -state normal
$PSPCalcEntryMat33r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat33j configure -state normal
$PSPCalcEntryMat33i configure -disabledbackground #FFFFFF -state normal
}

if {$DimMatX == 4} {
$PSPCalcLabelMat41 configure -state normal
$PSPCalcEntryMat41r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat41j configure -state normal
$PSPCalcEntryMat41i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat42 configure -state normal
$PSPCalcEntryMat42r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat42j configure -state normal
$PSPCalcEntryMat42i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat43 configure -state normal
$PSPCalcEntryMat43r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat43j configure -state normal
$PSPCalcEntryMat43i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat14 configure -state normal
$PSPCalcEntryMat14r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat14j configure -state normal
$PSPCalcEntryMat14i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat24 configure -state normal
$PSPCalcEntryMat24r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat24j configure -state normal
$PSPCalcEntryMat24i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat34 configure -state normal
$PSPCalcEntryMat34r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat34j configure -state normal
$PSPCalcEntryMat34i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat44 configure -state normal
$PSPCalcEntryMat44r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat44j configure -state normal
$PSPCalcEntryMat44i configure -disabledbackground #FFFFFF -state normal
}
}
#############################################################################
## Procedure:  PSPCalcCreateMatXInitFltInt

proc ::PSPCalcCreateMatXInitFltInt {DimMatX} {
global PSPBackgroundColor PSPCalcCreateMatXType
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i

global PSPCalcLabelMat11 PSPCalcEntryMat11r PSPCalcLabelMat11j PSPCalcEntryMat11i 
global PSPCalcLabelMat21 PSPCalcEntryMat21r PSPCalcLabelMat21j PSPCalcEntryMat21i 
global PSPCalcLabelMat31 PSPCalcEntryMat31r PSPCalcLabelMat31j PSPCalcEntryMat31i 
global PSPCalcLabelMat41 PSPCalcEntryMat41r PSPCalcLabelMat41j PSPCalcEntryMat41i 
global PSPCalcLabelMat12 PSPCalcEntryMat12r PSPCalcLabelMat12j PSPCalcEntryMat12i 
global PSPCalcLabelMat22 PSPCalcEntryMat22r PSPCalcLabelMat22j PSPCalcEntryMat22i 
global PSPCalcLabelMat32 PSPCalcEntryMat32r PSPCalcLabelMat32j PSPCalcEntryMat32i 
global PSPCalcLabelMat42 PSPCalcEntryMat42r PSPCalcLabelMat42j PSPCalcEntryMat42i 
global PSPCalcLabelMat13 PSPCalcEntryMat13r PSPCalcLabelMat13j PSPCalcEntryMat13i 
global PSPCalcLabelMat23 PSPCalcEntryMat23r PSPCalcLabelMat23j PSPCalcEntryMat23i 
global PSPCalcLabelMat33 PSPCalcEntryMat33r PSPCalcLabelMat33j PSPCalcEntryMat33i 
global PSPCalcLabelMat43 PSPCalcEntryMat43r PSPCalcLabelMat43j PSPCalcEntryMat43i 
global PSPCalcLabelMat14 PSPCalcEntryMat14r PSPCalcLabelMat14j PSPCalcEntryMat14i 
global PSPCalcLabelMat24 PSPCalcEntryMat24r PSPCalcLabelMat24j PSPCalcEntryMat24i 
global PSPCalcLabelMat34 PSPCalcEntryMat34r PSPCalcLabelMat34j PSPCalcEntryMat34i 
global PSPCalcLabelMat44 PSPCalcEntryMat44r PSPCalcLabelMat44j PSPCalcEntryMat44i 


set PSPCalcCreateMat11r "?"; set PSPCalcCreateMat11i ""
set PSPCalcCreateMat12r "?"; set PSPCalcCreateMat12i ""
set PSPCalcCreateMat21r "?"; set PSPCalcCreateMat21i ""
set PSPCalcCreateMat22r "?"; set PSPCalcCreateMat22i ""

if {$DimMatX == 3 || $DimMatX == 4} {
set PSPCalcCreateMat13r "?"; set PSPCalcCreateMat13i ""
set PSPCalcCreateMat23r "?"; set PSPCalcCreateMat23i ""
set PSPCalcCreateMat31r "?"; set PSPCalcCreateMat31i ""
set PSPCalcCreateMat32r "?"; set PSPCalcCreateMat32i ""
set PSPCalcCreateMat33r "?"; set PSPCalcCreateMat33i ""
}

if {$DimMatX == 4} {
set PSPCalcCreateMat41r "?"; set PSPCalcCreateMat41i ""
set PSPCalcCreateMat42r "?"; set PSPCalcCreateMat42i ""
set PSPCalcCreateMat43r "?"; set PSPCalcCreateMat43i ""
set PSPCalcCreateMat14r "?"; set PSPCalcCreateMat14i ""
set PSPCalcCreateMat24r "?"; set PSPCalcCreateMat24i ""
set PSPCalcCreateMat34r "?"; set PSPCalcCreateMat34i ""
set PSPCalcCreateMat44r "?"; set PSPCalcCreateMat44i ""
}

$PSPCalcLabelMat11 configure -state normal
$PSPCalcEntryMat11r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat11j configure -state disable
$PSPCalcEntryMat11i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat21 configure -state normal
$PSPCalcEntryMat21r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat21j configure -state disable
$PSPCalcEntryMat21i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat12 configure -state normal
$PSPCalcEntryMat12r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat12j configure -state disable
$PSPCalcEntryMat12i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat22 configure -state normal
$PSPCalcEntryMat22r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat22j configure -state disable
$PSPCalcEntryMat22i configure -disabledbackground $PSPBackgroundColor -state disable

if {$DimMatX == 3 || $DimMatX == 4} {
$PSPCalcLabelMat13 configure -state normal
$PSPCalcEntryMat13r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat13j configure -state disable
$PSPCalcEntryMat13i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat23 configure -state normal
$PSPCalcEntryMat23r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat23j configure -state disable
$PSPCalcEntryMat23i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat31 configure -state normal
$PSPCalcEntryMat31r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat31j configure -state disable
$PSPCalcEntryMat31i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat32 configure -state normal
$PSPCalcEntryMat32r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat32j configure -state disable
$PSPCalcEntryMat32i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat33 configure -state normal
$PSPCalcEntryMat33r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat33j configure -state disable
$PSPCalcEntryMat33i configure -disabledbackground $PSPBackgroundColor -state disable
}

if {$DimMatX == 4} {
$PSPCalcLabelMat41 configure -state normal
$PSPCalcEntryMat41r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat41j configure -state disable
$PSPCalcEntryMat41i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat42 configure -state normal
$PSPCalcEntryMat42r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat42j configure -state disable
$PSPCalcEntryMat42i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat43 configure -state normal
$PSPCalcEntryMat43r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat43j configure -state disable
$PSPCalcEntryMat43i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat14 configure -state normal
$PSPCalcEntryMat14r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat14j configure -state disable
$PSPCalcEntryMat14i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat24 configure -state normal
$PSPCalcEntryMat24r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat24j configure -state disable
$PSPCalcEntryMat24i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat34 configure -state normal
$PSPCalcEntryMat34r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat34j configure -state disable
$PSPCalcEntryMat34i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat44 configure -state normal
$PSPCalcEntryMat44r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat44j configure -state disable
$PSPCalcEntryMat44i configure -disabledbackground $PSPBackgroundColor -state disable
}
}
#############################################################################
## Procedure:  PSPCalcCreateMatXInitHerm

proc ::PSPCalcCreateMatXInitHerm {DimMatX} {
global PSPBackgroundColor PSPCalcCreateMatXType
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i

global PSPCalcLabelMat11 PSPCalcEntryMat11r PSPCalcLabelMat11j PSPCalcEntryMat11i 
global PSPCalcLabelMat21 PSPCalcEntryMat21r PSPCalcLabelMat21j PSPCalcEntryMat21i 
global PSPCalcLabelMat31 PSPCalcEntryMat31r PSPCalcLabelMat31j PSPCalcEntryMat31i 
global PSPCalcLabelMat41 PSPCalcEntryMat41r PSPCalcLabelMat41j PSPCalcEntryMat41i 
global PSPCalcLabelMat12 PSPCalcEntryMat12r PSPCalcLabelMat12j PSPCalcEntryMat12i 
global PSPCalcLabelMat22 PSPCalcEntryMat22r PSPCalcLabelMat22j PSPCalcEntryMat22i 
global PSPCalcLabelMat32 PSPCalcEntryMat32r PSPCalcLabelMat32j PSPCalcEntryMat32i 
global PSPCalcLabelMat42 PSPCalcEntryMat42r PSPCalcLabelMat42j PSPCalcEntryMat42i 
global PSPCalcLabelMat13 PSPCalcEntryMat13r PSPCalcLabelMat13j PSPCalcEntryMat13i 
global PSPCalcLabelMat23 PSPCalcEntryMat23r PSPCalcLabelMat23j PSPCalcEntryMat23i 
global PSPCalcLabelMat33 PSPCalcEntryMat33r PSPCalcLabelMat33j PSPCalcEntryMat33i 
global PSPCalcLabelMat43 PSPCalcEntryMat43r PSPCalcLabelMat43j PSPCalcEntryMat43i 
global PSPCalcLabelMat14 PSPCalcEntryMat14r PSPCalcLabelMat14j PSPCalcEntryMat14i 
global PSPCalcLabelMat24 PSPCalcEntryMat24r PSPCalcLabelMat24j PSPCalcEntryMat24i 
global PSPCalcLabelMat34 PSPCalcEntryMat34r PSPCalcLabelMat34j PSPCalcEntryMat34i 
global PSPCalcLabelMat44 PSPCalcEntryMat44r PSPCalcLabelMat44j PSPCalcEntryMat44i 


set PSPCalcCreateMat11r "?"; set PSPCalcCreateMat11i ""
set PSPCalcCreateMat12r "?"; set PSPCalcCreateMat12i "?"
set PSPCalcCreateMat21r ""; set PSPCalcCreateMat21i ""
set PSPCalcCreateMat22r "?"; set PSPCalcCreateMat22i ""

if {$DimMatX == 3 || $DimMatX == 4} {
set PSPCalcCreateMat13r "?"; set PSPCalcCreateMat13i "?"
set PSPCalcCreateMat23r "?"; set PSPCalcCreateMat23i "?"
set PSPCalcCreateMat31r ""; set PSPCalcCreateMat31i ""
set PSPCalcCreateMat32r ""; set PSPCalcCreateMat32i ""
set PSPCalcCreateMat33r "?"; set PSPCalcCreateMat33i ""
}

if {$DimMatX == 4} {
set PSPCalcCreateMat41r ""; set PSPCalcCreateMat41i ""
set PSPCalcCreateMat42r ""; set PSPCalcCreateMat42i ""
set PSPCalcCreateMat43r ""; set PSPCalcCreateMat43i ""
set PSPCalcCreateMat14r "?"; set PSPCalcCreateMat14i "?"
set PSPCalcCreateMat24r "?"; set PSPCalcCreateMat24i "?"
set PSPCalcCreateMat34r "?"; set PSPCalcCreateMat34i "?"
set PSPCalcCreateMat44r "?"; set PSPCalcCreateMat44i ""
}

$PSPCalcLabelMat11 configure -state normal
$PSPCalcEntryMat11r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat11j configure -state disable
$PSPCalcEntryMat11i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat21 configure -state disable
$PSPCalcEntryMat21r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat21j configure -state disable
$PSPCalcEntryMat21i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat12 configure -state normal
$PSPCalcEntryMat12r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat12j configure -state normal
$PSPCalcEntryMat12i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat22 configure -state normal
$PSPCalcEntryMat22r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat22j configure -state disable
$PSPCalcEntryMat22i configure -disabledbackground $PSPBackgroundColor -state disable

if {$DimMatX == 3 || $DimMatX == 4} {
$PSPCalcLabelMat13 configure -state normal
$PSPCalcEntryMat13r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat13j configure -state normal
$PSPCalcEntryMat13i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat23 configure -state normal
$PSPCalcEntryMat23r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat23j configure -state normal
$PSPCalcEntryMat23i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat31 configure -state disable
$PSPCalcEntryMat31r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat31j configure -state disable
$PSPCalcEntryMat31i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat32 configure -state disable
$PSPCalcEntryMat32r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat32j configure -state disable
$PSPCalcEntryMat32i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat33 configure -state normal
$PSPCalcEntryMat33r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat33j configure -state disable
$PSPCalcEntryMat33i configure -disabledbackground $PSPBackgroundColor -state disable
}

if {$DimMatX == 4} {
$PSPCalcLabelMat41 configure -state disable
$PSPCalcEntryMat41r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat41j configure -state disable
$PSPCalcEntryMat41i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat42 configure -state disable
$PSPCalcEntryMat42r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat42j configure -state disable
$PSPCalcEntryMat42i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat43 configure -state disable
$PSPCalcEntryMat43r configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat43j configure -state disable
$PSPCalcEntryMat43i configure -disabledbackground $PSPBackgroundColor -state disable
$PSPCalcLabelMat14 configure -state normal
$PSPCalcEntryMat14r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat14j configure -state normal
$PSPCalcEntryMat14i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat24 configure -state normal
$PSPCalcEntryMat24r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat24j configure -state normal
$PSPCalcEntryMat24i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat34 configure -state normal
$PSPCalcEntryMat34r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat34j configure -state normal
$PSPCalcEntryMat34i configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat44 configure -state normal
$PSPCalcEntryMat44r configure -disabledbackground #FFFFFF -state normal
$PSPCalcLabelMat44j configure -state disable
$PSPCalcEntryMat44i configure -disabledbackground $PSPBackgroundColor -state disable
}
}
#############################################################################
## Procedure:  PSPCalcTestSU

proc ::PSPCalcTestSU {MatDim} {
global TMPPSPCalcMatSU TMPPSPCalcMatX0 PSPCalcTestSUFlag
global ErrorMessage VarError

DeleteFile $TMPPSPCalcMatSU 

set f [open $TMPPSPCalcMatX0 "w"]
puts $f "PolSARpro Calculator v1.0"
puts $f $PSPCalcCreateMatXType
puts $f $MatDim
if {$MatDim == 4} {
puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
puts $f $PSPCalcCreateMat14r; puts $f $PSPCalcCreateMat14i
puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
puts $f $PSPCalcCreateMat24r; puts $f $PSPCalcCreateMat24i
puts $f $PSPCalcCreateMat31r; puts $f $PSPCalcCreateMat31i
puts $f $PSPCalcCreateMat32r; puts $f $PSPCalcCreateMat32i
puts $f $PSPCalcCreateMat33r; puts $f $PSPCalcCreateMat33i
puts $f $PSPCalcCreateMat34r; puts $f $PSPCalcCreateMat34i
puts $f $PSPCalcCreateMat41r; puts $f $PSPCalcCreateMat41i
puts $f $PSPCalcCreateMat42r; puts $f $PSPCalcCreateMat42i
puts $f $PSPCalcCreateMat43r; puts $f $PSPCalcCreateMat43i
puts $f $PSPCalcCreateMat44r; puts $f $PSPCalcCreateMat44i
}
if {$MatDim == 3} {
puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
puts $f $PSPCalcCreateMat31r; puts $f $PSPCalcCreateMat31i
puts $f $PSPCalcCreateMat32r; puts $f $PSPCalcCreateMat32i
puts $f $PSPCalcCreateMat33r; puts $f $PSPCalcCreateMat33i
}
if {$MatDim == 2} {
puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
}
close $f

set f [ open "| Soft/calculator/test_SU_matX.exe -if \x22$TMPPSPCalcMatX0\x22 -of \x22$TMPPSPCalcMatSU\x22" r]

WaitUntilCreated $TMPPSPCalcMatSU
set f [open $TMPPSPCalcMatSU "r"]
gets $f PSPCalcTestSUFlag
close $f

if {$PSPCalcTestSUFlag == "KO"} {
    set ErrorMessage "THIS MATRIX IS NOT A SU( $MatDim ) MATRIX"
    WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    PSPCalcCreateMat4_RAZ
    PSPCalcCreateMat4_InitCmplx
    }
}
#############################################################################
## Procedure:  PSPCalcOperatorFileON

proc ::PSPCalcOperatorFileON {} {
global PSPCalcOperatorF PSPCalcOperator PSPCalcOperatorName PSPCalcOperatorNameEntry
global PSPCalcOperatorFileTitleFrame PSPCalcOperatorFileButtonOK
global PSPCalcOperatorFileRadio11 PSPCalcOperatorFileRadio12 PSPCalcOperatorFileRadio13 PSPCalcOperatorFileRadio14
global PSPCalcOperatorFileRadio15 PSPCalcOperatorFileRadio16 PSPCalcOperatorFileRadio17 PSPCalcOperatorFileRadio18
global PSPCalcOperatorFileRadio21 PSPCalcOperatorFileRadio22 PSPCalcOperatorFileRadio23 PSPCalcOperatorFileRadio24
global PSPCalcOperatorFileRadio25 PSPCalcOperatorFileRadio26 PSPCalcOperatorFileRadio27 PSPCalcOperatorFileRadio28
global PSPCalcOperatorFileRadio31 PSPCalcOperatorFileRadio32 PSPCalcOperatorFileRadio33 PSPCalcOperatorFileRadio34
global PSPCalcOperatorFileRadio35 PSPCalcOperatorFileRadio36 PSPCalcOperatorFileRadio37 PSPCalcOperatorFileRadio38
global PSPCalcOperatorFileRadio41 PSPCalcOperatorFileRadio42 PSPCalcOperatorFileRadio43 PSPCalcOperatorFileRadio44
global PSPCalcOperatorFileRadio45 PSPCalcOperatorFileRadio46 PSPCalcOperatorFileRadio47 PSPCalcOperatorFileRadio48

set PSPCalcOperatorF ""
set PSPCalcOperator ""

set PSPCalcOperatorName "Select Operator"
$PSPCalcOperatorNameEntry configure -disabledbackground #FFFFFF

$PSPCalcOperatorFileTitleFrame configure -state normal -background #FFFFFF
$PSPCalcOperatorFileButtonOK configure -state normal -background #FFFF00
$PSPCalcOperatorFileRadio11 configure -state normal; $PSPCalcOperatorFileRadio12 configure -state normal;
$PSPCalcOperatorFileRadio13 configure -state normal; $PSPCalcOperatorFileRadio14 configure -state normal;
$PSPCalcOperatorFileRadio15 configure -state normal; $PSPCalcOperatorFileRadio16 configure -state normal; 
$PSPCalcOperatorFileRadio17 configure -state normal; $PSPCalcOperatorFileRadio18 configure -state normal;
$PSPCalcOperatorFileRadio21 configure -state normal; $PSPCalcOperatorFileRadio22 configure -state normal; 
$PSPCalcOperatorFileRadio23 configure -state normal; $PSPCalcOperatorFileRadio24 configure -state normal;
$PSPCalcOperatorFileRadio25 configure -state normal; $PSPCalcOperatorFileRadio26 configure -state normal; 
$PSPCalcOperatorFileRadio27 configure -state normal; $PSPCalcOperatorFileRadio28 configure -state normal;
$PSPCalcOperatorFileRadio31 configure -state normal; $PSPCalcOperatorFileRadio32 configure -state normal; 
$PSPCalcOperatorFileRadio33 configure -state normal; $PSPCalcOperatorFileRadio34 configure -state normal;
$PSPCalcOperatorFileRadio35 configure -state normal; $PSPCalcOperatorFileRadio36 configure -state normal; 
$PSPCalcOperatorFileRadio37 configure -state normal; $PSPCalcOperatorFileRadio38 configure -state normal;
$PSPCalcOperatorFileRadio41 configure -state normal; $PSPCalcOperatorFileRadio42 configure -state normal; 
$PSPCalcOperatorFileRadio43 configure -state normal; $PSPCalcOperatorFileRadio44 configure -state normal;
$PSPCalcOperatorFileRadio45 configure -state normal; $PSPCalcOperatorFileRadio46 configure -state normal; 
$PSPCalcOperatorFileRadio47 configure -state normal; $PSPCalcOperatorFileRadio48 configure -state normal;
}
#############################################################################
## Procedure:  PSPCalcOperatorMatMON

proc ::PSPCalcOperatorMatMON {} {
global PSPCalcOperatorM PSPCalcOperator PSPCalcOperatorName PSPCalcOp1MatDim PSPCalcOperatorNameEntry
global PSPCalcOperatorMatMTitleFrame PSPCalcOperatorMatMButtonOK
global PSPCalcOperatorMatMRadio11 PSPCalcOperatorMatMRadio12 PSPCalcOperatorMatMRadio13 PSPCalcOperatorMatMRadio14
global PSPCalcOperatorMatMRadio15 
global PSPCalcOperatorMatMRadio21 PSPCalcOperatorMatMRadio22 PSPCalcOperatorMatMRadio23 PSPCalcOperatorMatMRadio24
global PSPCalcOperatorMatMRadio25 
global PSPCalcOperatorMatMRadio31 PSPCalcOperatorMatMRadio32 PSPCalcOperatorMatMRadio33 PSPCalcOperatorMatMRadio34
global PSPCalcOperatorMatMRadio35 
global PSPCalcOperatorMatMRadio41 PSPCalcOperatorMatMRadio42 PSPCalcOperatorMatMRadio43 PSPCalcOperatorMatMRadio44
global PSPCalcOperatorMatMRadio45 

set PSPCalcOperatorM ""
set PSPCalcOperator ""

set PSPCalcOperatorName "Select Operator"
$PSPCalcOperatorNameEntry configure -disabledbackground #FFFFFF

$PSPCalcOperatorMatMTitleFrame configure -state normal -background #FFFFFF
$PSPCalcOperatorMatMButtonOK configure -state normal -background #FFFF00
$PSPCalcOperatorMatMRadio11 configure -state normal; $PSPCalcOperatorMatMRadio12 configure -state normal;
$PSPCalcOperatorMatMRadio13 configure -state normal; $PSPCalcOperatorMatMRadio14 configure -state normal;
$PSPCalcOperatorMatMRadio15 configure -state normal;
$PSPCalcOperatorMatMRadio21 configure -state normal; $PSPCalcOperatorMatMRadio22 configure -state normal; 
$PSPCalcOperatorMatMRadio23 configure -state normal; $PSPCalcOperatorMatMRadio24 configure -state normal;
$PSPCalcOperatorMatMRadio25 configure -state normal;
$PSPCalcOperatorMatMRadio31 configure -state normal; $PSPCalcOperatorMatMRadio32 configure -state normal; 
$PSPCalcOperatorMatMRadio33 configure -state normal; $PSPCalcOperatorMatMRadio34 configure -state normal;
if {$PSPCalcOp1MatDim == "3" || $PSPCalcOp1MatDim == "4"} {
    $PSPCalcOperatorMatMRadio35 configure -state normal;
    } else {
    $PSPCalcOperatorMatMRadio35 configure -state disable;
    }
$PSPCalcOperatorMatMRadio41 configure -state normal; $PSPCalcOperatorMatMRadio42 configure -state normal; 
$PSPCalcOperatorMatMRadio43 configure -state normal; $PSPCalcOperatorMatMRadio44 configure -state normal;
if {$PSPCalcOp1MatDim == "4"} {
    $PSPCalcOperatorMatMRadio45 configure -state normal;
    } else {
    $PSPCalcOperatorMatMRadio45 configure -state disable;
    }
}
#############################################################################
## Procedure:  PSPCalcOperatorMatSON

proc ::PSPCalcOperatorMatSON {} {
global PSPCalcOperatorS PSPCalcOperator PSPCalcOperatorName PSPCalcOperatorNameEntry
global PSPCalcOperatorMatSTitleFrame PSPCalcOperatorMatSButtonOK
global PSPCalcOperatorMatSRadio11 PSPCalcOperatorMatSRadio12 PSPCalcOperatorMatSRadio13 PSPCalcOperatorMatSRadio14
global PSPCalcOperatorMatSRadio15 PSPCalcOperatorMatSRadio16 
global PSPCalcOperatorMatSRadio21 PSPCalcOperatorMatSRadio22 PSPCalcOperatorMatSRadio23 PSPCalcOperatorMatSRadio24
global PSPCalcOperatorMatSRadio25 PSPCalcOperatorMatSRadio26 
global PSPCalcOperatorMatSRadio31 PSPCalcOperatorMatSRadio32 PSPCalcOperatorMatSRadio33 PSPCalcOperatorMatSRadio34
global PSPCalcOperatorMatSRadio35 PSPCalcOperatorMatSRadio36 
global PSPCalcOperatorMatSRadio41 PSPCalcOperatorMatSRadio42 PSPCalcOperatorMatSRadio43 PSPCalcOperatorMatSRadio44
global PSPCalcOperatorMatSRadio45 PSPCalcOperatorMatSRadio46 

set PSPCalcOperatorS ""
set PSPCalcOperator ""

set PSPCalcOperatorName "Select Operator"
$PSPCalcOperatorNameEntry configure -disabledbackground #FFFFFF

$PSPCalcOperatorMatSTitleFrame configure -state normal -background #FFFFFF
$PSPCalcOperatorMatSButtonOK configure -state normal -background #FFFF00
$PSPCalcOperatorMatSRadio11 configure -state normal; $PSPCalcOperatorMatSRadio12 configure -state normal;
$PSPCalcOperatorMatSRadio13 configure -state normal; $PSPCalcOperatorMatSRadio14 configure -state normal;
$PSPCalcOperatorMatSRadio15 configure -state normal; $PSPCalcOperatorMatSRadio16 configure -state normal;
$PSPCalcOperatorMatSRadio21 configure -state normal; $PSPCalcOperatorMatSRadio22 configure -state normal; 
$PSPCalcOperatorMatSRadio23 configure -state normal; $PSPCalcOperatorMatSRadio24 configure -state normal;
$PSPCalcOperatorMatSRadio25 configure -state normal; $PSPCalcOperatorMatSRadio26 configure -state normal;
$PSPCalcOperatorMatSRadio31 configure -state normal; $PSPCalcOperatorMatSRadio32 configure -state normal; 
$PSPCalcOperatorMatSRadio33 configure -state normal; $PSPCalcOperatorMatSRadio34 configure -state normal;
$PSPCalcOperatorMatSRadio35 configure -state normal; $PSPCalcOperatorMatSRadio36 configure -state normal;
$PSPCalcOperatorMatSRadio41 configure -state normal; $PSPCalcOperatorMatSRadio42 configure -state normal; 
$PSPCalcOperatorMatSRadio43 configure -state normal; $PSPCalcOperatorMatSRadio44 configure -state normal;
$PSPCalcOperatorMatSRadio45 configure -state normal; $PSPCalcOperatorMatSRadio46 configure -state normal;
}
#############################################################################
## Procedure:  PSPCalcOperatorMatXON

proc ::PSPCalcOperatorMatXON {} {
global PSPCalcOperatorX PSPCalcOperator PSPCalcOperatorName PSPCalcOp1MatDim PSPCalcOperatorNameEntry
global PSPCalcOperatorMatXTitleFrame PSPCalcOperatorMatXButtonOK
global PSPCalcOperatorMatXRadio11 PSPCalcOperatorMatXRadio12 PSPCalcOperatorMatXRadio13 PSPCalcOperatorMatXRadio14
global PSPCalcOperatorMatXRadio21 PSPCalcOperatorMatXRadio22 PSPCalcOperatorMatXRadio23 PSPCalcOperatorMatXRadio24
global PSPCalcOperatorMatXRadio31 PSPCalcOperatorMatXRadio32 PSPCalcOperatorMatXRadio33 PSPCalcOperatorMatXRadio34
global PSPCalcOperatorMatXRadio41 PSPCalcOperatorMatXRadio42 PSPCalcOperatorMatXRadio43 PSPCalcOperatorMatXRadio44

set PSPCalcOperatorS ""
set PSPCalcOperator ""

set PSPCalcOperatorName "Select Operator"
$PSPCalcOperatorNameEntry configure -disabledbackground #FFFFFF

$PSPCalcOperatorMatXTitleFrame configure -state normal -background #FFFFFF
$PSPCalcOperatorMatXButtonOK configure -state normal -background #FFFF00
$PSPCalcOperatorMatXRadio11 configure -state normal; $PSPCalcOperatorMatXRadio12 configure -state normal;
$PSPCalcOperatorMatXRadio13 configure -state normal; $PSPCalcOperatorMatXRadio14 configure -state normal;
$PSPCalcOperatorMatXRadio21 configure -state normal; $PSPCalcOperatorMatXRadio22 configure -state normal; 
$PSPCalcOperatorMatXRadio23 configure -state normal; $PSPCalcOperatorMatXRadio24 configure -state normal;
$PSPCalcOperatorMatXRadio31 configure -state normal; $PSPCalcOperatorMatXRadio32 configure -state normal; 
$PSPCalcOperatorMatXRadio33 configure -state normal; 
if {$PSPCalcOp1MatDim == "3" || $PSPCalcOp1MatDim == "4"} {
    $PSPCalcOperatorMatXRadio34 configure -state normal;
    } else {
    $PSPCalcOperatorMatXRadio34 configure -state disable;
    }
$PSPCalcOperatorMatXRadio41 configure -state normal; $PSPCalcOperatorMatXRadio42 configure -state normal; 
$PSPCalcOperatorMatXRadio43 configure -state normal; 
if {$PSPCalcOp1MatDim == "4"} {
    $PSPCalcOperatorMatXRadio44 configure -state normal;
    } else {
    $PSPCalcOperatorMatXRadio44 configure -state disable;
    }
}
#############################################################################
## Procedure:  PSPCalcInputValueON

proc ::PSPCalcInputValueON {} {
global PSPCalcOp2Format PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global PSPBackgroundColor
global PSPCalcInputValueTypeFrameTitle PSPCalcInputValueRadioCmplx PSPCalcInputValueRadioFloat PSPCalcInputValueRadioInt
global PSPCalcInputValueButtonOK
global PSPCalcInputValueFrameTitle PSPCalcInputValueEntryReal PSPCalcInputValueEntryImag PSPCalcInputValueLabelJ

$PSPCalcInputValueTypeFrameTitle configure -state normal
$PSPCalcInputValueRadioCmplx configure -state normal
$PSPCalcInputValueRadioFloat configure -state normal
$PSPCalcInputValueRadioInt configure -state normal
$PSPCalcInputValueButtonOK configure -state normal -background #FFFF00
$PSPCalcInputValueFrameTitle configure -state normal
$PSPCalcInputValueEntryReal configure -state normal -disabledbackground #FFFFFF
$PSPCalcInputValueLabelJ configure -state disable
$PSPCalcInputValueEntryImag configure -state disable -disabledbackground $PSPBackgroundColor
}
#############################################################################
## Procedure:  PSPCalcInitOperand2

proc ::PSPCalcInitOperand2 {} {
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global OpenDirFile PSPCalcInputFile PSPCalcInputFileFormat PSPCalcInputDirMat PSPCalcInputDirMatFormat PSPCalcCreateMatXType
global PSPCalcValueFormat PSPCalcValueInputReal PSPCalcValueInputImag PSPCalcNwinL PSPCalcNwinC PSPCalcNlook PSPCalcFilter
global NligInitFile NligEndFile NcolInitFile NcolEndFile
global NligInitMat NligEndMat NcolInitMat NcolEndMat
global PSPBackgroundColor PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1MatDim PSPCalcOperand
global PSPCalcInputValueRadioCmplx PSPCalcInputValueRadioFloat PSPCalcInputValueRadioInt
global PSPBackgroundColor
global Load_PolSARproCalcFilter PSPTopLevel

if {$OpenDirFile == 0} {

set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"; set PSPCalcOp2Format ""
set PSPCalcOp2PolarCase ""; set PSPCalcOp2PolarType ""; set PSPCalcOp2MatDim ""
set PSPCalcOp2FileInput ""; set PSPCalcOp2MatDirInput ""

set PSPCalcOperand "OP2"

set PSPCalcInputFile ""; set PSPCalcInputFileFormat ""; 
set NligInitFile ""; set NligEndFile ""; set NcolInitFile ""; set NcolEndFile ""
set PSPCalcInputDirMat ""; set PSPCalcInputDirMatFormat ""
set NligInitMat ""; set NligEndMat ""; set NcolInitMat ""; set NcolEndMat ""
set PSPCalcNwinL ""; set PSPCalcNwinC ""; set PSPCalcNlook ""; set PSPCalcFilter ""

if {$PSPCalcOp2Type == "value"} {
    set PSPCalcValueInputReal "?"; set PSPCalcValueInputImag ""
    set PSPCalcValueFormat "float"
    PSPCalcInputValueON
    if {$PSPCalcOp1Type == "matM"} {
        $PSPCalcInputValueRadioCmplx configure -state disable
        }
    }

if {$PSPCalcOp2Type == "valuefloat"} {
    set PSPCalcValueInputReal "?"; set PSPCalcValueInputImag ""
    set PSPCalcValueFormat "float"
    PSPCalcInputValueON
    $PSPCalcInputValueRadioCmplx configure -state disable
    $PSPCalcInputValueRadioInt configure -state disable
    }

if {$PSPCalcOp2Type == "valueint"} {
    set PSPCalcValueInputReal "?"; set PSPCalcValueInputImag ""
    set PSPCalcValueFormat "int"
    PSPCalcInputValueON
    $PSPCalcInputValueRadioCmplx configure -state disable
    $PSPCalcInputValueRadioFloat configure -state disable
    }

if {$PSPCalcOp2Type == "file"} {
    PSPCalcInputFileON
    }

if {$PSPCalcOp2Type == "filter"} {
    set PSPCalcFilter "boxcar"
    set PSPCalcNwinL "5"; set PSPCalcNwinC "5"
    set PSPCalcNlook ""
    .top603.tit73.f.cpd76 configure -state normal
    .top603.tit73.f.cpd78 configure -state normal
    .top603.tit73.f.cpd78 configure -disabledbackground #FFFFFF
    .top603.fra79.cpd80 configure -state disable
    .top603.fra79.cpd82 configure -state disable
    .top603.fra79.cpd82 configure -disabledbackground $PSPBackgroundColor
    Window show .top603
    }

if {$PSPCalcOp2Type == "matM" || $PSPCalcOp2Type == "matS"} {
    PSPCalcInputDirMatON
    }


if {$PSPCalcOp2Type == "matX" || $PSPCalcOp2Type == "matXSU" || $PSPCalcOp2Type == "matXherm"} {
    set PSPCalcCreateMatXType ""
    set PSPCalcOp2MatDim $PSPCalcOp1MatDim
    PSPCalcCreateMatXRAZ
    if {$PSPCalcOp2Type == "matX"} {
        set PSPCalcCreateMatXType "cmplx"
        PSPCalcCreateMatXON "cmplx" "float" "herm" "SU"
        PSPCalcCreateMatXInitCmplx $PSPCalcOp1MatDim
        }
    if {$PSPCalcOp2Type == "matXherm"} {
        set PSPCalcCreateMatXType "herm"
        PSPCalcCreateMatXON "no" "no" "herm" "no"
        PSPCalcCreateMatXInitHerm $PSPCalcOp1MatDim
        }
    if {$PSPCalcOp2Type == "matXSU"} {
        set PSPCalcCreateMatXType "SU"
        PSPCalcCreateMatXON "no" "no" "no" "SU"
        PSPCalcCreateMatXInitCmplx $PSPCalcOp1MatDim
        }
    }
}
}
#############################################################################
## Procedure:  PSPCalcRunFile

proc ::PSPCalcRunFile {DirNum} {
global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global PSPCalcFilter PSPCalcNwinL PSPCalcNwinC PSPCalcNlook
global TMPPSPCalcDirResult1 TMPPSPCalcDirResult2 TMPPSPCalcDirResult3
global PSPCalcOutputFormat PSPCalcOutputType PSPCalcOperatorF
global PSPCalcOutputResultDir PSPCalcOutputResultFile
global PSPCalcOutputResultFileCmplx PSPCalcOutputResultFileFloat PSPCalcOutputResultFileInt
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global VarError ErrorMessage PSPMemory TMPMemoryAllocError
global TMPPSPCalcInputDirMatConfig TMPPSPCalcInputDirMatMapInfo TMPPSPCalcInputDirMatMaskFile

if {$DirNum == 1} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult1}
if {$DirNum == 2} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult2}
if {$DirNum == 3} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult3}
set PSPCalcOutputResultFileCmplx "$PSPCalcOutputResultDir/PSPCalc_OutputFile_cmplx.bin"
set PSPCalcOutputResultFileFloat "$PSPCalcOutputResultDir/PSPCalc_OutputFile_float.bin"
set PSPCalcOutputResultFileInt "$PSPCalcOutputResultDir/PSPCalc_OutputFile_int.bin"

set PSPCalcOutputType "file"

if {$PSPCalcOp2Type == "" } {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set TmpDirInput [file dirname $PSPCalcOp1FileInput]
    set MaskFile "$TmpDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    if {$PSPCalcOp1Format == "float"} {set PSPCalcOutputFormat "float"}
    if {$PSPCalcOp1Format == "cmplx"} {
      if {$PSPCalcOperatorF == "real" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "imag" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "abs" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "arg" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "log" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "ln" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "10log" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "20log" } { set PSPCalcOutputFormat "float" }
      if {$PSPCalcOperatorF == "cos" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "sin" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "tan" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "conj" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "sqrt" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "x2" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "x3" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "10x" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "exp" } { set PSPCalcOutputFormat "cmplx" }
      if {$PSPCalcOperatorF == "conj" } { set PSPCalcOutputFormat "cmplx" }
      }
    if {$PSPCalcOutputFormat == "cmplx"} {set PSPCalcOutputResultFile $PSPCalcOutputResultFileCmplx}
    if {$PSPCalcOutputFormat == "float"} {set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat}

    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/file_operand.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$PSPCalcOp1FileInput\x22 -it $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFile\x22 -ot $PSPCalcOutputFormat -op $PSPCalcOperatorF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/file_operand.exe -if \x22$PSPCalcOp1FileInput\x22 -it $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFile\x22 -ot $PSPCalcOutputFormat -op $PSPCalcOperatorF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "filter" } {
    if {$PSPCalcOperatorF == "filter"} {set PSPCalcOperatorName ".boxcar(?x?)"; set PSPCalcOp2Type "valueint"}
    set PSPCalcOp2Type "valueint"
    set PSPCalcOp2Name "$PSPCalcNwinL x $PSPCalcNwinC"    
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set TmpDirInput [file dirname $PSPCalcOp1FileInput]
    set MaskFile "$TmpDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputFormat "float"; set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    if {$PSPCalcFilter == "boxcar"} {
        set PSPCalcOperatorName ".boxcar(?x?)"
        set PSPCalcFilterExe "Soft/calculator/file_boxcar.exe"
        set PSPCalcFilterArg "-if \x22$PSPCalcOp1FileInput\x22 -of \x22$PSPCalcOutputResultFile\x22 -nwr $PSPCalcNwinL -nwc $PSPCalcNwinC -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd"
        }
    if {$PSPCalcFilter == "lee"} {
        set PSPCalcOperatorName ".lee refined(?x?)"
        set PSPCalcFilterExe "Soft/calculator/file_lee_refined.exe"
        set PSPCalcFilterArg "-if \x22$PSPCalcOp1FileInput\x22 -of \x22$PSPCalcOutputResultFile\x22 -nw $PSPCalcNwinL -nlk $PSPCalcNlook -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd"
        }
    if {$PSPCalcFilter == "median"} {
        set PSPCalcOperatorName ".median(?x?)"
        set PSPCalcFilterExe "Soft/calculator/file_median.exe"
        set PSPCalcFilterArg "-if \x22$PSPCalcOp1FileInput\x22 -of \x22$PSPCalcOutputResultFile\x22 -nwr $PSPCalcNwinL -nwc $PSPCalcNwinC -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd"
        }
    if {$PSPCalcFilter == "nagao"} {
        set PSPCalcOperatorName ".nagao(?x?)"
        set PSPCalcFilterExe "Soft/calculator/file_nagao.exe"
        set PSPCalcFilterArg "-if \x22$PSPCalcOp1FileInput\x22 -of \x22$PSPCalcOutputResultFile\x22 -nwr $PSPCalcNwinL -nwc $PSPCalcNwinC -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd"
        }
    TextEditorRunTrace "Process The Function $PSPCalcFilterExe" "k"
    TextEditorRunTrace "Arguments: $PSPCalcFilterArg" "k"
    set f [ open "| $PSPCalcFilterExe $PSPCalcFilterArg" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "value" || $PSPCalcOp2Type == "valuefloat"} {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set TmpDirInput [file dirname $PSPCalcOp1FileInput]
    set MaskFile "$TmpDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    if {$PSPCalcOp1Format == "float"} {
        if {$PSPCalcOp2Format == "float"} {set PSPCalcOutputFormat "float"}
        if {$PSPCalcOp2Format == "cmplx"} {set PSPCalcOutputFormat "cmplx"}
        }
    if {$PSPCalcOp1Format == "cmplx"} {
        if {$PSPCalcOp2Format == "float"} {set PSPCalcOutputFormat "cmplx"}
        if {$PSPCalcOp2Format == "cmplx"} {set PSPCalcOutputFormat "cmplx"}
        }
    if {$PSPCalcOutputFormat == "cmplx"} {set PSPCalcOutputResultFile $PSPCalcOutputResultFileCmplx}
    if {$PSPCalcOutputFormat == "float"} {set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat}

    if {$PSPCalcOp2Format == "cmplx"} {set PSPCalcOp2ValueInputIm $PSPCalcOp2ValueInputImag }
    if {$PSPCalcOp2Format == "float"} {set PSPCalcOp2ValueInputIm "0" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/file_operand_value.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$PSPCalcOp1FileInput\x22 -it $PSPCalcOp1Format -ivr $PSPCalcOp2ValueInputReal -ivi $PSPCalcOp2ValueInputIm -it2 $PSPCalcOp2Format -of \x22$PSPCalcOutputResultFile\x22 -ot $PSPCalcOutputFormat -op $PSPCalcOperatorF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/file_operand_value.exe -if \x22$PSPCalcOp1FileInput\x22 -it $PSPCalcOp1Format -ivr $PSPCalcOp2ValueInputReal -ivi $PSPCalcOp2ValueInputIm -it2 $PSPCalcOp2Format -of \x22$PSPCalcOutputResultFile\x22 -ot $PSPCalcOutputFormat -op $PSPCalcOperatorF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "file" } {
    set config "true"
    if {$NligEndOp1 != $NligEndOp2} {set config "false"}
    if {$NcolEndOp1 != $NcolEndOp2} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set TmpDirInput [file dirname $PSPCalcOp1FileInput]
        set MaskFile "$TmpDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        if {$PSPCalcOp1Format == "float"} {
            if {$PSPCalcOp2Format == "float"} {set PSPCalcOutputFormat "float"}
            if {$PSPCalcOp2Format == "cmplx"} {set PSPCalcOutputFormat "cmplx"}
            }
        if {$PSPCalcOp1Format == "cmplx"} {
            if {$PSPCalcOp2Format == "float"} {set PSPCalcOutputFormat "cmplx"}
            if {$PSPCalcOp2Format == "cmplx"} {set PSPCalcOutputFormat "cmplx"}
            }
        if {$PSPCalcOutputFormat == "cmplx"} {set PSPCalcOutputResultFile $PSPCalcOutputResultFileCmplx}
        if {$PSPCalcOutputFormat == "float"} {set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat}

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/file_operand_file.exe" "k"
        TextEditorRunTrace "Arguments: -if1 \x22$PSPCalcOp1FileInput\x22 -it1 $PSPCalcOp1Format -if2 \x22$PSPCalcOp2FileInput\x22 -it2 $PSPCalcOp2Format -of \x22$PSPCalcOutputResultFile\x22 -ot $PSPCalcOutputFormat -op $PSPCalcOperatorF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/file_operand_file.exe -if1 \x22$PSPCalcOp1FileInput\x22 -it1 $PSPCalcOp1Format -if2 \x22$PSPCalcOp2FileInput\x22 -it2 $PSPCalcOp2Format -of \x22$PSPCalcOutputResultFile\x22 -ot $PSPCalcOutputFormat -op $PSPCalcOperatorF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE TWO FILES HAVE NOT THE SAME SIZE"
        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }
    
if {$PSPCalcOutputType == "file" } {
    if {$TMPPSPCalcInputDirMatConfig != "$PSPCalcOutputResultDir/config.txt" } {
        CopyFile $TMPPSPCalcInputDirMatConfig "$PSPCalcOutputResultDir/config.txt"
        }
    if {$TMPPSPCalcInputDirMatMapInfo != ""} {
        if {$TMPPSPCalcInputDirMatMapInfo != "$PSPCalcOutputResultDir/config_mapinfo.txt"} {
            CopyFile $TMPPSPCalcInputDirMatMapInfo "$PSPCalcOutputResultDir/config_mapinfo.txt"
            }
        }
    if {$TMPPSPCalcInputDirMatMaskFile != ""} {
        if {$TMPPSPCalcInputDirMatMaskFile != "$PSPCalcOutputResultDir/mask_valid_pixels.bin" } {
            CopyFile $TMPPSPCalcInputDirMatMaskFile "$PSPCalcOutputResultDir/mask_valid_pixels.bin"
            }
        }
    if {$PSPCalcOutputFormat == "int"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 2}
    if {$PSPCalcOutputFormat == "float"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 4}
    if {$PSPCalcOutputFormat == "cmplx"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 6}
    }
}
#############################################################################
## Procedure:  PSPCalcRunMatM

proc ::PSPCalcRunMatM {DirNum} {
global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global TMPPSPCalcDirResult1 TMPPSPCalcDirResult2 TMPPSPCalcDirResult3
global PSPCalcOutputFormat PSPCalcOutputType PSPCalcOperatorM
global PSPCalcOutputResultDir PSPCalcOutputResultFile
global PSPCalcOutputResultFileCmplx PSPCalcOutputResultFileFloat PSPCalcOutputResultFileInt
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global VarError ErrorMessage PSPMemory TMPMemoryAllocError
global TMPPSPCalcInputDirMatConfig TMPPSPCalcInputDirMatMapInfo TMPPSPCalcInputDirMatMaskFile

if {$DirNum == 1} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult1}
if {$DirNum == 2} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult2}
if {$DirNum == 3} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult3}
set PSPCalcOutputResultFileCmplx "$PSPCalcOutputResultDir/PSPCalc_OutputFile_cmplx.bin"
set PSPCalcOutputResultFileFloat "$PSPCalcOutputResultDir/PSPCalc_OutputFile_float.bin"
set PSPCalcOutputResultFileInt "$PSPCalcOutputResultDir/PSPCalc_OutputFile_int.bin"
set PSPCalcOutputResultFile ""

if {$PSPCalcOp2Type == "matM" } {
    set config "true"
    if {$NligEndOp1 != $NligEndOp2} {set config "false"}
    if {$NcolEndOp1 != $NcolEndOp2} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matM"

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_matM.exe" "k"
        TextEditorRunTrace "Arguments: -id1 \x22$PSPCalcOp1MatDirInput\x22 -id2 \x22$PSPCalcOp2MatDirInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matM_operand_matM.exe -id1 \x22$PSPCalcOp1MatDirInput\x22 -id2 \x22$PSPCalcOp2MatDirInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE TWO MATRICES HAVE NOT THE SAME SIZE"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "matXherm" } {
    set config "true"
    if {$PSPCalcOp1MatDim != $PSPCalcOp2MatDim} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        if {$PSPCalcOperatorM == "addmatX" } {
            set PSPCalcOutputFormat $PSPCalcOp1Format
            set PSPCalcOutputType "matM"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_matX_add.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/matM_operand_matX_add.exe -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            } else {
            set PSPCalcOutputFormat "float"
            set PSPCalcOutputType "file"
            set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat 
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_matX_dist.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFileFloat\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/matM_operand_matX_dist.exe -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFileFloat\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE TWO MATRICES HAVE NOT THE SAME DIMENSION"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "matXSU" } {
    set config "true"
    if {$PSPCalcOp1MatDim != $PSPCalcOp2MatDim} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matM"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_matXSU.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matM_operand_matXSU.exe -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE TWO MATRICES HAVE NOT THE SAME DIMENSION"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "file" } {
    set config "true"
    if {$NligEndOp1 != $NligEndOp2} {set config "false"}
    if {$NcolEndOp1 != $NcolEndOp2} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matM"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matM_operand_file.exe -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE MATRIX AND THE FILE HAVE NOT THE SAME SIZE"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "valuefloat"} {
    if {$PSPCalcOp2Format == "float"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matM"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_value.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -iv \x22$PSPCalcOp2ValueInputReal\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matM_operand_value.exe -id \x22$PSPCalcOp1MatDirInput\x22 -iv \x22$PSPCalcOp2ValueInputReal\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE VALUE MUST BE A FLOAT VALUE FORMAT"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "out_matM" } {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputFormat $PSPCalcOp1Format
    set PSPCalcOutputType "matM"
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_out_matM.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/matM_operand_out_matM.exe -id \x22$PSPCalcOp1MatDirInput\x22 -iodf $PSPCalcOp1Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "out_file" } {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputFormat "float"
    set PSPCalcOutputType "file"
    set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat 
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_out_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -it $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFileFloat\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/matM_operand_out_file.exe -id \x22$PSPCalcOp1MatDirInput\x22 -it $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFileFloat\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "out_eig" } {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputFormat "float"
    set PSPCalcOutputType "file"
    set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat 
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matM_operand_out_eig.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -it $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFileFloat\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/matM_operand_out_eig.exe -id \x22$PSPCalcOp1MatDirInput\x22 -it $PSPCalcOp1Format -of \x22$PSPCalcOutputResultFileFloat\x22 -op $PSPCalcOperatorM -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }
    
if {$PSPCalcOutputType == "file" } {
    if {$TMPPSPCalcInputDirMatConfig != "$PSPCalcOutputResultDir/config.txt" } {
        CopyFile $TMPPSPCalcInputDirMatConfig "$PSPCalcOutputResultDir/config.txt"
        }
    if {$TMPPSPCalcInputDirMatMapInfo != ""} {
        if {$TMPPSPCalcInputDirMatMapInfo != "$PSPCalcOutputResultDir/config_mapinfo.txt"} {
            CopyFile $TMPPSPCalcInputDirMatMapInfo "$PSPCalcOutputResultDir/config_mapinfo.txt"
            }
        }
    if {$TMPPSPCalcInputDirMatMaskFile != ""} {
        if {$TMPPSPCalcInputDirMatMaskFile != "$PSPCalcOutputResultDir/mask_valid_pixels.bin" } {
            CopyFile $TMPPSPCalcInputDirMatMaskFile "$PSPCalcOutputResultDir/mask_valid_pixels.bin"
            }
        }
    if {$PSPCalcOutputFormat == "int"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 2}
    if {$PSPCalcOutputFormat == "float"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 4}
    if {$PSPCalcOutputFormat == "cmplx"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 6}
    }
if {$PSPCalcOutputType == "matM" } {
    if {$TMPPSPCalcInputDirMatConfig != "$PSPCalcOutputResultDir/config.txt" } {
        CopyFile $TMPPSPCalcInputDirMatConfig "$PSPCalcOutputResultDir/config.txt"
        }
    if {$TMPPSPCalcInputDirMatMapInfo != ""} {
        if {$TMPPSPCalcInputDirMatMapInfo != "$PSPCalcOutputResultDir/config_mapinfo.txt"} {
            CopyFile $TMPPSPCalcInputDirMatMapInfo "$PSPCalcOutputResultDir/config_mapinfo.txt"
            }
        }
    if {$TMPPSPCalcInputDirMatMaskFile != ""} {
        if {$TMPPSPCalcInputDirMatMaskFile != "$PSPCalcOutputResultDir/mask_valid_pixels.bin" } {
            CopyFile $TMPPSPCalcInputDirMatMaskFile "$PSPCalcOutputResultDir/mask_valid_pixels.bin"
            }
        }
    PSPCalcEnviWriteConfigCheck $PSPCalcOutputResultDir $FinalNlig $FinalNcol $PSPCalcOp1Format
    }
}
#############################################################################
## Procedure:  PSPCalcRunMatS

proc ::PSPCalcRunMatS {DirNum} {
global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global TMPPSPCalcDirResult1 TMPPSPCalcDirResult2 TMPPSPCalcDirResult3
global PSPCalcOutputFormat PSPCalcOutputType PSPCalcOperatorS
global PSPCalcOutputResultDir PSPCalcOutputResultFile
global PSPCalcOutputResultFileCmplx PSPCalcOutputResultFileFloat PSPCalcOutputResultFileInt
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global VarError ErrorMessage PSPMemory TMPMemoryAllocError
global TMPPSPCalcInputDirMatConfig TMPPSPCalcInputDirMatMapInfo TMPPSPCalcInputDirMatMaskFile

if {$DirNum == 1} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult1}
if {$DirNum == 2} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult2}
if {$DirNum == 3} {set PSPCalcOutputResultDir $TMPPSPCalcDirResult3}
set PSPCalcOutputResultFileCmplx "$PSPCalcOutputResultDir/PSPCalc_OutputFile_cmplx.bin"
set PSPCalcOutputResultFileFloat "$PSPCalcOutputResultDir/PSPCalc_OutputFile_float.bin"
set PSPCalcOutputResultFileInt "$PSPCalcOutputResultDir/PSPCalc_OutputFile_int.bin"
set PSPCalcOutputResultFile ""

if {$PSPCalcOp2Type == "matS" } {
    set config "true"
    if {$NligEndOp1 != $NligEndOp2} {set config "false"}
    if {$NcolEndOp1 != $NcolEndOp2} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matS"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_matS.exe" "k"
        TextEditorRunTrace "Arguments: -id1 \x22$PSPCalcOp1MatDirInput\x22 -id2 \x22$PSPCalcOp2MatDirInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matS_operand_matS.exe -id1 \x22$PSPCalcOp1MatDirInput\x22 -id2 \x22$PSPCalcOp2MatDirInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE TWO MATRICES HAVE NOT THE SAME SIZE"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "matX" } {
    set config "true"
    if {$PSPCalcOp1MatDim != $PSPCalcOp2MatDim} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matS"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_matX.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matS_operand_matX.exe -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE TWO MATRICES HAVE NOT THE SAME DIMENSION"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "matXSU" } {
    set config "true"
    if {$PSPCalcOp1MatDim != $PSPCalcOp2MatDim} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matS"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_matXSU.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matS_operand_matXSU.exe -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE TWO MATRICES HAVE NOT THE SAME DIMENSION"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "file" } {
    set config "true"
    if {$NligEndOp1 != $NligEndOp2} {set config "false"}
    if {$NcolEndOp1 != $NcolEndOp2} {set config "false"}
    if {$config == "true"} {
        set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
        set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
        set MaskCmd ""
        set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set PSPCalcOutputFormat $PSPCalcOp1Format
        set PSPCalcOutputType "matS"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -it $PSPCalcOp2Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/calculator/matS_operand_file.exe -id \x22$PSPCalcOp1MatDirInput\x22 -if \x22$PSPCalcOp2FileInput\x22 -it $PSPCalcOp2Format -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        set ErrorMessage "THE MATRIX AND THE FILE HAVE NOT THE SAME SIZE"
        WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcRAZButton
        }
    }

if {$PSPCalcOp2Type == "value"} {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputFormat $PSPCalcOp1Format
    set PSPCalcOutputType "matS"
    if {$PSPCalcOp2Format == "cmplx"} {set PSPCalcOp2ValueInputIm $PSPCalcOp2ValueInputImag }
    if {$PSPCalcOp2Format == "float"} {set PSPCalcOp2ValueInputIm "0" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_value.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -ivr \x22$PSPCalcOp2ValueInputReal\x22 -ivi \x22$PSPCalcOp2ValueInputIm\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/matS_operand_value.exe -id \x22$PSPCalcOp1MatDirInput\x22 -ivr \x22$PSPCalcOp2ValueInputReal\x22 -ivi \x22$PSPCalcOp2ValueInputIm\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "out_matS" } {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputFormat $PSPCalcOp1Format;
    set PSPCalcOutputType "matS"
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_out_matS.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/matS_operand_out_matS.exe -id \x22$PSPCalcOp1MatDirInput\x22 -od \x22$PSPCalcOutputResultDir\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "out_file" } {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputFormat "cmplx"
    set PSPCalcOutputType "file"
    set PSPCalcOutputResultFile $PSPCalcOutputResultFileCmplx
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_out_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -of \x22$PSPCalcOutputResultFile\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/matS_operand_out_file.exe -id \x22$PSPCalcOp1MatDirInput\x22 -of \x22$PSPCalcOutputResultFileCmplx\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "out_eig" } {
    set FinalNlig [expr $NligEndOp1 - $NligInitOp1 + 1]
    set FinalNcol [expr $NcolEndOp1 - $NcolInitOp1 + 1]
    set MaskCmd ""
    set MaskFile "$PSPCalcOp1MatDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set PSPCalcOutputType "file"
    if {$PSPCalcOperatorS == "eig1S" || $PSPCalcOperatorS == "eig2S"} {
        set PSPCalcOutputFormat "cmplx"
        set PSPCalcOutputResultFile $PSPCalcOutputResultFileCmplx
        }
    if {$PSPCalcOperatorS == "eig1G" || $PSPCalcOperatorS == "eig2G"} {
        set PSPCalcOutputFormat "float"
        set PSPCalcOutputResultFile $PSPCalcOutputResultFileFloat
        }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matS_operand_out_eig.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$PSPCalcOp1MatDirInput\x22 -of \x22$PSPCalcOutputResultFile\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/calculator/matS_operand_out_eig.exe -id \x22$PSPCalcOp1MatDirInput\x22 -of \x22$PSPCalcOutputResultFile\x22 -op $PSPCalcOperatorS -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }
    
if {$PSPCalcOutputType == "file" } {
    if {$TMPPSPCalcInputDirMatConfig != "$PSPCalcOutputResultDir/config.txt" } {
        CopyFile $TMPPSPCalcInputDirMatConfig "$PSPCalcOutputResultDir/config.txt"
        }
    if {$TMPPSPCalcInputDirMatMapInfo != ""} {
        if {$TMPPSPCalcInputDirMatMapInfo != "$PSPCalcOutputResultDir/config_mapinfo.txt"} {
            CopyFile $TMPPSPCalcInputDirMatMapInfo "$PSPCalcOutputResultDir/config_mapinfo.txt"
            }
        }
    if {$TMPPSPCalcInputDirMatMaskFile != ""} {
        if {$TMPPSPCalcInputDirMatMaskFile != "$PSPCalcOutputResultDir/mask_valid_pixels.bin" } {
            CopyFile $TMPPSPCalcInputDirMatMaskFile "$PSPCalcOutputResultDir/mask_valid_pixels.bin"
            }
        }
    if {$PSPCalcOutputFormat == "int"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 2}
    if {$PSPCalcOutputFormat == "float"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 4}
    if {$PSPCalcOutputFormat == "cmplx"} {PSPCalcEnviWriteConfig $PSPCalcOutputResultFile $FinalNlig $FinalNcol 6}
    }
if {$PSPCalcOutputType == "matS" } {
    if {$TMPPSPCalcInputDirMatConfig != "$PSPCalcOutputResultDir/config.txt" } {
        CopyFile $TMPPSPCalcInputDirMatConfig "$PSPCalcOutputResultDir/config.txt"
        }
    if {$TMPPSPCalcInputDirMatMapInfo != ""} {
        if {$TMPPSPCalcInputDirMatMapInfo != "$PSPCalcOutputResultDir/config_mapinfo.txt"} {
            CopyFile $TMPPSPCalcInputDirMatMapInfo "$PSPCalcOutputResultDir/config_mapinfo.txt"
            }
        }
    if {$TMPPSPCalcInputDirMatMaskFile != ""} {
        if {$TMPPSPCalcInputDirMatMaskFile != "$PSPCalcOutputResultDir/mask_valid_pixels.bin" } {
            CopyFile $TMPPSPCalcInputDirMatMaskFile "$PSPCalcOutputResultDir/mask_valid_pixels.bin"
            }
        }
   PSPCalcEnviWriteConfigCheck $PSPCalcOutputResultDir $FinalNlig $FinalNcol "S2"
   }
}
#############################################################################
## Procedure:  PSPCalcCleanResultDir

proc ::PSPCalcCleanResultDir {DirNum} {
global TMPPSPCalcDirResult1 TMPPSPCalcDirResult2 TMPPSPCalcDirResult3

if {$DirNum == 1} {set TMPResultDir $TMPPSPCalcDirResult1}
if {$DirNum == 2} {set TMPResultDir $TMPPSPCalcDirResult2}
if {$DirNum == 3} {set TMPResultDir $TMPPSPCalcDirResult3}

DeleteMatrixT $TMPResultDir
DeleteMatrixC $TMPResultDir
DeleteMatrixS $TMPResultDir
DeleteMatrixI $TMPResultDir

DeleteFile "$TMPResultDir/PSPCalc_OutputFile_cmplx.bin"
DeleteFile "$TMPResultDir/PSPCalc_OutputFile_float.bin"
DeleteFile "$TMPResultDir/PSPCalc_OutputFile_int.bin"
}
#############################################################################
## Procedure:  PSPCalcDefineOutput

proc ::PSPCalcDefineOutput {} {
global PSPCalcOutput PSPCalcOutputTab PSPCalcMemory

if {$PSPCalcOutput == ""} {
    set PSPCalcOutput $PSPCalcOutputTab(1)
    } else {
    if {$PSPCalcOutput == $PSPCalcOutputTab(1) } {
        set PSPCalcOutput $PSPCalcOutputTab(2)
        } else {
        set PSPCalcOutput $PSPCalcOutputTab(1)
        }
    }
}
#############################################################################
## Procedure:  PSPCalcLoadConfig

proc ::PSPCalcLoadConfig {PSPCalcConfigFile} {
global PSPCalcNligFullSize PSPCalcNcolFullSize PSPCalcPolarCase PSPCalcPolarType
global PSPCalcMapInfoActive PSPCalcMapInfoMapInfo PSPCalcMapInfoProjInfo PSPCalcMapInfoUnit
global ErrorMessage FatalErrorMessage VarFatalError

set PSPCalcMapInfoActive ""
set PSPCalcMapInfoMapInfo ""
set PSPCalcMapInfoProjInfo ""
set PSPCalcMapInfoUnit ""

if [file exists $PSPCalcConfigFile] {
    set f [open $PSPCalcConfigFile r]
    gets $f tmp
    gets $f PSPCalcNligFullSize
    gets $f tmp
    gets $f tmp
    gets $f PSPCalcNcolFullSize
    gets $f tmp
    gets $f tmp
    gets $f PSPCalcPolarCase
    gets $f tmp
    gets $f tmp
    gets $f PSPCalcPolarType
    close $f
    set config "false"
    if {$PSPCalcPolarCase == "monostatic"} {set config "true"}
    if {$PSPCalcPolarCase == "bistatic"} {set config "true"}
    if {$PSPCalcPolarCase == "intensities"} {set config "true"}
    if {$config == "false"} {
        set VarFatalError ""
        set FatalErrorMessage "WRONG POLAR-CASE ARGUMENT IN CONFIG.TXT"
        .top236.fra34.cpd68 configure -state disable
        Window show .top236
        tkwait variable VarFatalError
        }
    set config "false"
    if {$PSPCalcPolarType == "full"} {set config "true"}
    if {$PSPCalcPolarType == "pp1"} {set config "true"}
    if {$PSPCalcPolarType == "pp2"} {set config "true"}
    if {$PSPCalcPolarType == "pp3"} {set config "true"}
    if {$PSPCalcPolarType == "pp4"} {set config "true"}
    if {$PSPCalcPolarType == "pp5"} {set config "true"}
    if {$PSPCalcPolarType == "pp6"} {set config "true"}
    if {$PSPCalcPolarType == "pp7"} {set config "true"}
    if {$config == "false"} {
        set VarFatalError ""
        set FatalErrorMessage "WRONG POLAR-TYPE ARGUMENT IN CONFIG.TXT"
        .top236.fra34.cpd68 configure -state disable
        Window show .top236
        tkwait variable VarFatalError
        }
    set ErrorMessage ""
    
    set PSPCalcMapInfoConfigFile [file rootname $PSPCalcConfigFile]
    append PSPCalcMapInfoConfigFile "_mapinfo.txt" 
    if [file exists $PSPCalcMapInfoConfigFile] { PSPCalcMapInfoReadConfig $PSPCalcMapInfoConfigFile }
    }
}
#############################################################################
## Procedure:  PSPCalcEnviWriteConfig

proc ::PSPCalcEnviWriteConfig {PSPCalcEnviFile PSPCalcEnviNlig PSPCalcEnviNcol PSPCalcEnviType} {
global ENVIConfigFile PSPCalcMapInfoActive PSPCalcMapInfoMapInfo PSPCalcMapInfoProjInfo PSPCalcMapInfoUnit

if {$ENVIConfigFile == 1} {
    if [file exists $PSPCalcEnviFile] {
        set PSPCalcEnviNameHdr $PSPCalcEnviFile
        append PSPCalcEnviNameHdr ".hdr"
        set PSPCalcEnviName [file tail $PSPCalcEnviFile]
        set f [open $PSPCalcEnviNameHdr w]
        puts $f "ENVI"
        puts $f "description = {"
        puts $f "PolSARpro File Imported to ENVI}"
        puts $f "samples = $PSPCalcEnviNcol"
        puts $f "lines   = $PSPCalcEnviNlig"
        puts $f "bands   = 1"
        puts $f "header offset = 0"
        puts $f "file type = ENVI Standard"
        puts $f "data type = $PSPCalcEnviType"
        puts $f "interleave = bsq"
        if {$PSPCalcMapInfoActive == ""} { puts $f "sensor type = Unknown" }
        if {$PSPCalcMapInfoActive == "Unknown"} { puts $f "sensor type = Unknown" }
        if {$PSPCalcMapInfoActive == "ALOS"} { puts $f "sensor type = ALOS" }
        if {$PSPCalcMapInfoActive == "RS2"} { puts $f "sensor type = RADARSAT2" }
        if {$PSPCalcMapInfoActive == "RISAT"} { puts $f "sensor type = RISAT" }
        if {$PSPCalcMapInfoActive == "CSK"} { puts $f "sensor type = COSMO-SKYMED" }
        if {$PSPCalcMapInfoActive == "TSX"} { puts $f "sensor type = TerraSAR-X" }
        if {$PSPCalcMapInfoActive == "UAVSAR"} { puts $f "sensor type = UAVSAR" }
        if {$PSPCalcMapInfoActive == "Other"} { puts $f "sensor type = Other" }
        puts $f "byte order = 0"
        if {$PSPCalcMapInfoActive != ""} {
            if {$PSPCalcMapInfoMapInfo != "" } { puts $f $PSPCalcMapInfoMapInfo }
            if {$PSPCalcMapInfoProjInfo != "" } { puts $f $PSPCalcMapInfoProjInfo }
            if {$PSPCalcMapInfoUnit != "" } { puts $f $PSPCalcMapInfoUnit }
            }
        puts $f "band names = {"
        puts $f "$PSPCalcEnviName }"
        close $f
        
        set PSPCalcEnviDir [file dirname $PSPCalcEnviFile]
        set MaskFile "$PSPCalcEnviDir/mask_valid_pixels.bin"
        if [file exists $MaskFile] {
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function apply_mask_valid_pixels.exe" "k"
            TextEditorRunTrace "Arguments: -bf \x22$PSPCalcEnviFile\x22 -mf \x22$MaskFile\x22 -iodf $PSPCalcEnviType -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" "k"
            set f [ open "| Soft/tools/apply_mask_valid_pixels.exe -bf \x22$PSPCalcEnviFile\x22 -mf \x22$MaskFile\x22 -iodf $PSPCalcEnviType -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }     
        }
    }
}
#############################################################################
## Procedure:  PSPCalcEnviWriteConfigS

proc ::PSPCalcEnviWriteConfigS {PSPCalcEnviDir PSPCalcEnviNlig PSPCalcEnviNcol} {
global ENVIConfigFile
global WarningMessage WarningMessage2

if {$ENVIConfigFile ==1} { 
    set MaskFile "$PSPCalcEnviDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] {
        } else {
        set MaskPolFormat ""; set MaskPol "0"
        set PSPCalcEnviFile "$PSPCalcEnviDir/s11.bin"
        if [file exists $PSPCalcEnviFile] { append MaskPol "1" }
        set PSPCalcEnviFile "$PSPCalcEnviDir/s12.bin"
        if [file exists $PSPCalcEnviFile] { append MaskPol "2" }
        set PSPCalcEnviFile "$PSPCalcEnviDir/s21.bin"
        if [file exists $PSPCalcEnviFile] { append MaskPol "3" }
        set PSPCalcEnviFile "$PSPCalcEnviDir/s22.bin"
        if [file exists $PSPCalcEnviFile] { append MaskPol "4" }
        
        if {$MaskPol == "01234"} { 
          set MaskPolFormat "S2" 
          } else {
          set MaskPolFormat "SPP"
          }
        
        set WarningMessage "PolSARpro IS CREATING"
        set WarningMessage2 "THE VALID PIXEL MASK"
        Window show .top448
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        set ProgressLine "0"
        update
        TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcEnviDir\x22 -od \x22$PSPCalcEnviDir\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" "k"
        set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$PSPCalcEnviDir\x22 -od \x22$PSPCalcEnviDir\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists $MaskFile] { PSPCalcEnviWriteConfig $MaskFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 } 
        Window hide .top448
        }
    
    set PSPCalcEnviFile "$PSPCalcEnviDir/s11.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 6 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/s12.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 6 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/s21.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 6 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/s22.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 6 }
    }
}
#############################################################################
## Procedure:  PSPCalcEnviWriteConfigC

proc ::PSPCalcEnviWriteConfigC {PSPCalcEnviDir PSPCalcEnviNlig PSPCalcEnviNcol} {
global ENVIConfigFile
global WarningMessage WarningMessage2

if {$ENVIConfigFile ==1} {
    set MaskFile "$PSPCalcEnviDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] {
        } else {
        set MaskPolFormat "C2"
        set PSPCalcEnviFile "$PSPCalcEnviDir/C33.bin"
        if [file exists $PSPCalcEnviFile] { set MaskPolFormat "C3" }
        set PSPCalcEnviFile "$PSPCalcEnviDir/C44.bin"
        if [file exists $PSPCalcEnviFile] { set MaskPolFormat "C4" }
        
        set WarningMessage "PolSARpro IS CREATING"
        set WarningMessage2 "THE VALID PIXEL MASK"
        Window show .top448
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        set ProgressLine "0"
        update
        TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcEnviDir\x22 -od \x22$PSPCalcEnviDir\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" "k"
        set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$PSPCalcEnviDir\x22 -od \x22$PSPCalcEnviDir\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists $MaskFile] { PSPCalcEnviWriteConfig $MaskFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 } 
        Window hide .top448
        }
    
    set PSPCalcEnviFile "$PSPCalcEnviDir/C11.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C12_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C12_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C13_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C13_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C14_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C14_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C22.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C23_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C23_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C24_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C24_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C33.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C34_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C34_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/C44.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 } 
    }
}
#############################################################################
## Procedure:  PSPCalcEnviWriteConfigT

proc ::PSPCalcEnviWriteConfigT {PSPCalcEnviDir PSPCalcEnviNlig PSPCalcEnviNcol} {
global ENVIConfigFile
global WarningMessage WarningMessage2

if {$ENVIConfigFile ==1} {
    set MaskFile "$PSPCalcEnviDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] {
        } else {
        set MaskPolFormat "T2"
        set PSPCalcEnviFile "$PSPCalcEnviDir/T33.bin"
        if [file exists $PSPCalcEnviFile] { set MaskPolFormat "T3" }
        set PSPCalcEnviFile "$PSPCalcEnviDir/T44.bin"
        if [file exists $PSPCalcEnviFile] { set MaskPolFormat "T4" }
        set PSPCalcEnviFile "$PSPCalcEnviDir/T66.bin"
        if [file exists $PSPCalcEnviFile] { set MaskPolFormat "T6" }
        
        set WarningMessage "PolSARpro IS CREATING"
        set WarningMessage2 "THE VALID PIXEL MASK"
        Window show .top448
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        set ProgressLine "0"
        update
        TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PSPCalcEnviDir\x22 -od \x22$PSPCalcEnviDir\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" "k"
        set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$PSPCalcEnviDir\x22 -od \x22$PSPCalcEnviDir\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $PSPCalcEnviNlig -fnc $PSPCalcEnviNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists $MaskFile] { PSPCalcEnviWriteConfig $MaskFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 } 
        Window hide .top448
        }
    
    set PSPCalcEnviFile "$PSPCalcEnviDir/T11.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T12_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T12_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T13_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T13_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T14_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T14_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T15_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T15_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T16_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T16_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T22.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T23_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T23_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T24_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T24_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T25_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T25_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T26_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T26_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T33.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T34_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T34_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T35_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T35_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T36_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T36_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T44.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T45_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T45_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T46_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T46_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T55.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T56_real.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T56_imag.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    set PSPCalcEnviFile "$PSPCalcEnviDir/T66.bin"
    if [file exists $PSPCalcEnviFile] { PSPCalcEnviWriteConfig $PSPCalcEnviFile $PSPCalcEnviNlig $PSPCalcEnviNcol 4 }
    }
}
#############################################################################
## Procedure:  PSPCalcEnviWriteConfigCheck

proc ::PSPCalcEnviWriteConfigCheck {PSPCalcEnviDir PSPCalcEnviNlig PSPCalcEnviNcol PSPCalcEnviDataType} {
if { $PSPCalcEnviDataType == "S2" } { PSPCalcEnviWriteConfigS $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "SPP" } { PSPCalcEnviWriteConfigS $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "C2" } { PSPCalcEnviWriteConfigC $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "C3" } { PSPCalcEnviWriteConfigC $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "C4" } { PSPCalcEnviWriteConfigC $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "T2" } { PSPCalcEnviWriteConfigT $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "T3" } { PSPCalcEnviWriteConfigT $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "T4" } { PSPCalcEnviWriteConfigT $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
if { $PSPCalcEnviDataType == "T6" } { PSPCalcEnviWriteConfigT $PSPCalcEnviDir $PSPCalcEnviNlig $PSPCalcEnviNcol }
}
#############################################################################
## Procedure:  PSPCalcMapInfoReadConfig

proc ::PSPCalcMapInfoReadConfig {PSPCalcMapInfoConfFile} {
global PSPCalcMapInfoActive PSPCalcMapInfoMapInfo PSPCalcMapInfoProjInfo PSPCalcMapInfoUnit
global PSPCalcMapInfoGeocoding MapReadyPixelSize 
global PSPCalcMapInfoUTM_X0 PSPCalcMapInfoUTM_Y0 PSPCalcMapInfoUTM_dX PSPCalcMapInfoUTM_dY
global PSPCalcMapInfoLatLong_X0 PSPCalcMapInfoLatLong_Y0 PSPCalcMapInfoLatLong_Lat0 PSPCalcMapInfoLatLong_Long0
global PSPCalcMapInfoLatLong_dLat PSPCalcMapInfoLatLong_dLong

if [file exists $PSPCalcMapInfoConfFile] {
    set f [open $PSPCalcMapInfoConfFile r]
    set FlagStop 0
    while {$FlagStop == 0} {
        gets $f tmp
        if {$tmp == "Sensor"} { gets $f PSPCalcMapInfoActive }    
        if {$tmp == "MapInfo"} { gets $f PSPCalcMapInfoMapInfo }    
        if {$tmp == "ProjInfo"} { gets $f PSPCalcMapInfoProjInfo }    
        if {$tmp == "WaveUnit"} { gets $f PSPCalcMapInfoUnit }    
        if {$tmp == "MapProj"} { 
            gets $f PSPCalcMapInfoGeocoding
            if {$PSPCalcMapInfoGeocoding == "UTM"} {
                gets $f PSPCalcMapInfoUTM_X0
                gets $f PSPCalcMapInfoUTM_Y0
                gets $f PSPCalcMapInfoUTM_dX; set MapReadyPixelSize $PSPCalcMapInfoUTM_dX
                gets $f PSPCalcMapInfoUTM_dY
                }
            if {$PSPCalcMapInfoGeocoding == "Geographic Lat/Lon"} {
                gets $f PSPCalcMapInfoLatLong_X0
                gets $f PSPCalcMapInfoLatLong_Y0
                gets $f PSPCalcMapInfoLatLong_Lat0
                gets $f PSPCalcMapInfoLatLong_Long0
                gets $f PSPCalcMapInfoLatLong_dLat
                gets $f PSPCalcMapInfoLatLong_dLong
                }
            set FlagStop 1
            }
        }
    close $f
    }
}
#############################################################################
## Procedure:  PSPCalcOutputValueON

proc ::PSPCalcOutputValueON {} {
global PSPCalcValueOutputReal PSPCalcValueOutputImag PSPCalcOutputFormat
global PSPBackgroundColor
global PSPCalcOutputValueFrameTitle PSPCalcOutputValueEntryReal PSPCalcOutputValueEntryImag PSPCalcOutputValueLabelJ


$PSPCalcOutputValueFrameTitle configure -state normal
$PSPCalcOutputValueEntryReal configure -state disable -disabledbackground #FFFFFF

if {$PSPCalcOutputFormat == "cmplx"} {
    $PSPCalcOutputValueLabelJ configure -state normal
    $PSPCalcOutputValueEntryImag configure -state disable -disabledbackground #FFFFFF
    }
}
#############################################################################
## Procedure:  PSPCalcRunMatX

proc ::PSPCalcRunMatX {} {
global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global PSPCalcOutputFormat PSPCalcOutputType PSPCalcOperatorX
global VarError ErrorMessage PSPMemory TMPMemoryAllocError TMPPSPCalcMatX0
global PSPCalcValueOutputReal PSPCalcValueOutputImag PSPCalcCreateMatXType
global PSPCalcOutputResultDir PSPCalcOutputResultFile PSPCalcCreateMatXTitleFrame
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i
    
set PSPCalcOutputType "matX"
DeleteFile $TMPPSPCalcMatX0

if {$PSPCalcOp2Type == "" } {
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matX_operand_out_value.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$PSPCalcOp1FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -op $PSPCalcOperatorX" "k"
    set f [ open "| Soft/calculator/matX_operand_out_value.exe -if \x22$PSPCalcOp1FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -op $PSPCalcOperatorX" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    set PSPCalcOutputType "value"
    }

if {$PSPCalcOp2Type == "out_matX" } {
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matX_operand_out_matX.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$PSPCalcOp1FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -op $PSPCalcOperatorX" "k"
    set f [ open "| Soft/calculator/matX_operand_out_matX.exe -if \x22$PSPCalcOp1FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -op $PSPCalcOperatorX" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "value" } {
    if {$PSPCalcOp2Format == "cmplx"} {set PSPCalcOp2ValueInputIm $PSPCalcOp2ValueInputImag }
    if {$PSPCalcOp2Format == "float"} {set PSPCalcOp2ValueInputIm "0" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matX_operand_value.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$PSPCalcOp1FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -ivr $PSPCalcOp2ValueInputReal -ivi $PSPCalcOp2ValueInputIm -it $PSPCalcOp2Format -op $PSPCalcOperatorX" "k"
    set f [ open "| Soft/calculator/matX_operand_value.exe -if \x22$PSPCalcOp1FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -ivr $PSPCalcOp2ValueInputReal -ivi $PSPCalcOp2ValueInputIm -it $PSPCalcOp2Format -op $PSPCalcOperatorX" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

if {$PSPCalcOp2Type == "matX" } {
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/calculator/matX_operand_matX.exe" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$PSPCalcOp1FileInput\x22 -if2 \x22$PSPCalcOp2FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -op $PSPCalcOperatorX" "k"
    set f [ open "| Soft/calculator/matX_operand_matX.exe -if1 \x22$PSPCalcOp1FileInput\x22 -if2 \x22$PSPCalcOp2FileInput\x22 -of \x22$TMPPSPCalcMatX0\x22 -op $PSPCalcOperatorX" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }

WaitUntilCreated $TMPPSPCalcMatX0
DeleteFile $PSPCalcOp1FileInput

set PSPCalcOutputResultDir [file tail $PSPCalcOp1FileInput]
set PSPCalcOutputResultFile $PSPCalcOp1FileInput

if {$PSPCalcOutputType == "value"} {
    set f [open $TMPPSPCalcMatX0 "r"]
    gets $f tmp
    gets $f PSPCalcOutputFormat
    gets $f PSPCalcValueOutputReal
    gets $f PSPCalcValueOutputImag
    close $f
    PSPCalcOutputValueON
    PSPCalcCreateMatXRAZ
    set PSPCalcOp1Format $PSPCalcOutputFormat
    CopyFile $TMPPSPCalcMatX0 $PSPCalcOp1FileInput 
    WaitUntilCreated $PSPCalcOp1FileInput
    }

if {$PSPCalcOutputType == "matX"} {
    $PSPCalcCreateMatXTitleFrame configure -state normal
    #PSPCalcCreateMatXON "cmplx" "float" "herm" "SU"
    set f [open $TMPPSPCalcMatX0 "r"]
    gets $f tmp
    if {$tmp == "PolSARpro Calculator v1.0"} {
        gets $f PSPCalcCreateMatXType
        set PSPCalcOutputFormat $PSPCalcCreateMatXType
        gets $f MatDim
        if {$MatDim == "4"} {
            if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
                PSPCalcCreateMatXInitCmplx $MatDim
                gets $f PSPCalcCreateMat11r; gets $f PSPCalcCreateMat11i
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat14r; gets $f PSPCalcCreateMat14i
                gets $f PSPCalcCreateMat21r; gets $f PSPCalcCreateMat21i
                gets $f PSPCalcCreateMat22r; gets $f PSPCalcCreateMat22i
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat24r; gets $f PSPCalcCreateMat24i
                gets $f PSPCalcCreateMat31r; gets $f PSPCalcCreateMat31i
                gets $f PSPCalcCreateMat32r; gets $f PSPCalcCreateMat32i
                gets $f PSPCalcCreateMat33r; gets $f PSPCalcCreateMat33i
                gets $f PSPCalcCreateMat34r; gets $f PSPCalcCreateMat34i
                gets $f PSPCalcCreateMat41r; gets $f PSPCalcCreateMat41i
                gets $f PSPCalcCreateMat42r; gets $f PSPCalcCreateMat42i
                gets $f PSPCalcCreateMat43r; gets $f PSPCalcCreateMat43i
                gets $f PSPCalcCreateMat44r; gets $f PSPCalcCreateMat44i
                }
            if {$PSPCalcCreateMatXType == "float"} {
                PSPCalcCreateMatXInitFltInt $MatDim
                gets $f PSPCalcCreateMat11r
                gets $f PSPCalcCreateMat12r
                gets $f PSPCalcCreateMat13r
                gets $f PSPCalcCreateMat14r
                gets $f PSPCalcCreateMat21r
                gets $f PSPCalcCreateMat22r
                gets $f PSPCalcCreateMat23r
                gets $f PSPCalcCreateMat24r
                gets $f PSPCalcCreateMat31r
                gets $f PSPCalcCreateMat32r
                gets $f PSPCalcCreateMat33r
                gets $f PSPCalcCreateMat34r
                gets $f PSPCalcCreateMat41r
                gets $f PSPCalcCreateMat42r
                gets $f PSPCalcCreateMat43r
                gets $f PSPCalcCreateMat44r
                }
            if {$PSPCalcCreateMatXType == "herm"} {
                PSPCalcCreateMatXInitHerm $MatDim
                gets $f PSPCalcCreateMat11r;
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat14r; gets $f PSPCalcCreateMat14i
                gets $f PSPCalcCreateMat22r;
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat24r; gets $f PSPCalcCreateMat24i
                gets $f PSPCalcCreateMat33r;
                gets $f PSPCalcCreateMat34r; gets $f PSPCalcCreateMat34i
                gets $f PSPCalcCreateMat44r;
                }
            }
        if {$MatDim == "3"} {
            if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
                PSPCalcCreateMatXInitCmplx $MatDim
                gets $f PSPCalcCreateMat11r; gets $f PSPCalcCreateMat11i
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat21r; gets $f PSPCalcCreateMat21i
                gets $f PSPCalcCreateMat22r; gets $f PSPCalcCreateMat22i
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat31r; gets $f PSPCalcCreateMat31i
                gets $f PSPCalcCreateMat32r; gets $f PSPCalcCreateMat32i
                gets $f PSPCalcCreateMat33r; gets $f PSPCalcCreateMat33i
                }
            if {$PSPCalcCreateMatXType == "float"} {
                PSPCalcCreateMatXInitFltInt $MatDim
                gets $f PSPCalcCreateMat11r
                gets $f PSPCalcCreateMat12r
                gets $f PSPCalcCreateMat13r
                gets $f PSPCalcCreateMat21r
                gets $f PSPCalcCreateMat22r
                gets $f PSPCalcCreateMat23r
                gets $f PSPCalcCreateMat31r
                gets $f PSPCalcCreateMat32r
                gets $f PSPCalcCreateMat33r
                }
            if {$PSPCalcCreateMatXType == "herm"} {
                PSPCalcCreateMatXInitHerm $MatDim
                gets $f PSPCalcCreateMat11r;
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat22r;
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat33r;
                }
            }
        if {$MatDim == "2"} {
            if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
                PSPCalcCreateMatXInitCmplx $MatDim
                gets $f PSPCalcCreateMat11r; gets $f PSPCalcCreateMat11i
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat21r; gets $f PSPCalcCreateMat21i
                gets $f PSPCalcCreateMat22r; gets $f PSPCalcCreateMat22i
                }
            if {$PSPCalcCreateMatXType == "float"} {
                PSPCalcCreateMatXInitFltInt $MatDim
                gets $f PSPCalcCreateMat11r
                gets $f PSPCalcCreateMat12r
                gets $f PSPCalcCreateMat21r
                gets $f PSPCalcCreateMat22r
                }
            if {$PSPCalcCreateMatXType == "herm"} {
                PSPCalcCreateMatXInitHerm $MatDim
                gets $f PSPCalcCreateMat11r;
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat22r;
                }
            }
        set PSPCalcOperand "OP1"
        set PSPCalcOp1MatDim $MatDim
        CopyFile $TMPPSPCalcMatX0 $PSPCalcOp1FileInput
        WaitUntilCreated $PSPCalcOp1FileInput
        } else {
        set ErrorMessage "NOT A PolSARpro Calculator BINARY DATA FILE"
        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcCreateMatXRAZ
        }    
    close $f
    }
    
}
#############################################################################
## Procedure:  PSPCalcOperatorFileRAZ

proc ::PSPCalcOperatorFileRAZ {} {
global PSPCalcOperatorF PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton
global PSPCalcOp1Format PSPBackgroundColor
global VarError ErrorMessage PSPMemory TMPMemoryAllocError

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

$PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcOutputValueOFF
Window hide .top601
Window hide .top602
Window hide .top603

if {$PSPCalcOperatorF == "addval"} {set PSPCalcOperatorName "(file) + value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorF == "subval"} {set PSPCalcOperatorName "(file) - value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorF == "mulval"} {set PSPCalcOperatorName "(file) * value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorF == "divval"} {set PSPCalcOperatorName "(file) / value"; set PSPCalcOp2Type "value"}

if {$PSPCalcOperatorF == "xy"} {set PSPCalcOperatorName ".(.)^(?)"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorF == "inf"} {set PSPCalcOperatorName ".(.) < (?)"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorF == "sup"} {set PSPCalcOperatorName ".(.) > (?)"; set PSPCalcOp2Type "valuefloat"}

if {$PSPCalcOperatorF == "filter"} {set PSPCalcOperatorName ".filter(?x?)"; set PSPCalcOp2Type "valueint"}

if {$PSPCalcOperatorF == "addfile"} {set PSPCalcOperatorName "(file)  .+  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorF == "subfile"} {set PSPCalcOperatorName "(file)  .-  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorF == "mulfile"} {set PSPCalcOperatorName "(file)  .*  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorF == "divfile"} {set PSPCalcOperatorName "(file)  ./  (file)"; set PSPCalcOp2Type "file"}

if {$PSPCalcOperatorF == "real"} {set PSPCalcOperatorName ".real(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "imag"} {set PSPCalcOperatorName ".imag(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "arg"} {set PSPCalcOperatorName ".arg(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "abs"} {set PSPCalcOperatorName ".abs(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "cos"} {set PSPCalcOperatorName ".cos(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "sin"} {set PSPCalcOperatorName ".sin(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "tan"} {set PSPCalcOperatorName ".tan(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "conj"} {set PSPCalcOperatorName ".conj(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "acos"} {set PSPCalcOperatorName ".acos(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "asin"} {set PSPCalcOperatorName ".asin(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "atan"} {set PSPCalcOperatorName ".atan(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "sqrt"} {set PSPCalcOperatorName ".sqrt(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "x2"} {set PSPCalcOperatorName ".(.)^2"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "x3"} {set PSPCalcOperatorName ".(.)^3"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "log"} {set PSPCalcOperatorName ".log(|.|)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "ln"} {set PSPCalcOperatorName ".ln(|.|)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "10x"} {set PSPCalcOperatorName ".10^(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "exp"} {set PSPCalcOperatorName ".exp(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "10log"} {set PSPCalcOperatorName ".10log(|.|)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "20log"} {set PSPCalcOperatorName ".20log(|.|)"; set PSPCalcOp2Type ""}

set config "true"
if {$PSPCalcOp1Format == "cmplx"} {
  if {$PSPCalcOperatorF == "acos" } { set config "false" }
  if {$PSPCalcOperatorF == "asin" } { set config "false" }
  if {$PSPCalcOperatorF == "atan" } { set config "false" }
  if {$PSPCalcOperatorF == "xy" } { set config "false" }
  if {$PSPCalcOperatorF == "inf" } { set config "false" }
  if {$PSPCalcOperatorF == "sup" } { set config "false" }
  if {$PSPCalcOperatorF == "filter" } { set config "false" }
  }

if {$config == "true"} {
if {$PSPCalcOperatorF != ""} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type != ""} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        }
    }
    }
} else {
set ErrorMessage "OPERATOR NOT COMPATIBLE WITH COMPLEX TYPE"
WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
PSPCalcRAZButton
}
}
#############################################################################
## Procedure:  PSPCalcOperatorMatSRAZ

proc ::PSPCalcOperatorMatSRAZ {} {
global PSPCalcOperatorS PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton
global PSPBackgroundColor

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

$PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcOutputValueOFF
Window hide .top601
Window hide .top602
Window hide .top603

if {$PSPCalcOperatorS == "addval"} {set PSPCalcOperatorName "\[ S \] + value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorS == "subval"} {set PSPCalcOperatorName "\[ S \] - value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorS == "mulval"} {set PSPCalcOperatorName "\[ S \] * value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorS == "divval"} {set PSPCalcOperatorName "\[ S \] / value"; set PSPCalcOp2Type "value"}

if {$PSPCalcOperatorS == "addfile"} {set PSPCalcOperatorName "\[ S \]  .+  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorS == "subfile"} {set PSPCalcOperatorName "\[ S \]  .-  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorS == "mulfile"} {set PSPCalcOperatorName "\[ S \]  .*  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorS == "divfile"} {set PSPCalcOperatorName "\[ S \]  ./  (file)"; set PSPCalcOp2Type "file"}

if {$PSPCalcOperatorS == "addmatS"} {set PSPCalcOperatorName "\[ S \]  .+  \[ S' \]"; set PSPCalcOp2Type "matS"}
if {$PSPCalcOperatorS == "mulmatS"} {set PSPCalcOperatorName "\[ S \]  .*  \[ S' \]"; set PSPCalcOp2Type "matS"}

if {$PSPCalcOperatorS == "addmatX"} {set PSPCalcOperatorName "\[ S \]  .+  \[ mat \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorS == "mulmatX"} {set PSPCalcOperatorName "\[ S \]  .*  \[ mat \]"; set PSPCalcOp2Type "matX"}

if {$PSPCalcOperatorS == "consimilarity"} {set PSPCalcOperatorName "\[ U \]t  .*  \[ S \]  .*  \[ U \]"; set PSPCalcOp2Type "matXSU"}

if {$PSPCalcOperatorS == "graves"} {set PSPCalcOperatorName "\[ S \]  .*  \[ S \]*"; set PSPCalcOp2Type "out_matS"}
if {$PSPCalcOperatorS == "conj"} {set PSPCalcOperatorName ".conj \[ S \]"; set PSPCalcOp2Type "out_matS"}
if {$PSPCalcOperatorS == "inv"} {set PSPCalcOperatorName ".inv \[ S \]"; set PSPCalcOp2Type "out_matS"}
if {$PSPCalcOperatorS == "det"} {set PSPCalcOperatorName ".det \[ S \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorS == "tr"} {set PSPCalcOperatorName ".tr \[ S \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorS == "eig1S"} {set PSPCalcOperatorName ".eig1 \[ S \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorS == "eig2S"} {set PSPCalcOperatorName ".eig2 \[ S \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorS == "eig1G"} {set PSPCalcOperatorName ".eig1 \[ G \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorS == "eig2G"} {set PSPCalcOperatorName ".eig2 \[ G \]"; set PSPCalcOp2Type "out_eig"}

if {$PSPCalcOperatorS != ""} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type == "value" || $PSPCalcOp2Type == "file" || $PSPCalcOp2Type == "matS" || $PSPCalcOp2Type == "matX" || $PSPCalcOp2Type == "matXSU"} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        }
    }
    }
}
#############################################################################
## Procedure:  PSPCalcOperatorMatMRAZ

proc ::PSPCalcOperatorMatMRAZ {} {
global PSPCalcOperatorM PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton
global PSPBackgroundColor

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

$PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcOutputValueOFF
Window hide .top601
Window hide .top602
Window hide .top603

if {$PSPCalcOperatorM == "addval"} {set PSPCalcOperatorName "\[ M \] + value"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorM == "subval"} {set PSPCalcOperatorName "\[ M \] - value"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorM == "mulval"} {set PSPCalcOperatorName "\[ M \] * value"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorM == "divval"} {set PSPCalcOperatorName "\[ M \] / value"; set PSPCalcOp2Type "valuefloat"}

if {$PSPCalcOperatorM == "addfile"} {set PSPCalcOperatorName "\[ M \]  .+  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorM == "subfile"} {set PSPCalcOperatorName "\[ M \]  .-  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorM == "mulfile"} {set PSPCalcOperatorName "\[ M \]  .*  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorM == "divfile"} {set PSPCalcOperatorName "\[ M \]  ./  (file)"; set PSPCalcOp2Type "file"}

if {$PSPCalcOperatorM == "addmatM"} {set PSPCalcOperatorName "\[ M \]  .+  \[ M' \]"; set PSPCalcOp2Type "matM"}
if {$PSPCalcOperatorM == "addmatX"} {set PSPCalcOperatorName "\[ M \]  .+  \[ mat \]"; set PSPCalcOp2Type "matXherm"}

if {$PSPCalcOperatorM == "similarity"} {set PSPCalcOperatorName "\[ U \]  .*  \[ M \]  .*  inv\[ U \]"; set PSPCalcOp2Type "matXSU"}
if {$PSPCalcOperatorM == "trmatXmatM"} {set PSPCalcOperatorName "tr( inv\[ mat \]  .*  \[ M \] )"; set PSPCalcOp2Type "matXherm"}

if {$PSPCalcOperatorM == "conj"} {set PSPCalcOperatorName ".conj \[ M \]"; set PSPCalcOp2Type "out_matM"}
if {$PSPCalcOperatorM == "inv"} {set PSPCalcOperatorName ".inv \[ M \]"; set PSPCalcOp2Type "out_matM"}
if {$PSPCalcOperatorM == "det"} {set PSPCalcOperatorName ".det \[ M \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorM == "tr"} {set PSPCalcOperatorName ".tr \[ M \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorM == "eig1"} {set PSPCalcOperatorName ".eig1 \[ M \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorM == "eig2"} {set PSPCalcOperatorName ".eig2 \[ M \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorM == "eig3"} {set PSPCalcOperatorName ".eig3 \[ M \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorM == "eig4"} {set PSPCalcOperatorName ".eig4 \[ M \]"; set PSPCalcOp2Type "out_eig"}

if {$PSPCalcOperatorM != ""} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type == "valuefloat" || $PSPCalcOp2Type == "file" || $PSPCalcOp2Type == "matM" || $PSPCalcOp2Type == "matX" || $PSPCalcOp2Type == "matXSU" || $PSPCalcOp2Type == "matXherm"} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        }
    }
}
}
#############################################################################
## Procedure:  PSPCalcOperatorMatXRAZ

proc ::PSPCalcOperatorMatXRAZ {} {
global PSPCalcOperatorX PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton
global PSPCalcOp1Format PSPCalcOp1MatDim
global VarError ErrorMessage PSPMemory TMPMemoryAllocError
global PSPBackgroundColor

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

$PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcOutputValueOFF
Window hide .top601
Window hide .top602
Window hide .top603

if {$PSPCalcOperatorX == "addval"} {set PSPCalcOperatorName "\[ mat \] + value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "subval"} {set PSPCalcOperatorName "\[ mat \] - value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "mulval"} {set PSPCalcOperatorName "\[ mat \] * value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "divval"} {set PSPCalcOperatorName "\[ mat \] / value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "addmatX"} {set PSPCalcOperatorName "\[ mat \]  .+  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "submatX"} {set PSPCalcOperatorName "\[ mat \]  .-  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "mulmatX"} {set PSPCalcOperatorName "\[ mat \]  .*  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "divmatX"} {set PSPCalcOperatorName "\[ mat \]  ./  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "inv"} {set PSPCalcOperatorName ".inv \[ mat \]"; set PSPCalcOp2Type "out_matX"}
if {$PSPCalcOperatorX == "det"} {set PSPCalcOperatorName ".det \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "tr"} {set PSPCalcOperatorName ".tr \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "conj"} {set PSPCalcOperatorName ".conj \[ mat \]"; set PSPCalcOp2Type "out_matX"}
if {$PSPCalcOperatorX == "eig1"} {set PSPCalcOperatorName ".eig1 \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "eig2"} {set PSPCalcOperatorName ".eig2 \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "eig3"} {set PSPCalcOperatorName ".eig3 \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "eig4"} {set PSPCalcOperatorName ".eig4 \[ mat \]"; set PSPCalcOp2Type ""}

set config "true"
if {$PSPCalcOperatorX == "divmatX" || $PSPCalcOperatorX == "det" || $PSPCalcOperatorX == "inv" || $PSPCalcOperatorX == "eig1" || $PSPCalcOperatorX == "eig2" || $PSPCalcOperatorX == "eig3" || $PSPCalcOperatorX == "eig4" } {
  if {$PSPCalcOp1Format != "herm"} { set config "false" }
  }

if {$config == "true"} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type == "value" || $PSPCalcOp2Type == "matX"} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        }
    }
} else {
set ErrorMessage "MATRIX MUST BE HERMITIAN TYPE"
WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
PSPCalcRAZButton
}
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

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
    wm geometry $top 200x200+150+150; update
    wm maxsize $top 1684 1032
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

proc vTclWindow.top600 {base} {
    if {$base == ""} {
        set base .top600
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
    wm geometry $top 1000x600+10+110; update
    wm maxsize $top 3360 1028
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSARpro Calculator v1.0"
    vTcl:DefineAlias "$top" "Toplevel600" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra67 \
        -borderwidth 2 -height 75 -width 600 
    vTcl:DefineAlias "$top.fra67" "Frame1" vTcl:WidgetProc "Toplevel600" 1
    set site_3_0 $top.fra67
    label $site_3_0.lab78 \
        \
        -image [vTcl:image:get_image [file join . GUI Images calculator2.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_3_0.lab78" "Label1" vTcl:WidgetProc "Toplevel600" 1
    frame $site_3_0.fra79 \
        -borderwidth 2 -relief ridge -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra79" "Frame115" vTcl:WidgetProc "Toplevel600" 1
    set site_4_0 $site_3_0.fra79
    frame $site_4_0.fra80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra80" "Frame121" vTcl:WidgetProc "Toplevel600" 1
    set site_5_0 $site_4_0.fra80
    entry $site_5_0.ent81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -relief flat -state disabled -textvariable PSPCalcOp1Name -width 25 
    vTcl:DefineAlias "$site_5_0.ent81" "Entry1" vTcl:WidgetProc "Toplevel600" 1
    frame $site_5_0.fra122 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra122" "Frame133" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.fra122
    label $site_6_0.lab125 \
        -text {Op #1} 
    vTcl:DefineAlias "$site_6_0.lab125" "Label11" vTcl:WidgetProc "Toplevel600" 1
    entry $site_6_0.cpd124 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPCalcOperand1 -width 15 
    vTcl:DefineAlias "$site_6_0.cpd124" "Entry18" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.lab125 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd124 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra122 \
        -in $site_5_0 -anchor center -expand 1 -fill x -pady 4 -side top 
    frame $site_4_0.cpd83 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd83" "Frame123" vTcl:WidgetProc "Toplevel600" 1
    set site_5_0 $site_4_0.cpd83
    entry $site_5_0.ent81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -relief flat -state disabled -textvariable PSPCalcOperatorName \
        -width 25 
    vTcl:DefineAlias "$site_5_0.ent81" "Entry3" vTcl:WidgetProc "Toplevel600" 1
    frame $site_5_0.fra66 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra66" "Frame135" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.fra66
    label $site_6_0.cpd67 \
        -font {{MS Sans Serif} 8 italic} -text {( Op#1 )  Operator  ( Op#2 )} 
    vTcl:DefineAlias "$site_6_0.cpd67" "Label13" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra66 \
        -in $site_5_0 -anchor center -expand 1 -fill none -pady 4 -side top 
    frame $site_4_0.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame124" vTcl:WidgetProc "Toplevel600" 1
    set site_5_0 $site_4_0.cpd84
    entry $site_5_0.ent81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -relief flat -state disabled -textvariable PSPCalcOp2Name -width 25 
    vTcl:DefineAlias "$site_5_0.ent81" "Entry5" vTcl:WidgetProc "Toplevel600" 1
    frame $site_5_0.cpd126 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd126" "Frame134" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd126
    label $site_6_0.lab125 \
        -text {Op #2} 
    vTcl:DefineAlias "$site_6_0.lab125" "Label12" vTcl:WidgetProc "Toplevel600" 1
    entry $site_6_0.cpd124 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPCalcOperand2 -width 15 
    vTcl:DefineAlias "$site_6_0.cpd124" "Entry19" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.lab125 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd124 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd126 \
        -in $site_5_0 -anchor center -expand 1 -fill x -pady 4 -side top 
    pack $site_4_0.fra80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra66" "Frame103" vTcl:WidgetProc "Toplevel600" 1
    set site_4_0 $site_3_0.fra66
    TitleFrame $site_4_0.tit67 \
        -foreground #0000ff -text {Operand #1} 
    vTcl:DefineAlias "$site_4_0.tit67" "TitleFrame1" vTcl:WidgetProc "Toplevel600" 1
    bind $site_4_0.tit67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit67 getframe]
    button $site_6_0.but68 \
        \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global OpenDirFile PSPCalcInputFile PSPCalcInputFileFormat
global NligInitFile NligEndFile NcolInitFile NcolEndFile

if {$OpenDirFile == 0} {
PSPCalcRAZButton

set PSPCalcOp1Name "? ? ?"; set PSPCalcOperand1  "---"; set PSPCalcOp1Type "file"; set PSPCalcOp1Format ""
set PSPCalcOp1PolarCase ""; set PSPCalcOp1PolarType ""; set PSPCalcOp1MatDim ""
set PSPCalcOp1FileInput ""; set PSPCalcOp1MatDirInput ""

set PSPCalcOperand "OP1"

set PSPCalcInputFile ""; set PSPCalcInputFileFormat ""
set NligInitFile ""; set NligEndFile ""; set NcolInitFile ""; set NcolEndFile ""

PSPCalcInputFileON
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcCreateMatXOFF
PSPCalcOperatorFileOFF
PSPCalcOperatorMatSOFF
PSPCalcOperatorMatMOFF
PSPCalcOperatorMatXOFF
PSPCalcOutputValueOFF
}} \
        -foreground #0000ff -padx 4 -pady 2 -text File 
    vTcl:DefineAlias "$site_6_0.but68" "Button1" vTcl:WidgetProc "Toplevel600" 1
    button $site_6_0.cpd69 \
        \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global OpenDirFile PSPCalcInputDirMat PSPCalcInputDirMatFormat
global NligInitMat NligEndMat NcolInitMat NcolEndMat

if {$OpenDirFile == 0} {
PSPCalcRAZButton

set PSPCalcOp1Name "? ? ?"; set PSPCalcOperand1  "---"; set PSPCalcOp1Type "matM"; set PSPCalcOp1Format ""
set PSPCalcOp1PolarCase ""; set PSPCalcOp1PolarType ""; set PSPCalcOp1MatDim ""
set PSPCalcOp1FileInput ""; set PSPCalcOp1MatDirInput ""

set PSPCalcOperand "OP1"

set PSPCalcInputDirMat ""; set PSPCalcInputDirMatFormat ""
set NligInitMat ""; set NligEndMat ""; set NcolInitMat ""; set NcolEndMat ""

PSPCalcInputFileOFF
PSPCalcInputDirMatON
PSPCalcInputValueOFF
PSPCalcCreateMatXOFF
PSPCalcOperatorFileOFF
PSPCalcOperatorMatSOFF
PSPCalcOperatorMatMOFF
PSPCalcOperatorMatXOFF
PSPCalcOutputValueOFF
}} \
        -foreground #0000ff -padx 4 -pady 2 -text {Mat S / M} 
    vTcl:DefineAlias "$site_6_0.cpd69" "Button2" vTcl:WidgetProc "Toplevel600" 1
    button $site_6_0.cpd70 \
        \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim
global OpenDirFile PSPCalcCreateMatXType

if {$OpenDirFile == 0} {
PSPCalcRAZButton

set PSPCalcOp1Name "? ? ?"; set PSPCalcOperand1  "---"; set PSPCalcOp1Type "matX"; set PSPCalcOp1Format ""
set PSPCalcOp1PolarCase ""; set PSPCalcOp1PolarType ""; set PSPCalcOp1MatDim "2"

set PSPCalcOperand "OP1"

PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcCreateMatXON "cmplx" "float" "herm" "SU"
PSPCalcOperatorFileOFF
PSPCalcOperatorMatSOFF
PSPCalcOperatorMatMOFF
PSPCalcOperatorMatXOFF
PSPCalcOutputValueOFF
}} \
        -foreground #0000ff -padx 4 -pady 2 -text {2x2 mat} 
    vTcl:DefineAlias "$site_6_0.cpd70" "Button3" vTcl:WidgetProc "Toplevel600" 1
    button $site_6_0.cpd71 \
        \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim
global OpenDirFile PSPCalcCreateMatXType

if {$OpenDirFile == 0} {
PSPCalcRAZButton

set PSPCalcOp1Name "? ? ?"; set PSPCalcOperand1 "---"; set PSPCalcOp1Type "matX"; set PSPCalcOp1Format ""
set PSPCalcOp1PolarCase ""; set PSPCalcOp1PolarType ""; set PSPCalcOp1MatDim "3"

set PSPCalcOperand "OP1"

PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcCreateMatXON "cmplx" "float" "herm" "SU"
PSPCalcOperatorFileOFF
PSPCalcOperatorMatSOFF
PSPCalcOperatorMatMOFF
PSPCalcOperatorMatXOFF
PSPCalcOutputValueOFF
}} \
        -foreground #0000ff -padx 4 -pady 2 -text {3x3 mat} 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button4" vTcl:WidgetProc "Toplevel600" 1
    button $site_6_0.cpd72 \
        \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim
global OpenDirFile PSPCalcCreateMatXType

if {$OpenDirFile == 0} {
PSPCalcRAZButton

set PSPCalcOp1Name "? ? ?"; set PSPCalcOperand1  "---"; set PSPCalcOp1Type "matX"; set PSPCalcOp1Format ""
set PSPCalcOp1PolarCase ""; set PSPCalcOp1PolarType ""; set PSPCalcOp1MatDim "4"

set PSPCalcOperand "OP1"

PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcCreateMatXON "cmplx" "float" "herm" "SU"
PSPCalcOperatorFileOFF
PSPCalcOperatorMatSOFF
PSPCalcOperatorMatMOFF
PSPCalcOperatorMatXOFF
PSPCalcOutputValueOFF
}} \
        -foreground #0000ff -padx 4 -pady 2 -text {4x4 mat} 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button5" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.but68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    frame $site_4_0.fra73 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra73" "Frame109" vTcl:WidgetProc "Toplevel600" 1
    set site_5_0 $site_4_0.fra73
    button $site_5_0.but74 \
        -background #009999 \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim
global PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcMemName PSPCalcOperandMem PSPCalcMemType PSPCalcMemFormat PSPCalcMemPolarCase PSPCalcMemPolarType PSPCalcMemMatDim
global PSPCalcMemFileInput PSPCalcMemMatDirInput
global PSPCalcOutput PSPCalcOutputTab PSPCalcMemory PSPCalcOperand
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitMem NligEndMem NcolInitMem NcolEndMem

set PSPCalcMemory $PSPCalcOutput
if {$PSPCalcMemory == 1} {
    set PSPCalcOutputTab(1) 2
    set PSPCalcOutputTab(2) 3
    }
if {$PSPCalcMemory == 2} {
    set PSPCalcOutputTab(1) 1
    set PSPCalcOutputTab(2) 3
    }
if {$PSPCalcMemory == 3} {
    set PSPCalcOutputTab(1) 1
    set PSPCalcOutputTab(2) 2
    }
set PSPCalcOutput ""
    
set PSPCalcMemName $PSPCalcOp1Name; set PSPCalcOperandMem $PSPCalcOperand1;
set PSPCalcMemType $PSPCalcOp1Type; set PSPCalcMemFormat $PSPCalcOp1Format
set PSPCalcMemPolarCase $PSPCalcOp1PolarCase; set PSPCalcMemPolarType $PSPCalcOp1PolarType;
set PSPCalcMemMatDim $PSPCalcOp1MatDim
set PSPCalcMemFileInput $PSPCalcOp1FileInput; set PSPCalcMemMatDirInput $PSPCalcOp1MatDirInput
set NligInitMem $NligInitOp1; set NligEndMem $NligEndOp1; set NcolInitMem $NcolInitOp1; set NcolEndMem $NcolEndOp1

set PSPCalcOp1Name "? ? ?"; set PSPCalcOperand1 "---"; set PSPCalcOp1Type ""; set PSPCalcOp1Format ""
set PSPCalcOp1PolarCase ""; set PSPCalcOp1PolarType ""; set PSPCalcOp1MatDim ""
set PSPCalcOp1FileInput ""; set PSPCalcOp1MatDirInput ""
set NligInitOp1 ""; set NligEndOp1 ""; set NcolInitOp1 ""; set NcolEndOp1 ""
set PSPCalcOperand "OP1"

PSPCalcRAZButton} \
        -foreground #ffffff -padx 4 -pady 2 -relief ridge -text STO 
    vTcl:DefineAlias "$site_5_0.but74" "Button6" vTcl:WidgetProc "Toplevel600" 1
    button $site_5_0.cpd75 \
        -background #009900 \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcMemName PSPCalcOperandMem PSPCalcMemType PSPCalcMemFormat PSPCalcMemPolarCase PSPCalcMemPolarType PSPCalcMemMatDim
global PSPCalcMemFileInput PSPCalcMemMatDirInput
global PSPCalcOperand
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global NligInitMem NligEndMem NcolInitMem NcolEndMem

if {$PSPCalcOperand == "OP1"} {
    set PSPCalcOp1Name $PSPCalcMemName; set PSPCalcOperand1 $PSPCalcOperandMem; 
    set PSPCalcOp1Type $PSPCalcMemType; set PSPCalcOp1Format $PSPCalcMemFormat
    set PSPCalcOp1PolarCase $PSPCalcMemPolarCase; set PSPCalcOp1PolarType $PSPCalcMemPolarType; set PSPCalcOp1MatDim $PSPCalcMemMatDim
    set PSPCalcOp1FileInput $PSPCalcMemFileInput; set PSPCalcOp1MatDirInput $PSPCalcMemMatDirInput
    set NligInitOp1 $NligInitMem; set NligEndOp1 $NligEndMem; set NcolInitOp1 $NcolInitMem; set NcolEndOp1 $NcolEndMem
    $PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
    }
if {$PSPCalcOperand == "OP2"} {
    set PSPCalcOp2Name $PSPCalcMemName; set PSPCalcOperand2 $PSPCalcOperandMem; 
    set PSPCalcOp2Type $PSPCalcMemType; set PSPCalcOp2Format $PSPCalcMemFormat
    set PSPCalcOp2PolarCase $PSPCalcMemPolarCase; set PSPCalcOp2PolarType $PSPCalcMemPolarType; set PSPCalcOp2MatDim $PSPCalcMemMatDim
    set PSPCalcOp2FileInput $PSPCalcMemFileInput; set PSPCalcOp2MatDirInput $PSPCalcMemMatDirInput
    set NligInitOp2 $NligInitMem; set NligEndOp2 $NligEndMem; set NcolInitOp2 $NcolInitMem; set NcolEndOp2 $NcolEndMem
    $PSPCalcRunButton configure -state normal -background #FFFF00
    }
PSPCalcInputFileOFF
PSPCalcInputDirMatOFF
PSPCalcInputValueOFF
PSPCalcCreateMatXOFF} \
        -foreground #ffffff -padx 4 -pady 2 -relief ridge -text RCL 
    vTcl:DefineAlias "$site_5_0.cpd75" "Button7" vTcl:WidgetProc "Toplevel600" 1
    button $site_5_0.cpd76 \
        -activeforeground #ffffff -background #ff8000 \
        -command {global PSPCalcMemName PSPCalcOperandMem PSPCalcMemType PSPCalcMemFormat PSPCalcMemPolarCase PSPCalcMemPolarType PSPCalcMemMatDim
global PSPCalcMemFileInput PSPCalcMemMatDirInput
global NligInitMem NligEndMem NcolInitMem NcolEndMem
global PSPCalcMemory
 

set PSPCalcMemName ""; set PSPCalcOperandMem ""; set PSPCalcMemType ""; set PSPCalcMemFormat ""
set PSPCalcMemPolarCase ""; set PSPCalcMemPolarType ""; set PSPCalcMemMatDim ""
set PSPCalcMemFileInput ""; set PSPCalcMemMatDirInput ""
set NligInitMem ""; set NligEndMem ""; set NcolInitMem ""; set NcolEndMem ""

PSPCalcCleanResultDir $PSPCalcMemory
PSPCalcRAZButtonMemory} \
        -foreground #ffffff -padx 4 -pady 2 -relief ridge -text MC 
    vTcl:DefineAlias "$site_5_0.cpd76" "Button8" vTcl:WidgetProc "Toplevel600" 1
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -pady 2 \
        -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -pady 2 \
        -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -pady 2 \
        -side left 
    button $site_4_0.cpd77 \
        -background #ff0000 -command PSPCalcRAZ -foreground #ffffff -padx 4 \
        -pady 2 -relief ridge -text AC 
    vTcl:DefineAlias "$site_4_0.cpd77" "Button9" vTcl:WidgetProc "Toplevel600" 1
    pack $site_4_0.tit67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipadx 2 -ipady 2 \
        -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.tit86 \
        -ipad 0 -relief sunken -text {Input File} 
    vTcl:DefineAlias "$site_3_0.tit86" "TitleFrame3" vTcl:WidgetProc "Toplevel600" 1
    bind $site_3_0.tit86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit86 getframe]
    button $site_5_0.cpd89 \
        -background #ffff00 \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOperand PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcRunButton
global PSPCalcInputFormat PSPCalcInputFileFormat PSPCalcInputFile
global NligInitFile NligEndFile NcolInitFile NcolEndFile
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global PSPCalcOperatorNameEntry PSPCalcOperatorButton

if {$PSPCalcInputFile == "" || $PSPCalcInputFile == "SELECT THE INPUT BINARY DATA FILE"} {
PSPCalcInputFileOFF
if {$PSPCalcOperand == "OP1"} {
    set PSPCalcOp1Name "Select Operand #1"
    } else {
    set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
    $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
    $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
    $PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
    PSPCalcOperatorFileON
    }
} else {
if {$PSPCalcOperand == "OP1"} {
    set PSPCalcOp1Name [file tail $PSPCalcInputFile]
    set PSPCalcOperand1 $PSPCalcInputFileFormat
    set PSPCalcOp1Format $PSPCalcInputFormat
    set PSPCalcOp1FileInput $PSPCalcInputFile
    set NligInitOp1 $NligInitFile; set NligEndOp1 $NligEndFile
    set NcolInitOp1 $NcolInitFile; set NcolEndOp1 $NcolEndFile
    PSPCalcOperatorFileON
    } else {
    set PSPCalcOp2Name [file tail $PSPCalcInputFile]
    set PSPCalcOperand2 $PSPCalcInputFileFormat
    set PSPCalcOp2Format $PSPCalcInputFormat
    set PSPCalcOp2FileInput $PSPCalcInputFile
    set NligInitOp2 $NligInitFile; set NligEndOp2 $NligEndFile
    set NcolInitOp2 $NcolInitFile; set NcolEndOp2 $NcolEndFile
    $PSPCalcRunButton configure -state normal -background #FFFF00
    }
    PSPCalcInputFileOFF
}} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_5_0.cpd89" "PSPCalcOperatorFileButtonOK11" vTcl:WidgetProc "Toplevel600" 1
    frame $site_5_0.cpd92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame126" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd92
    frame $site_6_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd96" "Frame128" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd96
    entry $site_7_0.cpd93 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PSPCalcInputFile 
    vTcl:DefineAlias "$site_7_0.cpd93" "Entry8" vTcl:WidgetProc "Toplevel600" 1
    button $site_7_0.cpd94 \
        \
        -command {global PSPCalcInputFormat PSPCalcInputFileFormat PSPCalcInputFile
global NligInitFile NligEndFile NcolInitFile NcolEndFile
global FileName PSPCalcDirInput PSPCalcMaskCmd
global VarError ErrorMessage
global PSPCalcOp1Type PSPCalcOp1Format
global TMPPSPCalcInputDirMatConfig TMPPSPCalcInputDirMatMapInfo TMPPSPCalcInputDirMatMaskFile

set NligInitFile ""
set NligEndFile ""
set NcolInitFile ""
set NcolEndFile ""
set PSPCalcInputFormat ""
set PSPCalcInputFileFormat ""
set PSPCalcInputFile ""
set TMPPSPCalcInputDirMatConfig ""
set TMPPSPCalcInputDirMatMapInfo ""
set TMPPSPCalcInputDirMatMaskFile ""

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $PSPCalcDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set NcolEndFile [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set NligEndFile [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            set NligInitFile 1
            set NcolInitFile 1
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp == "data type = 2"} {set PSPCalcInputFormat "int"; set PSPCalcInputFileFormat "integer type file"}
            if {$tmp == "data type = 4"} {set PSPCalcInputFormat "float"; set PSPCalcInputFileFormat "float type file"}
            if {$tmp == "data type = 6"} {set PSPCalcInputFormat "cmplx"; set PSPCalcInputFileFormat "complex type file"}
            if {$PSPCalcInputFormat != "int"} {
                set config "true"
                if {$PSPCalcOp1Type == "matM"} {
                    if {$PSPCalcInputFormat == "float"} {
                        set config "true"
                        } else {
                        set config "false"
                        set ErrorMessage "THE INPUT FILE FORMAT MUST BE FLOAT FORMAT"
                        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        set PSPCalcInputFile ""
                        }
                    }
                if {$config == "true"} {
                    set PSPCalcDirInput [file dirname $FileName]
                    set PSPCalcInputFile $FileName
                    set MaskFile "$PSPCalcDirInput/mask_valid_pixels.bin"
                    if [file exists $MaskFile] {
                        set TMPPSPCalcInputDirMatMaskFile $MaskFile
                        set PSPCalcMaskCmd "-mask \x22$MaskFile\x22"
                        }
                    if [file exists "$PSPCalcDirInput/config.txt"] { set TMPPSPCalcInputDirMatConfig "$PSPCalcDirInput/config.txt" }
                    if [file exists "$PSPCalcDirInput/config_mapinfo.txt"] { set TMPPSPCalcInputDirMatMapInfo "$PSPCalcDirInput/config_mapinfo.txt" }
                    }
                } else {
                set ErrorMessage "PolSARpro Calculator v1.0 DOES NOT YET PROCESS INTEGER FORMAT"
                WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set PSPCalcInputFile "SELECT THE INPUT BINARY DATA FILE"
                }    
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE"
            WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set PSPCalcInputFile "SELECT THE INPUT BINARY DATA FILE"
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set PSPCalcInputFile "SELECT THE INPUT BINARY DATA FILE"
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd94" "Button12" vTcl:WidgetProc "Toplevel600" 1
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    frame $site_6_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd95" "Frame127" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd95
    TitleFrame $site_7_0.tit97 \
        -ipad 2 -text {Input File Data Format} 
    vTcl:DefineAlias "$site_7_0.tit97" "TitleFrame4" vTcl:WidgetProc "Toplevel600" 1
    bind $site_7_0.tit97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_9_0 [$site_7_0.tit97 getframe]
    entry $site_9_0.ent98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPCalcInputFileFormat -width 22 
    vTcl:DefineAlias "$site_9_0.ent98" "Entry4" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.ent98 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    label $site_7_0.lab99 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_7_0.lab99" "Label3" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.ent100 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInitFile -width 5 
    vTcl:DefineAlias "$site_7_0.ent100" "Entry7" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd102 \
        -text {End Row} 
    vTcl:DefineAlias "$site_7_0.cpd102" "Label4" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd105 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEndFile -width 5 
    vTcl:DefineAlias "$site_7_0.cpd105" "Entry9" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd103 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_7_0.cpd103" "Label5" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd106 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInitFile -width 5 
    vTcl:DefineAlias "$site_7_0.cpd106" "Entry10" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd104 \
        -text {End Col} 
    vTcl:DefineAlias "$site_7_0.cpd104" "Label6" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd107 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEndFile -width 5 
    vTcl:DefineAlias "$site_7_0.cpd107" "Entry11" vTcl:WidgetProc "Toplevel600" 1
    pack $site_7_0.tit97 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.lab99 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.ent100 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd102 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd105 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd103 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd106 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd104 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd107 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd89 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_3_0.cpd108 \
        -ipad 0 -relief sunken -text {Input Matrix Directory} 
    vTcl:DefineAlias "$site_3_0.cpd108" "TitleFrame5" vTcl:WidgetProc "Toplevel600" 1
    bind $site_3_0.cpd108 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd108 getframe]
    button $site_5_0.cpd89 \
        -background #ffff00 \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOperand 
global PSPCalcInputFormat PSPCalcInputDirMatFormat PSPCalcFileDirMat 
global NligInitMat NligEndMat NcolInitMat NcolEndMat PolCase PolType
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global WarningMessage WarningMessage2 VarWarning
global PSPCalcOperatorNameEntry PSPCalcOperatorButton

if {$PSPCalcInputDirMat == "" || $PSPCalcInputDirMat == "SELECT THE INPUT POLARIMETRIC BINARY DATA DIRECTORY (MATRIX : S2, C2, C3, C4, T2, T3, T4)"} {
PSPCalcInputDirMatOFF
if {$PSPCalcOperand == "OP1"} {
    set PSPCalcOp1Name "Select Operand #1"
    } else {
    set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
    $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
    $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
    $PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
    if {$PSPCalcOp1Type == "matM"} { PSPCalcOperatorMatMON }
    if {$PSPCalcOp1Type == "matS"} { PSPCalcOperatorMatSON }
    }
} else {
if {$PolType == "full"} {
if {$PSPCalcOperand == "OP1"} {
    set PSPCalcOp1Name $PSPCalcInputDirMatFormat
    set PSPCalcOp1Format $PSPCalcInputFormat
    set PSPCalcOp1MatDirInput $PSPCalcInputDirMat
    set PSPCalcOp1PolarCase $PolCase
    set PSPCalcOp1PolarType $PolType
    set PSPCalcOp1Type "matM"
    set PSPCalcOperand1 "herm matrix"
    if {$PSPCalcInputFormat == "S2"} { set PSPCalcOp1Type "matS"; set PSPCalcOperand1 "cmplx matrix"; set PSPCalcOp1MatDim 2}
    if {$PSPCalcInputFormat == "C2"} { set PSPCalcOp1MatDim 2}
    if {$PSPCalcInputFormat == "C3"} { set PSPCalcOp1MatDim 3}
    if {$PSPCalcInputFormat == "C4"} { set PSPCalcOp1MatDim 4}
    if {$PSPCalcInputFormat == "T2"} { set PSPCalcOp1MatDim 2}
    if {$PSPCalcInputFormat == "T3"} { set PSPCalcOp1MatDim 3}
    if {$PSPCalcInputFormat == "T4"} { set PSPCalcOp1MatDim 4}
    if {$PSPCalcInputFormat == "T6"} { set PSPCalcOp1MatDim 6}
    set NligInitOp1 $NligInitMat; set NligEndOp1 $NligEndMat
    set NcolInitOp1 $NcolInitMat; set NcolEndOp1 $NcolEndMat
    $PSPCalcOperatorNameEntry configure -disabledbackground #FFFFFF
    if {$PSPCalcOp1Type == "matM"} { PSPCalcOperatorMatMON }
    if {$PSPCalcOp1Type == "matS"} { PSPCalcOperatorMatSON }
    } else {
    if {$PSPCalcOp1Format == $PSPCalcInputFormat} {
        set PSPCalcOp2Name $PSPCalcInputDirMatFormat
        set PSPCalcOp2Format $PSPCalcInputFormat
        set PSPCalcOp2MatDirInput $PSPCalcInputDirMat
        set PSPCalcOp2PolarCase $PolCase
        set PSPCalcOp2PolarType $PolType
        set PSPCalcOp2Type "matM"
        set PSPCalcOperand2 "herm matrix"
        if {$PSPCalcInputFormat == "S2"} { set PSPCalcOp2Type "matS"; set PSPCalcOperand2 "cmplx matrix"; set PSPCalcOp2MatDim 2}
        if {$PSPCalcInputFormat == "C2"} { set PSPCalcOp2MatDim 2}
        if {$PSPCalcInputFormat == "C3"} { set PSPCalcOp2MatDim 3}
        if {$PSPCalcInputFormat == "C4"} { set PSPCalcOp2MatDim 4}
        if {$PSPCalcInputFormat == "T2"} { set PSPCalcOp2MatDim 2}
        if {$PSPCalcInputFormat == "T3"} { set PSPCalcOp2MatDim 3}
        if {$PSPCalcInputFormat == "T4"} { set PSPCalcOp2MatDim 4}
        if {$PSPCalcInputFormat == "T6"} { set PSPCalcOp2MatDim 6}
        set NligInitOp2 $NligInitMat; set NligEndOp2 $NligEndMat
        set NcolInitOp2 $NcolInitMat; set NcolEndOp2 $NcolEndMat
        $PSPCalcRunButton configure -state normal -background #FFFF00
        } else {
        set ErrorMessage "THE TWO MATRICES HAVE NOT THE SAME POLARIMETRIC TYPE"
        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcInputDirMatON
        }
    }
    
} else {
    set WarningMessage "INPUT POLARIMETRIC DATA FORMAT = DUAL-POL"
    set WarningMessage2 "USE INPUT OPERAND-1 TYPE = FILE"
    set VarWarning ""
    Window show $widget(Toplevel388); TextEditorRunTrace "Open Window Advice Warning" "b"
    tkwait variable VarWarning
    set VarWarning ""
}
PSPCalcInputDirMatOFF
}} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_5_0.cpd89" "PSPCalcOperatorFileButtonOK12" vTcl:WidgetProc "Toplevel600" 1
    frame $site_5_0.cpd92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame129" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd92
    frame $site_6_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd96" "Frame130" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd96
    entry $site_7_0.cpd93 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PSPCalcInputDirMat 
    vTcl:DefineAlias "$site_7_0.cpd93" "Entry12" vTcl:WidgetProc "Toplevel600" 1
    button $site_7_0.cpd94 \
        \
        -command {global PSPCalcInputFormat PSPCalcInputDirMat PSPCalcInputDirMatFormat
global NligInitMat NligEndMat NcolInitMat NcolEndMat PolCase PolType
global DirName PSPCalcDirInput PSPCalcMaskCmd
global VarError ErrorMessage
global TMPPSPCalcInputDirMatConfig TMPPSPCalcInputDirMatMapInfo TMPPSPCalcInputDirMatMaskFile

set NligInitMat ""
set NligEndMat ""
set NcolInitMat ""
set NcolEndMat ""
set PSPCalcInputFormat ""
set PSPCalcInputDirFormat ""
set PSPCalcInputDirMat ""
set PSPCalcInputDirMatFormat ""
set TMPPSPCalcInputDirMatConfig ""
set TMPPSPCalcInputDirMatMapInfo ""
set TMPPSPCalcInputDirMatMaskFile ""

set DirName ""
OpenDir $PSPCalcDirInput "DATA INPUT DIRECTORY"
if {$DirName != ""} {
    set PSPCalcInputDirMat $DirName
    if [file exists "$PSPCalcInputDirMat/config.txt"] {
        set ConfigFile "$PSPCalcInputDirMat/config.txt"
        set f [open $ConfigFile "r"]
        gets $f tmp
        gets $f NligEndMat 
        gets $f tmp
        gets $f tmp
        gets $f NcolEndMat 
        gets $f tmp
        gets $f tmp
        gets $f PolCase
        gets $f tmp
        gets $f tmp
        gets $f PolType
        close $f
        set configg "true"
        set config "false"
        if {$PolCase == "monostatic"} {set config "true"}
        if {$PolCase == "bistatic"} {set config "true"}
        if {$PolCase == "intensities"} {set config "true"}
        if {$config == "false"} {
            set VarFatalError ""
            set FatalErrorMessage "WRONG POLAR-CASE ARGUMENT IN CONFIG.TXT"
            .top236.fra34.cpd68 configure -state disable
            Window show .top236
            tkwait variable VarFatalError
            set configg "false"
            }
        set config "false"
        if {$PolType == "full"} {set config "true"}
        if {$PolType == "pp1"} {set config "true"}
        if {$PolType == "pp2"} {set config "true"}
        if {$PolType == "pp3"} {set config "true"}
        if {$PolType == "pp4"} {set config "true"}
        if {$PolType == "pp5"} {set config "true"}
        if {$PolType == "pp6"} {set config "true"}
        if {$PolType == "pp7"} {set config "true"}
        if {$config == "false"} {
            set VarFatalError ""
            set FatalErrorMessage "WRONG POLAR-TYPE ARGUMENT IN CONFIG.TXT"
            .top236.fra34.cpd68 configure -state disable
            Window show .top236
            tkwait variable VarFatalError
            set configg "false"
            }

        if {$configg == "true"} {
            set NligInitMat 1
            set NcolInitMat 1

            set MaskFile "$PSPCalcInputDirMat/mask_valid_pixels.bin"
            if [file exists $MaskFile] {
                set TMPPSPCalcInputDirMatMaskFile $MaskFile
                set PSPCalcMaskCmd "-mask \x22$MaskFile\x22"
                }

            if [file exists "$PSPCalcInputDirMat/config.txt"] { set TMPPSPCalcInputDirMatConfig "$PSPCalcInputDirMat/config.txt" }
            if [file exists "$PSPCalcInputDirMat/config_mapinfo.txt"] { set TMPPSPCalcInputDirMatMapInfo "$PSPCalcInputDirMat/config_mapinfo.txt" }

            if {$PolType == "full"} {
                if [file exists "$PSPCalcInputDirMat/T11.bin"] {
                    if [file exists "$PSPCalcInputDirMat/T66.bin"] {
                        set PSPCalcInputFormat "T6"; set PSPCalcInputDirMatFormat "6x6 Coherency Matrix"
                        } else {
                        if [file exists "$PSPCalcInputDirMat/T44.bin"] {
                            set PSPCalcInputFormat "T4"; set PSPCalcInputDirMatFormat "4x4 Coherency Matrix"
                            } else {
                            if [file exists "$PSPCalcInputDirMat/T33.bin"] {
                                set PSPCalcInputFormat "T3"; set PSPCalcInputDirMatFormat "3x3 Coherency Matrix"
                                } else {
                                if [file exists "$PSPCalcInputDirMat/T22.bin"] {
                                    set PSPCalcInputFormat "T2"; set PSPCalcInputDirMatFormat "2x2 Coherency Matrix"
                                    }
                                }
                            }
                        }
                    }
                if [file exists "$PSPCalcInputDirMat/C11.bin"] {
                    if [file exists "$PSPCalcInputDirMat/C44.bin"] {
                        set PSPCalcInputFormat "C4"; set PSPCalcInputDirMatFormat "4x4 Covariance Matrix"
                        } else {
                        if [file exists "$PSPCalcInputDirMat/C33.bin"] {
                            set PSPCalcInputFormat "C3"; set PSPCalcInputDirMatFormat "3x3 Covariance Matrix"
                            } else {
                            if [file exists "$PSPCalcInputDirMat/C22.bin"] {
                                set PSPCalcInputFormat "C2"; set PSPCalcInputDirMatFormat "2x2 Covariance Matrix"
                                }
                            }
                        }
                    }
                if [file exists "$PSPCalcInputDirMat/s11.bin"] {
                    if [file exists "$PSPCalcInputDirMat/s22.bin"] {
                        set PSPCalcInputFormat "S2"; set PSPCalcInputDirMatFormat "2x2 Sinclair Matrix"
                        }
                    }
                }    
            if {$PolType == "pp1"} {
                set PSPCalcInputDirMatFormat "Dual-Pol Elements (s11,s21)"
                }    
            if {$PolType == "pp2"} {
                set PSPCalcInputDirMatFormat "Dual-Pol Elements (s12,s22)"
                }    
            if {$PolType == "pp3"} {
                set PSPCalcInputDirMatFormat "Dual-Pol Elements (s11,s22)"
                }    
            if {$PolType == "pp4"} {
                set PSPCalcInputDirMatFormat "Intensity Elements (I11,I12,I21,I22)"
                }    
            if {$PolType == "pp5"} {
                set PSPCalcInputDirMatFormat "Dual-Pol Elements (I11,I21)"
                }    
            if {$PolType == "pp6"} {
                set PSPCalcInputDirMatFormat "Dual-Pol Elements (I12,I22)"
                }    
            if {$PolType == "pp7"} {
                set PSPCalcInputDirMatFormat "Dual-Pol Elements (I11,I22)"
                }    
            }
        } else {
        set ErrorMessage "NO CONFIG FILE"
        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set PSPCalcInputDirMat "SELECT THE INPUT POLARIMETRIC BINARY DATA DIRECTORY (MATRIX : S2, C2, C3, C4, T2, T3, T4)"
        }    
    } else {
    set PSPCalcInputDirMat "SELECT THE INPUT POLARIMETRIC BINARY DATA DIRECTORY (MATRIX : S2, C2, C3, C4, T2, T3, T4)"
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd94" "Button13" vTcl:WidgetProc "Toplevel600" 1
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    frame $site_6_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd95" "Frame131" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd95
    TitleFrame $site_7_0.tit97 \
        -ipad 2 -text {Input Matrix Data Format} 
    vTcl:DefineAlias "$site_7_0.tit97" "TitleFrame6" vTcl:WidgetProc "Toplevel600" 1
    bind $site_7_0.tit97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_9_0 [$site_7_0.tit97 getframe]
    entry $site_9_0.ent98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPCalcInputDirMatFormat -width 22 
    vTcl:DefineAlias "$site_9_0.ent98" "Entry13" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.ent98 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    label $site_7_0.lab99 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_7_0.lab99" "Label7" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.ent100 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInitMat -width 5 
    vTcl:DefineAlias "$site_7_0.ent100" "Entry14" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd102 \
        -text {End Row} 
    vTcl:DefineAlias "$site_7_0.cpd102" "Label8" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd105 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEndMat -width 5 
    vTcl:DefineAlias "$site_7_0.cpd105" "Entry15" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd103 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_7_0.cpd103" "Label9" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd106 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInitMat -width 5 
    vTcl:DefineAlias "$site_7_0.cpd106" "Entry16" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd104 \
        -text {End Col} 
    vTcl:DefineAlias "$site_7_0.cpd104" "Label10" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd107 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEndMat -width 5 
    vTcl:DefineAlias "$site_7_0.cpd107" "Entry17" vTcl:WidgetProc "Toplevel600" 1
    pack $site_7_0.tit97 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.lab99 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.ent100 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd102 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd105 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd103 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd106 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd104 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd107 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd89 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_3_0.fra109 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra109" "Frame125" vTcl:WidgetProc "Toplevel600" 1
    set site_4_0 $site_3_0.fra109
    TitleFrame $site_4_0.tit110 \
        -text {Input Value Type} 
    vTcl:DefineAlias "$site_4_0.tit110" "TitleFrame7" vTcl:WidgetProc "Toplevel600" 1
    bind $site_4_0.tit110 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit110 getframe]
    radiobutton $site_6_0.rad112 \
        \
        -command {global PSPCalcValueInputReal PSPCalcValueInputImag
global PSPBackgroundColor
global PSPCalcInputValueFrameTitle PSPCalcInputValueEntryReal PSPCalcInputValueEntryImag PSPCalcInputValueLabelJ

$PSPCalcInputValueEntryReal configure -state normal -disabledbackground #FFFFFF
$PSPCalcInputValueLabelJ configure -state normal
$PSPCalcInputValueEntryImag configure -state normal -disabledbackground #FFFFFF
set PSPCalcValueInputReal "?"
set PSPCalcValueInputImag "?"} \
        -text {Complex Value} -value cmplx -variable PSPCalcValueFormat 
    vTcl:DefineAlias "$site_6_0.rad112" "Radiobutton1" vTcl:WidgetProc "Toplevel600" 1
    radiobutton $site_6_0.cpd113 \
        \
        -command {global PSPCalcValueInputReal PSPCalcValueInputImag
global PSPBackgroundColor
global PSPCalcInputValueFrameTitle PSPCalcInputValueEntryReal PSPCalcInputValueEntryImag PSPCalcInputValueLabelJ

$PSPCalcInputValueEntryReal configure -state normal -disabledbackground #FFFFFF
$PSPCalcInputValueLabelJ configure -state disable
$PSPCalcInputValueEntryImag configure -state disable -disabledbackground $PSPBackgroundColor
set PSPCalcValueInputReal "?"
set PSPCalcValueInputImag ""} \
        -text {Float Value} -value float -variable PSPCalcValueFormat 
    vTcl:DefineAlias "$site_6_0.cpd113" "Radiobutton2" vTcl:WidgetProc "Toplevel600" 1
    radiobutton $site_6_0.cpd114 \
        \
        -command {global PSPCalcValueInputReal PSPCalcValueInputImag
global PSPBackgroundColor
global PSPCalcInputValueFrameTitle PSPCalcInputValueEntryReal PSPCalcInputValueEntryImag PSPCalcInputValueLabelJ

$PSPCalcInputValueEntryReal configure -state normal -disabledbackground #FFFFFF
$PSPCalcInputValueLabelJ configure -state disable
$PSPCalcInputValueEntryImag configure -state disable -disabledbackground $PSPBackgroundColor
set PSPCalcValueInputReal "?"
set PSPCalcValueInputImag ""} \
        -text {Integer Value} -value int -variable PSPCalcValueFormat 
    vTcl:DefineAlias "$site_6_0.cpd114" "Radiobutton3" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.rad112 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd113 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd114 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd111 \
        -text {Input Value} 
    vTcl:DefineAlias "$site_4_0.cpd111" "TitleFrame8" vTcl:WidgetProc "Toplevel600" 1
    bind $site_4_0.cpd111 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd111 getframe]
    frame $site_6_0.cpd115 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd115" "Frame167" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd115
    entry $site_7_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcValueInputReal -width 10 
    vTcl:DefineAlias "$site_7_0.ent90" "Entry65" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcValueInputImag -width 10 
    vTcl:DefineAlias "$site_7_0.cpd91" "Entry66" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_7_0.cpd93" "Label66" vTcl:WidgetProc "Toplevel600" 1
    pack $site_7_0.ent90 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd115 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    button $site_4_0.cpd116 \
        -background #ffff00 \
        -command {global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Format PSPCalcOp2ValueInputReal PSPCalcOp2ValueInputImag
global PSPCalcValueFormat PSPCalcValueInputReal PSPCalcValueInputImag

if {$PSPCalcValueInputReal == "" || $PSPCalcValueInputReal == "?"} {
PSPCalcInputValueOFF
set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
$PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
$PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
$PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
if {$PSPCalcOp1Type == "file"} { PSPCalcOperatorFileON }
if {$PSPCalcOp1Type == "matM"} { PSPCalcOperatorMatMON }
if {$PSPCalcOp1Type == "matS"} { PSPCalcOperatorMatSON }
if {$PSPCalcOp1Type == "matX"} { PSPCalcOperatorMatXON }

} else {

if {$PSPCalcOperand == "OP2"} {
    set PSPCalcOp2Format $PSPCalcValueFormat
    set PSPCalcOp2ValueInputReal $PSPCalcValueInputReal
    set PSPCalcOp2ValueInputImag $PSPCalcValueInputImag
    set PSPCalcOp2Name "Value = "
    if {$PSPCalcOp2Format == "cmplx"} {
        if {$PSPCalcValueInputImag == "" || $PSPCalcValueInputImag == "?"} { set PSPCalcValueInputImag 0 }
        set PSPCalcOperand2 "cmplx value"
        append PSPCalcOp2Name "$PSPCalcOp2ValueInputReal +j $PSPCalcOp2ValueInputImag"
        }
    if {$PSPCalcOp2Format == "float"} {
        set PSPCalcOperand2 "float value"
        append PSPCalcOp2Name "$PSPCalcOp2ValueInputReal"
        }
    if {$PSPCalcOp2Format == "int"} {
        set PSPCalcOperand2 "integer value"
        append PSPCalcOp2Name "$PSPCalcOp2ValueInputReal"
        }
    PSPCalcInputValueOFF
    $PSPCalcRunButton configure -state normal -background #FFFF00
    }
}} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_4_0.cpd116" "PSPCalcOperatorFileButtonOK13" vTcl:WidgetProc "Toplevel600" 1
    pack $site_4_0.tit110 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd116 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    TitleFrame $site_3_0.cpd66 \
        -ipad 2 -text {N x N Matrix} 
    vTcl:DefineAlias "$site_3_0.cpd66" "TitleFrame2" vTcl:WidgetProc "Toplevel600" 1
    bind $site_3_0.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd66 getframe]
    frame $site_5_0.fra71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra71" "Frame143" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.fra71
    button $site_6_0.cpd81 \
        -background #ffff00 \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOp2Name PSPCalcOperand2 PSPCalcOp2Type PSPCalcOp2Format PSPCalcOp2PolarCase PSPCalcOp2PolarType PSPCalcOp2MatDim PSPCalcOp2FileInput PSPCalcOp2MatDirInput
global PSPCalcOperand PSPCalcCreateMatXType TMPPSPCalcMatX1 TMPPSPCalcMatX2
global PSPCalcInputFormat PSPCalcInputDirMatFormat PSPCalcFileDirMat PSPCalcTestSUFlag 
global NligInitMat NligEndMat NcolInitMat NcolEndMat PolCase PolType
global NligInitOp1 NligEndOp1 NcolInitOp1 NcolEndOp1
global NligInitOp2 NligEndOp2 NcolInitOp2 NcolEndOp2
global WarningMessage WarningMessage2 VarWarning
global PSPCalcOperatorNameEntry PSPCalcOperatorButton
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i

if {$PSPCalcCreateMatXType != ""} {

if {$PSPCalcOperand == "OP1"} { set MatDim $PSPCalcOp1MatDim }
if {$PSPCalcOperand == "OP2"} { set MatDim $PSPCalcOp2MatDim }

set PSPCalcTestSUFlag "OK"
if {$PSPCalcCreateMatXType == "SU"} { PSPCalcTestSU $MatDim }

if {$PSPCalcTestSUFlag == "OK"} {


if {$PSPCalcOperand == "OP1"} {
    set NligInitOp1 1; set NcolInitOp1 1
    set NligEndOp1 $MatDim; set NcolEndOp1 $MatDim
    set PSPCalcOp1PolarCase ""
    set PSPCalcOp1PolarType ""
    set PSPCalcOp1Format $PSPCalcCreateMatXType
    set PSPCalcOp1MatDirInput ""
    set PSPCalcOp1FileInput $TMPPSPCalcMatX1
    set f [open $TMPPSPCalcMatX1 "w"]
    set PSPCalcOp1Name $MatDim; append PSPCalcOp1Name "x"; append PSPCalcOp1Name $MatDim
    if {$PSPCalcCreateMatXType == "cmplx"} {
        append PSPCalcOp1Name " Complex Matrix"
        set PSPCalcOperand1 "cmplx matrix"
        }
    if {$PSPCalcCreateMatXType == "float"} {
        append PSPCalcOp1Name " Float Matrix"
        set PSPCalcOperand1 "float matrix"
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        append PSPCalcOp1Name " Hermitian Matrix"
        set PSPCalcOperand1 "herm matrix"
        }
    if {$PSPCalcCreateMatXType == "SU"} {
        append PSPCalcOp1Name " Complex SU Matrix"
        set PSPCalcOperand1 "cmplx SU matrix"
        }
    $PSPCalcOperatorNameEntry configure -disabledbackground #FFFFFF
    PSPCalcOperatorMatXON
    } else {
    set NligInitOp2 1; set NcolInitOp2 1
    set NligEndOp2 $MatDim; set NcolEndOp2 $MatDim
    set PSPCalcOp2PolarCase ""
    set PSPCalcOp2PolarType ""
    set PSPCalcOp2Format $PSPCalcCreateMatXType
    set PSPCalcOp2MatDirInput ""
    set PSPCalcOp2FileInput $TMPPSPCalcMatX2
    set f [open $TMPPSPCalcMatX2 "w"]
    set PSPCalcOp2Name $MatDim; append PSPCalcOp2Name "x"; append PSPCalcOp2Name $MatDim
    if {$PSPCalcCreateMatXType == "cmplx"} {
        append PSPCalcOp2Name " Complex Matrix"
        set PSPCalcOperand2 "cmplx matrix"
        }
    if {$PSPCalcCreateMatXType == "float"} {
        append PSPCalcOp2Name " Float Matrix"
        set PSPCalcOperand2 "float matrix"
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        append PSPCalcOp2Name " Hermitian Matrix"
        set PSPCalcOperand2 "herm matrix"
        }
    if {$PSPCalcCreateMatXType == "SU"} {
        append PSPCalcOp2Name " Complex SU Matrix"
        set PSPCalcOperand2 "cmplx SU matrix"
        }
    $PSPCalcRunButton configure -state normal -background #FFFF00
    }
    puts $f "PolSARpro Calculator v1.0"
    puts $f $PSPCalcCreateMatXType
    puts $f $MatDim
    if {$MatDim == 4} {
    if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
        puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat14r; puts $f $PSPCalcCreateMat14i
        puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
        puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat24r; puts $f $PSPCalcCreateMat24i
        puts $f $PSPCalcCreateMat31r; puts $f $PSPCalcCreateMat31i
        puts $f $PSPCalcCreateMat32r; puts $f $PSPCalcCreateMat32i
        puts $f $PSPCalcCreateMat33r; puts $f $PSPCalcCreateMat33i
        puts $f $PSPCalcCreateMat34r; puts $f $PSPCalcCreateMat34i
        puts $f $PSPCalcCreateMat41r; puts $f $PSPCalcCreateMat41i
        puts $f $PSPCalcCreateMat42r; puts $f $PSPCalcCreateMat42i
        puts $f $PSPCalcCreateMat43r; puts $f $PSPCalcCreateMat43i
        puts $f $PSPCalcCreateMat44r; puts $f $PSPCalcCreateMat44i
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        puts $f $PSPCalcCreateMat11r;
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat14r; puts $f $PSPCalcCreateMat14i
        puts $f $PSPCalcCreateMat22r;
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat24r; puts $f $PSPCalcCreateMat24i
        puts $f $PSPCalcCreateMat33r;
        puts $f $PSPCalcCreateMat34r; puts $f $PSPCalcCreateMat34i
        puts $f $PSPCalcCreateMat44r;
        }
    if {$PSPCalcCreateMatXType == "float"} {
        puts $f $PSPCalcCreateMat11r
        puts $f $PSPCalcCreateMat12r
        puts $f $PSPCalcCreateMat13r
        puts $f $PSPCalcCreateMat14r
        puts $f $PSPCalcCreateMat21r
        puts $f $PSPCalcCreateMat22r
        puts $f $PSPCalcCreateMat23r
        puts $f $PSPCalcCreateMat24r
        puts $f $PSPCalcCreateMat31r
        puts $f $PSPCalcCreateMat32r
        puts $f $PSPCalcCreateMat33r
        puts $f $PSPCalcCreateMat34r
        puts $f $PSPCalcCreateMat41r
        puts $f $PSPCalcCreateMat42r
        puts $f $PSPCalcCreateMat43r
        puts $f $PSPCalcCreateMat44r
        }
    }
    if {$MatDim == 3} {
    if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
        puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
        puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat31r; puts $f $PSPCalcCreateMat31i
        puts $f $PSPCalcCreateMat32r; puts $f $PSPCalcCreateMat32i
        puts $f $PSPCalcCreateMat33r; puts $f $PSPCalcCreateMat33i
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        puts $f $PSPCalcCreateMat11r;
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat22r;
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat33r;
        }
    if {$PSPCalcCreateMatXType == "float"} {
        puts $f $PSPCalcCreateMat11r
        puts $f $PSPCalcCreateMat12r
        puts $f $PSPCalcCreateMat13r
        puts $f $PSPCalcCreateMat21r
        puts $f $PSPCalcCreateMat22r
        puts $f $PSPCalcCreateMat23r
        puts $f $PSPCalcCreateMat31r
        puts $f $PSPCalcCreateMat32r
        puts $f $PSPCalcCreateMat33r
        }
    }
    if {$MatDim == 2} {
    if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
        puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
        puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        puts $f $PSPCalcCreateMat11r;
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat22r;
        }
    if {$PSPCalcCreateMatXType == "float"} {
        puts $f $PSPCalcCreateMat11r
        puts $f $PSPCalcCreateMat12r
        puts $f $PSPCalcCreateMat21r
        puts $f $PSPCalcCreateMat22r
        }
    }
    close $f
    PSPCalcCreateMatXOFF
} else {
    set WarningMessage "THE $MatDim x $MatDim MATRIX"
    set WarningMessage2 "IS NOT A SU($MatDim) MATRIX"
    set VarWarning ""
    Window show $widget(Toplevel388); TextEditorRunTrace "Open Window Advice Warning" "b"
    tkwait variable VarWarning
    set VarWarning ""
    PSPCalcCreateMatXOFF
}

} else {
    set WarningMessage "SELECT THE DATA FORMAT FIRST"
    set WarningMessage2 "AND ENTER THE $MatDim x $MatDim MATRIX ELEMENTS"
    set VarWarning ""
    Window show $widget(Toplevel388); TextEditorRunTrace "Open Window Advice Warning" "b"
    tkwait variable VarWarning
    set VarWarning ""
    PSPCalcCreateMatXOFF
}} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_6_0.cpd81" "PSPCalcOperatorFileButtonOK8" vTcl:WidgetProc "Toplevel600" 1
    button $site_6_0.cpd82 \
        -background #ffff00 \
        -command {global FileName PSPCalcDirInput PSPCalcCreateMatXType
global PSPCalcOperand PSPCalcOp1MatDim PSPCalcOp2MatDim
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i
global OpenDirFile
global ErrorMessage VarError


if {$OpenDirFile == 0} {

if {$PSPCalcOperand == "OP1"} { set MatDim $PSPCalcOp1MatDim }
if {$PSPCalcOperand == "OP2"} { set MatDim $PSPCalcOp2MatDim }

set types {
{{TXT Files}        {.txt}        }
}
set FileName ""
OpenFile $PSPCalcDirInput $types "TXT INPUT FILE"
    
if {$FileName != ""} {
    set f [open $FileName "r"]
    gets $f tmp
    if {$tmp == "PolSARpro Calculator v1.0"} {
        gets $f PSPCalcCreateMatXType
        gets $f tmp
        if {$tmp == $MatDim} {
        if {$MatDim == "4"} {
            if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
                PSPCalcCreateMatXInitCmplx $MatDim
                gets $f PSPCalcCreateMat11r; gets $f PSPCalcCreateMat11i
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat14r; gets $f PSPCalcCreateMat14i
                gets $f PSPCalcCreateMat21r; gets $f PSPCalcCreateMat21i
                gets $f PSPCalcCreateMat22r; gets $f PSPCalcCreateMat22i
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat24r; gets $f PSPCalcCreateMat24i
                gets $f PSPCalcCreateMat31r; gets $f PSPCalcCreateMat31i
                gets $f PSPCalcCreateMat32r; gets $f PSPCalcCreateMat32i
                gets $f PSPCalcCreateMat33r; gets $f PSPCalcCreateMat33i
                gets $f PSPCalcCreateMat34r; gets $f PSPCalcCreateMat34i
                gets $f PSPCalcCreateMat41r; gets $f PSPCalcCreateMat41i
                gets $f PSPCalcCreateMat42r; gets $f PSPCalcCreateMat42i
                gets $f PSPCalcCreateMat43r; gets $f PSPCalcCreateMat43i
                gets $f PSPCalcCreateMat44r; gets $f PSPCalcCreateMat44i
                }
            if {$PSPCalcCreateMatXType == "float"} {
                PSPCalcCreateMatXInitFltInt $MatDim
                gets $f PSPCalcCreateMat11r
                gets $f PSPCalcCreateMat12r
                gets $f PSPCalcCreateMat13r
                gets $f PSPCalcCreateMat14r
                gets $f PSPCalcCreateMat21r
                gets $f PSPCalcCreateMat22r
                gets $f PSPCalcCreateMat23r
                gets $f PSPCalcCreateMat24r
                gets $f PSPCalcCreateMat31r
                gets $f PSPCalcCreateMat32r
                gets $f PSPCalcCreateMat33r
                gets $f PSPCalcCreateMat34r
                gets $f PSPCalcCreateMat41r
                gets $f PSPCalcCreateMat42r
                gets $f PSPCalcCreateMat43r
                gets $f PSPCalcCreateMat44r
                }
            if {$PSPCalcCreateMatXType == "herm"} {
                PSPCalcCreateMatXInitHerm $MatDim
                gets $f PSPCalcCreateMat11r;
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat14r; gets $f PSPCalcCreateMat14i
                gets $f PSPCalcCreateMat22r;
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat24r; gets $f PSPCalcCreateMat24i
                gets $f PSPCalcCreateMat33r;
                gets $f PSPCalcCreateMat34r; gets $f PSPCalcCreateMat34i
                gets $f PSPCalcCreateMat44r;
                }
            }
        if {$MatDim == "3"} {
            if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
                PSPCalcCreateMatXInitCmplx $MatDim
                gets $f PSPCalcCreateMat11r; gets $f PSPCalcCreateMat11i
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat21r; gets $f PSPCalcCreateMat21i
                gets $f PSPCalcCreateMat22r; gets $f PSPCalcCreateMat22i
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat31r; gets $f PSPCalcCreateMat31i
                gets $f PSPCalcCreateMat32r; gets $f PSPCalcCreateMat32i
                gets $f PSPCalcCreateMat33r; gets $f PSPCalcCreateMat33i
                }
            if {$PSPCalcCreateMatXType == "float"} {
                PSPCalcCreateMatXInitFltInt $MatDim
                gets $f PSPCalcCreateMat11r
                gets $f PSPCalcCreateMat12r
                gets $f PSPCalcCreateMat13r
                gets $f PSPCalcCreateMat21r
                gets $f PSPCalcCreateMat22r
                gets $f PSPCalcCreateMat23r
                gets $f PSPCalcCreateMat31r
                gets $f PSPCalcCreateMat32r
                gets $f PSPCalcCreateMat33r
                }
            if {$PSPCalcCreateMatXType == "herm"} {
                PSPCalcCreateMatXInitHerm $MatDim
                gets $f PSPCalcCreateMat11r;
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat13r; gets $f PSPCalcCreateMat13i
                gets $f PSPCalcCreateMat22r;
                gets $f PSPCalcCreateMat23r; gets $f PSPCalcCreateMat23i
                gets $f PSPCalcCreateMat33r;
                }
            }
        if {$MatDim == "2"} {
            if {$PSPCalcCreateMatXType == "cmplx" || $PSPCalcCreateMatXType == "SU"} {
                PSPCalcCreateMatXInitCmplx $MatDim
                gets $f PSPCalcCreateMat11r; gets $f PSPCalcCreateMat11i
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat21r; gets $f PSPCalcCreateMat21i
                gets $f PSPCalcCreateMat22r; gets $f PSPCalcCreateMat22i
                }
            if {$PSPCalcCreateMatXType == "float"} {
                PSPCalcCreateMatXInitFltInt $MatDim
                gets $f PSPCalcCreateMat11r
                gets $f PSPCalcCreateMat12r
                gets $f PSPCalcCreateMat21r
                gets $f PSPCalcCreateMat22r
                }
            if {$PSPCalcCreateMatXType == "herm"} {
                PSPCalcCreateMatXInitHerm $MatDim
                gets $f PSPCalcCreateMat11r;
                gets $f PSPCalcCreateMat12r; gets $f PSPCalcCreateMat12i
                gets $f PSPCalcCreateMat22r;
                }
            }
            } else {
            set ErrorMessage "THIS MATRIX IS NOT A $MatDim x $MatDim MATRIX"
            WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            PSPCalcCreateMatXRAZ
            }    
        } else {
        set ErrorMessage "NOT A PolSARpro Calculator BINARY DATA FILE"
        WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        PSPCalcCreateMatXRAZ
        }    
    close $f
    }
}} \
        -padx 4 -pady 2 -takefocus 0 -text Load 
    vTcl:DefineAlias "$site_6_0.cpd82" "PSPCalcOperatorFileButtonOK9" vTcl:WidgetProc "Toplevel600" 1
    button $site_6_0.cpd83 \
        -background #ffff00 \
        -command {global FileName PSPCalcDirInput PSPCalcCreateMatXType
global PSPCalcOperand PSPCalcOp1MatDim PSPCalcOp2MatDim
global PSPCalcCreateMat11r PSPCalcCreateMat11i PSPCalcCreateMat12r PSPCalcCreateMat12i
global PSPCalcCreateMat13r PSPCalcCreateMat13i PSPCalcCreateMat14r PSPCalcCreateMat14i
global PSPCalcCreateMat21r PSPCalcCreateMat21i PSPCalcCreateMat22r PSPCalcCreateMat22i
global PSPCalcCreateMat23r PSPCalcCreateMat23i PSPCalcCreateMat24r PSPCalcCreateMat24i
global PSPCalcCreateMat31r PSPCalcCreateMat31i PSPCalcCreateMat32r PSPCalcCreateMat32i
global PSPCalcCreateMat33r PSPCalcCreateMat33i PSPCalcCreateMat34r PSPCalcCreateMat34i
global PSPCalcCreateMat41r PSPCalcCreateMat41i PSPCalcCreateMat42r PSPCalcCreateMat42i
global PSPCalcCreateMat43r PSPCalcCreateMat43i PSPCalcCreateMat44r PSPCalcCreateMat44i
global OpenDirFile

if {$OpenDirFile == 0} {

if {$PSPCalcOperand == "OP1"} { set MatDim $PSPCalcOp1MatDim }
if {$PSPCalcOperand == "OP2"} { set MatDim $PSPCalcOp2MatDim }

if {$PSPCalcCreateMatXType != ""} {
set Types {
    {{TXT Files}        {.txt}        }
    }

if {$MatDim == 2} {
    if {$PSPCalcCreateMatXType == "SU"} {set FileNameTmp "CreateMatrix_2x2_cmplx_SU.txt"}
    if {$PSPCalcCreateMatXType == "cmplx"} {set FileNameTmp "CreateMatrix_2x2_cmplx.txt"}
    if {$PSPCalcCreateMatXType == "float"} {set FileNameTmp "CreateMatrix_2x2_float.txt"}
    if {$PSPCalcCreateMatXType == "herm"} {set FileNameTmp "CreateMatrix_2x2_herm.txt"}
    }
if {$MatDim == 3} {
    if {$PSPCalcCreateMatXType == "SU"} {set FileNameTmp "CreateMatrix_3x3_cmplx_SU.txt"}
    if {$PSPCalcCreateMatXType == "cmplx"} {set FileNameTmp "CreateMatrix_3x3_cmplx.txt"}
    if {$PSPCalcCreateMatXType == "float"} {set FileNameTmp "CreateMatrix_3x3_float.txt"}
    if {$PSPCalcCreateMatXType == "herm"} {set FileNameTmp "CreateMatrix_3x3_herm.txt"}
    }
if {$MatDim == 4} {
    if {$PSPCalcCreateMatXType == "SU"} {set FileNameTmp "CreateMatrix_4x4_cmplx_SU.txt"}
    if {$PSPCalcCreateMatXType == "cmplx"} {set FileNameTmp "CreateMatrix_4x4_cmplx.txt"}
    if {$PSPCalcCreateMatXType == "float"} {set FileNameTmp "CreateMatrix_4x4_float.txt"}
    if {$PSPCalcCreateMatXType == "herm"} {set FileNameTmp "CreateMatrix_4x4_herm.txt"}
    }
set FileName [tk_getSaveFile -initialdir $PSPCalcDirInput -filetypes $Types -title "TXT OUTPUT FILE" -defaultextension .txt -initialfile $FileNameTmp]
if {"$FileName" != ""} {
    set f [open $FileName "w"]
    puts $f "PolSARpro Calculator v1.0"
    puts $f $PSPCalcCreateMatXType
    puts $f $MatDim
    if {$MatDim == 4} {
    if {$PSPCalcCreateMatXType == "cmplx"||$PSPCalcCreateMatXType == "SU"} {
        puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat14r; puts $f $PSPCalcCreateMat14i
        puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
        puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat24r; puts $f $PSPCalcCreateMat24i
        puts $f $PSPCalcCreateMat31r; puts $f $PSPCalcCreateMat31i
        puts $f $PSPCalcCreateMat32r; puts $f $PSPCalcCreateMat32i
        puts $f $PSPCalcCreateMat33r; puts $f $PSPCalcCreateMat33i
        puts $f $PSPCalcCreateMat34r; puts $f $PSPCalcCreateMat34i
        puts $f $PSPCalcCreateMat41r; puts $f $PSPCalcCreateMat41i
        puts $f $PSPCalcCreateMat42r; puts $f $PSPCalcCreateMat42i
        puts $f $PSPCalcCreateMat43r; puts $f $PSPCalcCreateMat43i
        puts $f $PSPCalcCreateMat44r; puts $f $PSPCalcCreateMat44i
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        puts $f $PSPCalcCreateMat11r; 
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat14r; puts $f $PSPCalcCreateMat14i
        puts $f $PSPCalcCreateMat22r;
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat24r; puts $f $PSPCalcCreateMat24i
        puts $f $PSPCalcCreateMat33r;
        puts $f $PSPCalcCreateMat34r; puts $f $PSPCalcCreateMat34i
        puts $f $PSPCalcCreateMat44r;
        }
    if {$PSPCalcCreateMatXType == "float"} {
        puts $f $PSPCalcCreateMat11r
        puts $f $PSPCalcCreateMat12r
        puts $f $PSPCalcCreateMat13r
        puts $f $PSPCalcCreateMat14r
        puts $f $PSPCalcCreateMat21r
        puts $f $PSPCalcCreateMat22r
        puts $f $PSPCalcCreateMat23r
        puts $f $PSPCalcCreateMat24r
        puts $f $PSPCalcCreateMat31r
        puts $f $PSPCalcCreateMat32r
        puts $f $PSPCalcCreateMat33r
        puts $f $PSPCalcCreateMat34r
        puts $f $PSPCalcCreateMat41r
        puts $f $PSPCalcCreateMat42r
        puts $f $PSPCalcCreateMat43r
        puts $f $PSPCalcCreateMat44r
        }
    }
    if {$MatDim == 3} {
    if {$PSPCalcCreateMatXType == "cmplx"||$PSPCalcCreateMatXType == "SU"} {
        puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
        puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat31r; puts $f $PSPCalcCreateMat31i
        puts $f $PSPCalcCreateMat32r; puts $f $PSPCalcCreateMat32i
        puts $f $PSPCalcCreateMat33r; puts $f $PSPCalcCreateMat33i
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        puts $f $PSPCalcCreateMat11r; 
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat13r; puts $f $PSPCalcCreateMat13i
        puts $f $PSPCalcCreateMat22r;
        puts $f $PSPCalcCreateMat23r; puts $f $PSPCalcCreateMat23i
        puts $f $PSPCalcCreateMat33r;
        }
    if {$PSPCalcCreateMatXType == "float"} {
        puts $f $PSPCalcCreateMat11r
        puts $f $PSPCalcCreateMat12r
        puts $f $PSPCalcCreateMat13r
        puts $f $PSPCalcCreateMat21r
        puts $f $PSPCalcCreateMat22r
        puts $f $PSPCalcCreateMat23r
        puts $f $PSPCalcCreateMat31r
        puts $f $PSPCalcCreateMat32r
        puts $f $PSPCalcCreateMat33r
        }
    }
    if {$MatDim == 2} {
    if {$PSPCalcCreateMatXType == "cmplx"||$PSPCalcCreateMatXType == "SU"} {
        puts $f $PSPCalcCreateMat11r; puts $f $PSPCalcCreateMat11i
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat21r; puts $f $PSPCalcCreateMat21i
        puts $f $PSPCalcCreateMat22r; puts $f $PSPCalcCreateMat22i
        }
    if {$PSPCalcCreateMatXType == "herm"} {
        puts $f $PSPCalcCreateMat11r; 
        puts $f $PSPCalcCreateMat12r; puts $f $PSPCalcCreateMat12i
        puts $f $PSPCalcCreateMat22r;
        }
    if {$PSPCalcCreateMatXType == "float"} {
        puts $f $PSPCalcCreateMat11r
        puts $f $PSPCalcCreateMat12r
        puts $f $PSPCalcCreateMat21r
        puts $f $PSPCalcCreateMat22r
        }
    }
    close $f
    }
}
}} \
        -padx 4 -pady 2 -takefocus 0 -text Save 
    vTcl:DefineAlias "$site_6_0.cpd83" "PSPCalcOperatorFileButtonOK10" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 3 -side top 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame144" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd72
    frame $site_6_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame145" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd75
    radiobutton $site_7_0.rad85 \
        \
        -command {global PSPCalcOperand PSPCalcOp1MatDim PSPCalcOp2MatDim

PSPCalcCreateMatXRAZ
if {$PSPCalcOperand == "OP1"} { PSPCalcCreateMatXInitCmplx $PSPCalcOp1MatDim }
if {$PSPCalcOperand == "OP2"} { PSPCalcCreateMatXInitCmplx $PSPCalcOp2MatDim }} \
        -text Complex -value cmplx -variable PSPCalcCreateMatXType 
    vTcl:DefineAlias "$site_7_0.rad85" "Radiobutton5" vTcl:WidgetProc "Toplevel600" 1
    radiobutton $site_7_0.cpd86 \
        \
        -command {global PSPCalcOperand PSPCalcOp1MatDim PSPCalcOp2MatDim

PSPCalcCreateMatXRAZ
if {$PSPCalcOperand == "OP1"} { PSPCalcCreateMatXInitFltInt $PSPCalcOp1MatDim }
if {$PSPCalcOperand == "OP2"} { PSPCalcCreateMatXInitFltInt $PSPCalcOp2MatDim }} \
        -text Float -value float -variable PSPCalcCreateMatXType 
    vTcl:DefineAlias "$site_7_0.cpd86" "Radiobutton6" vTcl:WidgetProc "Toplevel600" 1
    radiobutton $site_7_0.cpd87 \
        \
        -command {global PSPCalcOperand PSPCalcOp1MatDim PSPCalcOp2MatDim

PSPCalcCreateMatXRAZ
if {$PSPCalcOperand == "OP1"} { PSPCalcCreateMatXInitHerm $PSPCalcOp1MatDim }
if {$PSPCalcOperand == "OP2"} { PSPCalcCreateMatXInitHerm $PSPCalcOp2MatDim }} \
        -text Hermitian -value herm -variable PSPCalcCreateMatXType 
    vTcl:DefineAlias "$site_7_0.cpd87" "Radiobutton7" vTcl:WidgetProc "Toplevel600" 1
    radiobutton $site_7_0.cpd88 \
        \
        -command {global PSPCalcOperand PSPCalcOp1MatDim PSPCalcOp2MatDim

PSPCalcCreateMatXRAZ
if {$PSPCalcOperand == "OP1"} { PSPCalcCreateMatXInitCmplx $PSPCalcOp1MatDim }
if {$PSPCalcOperand == "OP2"} { PSPCalcCreateMatXInitCmplx $PSPCalcOp2MatDim }} \
        -text {Special Unitary} -value SU -variable PSPCalcCreateMatXType 
    vTcl:DefineAlias "$site_7_0.cpd88" "Radiobutton8" vTcl:WidgetProc "Toplevel600" 1
    pack $site_7_0.rad85 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd86 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd87 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd77" "Frame146" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd77
    frame $site_7_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd80" "Frame147" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd80
    frame $site_8_0.fra89 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra89" "Frame148" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.fra89
    label $site_9_0.cpd106 \
        -text m11 
    vTcl:DefineAlias "$site_9_0.cpd106" "Label33" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat11r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry33" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat11i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry34" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label34" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd106 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd94" "Frame149" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd94
    label $site_9_0.cpd105 \
        -text m21 
    vTcl:DefineAlias "$site_9_0.cpd105" "Label35" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat21r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry35" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat21i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry36" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label36" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd105 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd95" "Frame150" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd95
    label $site_9_0.cpd104 \
        -text m31 
    vTcl:DefineAlias "$site_9_0.cpd104" "Label37" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat31r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry37" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat31i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry38" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label38" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd104 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd96" "Frame151" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd96
    label $site_9_0.cpd103 \
        -text m41 
    vTcl:DefineAlias "$site_9_0.cpd103" "Label39" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat41r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry39" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat41i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry40" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label40" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd103 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra89 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd94 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd95 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd96 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    frame $site_7_0.cpd119 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd119" "Frame152" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd119
    frame $site_8_0.fra89 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra89" "Frame153" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.fra89
    label $site_9_0.cpd106 \
        -text m12 
    vTcl:DefineAlias "$site_9_0.cpd106" "Label41" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat12r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry41" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat12i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry42" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label42" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd106 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd94" "Frame154" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd94
    label $site_9_0.cpd105 \
        -text m22 
    vTcl:DefineAlias "$site_9_0.cpd105" "Label43" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat22r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry43" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat22i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry44" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label44" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd105 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd95" "Frame155" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd95
    label $site_9_0.cpd104 \
        -text m32 
    vTcl:DefineAlias "$site_9_0.cpd104" "Label45" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat32r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry45" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat32i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry46" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label46" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd104 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd96" "Frame156" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd96
    label $site_9_0.cpd103 \
        -text m42 
    vTcl:DefineAlias "$site_9_0.cpd103" "Label47" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat42r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry47" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat42i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry48" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label48" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd103 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra89 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd94 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd95 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd96 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    frame $site_7_0.cpd120 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd120" "Frame157" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd120
    frame $site_8_0.fra89 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra89" "Frame158" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.fra89
    label $site_9_0.cpd106 \
        -text m13 
    vTcl:DefineAlias "$site_9_0.cpd106" "Label49" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat13r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry49" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat13i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry50" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label50" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd106 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd94" "Frame159" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd94
    label $site_9_0.cpd105 \
        -text m23 
    vTcl:DefineAlias "$site_9_0.cpd105" "Label51" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat23r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry51" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat23i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry52" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label52" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd105 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd95" "Frame160" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd95
    label $site_9_0.cpd104 \
        -text m33 
    vTcl:DefineAlias "$site_9_0.cpd104" "Label53" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat33r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry53" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat33i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry54" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label54" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd104 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd96" "Frame161" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd96
    label $site_9_0.cpd103 \
        -text m43 
    vTcl:DefineAlias "$site_9_0.cpd103" "Label55" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat43r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry55" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat43i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry56" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label56" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd103 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra89 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd94 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd95 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd96 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    frame $site_7_0.cpd121 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd121" "Frame162" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd121
    frame $site_8_0.fra89 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra89" "Frame163" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.fra89
    label $site_9_0.cpd106 \
        -text m14 
    vTcl:DefineAlias "$site_9_0.cpd106" "Label57" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat14r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry57" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat14i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry58" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label58" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd106 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd94" "Frame164" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd94
    label $site_9_0.cpd105 \
        -text m24 
    vTcl:DefineAlias "$site_9_0.cpd105" "Label59" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat24r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry59" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat24i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry60" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label60" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd105 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd95" "Frame165" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd95
    label $site_9_0.cpd104 \
        -text m34 
    vTcl:DefineAlias "$site_9_0.cpd104" "Label61" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat34r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry61" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat34i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry62" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label62" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd104 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd96" "Frame166" vTcl:WidgetProc "Toplevel600" 1
    set site_9_0 $site_8_0.cpd96
    label $site_9_0.cpd103 \
        -text m44 
    vTcl:DefineAlias "$site_9_0.cpd103" "Label63" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.ent90 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat44r -width 5 
    vTcl:DefineAlias "$site_9_0.ent90" "Entry63" vTcl:WidgetProc "Toplevel600" 1
    entry $site_9_0.cpd91 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcCreateMat44i -width 5 
    vTcl:DefineAlias "$site_9_0.cpd91" "Entry64" vTcl:WidgetProc "Toplevel600" 1
    label $site_9_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_9_0.cpd93" "Label64" vTcl:WidgetProc "Toplevel600" 1
    pack $site_9_0.cpd103 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -pady 1 \
        -side left 
    pack $site_9_0.ent90 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd91 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd93 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra89 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd94 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd95 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_8_0.cpd96 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd119 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd120 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd121 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra71 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_3_0.cpd121 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd121" "Frame132" vTcl:WidgetProc "Toplevel600" 1
    set site_4_0 $site_3_0.cpd121
    TitleFrame $site_4_0.cpd111 \
        -text {Output Value} 
    vTcl:DefineAlias "$site_4_0.cpd111" "TitleFrame10" vTcl:WidgetProc "Toplevel600" 1
    bind $site_4_0.cpd111 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd111 getframe]
    frame $site_6_0.cpd115 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd115" "Frame169" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd115
    entry $site_7_0.ent90 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable PSPCalcValueOutputReal -width 10 
    vTcl:DefineAlias "$site_7_0.ent90" "Entry67" vTcl:WidgetProc "Toplevel600" 1
    entry $site_7_0.cpd91 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable PSPCalcValueOutputImag -width 10 
    vTcl:DefineAlias "$site_7_0.cpd91" "Entry68" vTcl:WidgetProc "Toplevel600" 1
    label $site_7_0.cpd93 \
        -text { +j } 
    vTcl:DefineAlias "$site_7_0.cpd93" "Label67" vTcl:WidgetProc "Toplevel600" 1
    pack $site_7_0.ent90 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd115 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame170" vTcl:WidgetProc "Toplevel600" 1
    set site_5_0 $site_4_0.cpd66
    button $site_5_0.cpd81 \
        -background #ffff00 \
        -command {global PSPCalcOp1Name PSPCalcOperand1 PSPCalcOp1Type PSPCalcOp1Format PSPCalcOp1PolarCase PSPCalcOp1PolarType PSPCalcOp1MatDim
global PSPCalcOp1FileInput PSPCalcOp1MatDirInput
global PSPCalcOutputFormat PSPCalcOutputType PSPCalcOperator
global PSPCalcOutputResultDir PSPCalcOutputResultFile
global PSPCalcOutputResultFileCmplx PSPCalcOutputResultFileFloat PSPCalcOutputResultFileInt
global PSPCalcStoButton PSPCalcRclButton PSPCalcMcButton
global PSPCalcOutput PSPCalcOp1Type

PSPCalcDefineOutput
PSPCalcCleanResultDir $PSPCalcOutput
if {$PSPCalcOp1Type =="file"} { PSPCalcRunFile $PSPCalcOutput }
if {$PSPCalcOp1Type =="matM"} { PSPCalcRunMatM $PSPCalcOutput }
if {$PSPCalcOp1Type =="matS"} { PSPCalcRunMatS $PSPCalcOutput }
if {$PSPCalcOp1Type =="matX"} { PSPCalcRunMatX }

PSPCalcRAZButton
PSPCalcOperatorFileOFF
PSPCalcOperatorMatSOFF
PSPCalcOperatorMatMOFF
PSPCalcOperatorMatXOFF

if {$PSPCalcOutputType != "value"} {
set PSPCalcOp1Type $PSPCalcOutputType
set PSPCalcOp1Format $PSPCalcOutputFormat
set PSPCalcOp1FileInput $PSPCalcOutputResultFile
set PSPCalcOp1MatDirInput $PSPCalcOutputResultDir

if {$PSPCalcOp1Format == "int"} {set PSPCalcOperand1 "integer type"}
if {$PSPCalcOp1Format == "float"} {set PSPCalcOperand1 "float type"}
if {$PSPCalcOp1Format == "cmplx"} {set PSPCalcOperand1 "complex type"}
if {$PSPCalcOp1Format == "herm"} {set PSPCalcOperand1 "hermitian type"}
if {$PSPCalcOp1Format == "SU"} {set PSPCalcOperand1 "special unitary type"}

if {$PSPCalcOp1Type == "file" } { set PSPCalcOp1Name "ANS = Result File"; PSPCalcOperatorFileON }
if {$PSPCalcOp1Type == "matM" } { set PSPCalcOp1Name "ANS = Result Mat M"; PSPCalcOperatorMatMON }
if {$PSPCalcOp1Type == "matS" } { set PSPCalcOp1Name "ANS = Result Mat S"; PSPCalcOperatorMatSON }
if {$PSPCalcOp1Type == "matX" } { set PSPCalcOp1Name "ANS = Result Mat X"; PSPCalcOperatorMatXON }

if {$PSPCalcOp1Type != "matX" } { $PSPCalcSaveButton configure -state normal -background #FFFF00 }

#Memory
$PSPCalcStoButton configure -state normal
$PSPCalcRclButton configure -state normal
$PSPCalcMcButton configure -state normal
} else {
if {$PSPCalcOp1Format == "int"} {set PSPCalcOperand1 "integer type"}
if {$PSPCalcOp1Format == "float"} {set PSPCalcOperand1 "float type"}
if {$PSPCalcOp1Format == "cmplx"} {set PSPCalcOperand1 "complex type"}
set PSPCalcOp1Name "ANS = Output Value"
set PSPCalcOp1Type ""
set PSPCalcOp1Format ""
set PSPCalcOp1FileInput ""
set PSPCalcOp1MatDirInput ""
}} \
        -padx 4 -pady 2 -takefocus 0 -text Exec 
    vTcl:DefineAlias "$site_5_0.cpd81" "PSPCalcOperatorFileButtonOK18" vTcl:WidgetProc "Toplevel600" 1
    button $site_5_0.cpd83 \
        -background #ffff00 \
        -command {global OpenDirFile DataDir
global PSPCalcOutputType PSPCalcOutputFormat PSPCalcOutputResultFile PSPCalcOutputResultDir
global FileNameSourceCopy FileNameTargetCopy FileNameTargetCopyDir FileNameTargetCopyName
global DirNameSourceCopy DirNameTargetCopy SubDirNameTargetCopy

if {$OpenDirFile == 0} {

if {$PSPCalcOutputType == "file" } { 
    set FileNameSourceCopy $PSPCalcOutputResultFile
    set FileNameTargetCopyDir $DataDir
    set FileNameTargetCopyName "PolSARpro_Calculator_Output_File"
    WidgetShow $widget(Toplevel601); TextEditorRunTrace "Open Window PolSARpro Calculator v1.0 : Save File" "b"
    } else {
    set DirNameSourceCopy $PSPCalcOutputResultDir
    set DirNameTargetCopy $DataDir; append DirNameTargetCopy "_CALC"
    set SubDirNameTargetCopy ""
    if {$PSPCalcOutputFormat != "S2"} { set SubDirNameTargetCopy $PSPCalcOutputFormat }
    WidgetShow $widget(Toplevel602); TextEditorRunTrace "Open Window PolSARpro Calculator v1.0 : Save Polarimetric Matrix" "b"
    }
}} \
        -padx 4 -pady 2 -takefocus 0 -text Save 
    vTcl:DefineAlias "$site_5_0.cpd83" "PSPCalcOperatorFileButtonOK19" vTcl:WidgetProc "Toplevel600" 1
    button $site_5_0.cpd82 \
        -background #ff8000 \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -padx 4 -pady 2 -takefocus 0 
    vTcl:DefineAlias "$site_5_0.cpd82" "PSPCalcOperatorFileButtonOK20" vTcl:WidgetProc "Toplevel600" 1
    button $site_5_0.cpd120 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel601)
Window hide $widget(Toplevel602)
Window hide $widget(Toplevel603)
Window hide $widget(Toplevel600); TextEditorRunTrace "Close Window PolSARpro Calculator v1.0" "b"
}} \
        -padx 4 -pady 2 -takefocus 0 -text Exit 
    vTcl:DefineAlias "$site_5_0.cpd120" "PSPCalcOperatorFileButtonOK21" vTcl:WidgetProc "Toplevel600" 1
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 3 -side left 
    pack $site_5_0.cpd120 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill x -ipady 5 -padx 20 \
        -side left 
    pack $site_3_0.lab78 \
        -in $site_3_0 -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $site_3_0.fra79 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.fra66 \
        -in $site_3_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $site_3_0.tit86 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd108 \
        -in $site_3_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $site_3_0.fra109 \
        -in $site_3_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd121 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd68 \
        -borderwidth 2 -height 75 -width 100 
    vTcl:DefineAlias "$top.cpd68" "Frame2" vTcl:WidgetProc "Toplevel600" 1
    set site_3_0 $top.cpd68
    TitleFrame $site_3_0.tit69 \
        -text {Operator : File} 
    vTcl:DefineAlias "$site_3_0.tit69" "PSPCalcOperatorFileTitleFrame1" vTcl:WidgetProc "Toplevel600" 1
    bind $site_3_0.tit69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit69 getframe]
    frame $site_5_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame3" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd70
    frame $site_6_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame5" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame9" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file) + value} -value addval -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton33" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame10" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file) .+ (file)} -value addfile -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton34" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame11" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. real ( . )} -value real -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton35" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame12" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. cos ( . )} -value cos -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton36" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame13" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. acos ( . )} -value acos -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton37" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame14" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. sqrt ( . )} -value sqrt -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton38" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd97 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd97" "Frame15" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd97
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. log ( | . | )} -value log -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton39" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd98 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd98" "Frame16" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd98
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. 10log ( | . | )} -value 10log -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton40" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd97 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd98 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd99 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd99" "Frame6" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd99
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame17" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file)  - value} -value subval -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton41" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file) .- (file)} -value subfile -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton42" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame19" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. imag ( . )} -value imag -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton43" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame20" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. sin ( . )} -value sin -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton44" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame21" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. asin ( . )} -value asin -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton45" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame22" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. ( . )^2} -value x2 -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton46" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd97 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd97" "Frame23" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd97
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. ln ( | . | )} -value ln -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton47" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd98 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd98" "Frame24" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd98
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. 20log ( | . | )} -value 20log -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton48" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd97 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd98 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd100 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd100" "Frame7" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd100
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame25" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file) * value} -value mulval -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton49" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file) .* (file)} -value mulfile -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton50" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame27" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. arg ( . )} -value arg -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton51" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame28" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. tan ( . )} -value tan -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton52" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame29" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. atan ( . )} -value atan -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton53" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame30" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. ( . )^3} -value x3 -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton54" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd97 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd97" "Frame31" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd97
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. 10^( . )} -value 10x -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton55" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd98 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd98" "Frame32" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd98
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. ( . ) < ( ? )} -value inf -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton56" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd97 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd98 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd101 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd101" "Frame8" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd101
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame33" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file) / value} -value divval -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton57" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame34" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {(file) ./ (file)} -value divfile -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton58" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame35" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. abs ( . )} -value abs -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton59" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame36" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. conj ( . )} -value conj -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton60" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame37" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. filter ( ?x? )} -value filter -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton61" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame38" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. ( . )^( ? )} -value xy -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton62" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd97 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd97" "Frame39" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd97
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. exp ( . )} -value exp -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton63" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd98 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd98" "Frame40" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd98
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorFileRAZ -takefocus 0 \
        -text {. ( . ) > ( ? )} -value sup -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton64" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd97 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd98 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd99 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd100 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame4" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.but84 \
        -background #ffff00 \
        -command {global PSPCalcOperatorF PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton
global PSPCalcOp1Format
global VarError ErrorMessage PSPMemory TMPMemoryAllocError

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

if {$PSPCalcOperatorF == "addval"} {set PSPCalcOperatorName "(file) + value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorF == "subval"} {set PSPCalcOperatorName "(file) - value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorF == "mulval"} {set PSPCalcOperatorName "(file) * value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorF == "divval"} {set PSPCalcOperatorName "(file) / value"; set PSPCalcOp2Type "value"}

if {$PSPCalcOperatorF == "xy"} {set PSPCalcOperatorName ".(.)^(?)"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorF == "inf"} {set PSPCalcOperatorName ".(.) < (?)"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorF == "sup"} {set PSPCalcOperatorName ".(.) > (?)"; set PSPCalcOp2Type "valuefloat"}

if {$PSPCalcOperatorF == "filter"} {set PSPCalcOperatorName ".filter(?x?)"; set PSPCalcOp2Type "filter"}

if {$PSPCalcOperatorF == "addfile"} {set PSPCalcOperatorName "(file)  .+  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorF == "subfile"} {set PSPCalcOperatorName "(file)  .-  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorF == "mulfile"} {set PSPCalcOperatorName "(file)  .*  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorF == "divfile"} {set PSPCalcOperatorName "(file)  ./  (file)"; set PSPCalcOp2Type "file"}

if {$PSPCalcOperatorF == "real"} {set PSPCalcOperatorName ".real(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "imag"} {set PSPCalcOperatorName ".imag(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "arg"} {set PSPCalcOperatorName ".arg(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "abs"} {set PSPCalcOperatorName ".abs(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "cos"} {set PSPCalcOperatorName ".cos(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "sin"} {set PSPCalcOperatorName ".sin(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "tan"} {set PSPCalcOperatorName ".tan(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "conj"} {set PSPCalcOperatorName ".conj(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "acos"} {set PSPCalcOperatorName ".acos(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "asin"} {set PSPCalcOperatorName ".asin(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "atan"} {set PSPCalcOperatorName ".atan(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "sqrt"} {set PSPCalcOperatorName ".sqrt(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "x2"} {set PSPCalcOperatorName ".(.)^2"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "x3"} {set PSPCalcOperatorName ".(.)^3"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "log"} {set PSPCalcOperatorName ".log(|.|)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "ln"} {set PSPCalcOperatorName ".ln(|.|)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "10x"} {set PSPCalcOperatorName ".10^(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "exp"} {set PSPCalcOperatorName ".exp(.)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "10log"} {set PSPCalcOperatorName ".10log(|.|)"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorF == "20log"} {set PSPCalcOperatorName ".20log(|.|)"; set PSPCalcOp2Type ""}

set config "true"
if {$PSPCalcOp1Format == "cmplx"} {
  if {$PSPCalcOperatorF == "acos" } { set config "false" }
  if {$PSPCalcOperatorF == "asin" } { set config "false" }
  if {$PSPCalcOperatorF == "atan" } { set config "false" }
  if {$PSPCalcOperatorF == "xy" } { set config "false" }
  if {$PSPCalcOperatorF == "inf" } { set config "false" }
  if {$PSPCalcOperatorF == "sup" } { set config "false" }
  if {$PSPCalcOperatorF == "filter" } { set config "false" }
  }

if {$config == "true"} {
if {$PSPCalcOperatorF != ""} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type != ""} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        $PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
        PSPCalcInitOperand2
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        $PSPCalcRunButton configure -state normal -background #FFFF00
        }
    }
    }
} else {
set ErrorMessage "OPERATOR NOT COMPATIBLE WITH COMPLEX TYPE"
WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
PSPCalcRAZButton
}} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_6_0.but84" "PSPCalcOperatorFileButtonOK1" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.but84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_3_0.cpd67 \
        -text {Operator : Sinclair Matrix : S2} 
    vTcl:DefineAlias "$site_3_0.cpd67" "PSPCalcOperatorFileTitleFrame2" vTcl:WidgetProc "Toplevel600" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame41" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd70
    frame $site_6_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame42" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame43" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] + value} -value addval -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton65" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame44" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .+ (file)} -value addfile -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton66" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame45" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .+ [ S' ]} -value addmatS -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton67" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame46" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .* [ S ]*} -value graves -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton68" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame47" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. conj [ S ]} -value conj -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton69" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame48" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. eig1 [ S ]} -value eig1S -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton70" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd99 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd99" "Frame51" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd99
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame52" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ]  - value} -value subval -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton73" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame53" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .- (file)} -value subfile -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton74" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame54" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .+ [ mat ]} -value addmatX -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton75" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame55" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ U ]t .* [ S ] .* [ U]} -value consimilarity \
        -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton76" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame56" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. tr [ S ]} -value tr -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton77" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame57" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. eig2 [ S ]} -value eig2S -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton78" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd100 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd100" "Frame60" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd100
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame61" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] * value} -value mulval -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton81" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame62" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .* (file)} -value mulfile -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton82" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame63" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .* [ S' ]} -value mulmatS -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton83" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame64" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -state disabled -takefocus 0 -value null \
        -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton84" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame65" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. det [ S ]} -value det -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton85" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame66" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. eig1 [ G ]} -value eig1G -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton86" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd101 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd101" "Frame69" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd101
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame70" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] / value} -value divval -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton89" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame71" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] ./ (file)} -value divfile -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton90" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame72" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {[ S ] .* [ mat ]} -value mulmatX -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton91" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame73" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -state disabled -takefocus 0 -value null \
        -variable PSPCalcOperatorF 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton92" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame74" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. inv [ S ]} -value inv -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton93" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd96 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame75" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd96
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatSRAZ -takefocus 0 \
        -text {. eig2 [ G ]} -value eig2G -variable PSPCalcOperatorS 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton94" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd99 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd100 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame78" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.but84 \
        -background #ffff00 \
        -command {global PSPCalcOperatorS PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

if {$PSPCalcOperatorS == "addval"} {set PSPCalcOperatorName "\[ S \] + value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorS == "subval"} {set PSPCalcOperatorName "\[ S \] - value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorS == "mulval"} {set PSPCalcOperatorName "\[ S \] * value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorS == "divval"} {set PSPCalcOperatorName "\[ S \] / value"; set PSPCalcOp2Type "value"}

if {$PSPCalcOperatorS == "addfile"} {set PSPCalcOperatorName "\[ S \]  .+  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorS == "subfile"} {set PSPCalcOperatorName "\[ S \]  .-  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorS == "mulfile"} {set PSPCalcOperatorName "\[ S \]  .*  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorS == "divfile"} {set PSPCalcOperatorName "\[ S \]  ./  (file)"; set PSPCalcOp2Type "file"}

if {$PSPCalcOperatorS == "addmatS"} {set PSPCalcOperatorName "\[ S \]  .+  \[ S' \]"; set PSPCalcOp2Type "matS"}
if {$PSPCalcOperatorS == "mulmatS"} {set PSPCalcOperatorName "\[ S \]  .*  \[ S' \]"; set PSPCalcOp2Type "matS"}

if {$PSPCalcOperatorS == "addmatX"} {set PSPCalcOperatorName "\[ S \]  .+  \[ mat \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorS == "mulmatX"} {set PSPCalcOperatorName "\[ S \]  .*  \[ mat \]"; set PSPCalcOp2Type "matX"}

if {$PSPCalcOperatorS == "consimilarity"} {set PSPCalcOperatorName "\[ U \]t  .*  \[ S \]  .*  \[ U \]"; set PSPCalcOp2Type "matXSU"}

if {$PSPCalcOperatorS == "graves"} {set PSPCalcOperatorName "\[ S \]  .*  \[ S \]*"; set PSPCalcOp2Type "out_matS"}
if {$PSPCalcOperatorS == "conj"} {set PSPCalcOperatorName ".conj \[ S \]"; set PSPCalcOp2Type "out_matS"}
if {$PSPCalcOperatorS == "inv"} {set PSPCalcOperatorName ".inv \[ S \]"; set PSPCalcOp2Type "out_matS"}
if {$PSPCalcOperatorS == "det"} {set PSPCalcOperatorName ".det \[ S \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorS == "tr"} {set PSPCalcOperatorName ".tr \[ S \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorS == "eig1S"} {set PSPCalcOperatorName ".eig1 \[ S \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorS == "eig2S"} {set PSPCalcOperatorName ".eig2 \[ S \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorS == "eig1G"} {set PSPCalcOperatorName ".eig1 \[ G \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorS == "eig2G"} {set PSPCalcOperatorName ".eig2 \[ G \]"; set PSPCalcOp2Type "out_eig"}

if {$PSPCalcOperatorS != ""} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type == "value" || $PSPCalcOp2Type == "file" || $PSPCalcOp2Type == "matS" || $PSPCalcOp2Type == "matX" || $PSPCalcOp2Type == "matXSU"} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        $PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
        PSPCalcInitOperand2
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        $PSPCalcRunButton configure -state normal -background #FFFF00
        }
    }
    }} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_6_0.but84" "PSPCalcOperatorFileButtonOK2" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.but84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_3_0.cpd68 \
        -text {Operator : Hermitian Matrix : C2, C3, C4, T2, T3, T4} 
    vTcl:DefineAlias "$site_3_0.cpd68" "PSPCalcOperatorFileTitleFrame3" vTcl:WidgetProc "Toplevel600" 1
    bind $site_3_0.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    frame $site_5_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame49" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd70
    frame $site_6_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame50" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame58" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] + value} -value addval -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton71" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame59" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] .+ (file)} -value addfile -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton72" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame67" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] .+ [ M' ]} -value addmatM -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton79" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame68" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. conj [ M ]} -value conj -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton80" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame76" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. eig1 [ M ]} -value eig1 -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton87" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd99 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd99" "Frame79" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd99
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame80" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ]  - value} -value subval -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton95" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame81" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] .- (file)} -value subfile -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton96" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame82" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] .+ [ mat ]} -value addmatX -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton97" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame83" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. tr [ M ]} -value tr -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton98" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame84" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. eig2 [ M ]} -value eig2 -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton99" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd100 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd100" "Frame86" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd100
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame87" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] * value} -value mulval -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton101" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame88" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] .* (file)} -value mulfile -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton102" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame89" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. inv [ M ]} -value inv -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton103" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame90" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. det [ M ]} -value det -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton104" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame91" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. eig3 [ M ]} -value eig3 -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton105" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd101 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd101" "Frame93" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd101
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame94" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] / value} -value divval -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton107" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame95" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ M ] ./ (file)} -value divfile -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton108" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame96" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {[ U ] .* [ M ] .* inv[ U ]} -value similarity \
        -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton109" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame97" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {tr ( inv [ mat ] .* [ M ] )} -value trmatXmatM \
        -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton110" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd95" "Frame98" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd95
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatMRAZ -takefocus 0 \
        -text {. eig4 [ M ]} -value eig4 -variable PSPCalcOperatorM 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton111" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd95 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd99 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd100 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame100" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.but84 \
        -background #ffff00 \
        -command {global PSPCalcOperatorM PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

if {$PSPCalcOperatorM == "addval"} {set PSPCalcOperatorName "\[ M \] + value"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorM == "subval"} {set PSPCalcOperatorName "\[ M \] - value"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorM == "mulval"} {set PSPCalcOperatorName "\[ M \] * value"; set PSPCalcOp2Type "valuefloat"}
if {$PSPCalcOperatorM == "divval"} {set PSPCalcOperatorName "\[ M \] / value"; set PSPCalcOp2Type "valuefloat"}

if {$PSPCalcOperatorM == "addfile"} {set PSPCalcOperatorName "\[ M \]  .+  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorM == "subfile"} {set PSPCalcOperatorName "\[ M \]  .-  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorM == "mulfile"} {set PSPCalcOperatorName "\[ M \]  .*  (file)"; set PSPCalcOp2Type "file"}
if {$PSPCalcOperatorM == "divfile"} {set PSPCalcOperatorName "\[ M \]  ./  (file)"; set PSPCalcOp2Type "file"}

if {$PSPCalcOperatorM == "addmatM"} {set PSPCalcOperatorName "\[ M \]  .+  \[ M' \]"; set PSPCalcOp2Type "matM"}
if {$PSPCalcOperatorM == "addmatX"} {set PSPCalcOperatorName "\[ M \]  .+  \[ mat \]"; set PSPCalcOp2Type "matXherm"}

if {$PSPCalcOperatorM == "similarity"} {set PSPCalcOperatorName "\[ U \]  .*  \[ M \]  .*  inv\[ U \]"; set PSPCalcOp2Type "matXSU"}
if {$PSPCalcOperatorM == "trmatXmatM"} {set PSPCalcOperatorName "tr( inv\[ mat \]  .*  \[ M \] )"; set PSPCalcOp2Type "matXherm"}

if {$PSPCalcOperatorM == "conj"} {set PSPCalcOperatorName ".conj \[ M \]"; set PSPCalcOp2Type "out_matM"}
if {$PSPCalcOperatorM == "inv"} {set PSPCalcOperatorName ".inv \[ M \]"; set PSPCalcOp2Type "out_matM"}
if {$PSPCalcOperatorM == "det"} {set PSPCalcOperatorName ".det \[ M \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorM == "tr"} {set PSPCalcOperatorName ".tr \[ M \]"; set PSPCalcOp2Type "out_file"}
if {$PSPCalcOperatorM == "eig1"} {set PSPCalcOperatorName ".eig1 \[ M \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorM == "eig2"} {set PSPCalcOperatorName ".eig2 \[ M \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorM == "eig3"} {set PSPCalcOperatorName ".eig3 \[ M \]"; set PSPCalcOp2Type "out_eig"}
if {$PSPCalcOperatorM == "eig4"} {set PSPCalcOperatorName ".eig4 \[ M \]"; set PSPCalcOp2Type "out_eig"}

if {$PSPCalcOperatorM != ""} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type == "valuefloat" || $PSPCalcOp2Type == "file" || $PSPCalcOp2Type == "matM" || $PSPCalcOp2Type == "matX" || $PSPCalcOp2Type == "matXSU" || $PSPCalcOp2Type == "matXherm"} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        $PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
        PSPCalcInitOperand2
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        $PSPCalcRunButton configure -state normal -background #FFFF00
        }
    }
}} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_6_0.but84" "PSPCalcOperatorFileButtonOK3" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.but84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_3_0.cpd69 \
        \
        -text {Operator : Complex / Hermitian / Float / Special Unitary NxN Matrix} 
    vTcl:DefineAlias "$site_3_0.cpd69" "PSPCalcOperatorFileTitleFrame4" vTcl:WidgetProc "Toplevel600" 1
    bind $site_3_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    frame $site_5_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame77" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd70
    frame $site_6_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame85" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame92" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ] + value} -value addval -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton88" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame99" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ] .+ [ mat' ]} -value addmatX -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton100" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame101" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. det [ mat ] } -value det -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton106" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame102" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. eig1 [ mat ] } -value eig1 -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton112" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd99 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd99" "Frame104" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd99
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame105" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ]  - value} -value subval -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton114" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame106" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ] .- [ mat' ]} -value submatX -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton115" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame107" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. tr [ mat ]} -value tr -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton116" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame108" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. eig2 [ mat ] } -value eig2 -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton117" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd100 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd100" "Frame110" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd100
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame111" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ] * value} -value mulval -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton119" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame112" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ] .* [ mat' ]} -value mulmatX -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton120" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame113" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. conj [ mat ] } -value conj -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton121" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame114" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. eig3 [ mat ] } -value eig3 -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton122" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.cpd101 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd101" "Frame116" vTcl:WidgetProc "Toplevel600" 1
    set site_7_0 $site_6_0.cpd101
    frame $site_7_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame117" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ] / value} -value divval -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton124" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd91" "Frame118" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd91
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {[ mat ] ./ [ mat' ]} -value divmatX -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton125" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd93" "Frame119" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd93
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. inv [ mat ] } -value inv -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton126" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd94 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd94" "Frame120" vTcl:WidgetProc "Toplevel600" 1
    set site_8_0 $site_7_0.cpd94
    radiobutton $site_8_0.rad73 \
        -borderwidth 0 -command PSPCalcOperatorMatXRAZ -takefocus 0 \
        -text {. eig4 [ mat ] } -value eig4 -variable PSPCalcOperatorX 
    vTcl:DefineAlias "$site_8_0.rad73" "Radiobutton127" vTcl:WidgetProc "Toplevel600" 1
    pack $site_8_0.rad73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd99 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd100 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame122" vTcl:WidgetProc "Toplevel600" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.but84 \
        -background #ffff00 \
        -command {global PSPCalcOperatorX PSPCalcOperatorName PSPCalcOp2Type PSPCalcOp2Name PSPCalcOperand2
global PSPCalcOp2NameEntry PSPCalcOperand2Entry PSPCalcOp2SelectButton PSPCalcRunButton
global PSPCalcOp1Format PSPCalcOp1MatDim
global VarError ErrorMessage PSPMemory TMPMemoryAllocError

set PSPCalcOp2Name ""
set PSPCalcOp2Type ""
set PSPCalcOperatorName ""

if {$PSPCalcOperatorX == "addval"} {set PSPCalcOperatorName "\[ mat \] + value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "subval"} {set PSPCalcOperatorName "\[ mat \] - value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "mulval"} {set PSPCalcOperatorName "\[ mat \] * value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "divval"} {set PSPCalcOperatorName "\[ mat \] / value"; set PSPCalcOp2Type "value"}
if {$PSPCalcOperatorX == "addmatX"} {set PSPCalcOperatorName "\[ mat \]  .+  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "submatX"} {set PSPCalcOperatorName "\[ mat \]  .-  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "mulmatX"} {set PSPCalcOperatorName "\[ mat \]  .*  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "divmatX"} {set PSPCalcOperatorName "\[ mat \]  ./  \[ mat' \]"; set PSPCalcOp2Type "matX"}
if {$PSPCalcOperatorX == "inv"} {set PSPCalcOperatorName ".inv \[ mat \]"; set PSPCalcOp2Type "out_matX"}
if {$PSPCalcOperatorX == "det"} {set PSPCalcOperatorName ".det \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "tr"} {set PSPCalcOperatorName ".tr \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "conj"} {set PSPCalcOperatorName ".conj \[ mat \]"; set PSPCalcOp2Type "out_matX"}
if {$PSPCalcOperatorX == "eig1"} {set PSPCalcOperatorName ".eig1 \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "eig2"} {set PSPCalcOperatorName ".eig2 \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "eig3"} {set PSPCalcOperatorName ".eig3 \[ mat \]"; set PSPCalcOp2Type ""}
if {$PSPCalcOperatorX == "eig4"} {set PSPCalcOperatorName ".eig4 \[ mat \]"; set PSPCalcOp2Type ""}

set config "true"
if {$PSPCalcOperatorX == "divmatX" || $PSPCalcOperatorX == "det" || $PSPCalcOperatorX == "inv" || $PSPCalcOperatorX == "eig1" || $PSPCalcOperatorX == "eig2" || $PSPCalcOperatorX == "eig3" || $PSPCalcOperatorX == "eig4" } {
  if {$PSPCalcOp1Format != "herm"} { set config "false" }
  }

if {$config == "true"} {
if {$PSPCalcOperatorName != ""} {
    if {$PSPCalcOp2Type == "value" || $PSPCalcOp2Type == "matX"} {
        $PSPCalcOp2NameEntry configure -disabledbackground #FFFFFF
        $PSPCalcOperand2Entry configure -disabledbackground #FFFFFF
        set PSPCalcOp2Name "? ? ?"; set PSPCalcOperand2 "---"
        $PSPCalcRunButton configure -state disable -background $PSPBackgroundColor
        PSPCalcInitOperand2
        } else {
        $PSPCalcOp2NameEntry configure -disabledbackground $PSPBackgroundColor
        $PSPCalcOperand2Entry configure -disabledbackground $PSPBackgroundColor
        set PSPCalcOp2Name ""; set PSPCalcOperand2 ""
        $PSPCalcRunButton configure -state normal -background #FFFF00
        }
    }
} else {
set ErrorMessage "MATRIX MUST BE HERMITIAN TYPE"
WidgetShow $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
PSPCalcRAZButton
}} \
        -padx 4 -pady 2 -takefocus 0 -text OK 
    vTcl:DefineAlias "$site_6_0.but84" "PSPCalcOperatorFileButtonOK4" vTcl:WidgetProc "Toplevel600" 1
    pack $site_6_0.but84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.tit69 \
        -in $site_3_0 -anchor center -expand 1 -fill both -pady 3 -side top 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill both -pady 3 -side top 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill both -pady 3 -side top 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill both -pady 3 -side top 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra67 \
        -in $top -anchor center -expand 1 -fill both -side left 
    pack $top.cpd68 \
        -in $top -anchor center -expand 1 -fill both -side right 

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

Window show .
Window show .top600

main $argc $argv
