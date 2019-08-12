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

        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}

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
    set base .top337
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
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
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
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
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit85 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit85 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit97 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit97 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra77
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.cpd102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd102
    namespace eval ::widgets::$site_6_0.lab32 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent33 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent35 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-_tooltip 1 -background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.lab34 {
        array set save {-padx 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd90 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd90 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra83
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd84 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd87
    namespace eval ::widgets::$site_8_0.cpd84 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.cpd86 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd87 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd86 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd77
    namespace eval ::widgets::$site_9_0.cpd78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd84 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd80
    namespace eval ::widgets::$site_9_0.cpd78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd84 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd89 {
        array set save {}
    }
    set site_8_0 $site_7_0.cpd89
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd82
    namespace eval ::widgets::$site_9_0.cpd78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd84 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd67 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd68 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd69 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd70 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.cpd99 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.fra38 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra38
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
            vTclWindow.top337
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
    wm geometry $top 200x200+50+50; update
    wm maxsize $top 3364 1032
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

proc vTclWindow.top337 {base} {
    if {$base == ""} {
        set base .top337
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
    wm geometry $top 500x650+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Edge Detector"
    vTcl:DefineAlias "$top" "Toplevel337" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel337" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel337" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable EdgeFileInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel337" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel337" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName EdgeDirInput EdgeDirOutput EdgeFileInput EdgeFileOutput
global EdgeDetector EdgeCoeff InputFormat OutputFormat
global ConfigFile NligInit VarError ErrorMessage

set EdgeFileInput ""
set EdgeFileOutput ""
set InputFormat "float"
set OutputFormat "real"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label337_1) configure -state disable
$widget(Entry337_1) configure -state disable
$widget(Label337_2) configure -state disable
$widget(Entry337_2) configure -state disable
$widget(Button337_1) configure -state disable
set MinBMP "Auto"
set MaxBMP "Auto"

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $EdgeDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
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
            if {$tmp == "data type = 2"} {set InputFormat "int"; set OutputFormat "real"}
            if {$tmp == "data type = 4"} {set InputFormat "float"; set OutputFormat "real"}
            if {$tmp == "data type = 6"} {set InputFormat "cmplx"; set OutputFormat "mod"}
            set EdgeDirInput [file dirname $FileName]
            set ConfigFile "$EdgeDirInput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                set EdgeFileInput $FileName
                if {$EdgeDetector != "paillou"} {
                    set EdgeFileOutput "$EdgeDirOutput/"
                    append EdgeFileOutput "$EdgeDetector"
                    append EdgeFileOutput "_"
                    append EdgeFileOutput "$EdgeCoeff.bin"
                    }
                } else {
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                if {$VarError == "cancel"} {Window hide $widget(Toplevel337); TextEditorRunTrace "Close Window Edge Detector" "b"}
                }    
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            if {$VarError == "cancel"} {Window hide $widget(Toplevel337); TextEditorRunTrace "Close Window Edge Detector" "b"}
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel337); TextEditorRunTrace "Close Window Edge Detector" "b"}
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame9" vTcl:WidgetProc "Toplevel337" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable EdgeDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel337" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel337" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global DirName DataDir EdgeDirOutput EdgeFileOutput

set EdgeDirOutputTmp $EdgeDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set EdgeDirOutput $DirName
    } else {
    set EdgeDirOutput $EdgeDirOutputTmp
    }
set FileTmp "$EdgeDirOutput/"
append FileTmp [file tail $EdgeFileOutput]
set EdgeFileOutput $FileTmp} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra51 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame9" vTcl:WidgetProc "Toplevel337" 1
    set site_3_0 $top.fra51
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel337" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel337" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel337" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel337" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel337" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel337" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel337" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel337" 1
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
    TitleFrame $top.tit81 \
        -ipad 0 -text {Data Format} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame1" vTcl:WidgetProc "Toplevel337" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    radiobutton $site_4_0.cpd82 \
        -padx 1 -text Complex -value cmplx -variable InputFormat 
    radiobutton $site_4_0.cpd83 \
        -padx 1 -text Float -value float -variable InputFormat 
    radiobutton $site_4_0.cpd84 \
        -padx 1 -text Integer -value int -variable InputFormat 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit85 \
        -ipad 0 -text {Gray Level Coded Input Data} 
    vTcl:DefineAlias "$top.tit85" "TitleFrame2" vTcl:WidgetProc "Toplevel337" 1
    bind $top.tit85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit85 getframe]
    radiobutton $site_4_0.cpd86 \
        -command {global MinMaxContrastBMP

set MinMaxContrastBMP 0} -padx 1 \
        -text Modulus -value mod -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd86" "Radiobutton35" vTcl:WidgetProc "Toplevel337" 1
    radiobutton $site_4_0.cpd71 \
        -command {global MinMaxContrastBMP

set MinMaxContrastBMP 1} -padx 1 \
        -text 10log(Mod) -value db10 -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd71" "Radiobutton337" vTcl:WidgetProc "Toplevel337" 1
    radiobutton $site_4_0.cpd87 \
        -command {global MinMaxContrastBMP

set MinMaxContrastBMP 1} -padx 1 \
        -text 20log(Mod) -value db20 -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd87" "Radiobutton36" vTcl:WidgetProc "Toplevel337" 1
    radiobutton $site_4_0.cpd89 \
        -command {global MinMaxContrastBMP

set MinMaxContrastBMP 0} -padx 1 \
        -text Phase -value pha -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd89" "Radiobutton37" vTcl:WidgetProc "Toplevel337" 1
    radiobutton $site_4_0.cpd90 \
        -command {global MinMaxContrastBMP

set MinMaxContrastBMP 0} -padx 1 \
        -text Real -value real -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd90" "Radiobutton38" vTcl:WidgetProc "Toplevel337" 1
    radiobutton $site_4_0.cpd92 \
        -command {global MinMaxContrastBMP

set MinMaxContrastBMP 0} -padx 1 \
        -text Imag -value imag -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd92" "Radiobutton39" vTcl:WidgetProc "Toplevel337" 1
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit97 \
        -ipad 0 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$top.tit97" "TitleFrame6" vTcl:WidgetProc "Toplevel337" 1
    bind $top.tit97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit97 getframe]
    frame $site_4_0.cpd72
    set site_5_0 $site_4_0.cpd72
    frame $site_5_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra77" "Frame3" vTcl:WidgetProc "Toplevel337" 1
    set site_6_0 $site_5_0.fra77
    checkbutton $site_6_0.cpd78 \
        \
        -command {global MinMaxAutoBMP
if {"$MinMaxAutoBMP"=="1"} {
    $widget(Label337_1) configure -state disable
    $widget(Entry337_1) configure -state disable
    $widget(Label337_2) configure -state disable
    $widget(Entry337_2) configure -state disable
    $widget(Button337_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    } else {
    $widget(Label337_1) configure -state normal
    $widget(Entry337_1) configure -state normal
    $widget(Label337_2) configure -state normal
    $widget(Entry337_2) configure -state normal
    $widget(Button337_1) configure -state normal
    set MinBMP "?"
    set MaxBMP "?"
    }} \
        -padx 1 -text Automatic -variable MinMaxAutoBMP 
    vTcl:DefineAlias "$site_6_0.cpd78" "Checkbutton39" vTcl:WidgetProc "Toplevel337" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame4" vTcl:WidgetProc "Toplevel337" 1
    set site_6_0 $site_5_0.cpd79
    checkbutton $site_6_0.cpd78 \
        -padx 1 -text {Enhanced Contrast} -variable MinMaxContrastBMP 
    vTcl:DefineAlias "$site_6_0.cpd78" "Checkbutton40" vTcl:WidgetProc "Toplevel337" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra77 \
        -in $site_5_0 -anchor w -expand 1 -fill none -side top 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    frame $site_4_0.cpd73
    set site_5_0 $site_4_0.cpd73
    frame $site_5_0.cpd102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd102" "Frame69" vTcl:WidgetProc "Toplevel337" 1
    set site_6_0 $site_5_0.cpd102
    label $site_6_0.lab32 \
        -padx 1 -text Min 
    vTcl:DefineAlias "$site_6_0.lab32" "Label337_1" vTcl:WidgetProc "Toplevel337" 1
    entry $site_6_0.ent33 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MinBMP -width 12 
    vTcl:DefineAlias "$site_6_0.ent33" "Entry337_1" vTcl:WidgetProc "Toplevel337" 1
    label $site_6_0.lab34 \
        -padx 1 -text Max 
    vTcl:DefineAlias "$site_6_0.lab34" "Label337_2" vTcl:WidgetProc "Toplevel337" 1
    entry $site_6_0.ent35 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxBMP -width 12 
    vTcl:DefineAlias "$site_6_0.ent35" "Entry337_2" vTcl:WidgetProc "Toplevel337" 1
    button $site_6_0.cpd75 \
        -background #ffff00 \
        -command {global MaxBMP MinBMP TMPMinMaxBmp OpenDirFile EdgeFileInput TMPMemoryAllocError

if {$OpenDirFile == 0} {
#read MinMaxBMP
set MinMaxBMPvalues $TMPMinMaxBmp
DeleteFile $MinMaxBMPvalues

set OffsetLig [expr $NligInit - 1]
set OffsetCol [expr $NcolInit - 1]
set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

set Fonction "Min / Max Values Determination of the Bin File :"
set Fonction2 "$EdgeFileInput"    
set MaskCmd ""
set MaskDir [file dirname $EdgeFileInput]
set MaskFile "$MaskDir/mask_valid_pixels.bin"
if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
TextEditorRunTrace "Process The Function Soft/bin/bmp_process/MinMaxBMP.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$EdgeFileInput\x22 -ift $InputFormat -oft $OutputFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/bmp_process/MinMaxBMP.exe -if \x22$EdgeFileInput\x22 -ift $InputFormat -oft $OutputFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

WaitUntilCreated $MinMaxBMPvalues 
if [file exists $MinMaxBMPvalues] {
    set f [open $MinMaxBMPvalues r]
    gets $f MaxBMP
    gets $f MinBMP
    close $f
    }
}} \
        -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_6_0.cpd75" "Button337_1" vTcl:WidgetProc "Toplevel337" 1
    bindtags $site_6_0.cpd75 "$site_6_0.cpd75 Button $top all _vTclBalloon"
    bind $site_6_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Find the Min Max values}
    }
    pack $site_6_0.lab32 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_6_0.ent33 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.lab34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_6_0.ent35 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame70" vTcl:WidgetProc "Toplevel337" 1
    set site_6_0 $site_5_0.cpd76
    label $site_6_0.lab34 \
        -padx 1 -width 20 
    vTcl:DefineAlias "$site_6_0.lab34" "Label61" vTcl:WidgetProc "Toplevel337" 1
    pack $site_6_0.lab34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd102 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $top.cpd90 \
        -ipad 0 -text {Edge Detector} 
    vTcl:DefineAlias "$top.cpd90" "TitleFrame10" vTcl:WidgetProc "Toplevel337" 1
    bind $top.cpd90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd90 getframe]
    frame $site_4_0.cpd74
    set site_5_0 $site_4_0.cpd74
    radiobutton $site_5_0.cpd82 \
        \
        -command {global EdgeFileOutput EdgeDetector EdgeCoeff
global EdgePaillouAmpOutput EdgePaillouMaxAmpOutput
global EdgePaillouAngOutput EdgePaillouMaxAngOutput
global EdgeAlpha EdgeOmega EdgeThreshold

set EdgeAlpha ""; set EdgeOmega ""; set EdgeThreshold ""

$widget(TitleFrame337_6) configure -state normal
$widget(Label337_3) configure -state normal
$widget(Entry337_3) configure -state normal
$widget(Button337_2) configure -state normal
$widget(Button337_3) configure -state normal
$widget(TitleFrame337_7) configure -state disable
$widget(Label337_4) configure -state disable
$widget(Entry337_4) configure -state disable
$widget(Label337_5) configure -state disable
$widget(Entry337_5) configure -state disable
$widget(Label337_6) configure -state disable
$widget(Entry337_6) configure -state disable
$widget(TitleFrame337_1) configure -state disable
$widget(TitleFrame337_2) configure -state disable
$widget(Entry337_7) configure -state disable
$widget(TitleFrame337_3) configure -state disable
$widget(Entry337_8) configure -state disable
$widget(TitleFrame337_4) configure -state disable
$widget(Entry337_9) configure -state disable
$widget(TitleFrame337_5) configure -state disable
$widget(Entry337_10) configure -state disable
$widget(TitleFrame337_8) configure -state normal
$widget(Entry337_11) configure -state normal

set EdgePaillouAmpOutput ""
set EdgePaillouMaxAmpOutput ""
set EdgePaillouAngOutput ""
set EdgePaillouMaxAngOutput ""
set EdgeCoeff "0.5"
set EdgeFileOutput "$EdgeDirOutput/"
append EdgeFileOutput "$EdgeDetector"
append EdgeFileOutput "_"
append EdgeFileOutput "$EdgeCoeff.bin"} \
        -padx 1 -text Black -value black -variable EdgeDetector 
    radiobutton $site_5_0.cpd83 \
        \
        -command {global EdgeFileOutput EdgeDetector EdgeCoeff
global EdgePaillouAmpOutput EdgePaillouMaxAmpOutput
global EdgePaillouAngOutput EdgePaillouMaxAngOutput
global EdgeAlpha EdgeOmega EdgeThreshold

set EdgeAlpha ""; set EdgeOmega ""; set EdgeThreshold ""

$widget(TitleFrame337_6) configure -state normal
$widget(Label337_3) configure -state normal
$widget(Entry337_3) configure -state normal
$widget(Button337_2) configure -state normal
$widget(Button337_3) configure -state normal
$widget(TitleFrame337_7) configure -state disable
$widget(Label337_4) configure -state disable
$widget(Entry337_4) configure -state disable
$widget(Label337_5) configure -state disable
$widget(Entry337_5) configure -state disable
$widget(Label337_6) configure -state disable
$widget(Entry337_6) configure -state disable
$widget(TitleFrame337_1) configure -state disable
$widget(TitleFrame337_2) configure -state disable
$widget(Entry337_7) configure -state disable
$widget(TitleFrame337_3) configure -state disable
$widget(Entry337_8) configure -state disable
$widget(TitleFrame337_4) configure -state disable
$widget(Entry337_9) configure -state disable
$widget(TitleFrame337_5) configure -state disable
$widget(Entry337_10) configure -state disable
$widget(TitleFrame337_8) configure -state normal
$widget(Entry337_11) configure -state normal

set EdgePaillouAmpOutput ""
set EdgePaillouMaxAmpOutput ""
set EdgePaillouAngOutput ""
set EdgePaillouMaxAngOutput ""
set EdgeCoeff "0.5"
set EdgeFileOutput "$EdgeDirOutput/"
append EdgeFileOutput "$EdgeDetector"
append EdgeFileOutput "_"
append EdgeFileOutput "$EdgeCoeff.bin"} \
        -padx 1 -text Canny -value canny -variable EdgeDetector 
    radiobutton $site_5_0.cpd84 \
        \
        -command {global EdgeFileOutput EdgeDetector EdgeCoeff
global EdgePaillouAmpOutput EdgePaillouMaxAmpOutput
global EdgePaillouAngOutput EdgePaillouMaxAngOutput
global EdgeAlpha EdgeOmega EdgeThreshold

set EdgeAlpha ""; set EdgeOmega ""; set EdgeThreshold ""

$widget(TitleFrame337_6) configure -state normal
$widget(Label337_3) configure -state normal
$widget(Entry337_3) configure -state normal
$widget(Button337_2) configure -state normal
$widget(Button337_3) configure -state normal
$widget(TitleFrame337_7) configure -state disable
$widget(Label337_4) configure -state disable
$widget(Entry337_4) configure -state disable
$widget(Label337_5) configure -state disable
$widget(Entry337_5) configure -state disable
$widget(Label337_6) configure -state disable
$widget(Entry337_6) configure -state disable
$widget(TitleFrame337_1) configure -state disable
$widget(TitleFrame337_2) configure -state disable
$widget(Entry337_7) configure -state disable
$widget(TitleFrame337_3) configure -state disable
$widget(Entry337_8) configure -state disable
$widget(TitleFrame337_4) configure -state disable
$widget(Entry337_9) configure -state disable
$widget(TitleFrame337_5) configure -state disable
$widget(Entry337_10) configure -state disable
$widget(TitleFrame337_8) configure -state normal
$widget(Entry337_11) configure -state normal

set EdgePaillouAmpOutput ""
set EdgePaillouMaxAmpOutput ""
set EdgePaillouAngOutput ""
set EdgePaillouMaxAngOutput ""
set EdgeCoeff "0.5"
set EdgeFileOutput "$EdgeDirOutput/"
append EdgeFileOutput "$EdgeDetector"
append EdgeFileOutput "_"
append EdgeFileOutput "$EdgeCoeff.bin"} \
        -padx 1 -text Marr-Hildreth -value marr -variable EdgeDetector 
    radiobutton $site_5_0.cpd71 \
        \
        -command {global EdgeFileOutput EdgeDetector EdgeCoeff
global EdgePaillouAmpOutput EdgePaillouMaxAmpOutput
global EdgePaillouAngOutput EdgePaillouMaxAngOutput
global EdgeAlpha EdgeOmega EdgeThreshold

set EdgeAlpha "1.0"; set EdgeOmega "0.1"; set EdgeThreshold "10"

$widget(TitleFrame337_6) configure -state disable
$widget(Label337_3) configure -state disable
$widget(Entry337_3) configure -state disable
$widget(Button337_2) configure -state disable
$widget(Button337_3) configure -state disable
set EdgeCoeff ""
$widget(TitleFrame337_7) configure -state normal
$widget(Label337_4) configure -state normal
$widget(Entry337_4) configure -state normal
$widget(Label337_5) configure -state normal
$widget(Entry337_5) configure -state normal
$widget(Label337_6) configure -state normal
$widget(Entry337_6) configure -state normal
$widget(TitleFrame337_1) configure -state normal
$widget(TitleFrame337_2) configure -state normal
$widget(Entry337_7) configure -state normal
$widget(TitleFrame337_3) configure -state normal
$widget(Entry337_8) configure -state normal
$widget(TitleFrame337_4) configure -state normal
$widget(Entry337_9) configure -state normal
$widget(TitleFrame337_5) configure -state normal
$widget(Entry337_10) configure -state normal
$widget(TitleFrame337_8) configure -state disable
$widget(Entry337_11) configure -state disable

set EdgeFileOutput ""
set EdgePaillouAmpOutput "$EdgeDirOutput/"
append EdgePaillouAmpOutput "paillou_gradient_amp.bin"
set EdgePaillouMaxAmpOutput "$EdgeDirOutput/"
append EdgePaillouMaxAmpOutput "paillou_gradient_maxamp.bin"
set EdgePaillouAngOutput "$EdgeDirOutput/"
append EdgePaillouAngOutput "paillou_gradient_dir.bin"
set EdgePaillouMaxAngOutput "$EdgeDirOutput/"
append EdgePaillouMaxAngOutput "paillou_gradient_maxdir.bin"} \
        -padx 1 -text Paillou -value paillou -variable EdgeDetector 
    radiobutton $site_5_0.cpd76 \
        \
        -command {global EdgeFileOutput EdgeDetector EdgeCoeff
global EdgePaillouAmpOutput EdgePaillouMaxAmpOutput
global EdgePaillouAngOutput EdgePaillouMaxAngOutput
global EdgeAlpha EdgeOmega EdgeThreshold

set EdgeAlpha ""; set EdgeOmega ""; set EdgeThreshold ""

$widget(TitleFrame337_6) configure -state normal
$widget(Label337_3) configure -state normal
$widget(Entry337_3) configure -state normal
$widget(Button337_2) configure -state normal
$widget(Button337_3) configure -state normal
$widget(TitleFrame337_7) configure -state disable
$widget(Label337_4) configure -state disable
$widget(Entry337_4) configure -state disable
$widget(Label337_5) configure -state disable
$widget(Entry337_5) configure -state disable
$widget(Label337_6) configure -state disable
$widget(Entry337_6) configure -state disable
$widget(TitleFrame337_1) configure -state disable
$widget(TitleFrame337_2) configure -state disable
$widget(Entry337_7) configure -state disable
$widget(TitleFrame337_3) configure -state disable
$widget(Entry337_8) configure -state disable
$widget(TitleFrame337_4) configure -state disable
$widget(Entry337_9) configure -state disable
$widget(TitleFrame337_5) configure -state disable
$widget(Entry337_10) configure -state disable
$widget(TitleFrame337_8) configure -state normal
$widget(Entry337_11) configure -state normal

set EdgePaillouAmpOutput ""
set EdgePaillouMaxAmpOutput ""
set EdgePaillouAngOutput ""
set EdgePaillouMaxAngOutput ""
set EdgeCoeff "0.5"
set EdgeFileOutput "$EdgeDirOutput/"
append EdgeFileOutput "$EdgeDetector"
append EdgeFileOutput "_"
append EdgeFileOutput "$EdgeCoeff.bin"} \
        -padx 1 -text Rothwell -value rothwell -variable EdgeDetector 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra83" "Frame1" vTcl:WidgetProc "Toplevel337" 1
    set site_5_0 $site_4_0.fra83
    TitleFrame $site_5_0.cpd84 \
        -text {Detector Coefficient} 
    vTcl:DefineAlias "$site_5_0.cpd84" "TitleFrame337_6" vTcl:WidgetProc "Toplevel337" 1
    bind $site_5_0.cpd84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd84 getframe]
    frame $site_7_0.cpd87 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd87" "Frame8" vTcl:WidgetProc "Toplevel337" 1
    set site_8_0 $site_7_0.cpd87
    entry $site_8_0.cpd84 \
        -background white -disabledbackground #ffffff -foreground #0000ff \
        -justify center -state disabled -textvariable EdgeCoeff -width 4 
    vTcl:DefineAlias "$site_8_0.cpd84" "Entry337_3" vTcl:WidgetProc "Toplevel337" 1
    frame $site_8_0.fra85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame10" vTcl:WidgetProc "Toplevel337" 1
    set site_9_0 $site_8_0.fra85
    button $site_9_0.cpd86 \
        \
        -command {global EdgeFileOutput EdgeDetector EdgeCoeff

set EdgeCoeff [expr $EdgeCoeff - 0.1]
if {$EdgeCoeff == "-0.1"} {set EdgeCoeff 1}

set EdgeFileOutput "$EdgeDirOutput/"
append EdgeFileOutput "$EdgeDetector"
append EdgeFileOutput "_"
append EdgeFileOutput "$EdgeCoeff.bin"} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd86" "Button337_2" vTcl:WidgetProc "Toplevel337" 1
    button $site_9_0.cpd87 \
        \
        -command {global EdgeFileOutput EdgeDetector EdgeCoeff

set EdgeCoeff [expr $EdgeCoeff + 0.1]
if {$EdgeCoeff == "1.1"} {set EdgeCoeff "0.0"}

set EdgeFileOutput "$EdgeDirOutput/"
append EdgeFileOutput "$EdgeDetector"
append EdgeFileOutput "_"
append EdgeFileOutput "$EdgeCoeff.bin"} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd87" "Button337_3" vTcl:WidgetProc "Toplevel337" 1
    pack $site_9_0.cpd86 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_9_0.cpd87 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd84 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    label $site_7_0.cpd86 \
        -text {Coarse ( 0 ) ... Fine ( 1 )} 
    vTcl:DefineAlias "$site_7_0.cpd86" "Label337_3" vTcl:WidgetProc "Toplevel337" 1
    pack $site_7_0.cpd87 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd86 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_5_0.cpd85 \
        -text {Paillou Detector Parameters} 
    vTcl:DefineAlias "$site_5_0.cpd85" "TitleFrame337_7" vTcl:WidgetProc "Toplevel337" 1
    bind $site_5_0.cpd85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
    frame $site_7_0.cpd88
    set site_8_0 $site_7_0.cpd88
    frame $site_8_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd77" "Frame23" vTcl:WidgetProc "Toplevel337" 1
    set site_9_0 $site_8_0.cpd77
    label $site_9_0.cpd78 \
        -text Alpha 
    vTcl:DefineAlias "$site_9_0.cpd78" "Label337_4" vTcl:WidgetProc "Toplevel337" 1
    entry $site_9_0.cpd84 \
        -background white -disabledbackground #ffffff -foreground #ff0000 \
        -justify center -state disabled -textvariable EdgeAlpha -width 5 
    vTcl:DefineAlias "$site_9_0.cpd84" "Entry337_4" vTcl:WidgetProc "Toplevel337" 1
    pack $site_9_0.cpd78 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd84 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_8_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd80" "Frame24" vTcl:WidgetProc "Toplevel337" 1
    set site_9_0 $site_8_0.cpd80
    label $site_9_0.cpd78 \
        -text Omega 
    vTcl:DefineAlias "$site_9_0.cpd78" "Label337_5" vTcl:WidgetProc "Toplevel337" 1
    entry $site_9_0.cpd84 \
        -background white -disabledbackground #ffffff -foreground #ff0000 \
        -justify center -state disabled -textvariable EdgeOmega -width 5 
    vTcl:DefineAlias "$site_9_0.cpd84" "Entry337_5" vTcl:WidgetProc "Toplevel337" 1
    pack $site_9_0.cpd78 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd84 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd80 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd89
    set site_8_0 $site_7_0.cpd89
    frame $site_8_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd82" "Frame28" vTcl:WidgetProc "Toplevel337" 1
    set site_9_0 $site_8_0.cpd82
    label $site_9_0.cpd78 \
        -text Threshold 
    vTcl:DefineAlias "$site_9_0.cpd78" "Label337_6" vTcl:WidgetProc "Toplevel337" 1
    entry $site_9_0.cpd84 \
        -background white -disabledbackground #ffffff -foreground #ff0000 \
        -justify center -state disabled -textvariable EdgeThreshold -width 7 
    vTcl:DefineAlias "$site_9_0.cpd84" "Entry337_6" vTcl:WidgetProc "Toplevel337" 1
    pack $site_9_0.cpd78 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd84 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd89 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.fra83 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    TitleFrame $top.tit66 \
        -text {Paillou Detector} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame337_1" vTcl:WidgetProc "Toplevel337" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    TitleFrame $site_4_0.cpd67 \
        -ipad 2 -text {Output Gradient Amplitude File} 
    vTcl:DefineAlias "$site_4_0.cpd67" "TitleFrame337_2" vTcl:WidgetProc "Toplevel337" 1
    bind $site_4_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd67 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff -foreground #ff0000 \
        -textvariable EdgePaillouAmpOutput 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry337_7" vTcl:WidgetProc "Toplevel337" 1
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_4_0.cpd68 \
        -ipad 2 -text {Output Gradient Maximum Amplitude File} 
    vTcl:DefineAlias "$site_4_0.cpd68" "TitleFrame337_3" vTcl:WidgetProc "Toplevel337" 1
    bind $site_4_0.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd68 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff -foreground #ff0000 \
        -textvariable EdgePaillouMaxAmpOutput 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry337_8" vTcl:WidgetProc "Toplevel337" 1
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_4_0.cpd69 \
        -ipad 2 -text {Output Gradient Direction File} 
    vTcl:DefineAlias "$site_4_0.cpd69" "TitleFrame337_4" vTcl:WidgetProc "Toplevel337" 1
    bind $site_4_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd69 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff -foreground #ff0000 \
        -textvariable EdgePaillouAngOutput 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry337_9" vTcl:WidgetProc "Toplevel337" 1
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_4_0.cpd70 \
        -ipad 2 -text {Output Gradient Maximum Direction File} 
    vTcl:DefineAlias "$site_4_0.cpd70" "TitleFrame337_5" vTcl:WidgetProc "Toplevel337" 1
    bind $site_4_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd70 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff -foreground #ff0000 \
        -textvariable EdgePaillouMaxAngOutput 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry337_10" vTcl:WidgetProc "Toplevel337" 1
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame5" vTcl:WidgetProc "Toplevel337" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd99 \
        -ipad 2 -text {Output Binary File} 
    vTcl:DefineAlias "$site_3_0.cpd99" "TitleFrame337_8" vTcl:WidgetProc "Toplevel337" 1
    bind $site_3_0.cpd99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable EdgeFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry337_11" vTcl:WidgetProc "Toplevel337" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd99 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel337" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global EdgeDirOutput EdgeFileInput EdgeFileOutput
global EdgeDetector EdgeCoeff InputFormat OutputFormat 
global EdgePaillouAmpOutput EdgePaillouMaxAmpOutput
global EdgePaillouAngOutput EdgePaillouMaxAngOutput
global EdgeAlpha EdgeOmega EdgeThreshold
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global MinMaxAutoBMP MinMaxContrastBMP OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {"$EdgeFileInput"==""} {
    set VarError ""
    set ErrorMessage "INVALID INPUT FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    if {$EdgeDetector != "paillou"} {
        set EdgeDirOutput [file dirname $EdgeFileOutput]
        } else {
        set EdgeDirOutput [file dirname $EdgePaillouAmpOutput]
        }
    
    #####################################################################
    #Create Directory
    set EdgeDirOutput [PSPCreateDirectoryMask $EdgeDirOutput $EdgeDirOutput $EdgeDirInput]
    #####################################################################       
        if {"$VarWarning"=="ok"} {
            if {$MinMaxAutoBMP == 0} {
                if {$MinMaxContrastBMP == 0} {set MinMaxBMP 0}
                if {$MinMaxContrastBMP == 1} {set MinMaxBMP 2}
                }            
            if {$MinMaxAutoBMP == 1} {
                if {$MinMaxContrastBMP == 0} {set MinMaxBMP 3}
                if {$MinMaxContrastBMP == 1} {set MinMaxBMP 1}
                set MinBMP "-9999"
                set MaxBMP "+9999"
                }

            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            set TestVarName(4) "Min Value"; set TestVarType(4) "float"; set TestVarValue(4) $MinBMP; set TestVarMin(4) "-10000.00"; set TestVarMax(4) "10000.00"
            set TestVarName(5) "Max Value"; set TestVarType(5) "float"; set TestVarValue(5) $MaxBMP; set TestVarMin(5) "-10000.00"; set TestVarMax(5) "10000.00"
            TestVar 6
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
                set Fonction "Process an Edge Detection"
                set Fonction2 "Procedure : $EdgeDetector"    
                set MaskCmd ""
                set MaskDir [file dirname $EdgeFileInput]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                if {$EdgeDetector == "black"} { set EdgeSoft "Soft/bin/data_process_sngl/edge_detector_black.exe" }
                if {$EdgeDetector == "canny"} { set EdgeSoft "Soft/bin/data_process_sngl/edge_detector_canny.exe" }
                if {$EdgeDetector == "marr"} { set EdgeSoft "Soft/bin/data_process_sngl/edge_detector_marr.exe" }
                if {$EdgeDetector == "paillou"} { set EdgeSoft "Soft/bin/data_process_sngl/edge_detector_paillou.exe" }
                if {$EdgeDetector == "rothwell"} { set EdgeSoft "Soft/bin/data_process_sngl/edge_detector_rothwell.exe" }
                TextEditorRunTrace "Process The Function $EdgeSoft" "k"
                if {$EdgeDetector == "paillou"} {
                    TextEditorRunTrace "Arguments: -if \x22$EdgeFileInput\x22 -od \x22$EdgeDirOutput\x22 -idf $InputFormat -odf $OutputFormat -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mmb $MinMaxBMP -min $MinBMP -max $MaxBMP -alp $EdgeAlpha -ome $EdgeOmega -thr $EdgeThreshold -of1 \x22$EdgePaillouAmpOutput\x22 -of2 \x22$EdgePaillouAngOutput\x22 -of3 \x22$EdgePaillouMaxAmpOutput\x22 -of4 \x22$EdgePaillouMaxAngOutput\x22 $MaskCmd" "k"
                    set f [ open "| $EdgeSoft -if \x22$EdgeFileInput\x22 -od \x22$EdgeDirOutput\x22 -idf $InputFormat -odf $OutputFormat -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mmb $MinMaxBMP -min $MinBMP -max $MaxBMP -alp $EdgeAlpha -ome $EdgeOmega -thr $EdgeThreshold -of1 \x22$EdgePaillouAmpOutput\x22 -of2 \x22$EdgePaillouAngOutput\x22 -of3 \x22$EdgePaillouMaxAmpOutput\x22 -of4 \x22$EdgePaillouMaxAngOutput\x22 $MaskCmd" r]
                    } else {
                    TextEditorRunTrace "Arguments: -if \x22$EdgeFileInput\x22 -od \x22$EdgeDirOutput\x22 -idf $InputFormat -odf $OutputFormat -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mmb $MinMaxBMP -min $MinBMP -max $MaxBMP -det $EdgeCoeff -of \x22$EdgeFileOutput\x22 $MaskCmd" "k"
                    set f [ open "| $EdgeSoft -if \x22$EdgeFileInput\x22 -od \x22$EdgeDirOutput\x22 -idf $InputFormat -odf $OutputFormat -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mmb $MinMaxBMP -min $MinBMP -max $MaxBMP -det $EdgeCoeff -of \x22$EdgeFileOutput\x22 $MaskCmd" r]
                    }
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                if {$EdgeDetector != "paillou"} {
                    if [file exists $EdgeFileOutput] {
                        EnviWriteConfig $EdgeFileOutput $FinalNlig $FinalNcol 4
                        set BMPDirInput $EdgeDirOutput
                        set BMPFileInput $EdgeFileOutput
                        set BMPFileOutput [file rootname $EdgeFileOutput]
                        append BMPFileOutput ".bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 1
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE $EdgeFileOutput DOES NOT EXIST" 
                        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }   
                    } else {
                    if [file exists $EdgePaillouAmpOutput] {
                        EnviWriteConfig $EdgePaillouAmpOutput $FinalNlig $FinalNcol 4
                        set BMPFileInput $EdgePaillouAmpOutput
                        set BMPFileOutput [file rootname $EdgePaillouAmpOutput]
                        append BMPFileOutput ".bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 1
                        EnviWriteConfig $EdgePaillouMaxAmpOutput $FinalNlig $FinalNcol 4
                        set BMPFileInput $EdgePaillouMaxAmpOutput
                        set BMPFileOutput [file rootname $EdgePaillouMaxAmpOutput]
                        append BMPFileOutput ".bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 1
                        EnviWriteConfig $EdgePaillouAngOutput $FinalNlig $FinalNcol 4
                        set BMPFileInput $EdgePaillouAngOutput
                        set BMPFileOutput [file rootname $EdgePaillouAngOutput]
                        append BMPFileOutput ".bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 1
                        EnviWriteConfig $EdgePaillouMaxAngOutput $FinalNlig $FinalNcol 4
                        set BMPFileInput $EdgePaillouMaxAngOutput
                        set BMPFileOutput [file rootname $EdgePaillouMaxAngOutput]
                        append BMPFileOutput ".bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 1
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE $EdgePaillouAmpOutput DOES NOT EXIST" 
                        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }                      
                    }
                }
            } else {
            if {"$VarWarning"=="no"} {Window hide $widget(Toplevel337); TextEditorRunTrace "Close Window Edge Detector" "b"}
            }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel337" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/EdgeDetector.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel337" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel337); TextEditorRunTrace "Close Window Edge Detector" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel337" 1
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
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra51 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit85 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit97 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd90 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -padx 10 -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra38 \
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
Window show .top337

main $argc $argv
