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
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images DecrDir.gif]} {user image} user {}}
        {{[file join . GUI Images HomeDir.gif]} {user image} user {}}
        {{[file join . GUI Images PolSARproSIM.gif]} {user image} user {}}
        {{[file join . GUI Images help_book.gif]} {user image} user {}}

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
    set base .top400
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.cpd122 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.lab71 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd82 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit95 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit95 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd87
    namespace eval ::widgets::$site_5_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra81
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd85
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd88
    namespace eval ::widgets::$site_5_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra81
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd85
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd91 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd91 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd84
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd85
    namespace eval ::widgets::$site_7_0.cpd83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd98
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd87
    namespace eval ::widgets::$site_6_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra81
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd85
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd88
    namespace eval ::widgets::$site_6_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra81
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd85
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd100
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd101
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-_tooltip 1 -background 1 -disabledforeground 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd108 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd102
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-_tooltip 1 -background 1 -disabledforeground 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd109 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd95
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd85
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd106 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd106 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd98
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd87
    namespace eval ::widgets::$site_6_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra81
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd88
    namespace eval ::widgets::$site_6_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra81
    namespace eval ::widgets::$site_7_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd100
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd101
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-_tooltip 1 -background 1 -disabledforeground 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd110 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd95 {
        array set save {-width 1}
    }
    set site_5_0 $site_4_0.cpd95
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd85
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd111 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd111
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra112 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra112
    namespace eval ::widgets::$site_3_0.fra113 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra113
    namespace eval ::widgets::$site_4_0.cpd118 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_4_0.lab115 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent116 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd117 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_3_0.but114 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra119 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra119
    namespace eval ::widgets::$site_3_0.cpd120 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd120
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd121 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd121
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd123 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd123 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
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
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top400
            PSPSIMWrite
            PSPSIM_RGB_S2
            PSPSIM_RGB_SPP
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
## Procedure:  PSPSIMWrite

proc ::PSPSIMWrite {} {
global OpenDirFile
global PSPSIMAltitude PSPSIMIncAngle1 PSPSIMIncAngle2
global PSPSIMSlantRange1 PSPSIMSlantRange2
global PSPSIMHorBaseline PSPSIMVerBaseline
global PSPSIMFrequency PSPSIMAzResol PSPSIMRgResol
global PSPSIMSurface PSPSIMMoisture PSPSIMAzSlope PSPSIMRgSlope
global PSPSIMTreeSpecies PSPSIMTreeHeight PSPSIMForestArea PSPSIMForestDensity
global PSPSIMRandom PSPSIMNrows PSPSIMNcols PSPSIMConfig

if {$OpenDirFile == 0} {

set PSPSIMSlantRange1 [expr $PSPSIMAltitude / cos([expr $PSPSIMIncAngle1 * 3.1415926 / 180.0])]
set PSPSIMGroundRange1 [expr $PSPSIMSlantRange1 * sin([expr $PSPSIMIncAngle1 * 3.1415926 / 180.0])]
set PSPSIMGroundRange2 [expr $PSPSIMGroundRange1 + $PSPSIMHorBaseline]
set PSPSIMAltitude2 [expr $PSPSIMAltitude + $PSPSIMVerBaseline]
set PSPSIMIncAngle2 [expr atan2($PSPSIMGroundRange2,$PSPSIMAltitude2)]
set PSPSIMSlantRange2 [expr $PSPSIMAltitude2 / cos($PSPSIMIncAngle2)]
set PSPSIMIncAngle2 [expr $PSPSIMIncAngle2 * 180.0 / 3.1415926]
set PSPSIMForestArea [expr $PSPSIMForestArea * 10000.0]

set PSPSIMFile "$PSPSIMConfig.sar"
set f [open $PSPSIMFile "w"]
puts $f [format "%-*d%s" 12 2 "/* The number of requested tracks                                */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMSlantRange1 "/* Slant range (broadside platform to scene centre) in metres    */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMIncAngle1 "/* Incidence angle in degrees                                    */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMSlantRange2 "/* Slant range (broadside platform to scene centre) in metres    */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMIncAngle2 "/* Incidence angle in degrees                                    */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMFrequency "/* Centre frequency in GHz                                       */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMAzResol "/* Azimuth resolution (width at half-height power) in metres     */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMRgResol "/* Slant range resolution (width at half-height power) in metres */"]
puts $f [format "%-*d%s" 12 $PSPSIMSurface "/* DEM model: 0 = perfectly smooth … 10 = very rough             */"]
puts $f [format "%-*.4f%s" 12 [expr ( $PSPSIMAzSlope / 100.0) ] "/* Ground slope in azimuth direction (dimensionless)             */"]
puts $f [format "%-*.4f%s" 12 [expr ( $PSPSIMRgSlope / 100.0) ] "/* Ground slope in ground range direction (dimensionless)        */"]
puts $f [format "%-*d%s" 12 $PSPSIMRandom "/* Random number generator seed                                  */"]
puts $f [format "%-*d%s" 12 $PSPSIMTreeSpecies "/* Tree species: 0 = HEDGE, 1,2,3 = PINE, 4 = DECIDUOUS          */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMTreeHeight "/* Mean tree height in metres                                    */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMForestArea "/* Area of the forest stand in square metres                     */"]
puts $f [format "%-*.4f%s" 12 $PSPSIMForestDensity "/* Desired stand density in stems per hectare                    */"]
puts $f [format "%-*d%s" 12 $PSPSIMMoisture "/* Ground moisture content model: 0 = driest ... 10  = wettest   */"]
close $f
}
}
#############################################################################
## Procedure:  PSPSIM_RGB_S2

proc ::PSPSIM_RGB_S2 {DirInputOutput} {
global ConvertDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError
   
set RGBDirInput $DirInputOutput
set RGBDirOutput $DirInputOutput
set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
set config "true"
set fichier "$RGBDirInput/s11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s12.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s12.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s21.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s21.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto 1" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  PSPSIM_RGB_SPP

proc ::PSPSIM_RGB_SPP {DirInputOutput} {
global ConvertDirOutput BMPDirInput PSPOutputFormat
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError
   
set RGBDirInput $DirInputOutput
set RGBDirOutput $DirInputOutput
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
set Channel1 ""
set Channel2 ""

if {$PSPOutputFormat == "dualpp1"} {set Channel1 "s11"; set Channel2 "s21"}
if {$PSPOutputFormat == "dualpp2"} {set Channel1 "s22"; set Channel2 "s12"}
if {$PSPOutputFormat == "dualpp3"} {set Channel1 "s11"; set Channel2 "s22"}
set config "true"
set fichier "$RGBDirInput/"
append fichier "$Channel1.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/"
append fichier "$Channel2.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
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

proc vTclWindow.top400 {base} {
    if {$base == ""} {
        set base .top400
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
    wm title $top "PolSARpro Forest Simulator (c) Dr Mark L. Williams"
    vTcl:DefineAlias "$top" "Toplevel400" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame1" vTcl:WidgetProc "Toplevel400" 1
    set site_3_0 $top.fra69
    button $site_3_0.cpd122 \
        -background #ffff00 \
        -command {global OpenDirFile TMPPolSARproSIM DataDirChannel1 DataDirChannel2
global PSPSIMChannel1 PSPSIMChannel2 PSPOutputFormat
global PSPSIMAltitude PSPSIMIncAngle1 PSPSIMIncAngle2
global PSPSIMSlantRange1 PSPSIMSlantRange2
global PSPSIMHorBaseline PSPSIMVerBaseline
global PSPSIMFrequency PSPSIMAzResol PSPSIMRgResol
global PSPSIMSurface PSPSIMMoisture PSPSIMAzSlope PSPSIMRgSlope
global PSPSIMTreeSpecies PSPSIMTreeHeight PSPSIMForestArea PSPSIMForestDensity
global PSPSIMRandom PSPSIMNrows PSPSIMNcols PSPSIMConfig
global PSPSIMLx PSPSIMLy PSPSIMDx PSPSIMDy
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global ProgressLine ConfigFile FinalNlig FinalNcol PolarCase PolarType

set TestVarError ""
set TestVarName(0) "Platform Altitude"; set TestVarType(0) "float"; set TestVarValue(0) $PSPSIMAltitude; set TestVarMin(0) "1"; set TestVarMax(0) ""
set TestVarName(1) "Incidence Angle"; set TestVarType(1) "float"; set TestVarValue(1) $PSPSIMIncAngle1; set TestVarMin(1) "0"; set TestVarMax(1) "90"
set TestVarName(2) "Horizontal Baseline"; set TestVarType(2) "float"; set TestVarValue(2) $PSPSIMHorBaseline; set TestVarMin(2) ""; set TestVarMax(2) ""
set TestVarName(3) "Vertical Baseline"; set TestVarType(3) "float"; set TestVarValue(3) $PSPSIMVerBaseline; set TestVarMin(3) ""; set TestVarMax(3) ""
set TestVarName(4) "Centre Frequency"; set TestVarType(4) "float"; set TestVarValue(4) $PSPSIMFrequency; set TestVarMin(4) "0"; set TestVarMax(4) ""
set TestVarName(5) "Azimut Resolution"; set TestVarType(5) "float"; set TestVarValue(5) $PSPSIMAzResol; set TestVarMin(5) "0"; set TestVarMax(5) ""
set TestVarName(6) "Range Resolution"; set TestVarType(6) "float"; set TestVarValue(6) $PSPSIMRgResol; set TestVarMin(6) "0"; set TestVarMax(6) ""
set TestVarName(7) "Azimut Slope"; set TestVarType(7) "float"; set TestVarValue(7) $PSPSIMAzSlope; set TestVarMin(7) "0"; set TestVarMax(7) "100"
set TestVarName(8) "Range Slope"; set TestVarType(8) "float"; set TestVarValue(8) $PSPSIMRgSlope; set TestVarMin(8) "0"; set TestVarMax(8) "100"
set TestVarName(9) "Tree Mean Height"; set TestVarType(9) "float"; set TestVarValue(9) $PSPSIMTreeHeight; set TestVarMin(9) "0"; set TestVarMax(9) ""
set TestVarName(10) "Forest Stand Density"; set TestVarType(10) "int"; set TestVarValue(10) $PSPSIMForestDensity; set TestVarMin(10) "0"; set TestVarMax(10) ""
set TestVarName(11) "Forest Stand Area"; set TestVarType(11) "float"; set TestVarValue(11) $PSPSIMForestArea; set TestVarMin(11) "0"; set TestVarMax(11) ""
set TestVarName(12) "Random Number Generator"; set TestVarType(12) "int"; set TestVarValue(12) $PSPSIMRandom; set TestVarMin(12) "0"; set TestVarMax(12) "65535"
TestVar 13

if {$TestVarError == "ok"} {

if {$OpenDirFile == 0} {
        
    #####################################################################
    #Create Directory
    set config1 "ok"
    set DirNameCreate $PSPSIMChannel1
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixS $DirNameCreate
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            set config1 "ok"
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set config1 "no"
            }
        }
    #####################################################################       
    #####################################################################
    #Create Directory
    set config2 "ok"
    set DirNameCreate $PSPSIMChannel2
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixS $DirNameCreate
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            set config2 "ok"
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set config2 "no"
            }
        }
    #####################################################################       
    set config $config1
    append config $config2

    if {$config == "okok"} {

        PSPSIMWrite

        set Fonction "PolSARpro Forest Simulator"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/PolSARproSIM/PolSARproSim.exe" "k"
        TextEditorRunTrace "Arguments: \x22$PSPSIMConfig\x22 \x22$PSPSIMChannel1\x22 \x22$PSPSIMChannel2\x22" "k"
        set f [ open "| Soft/PolSARproSIM/PolSARproSim.exe \x22$PSPSIMConfig\x22 \x22$PSPSIMChannel1\x22 \x22$PSPSIMChannel2\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set FinalNlig $PSPSIMNrows; set FinalNcol $PSPSIMNcols
        set PolarCase "monostatic"; set PolarType "full"
        if {$PSPOutputFormat != "quad"} {
            if {$PSPOutputFormat == "dualpp1"} {
                set PolarCase "monostatic"; set PolarType "pp1"
                DeleteFile "$PSPSIMChannel1/s12.bin"
                DeleteFile "$PSPSIMChannel1/s22.bin"
                DeleteFile "$PSPSIMChannel2/s12.bin"
                DeleteFile "$PSPSIMChannel2/s22.bin"
                }
            if {$PSPOutputFormat == "dualpp2"} {
                set PolarCase "monostatic"; set PolarType "pp2"
                DeleteFile "$PSPSIMChannel1/s11.bin"
                DeleteFile "$PSPSIMChannel1/s21.bin"
                DeleteFile "$PSPSIMChannel2/s11.bin"
                DeleteFile "$PSPSIMChannel2/s21.bin"
                }
            if {$PSPOutputFormat == "dualpp3"} {
                set PolarCase "monostatic"; set PolarType "pp3"
                DeleteFile "$PSPSIMChannel1/s12.bin"
                DeleteFile "$PSPSIMChannel1/s21.bin"
                DeleteFile "$PSPSIMChannel2/s12.bin"
                DeleteFile "$PSPSIMChannel2/s21.bin"
                }
            }
        set config ""       
        set ConfigFile "$PSPSIMChannel1/config.txt"
        WriteConfig
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            EnviWriteConfigS $PSPSIMChannel1 $NligFullSize $NcolFullSize
            if {$PSPOutputFormat == "quad"} {
                PSPSIM_RGB_S2 $PSPSIMChannel1
                } else {
                PSPSIM_RGB_SPP $PSPSIMChannel1
                }
            set DataDirChannel1 $PSPSIMChannel1
            MenuOn
            append config "master"
            } else {
            append ErrorMessage " -> An ERROR occured during the SIMULATION"
            set VarError ""
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            }
    
        set ConfigFile "$PSPSIMChannel2/config.txt"
        WriteConfig
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            EnviWriteConfigS $PSPSIMChannel2 $NligFullSize $NcolFullSize
            if {$PSPOutputFormat == "quad"} {
                PSPSIM_RGB_S2 $PSPSIMChannel2
                } else {
                PSPSIM_RGB_SPP $PSPSIMChannel2
                }
            set DataDirChannel2 $PSPSIMChannel2
            MenuOn
            append config "slave"
            } else {
            append ErrorMessage " -> An ERROR occured during the SIMULATION"
            set VarError ""
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            }

        if {$config == "masterslave"} {
            set Fonction "PolSARpro Forest Simulator"
            set Fonction2 "Flat Earth - Kz"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/PolSARproSIM/PolSARproSim_FE_Kz.exe" "k"
            TextEditorRunTrace "Arguments: \x22$PSPSIMChannel2\x22 $PSPSIMNrows $PSPSIMNcols $PSPSIMDy $PSPSIMFrequency $PSPSIMIncAngle1 $PSPSIMAltitude $PSPSIMHorBaseline $PSPSIMVerBaseline" "k"
            set f [ open "| Soft/PolSARproSIM/PolSARproSim_FE_Kz.exe \x22$PSPSIMChannel2\x22 $PSPSIMNrows $PSPSIMNcols $PSPSIMDy $PSPSIMFrequency $PSPSIMIncAngle1 $PSPSIMAltitude $PSPSIMHorBaseline $PSPSIMVerBaseline" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
 
        Window hide $widget(Toplevel400); TextEditorRunTrace "Close PolSARpro Forest Simulator" "b"
        } else {
        if {$config =="nono"} {Window hide $widget(Toplevel400); TextEditorRunTrace "Close PolSARpro Forest Simulator" "b"}
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.cpd122" "Button400_0" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_3_0.cpd122 "$site_3_0.cpd122 Button $top all _vTclBalloon"
    bind $site_3_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.cpd71 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolSARproSIM.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -padx 1 -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.cpd71" "Button3" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_3_0.cpd71 "$site_3_0.cpd71 Button $top all _vTclBalloon"
    bind $site_3_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but72 \
        -background #ffffff \
        -command {HelpPdfEdit "TechDoc/PolSARproSimulator/PolSARproSim_Design.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help_book.gif]] \
        -padx 4 -pady 2 -text button -width 25 
    vTcl:DefineAlias "$site_3_0.but72" "Button4" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_3_0.but72 "$site_3_0.but72 Button $top all _vTclBalloon"
    bind $site_3_0.but72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Technical Documentation}
    }
    button $site_3_0.cpd70 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel400); TextEditorRunTrace "Close Window PolSARpro Forest Simulator" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.cpd70" "Button2" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_3_0.cpd70 "$site_3_0.cpd70 Button $top all _vTclBalloon"
    bind $site_3_0.cpd70 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd122 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    label $top.lab71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PolSARproSIM.gif]] \
        -relief sunken -text label 
    vTcl:DefineAlias "$top.lab71" "Label2" vTcl:WidgetProc "Toplevel400" 1
    TitleFrame $top.tit92 \
        -ipad 0 -text {Output Master Directory} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame1" vTcl:WidgetProc "Toplevel400" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    frame $site_4_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame5" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.fra81
    button $site_5_0.cpd82 \
        \
        -command {global DirName PSPSIMChannel1

MenuOff

set DataDirTmp $PSPSIMChannel1
set DirName ""
OpenDir $PSPSIMChannel1 "DATA OUTPUT MASTER DIRECTORY"
if {$DirName != ""} {
    set PSPSIMChannel1 $DirName
    } else {
    set PSPSIMChannel1 $DataDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button400_1" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_5_0.cpd72 \
        \
        -command {global PSPSIMChannel1 OpenDirFile

if {$OpenDirFile == 0} {
MenuOff
set PSPSIMChannel1 [file dirname $PSPSIMChannel1]
}} \
        -image [vTcl:image:get_image [file join . GUI Images DecrDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button400_2" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Parent Directory}
    }
    button $site_5_0.cpd73 \
        \
        -command {global PSPSIMChannel1 OpenDirFile

if {$OpenDirFile == 0} {
MenuOff
set PSPSIMChannel1 $env(HOME)
}} \
        -image [vTcl:image:get_image [file join . GUI Images HomeDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button400_3" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Home Directory}
    }
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PSPSIMChannel1 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry100" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd82 \
        -ipad 0 -text {Output Slave Directory} 
    vTcl:DefineAlias "$top.cpd82" "TitleFrame3" vTcl:WidgetProc "Toplevel400" 1
    bind $top.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd82 getframe]
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PSPSIMChannel2 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry200" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    frame $site_4_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame8" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.fra81
    button $site_5_0.cpd82 \
        \
        -command {global DirName PSPSIMChannel2

MenuOff

set DataDirTmp $PSPSIMChannel2
set DirName ""
OpenDir $PSPSIMChannel2 "DATA OUTPUT SLAVE DIRECTORY"
if {$DirName != ""} {
    set PSPSIMChannel2 $DirName
    } else {
    set PSPSIMChannel2 $DataDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button400_4" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_5_0.cpd72 \
        \
        -command {global PSPSIMChannel2 OpenDirFile

if {$OpenDirFile == 0} {
MenuOff
set PSPSIMChannel2 [file dirname $PSPSIMChannel2]
}} \
        -image [vTcl:image:get_image [file join . GUI Images DecrDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button400_5" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Parent Directory}
    }
    button $site_5_0.cpd73 \
        \
        -command {global PSPSIMChannel2 OpenDirFile

if {$OpenDirFile == 0} {
MenuOff
set PSPSIMChannel2 $env(HOME)
}} \
        -image [vTcl:image:get_image [file join . GUI Images HomeDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button400_6" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Home Directory}
    }
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.tit95 \
        -ipad 0 -text {Geometric Configuration} 
    vTcl:DefineAlias "$top.tit95" "TitleFrame2" vTcl:WidgetProc "Toplevel400" 1
    bind $top.tit95 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit95 getframe]
    frame $site_4_0.cpd87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd87" "Frame4" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.cpd87
    frame $site_5_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra81" "Frame14" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.fra81
    label $site_6_0.lab83 \
        -text {Platform Altitude ( m )} 
    vTcl:DefineAlias "$site_6_0.lab83" "Label1" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMAltitude -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry1" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    frame $site_5_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd85" "Frame16" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd85
    label $site_6_0.lab83 \
        -text {Incidence Angle ( deg )  } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label6" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMIncAngle1 -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry2" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.fra81 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd88" "Frame12" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.cpd88
    frame $site_5_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra81" "Frame15" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.fra81
    label $site_6_0.lab83 \
        -text {Horizontal Baseline ( m )  } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label7" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMHorBaseline -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry3" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    frame $site_5_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd85" "Frame17" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd85
    label $site_6_0.lab83 \
        -text {Vertical Baseline ( m )} 
    vTcl:DefineAlias "$site_6_0.lab83" "Label8" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMVerBaseline -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry4" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.fra81 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    TitleFrame $top.cpd91 \
        -ipad 0 -text {System Configuration} 
    vTcl:DefineAlias "$top.cpd91" "TitleFrame5" vTcl:WidgetProc "Toplevel400" 1
    bind $top.cpd91 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd91 getframe]
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame18" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame44" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd78
    label $site_6_0.lab83 \
        -text {Centre Frequency ( GHz )  } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label34" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMFrequency -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry14" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame37" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.cpd77
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame42" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd74
    frame $site_6_0.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd84" "Frame45" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd84
    label $site_7_0.lab83 \
        -text {Azimuth Resolution ( m )   } 
    vTcl:DefineAlias "$site_7_0.lab83" "Label35" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd85 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd85" "Frame47" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd85
    label $site_7_0.cpd83 \
        -text {Slant Range Resolution ( m ) } 
    vTcl:DefineAlias "$site_7_0.cpd83" "Label39" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.cpd83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame46" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd80
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMAzResol -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry17" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.cpd81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMRgResol -width 10 
    vTcl:DefineAlias "$site_6_0.cpd81" "Entry18" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {Ground Surface Configuration} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame4" vTcl:WidgetProc "Toplevel400" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    frame $site_4_0.cpd98
    set site_5_0 $site_4_0.cpd98
    frame $site_5_0.cpd87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd87" "Frame6" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd87
    frame $site_6_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra81" "Frame21" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.fra81
    label $site_7_0.lab83 \
        -text {Surface Properties} 
    vTcl:DefineAlias "$site_7_0.lab83" "Label3" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd85" "Frame26" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd85
    label $site_7_0.lab83 \
        -text {Ground Moisture Content} 
    vTcl:DefineAlias "$site_7_0.lab83" "Label18" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra81 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd88" "Frame27" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd88
    frame $site_6_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra81" "Frame28" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.fra81
    label $site_7_0.lab83 \
        -text {(  Smoothest = 0} 
    vTcl:DefineAlias "$site_7_0.lab83" "Label19" vTcl:WidgetProc "Toplevel400" 1
    label $site_7_0.cpd73 \
        -text {(  Driest = 0} 
    vTcl:DefineAlias "$site_7_0.cpd73" "Label27" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd85" "Frame29" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd85
    label $site_7_0.lab83 \
        -text {  .....  } 
    vTcl:DefineAlias "$site_7_0.lab83" "Label20" vTcl:WidgetProc "Toplevel400" 1
    label $site_7_0.cpd74 \
        -text {  .....  } 
    vTcl:DefineAlias "$site_7_0.cpd74" "Label29" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame34" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd75
    label $site_7_0.lab83 \
        -text {Roughest = 10  )} 
    vTcl:DefineAlias "$site_7_0.lab83" "Label31" vTcl:WidgetProc "Toplevel400" 1
    label $site_7_0.cpd74 \
        -text {Wettest = 10  )} 
    vTcl:DefineAlias "$site_7_0.cpd74" "Label32" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra81 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd100" "Frame2" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd100
    frame $site_6_0.cpd101 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd101" "Frame10" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd101
    label $site_7_0.cpd72 \
        -background #ffffff -disabledforeground #ffffff -foreground #0000ff \
        -relief sunken -textvariable PSPSIMSurface -width 5 
    vTcl:DefineAlias "$site_7_0.cpd72" "Label11" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_7_0.cpd72 "$site_7_0.cpd72 Label $top all _vTclBalloon"
    bind $site_7_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {DIsplay Screen Width Size}
    }
    button $site_7_0.but75 \
        \
        -command {global PSPSIMSurface

set PSPSIMSurface [expr $PSPSIMSurface +1]
if {$PSPSIMSurface == "11" } { set PSPSIMSurface "0" }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.but75" "Button13" vTcl:WidgetProc "Toplevel400" 1
    button $site_7_0.but76 \
        \
        -command {global PSPSIMSurface

set PSPSIMSurface [expr $PSPSIMSurface -1]
if {$PSPSIMSurface == "-1" } { set PSPSIMSurface "10" }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but76" "Button14" vTcl:WidgetProc "Toplevel400" 1
    label $site_7_0.cpd108 \
        -width 5 
    vTcl:DefineAlias "$site_7_0.cpd108" "Label5" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.but75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.but76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd108 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.cpd102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd102" "Frame11" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd102
    label $site_7_0.cpd72 \
        -background #ffffff -disabledforeground #ffffff -foreground #0000ff \
        -relief sunken -textvariable PSPSIMMoisture -width 5 
    vTcl:DefineAlias "$site_7_0.cpd72" "Label22" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_7_0.cpd72 "$site_7_0.cpd72 Label $top all _vTclBalloon"
    bind $site_7_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {DIsplay Screen Width Size}
    }
    button $site_7_0.but75 \
        \
        -command {global PSPSIMMoisture

set PSPSIMMoisture [expr $PSPSIMMoisture +1]
if {$PSPSIMMoisture == "11" } { set PSPSIMMoisture "0" }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.but75" "Button15" vTcl:WidgetProc "Toplevel400" 1
    button $site_7_0.but76 \
        \
        -command {global PSPSIMMoisture

set PSPSIMMoisture [expr $PSPSIMMoisture -1]
if {$PSPSIMMoisture == "-1" } { set PSPSIMMoisture "10" }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but76" "Button16" vTcl:WidgetProc "Toplevel400" 1
    label $site_7_0.cpd109 \
        -width 5 
    vTcl:DefineAlias "$site_7_0.cpd109" "Label9" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.but75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.but76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd109 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    frame $site_4_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd95" "Frame22" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.cpd95
    frame $site_5_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd85" "Frame24" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd85
    label $site_6_0.lab83 \
        -text {Azimuth Ground Slope ( % )   } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label16" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMAzSlope -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry9" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame25" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd92
    label $site_6_0.lab83 \
        -text {Range Ground Slope ( % ) } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label17" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMRgSlope -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry10" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.cpd95 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd106 \
        -ipad 0 -text {Forest Configuration} 
    vTcl:DefineAlias "$top.cpd106" "TitleFrame6" vTcl:WidgetProc "Toplevel400" 1
    bind $top.cpd106 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd106 getframe]
    frame $site_4_0.cpd98
    set site_5_0 $site_4_0.cpd98
    frame $site_5_0.cpd87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd87" "Frame7" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd87
    frame $site_6_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra81" "Frame23" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.fra81
    label $site_7_0.lab83 \
        -text {Tree Species} 
    vTcl:DefineAlias "$site_7_0.lab83" "Label4" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra81 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd88" "Frame31" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd88
    frame $site_6_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra81" "Frame32" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.fra81
    label $site_7_0.lab83 \
        -text {Hedge ( 0 )   Pine (1 , 2 , 3 )   Deciduous ( 4 )} 
    vTcl:DefineAlias "$site_7_0.lab83" "Label23" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.lab83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra81 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd100" "Frame3" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd100
    frame $site_6_0.cpd101 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd101" "Frame13" vTcl:WidgetProc "Toplevel400" 1
    set site_7_0 $site_6_0.cpd101
    label $site_7_0.cpd72 \
        -background #ffffff -disabledforeground #ffffff -foreground #0000ff \
        -relief sunken -textvariable PSPSIMTreeSpecies -width 5 
    vTcl:DefineAlias "$site_7_0.cpd72" "Label15" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_7_0.cpd72 "$site_7_0.cpd72 Label $top all _vTclBalloon"
    bind $site_7_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {DIsplay Screen Width Size}
    }
    button $site_7_0.but75 \
        \
        -command {global PSPSIMTreeSpecies

set PSPSIMTreeSpecies [expr $PSPSIMTreeSpecies +1]
if {$PSPSIMTreeSpecies == "5" } { set PSPSIMTreeSpecies "0" }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.but75" "Button17" vTcl:WidgetProc "Toplevel400" 1
    button $site_7_0.but76 \
        \
        -command {global PSPSIMTreeSpecies

set PSPSIMTreeSpecies [expr $PSPSIMTreeSpecies -1]
if {$PSPSIMTreeSpecies == "-1" } { set PSPSIMTreeSpecies "4" }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but76" "Button18" vTcl:WidgetProc "Toplevel400" 1
    label $site_7_0.cpd110 \
        -width 5 
    vTcl:DefineAlias "$site_7_0.cpd110" "Label10" vTcl:WidgetProc "Toplevel400" 1
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.but75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.but76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd110 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    frame $site_4_0.cpd95 \
        -width 125 
    vTcl:DefineAlias "$site_4_0.cpd95" "Frame35" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.cpd95
    frame $site_5_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd85" "Frame36" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd85
    label $site_6_0.lab83 \
        -text {Tree Height ( m ) } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label26" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMTreeHeight -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry11" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    frame $site_5_0.cpd111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd111" "Frame38" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd111
    label $site_6_0.lab83 \
        -text {Forest Stand Density ( stems / Ha )   } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label28" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMForestDensity -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry13" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd111 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame41" vTcl:WidgetProc "Toplevel400" 1
    set site_5_0 $site_4_0.cpd71
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame43" vTcl:WidgetProc "Toplevel400" 1
    set site_6_0 $site_5_0.cpd92
    label $site_6_0.lab83 \
        -text {Forest Stand Circular Area ( Ha )   } 
    vTcl:DefineAlias "$site_6_0.lab83" "Label30" vTcl:WidgetProc "Toplevel400" 1
    entry $site_6_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PSPSIMForestArea -width 10 
    vTcl:DefineAlias "$site_6_0.ent84" "Entry15" vTcl:WidgetProc "Toplevel400" 1
    pack $site_6_0.lab83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.cpd95 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra112 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra112" "Frame9" vTcl:WidgetProc "Toplevel400" 1
    set site_3_0 $top.fra112
    frame $site_3_0.fra113 \
        -borderwidth 4 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra113" "Frame30" vTcl:WidgetProc "Toplevel400" 1
    set site_4_0 $site_3_0.fra113
    label $site_4_0.cpd118 \
        -width 1 
    vTcl:DefineAlias "$site_4_0.cpd118" "Label25" vTcl:WidgetProc "Toplevel400" 1
    label $site_4_0.lab115 \
        -text {Random Number Generator   } 
    vTcl:DefineAlias "$site_4_0.lab115" "Label21" vTcl:WidgetProc "Toplevel400" 1
    entry $site_4_0.ent116 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -relief ridge -textvariable PSPSIMRandom -width 10 
    vTcl:DefineAlias "$site_4_0.ent116" "Entry8" vTcl:WidgetProc "Toplevel400" 1
    label $site_4_0.cpd117 \
        -width 1 
    vTcl:DefineAlias "$site_4_0.cpd117" "Label24" vTcl:WidgetProc "Toplevel400" 1
    pack $site_4_0.cpd118 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.lab115 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent116 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd117 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.but114 \
        -background #ffff00 \
        -command {global OpenDirFile TMPPolSARproSIM
global PSPSIMChannel1 PSPSIMChannel2
global PSPSIMAltitude PSPSIMIncAngle1 PSPSIMIncAngle2
global PSPSIMSlantRange1 PSPSIMSlantRange2
global PSPSIMHorBaseline PSPSIMVerBaseline
global PSPSIMFrequency PSPSIMAzResol PSPSIMRgResol
global PSPSIMSurface PSPSIMMoisture PSPSIMAzSlope PSPSIMRgSlope
global PSPSIMTreeSpecies PSPSIMTreeHeight PSPSIMForestArea PSPSIMForestDensity
global PSPSIMRandom PSPSIMNrows PSPSIMNcols PSPSIMConfig
global PSPSIMLx PSPSIMLy PSPSIMDx PSPSIMDy
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set TestVarError ""
set TestVarName(0) "Platform Altitude"; set TestVarType(0) "float"; set TestVarValue(0) $PSPSIMAltitude; set TestVarMin(0) "1"; set TestVarMax(0) ""
set TestVarName(1) "Incidence Angle"; set TestVarType(1) "float"; set TestVarValue(1) $PSPSIMIncAngle1; set TestVarMin(1) "0"; set TestVarMax(1) "90"
set TestVarName(2) "Horizontal Baseline"; set TestVarType(2) "float"; set TestVarValue(2) $PSPSIMHorBaseline; set TestVarMin(2) ""; set TestVarMax(2) ""
set TestVarName(3) "Vertical Baseline"; set TestVarType(3) "float"; set TestVarValue(3) $PSPSIMVerBaseline; set TestVarMin(3) ""; set TestVarMax(3) ""
set TestVarName(4) "Centre Frequency"; set TestVarType(4) "float"; set TestVarValue(4) $PSPSIMFrequency; set TestVarMin(4) "0"; set TestVarMax(4) ""
set TestVarName(5) "Azimut Resolution"; set TestVarType(5) "float"; set TestVarValue(5) $PSPSIMAzResol; set TestVarMin(5) "0"; set TestVarMax(5) ""
set TestVarName(6) "Range Resolution"; set TestVarType(6) "float"; set TestVarValue(6) $PSPSIMRgResol; set TestVarMin(6) "0"; set TestVarMax(6) ""
set TestVarName(7) "Azimut Slope"; set TestVarType(7) "float"; set TestVarValue(7) $PSPSIMAzSlope; set TestVarMin(7) "0"; set TestVarMax(7) "100"
set TestVarName(8) "Range Slope"; set TestVarType(8) "float"; set TestVarValue(8) $PSPSIMRgSlope; set TestVarMin(8) "0"; set TestVarMax(8) "100"
set TestVarName(9) "Tree Mean Height"; set TestVarType(9) "float"; set TestVarValue(9) $PSPSIMTreeHeight; set TestVarMin(9) "0"; set TestVarMax(9) ""
set TestVarName(10) "Forest Stand Density"; set TestVarType(10) "int"; set TestVarValue(10) $PSPSIMForestDensity; set TestVarMin(10) "0"; set TestVarMax(10) ""
set TestVarName(11) "Forest Stand Area"; set TestVarType(11) "float"; set TestVarValue(11) $PSPSIMForestArea; set TestVarMin(11) "0"; set TestVarMax(11) ""
set TestVarName(12) "Random Number Generator"; set TestVarType(12) "int"; set TestVarValue(12) $PSPSIMRandom; set TestVarMin(12) "0"; set TestVarMax(12) "65535"
TestVar 13

if {$TestVarError == "ok"} {
    TextEditorRunTrace "Process The Function Soft/PolSARproSIM/PolSARproSim_ImgSize.exe" "k"
    TextEditorRunTrace "Arguments: \x22$TMPPolSARproSIM\x22 $PSPSIMTreeSpecies $PSPSIMTreeHeight $PSPSIMIncAngle1 $PSPSIMAzResol $PSPSIMRgResol $PSPSIMForestArea" "k"
    set f [ open "| Soft/PolSARproSIM/PolSARproSim_ImgSize.exe \x22$TMPPolSARproSIM\x22 $PSPSIMTreeSpecies $PSPSIMTreeHeight $PSPSIMIncAngle1 $PSPSIMAzResol $PSPSIMRgResol $PSPSIMForestArea" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    
    set ConfigFile $TMPPolSARproSIM
    set ErrorMessage ""
    WaitUntilCreated $ConfigFile
    if [file exists $ConfigFile] {
        $widget(Label400_1) configure -state normal
        $widget(Entry400_1) configure -disabledbackground #FFFFFF
        $widget(Label400_2) configure -state normal
        $widget(Entry400_2) configure -disabledbackground #FFFFFF
        set f [open $ConfigFile r]
        gets $f tmp
        gets $f PSPSIMNrows
        gets $f tmp
        gets $f PSPSIMNcols
        gets $f tmp
        gets $f PSPSIMLx
        gets $f tmp
        gets $f PSPSIMLy
        gets $f tmp
        gets $f PSPSIMDx
        gets $f tmp
        gets $f PSPSIMDy
        close $f
        }

    set WarningMessage "BEFORE RUNNING THE SIMULATOR, PLEASE CHECK"
    set WarningMessage2 "IF THE FINAL IMAGE NROWS / NCOLS ARE CORRECT"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    $widget(TitleFrame400_1) configure -state normal
    $widget(Entry400_3) configure -state normal
    $widget(Entry400_3) configure -disabledbackground #FFFFFF
    $widget(Button400_0) configure -state normal
    set PSPSIMConfig "$PSPSIMChannel1/pspsim_config"
    }
}} \
        -padx 4 -pady 2 -text {Save Config} 
    vTcl:DefineAlias "$site_3_0.but114" "Button1" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_3_0.but114 "$site_3_0.but114 Button $top all _vTclBalloon"
    bind $site_3_0.but114 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save the Simulator Configuration}
    }
    pack $site_3_0.fra113 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but114 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra119 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra119" "Frame33" vTcl:WidgetProc "Toplevel400" 1
    set site_3_0 $top.fra119
    frame $site_3_0.cpd120 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd120" "Frame39" vTcl:WidgetProc "Toplevel400" 1
    set site_4_0 $site_3_0.cpd120
    label $site_4_0.lab83 \
        -text {Final Image Number of Rows   } 
    vTcl:DefineAlias "$site_4_0.lab83" "Label400_1" vTcl:WidgetProc "Toplevel400" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPSIMNrows -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry400_1" vTcl:WidgetProc "Toplevel400" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $site_3_0.cpd121 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd121" "Frame40" vTcl:WidgetProc "Toplevel400" 1
    set site_4_0 $site_3_0.cpd121
    label $site_4_0.lab83 \
        -text {Final Image Number of Columns   } 
    vTcl:DefineAlias "$site_4_0.lab83" "Label400_2" vTcl:WidgetProc "Toplevel400" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPSIMNcols -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry400_2" vTcl:WidgetProc "Toplevel400" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.cpd120 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd121 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd123 \
        -ipad 0 -text {Configuration File} 
    vTcl:DefineAlias "$top.cpd123" "TitleFrame400_1" vTcl:WidgetProc "Toplevel400" 1
    bind $top.cpd123 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd123 getframe]
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PSPSIMConfig -width 60 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry400_3" vTcl:WidgetProc "Toplevel400" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Output Polarimetric Data Format} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame400" vTcl:WidgetProc "Toplevel400" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    radiobutton $site_4_0.rad67 \
        -text {Quad - Pol} -value quad -variable PSPOutputFormat 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel400" 1
    radiobutton $site_4_0.cpd68 \
        -text {Dual - Pol ( HH, VH )} -value dualpp1 \
        -variable PSPOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel400" 1
    radiobutton $site_4_0.cpd69 \
        -text {Dual - Pol ( HV, VV )} -value dualpp2 \
        -variable PSPOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton3" vTcl:WidgetProc "Toplevel400" 1
    radiobutton $site_4_0.cpd70 \
        -text {Dual - Pol ( HH, VV )} -value dualpp3 \
        -variable PSPOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd70" "Radiobutton4" vTcl:WidgetProc "Toplevel400" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra69 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.lab71 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit95 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd91 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd106 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra112 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra119 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd123 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 

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
Window show .top400

main $argc $argv
