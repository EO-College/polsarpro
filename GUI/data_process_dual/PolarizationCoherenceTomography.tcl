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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
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
    set base .top342
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
    namespace eval ::widgets::$base.cpd73 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
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
    namespace eval ::widgets::$base.tit73 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra74
    namespace eval ::widgets::$site_5_0.che77 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra75
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd78 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra88
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra90
    namespace eval ::widgets::$site_9_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra79 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra79
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-borderwidth 1}
    }
    set site_7_0 $site_6_0.cpd80
    namespace eval ::widgets::$site_7_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd84 {
        array set save {-borderwidth 1 -relief 1}
    }
    set site_8_0 $site_7_0.cpd84
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd77
    namespace eval ::widgets::$site_9_0.but79 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.but80 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-borderwidth 1}
    }
    set site_7_0 $site_6_0.cpd67
    namespace eval ::widgets::$site_7_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd84 {
        array set save {-borderwidth 1 -relief 1}
    }
    set site_8_0 $site_7_0.cpd84
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd77
    namespace eval ::widgets::$site_9_0.but79 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.but80 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-borderwidth 1}
    }
    set site_7_0 $site_6_0.cpd81
    namespace eval ::widgets::$site_7_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd83 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd83 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra74
    namespace eval ::widgets::$site_5_0.che77 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra75
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd78 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra88
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra90
    namespace eval ::widgets::$site_9_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra88
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra90
    namespace eval ::widgets::$site_9_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd87 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra88
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra90
    namespace eval ::widgets::$site_9_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra88
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra90
    namespace eval ::widgets::$site_9_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra79 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra79
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-ipad 1 -text 1}
    }
    set site_8_0 [$site_6_0.cpd95 getframe]
    namespace eval ::widgets::$site_8_0 {
        array set save {}
    }
    set site_8_0 $site_8_0
    namespace eval ::widgets::$site_8_0.cpd97 {
        array set save {-entrybg 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd98 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-ipad 1 -text 1}
    }
    set site_8_0 [$site_6_0.cpd96 getframe]
    namespace eval ::widgets::$site_8_0 {
        array set save {}
    }
    set site_8_0 $site_8_0
    namespace eval ::widgets::$site_8_0.cpd92 {
        array set save {-borderwidth 1}
    }
    set site_9_0 $site_8_0.cpd92
    namespace eval ::widgets::$site_9_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd94 {
        array set save {-borderwidth 1}
    }
    set site_9_0 $site_8_0.cpd94
    namespace eval ::widgets::$site_9_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
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
            vTclWindow.top342
            PCTUpdate
            Gamma_Files
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
## Procedure:  PCTUpdate

proc ::PCTUpdate {} {
global PCTChannel
global PCTDir PCTList PCTString
global VarError ErrorMessage

set PCTList(0) ""
for {set i 1} {$i < 100} {incr i } { set PCTList($i) "" }

set NumList 0
if [file exists "$PCTDir/cmplx_coh_PCTgamHi.bin"] {
    incr NumList
    set PCTList($NumList) "PCT GamHi"
    }
if [file exists "$PCTDir/cmplx_coh_PCTgamLo.bin"] {
    incr NumList
    set PCTList($NumList) "PCT GamLo"
    }
if [file exists "$PCTDir/cmplx_coh_HH.bin"] {
    incr NumList
    set PCTList($NumList) "HH"
    }
if [file exists "$PCTDir/cmplx_coh_avg_HH.bin"] {
    incr NumList
    set PCTList($NumList) "HH (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_HV.bin"] {
    incr NumList
    set PCTList($NumList) "HV"
    }
if [file exists "$PCTDir/cmplx_coh_avg_HV.bin"] {
    incr NumList
    set PCTList($NumList) "HV (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_VV.bin"] {
    incr NumList
    set PCTList($NumList) "VV"
    }
if [file exists "$PCTDir/cmplx_coh_avg_VV.bin"] {
    incr NumList
    set PCTList($NumList) "VV (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_HHpVV.bin"] {
    incr NumList
    set PCTList($NumList) "HH + VV"
    }
if [file exists "$PCTDir/cmplx_coh_avg_HHpVV.bin"] {
    incr NumList
    set PCTList($NumList) "HH + VV (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_HHmVV.bin"] {
    incr NumList
    set PCTList($NumList) "HH - VV"
    }
if [file exists "$PCTDir/cmplx_coh_avg_HHmVV.bin"] {
    incr NumList
    set PCTList($NumList) "HH - VV (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_HVpVH.bin"] {
    incr NumList
    set PCTList($NumList) "HV + VH"
    }
if [file exists "$PCTDir/cmplx_coh_avg_HVpVH.bin"] {
    incr NumList
    set PCTList($NumList) "HV + VH (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_LL.bin"] {
    incr NumList
    set PCTList($NumList) "LL"
    }
if [file exists "$PCTDir/cmplx_coh_avg_LL.bin"] {
    incr NumList
    set PCTList($NumList) "LL (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_LR.bin"] {
    incr NumList
    set PCTList($NumList) "LR"
    }
if [file exists "$PCTDir/cmplx_coh_avg_LR.bin"] {
    incr NumList
    set PCTList($NumList) "LR (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_RR.bin"] {
    incr NumList
    set PCTList($NumList) "RR"
    }
if [file exists "$PCTDir/cmplx_coh_avg_RR.bin"] {
    incr NumList
    set PCTList($NumList) "RR (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_Opt1.bin"] {
    incr NumList
    set PCTList($NumList) "OPT 1"
    }
if [file exists "$PCTDir/cmplx_coh_avg_Opt1.bin"] {
    incr NumList
    set PCTList($NumList) "OPT 1 (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_Opt2.bin"] {
    incr NumList
    set PCTList($NumList) "OPT 2"
    }
if [file exists "$PCTDir/cmplx_coh_avg_Opt2.bin"] {
    incr NumList
    set PCTList($NumList) "OPT 2 (avg)"
    }
if [file exists "$PCTDir/cmplx_coh_Opt3.bin"] {
    incr NumList
    set PCTList($NumList) "OPT 3"
    }
if [file exists "$PCTDir/cmplx_coh_avg_Opt3.bin"] {
    incr NumList
    set PCTList($NumList) "OPT 3 (avg)"
    }

if {$NumList == 0} {              
    set VarError ""
    set ErrorMessage "COMPLEX COHERENCE FILES MUST BE CREATED FIRST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set PCTString ""
    for {set i 1} {$i <= $NumList} {incr i } { lappend PCTString $PCTList($i) }
    .top342.cpd83.f.fra75.fra79.cpd95.f.cpd97 configure -values $PCTString
    set PCTChannel $PCTList(1)
    }
}
#############################################################################
## Procedure:  Gamma_Files

proc ::Gamma_Files {} {
global PCTDir PCTChannel PCTChannelFile

set PCTChannelFile ""
if {$PCTChannel == "PCT GamHi" } { set PCTChannelFile "$PCTDir/cmplx_coh_PCTgamHi.bin" }
if {$PCTChannel == "PCT GamLo" } { set PCTChannelFile "$PCTDir/cmplx_coh_PCTgamLo.bin" }
if {$PCTChannel == "HH" } { set PCTChannelFile "$PCTDir/cmplx_coh_HH.bin" }
if {$PCTChannel == "HH (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_HH.bin" }
if {$PCTChannel == "HV" } { set PCTChannelFile "$PCTDir/cmplx_coh_HV.bin" }
if {$PCTChannel == "HV (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_HV.bin" }
if {$PCTChannel == "VV" } { set PCTChannelFile "$PCTDir/cmplx_coh_VV.bin" }
if {$PCTChannel == "VV (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_VV.bin" }
if {$PCTChannel == "LL" } { set PCTChannelFile "$PCTDir/cmplx_coh_LL.bin" }
if {$PCTChannel == "LL (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_LL.bin" }
if {$PCTChannel == "LR" } { set PCTChannelFile "$PCTDir/cmplx_coh_LR.bin" }
if {$PCTChannel == "LR (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_LR.bin" }
if {$PCTChannel == "RR" } { set PCTChannelFile "$PCTDir/cmplx_coh_RR.bin" }
if {$PCTChannel == "RR (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_RR.bin" }
if {$PCTChannel == "HH + VV" } { set PCTChannelFile "$PCTDir/cmplx_coh_HHpVV.bin" }
if {$PCTChannel == "HH + VV (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_HHpVV.bin" }
if {$PCTChannel == "HV + VH" } { set PCTChannelFile "$PCTDir/cmplx_coh_HVpVH.bin" }
if {$PCTChannel == "HV + VH (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_HVpVH.bin" }
if {$PCTChannel == "HH - VV" } { set PCTChannelFile "$PCTDir/cmplx_coh_HHmVV.bin" }
if {$PCTChannel == "HH - VV (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_HHmVV.bin" }
if {$PCTChannel == "OPT 1" } { set PCTChannelFile "$PCTDir/cmplx_coh_Opt1.bin" }
if {$PCTChannel == "OPT 1 (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_Opt1.bin" }
if {$PCTChannel == "OPT 2" } { set PCTChannelFile "$PCTDir/cmplx_coh_Opt2.bin" }
if {$PCTChannel == "OPT 2 (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_Opt2.bin" }
if {$PCTChannel == "OPT 3" } { set PCTChannelFile "$PCTDir/cmplx_coh_Opt3.bin" }
if {$PCTChannel == "OPT 3 (avg)" } { set PCTChannelFile "$PCTDir/cmplx_coh_avg_Opt3.bin" }
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

proc vTclWindow.top342 {base} {
    if {$base == ""} {
        set base .top342
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
    wm geometry $top 500x610+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Polarization Coherence Tomography (P.C.T)"
    vTcl:DefineAlias "$top" "Toplevel342" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Master Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame342_1" vTcl:WidgetProc "Toplevel342" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PCTMasterDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry342_1" vTcl:WidgetProc "Toplevel342" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel342" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd73 \
        -text {Input Slave Directory} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame342_2" vTcl:WidgetProc "Toplevel342" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PCTSlaveDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry342_2" vTcl:WidgetProc "Toplevel342" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame5" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button2" vTcl:WidgetProc "Toplevel342" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -text {Output Master - Slave Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel342" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PCTOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry342_73" vTcl:WidgetProc "Toplevel342" 1
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel342" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTOutputSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel342" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName DataDirChannel1 PCTOutputDir

set PCTOutputDirTmp $PCTOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT MAIN DIRECTORY"
if {$DirName != "" } {
    set PCTOutputDir $DirName
    } else {
    set PCTOutputDir $PCTOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button342_92" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel342" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label342_01" vTcl:WidgetProc "Toplevel342" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry342_01" vTcl:WidgetProc "Toplevel342" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label342_02" vTcl:WidgetProc "Toplevel342" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry342_02" vTcl:WidgetProc "Toplevel342" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label342_03" vTcl:WidgetProc "Toplevel342" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry342_03" vTcl:WidgetProc "Toplevel342" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label342_04" vTcl:WidgetProc "Toplevel342" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry342_04" vTcl:WidgetProc "Toplevel342" 1
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
    TitleFrame $top.tit73 \
        -ipad 0 -text {P.C.T Parameters Estimation} 
    vTcl:DefineAlias "$top.tit73" "TitleFrame3" vTcl:WidgetProc "Toplevel342" 1
    bind $top.tit73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit73 getframe]
    frame $site_4_0.fra74 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra74" "Frame3" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.fra74
    checkbutton $site_5_0.che77 \
        \
        -command {global PCTpara KzPCTFile PCTNwinL PCTNwinC PCTEpsilon

if {$PCTpara == 0} {
    set KzPCTFile ""
    set PCTNwinL ""
    set PCTNwinC ""
    set PCTEpsilon ""
    $widget(TitleFrame342_3) configure -state disable
    $widget(Button342_1) configure -state disable
    $widget(Button342_2) configure -state disable
    $widget(Button342_3) configure -state disable
    $widget(Button342_2a) configure -state disable
    $widget(Button342_3a) configure -state disable
    $widget(Button342_4) configure -state disable
    $widget(Label342_1) configure -state disable
    $widget(Label342_1a) configure -state disable
    $widget(Label342_2) configure -state disable
    $widget(Entry342_3) configure -state disable
    $widget(Entry342_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_4) configure -state disable
    $widget(Entry342_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_4a) configure -state disable
    $widget(Entry342_4a) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_5) configure -state disable
    $widget(Entry342_5) configure -disabledbackground $PSPBackgroundColor   
} else {
    set KzPCTFile ""
    set PCTNwinL "11"
    set PCTNwinC "11"
    set PCTEpsilon "0.8"
    $widget(TitleFrame342_3) configure -state normal
    $widget(Button342_1) configure -state normal
    $widget(Button342_2) configure -state normal
    $widget(Button342_3) configure -state normal
    $widget(Button342_2a) configure -state normal
    $widget(Button342_3a) configure -state normal
    $widget(Button342_4) configure -state normal
    $widget(Label342_1) configure -state normal
    $widget(Label342_1a) configure -state normal
    $widget(Label342_2) configure -state normal
    $widget(Entry342_3) configure -state disable
    $widget(Entry342_3) configure -disabledbackground #FFFFFF
    $widget(Entry342_4) configure -state disable
    $widget(Entry342_4) configure -disabledbackground #FFFFFF
    $widget(Entry342_4a) configure -state disable
    $widget(Entry342_4a) configure -disabledbackground #FFFFFF
    $widget(Entry342_5) configure -state normal
    $widget(Entry342_5) configure -disabledbackground #FFFFFF
}} \
        -variable PCTpara 
    vTcl:DefineAlias "$site_5_0.che77" "Checkbutton1" vTcl:WidgetProc "Toplevel342" 1
    pack $site_5_0.che77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra75" "Frame4" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.fra75
    TitleFrame $site_5_0.cpd78 \
        -ipad 0 -text {2D Kz File} 
    vTcl:DefineAlias "$site_5_0.cpd78" "TitleFrame342_3" vTcl:WidgetProc "Toplevel342" 1
    bind $site_5_0.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd78 getframe]
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame112" vTcl:WidgetProc "Toplevel342" 1
    set site_8_0 $site_7_0.cpd76
    frame $site_8_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra88" "Frame21" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra88
    entry $site_9_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable KzPCTFile -width 40 
    vTcl:DefineAlias "$site_9_0.cpd89" "Entry342_3" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 1 -fill x -side top 
    frame $site_8_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra90" "Frame22" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra90
    button $site_9_0.cpd72 \
        \
        -command {global FileName PCTMasterDirInput KzPCTFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D Kz FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Kz Files}        {.dat}        }
{{Kz Files}        {.bin}        }
}
set FileName ""
OpenFile "$PCTMasterDirInput" $types "2D Kz FILE"
if {$FileName != ""} {
    set KzPCTFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd72" "Button342_1" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_9_0.cpd72 "$site_9_0.cpd72 Button $top all _vTclBalloon"
    bind $site_9_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_9_0.cpd72 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.fra88 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.fra90 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra79" "Frame23" vTcl:WidgetProc "Toplevel342" 1
    set site_6_0 $site_5_0.fra79
    frame $site_6_0.cpd80 \
        -borderwidth 2 
    set site_7_0 $site_6_0.cpd80
    label $site_7_0.cpd82 \
        -text {Window Size : Row} 
    vTcl:DefineAlias "$site_7_0.cpd82" "Label342_1" vTcl:WidgetProc "Toplevel342" 1
    frame $site_7_0.cpd84 \
        -borderwidth 2 -relief groove 
    set site_8_0 $site_7_0.cpd84
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTNwinL -width 5 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry342_4" vTcl:WidgetProc "Toplevel342" 1
    frame $site_8_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd77" "Frame19" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.cpd77
    button $site_9_0.but79 \
        \
        -command {global PCTNwinL

set PCTNwinL [expr $PCTNwinL - 2]
if {$PCTNwinL == "-1"} {set PCTNwinL 21}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.but79" "Button342_2" vTcl:WidgetProc "Toplevel342" 1
    button $site_9_0.but80 \
        \
        -command {global PCTNwinL

set PCTNwinL [expr $PCTNwinL + 2]
if {$PCTNwinL == 23} {set PCTNwinL 1}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.but80" "Button342_3" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.but79 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_9_0.but80 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd82 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_7_0.cpd84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -ipady 2 -side left 
    frame $site_6_0.cpd67 \
        -borderwidth 2 
    set site_7_0 $site_6_0.cpd67
    label $site_7_0.cpd82 \
        -text { Col} 
    vTcl:DefineAlias "$site_7_0.cpd82" "Label342_1a" vTcl:WidgetProc "Toplevel342" 1
    frame $site_7_0.cpd84 \
        -borderwidth 2 -relief groove 
    set site_8_0 $site_7_0.cpd84
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTNwinC -width 5 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry342_4a" vTcl:WidgetProc "Toplevel342" 1
    frame $site_8_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd77" "Frame35" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.cpd77
    button $site_9_0.but79 \
        \
        -command {global PCTNwinC

set PCTNwinC [expr $PCTNwinC - 2]
if {$PCTNwinC == "-1"} {set PCTNwinC 21}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.but79" "Button342_2a" vTcl:WidgetProc "Toplevel342" 1
    button $site_9_0.but80 \
        \
        -command {global PCTNwinC

set PCTNwinC [expr $PCTNwinC + 2]
if {$PCTNwinC == 23} {set PCTNwinC 1}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.but80" "Button342_3a" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.but79 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_9_0.but80 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd82 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_7_0.cpd84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -ipady 2 -side left 
    frame $site_6_0.cpd81 \
        -borderwidth 2 
    set site_7_0 $site_6_0.cpd81
    label $site_7_0.cpd82 \
        -text Epsilon 
    vTcl:DefineAlias "$site_7_0.cpd82" "Label342_2" vTcl:WidgetProc "Toplevel342" 1
    entry $site_7_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PCTEpsilon -width 5 
    vTcl:DefineAlias "$site_7_0.ent83" "Entry342_5" vTcl:WidgetProc "Toplevel342" 1
    pack $site_7_0.cpd82 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_7_0.ent83 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    button $site_6_0.cpd82 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 DirName BMPDirInput
global PCTMasterDirInput PCTSlaveDirInput PCTDirOutput PCTOutputDir PCTFonction
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global PCTNwinL PCTNwinC PCTEpsilon KzPCTFile PCTDir ConfigFile PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType PSPViewGimpBMP 

if {$OpenDirFile == 0} {

set PCTDirOutput $PCTOutputDir
if {$PCTOutputSubDir != ""} {append PCTDirOutput "/$PCTOutputSubDir"}

    #####################################################################
    #Create Directory
    set DirNameCreate $PCTDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show $widget(Toplevel44)
                set VarWarning ""
                }
            } else {
            set PCTDirOutput $PCTOutputDir
            }
        }
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "2D Kz File"; set TestVarType(4) "file"; set TestVarValue(4) $KzPCTFile; set TestVarMin(4) ""; set TestVarMax(4) ""
    set TestVarName(5) "Window Size Row"; set TestVarType(5) "int"; set TestVarValue(5) $PCTNwinL; set TestVarMin(5) "1"; set TestVarMax(5) "100"
    set TestVarName(6) "Epsilon"; set TestVarType(6) "float"; set TestVarValue(6) $PCTEpsilon; set TestVarMin(6) "0.0"; set TestVarMax(4) "1.0"
    set TestVarName(7) "Window Size Col"; set TestVarType(7) "int"; set TestVarValue(7) $PCTNwinC; set TestVarMin(7) "1"; set TestVarMax(7) "100"
    TestVar 8
    if {$TestVarError == "ok"} {
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        set MaskCmd ""
        set MaskFile "$PCTMasterDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        set MaskCmd ""
        if {$PCTFonction == "S2" || $PCTFonction == "SPP"} {
            set ConfigFile "$PCTDirOutput/config.txt"
            WriteConfig
            set MaskFileOut "$PCTDirOutput/mask_valid_pixels.bin"
            if [file exists $MaskFileOut] {
                set MaskCmd "-mask \x22$MaskFileOut\x22"
                } else {
                set MaskFile1 "$PCTMasterDirInput/mask_valid_pixels.bin"
                set MaskFile2 "$PCTSlaveDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile1] {
                    if [file exists $MaskFile2] {
                        set MaskFileOut "$PCTDirOutput/mask_valid_pixels.bin"
                        set ProgressLine "0"
                        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                        update
                        TextEditorRunTrace "Process The Function Soft/calculator/file_operand_file.exe" "k"
                        TextEditorRunTrace "Arguments: -if1 \x22$MaskFile1\x22 -it1 float -if2 \x22$MaskFile2\x22 -it2 float -of \x22$MaskFileOut\x22 -ot float -op mulfile -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                        set f [ open "| Soft/calculator/file_operand_file.exe -if1 \x22$MaskFile1\x22 -it1 float -if2 \x22$MaskFile2\x22 -it2 float -of \x22$MaskFileOut\x22 -ot float -op mulfile -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
                        EnviWriteConfig $MaskFileOut $FinalNlig $FinalNcol 4
                        if [file exists $MaskFileOut] {set MaskCmd "-mask \x22$MaskFileOut\x22"}
                        } 
                    } 
                }
            }
        if {$PCTFonction == "T4" || $PCTFonction == "T6"} {
            set MaskFile "$PCTMasterDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-maskm \x22$MaskFile\x22"}
            }
    
        set Fonction "Polarization Coherence Tomography"
        set Fonction2 "Parameters Estimation"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$PCTFonction == "SPP"} {
            TextEditorRunTrace "Process The Function Soft/data_process_dual/PCT_prepare_PP.exe" "k"
            TextEditorRunTrace "Arguments: -idm \x22$PCTMasterDirInput\x22 -ids \x22$PCTSlaveDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf SPPT4 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/PCT_prepare_PP.exe -idm \x22$PCTMasterDirInput\x22 -ids \x22$PCTSlaveDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf SPPT4 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$PCTFonction == "T4"} {
            TextEditorRunTrace "Process The Function Soft/data_process_dual/PCT_prepare_PP.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PCTMasterDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf T4 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/PCT_prepare_PP.exe -id \x22$PCTMasterDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf T4 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$PCTFonction == "S2"} {
            TextEditorRunTrace "Process The Function Soft/data_process_dual/PCT_prepare.exe" "k"
            TextEditorRunTrace "Arguments: -idm \x22$PCTMasterDirInput\x22 -ids \x22$PCTSlaveDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf S2T6 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/PCT_prepare.exe -idm \x22$PCTMasterDirInput\x22 -ids \x22$PCTSlaveDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf S2T6 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$PCTFonction == "T6"} {
            TextEditorRunTrace "Process The Function Soft/data_process_dual/PCT_prepare.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PCTMasterDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf T6 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/PCT_prepare.exe -id \x22$PCTMasterDirInput\x22 -od \x22$PCTDirOutput\x22 -iodf T6 -kz \x22$KzPCTFile\x22 -nwr $PCTNwinL -nwc $PCTNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -eps $PCTEpsilon -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$PCTDirOutput/PCT_TopoPhase.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_Height.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_Kv.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/cmplx_coh_PCTgamHi.bin" $FinalNlig $FinalNcol 6
        EnviWriteConfig "$PCTDirOutput/cmplx_coh_PCTgamLo.bin" $FinalNlig $FinalNcol 6

        if {$PCTFonction == "S2"} {
            set ConfigFile "$PCTDirOutput/config.txt"
            WriteConfig
            }
        
        PCTUpdate

        set BMPDirInput $PCTDirOutput

        set filename "$PCTDirOutput/PCT_TopoPhase"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180 180
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$PCTDirOutput/PCT_Height"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -25 25
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$PCTDirOutput/PCT_Kv"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 2
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$PCTDirOutput/cmplx_coh_PCTgamHi"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput $filename
            append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod gray $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 1
            set BMPFileOutput $filename
            append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180 180
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$PCTDirOutput/cmplx_coh_PCTgamLo"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput $filename
            append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod gray $FinalNcol 0 0 $FinalNlig $FinalNcol 0 0 1
            set BMPFileOutput $filename
            append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180 180
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set RGBDirInput $PCTMasterDirInput
        set RGBDirOutput $PCTDirOutput
        set RGBFileOutput "$RGBDirOutput/PauliRGB_PCT.bmp"
        set Fonction "Creation of the RGB BMP File :"
        set Fonction2 "$RGBFileOutput"    
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$PCTFonction == "SPP" || $PCTFonction == "T4"} {
          if {$PCTFonction == "SPP"} { set PCTFonc "SPP" }
          if {$PCTFonction == "T4"} { set PCTFonc "T2" }
          TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
          TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $PCTFonc -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
          set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $PCTFonc -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
          }
        if {$PCTFonction == "S2" || $PCTFonction == "T6"} {
          if {$PCTFonction == "S2"} { set PCTFonc "S2" }
          if {$PCTFonction == "T6"} { set PCTFonc "T3" }
          TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
          TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $PCTFonc -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
          set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $PCTFonc -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
          }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }

        $widget(Button342_0) configure -state normal
        
        set PCTDir $PCTDirOutput
        }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel303); TextEditorRunTrace "Close Window PCT" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_6_0.cpd82" "Button342_4" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_6_0.cpd82 "$site_6_0.cpd82 Button $top all _vTclBalloon"
    bind $site_6_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.fra79 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra74 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.fra75 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $top.cpd83 \
        -ipad 0 -text {P.C.T Engine} 
    vTcl:DefineAlias "$top.cpd83" "TitleFrame4" vTcl:WidgetProc "Toplevel342" 1
    bind $top.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd83 getframe]
    frame $site_4_0.fra74 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra74" "Frame24" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.fra74
    checkbutton $site_5_0.che77 \
        \
        -command {global PCTeng PCTKzFile KzPCTFile PCTKvFile PCTTopoFile PCTHeightFile
global PCTChannel PCTPixAz PCTPixRg PCTDir

if {$PCTeng == 0} {
    set PCTKzFile ""; set PCTKvFile ""; set PCTTopoFile ""; set PCTHeightFile ""
    set PCTChannel ""; set PCTPixAz ""; set PCTPixRg ""
    $widget(TitleFrame342_4) configure -state disable
    $widget(TitleFrame342_5) configure -state disable
    $widget(TitleFrame342_6) configure -state disable
    $widget(TitleFrame342_7) configure -state disable
    $widget(TitleFrame342_8) configure -state disable
    $widget(TitleFrame342_9) configure -state disable
    $widget(Button342_5) configure -state disable
    $widget(Button342_6) configure -state disable
    $widget(Button342_7) configure -state disable
    $widget(Button342_8) configure -state disable
    $widget(Button342_9) configure -state disable
    $widget(Button342_10) configure -state disable
    $widget(Label342_3) configure -state disable
    $widget(Label342_4) configure -state disable
    $widget(Entry342_6) configure -state disable
    $widget(Entry342_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_7) configure -state disable
    $widget(Entry342_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_8) configure -state disable
    $widget(Entry342_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_9) configure -state disable
    $widget(Entry342_9) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_10) configure -state disable
    $widget(Entry342_10) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry342_11) configure -state disable
    $widget(Entry342_11) configure -disabledbackground $PSPBackgroundColor
    $widget(ComboBox342_1) configure -state disabled -entrybg $PSPBackgroundColor   
} else {
    PCTUpdate
    if {$KzPCTFile != ""} { set PCTKzFile $KzPCTFile }
    if [file exists "$PCTDir/PCT_Kv.bin"] { 
        set PCTKvFile "$PCTDir/PCT_Kv.bin"
        } else {
        set PCTKvFile ""
        }
    if [file exists "$PCTDir/PCT_TopoPhase.bin"] {
        set PCTTopoFile "$PCTDir/PCT_TopoPhase.bin"
        } else {
        set PCTTopoFile ""
        }
    if [file exists "$PCTDir/PCT_Height.bin"] {
        set PCTHeightFile "$PCTDir/PCT_Height.bin"
        } else {
        set PCTHeightFile ""
        }
    set PCTChannel ""; set PCTPixAz "1.0"; set PCTPixRg "1.0"
    $widget(TitleFrame342_4) configure -state normal
    $widget(TitleFrame342_5) configure -state normal
    $widget(TitleFrame342_6) configure -state normal
    $widget(TitleFrame342_7) configure -state normal
    $widget(TitleFrame342_8) configure -state normal
    $widget(TitleFrame342_9) configure -state normal
    $widget(Button342_5) configure -state normal
    $widget(Button342_6) configure -state normal
    $widget(Button342_7) configure -state normal
    $widget(Button342_8) configure -state normal
    $widget(Button342_9) configure -state normal
    $widget(Button342_10) configure -state normal
    $widget(Label342_3) configure -state normal
    $widget(Label342_4) configure -state normal
    $widget(Entry342_6) configure -state disable
    $widget(Entry342_6) configure -disabledbackground #FFFFFF
    $widget(Entry342_7) configure -state disable
    $widget(Entry342_7) configure -disabledbackground #FFFFFF
    $widget(Entry342_8) configure -state disable
    $widget(Entry342_8) configure -disabledbackground #FFFFFF
    $widget(Entry342_9) configure -state disable
    $widget(Entry342_9) configure -disabledbackground #FFFFFF
    $widget(Entry342_10) configure -state normal
    $widget(Entry342_10) configure -disabledbackground #FFFFFF
    $widget(Entry342_11) configure -state normal
    $widget(Entry342_11) configure -disabledbackground #FFFFFF
    $widget(ComboBox342_1) configure -state normal -entrybg #FFFFFF
    }} \
        -variable PCTeng 
    vTcl:DefineAlias "$site_5_0.che77" "Checkbutton6" vTcl:WidgetProc "Toplevel342" 1
    pack $site_5_0.che77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra75" "Frame25" vTcl:WidgetProc "Toplevel342" 1
    set site_5_0 $site_4_0.fra75
    TitleFrame $site_5_0.cpd78 \
        -ipad 0 -text {2D Kz File} 
    vTcl:DefineAlias "$site_5_0.cpd78" "TitleFrame342_4" vTcl:WidgetProc "Toplevel342" 1
    bind $site_5_0.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd78 getframe]
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame113" vTcl:WidgetProc "Toplevel342" 1
    set site_8_0 $site_7_0.cpd76
    frame $site_8_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra88" "Frame26" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra88
    entry $site_9_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PCTKzFile -width 40 
    vTcl:DefineAlias "$site_9_0.cpd89" "Entry342_6" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 1 -fill x -side top 
    frame $site_8_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra90" "Frame27" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra90
    button $site_9_0.cpd72 \
        \
        -command {global FileName PCTDir PCTKzFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D Kz FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Kz Files}        {.dat}        }
{{Kz Files}        {.bin}        }
}
set FileName ""
OpenFile "$PCTDir" $types "2D Kz FILE"
if {$FileName != ""} {
    set PCTKzFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd72" "Button342_5" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_9_0.cpd72 "$site_9_0.cpd72 Button $top all _vTclBalloon"
    bind $site_9_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_9_0.cpd72 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.fra88 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.fra90 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_5_0.cpd86 \
        -ipad 0 -text {2D PCT Topographic Phase File} 
    vTcl:DefineAlias "$site_5_0.cpd86" "TitleFrame342_5" vTcl:WidgetProc "Toplevel342" 1
    bind $site_5_0.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame115" vTcl:WidgetProc "Toplevel342" 1
    set site_8_0 $site_7_0.cpd76
    frame $site_8_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra88" "Frame31" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra88
    entry $site_9_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PCTTopoFile -width 40 
    vTcl:DefineAlias "$site_9_0.cpd89" "Entry342_7" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 1 -fill x -side top 
    frame $site_8_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra90" "Frame32" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra90
    button $site_9_0.cpd72 \
        \
        -command {global FileName PCTDir PCTTopoFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Topo Files}        {.bin}        }
}
set FileName ""
OpenFile "$PCTDir" $types "2D PCT TOPOGRAPHIC PHASE FILE"
if {$FileName != ""} {
    set PCTTopoFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd72" "Button342_6" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_9_0.cpd72 "$site_9_0.cpd72 Button $top all _vTclBalloon"
    bind $site_9_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_9_0.cpd72 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.fra88 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.fra90 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_5_0.cpd87 \
        -ipad 0 -text {2D PCT Estimated Height File} 
    vTcl:DefineAlias "$site_5_0.cpd87" "TitleFrame342_6" vTcl:WidgetProc "Toplevel342" 1
    bind $site_5_0.cpd87 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd87 getframe]
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame116" vTcl:WidgetProc "Toplevel342" 1
    set site_8_0 $site_7_0.cpd76
    frame $site_8_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra88" "Frame33" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra88
    entry $site_9_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PCTHeightFile -width 40 
    vTcl:DefineAlias "$site_9_0.cpd89" "Entry342_8" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 1 -fill x -side top 
    frame $site_8_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra90" "Frame34" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra90
    button $site_9_0.cpd72 \
        \
        -command {global FileName PCTDir PCTHeightFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Height Files}        {.bin}        }
}
set FileName ""
OpenFile "$PCTDir" $types "2D PCT HEIGHT FILE"
if {$FileName != ""} {
    set PCTHeightFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd72" "Button342_7" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_9_0.cpd72 "$site_9_0.cpd72 Button $top all _vTclBalloon"
    bind $site_9_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_9_0.cpd72 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.fra88 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.fra90 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_5_0.cpd85 \
        -ipad 0 -text {2D PCT Kv File} 
    vTcl:DefineAlias "$site_5_0.cpd85" "TitleFrame342_7" vTcl:WidgetProc "Toplevel342" 1
    bind $site_5_0.cpd85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame114" vTcl:WidgetProc "Toplevel342" 1
    set site_8_0 $site_7_0.cpd76
    frame $site_8_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra88" "Frame29" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra88
    entry $site_9_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PCTKvFile -width 40 
    vTcl:DefineAlias "$site_9_0.cpd89" "Entry342_9" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 1 -fill x -side top 
    frame $site_8_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra90" "Frame30" vTcl:WidgetProc "Toplevel342" 1
    set site_9_0 $site_8_0.fra90
    button $site_9_0.cpd72 \
        \
        -command {global FileName PCTDir PCTKvFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Kv Files}        {.bin}        }
}
set FileName ""
OpenFile "$PCTDir" $types "2D PCT Kv FILE"
if {$FileName != ""} {
    set KvFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd72" "Button342_8" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_9_0.cpd72 "$site_9_0.cpd72 Button $top all _vTclBalloon"
    bind $site_9_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_9_0.cpd72 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.fra88 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.fra90 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra79" "Frame28" vTcl:WidgetProc "Toplevel342" 1
    set site_6_0 $site_5_0.fra79
    TitleFrame $site_6_0.cpd95 \
        -ipad 2 -text {Polarimetric Channel} 
    vTcl:DefineAlias "$site_6_0.cpd95" "TitleFrame342_8" vTcl:WidgetProc "Toplevel342" 1
    bind $site_6_0.cpd95 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd95 getframe]
    ComboBox $site_8_0.cpd97 \
        -entrybg #ffffff -takefocus 1 -textvariable PCTChannel -width 12 
    vTcl:DefineAlias "$site_8_0.cpd97" "ComboBox342_1" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_8_0.cpd97 "$site_8_0.cpd97 BwComboBox $top all"
    button $site_8_0.cpd98 \
        -background #ffff00 -command PCTUpdate -padx 4 -pady 2 \
        -text {Update List} 
    vTcl:DefineAlias "$site_8_0.cpd98" "Button342_9" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_8_0.cpd98 "$site_8_0.cpd98 Button $top all _vTclBalloon"
    bind $site_8_0.cpd98 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Update List}
    }
    pack $site_8_0.cpd97 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd98 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    button $site_6_0.cpd82 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 DirName BMPDirInput
global PCTDirOutput PCTOutputDir PCTOutputSubDir TMPPCTAsc TMPPCTBin PCTExecFid
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global OpenDirFile PCTKzFile PCTKvFile PCTTopoFile PCTHeightFile PCTChannel PCTChannelFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set PCTDirOutput $PCTOutputDir
if {$PCTOutputSubDir != ""} {append PCTDirOutput "/$PCTOutputSubDir"}

    #####################################################################
    #Create Directory
    set PCTDirOutput [PSPCreateDirectory $PCTDirOutput $PCTOutputDir "NO"]
    #####################################################################       

if {"$VarWarning"=="ok"} {

    Gamma_Files

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "2D Kz File"; set TestVarType(4) "file"; set TestVarValue(4) $PCTKzFile; set TestVarMin(4) ""; set TestVarMax(4) ""
    set TestVarName(5) "2D PCT Kv File"; set TestVarType(5) "file"; set TestVarValue(5) $PCTKvFile; set TestVarMin(5) ""; set TestVarMax(5) ""
    set TestVarName(6) "2D PCT Topo Phase File"; set TestVarType(6) "file"; set TestVarValue(6) $PCTTopoFile; set TestVarMin(6) ""; set TestVarMax(6) ""
    set TestVarName(7) "2D PCT Height File"; set TestVarType(7) "file"; set TestVarValue(7) $PCTHeightFile; set TestVarMin(7) ""; set TestVarMax(7) ""
    set TestVarName(8) "Gamma File"; set TestVarType(8) "file"; set TestVarValue(8) $PCTChannelFile; set TestVarMin(8) ""; set TestVarMax(8) ""
    TestVar 9
    if {$TestVarError == "ok"} {
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
        DeleteFile $TMPPCTAsc
        DeleteFile $TMPPCTBin
    
        set Fonction "Polarization Coherence Tomography"
        set Fonction2 "Engine"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/PCT_engine.exe" "k"
        TextEditorRunTrace "Arguments: -od \x22$PCTDirOutput\x22 -ifg \x22$PCTChannelFile\x22 -ifh \x22$PCTHeightFile\x22 -ift \x22$PCTTopoFile\x22 -ifkv \x22$PCTKvFile\x22 -ifkz \x22$PCTKzFile\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -oasc \x22$TMPPCTAsc\x22 -obin \x22$TMPPCTBin\x22" "k"
        set f [ open "| Soft/data_process_dual/PCT_engine.exe -od \x22$PCTDirOutput\x22 -ifg \x22$PCTChannelFile\x22 -ifh \x22$PCTHeightFile\x22 -ift \x22$PCTTopoFile\x22 -ifkv \x22$PCTKvFile\x22 -ifkz \x22$PCTKzFile\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -oasc \x22$TMPPCTAsc\x22 -obin \x22$TMPPCTBin\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$PCTDirOutput/PCT_f0.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_f1.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_f2.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_a10.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_a20.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_q1.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_q2.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$PCTDirOutput/PCT_q3.bin" $FinalNlig $FinalNcol 4

        set BMPDirInput $PCTDirOutput

        set filename "$PCTDirOutput/PCT_a10"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -3 3
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$PCTDirOutput/PCT_a20"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -7 7
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        $widget(Button342_0) configure -state normal
        $widget(Button342_00) configure -state normal
        
        if {$PCTExecFid != ""} {
            set ProgressLine ""
            puts $PCTExecFid "load\n"
            flush $PCTExecFid
            fconfigure $PCTExecFid -buffering line
            while {$ProgressLine != "OKload"} {
                gets $PCTExecFid ProgressLine
                update
                }
            }                

        }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel303); TextEditorRunTrace "Close Window PCT" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_6_0.cpd82" "Button342_10" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_6_0.cpd82 "$site_6_0.cpd82 Button $top all _vTclBalloon"
    bind $site_6_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    TitleFrame $site_6_0.cpd96 \
        -ipad 2 -text {Pixel Spacing} 
    vTcl:DefineAlias "$site_6_0.cpd96" "TitleFrame342_9" vTcl:WidgetProc "Toplevel342" 1
    bind $site_6_0.cpd96 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_8_0 [$site_6_0.cpd96 getframe]
    frame $site_8_0.cpd92 \
        -borderwidth 2 
    set site_9_0 $site_8_0.cpd92
    label $site_9_0.cpd82 \
        -text Row 
    vTcl:DefineAlias "$site_9_0.cpd82" "Label342_3" vTcl:WidgetProc "Toplevel342" 1
    entry $site_9_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PCTPixAz -width 5 
    vTcl:DefineAlias "$site_9_0.ent83" "Entry342_10" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.cpd82 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_9_0.ent83 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_8_0.cpd94 \
        -borderwidth 2 
    set site_9_0 $site_8_0.cpd94
    label $site_9_0.cpd82 \
        -text Col 
    vTcl:DefineAlias "$site_9_0.cpd82" "Label342_4" vTcl:WidgetProc "Toplevel342" 1
    entry $site_9_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PCTPixRg -width 5 
    vTcl:DefineAlias "$site_9_0.ent83" "Entry342_11" vTcl:WidgetProc "Toplevel342" 1
    pack $site_9_0.cpd82 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_9_0.ent83 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.cpd92 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd94 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.fra79 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra74 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.fra75 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel342" 1
    set site_3_0 $top.fra83
    button $site_3_0.but73 \
        -background #ffff00 \
        -command {global DataDir FileName
global PCTDirOutput PCTOutputDir PCTOutputSubDir
global HistoDirInput HistoDirOutput HistoOutputDir HistoOutputSubDir
global HistoFileInput HistoFileOpen
global TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt
global BMPDirInput BMPViewFileInput
global LineXLensInit LineYLensInit line_color
global ConfigFile VarError ErrorMessage Fonction
global VarWarning WarningMesage WarningMessage2
global HistoExecFid HistoOutputFile PCTExecFid
global GnuPlotPath GnuplotPipeFid GnuplotPipeHisto
global GnuOutputFormat GnuOutputFile 
global GnuHistoTitle GnuHistoLabel GnuHistoStyle
global HistoInputFormat HistoOutputFormat
global MinMaxAutoHisto MinHisto MaxHisto
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol AreaPointN
global widget SourceWidth SourceHeight WidthBMP HeightBMP BMPWidth BMPHeight
global ZoomBMP BMPImage ImageSource BMPCanvas
global TrainingAreaToolLine rect_color VarHistoSave VarStatToolLine                    

#DATA PROCESS SNGL
global Load_Histograms
#BMP PROCESS
global Load_ViewBMPLens Load_DisplayPCT PSPTopLevel

if {$Load_DisplayPCT == 1} {
    if {$PCTExecFid != ""} {
        puts $PCTExecFid "exit\n"
        flush $PCTExecFid
        fconfigure $PCTExecFid -buffering line
        while {$ProgressLine != "OKexit"} {
            gets $PCTExecFid ProgressLine
            update
            }
        catch "close $PCTExecFid"
        set PCTExecFid ""

        ClosePSPViewer
        PCTcloseBMP
        Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
        Window hide $widget(Toplevel343); TextEditorRunTrace "Close Window Display PCT" "b"
        }
    }

ClosePSPViewer
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"

set config "true"
if {$HistoExecFid != ""} {
    set ErrorMessage "STATISTICS - HISTOGRAM IS ALREADY RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$GnuplotPipeFid != ""} {
    set ErrorMessage "GNUPLOT IS ALREADY RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$config == "true"} {
if [file exists "$PCTDirOutput/config.txt"] {
    set HistoDirInput $PCTDirOutput
    set HistoDirOutput $PCTDirOutput
    set HistoOutputDir $PCTOutputDir
    set HistoOutputSubDir $PCTOutputSubDir
    set BMPDirInput $HistoDirInput
    set ConfigFile "$HistoDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$OpenDirFile == 0} {     
            set WarningMessage "OPEN A BMP FILE"
            set WarningMessage2 "TO SELECT AN AREA"
            set VarWarning ""
            Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
            tkwait variable VarWarning

            if {$VarWarning == "ok"} {
                LoadPSPViewer
                Window show $widget(Toplevel64); TextEditorRunTrace "Open Window PolSARpro Viewer" "b"

                if {$Load_Histograms == 0} {
                    source "GUI/data_process_sngl/Histograms.tcl"
                    set Load_Histograms 1
                    WmTransient $widget(Toplevel260) $PSPTopLevel
                    }
                set line_color "white"
                set b .top260.fra73.fra74.but77
                $b configure -background $line_color -foreground $line_color
                set GnuOutputFormat "SCREEN"
                set GnuOutputFile ""; set HistoOutputFile ""
                set NTrainingArea(0) 0; set AreaPoint(0) 0; set AreaPointLig(0) 0; set AreaPointCol(0) 0
                for {set i 0} {$i <= 2} {incr i} {
                    set NTrainingArea($i) ""
                    for {set j 0} {$j <= 2} {incr j} {
                        set Argument [expr (100*$i + $j)]
                        set AreaPoint($Argument) ""
                        for {set k 0} {$k <= 17} {incr k} {
                            set Argument [expr (10000*$i + 100*$j + $k)]
                            set AreaPointLig($Argument) ""
                            set AreaPointCol($Argument) ""
                            }
                        }
                    }           
                set AreaClassN 1; set NTrainingAreaClass 1; set AreaN 1; set NTrainingArea(1) 1; set AreaPointN ""
                set TrainingAreaToolLine "false"; set rect_color "white"; set VarHistoSave "no"; set VarStatToolLine "stop"                    
                set MouseInitX ""; set MouseInitY ""; set MouseEndX ""; set MouseEndY ""; set MouseNlig ""; set MouseNcol ""
                $widget(Button260_2) configure -state disable
                $widget(Button260_3) configure -state disable
                $widget(Button260_4) configure -state disable
                $widget(Button260_5) configure -state disable
                $widget(Radiobutton260_1) configure -state disable
                $widget(Radiobutton260_2) configure -state disable
                DeleteFile $TMPStatisticsTxt
                DeleteFile $TMPStatisticsBin
                DeleteFile $TMPStatResultsTxt
                TextEditorRunTrace "Launch The Process Soft/data_process_sngl/statistics_histogram_extract.exe" "k"
                TextEditorRunTrace "Arguments: \x22$TMPStatisticsTxt\x22 \x22$TMPStatisticsBin\x22" "k"
                set HistoExecFid [ open "| Soft/data_process_sngl/statistics_histogram_extract.exe \x22$TMPStatisticsTxt\x22 \x22$TMPStatisticsBin\x22" r+]
                set GnuplotPipeStat "";  set HistoFileInput ""; set HistoFileOpen 0
                set GnuHistoTitle "HISTOGRAM"; set GnuHistoLabel "Label"; set GnuHistoStyle "lines"
                set HistoInputFormat "float"; set HistoOutputFormat "real"
                $widget(Radiobutton260_3) configure -state disable; $widget(Radiobutton260_4) configure -state disable
                set MinMaxAutoHisto 1; set MinHisto "Auto"; set MaxHisto "Auto"
                $widget(TitleFrame260_1) configure -state disable; $widget(Checkbutton260_1) configure -state disable
                $widget(Label260_1) configure -state disable; $widget(Entry260_1) configure -state disable
                $widget(Label260_2) configure -state disable; $widget(Entry260_2) configure -state disable
                $widget(Button260_1) configure -state disable
                WidgetShowFromWidget $widget(Toplevel342) $widget(Toplevel260); TextEditorRunTrace "Open Window Histograms" "b"
                }
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Hist 
    vTcl:DefineAlias "$site_3_0.but73" "Button342_0" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_3_0.but73 "$site_3_0.but73 Button $top all _vTclBalloon"
    bind $site_3_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Function Histogram}
    }
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir FileName PCTDirOutput
global TMPPCTAsc TMPPCTBin TMPPCTBmp
global BMPDirInput BMPViewFileInput
global LineXLensInit LineYLensInit line_color
global BMPPCTX BMPPCTY BMPPCTValue
global PCTSlice BMPPCTZ BMPPCTinc
global BMPPCTind BMPPCTval
global PCTRow PCTRowMin PCTRowMax
global PCTCol PCTColMin PCTColMax
global PCTZMin PCTZValue PCTZMax
global PCTBMPMouseX PCTBMPMouseY
global PCTTomoNrow PCTTomoNcol PCTTomoNz
global PCTPixZ PCTHmax 
global ConfigFile VarError ErrorMessage Fonction
global VarWarning WarningMesage WarningMessage2
global PCTExecFid PCTBMPImageOpen
global PCTRedPalette PCTGreenPalette PCTBluePalette PCTColorNumber
global HistoExecFid GnuplotPipeFid GnuplotPipeHisto
global Load_SaveHisto Load_Histograms CONFIGDir

#DATA PROCESS MULT
global Load_DisplayPCT
#BMP PROCESS
global Load_ViewBMPLens Load_ViewBMPPCT PSPTopLevel

if {$Load_Histograms == 1} {
    if {$Load_SaveHisto == 1} {Window hide $widget(Toplevel261); TextEditorRunTrace "Close Window Save Histograms" "b"}
    if {$HistoExecFid != ""} {
        puts $HistoExecFid "exit\n"
        flush $HistoExecFid
        fconfigure $HistoExecFid -buffering line
        while {$ProgressLine != "OKexit"} {
            gets $HistoExecFid ProgressLine
            update
            }
        catch "close $HistoExecFid"
        set HistoExecFid ""
        PlotHistoRAZ   
        PlotHistoClose 
        ClosePSPViewer
        Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
        Window hide $widget(Toplevel260); TextEditorRunTrace "Close Window Histograms" "b"
        }
    }

if {$PCTExecFid != ""} {
    set ErrorMessage "PCT DISPLAY IS ALREADY RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    if [file exists $TMPPCTAsc] {
        if [file exists $TMPPCTBin] {
            if [file exists "$PCTDirOutput/PauliRGB_PCT.bmp"] { 
                set BMPDirInput $PCTDirOutput
                ClosePSPViewer
                Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
                set BMPImageOpen "1"
                set BMPViewFileInput "$PCTDirOutput/PauliRGB_PCT.bmp"

                if {$Load_ViewBMPLens == 0} {
                    source "GUI/bmp_process/ViewBMPLens.tcl"
                    set Load_ViewBMPLens 1
                    WmTransient .top73 $PSPTopLevel
                    }
                if {$Load_ViewBMPPCT == 0} {
                    source "GUI/bmp_process/ViewBMPPCT.tcl"
                    set Load_ViewBMPPCT 1
                    $widget(CANVASBMPPCT) configure -cursor arrow
                    set PCTBMPImageOpen "0"
                    WmTransient .top344 $PSPTopLevel
                    }
                if {$Load_DisplayPCT == 0} {
                    source "GUI/data_process_dual/DisplayPolarizationCoherenceTomography.tcl"
                    set Load_DisplayPCT 1
                    WmTransient $widget(Toplevel343) $PSPTopLevel
                    } else {
                    $widget(CANVASLENSPCT) dtag $LineXLensInit
                    $widget(CANVASLENSPCT) dtag $LineYLensInit
                    }

                set line_color "white"
                set b .top343.fra71.fra72.fra79.but80
                $b configure -background $line_color -foreground $line_color
                set BMPPCTX ""; set BMPPCTY ""; set BMPPCTValue ""
                set PCTSlice ""; set BMPPCTZ ""; set BMPPCTinc ""
                set BMPPCTind ""; set BMPPCTval ""
                set PCTRow ""; set PCTRowMin ""; set PCTRowMax ""
                set PCTCol ""; set PCTColMin ""; set PCTColMax ""
                set PCTZMin ""; set PCTZValue ""; set PCTZMax ""
                set PCTBMPMouseX ""; set PCTBMPMouseY ""

                for {set i 0} {$i <= 256} {incr i} {
                    set PCTRedPalette($i) 1
                    set PCTGreenPalette($i) 1
                    set PCTBluePalette($i) 1
                    }
                WaitUntilCreated "$CONFIGDir/ColorMapJETPCT.pal"
                set f [open "$CONFIGDir/ColorMapJETPCT.pal" r]
                gets $f tmp
                gets $f tmp
                gets $f PCTColorNumber
                for {set i 1} {$i <= $PCTColorNumber} {incr i} {
                    gets $f couleur
                    set PCTRedPalette($i) [lindex $couleur 0]
                    set PCTGreenPalette($i) [lindex $couleur 1]
                    set PCTBluePalette($i) [lindex $couleur 2]
                    }
                close $f                                
                
                WaitUntilCreated $TMPPCTAsc
                set f [open $TMPPCTAsc r]
                gets $f tmp
                gets $f PCTTomoNrow
                gets $f tmp
                gets $f tmp
                gets $f PCTTomoNcol
                gets $f tmp
                gets $f tmp
                gets $f PCTTomoNz
                gets $f tmp
                gets $f tmp
                gets $f PCTPixZ
                gets $f tmp
                gets $f tmp
                gets $f PCTHmax
                gets $f tmp
                gets $f tmp
                gets $f PCTZminvalue
                set PCTZMin [format %5.2f $PCTZminvalue]
                gets $f tmp
                gets $f tmp
                gets $f PCTZmaxvalue
                set PCTZMax [format %5.2f $PCTZmaxvalue]
                close $f
                
                LoadPSPViewer
                load_bmp_caracteristics $BMPViewFileInput
                load_bmp_file $BMPViewFileInput    
                load_bmp_lens_line $widget(Toplevel343) $widget(CANVASLENSPCT)
                MouseActiveFunction "LensPCT"

                set ColMapPCT "$CONFIGDir/ColorMapJETPCT.pal"
                TextEditorRunTrace "Launch The Process Soft/data_process_dual/PCT_display.exe" "k"
                TextEditorRunTrace "Arguments: \x22$TMPPCTAsc\x22 \x22$TMPPCTBin\x22 \x22$TMPPCTBmp\x22 $ColMapPCT" "k"
                set PCTExecFid [ open "| Soft/data_process_dual/PCT_display.exe \x22$TMPPCTAsc\x22 \x22$TMPPCTBin\x22 \x22$TMPPCTBmp\x22 $ColMapPCT" r+]
                set ProgressLine ""
                puts $PCTExecFid "load\n"
                flush $PCTExecFid
                fconfigure $PCTExecFid -buffering line
                while {$ProgressLine != "OKload"} {
                    gets $PCTExecFid ProgressLine
                    update
                    }
                #WidgetShowFromWidget $widget(Toplevel342) $widget(Toplevel343); TextEditorRunTrace "Open Window Display PCT" "b"             
                Window show $widget(Toplevel343); TextEditorRunTrace "Open Window Display PCT" "b"             
                } else {
                set ErrorMessage "THE PauliRGB_PCT.bmp FILE DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } else {
            set ErrorMessage "RUN FIRST THE PCT ENGINE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        } else {
        set ErrorMessage "RUN FIRST THE PCT ENGINE" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
#ExecFid
set ProgressLine "0"; update
}} \
        -cursor {} -padx 4 -pady 2 -text {Display PCT} 
    vTcl:DefineAlias "$site_3_0.but93" "Button342_00" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Function Display PCT}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolarizationCoherenceTomography.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global HistoExecFid GnuplotPipeFid GnuplotPipeHisto
global Load_SaveHisto Load_Histograms
global Load_DisplayPCT

if {$OpenDirFile == 0} {

if {$Load_Histograms == 1} {
    if {$Load_SaveHisto == 1} {Window hide $widget(Toplevel261); TextEditorRunTrace "Close Window Save Histograms" "b"}
    if {$HistoExecFid != ""} {
        puts $HistoExecFid "exit\n"
        flush $HistoExecFid
        fconfigure $HistoExecFid -buffering line
        while {$ProgressLine != "OKexit"} {
            gets $HistoExecFid ProgressLine
            update
            }
        catch "close $HistoExecFid"
        set HistoExecFid ""

        PlotHistoRAZ   
        PlotHistoClose 
        ClosePSPViewer
        Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
        Window hide $widget(Toplevel260); TextEditorRunTrace "Close Window Histograms" "b"
        }
    }
if {$Load_DisplayPCT == 1} {
    if {$PCTExecFid != ""} {
        puts $PCTExecFid "exit\n"
        flush $PCTExecFid
        fconfigure $PCTExecFid -buffering line
        while {$ProgressLine != "OKexit"} {
            gets $PCTExecFid ProgressLine
            update
            }
        catch "close $PCTExecFid"
        set PCTExecFid ""

        ClosePSPViewer
        PCTcloseBMP
        Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
        Window hide $widget(Toplevel343); TextEditorRunTrace "Close Window Display PCT" "b"
        }
    }
    
Window hide $widget(Toplevel342); TextEditorRunTrace "Close Window PCT" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel342" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
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
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd83 \
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
Window show .top342

main $argc $argv
