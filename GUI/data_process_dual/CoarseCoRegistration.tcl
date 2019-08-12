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
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}

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
    set base .top369
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
    namespace eval ::widgets::$base.cpd83 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd83 getframe]
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
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd86
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd67
    namespace eval ::widgets::$site_6_0.but68 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd87
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.but68 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
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
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd82 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.lab67 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent68 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
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
            vTclWindow.top369
            CoRegRGB_SPP
            CoRegRGB_S2
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
## Procedure:  CoRegRGB_SPP

proc ::CoRegRGB_SPP {Directory} {
global BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError PolarType 
   
set RGBDirInput $Directory
set RGBDirOutput $Directory
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
set Channel1 ""
set Channel2 ""
if {$PolarType == "pp1"} {set Channel1 "s11"; set Channel2 "s21"}
if {$PolarType == "pp2"} {set Channel1 "s22"; set Channel2 "s12"}
if {$PolarType == "pp3"} {set Channel1 "s11"; set Channel2 "s22"}
set config "true"
set fichier "$RGBDirInput/"
append fichier "$Channel1.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/"
append fichier "$Channel2.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }

if {"$config"=="true"} {
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  CoRegRGB_S2

proc ::CoRegRGB_S2 {Directory} {
global BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $Directory
set RGBDirOutput $Directory
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
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
    wm geometry $top 200x200+66+66; update
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

proc vTclWindow.top369 {base} {
    if {$base == ""} {
        set base .top369
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
    wm geometry $top 500x420+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Pol-InSAR Coarse Co-Registration"
    vTcl:DefineAlias "$top" "Toplevel369" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Master Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel369" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CoRegMasterDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry369_149" vTcl:WidgetProc "Toplevel369" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd83 \
        -text {Input Slave Directory} 
    vTcl:DefineAlias "$top.cpd83" "TitleFrame7" vTcl:WidgetProc "Toplevel369" 1
    bind $top.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd83 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CoRegSlaveDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry234" vTcl:WidgetProc "Toplevel369" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame26" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button5" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel369" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label369_01" vTcl:WidgetProc "Toplevel369" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry369_01" vTcl:WidgetProc "Toplevel369" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label369_02" vTcl:WidgetProc "Toplevel369" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry369_02" vTcl:WidgetProc "Toplevel369" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label369_03" vTcl:WidgetProc "Toplevel369" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry369_03" vTcl:WidgetProc "Toplevel369" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label369_04" vTcl:WidgetProc "Toplevel369" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry369_04" vTcl:WidgetProc "Toplevel369" 1
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
    TitleFrame $top.tit92 \
        -ipad 2 -text {Shift Estimation} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame5" vTcl:WidgetProc "Toplevel369" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    frame $site_4_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd86" "Frame17" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd86
    label $site_5_0.lab67 \
        -text {Window Size ( Row )} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label13" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegNwinRow -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry3" vTcl:WidgetProc "Toplevel369" 1
    frame $site_5_0.cpd67 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd67" "Frame2" vTcl:WidgetProc "Toplevel369" 1
    set site_6_0 $site_5_0.cpd67
    button $site_6_0.but68 \
        \
        -command {global CoRegNwinRow NligEnd NligInit

set FinalNlig [expr $NligEnd - $NligInit + 1]

set CoRegNwinRowTmp [expr 2 * $CoRegNwinRow]
if {$CoRegNwinRowTmp < $FinalNlig} { set CoRegNwinRow $CoRegNwinRowTmp }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_6_0.but68" "Button2" vTcl:WidgetProc "Toplevel369" 1
    button $site_6_0.cpd69 \
        \
        -command {global CoRegNwinRow

set CoRegNwinRowTmp [expr $CoRegNwinRow / 2]
if {$CoRegNwinRowTmp > "1"} { set CoRegNwinRow $CoRegNwinRowTmp }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd69" "Button3" vTcl:WidgetProc "Toplevel369" 1
    pack $site_6_0.but68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_4_0.cpd87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd87" "Frame18" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd87
    label $site_5_0.lab67 \
        -text {Window Size ( Col )} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label14" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegNwinCol -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry4" vTcl:WidgetProc "Toplevel369" 1
    frame $site_5_0.cpd70 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame3" vTcl:WidgetProc "Toplevel369" 1
    set site_6_0 $site_5_0.cpd70
    button $site_6_0.but68 \
        \
        -command {global CoRegNwinCol NcolEnd NcolInit

set FinalNcol [expr $NcolEnd - $NcolInit + 1]

set CoRegNwinColTmp [expr 2 * $CoRegNwinCol]
if {$CoRegNwinColTmp < $FinalNcol} { set CoRegNwinCol $CoRegNwinColTmp }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_6_0.but68" "Button7" vTcl:WidgetProc "Toplevel369" 1
    button $site_6_0.cpd69 \
        \
        -command {global CoRegNwinCol

set CoRegNwinColTmp [expr $CoRegNwinCol / 2]
if {$CoRegNwinColTmp > "1"} { set CoRegNwinCol $CoRegNwinColTmp }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd69" "Button8" vTcl:WidgetProc "Toplevel369" 1
    pack $site_6_0.but68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    button $site_4_0.cpd88 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 TMPCoRegTxt
global CoRegMasterDirInput CoRegSlaveDirInput
global CoRegSlaveDirOutput CoRegFonction
global CoRegNwinRow CoRegNwinCol
global CoRegRTL CoRegCTL CoRegRTR CoRegCTR
global CoRegRC CoRegCC CoRegRBL CoRegCBL
global CoRegRBR CoRegCBR CoRegRAV CoRegCAV
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Window Size (Row)"; set TestVarType(4) "int"; set TestVarValue(4) $CoRegNwinRow; set TestVarMin(4) "1"; set TestVarMax(4) "$FinalNlig"
    set TestVarName(5) "Window Size (Col)"; set TestVarType(5) "int"; set TestVarValue(5) $CoRegNwinCol; set TestVarMin(5) "1"; set TestVarMax(5) "$FinalNcol"
    TestVar 6
    if {$TestVarError == "ok"} {

        DeleteFile $TMPCoRegTxt
    
        set Fonction "Coarse Co-Registration"
        set Fonction2 "Shift Row / Col Estimation"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_dual/coarse_coregistration_estimation.exe" "k"
        TextEditorRunTrace "Arguments: -imd \x22$CoRegMasterDirInput\x22 -isd \x22$CoRegSlaveDirInput\x22 -of \x22$TMPCoRegTxt\x22 -iodf $CoRegFonction -nwr $CoRegNwinRow -nwc $CoRegNwinCol" "k"
        set f [ open "| Soft/bin/data_process_dual/coarse_coregistration_estimation.exe -imd \x22$CoRegMasterDirInput\x22 -isd \x22$CoRegSlaveDirInput\x22 -of \x22$TMPCoRegTxt\x22 -iodf $CoRegFonction -nwr $CoRegNwinRow -nwc $CoRegNwinCol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"  

    WaitUntilCreated $TMPCoRegTxt
    if [file exists $TMPCoRegTxt] {
        set f [open $TMPCoRegTxt r]
        gets $f CoRegRTL
        gets $f CoRegCTL
        gets $f CoRegRTR
        gets $f CoRegCTR
        gets $f CoRegRC
        gets $f CoRegCC
        gets $f CoRegRBL
        gets $f CoRegCBL
        gets $f CoRegRBR
        gets $f CoRegCBR
        gets $f CoRegRAV
        gets $f CoRegCAV
        close $f
        $widget(Button369_1) configure -state normal
        
        $widget(TitleFrame369_1) configure -state normal; $widget(TitleFrame369_2) configure -state normal
        $widget(TitleFrame369_3) configure -state normal; $widget(TitleFrame369_5) configure -state normal
        
        $widget(Label369_1) configure -state normal; $widget(Label369_2) configure -state normal
        $widget(Label369_3) configure -state normal; $widget(Label369_4) configure -state normal
        $widget(Label369_5) configure -state normal; $widget(Label369_6) configure -state normal
        $widget(Label369_7) configure -state normal; $widget(Label369_8) configure -state normal
        $widget(Label369_9) configure -state normal; $widget(Label369_10) configure -state normal
        $widget(Label369_11) configure -state normal; $widget(Label369_12) configure -state normal

        $widget(Entry369_1) configure -disabledbackground #FFFFFF; $widget(Entry369_2) configure -disabledbackground #FFFFFF
        $widget(Entry369_3) configure -disabledbackground #FFFFFF; $widget(Entry369_4) configure -disabledbackground #FFFFFF
        $widget(Entry369_5) configure -disabledbackground #FFFFFF; $widget(Entry369_6) configure -disabledbackground #FFFFFF
        $widget(Entry369_7) configure -disabledbackground #FFFFFF; $widget(Entry369_8) configure -disabledbackground #FFFFFF
        $widget(Entry369_9) configure -disabledbackground #FFFFFF; $widget(Entry369_10) configure -disabledbackground #FFFFFF
        $widget(Entry369_11) configure -disabledbackground #FFFFFF; $widget(Entry369_12) configure -disabledbackground #FFFFFF
        $widget(Entry369_11) configure -state normal; $widget(Entry369_12) configure -state normal

        set CoRegSlaveDirOutput $CoRegSlaveDirInput; append CoRegSlaveDirOutput "_COR"
        $widget(Entry369_21) configure -disabledbackground #FFFFFF; $widget(Entry369_21) configure -state normal
        }
    }
    #TestVar
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_4_0.cpd88" "Button4" vTcl:WidgetProc "Toplevel369" 1
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit72 \
        -ipad 0 -text {Shift Row} 
    vTcl:DefineAlias "$top.tit72" "TitleFrame369_1" vTcl:WidgetProc "Toplevel369" 1
    bind $top.tit72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit72 getframe]
    frame $site_4_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame4" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd75
    label $site_5_0.lab67 \
        -text {Top - Left} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_1" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegRTL -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_1" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame5" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd76
    label $site_5_0.lab67 \
        -text {Top - Right} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_2" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegRTR -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_2" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame7" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd77
    label $site_5_0.lab67 \
        -text Center 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_3" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegRC -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_3" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd78
    label $site_5_0.lab67 \
        -text {Botton - Left} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_4" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegRBL -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_4" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame10" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd79
    label $site_5_0.lab67 \
        -text {Botton - Right} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_5" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegRBR -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_5" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd81 \
        -ipad 0 -text {Shift Col} 
    vTcl:DefineAlias "$top.cpd81" "TitleFrame369_2" vTcl:WidgetProc "Toplevel369" 1
    bind $top.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd81 getframe]
    frame $site_4_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame11" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd75
    label $site_5_0.lab67 \
        -text {Top - Left} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_6" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegCTL -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_6" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame12" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd76
    label $site_5_0.lab67 \
        -text {Top - Right} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_7" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegCTR -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_7" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame13" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd77
    label $site_5_0.lab67 \
        -text Center 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_8" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegCC -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_8" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame14" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd78
    label $site_5_0.lab67 \
        -text {Botton - Left} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_9" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegCBL -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_9" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame15" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd79
    label $site_5_0.lab67 \
        -text {Botton - Right} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_10" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CoRegCBR -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_10" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd82 \
        -ipad 2 -text Co-Registration 
    vTcl:DefineAlias "$top.cpd82" "TitleFrame369_3" vTcl:WidgetProc "Toplevel369" 1
    bind $top.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd82 getframe]
    frame $site_4_0.cpd83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd83" "Frame21" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd83
    label $site_5_0.lab67 \
        -text {Shift Row} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_11" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable CoRegRAV -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_11" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame22" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd84
    label $site_5_0.lab67 \
        -text {Shift Col} 
    vTcl:DefineAlias "$site_5_0.lab67" "Label369_12" vTcl:WidgetProc "Toplevel369" 1
    entry $site_5_0.ent68 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable CoRegCAV -width 5 
    vTcl:DefineAlias "$site_5_0.ent68" "Entry369_12" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.lab67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    TitleFrame $top.cpd72 \
        -text {Output Slave Directory} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame369_5" vTcl:WidgetProc "Toplevel369" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CoRegSlaveDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry369_21" vTcl:WidgetProc "Toplevel369" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame27" vTcl:WidgetProc "Toplevel369" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button6" vTcl:WidgetProc "Toplevel369" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel369" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2
global CoRegMasterDirInput CoRegSlaveDirInput
global CoRegSlaveDirOutput
global CoRegRAV CoRegCAV
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global ProgressLine ConfigFile PolarCase PolarType TMPMemoryAllocError MaskCmd

if {$OpenDirFile == 0} {

    #####################################################################
    #Create Directory
    set config "ok"
    set CoRegSlaveDirOutput [PSPCreateDirectoryMask $CoRegSlaveDirOutput $CoRegSlaveDirOutput $CoRegSlaveDirInput]
    set config $VarWarning
    #####################################################################       

if {$config =="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set tmp [expr 0 - $NligFullSize]
    set TestVarName(4) "Shift Row"; set TestVarType(4) "int"; set TestVarValue(4) $CoRegRAV; set TestVarMin(4) $tmp; set TestVarMax(2) $NligFullSize
    set tmp [expr 0 - $NcolFullSize]
    set TestVarName(5) "Shift Col"; set TestVarType(5) "int"; set TestVarValue(5) $CoRegCAV; set TestVarMin(5) $tmp; set TestVarMax(3) $NcolFullSize
    TestVar 6
    if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
  
        set Fonction "Coarse Co-Registration"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_dual/coarse_coregistration.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CoRegSlaveDirInput\x22 -od \x22$CoRegSlaveDirOutput\x22 -iodf $CoRegFonction -sr $CoRegRAV -sc $CoRegCAV" "k"
        set f [ open "| Soft/bin/data_process_dual/coarse_coregistration.exe -id \x22$CoRegSlaveDirInput\x22 -od \x22$CoRegSlaveDirOutput\x22 -iodf $CoRegFonction -sr $CoRegRAV -sc $CoRegCAV" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        MapInfoWriteConfig $CoRegSlaveDirOutput
        EnviWriteConfigS $CoRegSlaveDirOutput $FinalNlig $FinalNcol 
        set MaskCmd ""
        set MaskFile "$CoRegSlaveDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
            
        set config ""
        set ConfigFile "$CoRegSlaveDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            set SourceFile "$CoRegSlaveDirInput/ceos_leader.txt"
            if [file exists $SourceFile] {
                set TargetFile "$CoRegSlaveDirOutput/ceos_leader.txt"
                CopyFile $SourceFile $TargetFile
                }
            set SourceFile "$CoRegSlaveDirInput/ceos_image.txt"
            if [file exists $SourceFile] {
                set TargetFile "$CoRegSlaveDirOutput/ceos_image.txt"
                CopyFile $SourceFile $TargetFile
                }
            set DataDirChannel2 $CoRegSlaveDirOutput
            if {$CoRegFonction == "SPP"} {CoRegRGB_SPP $CoRegSlaveDirOutput}
            if {$CoRegFonction == "S2"} {CoRegRGB_S2 $CoRegSlaveDirOutput}
            } else {
            append ErrorMessage " -> An ERROR occured during the Data Extraction"
            set VarError ""
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            }
        }
        #TestVar
    } else {
    if {$config == "nono"} {Window hide $widget(Toplevel369); TextEditorRunTrace "Close Window Pol-InSAR Coarse Co-Registration" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button369_1" vTcl:WidgetProc "Toplevel369" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CoarseCoRegistration.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text {} -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel369" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel369); TextEditorRunTrace "Close Window Pol-InSAR Coarse Co-Registration" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel369" 1
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
    pack $top.cpd83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
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
Window show .top369

main $argc $argv
