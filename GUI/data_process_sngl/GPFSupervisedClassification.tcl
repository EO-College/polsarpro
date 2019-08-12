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
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}

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
    set base .top445
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd88
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
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra55 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra55
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
    namespace eval ::widgets::$base.tit109 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit109 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd110
    namespace eval ::widgets::$site_5_0.fra23 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra23
    namespace eval ::widgets::$site_6_0.che24 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra66
    namespace eval ::widgets::$site_7_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd67
    namespace eval ::widgets::$site_8_0.lab57 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd68
    namespace eval ::widgets::$site_8_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd79 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd80 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.tit66 {
        array set save {-relief 1 -text 1}
    }
    set site_7_0 [$site_5_0.tit66 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd67
    namespace eval ::widgets::$site_8_0.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra66
    namespace eval ::widgets::$site_9_0.but67 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.lab69 {
        array set save {-borderwidth 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd68 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd70
    namespace eval ::widgets::$site_9_0.but67 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.lab69 {
        array set save {-borderwidth 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd68 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd68
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd72
    namespace eval ::widgets::$site_9_0.but67 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.lab69 {
        array set save {-borderwidth 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd68 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd71
    namespace eval ::widgets::$site_9_0.but67 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.lab69 {
        array set save {-borderwidth 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd68 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd70 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra29 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra29
    namespace eval ::widgets::$site_6_0.che30 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.but31 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd100 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd100 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra90
    namespace eval ::widgets::$site_5_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.but80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd101
    namespace eval ::widgets::$site_5_0.che24 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra25 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra25
    namespace eval ::widgets::$site_6_0.fra38 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra38
    namespace eval ::widgets::$site_7_0.che29 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.che31 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.fra42 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra42
    namespace eval ::widgets::$site_8_0.lab47 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab48 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab49 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.fra43 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra43
    namespace eval ::widgets::$site_8_0.lab52 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab445 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab54 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd103 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd103 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd105 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd106
    namespace eval ::widgets::$site_5_0.fra23 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra23
    namespace eval ::widgets::$site_6_0.but67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but68 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd107 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd107
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
    namespace eval ::widgets::$site_6_0.cpd108 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top445
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
    wm geometry $top 200x200+242+242; update
    wm maxsize $top 3604 1065
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

proc vTclWindow.top445 {base} {
    if {$base == ""} {
        set base .top445
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
    wm geometry $top 530x480+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Geometric Perturbation Filter Supervised Classification"
    vTcl:DefineAlias "$top" "Toplevel445" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame5" vTcl:WidgetProc "Toplevel445" 1
    set site_3_0 $top.cpd88
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel445" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SupervisedDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel445" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame19" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button43" vTcl:WidgetProc "Toplevel445" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel445" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable SupervisedOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel445" 1
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame1" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab73" "Label2" vTcl:WidgetProc "Toplevel445" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SupervisedOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel445" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd89 \
        \
        -command {global DirName DataDir SupervisedOutputDir SupervisedOutputSubDir FileTrainingArea FileTrainingSet
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol CONFIGDir

set SupervisedDirOutputTmp $SupervisedOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set SupervisedOutputDir $DirName
    } else {
    set SupervisedOutputDir $SupervisedDirOutputTmp
    }

set FileTrainingSet "$SupervisedDirOutput"
if {$SupervisedOutputSubDir != ""} {append FileTrainingSet "/$SupervisedOutputSubDir"}
append FileTrainingSet "/gpf_training_cluster_centers.bin"
    
set FileTrainingArea "$SupervisedDirOutput"
if {$SupervisedOutputSubDir != ""} {append FileTrainingArea "/$SupervisedOutputSubDir"}
append FileTrainingArea "/gpf_training_areas.txt"

if [file exists $FileTrainingArea] {
    set FileTrainingArea $FileTrainingArea
    } else {
    set FileTrainingArea "$CONFIGDir/gpf_training_areas.txt"
    } 
WaitUntilCreated $FileTrainingArea 
set f [open $FileTrainingArea r]
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
        -padx 1 -pady 0 -text button 
    pack $site_6_0.cpd89 \
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
    frame $top.fra55 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame9" vTcl:WidgetProc "Toplevel445" 1
    set site_3_0 $top.fra55
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel445" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel445" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel445" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel445" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel445" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel445" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel445" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel445" 1
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
    TitleFrame $top.tit109 \
        -ipad 0 -text {Classification Configuration} 
    vTcl:DefineAlias "$top.tit109" "TitleFrame3" vTcl:WidgetProc "Toplevel445" 1
    bind $top.tit109 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit109 getframe]
    frame $site_4_0.cpd110 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd110" "Frame260" vTcl:WidgetProc "Toplevel445" 1
    set site_5_0 $site_4_0.cpd110
    frame $site_5_0.fra23 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra23" "Frame265" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.fra23
    checkbutton $site_6_0.che24 \
        -text BMP -variable BMPSupervised 
    vTcl:DefineAlias "$site_6_0.che24" "Checkbutton84" vTcl:WidgetProc "Toplevel445" 1
    frame $site_6_0.fra66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra66" "Frame12" vTcl:WidgetProc "Toplevel445" 1
    set site_7_0 $site_6_0.fra66
    frame $site_7_0.cpd67 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_7_0.cpd67" "Frame267" vTcl:WidgetProc "Toplevel445" 1
    set site_8_0 $site_7_0.cpd67
    label $site_8_0.lab57 \
        -padx 1 -text {Window Size} -width 15 
    vTcl:DefineAlias "$site_8_0.lab57" "Label274" vTcl:WidgetProc "Toplevel445" 1
    pack $site_8_0.lab57 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd68 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_7_0.cpd68" "Frame269" vTcl:WidgetProc "Toplevel445" 1
    set site_8_0 $site_7_0.cpd68
    label $site_8_0.lab57 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_8_0.lab57" "Label278" vTcl:WidgetProc "Toplevel445" 1
    entry $site_8_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinSupervisedL -width 5 
    vTcl:DefineAlias "$site_8_0.ent58" "Entry193" vTcl:WidgetProc "Toplevel445" 1
    label $site_8_0.cpd79 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_8_0.cpd79" "Label279" vTcl:WidgetProc "Toplevel445" 1
    entry $site_8_0.cpd80 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinSupervisedC -width 5 
    vTcl:DefineAlias "$site_8_0.cpd80" "Entry194" vTcl:WidgetProc "Toplevel445" 1
    pack $site_8_0.lab57 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.ent58 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd79 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.cpd80 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd67 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd68 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.che24 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.fra66 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_5_0.tit66 \
        -relief sunken -text {Geometric Perturbation Filter} 
    vTcl:DefineAlias "$site_5_0.tit66" "TitleFrame4" vTcl:WidgetProc "Toplevel445" 1
    bind $site_5_0.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit66 getframe]
    frame $site_7_0.cpd67 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_7_0.cpd67" "Frame262" vTcl:WidgetProc "Toplevel445" 1
    set site_8_0 $site_7_0.cpd67
    frame $site_8_0.fra66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra66" "Frame3" vTcl:WidgetProc "Toplevel445" 1
    set site_9_0 $site_8_0.fra66
    button $site_9_0.but67 \
        \
        -command {global SupervisedThreshold

set SupervisedThreshold [expr $SupervisedThreshold - "0.01"]
if {$SupervisedThreshold < 0} {set SupervisedThreshold "1.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.but67" "Button2" vTcl:WidgetProc "Toplevel445" 1
    label $site_9_0.lab69 \
        -borderwidth 0 -text 0.01 
    vTcl:DefineAlias "$site_9_0.lab69" "Label5" vTcl:WidgetProc "Toplevel445" 1
    button $site_9_0.cpd68 \
        \
        -command {global SupervisedThreshold

set SupervisedThreshold [expr $SupervisedThreshold + "0.01"]
if {$SupervisedThreshold > "1.00"} {set SupervisedThreshold "0.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd68" "Button3" vTcl:WidgetProc "Toplevel445" 1
    pack $site_9_0.but67 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_9_0.lab69 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd68 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    frame $site_8_0.cpd70 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd70" "Frame4" vTcl:WidgetProc "Toplevel445" 1
    set site_9_0 $site_8_0.cpd70
    button $site_9_0.but67 \
        \
        -command {global SupervisedThreshold

set SupervisedThreshold [expr $SupervisedThreshold - "0.10"]
if {$SupervisedThreshold < 0} {set SupervisedThreshold "1.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.but67" "Button4" vTcl:WidgetProc "Toplevel445" 1
    label $site_9_0.lab69 \
        -borderwidth 0 -text 0.1 
    vTcl:DefineAlias "$site_9_0.lab69" "Label6" vTcl:WidgetProc "Toplevel445" 1
    button $site_9_0.cpd68 \
        \
        -command {global SupervisedThreshold

set SupervisedThreshold [expr $SupervisedThreshold + "0.10"]
if {$SupervisedThreshold > "1.00"} {set SupervisedThreshold "0.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd68" "Button5" vTcl:WidgetProc "Toplevel445" 1
    pack $site_9_0.but67 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_9_0.lab69 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd68 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    entry $site_8_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SupervisedThreshold -width 5 
    vTcl:DefineAlias "$site_8_0.ent58" "Entry446" vTcl:WidgetProc "Toplevel445" 1
    label $site_8_0.lab69 \
        -text Threshold 
    vTcl:DefineAlias "$site_8_0.lab69" "Label3" vTcl:WidgetProc "Toplevel445" 1
    pack $site_8_0.fra66 \
        -in $site_8_0 -anchor center -expand 0 -fill none -ipady 2 \
        -side right 
    pack $site_8_0.cpd70 \
        -in $site_8_0 -anchor center -expand 0 -fill none -ipady 2 \
        -side right 
    pack $site_8_0.ent58 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.lab69 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd68 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_7_0.cpd68" "Frame263" vTcl:WidgetProc "Toplevel445" 1
    set site_8_0 $site_7_0.cpd68
    frame $site_8_0.cpd72 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd72" "Frame7" vTcl:WidgetProc "Toplevel445" 1
    set site_9_0 $site_8_0.cpd72
    button $site_9_0.but67 \
        \
        -command {global SupervisedRedR

set SupervisedRedR [expr $SupervisedRedR - "0.01"]
if {$SupervisedRedR < 0} {set SupervisedRedR "1.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.but67" "Button8" vTcl:WidgetProc "Toplevel445" 1
    label $site_9_0.lab69 \
        -borderwidth 0 -text 0.01 
    vTcl:DefineAlias "$site_9_0.lab69" "Label8" vTcl:WidgetProc "Toplevel445" 1
    button $site_9_0.cpd68 \
        \
        -command {global SupervisedRedR

set SupervisedRedR [expr $SupervisedRedR + "0.01"]
if {$SupervisedRedR > "5.00"} {set SupervisedRedR "0.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd68" "Button9" vTcl:WidgetProc "Toplevel445" 1
    pack $site_9_0.but67 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_9_0.lab69 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd68 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    frame $site_8_0.cpd71 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd71" "Frame6" vTcl:WidgetProc "Toplevel445" 1
    set site_9_0 $site_8_0.cpd71
    button $site_9_0.but67 \
        \
        -command {global SupervisedRedR

set SupervisedRedR [expr $SupervisedRedR - "0.10"]
if {$SupervisedRedR < 0} {set SupervisedRedR "1.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.but67" "Button6" vTcl:WidgetProc "Toplevel445" 1
    label $site_9_0.lab69 \
        -borderwidth 0 -text 0.1 
    vTcl:DefineAlias "$site_9_0.lab69" "Label7" vTcl:WidgetProc "Toplevel445" 1
    button $site_9_0.cpd68 \
        \
        -command {global SupervisedRedR

set SupervisedRedR [expr $SupervisedRedR + "0.10"]
if {$SupervisedRedR > "5.00"} {set SupervisedRedR "0.00"}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd68" "Button7" vTcl:WidgetProc "Toplevel445" 1
    pack $site_9_0.but67 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_9_0.lab69 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd68 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    entry $site_8_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SupervisedRedR -width 5 
    vTcl:DefineAlias "$site_8_0.ent58" "Entry447" vTcl:WidgetProc "Toplevel445" 1
    label $site_8_0.cpd70 \
        -text {Reduction Ratio} 
    vTcl:DefineAlias "$site_8_0.cpd70" "Label4" vTcl:WidgetProc "Toplevel445" 1
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd71 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.ent58 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd70 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd67 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd68 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.fra29 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra29" "Frame268" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.fra29
    checkbutton $site_6_0.che30 \
        -text {Confusion Matrix} -variable ConfusionMatrix 
    vTcl:DefineAlias "$site_6_0.che30" "Checkbutton83" vTcl:WidgetProc "Toplevel445" 1
    button $site_6_0.but31 \
        -background #ffff00 \
        -command {global ConfusionMatrix NwinSupervisedL NwinSupervisedC SupervisedDirOutput OpenDirFile
global GPFThr GPFRedR 
#UTIL
global Load_TextEdit PSPTopLevel

if {$OpenDirFile == 0} {

if {$ConfusionMatrix == 1} {

    if {$Load_TextEdit == 0} {
        source "GUI/util/TextEdit.tcl"
        set Load_TextEdit 1
        WmTransient $widget(Toplevel95) $PSPTopLevel
        }

    set ConfusionMatrixFile "$SupervisedDirOutput/gpf_confusion_matrix_"
    append ConfusionMatrixFile $NwinSupervisedL; append ConfusionMatrixFile "x"; append ConfusionMatrixFile $NwinSupervisedC
    append ConfusionMatrixFile "_$GPFThr"; append ConfusionMatrixFile "_$GPFRedR"
    append ConfusionMatrixFile ".txt"

    TextEditorFromWidget .top445 $ConfusionMatrixFile
    }
}} \
        -padx 4 -pady 2 -text {CM Editor} 
    vTcl:DefineAlias "$site_6_0.but31" "Button445_1" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_6_0.but31 "$site_6_0.but31 Button $top all _vTclBalloon"
    bind $site_6_0.but31 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Confusion Matrix Editor}
    }
    pack $site_6_0.che30 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.but31 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra23 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.tit66 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.fra29 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.cpd110 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd100 \
        -ipad 0 -text {Color Maps} 
    vTcl:DefineAlias "$top.cpd100" "TitleFrame2" vTcl:WidgetProc "Toplevel445" 1
    bind $top.cpd100 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd100 getframe]
    frame $site_4_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra90" "Frame2" vTcl:WidgetProc "Toplevel445" 1
    set site_5_0 $site_4_0.fra90
    frame $site_5_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra91" "Frame8" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.fra91
    label $site_6_0.cpd95 \
        -text {ColorMap 16} 
    vTcl:DefineAlias "$site_6_0.cpd95" "Label126" vTcl:WidgetProc "Toplevel445" 1
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame10" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.fra92
    button $site_6_0.but80 \
        \
        -command {global FileName SupervisedDirInput ColorMapSupervised16

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$SupervisedDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapSupervised16 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but80" "Button1" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_6_0.but80 "$site_6_0.but80 Button $top all _vTclBalloon"
    bind $site_6_0.but80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd102 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd102 {global ColorMapSupervised16 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 16
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapSupervised16] {
    set f [open $ColorMapSupervised16 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal

set VarColorMap ""
set ColorMapIn $ColorMapSupervised16
set ColorMapOut $ColorMapSupervised16
WidgetShowFromWidget $widget(Toplevel445) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapSupervised16 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd102" "Button42" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_6_0.cpd102 "$site_6_0.cpd102 Button $top all _vTclBalloon"
    bind $site_6_0.cpd102 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.but80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame11" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapSupervised16 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd97" "Entry445" vTcl:WidgetProc "Toplevel445" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra91 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    frame $site_4_0.cpd101 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd101" "Frame660" vTcl:WidgetProc "Toplevel445" 1
    set site_5_0 $site_4_0.cpd101
    checkbutton $site_5_0.che24 \
        \
        -command {global ColorMapSupervisedCoded ColorMapSupervisedCodedPauli ColorMapSupervisedCodedSinclair

if {$ColorMapSupervisedCoded == "0"} {
    set ColorMapSupervisedCodedPauli "0"
    set ColorMapSupervisedCodedSinclair "0"
    $widget(Checkbutton445_1) configure -state disable
    $widget(Checkbutton445_2) configure -state disable
    $widget(Label445_1) configure -state disable
    $widget(Label445_2) configure -state disable
    $widget(Label445_3) configure -state disable
    $widget(Label445_4) configure -state disable
    $widget(Label445_5) configure -state disable
    $widget(Label445_6) configure -state disable
    }
if {$ColorMapSupervisedCoded == "1"} {
    $widget(Checkbutton445_1) configure -state normal
    $widget(Checkbutton445_2) configure -state normal
    $widget(Label445_1) configure -state normal
    $widget(Label445_2) configure -state normal
    $widget(Label445_3) configure -state normal
    $widget(Label445_4) configure -state normal
    $widget(Label445_5) configure -state normal
    $widget(Label445_6) configure -state normal
    }} \
        -text {Coded Colormap} -variable ColorMapSupervisedCoded 
    vTcl:DefineAlias "$site_5_0.che24" "Checkbutton638" vTcl:WidgetProc "Toplevel445" 1
    frame $site_5_0.fra25 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra25" "Frame70" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.fra25
    frame $site_6_0.fra38 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra38" "Frame87" vTcl:WidgetProc "Toplevel445" 1
    set site_7_0 $site_6_0.fra38
    checkbutton $site_7_0.che29 \
        -text {Pauli    } -variable ColorMapSupervisedCodedPauli 
    vTcl:DefineAlias "$site_7_0.che29" "Checkbutton445_1" vTcl:WidgetProc "Toplevel445" 1
    checkbutton $site_7_0.che31 \
        -text Sinclair -variable ColorMapSupervisedCodedSinclair 
    vTcl:DefineAlias "$site_7_0.che31" "Checkbutton445_2" vTcl:WidgetProc "Toplevel445" 1
    pack $site_7_0.che29 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.che31 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame88" vTcl:WidgetProc "Toplevel445" 1
    set site_7_0 $site_6_0.fra39
    frame $site_7_0.fra42 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra42" "Frame71" vTcl:WidgetProc "Toplevel445" 1
    set site_8_0 $site_7_0.fra42
    label $site_8_0.lab47 \
        -foreground #0000ff -text |S11+S22| 
    vTcl:DefineAlias "$site_8_0.lab47" "Label445_1" vTcl:WidgetProc "Toplevel445" 1
    label $site_8_0.lab48 \
        -foreground #008000 -text |S12+S21| 
    vTcl:DefineAlias "$site_8_0.lab48" "Label445_2" vTcl:WidgetProc "Toplevel445" 1
    label $site_8_0.lab49 \
        -foreground #ff0000 -text |S11-S22| 
    vTcl:DefineAlias "$site_8_0.lab49" "Label445_3" vTcl:WidgetProc "Toplevel445" 1
    pack $site_8_0.lab47 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.lab48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.lab49 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.fra43 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra43" "Frame72" vTcl:WidgetProc "Toplevel445" 1
    set site_8_0 $site_7_0.fra43
    label $site_8_0.lab52 \
        -foreground #0000ff -text |S11| 
    vTcl:DefineAlias "$site_8_0.lab52" "Label445_4" vTcl:WidgetProc "Toplevel445" 1
    label $site_8_0.lab445 \
        -foreground #008000 -text |(S12+S21)/2| 
    vTcl:DefineAlias "$site_8_0.lab445" "Label445_5" vTcl:WidgetProc "Toplevel445" 1
    label $site_8_0.lab54 \
        -foreground #ff0000 -text |S22| 
    vTcl:DefineAlias "$site_8_0.lab54" "Label445_6" vTcl:WidgetProc "Toplevel445" 1
    pack $site_8_0.lab52 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.lab445 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.lab54 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra42 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.fra43 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra38 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra39 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra90 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd103 \
        -ipad 0 -text {Training Areas} 
    vTcl:DefineAlias "$top.cpd103" "TitleFrame1" vTcl:WidgetProc "Toplevel445" 1
    bind $top.cpd103 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd103 getframe]
    frame $site_4_0.cpd93 \
        -relief groove -height 77 -width 437 
    vTcl:DefineAlias "$site_4_0.cpd93" "Frame270" vTcl:WidgetProc "Toplevel445" 1
    set site_5_0 $site_4_0.cpd93
    label $site_5_0.lab42 \
        -text {Areas File  } 
    vTcl:DefineAlias "$site_5_0.lab42" "Label275" vTcl:WidgetProc "Toplevel445" 1
    entry $site_5_0.ent44 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileTrainingArea 
    vTcl:DefineAlias "$site_5_0.ent44" "Entry188" vTcl:WidgetProc "Toplevel445" 1
    frame $site_5_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd94" "Frame22" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.cpd94
    button $site_6_0.cpd105 \
        \
        -command {global FileName SupervisedDirInput FileTrainingArea MapAlgebraConfigFileSupervised
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol

set FileTrainingAreaTmp $FileTrainingArea

set types {
{{TXT Files}        {.txt}        }
}
set FileName ""
OpenFile "$SupervisedDirInput" $types "TRAINING AREAS FILE"
if {$FileName != ""} {
    set f [open $FileName r]
    gets $f tmp
    if {$tmp == "NB_TRAINING_CLASSES"} {
        set FileTrainingArea $FileName
        if {$MapAlgebraConfigFileSupervised != ""} {
            set MapAlgebraConfigFileSupervised [MapAlgebra_command $MapAlgebraConfigFileSupervised "quit" ""]
            set MapAlgebraConfigFileSupervised ""
            }
        $widget(Button445_3) configure -state normal     
        } else {
        set ErrorMessage "TRAINING AREAS FILE NOT VALID"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set FileTrainingArea $FileTrainingAreaTmp
        $widget(Button445_3) configure -state disable
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd105" "Button19" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_6_0.cpd105 "$site_6_0.cpd105 Button $top all _vTclBalloon"
    bind $site_6_0.cpd105 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd105 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.lab42 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent44 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd106 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd106" "Frame279" vTcl:WidgetProc "Toplevel445" 1
    set site_5_0 $site_4_0.cpd106
    frame $site_5_0.fra23 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_5_0.fra23" "Frame474" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.fra23
    button $site_6_0.but67 \
        -background #ffff00 \
        -command {global VarTrainingArea NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint AreaPointN
global BMPDirInput OpenDirFile SupervisedDirInput FileTrainingArea
global MapAlgebraBMPFile MapAlgebraConfigFileSupervised

if {$OpenDirFile == 0} {

set WarningMessage "OPEN A BMP FILE TO SELECT"
set WarningMessage2 "THE TRAINING AREAS"
set VarWarning ""
Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
tkwait variable VarWarning

if {$VarWarning == "ok"} {

set types {
{{BMP Files}        {.bmp}        }
}
set filename ""
set filename [tk_getOpenFile -initialdir $SupervisedDirInput -filetypes $types -title "INPUT BMP FILE"]
if {$filename != ""} {
    set MapAlgebraBMPFile $filename
    }

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
set AreaClassN 1
set AreaN 1
set AreaPointN ""
set TrainingAreaToolLine "false"

set VarTrainingArea "no"
set MapAlgebraSession [ MapAlgebra_session ]
set MapAlgebraConfigFileSupervised "$TMPDir/$MapAlgebraSession"; append MapAlgebraConfigFileSupervised "_mapalgebrapaths.txt"
set FileTrainingArea "$SupervisedDirInput/$MapAlgebraSession"; append FileTrainingArea "_gpf_training_areas.txt"
DeleteFile $FileTrainingArea
$widget(Button445_3) configure -state disable
MapAlgebra_init "TrainingArea" $MapAlgebraSession $FileTrainingArea
MapAlgebra_launch $MapAlgebraConfigFileSupervised $MapAlgebraBMPFile
WaitUntilCreated $FileTrainingArea
if [file exists $FileTrainingArea] {
    set VarTrainingArea "ok"
    set MapAlgebraConfigFileSupervised [MapAlgebra_command $MapAlgebraConfigFileSupervised "quit" ""]
    set MapAlgebraConfigFileSupervised ""
    $widget(Button445_3) configure -state normal
    }
tkwait variable VarTrainingArea

#Return after Graphic Editor Exit
if {"$VarTrainingArea"=="no"} {
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
  }
}} \
        -padx 4 -pady 2 -text {Graphic Editor} 
    vTcl:DefineAlias "$site_6_0.but67" "Button642" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_6_0.but67 "$site_6_0.but67 Button $top all _vTclBalloon"
    bind $site_6_0.but67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Training Areas Graphic Editor}
    }
    pack $site_6_0.but67 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    button $site_5_0.but68 \
        -background #ffff00 \
        -command {global SupervisedDirInput SupervisedDirOutput SupervisedOutputDir SupervisedOutputSubDir
global SupervisedClusterFonction SupervisedClassifierFonction NwinSupervisedL NwinSupervisedC BMPSupervised SupervisedTrainingProcess
global ColorMapSupervised16 FileTrainingArea FileTrainingSet RejectClass RejectRatio ConfusionMatrix
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 OpenDirFile CONFIGDir
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax TMPMemoryAllocError

if {$OpenDirFile == 0} {

    set SupervisedTrainingProcess 1
    
    set SupervisedDirOutput $SupervisedOutputDir
    if {$SupervisedOutputSubDir != ""} {append SupervisedDirOutput "/$SupervisedOutputSubDir"}

    #####################################################################
    #Create Directory
    set SupervisedDirOutput [PSPCreateDirectoryMask $SupervisedDirOutput $SupervisedOutputDir $SupervisedDirInput]
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
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinSupervisedL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Training Area File"; set TestVarType(5) "file"; set TestVarValue(5) $FileTrainingArea; set TestVarMin(5) ""; set TestVarMax(5) ""
    set TestVarName(6) "ColorMap16"; set TestVarType(6) "file"; set TestVarValue(6) $ColorMapSupervised16; set TestVarMin(6) ""; set TestVarMax(6) ""
    set TestVarName(7) "Window Size Col"; set TestVarType(7) "int"; set TestVarValue(7) $NwinSupervisedC; set TestVarMin(7) "1"; set TestVarMax(7) "1000"
    TestVar 8
    if {$TestVarError == "ok"} {

    #Button "Confusion Matrix Editor"
    $widget(Button445_1) configure -state disable

    set FileTrainingSet "$SupervisedDirOutput/gpf_training_cluster_centers.bin"
    DeleteFile $FileTrainingSet

    set Fonction "Training and Determination"; set Fonction2 "of the Area Cluster Centers"
    set MaskCmd ""
    set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set SupervisedF $SupervisedFonction
    if {$SupervisedFonction == "S2m"} { set SupervisedF "S2" }
    if {$SupervisedFonction == "S2b"} { set SupervisedF "S2" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/gpf_training_set_sampler.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -od \x22$SupervisedDirOutput\x22 -iodf $SupervisedF -af \x22$FileTrainingArea\x22 -cf \x22$FileTrainingSet\x22 -bmp $BMPSupervised -col \x22$ColorMapSupervised16\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bin/data_process_sngl/gpf_training_set_sampler.exe -id \x22$SupervisedDirInput\x22 -od \x22$SupervisedDirOutput\x22 -iodf $SupervisedF -af \x22$FileTrainingArea\x22 -cf \x22$FileTrainingSet\x22 -bmp $BMPSupervised -col \x22$ColorMapSupervised16\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    $widget(Button445_4) configure -state normal
    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel445); TextEditorRunTrace "Close Window GPF Supervised Classification" "b"}
    }
}} \
        -padx 4 -pady 2 -text {Run Training Process} 
    vTcl:DefineAlias "$site_5_0.but68" "Button445_3" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_5_0.but68 "$site_5_0.but68 Button $top all _vTclBalloon"
    bind $site_5_0.but68 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run Training Process}
    }
    pack $site_5_0.fra23 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.but68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd107 \
        -relief groove -height 77 -width 437 
    vTcl:DefineAlias "$site_4_0.cpd107" "Frame271" vTcl:WidgetProc "Toplevel445" 1
    set site_5_0 $site_4_0.cpd107
    label $site_5_0.lab42 \
        -text {  Set File     } 
    vTcl:DefineAlias "$site_5_0.lab42" "Label276" vTcl:WidgetProc "Toplevel445" 1
    entry $site_5_0.ent44 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileTrainingSet 
    vTcl:DefineAlias "$site_5_0.ent44" "Entry189" vTcl:WidgetProc "Toplevel445" 1
    frame $site_5_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd94" "Frame23" vTcl:WidgetProc "Toplevel445" 1
    set site_6_0 $site_5_0.cpd94
    button $site_6_0.cpd108 \
        \
        -command {global FileName SupervisedDirInput FileTrainingSet FileTrainingArea
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol

set FileTrainingSetTmp $FileTrainingArea

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$SupervisedDirInput" $types "TRAINING SET FILE"
if {$FileName != ""} {
    set FileTrainingSet $FileName
    set lenfile [expr [string length $FileTrainingSet] - 25]
    set FileTrainingArea [string range $FileTrainingSet 0 $lenfile]
    append FileTrainingArea "gpf_training_areas.txt"

    WaitUntilCreated $FileTrainingArea 
    if [file exists $FileTrainingArea] {
        set f [open $FileTrainingArea r]
        gets $f tmp
        if {$tmp == "NB_TRAINING_CLASSES"} {
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
            set ErrorMessage "TRAINING AREAS FILE NOT VALID"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set FileTrainingArea $FileTrainingAreaTmp
            }
        } else {
        set ErrorMessage "TRAINING AREAS FILE DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd108" "Button20" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_6_0.cpd108 "$site_6_0.cpd108 Button $top all _vTclBalloon"
    bind $site_6_0.cpd108 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd108 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.lab42 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent44 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd107 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel445" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global SupervisedDirInput SupervisedDirOutput SupervisedOutputDir SupervisedOutputSubDir SupervisedTrainingProcess
global SupervisedClusterFonction SupervisedClassifierFonction SupervisedClassifierConfusionMatrixFonction
global NwinSupervisedL NwinSupervisedC BMPSupervised ColorMapSupervised16 FileTrainingArea FileTrainingSet TMPMemoryAllocError
global RejectClass RejectRatio ConfusionMatrix Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile SupervisedThreshold SupervisedRedR GPFThr GPFRedR 

if {$OpenDirFile == 0} {

set config "true"
if {$PolarCase == "intensities"} {
    if {$NwinSupervisedL <= 1} {
        set ErrorMessage "WINDOW SIZE MUST BE > 1" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set config "false"
        }
    }

if {$config == "true"} {

    if {$SupervisedTrainingProcess == 0} {
        set SupervisedDirOutput $SupervisedOutputDir 
        if {$SupervisedOutputSubDir != ""} {append SupervisedDirOutput "/$SupervisedOutputSubDir"}
        }
        
    #####################################################################
    #Create Directory
    set SupervisedDirOutput [PSPCreateDirectoryMask $SupervisedDirOutput $SupervisedOutputDir $SupervisedDirInput]
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
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinSupervisedL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Threshold"; set TestVarType(5) "float"; set TestVarValue(5) $SupervisedThreshold; set TestVarMin(5) ""; set TestVarMax(5) ""
    set TestVarName(6) "Training Set File"; set TestVarType(6) "file"; set TestVarValue(6) $FileTrainingSet; set TestVarMin(6) ""; set TestVarMax(6) ""
    set TestVarName(7) "ColorMap16"; set TestVarType(7) "file"; set TestVarValue(7) $ColorMapSupervised16; set TestVarMin(7) ""; set TestVarMax(7) ""
    set TestVarName(8) "Window Size Col"; set TestVarType(8) "int"; set TestVarValue(8) $NwinSupervisedC; set TestVarMin(8) "1"; set TestVarMax(8) "1000"
    set TestVarName(9) "Reduction Ratio"; set TestVarType(9) "float"; set TestVarValue(9) $SupervisedRedR; set TestVarMin(9) ""; set TestVarMax(9) ""
    TestVar 10
    if {$TestVarError == "ok"} {

    #Button "Confusion Matrix Editor"
    $widget(Button445_1) configure -state disable


    if [file exists $FileTrainingSet] {
        set Fonction ""; set Fonction2 "Supervised Classification"
        set MaskCmd ""
        set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set SupervisedF $SupervisedFonction
        if {$SupervisedFonction == "S2m"} { set SupervisedF "S2" }
        if {$SupervisedFonction == "S2b"} { set SupervisedF "S2" }

        set ClassificationFile "$SupervisedDirOutput/gpf_supervised_class_"
        append ClassificationFile $NwinSupervisedL; append ClassificationFile "x"; append ClassificationFile $NwinSupervisedC
        append ClassificationFile "_"; set tmp [expr 100 * $SupervisedThreshold]; set GPFThr [expr round($tmp)]; append ClassificationFile $GPFThr
        append ClassificationFile "_"; set tmp [expr 100 * $SupervisedRedR]; set GPFRedR [expr round($tmp)]; append ClassificationFile $GPFRedR
        set ClassificationInputFile "$ClassificationFile.bin"

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/gpf_supervised_classifier.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -od \x22$SupervisedDirOutput\x22 -iodf $SupervisedF -af \x22$FileTrainingArea\x22 -of \x22$ClassificationFile\x22 -thr $SupervisedThreshold -redr $SupervisedRedR -nwr $NwinSupervisedL -nwc $NwinSupervisedC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -bmp $BMPSupervised -col \x22$ColorMapSupervised16\x22 -cf \x22$FileTrainingSet\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/gpf_supervised_classifier.exe -id \x22$SupervisedDirInput\x22 -od \x22$SupervisedDirOutput\x22 -iodf $SupervisedF -af \x22$FileTrainingArea\x22 -of \x22$ClassificationFile\x22 -thr $SupervisedThreshold -redr $SupervisedRedR -nwr $NwinSupervisedL -nwc $NwinSupervisedC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -bmp $BMPSupervised -col \x22$ColorMapSupervised16\x22 -cf \x22$FileTrainingSet\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        
        if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ColorMapSupervised16 16}
        
        if {$ConfusionMatrix == "1"} {
            set Fonction ""; set Fonction2 "Confusion Matrix Determination"
            set MaskCmd ""
            set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/gpf_confusion_matrix.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -od \x22$SupervisedDirOutput\x22 -af \x22$FileTrainingArea\x22 -thr $GPFThr -redr $GPFRedR -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nwr $NwinSupervisedL -nwc $NwinSupervisedC -bmp $BMPSupervised -col \x22$ColorMapSupervised16\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/gpf_confusion_matrix.exe -id \x22$SupervisedDirInput\x22 -od \x22$SupervisedDirOutput\x22 -af \x22$FileTrainingArea\x22 -thr $GPFThr -redr $GPFRedR -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -nwr $NwinSupervisedL -nwc $NwinSupervisedC -bmp $BMPSupervised -col \x22$ColorMapSupervised16\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            $widget(Button445_1) configure -state normal
            }        
        if {$ColorMapSupervisedCoded == "1"} {
            set ClassificationFile "$SupervisedDirOutput/gpf_supervised_class_"
            append ClassificationFile $NwinSupervisedL; append ClassificationFile "x"; append ClassificationFile $NwinSupervisedC
            set ClassificationInputFile "$ClassificationFile.bin"
            if [file exists $ClassificationInputFile] {
                if {$ColorMapSupervisedCodedPauli == "1"} {
                    set Fonction "Creation of the Supervised Classification BMP File"
                    set Fonction2 "Using an automatic color coded (Pauli) ColorMap"
                    set MaskCmd ""
                    set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
                    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    set ClassificationOutputFile $ClassificationFile
                    append ClassificationOutputFile "_pauli.bmp"
                    set SupervisedF $SupervisedFonction
                    if {$SupervisedFonction == "S2m"} { set SupervisedF "S2" }
                    if {$SupervisedFonction == "S2b"} { set SupervisedF "S2" }
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/classification_colormap_pauli.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -iodf $SupervisedF -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/classification_colormap_pauli.exe -id \x22$SupervisedDirInput\x22 -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -iodf $SupervisedF -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    }
                if {$ColorMapSupervisedCodedSinclair == "1"} {
                    set Fonction "Creation of the Supervised Classification BMP File"
                    set Fonction2 "Using an automatic color coded (Sinclair) ColorMap"
                    set MaskCmd ""
                    set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
                    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    set ClassificationOutputFile $ClassificationFile
                    append ClassificationOutputFile "_sinclair.bmp"
                    set SupervisedF $SupervisedFonction
                    if {$SupervisedFonction == "S2m"} { set SupervisedF "S2" }
                    if {$SupervisedFonction == "S2b"} { set SupervisedF "S2" }
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/classification_colormap_sinclair.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -iodf $SupervisedF -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/classification_colormap_sinclair.exe -id \x22$SupervisedDirInput\x22 -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -iodf $SupervisedF -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    }
                } else {
                set VarError ""
                set ErrorMessage "THE FILE $ClassificationInputFile DOES NOT EXIST"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
            } 
        } else {
        set ErrorMessage "TRAINING AREAS OVERLAPPED" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel445); TextEditorRunTrace "Close Window G.P.F. Supervised Classification" "b"}
    }
}
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button445_4" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/GPFSupervisedClassification.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel445" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile MapAlgebraConfigFileSupervised

if {$OpenDirFile == 0} {
    if {$MapAlgebraConfigFileSupervised != ""} { set MapAlgebraConfigFileSupervised [MapAlgebra_command $MapAlgebraConfigFileSupervised "quit" ""] }
    Window hide $widget(Toplevel445); TextEditorRunTrace "Close Window G.P.F. Supervised Classification" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel445" 1
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
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit109 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd100 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd103 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -side bottom 

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
Window show .top445

main $argc $argv
