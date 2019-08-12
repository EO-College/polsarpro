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

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
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
    set base .top248
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
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit76 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$base.tit77 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra89 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra89
    namespace eval ::widgets::$site_5_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra90
    namespace eval ::widgets::$site_6_0.che75 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra76
    namespace eval ::widgets::$site_7_0.lab77 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab78 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab79 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.che75 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra76
    namespace eval ::widgets::$site_7_0.lab77 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab78 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab79 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.che81 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra82 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra82
    namespace eval ::widgets::$site_3_0.che83 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_4_0 $site_3_0.cpd84
    namespace eval ::widgets::$site_4_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra72
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd88
    namespace eval ::widgets::$site_3_0.che83 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_4_0 $site_3_0.cpd84
    namespace eval ::widgets::$site_4_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_4_0 $site_3_0.cpd71
    namespace eval ::widgets::$site_4_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_4_0 $site_3_0.cpd69
    namespace eval ::widgets::$site_4_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top248
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

proc vTclWindow.top248 {base} {
    if {$base == ""} {
        set base .top248
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
    wm geometry $top 500x430+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Sub-Aperture Applications"
    vTcl:DefineAlias "$top" "Toplevel248" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel248" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SubAptInputDir 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry248_149" vTcl:WidgetProc "Toplevel248" 1
    frame $site_4_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame16" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd75
    entry $site_5_0.cpd73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SubAptSubNum -width 2 
    vTcl:DefineAlias "$site_5_0.cpd73" "Entry5" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame17" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd76
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label2" vTcl:WidgetProc "Toplevel248" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SubAptSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry6" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -text {Output Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel248" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable SubAptOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry248_73" vTcl:WidgetProc "Toplevel248" 1
    frame $site_4_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame15" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd71
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SubAptOutputDirSub -width 5 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry2" vTcl:WidgetProc "Toplevel248" 1
    entry $site_5_0.cpd73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SubAptSubNum -width 2 
    vTcl:DefineAlias "$site_5_0.cpd73" "Entry3" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel248" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SubAptSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName DataDir SubAptOutputDir

set SubAptOutputDirTmp $SubAptOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT MAIN DIRECTORY"
if {$DirName != "" } {
    set SubAptOutputDir $DirName
    } else {
    set SubAptOutputDir $BSubAptOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button248_92" vTcl:WidgetProc "Toplevel248" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel248" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label248_01" vTcl:WidgetProc "Toplevel248" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry248_01" vTcl:WidgetProc "Toplevel248" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label248_02" vTcl:WidgetProc "Toplevel248" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry248_02" vTcl:WidgetProc "Toplevel248" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label248_03" vTcl:WidgetProc "Toplevel248" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry248_03" vTcl:WidgetProc "Toplevel248" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label248_04" vTcl:WidgetProc "Toplevel248" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry248_04" vTcl:WidgetProc "Toplevel248" 1
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
    TitleFrame $top.tit77 \
        -text {Sub-Aperture Processing} 
    vTcl:DefineAlias "$top.tit77" "TitleFrame3" vTcl:WidgetProc "Toplevel248" 1
    bind $top.tit77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit77 getframe]
    frame $site_4_0.cpd83 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_4_0.cpd83" "Frame218" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd83
    label $site_5_0.lab23 \
        -padx 1 -text {Nb of Sub-Apertures} 
    vTcl:DefineAlias "$site_5_0.lab23" "Label248_11" vTcl:WidgetProc "Toplevel248" 1
    entry $site_5_0.ent24 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SubAptSubIm -width 5 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry248_5" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame215" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd82
    label $site_5_0.lab23 \
        -padx 1 -text {Initial Sub-Aperture} 
    vTcl:DefineAlias "$site_5_0.lab23" "Label248_12" vTcl:WidgetProc "Toplevel248" 1
    entry $site_5_0.ent24 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SubAptInit -width 5 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry248_6" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame217" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd74
    label $site_5_0.lab23 \
        -padx 1 -text {Final Sub-Aperture} 
    vTcl:DefineAlias "$site_5_0.lab23" "Label248_13" vTcl:WidgetProc "Toplevel248" 1
    entry $site_5_0.ent24 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SubAptFin -width 5 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry248_7" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd73 \
        -text {Create BMP Files} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame4" vTcl:WidgetProc "Toplevel248" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    checkbutton $site_4_0.cpd79 \
        \
        -command {global SubAptBMP SubAptPauli SubAptSinclair SubAptSpan

if {"$SubAptBMP"=="0"} {
    set SubAptPauli 0
    set SubAptSinclair 0
    set SubAptSpan 0
    $widget(Checkbutton248_2) configure -state disable
    $widget(Checkbutton248_3) configure -state disable
    $widget(Checkbutton248_4) configure -state disable
    $widget(Label248_1) configure -state disable
    $widget(Label248_2) configure -state disable
    $widget(Label248_3) configure -state disable
    $widget(Label248_4) configure -state disable
    $widget(Label248_5) configure -state disable
    $widget(Label248_6) configure -state disable
    } else {
    $widget(Checkbutton248_2) configure -state normal
    $widget(Checkbutton248_3) configure -state normal
    $widget(Checkbutton248_4) configure -state normal
    $widget(Label248_1) configure -state normal
    $widget(Label248_2) configure -state normal
    $widget(Label248_3) configure -state normal
    $widget(Label248_4) configure -state normal
    $widget(Label248_5) configure -state normal
    $widget(Label248_6) configure -state normal
    }} \
        -variable SubAptBMP 
    vTcl:DefineAlias "$site_4_0.cpd79" "Checkbutton248_1" vTcl:WidgetProc "Toplevel248" 1
    frame $site_4_0.fra89 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra89" "Frame26" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.fra89
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame27" vTcl:WidgetProc "Toplevel248" 1
    set site_6_0 $site_5_0.fra90
    checkbutton $site_6_0.che75 \
        -text {Pauli Decomposition} -variable SubAptPauli 
    vTcl:DefineAlias "$site_6_0.che75" "Checkbutton248_2" vTcl:WidgetProc "Toplevel248" 1
    frame $site_6_0.fra76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra76" "Frame29" vTcl:WidgetProc "Toplevel248" 1
    set site_7_0 $site_6_0.fra76
    label $site_7_0.lab77 \
        -foreground #0000ff -text {|s11 + s22|} 
    vTcl:DefineAlias "$site_7_0.lab77" "Label248_1" vTcl:WidgetProc "Toplevel248" 1
    label $site_7_0.lab78 \
        -foreground #009900 -text {|s12 + s21|} 
    vTcl:DefineAlias "$site_7_0.lab78" "Label248_2" vTcl:WidgetProc "Toplevel248" 1
    label $site_7_0.lab79 \
        -foreground #ff0000 -text {|s11 - s22|} 
    vTcl:DefineAlias "$site_7_0.lab79" "Label248_3" vTcl:WidgetProc "Toplevel248" 1
    pack $site_7_0.lab77 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.lab78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.lab79 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.che75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side right 
    frame $site_5_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame30" vTcl:WidgetProc "Toplevel248" 1
    set site_6_0 $site_5_0.cpd80
    checkbutton $site_6_0.che75 \
        -text {Sinclair Decomposition} -variable SubAptSinclair 
    vTcl:DefineAlias "$site_6_0.che75" "Checkbutton248_3" vTcl:WidgetProc "Toplevel248" 1
    frame $site_6_0.fra76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra76" "Frame31" vTcl:WidgetProc "Toplevel248" 1
    set site_7_0 $site_6_0.fra76
    label $site_7_0.lab77 \
        -foreground #0000ff -text |s11| 
    vTcl:DefineAlias "$site_7_0.lab77" "Label248_4" vTcl:WidgetProc "Toplevel248" 1
    label $site_7_0.lab78 \
        -foreground #009900 -text {|(s12 + s21)/2|} 
    vTcl:DefineAlias "$site_7_0.lab78" "Label248_5" vTcl:WidgetProc "Toplevel248" 1
    label $site_7_0.lab79 \
        -foreground #ff0000 -text |s22| 
    vTcl:DefineAlias "$site_7_0.lab79" "Label248_6" vTcl:WidgetProc "Toplevel248" 1
    pack $site_7_0.lab77 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.lab78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.lab79 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.che75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side right 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    checkbutton $site_4_0.che81 \
        -text {Span (dB)} -variable SubAptSpan 
    vTcl:DefineAlias "$site_4_0.che81" "Checkbutton248_4" vTcl:WidgetProc "Toplevel248" 1
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra89 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.che81 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra82 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra82" "Frame6" vTcl:WidgetProc "Toplevel248" 1
    set site_3_0 $top.fra82
    checkbutton $site_3_0.che83 \
        \
        -command {global SubAptHAAlp SubAptHAAlpNwinL SubAptHAAlpNwinC

if {"$SubAptHAAlp"=="0"} {
    set SubAptHAAlpNwinL ""
    $widget(Label248_7a) configure -state disable
    $widget(Entry248_1a) configure -state disable
    set SubAptHAAlpNwinC ""
    $widget(Label248_7b) configure -state disable
    $widget(Entry248_1b) configure -state disable
    } else {
    set SubAptHAAlpNwinL "?"
    $widget(Label248_7a) configure -state normal
    $widget(Entry248_1a) configure -state normal
    set SubAptHAAlpNwinC "?"
    $widget(Label248_7b) configure -state normal
    $widget(Entry248_1b) configure -state normal
    }} \
        -text {H / A / Alpha Decomposition + Span (lin)} \
        -variable SubAptHAAlp 
    vTcl:DefineAlias "$site_3_0.che83" "Checkbutton248_5" vTcl:WidgetProc "Toplevel248" 1
    frame $site_3_0.cpd84 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_3_0.cpd84" "Frame244" vTcl:WidgetProc "Toplevel248" 1
    set site_4_0 $site_3_0.cpd84
    label $site_4_0.lab23 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_4_0.lab23" "Label248_7b" vTcl:WidgetProc "Toplevel248" 1
    entry $site_4_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubAptHAAlpNwinC -width 5 
    vTcl:DefineAlias "$site_4_0.ent24" "Entry248_1b" vTcl:WidgetProc "Toplevel248" 1
    pack $site_4_0.lab23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent24 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame247" vTcl:WidgetProc "Toplevel248" 1
    set site_4_0 $site_3_0.cpd66
    label $site_4_0.lab23 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_4_0.lab23" "Label248_7a" vTcl:WidgetProc "Toplevel248" 1
    entry $site_4_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubAptHAAlpNwinL -width 5 
    vTcl:DefineAlias "$site_4_0.ent24" "Entry248_1a" vTcl:WidgetProc "Toplevel248" 1
    pack $site_4_0.lab23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent24 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.che83 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.tit92 \
        -ipad 2 -text {Polarimetric Descriptor Variations} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame5" vTcl:WidgetProc "Toplevel248" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    frame $site_4_0.fra72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra72" "Frame5" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.fra72
    checkbutton $site_5_0.cpd73 \
        \
        -command {global SubAptCVH SubAptCVA SubAptCVAlp SubAptCVSpan SubAptCVNwinL SubAptCVNwinC

if {"$SubAptCVH"=="1"} {
    set SubAptCVNwinL "?"
    $widget(Label248_8a) configure -state normal
    $widget(Entry248_2a) configure -state normal
    set SubAptCVNwinC "?"
    $widget(Label248_8b) configure -state normal
    $widget(Entry248_2b) configure -state normal
    } else {
    set config "false"
    if {"$SubAptCVA"=="1"} {set config "true"}
    if {"$SubAptCVAlp"=="1"} {set config "true"}
    if {"$SubAptCVSpan"=="1"} {set config "true"}
    if {$config == "false"} {
        set SubAptCVNwinL ""
        $widget(Label248_8a) configure -state disable
        $widget(Entry248_2a) configure -state disable
        set SubAptCVNwinC ""
        $widget(Label248_8b) configure -state disable
        $widget(Entry248_2b) configure -state disable
        }
    }} \
        -text {Entropy (H)} -variable SubAptCVH 
    vTcl:DefineAlias "$site_5_0.cpd73" "Checkbutton248_6" vTcl:WidgetProc "Toplevel248" 1
    checkbutton $site_5_0.cpd85 \
        \
        -command {global SubAptCVH SubAptCVA SubAptCVAlp SubAptCVSpan SubAptCVNwinL SubAptCVNwinC

if {"$SubAptCVAlp"=="1"} {
    set SubAptCVNwinL "?"
    $widget(Label248_8a) configure -state normal
    $widget(Entry248_2a) configure -state normal
    set SubAptCVNwinC "?"
    $widget(Label248_8b) configure -state normal
    $widget(Entry248_2b) configure -state normal
    } else {
    set config "false"
    if {"$SubAptCVA"=="1"} {set config "true"}
    if {"$SubAptCVH"=="1"} {set config "true"}
    if {"$SubAptCVSpan"=="1"} {set config "true"}
    if {$config == "false"} {
        set SubAptCVNwinL ""
        $widget(Label248_8a) configure -state disable
        $widget(Entry248_2a) configure -state disable
        set SubAptCVNwinC ""
        $widget(Label248_8b) configure -state disable
        $widget(Entry248_2b) configure -state disable
        }
    }} \
        -text Alpha -variable SubAptCVAlp 
    vTcl:DefineAlias "$site_5_0.cpd85" "Checkbutton248_7" vTcl:WidgetProc "Toplevel248" 1
    checkbutton $site_5_0.cpd86 \
        \
        -command {global SubAptCVH SubAptCVA SubAptCVAlp SubAptCVSpan SubAptCVNwinL SubAptCVNwinC

if {"$SubAptCVA"=="1"} {
    set SubAptCVNwinL "?"
    $widget(Label248_8a) configure -state normal
    $widget(Entry248_2a) configure -state normal
    set SubAptCVNwinC "?"
    $widget(Label248_8b) configure -state normal
    $widget(Entry248_2b) configure -state normal
    } else {
    set config "false"
    if {"$SubAptCVH"=="1"} {set config "true"}
    if {"$SubAptCVAlp"=="1"} {set config "true"}
    if {"$SubAptCVSpan"=="1"} {set config "true"}
    if {$config == "false"} {
        set SubAptCVNwinL ""
        $widget(Label248_8a) configure -state disable
        $widget(Entry248_2a) configure -state disable
        set SubAptCVNwinC ""
        $widget(Label248_8b) configure -state disable
        $widget(Entry248_2b) configure -state disable
        }
    }} \
        -text {Anisotropy (A)} -variable SubAptCVA 
    vTcl:DefineAlias "$site_5_0.cpd86" "Checkbutton248_8" vTcl:WidgetProc "Toplevel248" 1
    checkbutton $site_5_0.cpd87 \
        \
        -command {global SubAptCVH SubAptCVA SubAptCVAlp SubAptCVSpan SubAptCVNwinL SubAptCVNwinC

if {"$SubAptCVSpan"=="1"} {
    set SubAptCVNwinL "?"
    $widget(Label248_8a) configure -state normal
    $widget(Entry248_2a) configure -state normal
    set SubAptCVNwinC "?"
    $widget(Label248_8b) configure -state normal
    $widget(Entry248_2b) configure -state normal
    } else {
    set config "false"
    if {"$SubAptCVA"=="1"} {set config "true"}
    if {"$SubAptCVAlp"=="1"} {set config "true"}
    if {"$SubAptCVH"=="1"} {set config "true"}
    if {$config == "false"} {
        set SubAptCVNwinL ""
        $widget(Label248_8a) configure -state disable
        $widget(Entry248_2a) configure -state disable
        set SubAptCVNwinC ""
        $widget(Label248_8b) configure -state disable
        $widget(Entry248_2b) configure -state disable
        }
    }} \
        -text Span -variable SubAptCVSpan 
    vTcl:DefineAlias "$site_5_0.cpd87" "Checkbutton248_9" vTcl:WidgetProc "Toplevel248" 1
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame7" vTcl:WidgetProc "Toplevel248" 1
    set site_5_0 $site_4_0.cpd67
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame248" vTcl:WidgetProc "Toplevel248" 1
    set site_6_0 $site_5_0.cpd75
    label $site_6_0.lab23 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_6_0.lab23" "Label248_8a" vTcl:WidgetProc "Toplevel248" 1
    entry $site_6_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubAptCVNwinL -width 5 
    vTcl:DefineAlias "$site_6_0.ent24" "Entry248_2a" vTcl:WidgetProc "Toplevel248" 1
    pack $site_6_0.lab23 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent24 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd68 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame249" vTcl:WidgetProc "Toplevel248" 1
    set site_6_0 $site_5_0.cpd68
    label $site_6_0.lab23 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_6_0.lab23" "Label248_8b" vTcl:WidgetProc "Toplevel248" 1
    entry $site_6_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubAptCVNwinC -width 5 
    vTcl:DefineAlias "$site_6_0.ent24" "Entry248_2b" vTcl:WidgetProc "Toplevel248" 1
    pack $site_6_0.lab23 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent24 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd88 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame8" vTcl:WidgetProc "Toplevel248" 1
    set site_3_0 $top.cpd88
    checkbutton $site_3_0.che83 \
        \
        -command {global SubAptNSM SubAptNSMNwinL SubAptNSMNwinC SubAptNSMNlook

if {"$SubAptNSM"=="0"} {
    set SubAptNSMNwinL ""
    $widget(Label248_9a) configure -state disable
    $widget(Entry248_3a) configure -state disable
    set SubAptNSMNwinC ""
    $widget(Label248_9b) configure -state disable
    $widget(Entry248_3b) configure -state disable
    set SubAptNSMNlook ""
    $widget(Label248_10) configure -state disable
    $widget(Entry248_4) configure -state disable
    } else {
    set SubAptNSMNwinL "?"
    $widget(Label248_9a) configure -state normal
    $widget(Entry248_3a) configure -state normal
    set SubAptNSMNwinC "?"
    $widget(Label248_9b) configure -state normal
    $widget(Entry248_3b) configure -state normal
    set SubAptNSMNlook "?"
    $widget(Label248_10) configure -state normal
    $widget(Entry248_4) configure -state normal
    }} \
        -text {Non Stationary Map} -variable SubAptNSM 
    vTcl:DefineAlias "$site_3_0.che83" "Checkbutton248_10" vTcl:WidgetProc "Toplevel248" 1
    frame $site_3_0.cpd84 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_3_0.cpd84" "Frame245" vTcl:WidgetProc "Toplevel248" 1
    set site_4_0 $site_3_0.cpd84
    label $site_4_0.lab23 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_4_0.lab23" "Label248_9b" vTcl:WidgetProc "Toplevel248" 1
    entry $site_4_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubAptNSMNwinC -width 5 
    vTcl:DefineAlias "$site_4_0.ent24" "Entry248_3b" vTcl:WidgetProc "Toplevel248" 1
    pack $site_4_0.lab23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent24 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd71 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame246" vTcl:WidgetProc "Toplevel248" 1
    set site_4_0 $site_3_0.cpd71
    label $site_4_0.lab23 \
        -padx 1 -text {Nb of Looks} 
    vTcl:DefineAlias "$site_4_0.lab23" "Label248_10" vTcl:WidgetProc "Toplevel248" 1
    entry $site_4_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubAptNSMNlook -width 5 
    vTcl:DefineAlias "$site_4_0.ent24" "Entry248_4" vTcl:WidgetProc "Toplevel248" 1
    pack $site_4_0.lab23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent24 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd69 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_3_0.cpd69" "Frame250" vTcl:WidgetProc "Toplevel248" 1
    set site_4_0 $site_3_0.cpd69
    label $site_4_0.lab23 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_4_0.lab23" "Label248_9a" vTcl:WidgetProc "Toplevel248" 1
    entry $site_4_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubAptNSMNwinL -width 5 
    vTcl:DefineAlias "$site_4_0.ent24" "Entry248_3a" vTcl:WidgetProc "Toplevel248" 1
    pack $site_4_0.lab23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent24 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.che83 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel248" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir FileName
global SubAptDirInput SubAptInputDir
global SubAptDirOutput SubAptOutputDir SubAptSubDir
global SubAptOutputDirSub SubAptSubNum
global BMPDirInput OpenDirFile TMPMemoryAllocError
global ConfigFile VarError ErrorMessage Fonction PSPViewGimpBMP
global VarWarning WarningMesage WarningMessage2
global SubAptInit SubAptFin SubAptNSubIm SubAptSubIm
global SubAptBMP SubAptPauli SubAptSinclair SubAptSpan
global SubAptHAAlp SubAptHAAlpNwinL SubAptHAAlpNwinC
global SubAptCVH SubAptCVA SubAptCVAlp SubAptCVSpan SubAptCVNwinL SubAptCVNwinC 
global SubAptNSM SubAptNSNwin SubAptNSMNlook
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set TestVarName(0) "Initial Sub Aperture"; set TestVarType(0) "int"; set TestVarValue(0) $SubAptInit; set TestVarMin(0) "0"; set TestVarMax(0) $SubAptNSubIm
set TestVarName(1) "Final Sub Aperture"; set TestVarType(1) "int"; set TestVarValue(1) $SubAptFin; set TestVarMin(1) "0"; set TestVarMax(1) $SubAptNSubIm
TestVar 2
if {$TestVarError == "ok"} {

set SubAptSubIm [expr $SubAptFin - $SubAptInit + 1]
if {$SubAptSubIm > $SubAptNSubIm} {
    set VarError ""
    set ErrorMessage "CONFLICT IN THE SUB-APERTURES NUMBER" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

#####################################################################
#Create Directory
set VarWarning ""
set VarWarningFinal "ok"
set SubAptSubNum $SubAptInit
set SubAptDirOutput $SubAptOutputDir
append SubAptDirOutput $SubAptOutputDirSub
for {set j 0} {$j < $SubAptSubIm} {incr j} {
    set DirNameCreate $SubAptDirOutput
    append DirNameCreate $SubAptSubNum
    if {$SubAptSubDir != ""} { append DirNameCreate "/$SubAptSubDir" }
    incr SubAptSubNum
    if [file isdirectory $DirNameCreate] {
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory $DirNameCreate" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show $widget(Toplevel44)
                set VarWarning ""
                }
            } else {
            set VarWarningFinal "no"
            }
        }
    }
#####################################################################       

if {"$VarWarningFinal"=="ok"} {

set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
TestVar 4
if {$TestVarError == "ok"} {

#####################################################################       

if {$SubAptBMP == "1"} {
set SubAptSubNum $SubAptInit
set OffsetLig [expr $NligInit - 1]
set OffsetCol [expr $NcolInit - 1]
set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

for {set j 0} {$j < $SubAptSubIm} {incr j} {
    set SubAptDirInput $SubAptInputDir
    append SubAptDirInput $SubAptSubNum
    if {$SubAptSubDir != ""} { append SubAptDirInput "/$SubAptSubDir" }

    set SubAptDirOutput $SubAptOutputDir
    append SubAptDirOutput $SubAptOutputDirSub
    append SubAptDirOutput $SubAptSubNum
    if {$SubAptSubDir != ""} { append SubAptDirOutput "/$SubAptSubDir" }

    incr SubAptSubNum

    if {$SubAptSubDir == ""} {
        if {$SubAptPauli == "1"} {
            set SubAptFileOutput "$SubAptDirOutput/PauliRGB.bmp" 
            set Fonction "Creation of the RGB BMP File :"
            set Fonction2 "$SubAptFileOutput"    
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $SubAptFileOutput }
            }
        if {$SubAptSinclair == "1"} {
            set SubAptFileOutput "$SubAptDirOutput/SinclairRGB.bmp" 
            set Fonction "Creation of the RGB BMP File :"
            set Fonction2 "$SubAptFileOutput"    
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_sinclair_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/bmp_process/create_sinclair_rgb_file.exe -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $SubAptFileOutput }
            }
        if {$SubAptSpan == "1"} {
            set Fonction "Creation of the Binary Data File :"
            set Fonction2 "$SubAptDirOutput/Span_db.bin"
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf S2 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf S2 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            EnviWriteConfig "$SubAptDirOutput/span_db.bin" $FinalNlig $FinalNcol 4
            set BMPFileInput "$SubAptDirOutput/span_db.bin"
            set BMPFileOutput "$SubAptDirOutput/span_db.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }                 
    if {$SubAptSubDir == "T3"} {
        if {$SubAptPauli == "1"} {
            set SubAptFileOutput "$SubAptDirOutput/PauliRGB.bmp" 
            set Fonction "Creation of the RGB BMP File :"
            set Fonction2 "$SubAptFileOutput"    
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $SubAptFileOutput }
            }
        if {$SubAptSinclair == "1"} {
            set SubAptFileOutput "$SubAptDirOutput/SinclairRGB.bmp" 
            set Fonction "Creation of the RGB BMP File :"
            set Fonction2 "$SubAptFileOutput"    
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_sinclair_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/bmp_process/create_sinclair_rgb_file.exe -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $SubAptFileOutput }
            }
        if {$SubAptSpan == "1"} {
            set Fonction "Creation of the Binary Data File :"
            set Fonction2 "$SubAptDirOutput/span_db.bin"
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf T3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf T3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            EnviWriteConfig "$SubAptDirOutput/span_db.bin" $FinalNlig $FinalNcol 4
            set BMPFileInput "$SubAptDirOutput/span_db.bin"
            set BMPFileOutput "$SubAptDirOutput/span_db.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }                 
    if {$SubAptSubDir == "C3"} {
        if {$SubAptPauli == "1"} {
            set SubAptFileOutput "$SubAptDirOutput/PauliRGB.bmp" 
            set Fonction "Creation of the RGB BMP File :"
            set Fonction2 "$SubAptFileOutput"    
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $SubAptFileOutput }
            }
        if {$SubAptSinclair == "1"} {
            set SubAptFileOutput "$SubAptDirOutput/SinclairRGB.bmp" 
            set Fonction "Creation of the RGB BMP File :"
            set Fonction2 "$SubAptFileOutput"    
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_sinclair_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/bmp_process/create_sinclair_rgb_file.exe -id \x22$SubAptDirInput\x22 -of \x22$SubAptFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $FinalNlig  -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $SubAptFileOutput }
            }                                 
        if {$SubAptSpan == "1"} {
            set Fonction "Creation of the Binary Data File :"
            set Fonction2 "$SubAptDirOutput/span_db.bin"
            set MaskCmd ""
            set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf C3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf C3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            EnviWriteConfig "$SubAptDirOutput/span_db.bin" $FinalNlig $FinalNcol 4
            set BMPFileInput "$SubAptDirOutput/span_db.bin"
            set BMPFileOutput "$SubAptDirOutput/span_db.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }                 
    }
    # j
set BMPDirInput $SubAptDirOutput
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
}
#SubAptBMP

#####################################################################       

if {$SubAptHAAlp == "1"} {

set TestVarName(0) "Window Size Row - H/A/Alpha Decomposition"; set TestVarType(0) "int"; set TestVarValue(0) $SubAptHAAlpNwinL; set TestVarMin(0) "1"; set TestVarMax(0) "100"
set TestVarName(1) "Window Size Col - H/A/Alpha Decomposition"; set TestVarType(1) "int"; set TestVarValue(1) $SubAptHAAlpNwinL; set TestVarMin(1) "1"; set TestVarMax(1) "100"
TestVar 2
if {$TestVarError == "ok"} {

set config "true"
if {$SubAptHAAlpNwinL ==""} {set config "false"}
if {$SubAptHAAlpNwinL =="?"} {set config "false"}
if {$SubAptHAAlpNwinL =="0"} {set config "false"}
if {$SubAptHAAlpNwinC ==""} {set config "false"}
if {$SubAptHAAlpNwinC =="?"} {set config "false"}
if {$SubAptHAAlpNwinC =="0"} {set config "false"}
if {$config == "false"} {
    set VarError ""
    set ErrorMessage "ENTER THE ANALYSIS WINDOW SIZE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set SubAptSubNum $SubAptInit
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    for {set j 0} {$j < $SubAptSubIm} {incr j} {
        set SubAptDirInput $SubAptInputDir
        append SubAptDirInput $SubAptSubNum
        if {$SubAptSubDir != ""} { append SubAptDirInput "/$SubAptSubDir" }

        set SubAptDirOutput $SubAptOutputDir
        append SubAptDirOutput $SubAptOutputDirSub
        append SubAptDirOutput $SubAptSubNum
        if {$SubAptSubDir != ""} { append SubAptDirOutput "/$SubAptSubDir" }

        incr SubAptSubNum

        set Fonction "Creation of all the Binary Data Files"
        set Fonction2 "of the H / A / Alpha Decomposition"
        set MaskCmd ""
        set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        if {$SubAptSubDir == ""} { set SubAptF "S2T3" }
        if {$SubAptSubDir == "T3"} { set SubAptF "T3" }
        if {$SubAptSubDir == "C3"} { set SubAptF "C3T3" }
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -nwr $SubAptHAAlpNwinL -nwc $SubAptHAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -nwr $SubAptHAAlpNwinL -nwc $SubAptHAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists "$SubAptDirOutput/alpha.bin"] {EnviWriteConfig "$SubAptDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SubAptDirOutput/entropy.bin"] {EnviWriteConfig "$SubAptDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SubAptDirOutput/anisotropy.bin"] {EnviWriteConfig "$SubAptDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}

        set Fonction "Creation of the BMP File"
        if [file exists "$SubAptDirOutput/alpha.bin"] {
            set BMPFileInput "$SubAptDirOutput/alpha.bin"
            set BMPFileOutput "$SubAptDirOutput/alpha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
            } else {
            set VarError ""
            set ErrorMessage "THE FILE alpha.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
             
        if [file exists "$SubAptDirOutput/entropy.bin"] {
            set BMPFileInput "$SubAptDirOutput/entropy.bin"
            set BMPFileOutput "$SubAptDirOutput/entropy.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE entropy.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
             
        if [file exists "$SubAptDirOutput/anisotropy.bin"] {
            set BMPFileInput "$SubAptDirOutput/anisotropy.bin"
            set BMPFileOutput "$SubAptDirOutput/anisotropy.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE anisotropy.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set Fonction "Creation of the Binary Data File"
        set Fonction2 "$SubAptDirOutput/span.bin"
        set MaskCmd ""
        set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$SubAptSubDir == ""} { set SubAptF "S2" }
        if {$SubAptSubDir == "T3"} { set SubAptF "T3" }
        if {$SubAptSubDir == "C3"} { set SubAptF "C3" }
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -fmt lin -nwr $SubAptHAAlpNwinL -nwc $SubAptHAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -fmt lin -nwr $SubAptHAAlpNwinL -nwc $SubAptHAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        EnviWriteConfig "$SubAptDirOutput/span.bin" $FinalNlig $FinalNcol 4
        if [file exists "$SubAptDirOutput/span_db.bmp"] {
            } else {
            set BMPFileInput "$SubAptDirOutput/span.bin"
            set BMPFileOutput "$SubAptDirOutput/span_db.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
        # j

    set BMPDirInput $SubAptDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }
    #Nwin
}
#TestVar
}
#SubAptHAAlp

#####################################################################       

set conf "false"
if {$SubAptCVH == "1"} {set conf "true"}
if {$SubAptCVA == "1"} {set conf "true"}
if {$SubAptCVAlp == "1"} {set conf "true"}
if {$SubAptCVSpan == "1"} {set conf "true"}

if {$conf == "true"} {

set TestVarName(0) "Window Size Row - Polarimetric Descriptor Variations"; set TestVarType(0) "int"; set TestVarValue(0) $SubAptCVNwinL; set TestVarMin(0) "1"; set TestVarMax(0) "100"
set TestVarName(1) "Window Size Col - Polarimetric Descriptor Variations"; set TestVarType(1) "int"; set TestVarValue(1) $SubAptCVNwinC; set TestVarMin(1) "1"; set TestVarMax(1) "100"
TestVar 2
if {$TestVarError == "ok"} {

set config "true"
if {$SubAptCVNwinL ==""} {set config "false"}
if {$SubAptCVNwinL =="?"} {set config "false"}
if {$SubAptCVNwinL =="0"} {set config "false"}
if {$SubAptCVNwinC ==""} {set config "false"}
if {$SubAptCVNwinC =="?"} {set config "false"}
if {$SubAptCVNwinC =="0"} {set config "false"}
if {$config == "false"} {
    set VarError ""
    set ErrorMessage "ENTER THE ANALYSIS WINDOW SIZE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set SubAptDirInput $SubAptInputDir
    append SubAptDirInput $SubAptInit
    if {$SubAptSubDir != ""} { append SubAptDirInput "/$SubAptSubDir" }
    set MaskCmd ""
    set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

    set SubAptDirInput $SubAptInputDir
    set SubAptDirOutput $SubAptOutputDir
    append SubAptDirOutput $SubAptOutputDirSub

    set Fonction "Creation of all the Binary Data Files"
    set Fonction2 "Coefficient of Variation of H-A-Alpha-Span parameters"
    if {$SubAptSubDir == ""} { set SubAptF "S2" }
    if {$SubAptSubDir == "T3"} { set SubAptF "T3" }
    if {$SubAptSubDir == "C3"} { set SubAptF "C3" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    if {$SubAptSubDir == ""} { set SubAptVal 0}
    if {$SubAptSubDir == "T3"} { set SubAptVal 1}
    if {$SubAptSubDir == "C3"} { set SubAptVal 2}
    TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/sub_aperture_CV.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -subi $SubAptInit -subn $SubAptSubIm -nwr $SubAptCVNwinL -nwc $SubAptCVNwinC -fnr $FinalNlig -fnc $FinalNcol -fh $SubAptCVH -fa $SubAptCVA -fal $SubAptCVAlp -fs $SubAptCVSpan  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bin/data_process_sngl/sub_aperture_CV.exe -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -subi $SubAptInit -subn $SubAptSubIm -nwr $SubAptCVNwinL -nwc $SubAptCVNwinC -fnr $FinalNlig -fnc $FinalNcol -fh $SubAptCVH -fa $SubAptCVA -fal $SubAptCVAlp -fs $SubAptCVSpan  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    set SubAptDirOutput $SubAptOutputDir
    append SubAptDirOutput $SubAptOutputDirSub
    append SubAptDirOutput $SubAptInit
    if {$SubAptSubDir != ""} { append SubAptDirOutput "/$SubAptSubDir" }

    if [file exists "$SubAptDirOutput/CValpha.bin"] {EnviWriteConfig "$SubAptDirOutput/CValpha.bin" $FinalNlig $FinalNcol 4}
    if [file exists "$SubAptDirOutput/CVentropy.bin"] {EnviWriteConfig "$SubAptDirOutput/CVentropy.bin" $FinalNlig $FinalNcol 4}
    if [file exists "$SubAptDirOutput/CVanisotropy.bin"] {EnviWriteConfig "$SubAptDirOutput/CVanisotropy.bin" $FinalNlig $FinalNcol 4}
    if [file exists "$SubAptDirOutput/CVspan.bin"] {EnviWriteConfig "$SubAptDirOutput/CVspan.bin" $FinalNlig $FinalNcol 4}

    set Fonction "Creation of the BMP File"
    if [file exists "$SubAptDirOutput/CValpha.bin"] {
        set BMPFileInput "$SubAptDirOutput/CValpha.bin"
        set BMPFileOutput "$SubAptDirOutput/CValpha.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
        } else {
        set VarError ""
        set ErrorMessage "THE FILE CValpha.bin DOES NOT EXIST" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
             
    if [file exists "$SubAptDirOutput/CVentropy.bin"] {
        set BMPFileInput "$SubAptDirOutput/CVentropy.bin"
        set BMPFileOutput "$SubAptDirOutput/CVentropy.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
        } else {
        set VarError ""
        set ErrorMessage "THE FILE CVentropy.bin DOES NOT EXIST" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
             
    if [file exists "$SubAptDirOutput/CVanisotropy.bin"] {
        set BMPFileInput "$SubAptDirOutput/CVanisotropy.bin"
        set BMPFileOutput "$SubAptDirOutput/CVanisotropy.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
        } else {
        set VarError ""
        set ErrorMessage "THE FILE CVanisotropy.bin DOES NOT EXIST" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if [file exists "$SubAptDirOutput/CVspan.bin"] {
        set BMPFileInput "$SubAptDirOutput/CVspan.bin"
        set BMPFileOutput "$SubAptDirOutput/CVspan.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
        } else {
        set VarError ""
        set ErrorMessage "THE FILE CVspan.bin DOES NOT EXIST" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    set BMPDirInput $SubAptDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }
    #Nwin
}
#TestVar
}
#SubAptCV

#####################################################################       

if {$SubAptNSM == "1"} {

set TestVarName(0) "Window Size Row - Non Stationary Map"; set TestVarType(0) "int"; set TestVarValue(0) $SubAptNSMNwinL; set TestVarMin(0) "1"; set TestVarMax(0) "100"
set TestVarName(1) "Number of Looks - Non Stationary Map"; set TestVarType(1) "int"; set TestVarValue(1) $SubAptNSMNlook; set TestVarMin(1) "1"; set TestVarMax(1) "100"
set TestVarName(2) "Window Size Col - Non Stationary Map"; set TestVarType(2) "int"; set TestVarValue(2) $SubAptNSMNwinC; set TestVarMin(2) "1"; set TestVarMax(2) "100"
TestVar 3
if {$TestVarError == "ok"} {

set config "true"
set config1 "true"
set config2 "true"
if {$SubAptNSMNwinL ==""} {set config1 "false"}
if {$SubAptNSMNwinL =="?"} {set config1 "false"}
if {$SubAptNSMNwinL =="0"} {set config1 "false"}
if {$SubAptNSMNwinC ==""} {set config1 "false"}
if {$SubAptNSMNwinC =="?"} {set config1 "false"}
if {$SubAptNSMNwinC =="0"} {set config1 "false"}
if {$SubAptNSMNlook ==""} {set config2 "false"}
if {$SubAptNSMNlook =="?"} {set config2 "false"}
if {$SubAptNSMNlook =="0"} {set config2 "false"}
if {$config1 == "false"} {
    set VarError ""
    set ErrorMessage "ENTER THE ANALYSIS WINDOW SIZE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$config2 == "false"} {
    set VarError ""
    set ErrorMessage "ENTER THE EQUIVALENT NUMBER OF LOOKS" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$config == "true"} {
    set SubAptSubNum $SubAptInit
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set SubAptDirInput $SubAptInputDir
    append SubAptDirInput $SubAptInit
    if {$SubAptSubDir != ""} { append SubAptDirInput "/$SubAptSubDir" }
    set MaskCmd ""
    set MaskFile "$SubAptDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

    set SubAptDirInput $SubAptInputDir
    set SubAptDirOutput $SubAptOutputDir

    set Fonction "Creation of all the Binary Data Files"
    set Fonction2 "of the Non Stationary Map"
    if {$SubAptSubDir == ""} { set SubAptF "S2" }
    if {$SubAptSubDir == "T3"} { set SubAptF "T3" }
    if {$SubAptSubDir == "C3"} { set SubAptF "C3" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/sub_aperture_anisotropy.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -subi $SubAptInit -subn $SubAptSubIm -nwr $SubAptNSMNwinL -nwc $SubAptNSMNwinC -nlk $SubAptNSMNlook -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bin/data_process_sngl/sub_aperture_anisotropy.exe -id \x22$SubAptDirInput\x22 -od \x22$SubAptDirOutput\x22 -iodf $SubAptF -subi $SubAptInit -subn $SubAptSubIm -nwr $SubAptNSMNwinL -nwc $SubAptNSMNwinC -nlk $SubAptNSMNlook -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    set SubAptDirOutput $SubAptOutputDir
    append SubAptDirOutput $SubAptOutputDirSub
    append SubAptDirOutput $SubAptInit
    if {$SubAptSubDir != ""} { append SubAptDirOutput "/$SubAptSubDir" }
    if [file exists "$SubAptDirOutput/TF_anisotropy.bin"] {EnviWriteConfig "$SubAptDirOutput/TF_anisotropy.bin" $FinalNlig $FinalNcol 4}
    if [file exists "$SubAptDirOutput/ratio_log.bin"] {EnviWriteConfig "$SubAptDirOutput/ratio_log.bin" $FinalNlig $FinalNcol 4}

    if [file exists "$SubAptDirOutput/TF_anisotropy.bin"] {
        set BMPFileInput "$SubAptDirOutput/TF_anisotropy.bin"
        set BMPFileOutput "$SubAptDirOutput/TF_anisotropy.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
        } else {
        set VarError ""
        set ErrorMessage "THE FILE TF_anisotropy.bin DOES NOT EXIST" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if [file exists "$SubAptDirOutput/ratio_log.bin"] {
        set BMPFileInput "$SubAptDirOutput/ratio_log.bin"
        set BMPFileOutput "$SubAptDirOutput/ratio_log.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
        } else {
        set VarError ""
        set ErrorMessage "THE FILE ratio_log.bin DOES NOT EXIST" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    set BMPDirInput $SubAptDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    }
    #Nwin
}
#TestVar
}
#SubAptNSM

#####################################################################       
}
#TestVar
} else {
if {"$VarWarningFinal"=="no"} {Window hide $widget(Toplevel248); TextEditorRunTrace "Close Window Sub-Aperture Applications" "b"}
}
#WarningFinal
}
#Sub-Aperture Number Conflict
}
#TestVar
}
#OpenDirFile} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel248" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SubApertureApplications.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel248" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel248); TextEditorRunTrace "Close Window Sub-Aperture Applications" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel248" 1
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
    pack $top.tit76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra82 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
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
Window show .top248

main $argc $argv
