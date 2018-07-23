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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
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
    set base .top390
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
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
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
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra67
    namespace eval ::widgets::$site_6_0.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra69
    namespace eval ::widgets::$site_7_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd73
    namespace eval ::widgets::$site_7_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd71
    namespace eval ::widgets::$site_7_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra69
    namespace eval ::widgets::$site_7_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd71
    namespace eval ::widgets::$site_7_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.lab71 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra72
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra74
    namespace eval ::widgets::$site_7_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd75
    namespace eval ::widgets::$site_4_0.lab27 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent29 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd74
    namespace eval ::widgets::$site_4_0.lab27 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent29 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd83
    namespace eval ::widgets::$site_4_0.lab71 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra72
    namespace eval ::widgets::$site_5_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.fra74
    namespace eval ::widgets::$site_6_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.che76 {
        array set save {-text 1 -variable 1}
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
            vTclWindow.top390
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

proc vTclWindow.top390 {base} {
    if {$base == ""} {
        set base .top390
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
    wm geometry $top 500x440+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Texture Analysis"
    vTcl:DefineAlias "$top" "Toplevel390" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel390" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel390" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TextStatFileInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel390" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel390" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName TextStatDirInput TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFileOutputTmp TextStatOutputFormat TextStatFonc
global ConfigFile VarError ErrorMessage
global OpenDirFile

if {$OpenDirFile == 0} {
set TextStatFileInput ""
set TextStatFileOutput ""
set TextStatFileOutputTmp ""
set InputFormat ""
set OutputFormat ""
set TextStatFonc ""
$widget(Radiobutton390_1) configure -state disable
$widget(Radiobutton390_2) configure -state disable
$widget(Radiobutton390_3) configure -state disable
$widget(Radiobutton390_4) configure -state disable
$widget(Radiobutton390_5) configure -state disable
$widget(Radiobutton390_6) configure -state disable

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $TextStatDirInput $types "INPUT FILE"
if {$FileName != ""} {
    set TextStatFileInput $FileName
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
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame9" vTcl:WidgetProc "Toplevel390" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable TextStatDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel390" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel390" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global DirName DataDir TextStatDirOutput TextStatFileOutput

set TextStatDirOutputTmp $TextStatDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set TextStatDirOutput $DirName
    } else {
    set TextStatDirOutput $TextStatDirOutputTmp
    }
set FileTmp "$TextStatDirOutput/"
append FileTmp [file tail $TextStatFileOutput]
set TextStatFileOutput $FileTmp} \
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
    vTcl:DefineAlias "$top.fra51" "Frame9" vTcl:WidgetProc "Toplevel390" 1
    set site_3_0 $top.fra51
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel390" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel390" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel390" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel390" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel390" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel390" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel390" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel390" 1
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
        -ipad 0 -text {Input Data Format} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame1" vTcl:WidgetProc "Toplevel390" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    radiobutton $site_4_0.cpd82 \
        \
        -command {global OutputFormat
set OutputFormat ""
$widget(Radiobutton390_1) configure -state normal
$widget(Radiobutton390_2) configure -state normal
$widget(Radiobutton390_3) configure -state normal
$widget(Radiobutton390_4) configure -state normal
$widget(Radiobutton390_5) configure -state normal
$widget(Radiobutton390_6) configure -state normal
} \
        -padx 1 -text Complex -value cmplx -variable InputFormat 
    radiobutton $site_4_0.cpd83 \
        \
        -command {global OutputFormat
set OutputFormat ""
$widget(Radiobutton390_1) configure -state normal
$widget(Radiobutton390_2) configure -state normal
$widget(Radiobutton390_3) configure -state disable
$widget(Radiobutton390_4) configure -state normal
$widget(Radiobutton390_5) configure -state disable
$widget(Radiobutton390_6) configure -state normal
} \
        -padx 1 -text Float -value float -variable InputFormat 
    radiobutton $site_4_0.cpd84 \
        \
        -command {global OutputFormat
set OutputFormat ""
$widget(Radiobutton390_1) configure -state normal
$widget(Radiobutton390_2) configure -state normal
$widget(Radiobutton390_3) configure -state disable
$widget(Radiobutton390_4) configure -state normal
$widget(Radiobutton390_5) configure -state disable
$widget(Radiobutton390_6) configure -state normal
} \
        -padx 1 -text Integer -value int -variable InputFormat 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit85 \
        -ipad 0 -text {Processing Format} 
    vTcl:DefineAlias "$top.tit85" "TitleFrame2" vTcl:WidgetProc "Toplevel390" 1
    bind $top.tit85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit85 getframe]
    radiobutton $site_4_0.cpd86 \
        -padx 1 -text Amplitude -value mod -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd86" "Radiobutton390_1" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_4_0.cpd71 \
        -padx 1 -text Intensity -value mod2 -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd71" "Radiobutton390_2" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_4_0.cpd66 \
        -padx 1 -text dB -value db -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd66" "Radiobutton390_6" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_4_0.cpd89 \
        -padx 1 -text Phase -value pha -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd89" "Radiobutton390_3" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_4_0.cpd90 \
        -padx 1 -text Real -value real -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd90" "Radiobutton390_4" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_4_0.cpd92 \
        -padx 1 -text Imag -value imag -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd92" "Radiobutton390_5" vTcl:WidgetProc "Toplevel390" 1
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit66 \
        -ipad 0 -text {Texture statistics based on GLCM} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame3" vTcl:WidgetProc "Toplevel390" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    frame $site_4_0.cpd67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame18" vTcl:WidgetProc "Toplevel390" 1
    set site_5_0 $site_4_0.cpd67
    frame $site_5_0.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra67" "Frame21" vTcl:WidgetProc "Toplevel390" 1
    set site_6_0 $site_5_0.fra67
    frame $site_6_0.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra69" "Frame23" vTcl:WidgetProc "Toplevel390" 1
    set site_7_0 $site_6_0.fra69
    radiobutton $site_7_0.rad70 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

$widget(Entry390_1) configure -disabledbackground #FFFFFF
$widget(Entry390_2) configure -disabledbackground #FFFFFF
$widget(Label390_1) configure -state normal
$widget(Label390_2) configure -state normal
$widget(Button390_1) configure -state normal
$widget(Button390_2) configure -state normal
$widget(Button390_3) configure -state normal
$widget(Button390_4) configure -state normal
set TextOrient "0"
set TextNcolor "32"

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -text mean -value mean -variable TextStatFonc 
    vTcl:DefineAlias "$site_7_0.rad70" "Radiobutton11" vTcl:WidgetProc "Toplevel390" 1
    pack $site_7_0.rad70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd73" "Frame24" vTcl:WidgetProc "Toplevel390" 1
    set site_7_0 $site_6_0.cpd73
    radiobutton $site_7_0.rad70 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

$widget(Entry390_1) configure -disabledbackground #FFFFFF
$widget(Entry390_2) configure -disabledbackground #FFFFFF
$widget(Label390_1) configure -state normal
$widget(Label390_2) configure -state normal
$widget(Button390_1) configure -state normal
$widget(Button390_2) configure -state normal
$widget(Button390_3) configure -state normal
$widget(Button390_4) configure -state normal
set TextOrient "0"
set TextNcolor "32"

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -text homogeneity -value homogeneity -variable TextStatFonc 
    vTcl:DefineAlias "$site_7_0.rad70" "Radiobutton12" vTcl:WidgetProc "Toplevel390" 1
    pack $site_7_0.rad70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd71" "Frame25" vTcl:WidgetProc "Toplevel390" 1
    set site_7_0 $site_6_0.cpd71
    radiobutton $site_7_0.rad70 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

$widget(Entry390_1) configure -disabledbackground #FFFFFF
$widget(Entry390_2) configure -disabledbackground #FFFFFF
$widget(Label390_1) configure -state normal
$widget(Label390_2) configure -state normal
$widget(Button390_1) configure -state normal
$widget(Button390_2) configure -state normal
$widget(Button390_3) configure -state normal
$widget(Button390_4) configure -state normal
set TextOrient "0"
set TextNcolor "32"

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -text contrast -value contrast -variable TextStatFonc 
    vTcl:DefineAlias "$site_7_0.rad70" "Radiobutton13" vTcl:WidgetProc "Toplevel390" 1
    pack $site_7_0.rad70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra69 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame28" vTcl:WidgetProc "Toplevel390" 1
    set site_6_0 $site_5_0.cpd75
    frame $site_6_0.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra69" "Frame29" vTcl:WidgetProc "Toplevel390" 1
    set site_7_0 $site_6_0.fra69
    radiobutton $site_7_0.rad70 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

$widget(Entry390_1) configure -disabledbackground #FFFFFF
$widget(Entry390_2) configure -disabledbackground #FFFFFF
$widget(Label390_1) configure -state normal
$widget(Label390_2) configure -state normal
$widget(Button390_1) configure -state normal
$widget(Button390_2) configure -state normal
$widget(Button390_3) configure -state normal
$widget(Button390_4) configure -state normal
set TextOrient "0"
set TextNcolor "32"

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -text dissimilarity -value dissimilarity -variable TextStatFonc 
    vTcl:DefineAlias "$site_7_0.rad70" "Radiobutton16" vTcl:WidgetProc "Toplevel390" 1
    pack $site_7_0.rad70 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side left 
    frame $site_6_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd71" "Frame30" vTcl:WidgetProc "Toplevel390" 1
    set site_7_0 $site_6_0.cpd71
    radiobutton $site_7_0.rad70 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

$widget(Entry390_1) configure -disabledbackground #FFFFFF
$widget(Entry390_2) configure -disabledbackground #FFFFFF
$widget(Label390_1) configure -state normal
$widget(Label390_2) configure -state normal
$widget(Button390_1) configure -state normal
$widget(Button390_2) configure -state normal
$widget(Button390_3) configure -state normal
$widget(Button390_4) configure -state normal
set TextOrient "0"
set TextNcolor "32"

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -text entropy -value entropy -variable TextStatFonc 
    vTcl:DefineAlias "$site_7_0.rad70" "Radiobutton17" vTcl:WidgetProc "Toplevel390" 1
    pack $site_7_0.rad70 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side left 
    frame $site_6_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame31" vTcl:WidgetProc "Toplevel390" 1
    set site_7_0 $site_6_0.cpd72
    radiobutton $site_7_0.rad70 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

$widget(Entry390_1) configure -disabledbackground #FFFFFF
$widget(Entry390_2) configure -disabledbackground #FFFFFF
$widget(Label390_1) configure -state normal
$widget(Label390_2) configure -state normal
$widget(Button390_1) configure -state normal
$widget(Button390_2) configure -state normal
$widget(Button390_3) configure -state normal
$widget(Button390_4) configure -state normal
set TextOrient "0"
set TextNcolor "32"

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -text uniformity -value uniformity -variable TextStatFonc 
    vTcl:DefineAlias "$site_7_0.rad70" "Radiobutton18" vTcl:WidgetProc "Toplevel390" 1
    pack $site_7_0.rad70 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side left 
    pack $site_6_0.fra69 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.fra67 \
        -in $site_5_0 -anchor center -expand 1 -fill x -padx 10 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -padx 10 -side left 
    frame $site_4_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame3" vTcl:WidgetProc "Toplevel390" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.lab71 \
        -text {Direction orientation} 
    vTcl:DefineAlias "$site_5_0.lab71" "Label390_1" vTcl:WidgetProc "Toplevel390" 1
    frame $site_5_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel390" 1
    set site_6_0 $site_5_0.fra72
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable TextOrient -width 5 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry390_1" vTcl:WidgetProc "Toplevel390" 1
    frame $site_6_0.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra74" "Frame6" vTcl:WidgetProc "Toplevel390" 1
    set site_7_0 $site_6_0.fra74
    button $site_7_0.but76 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

set TextOrient [expr $TextOrient + 45]
if {$TextOrient == 180} { set TextOrient 0}

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.but76" "Button390_1" vTcl:WidgetProc "Toplevel390" 1
    button $site_7_0.but75 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

set TextOrient [expr $TextOrient - 45]
if {$TextOrient == -45} { set TextOrient 135}

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput "_$TextOrient"
append TextStatFileOutput ".bin"} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but75" "Button390_2" vTcl:WidgetProc "Toplevel390" 1
    pack $site_7_0.but76 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.but75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.fra74 \
        -in $site_6_0 -anchor center -expand 0 -fill both -side left 
    pack $site_5_0.lab71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.fra72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd77 \
        -ipad 0 -text {Texture measures} 
    vTcl:DefineAlias "$top.cpd77" "TitleFrame4" vTcl:WidgetProc "Toplevel390" 1
    bind $top.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd77 getframe]
    frame $site_4_0.cpd67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame26" vTcl:WidgetProc "Toplevel390" 1
    set site_5_0 $site_4_0.cpd67
    radiobutton $site_5_0.cpd79 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput ".bin"

$widget(Entry390_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry390_2) configure -disabledbackground $PSPBackgroundColor
$widget(Label390_1) configure -state disable
$widget(Label390_2) configure -state disable
$widget(Button390_1) configure -state disable
$widget(Button390_2) configure -state disable
$widget(Button390_3) configure -state disable
$widget(Button390_4) configure -state disable
set TextOrient ""
set TextNcolor ""} \
        -text VI -value VI -variable TextStatFonc 
    vTcl:DefineAlias "$site_5_0.cpd79" "Radiobutton20" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_5_0.cpd80 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput ".bin"

$widget(Entry390_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry390_2) configure -disabledbackground $PSPBackgroundColor
$widget(Label390_1) configure -state disable
$widget(Label390_2) configure -state disable
$widget(Button390_1) configure -state disable
$widget(Button390_2) configure -state disable
$widget(Button390_3) configure -state disable
$widget(Button390_4) configure -state disable
set TextOrient ""
set TextNcolor ""} \
        -text VA -value VA -variable TextStatFonc 
    vTcl:DefineAlias "$site_5_0.cpd80" "Radiobutton21" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_5_0.cpd81 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput ".bin"

$widget(Entry390_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry390_2) configure -disabledbackground $PSPBackgroundColor
$widget(Label390_1) configure -state disable
$widget(Label390_2) configure -state disable
$widget(Button390_1) configure -state disable
$widget(Button390_2) configure -state disable
$widget(Button390_3) configure -state disable
$widget(Button390_4) configure -state disable
set TextOrient ""
set TextNcolor ""} \
        -text VL -value VL -variable TextStatFonc 
    vTcl:DefineAlias "$site_5_0.cpd81" "Radiobutton22" vTcl:WidgetProc "Toplevel390" 1
    radiobutton $site_5_0.cpd82 \
        \
        -command {global FileName TextStatDirOutput TextStatFileInput TextStatFileOutput TextStatFonc TextNcolor TextOrient
global PSPBackgroundColor

set TextStatFileOutput "$TextStatDirOutput/"
set FileName1 [file tail $TextStatFileInput]
set FileName2 [file rootname $FileName1]
append TextStatFileOutput $FileName2
append TextStatFileOutput "_texture"
append TextStatFileOutput "_$TextStatFonc"
append TextStatFileOutput ".bin"

$widget(Entry390_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry390_2) configure -disabledbackground $PSPBackgroundColor
$widget(Label390_1) configure -state disable
$widget(Label390_2) configure -state disable
$widget(Button390_1) configure -state disable
$widget(Button390_2) configure -state disable
$widget(Button390_3) configure -state disable
$widget(Button390_4) configure -state disable
set TextOrient ""
set TextNcolor ""} \
        -text U -value U -variable TextStatFonc 
    vTcl:DefineAlias "$site_5_0.cpd82" "Radiobutton23" vTcl:WidgetProc "Toplevel390" 1
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame1" vTcl:WidgetProc "Toplevel390" 1
    set site_3_0 $top.fra73
    frame $site_3_0.cpd75 \
        -borderwidth 2 -height 80 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd75" "Frame67" vTcl:WidgetProc "Toplevel390" 1
    set site_4_0 $site_3_0.cpd75
    label $site_4_0.lab27 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_4_0.lab27" "Label51" vTcl:WidgetProc "Toplevel390" 1
    entry $site_4_0.ent29 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NwinTextStatL -width 5 
    vTcl:DefineAlias "$site_4_0.ent29" "Entry35" vTcl:WidgetProc "Toplevel390" 1
    pack $site_4_0.lab27 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent29 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_3_0.cpd74 \
        -borderwidth 2 -height 80 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd74" "Frame68" vTcl:WidgetProc "Toplevel390" 1
    set site_4_0 $site_3_0.cpd74
    label $site_4_0.lab27 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_4_0.lab27" "Label52" vTcl:WidgetProc "Toplevel390" 1
    entry $site_4_0.ent29 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NwinTextStatC -width 5 
    vTcl:DefineAlias "$site_4_0.ent29" "Entry36" vTcl:WidgetProc "Toplevel390" 1
    pack $site_4_0.lab27 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent29 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_3_0.cpd83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd83" "Frame7" vTcl:WidgetProc "Toplevel390" 1
    set site_4_0 $site_3_0.cpd83
    label $site_4_0.lab71 \
        -text {Gray levels} 
    vTcl:DefineAlias "$site_4_0.lab71" "Label390_2" vTcl:WidgetProc "Toplevel390" 1
    frame $site_4_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra72" "Frame8" vTcl:WidgetProc "Toplevel390" 1
    set site_5_0 $site_4_0.fra72
    entry $site_5_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable TextNcolor -width 5 
    vTcl:DefineAlias "$site_5_0.ent73" "Entry390_2" vTcl:WidgetProc "Toplevel390" 1
    frame $site_5_0.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra74" "Frame10" vTcl:WidgetProc "Toplevel390" 1
    set site_6_0 $site_5_0.fra74
    button $site_6_0.but76 \
        \
        -command {global TextNcolor

set TextNcolor [expr $TextNcolor * 2]
if {$TextNcolor == 512} { set TextNcolor 32}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_6_0.but76" "Button390_3" vTcl:WidgetProc "Toplevel390" 1
    button $site_6_0.but75 \
        \
        -command {global TextNcolor

set TextNcolor [expr $TextNcolor / 2]
if {$TextNcolor == 16} { set TextNcolor 256}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but75" "Button390_4" vTcl:WidgetProc "Toplevel390" 1
    pack $site_6_0.but76 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.but75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.fra74 \
        -in $site_5_0 -anchor center -expand 0 -fill both -side left 
    pack $site_4_0.lab71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_4_0.fra72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    checkbutton $site_3_0.che76 \
        -text BMP -variable BMPTextStat 
    vTcl:DefineAlias "$site_3_0.che76" "Checkbutton1" vTcl:WidgetProc "Toplevel390" 1
    pack $site_3_0.cpd75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame5" vTcl:WidgetProc "Toplevel390" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd99 \
        -ipad 0 -text {Output Data File} 
    vTcl:DefineAlias "$site_3_0.cpd99" "TitleFrame12" vTcl:WidgetProc "Toplevel390" 1
    bind $site_3_0.cpd99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable TextStatFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh12" vTcl:WidgetProc "Toplevel390" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd99 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel390" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TextStatDirOutput TextStatFileInput TextStatFileOutput InputFormat OutputFormat TextStatOutputFormat
global VarError ErrorMessage Fonction Fonction2 ProgressLine TextStatFonc TextOrient TextNcolor
global OpenDirFile NwinTextStatL NwinTextStatC BMPTextStat BMPFileInput BMPFileOutput BMPDirInput
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax PSPMemory TMPMemoryAllocError

if {$OpenDirFile == 0} {

if {"$NligInit"!="0"} {
    set config "true"; set configfile "true"; set configfonc "true"
    set configinput "true"; set configoutput "true"
    
    if {$TextStatFileInput ==""} {set configfile "false"}
    if {$InputFormat ==""} {set configinput "false"}
    if {$OutputFormat ==""} {set configoutput "false"}
    if {$TextStatFonc ==""} {set configfonc "false"}
    
    if {$configfile =="false"} {
        set config "false"
        set VarError ""
        set ErrorMessage "INVALID INPUT FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {$configinput =="false"} {
        set config "false"
        set VarError ""
        set ErrorMessage "INVALID INPUT FORMAT"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {$configoutput =="false"} {
        set config "false"
        set VarError ""
        set ErrorMessage "INVALID OUTPUT FORMAT"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if {$configfonc =="false"} {
        set config "false"
        set VarError ""
        set ErrorMessage "INVALID FUNCTION"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {"$config"=="true"} {

    set TextStatDirOutput [file dirname $TextStatFileOutput]
    
    #####################################################################
    #Create Directory
    set TextStatDirOutput [PSPCreateDirectoryMask $TextStatDirOutput $TextStatDirOutput $TextStatDirInput]
    #####################################################################       

        if {"$VarWarning"=="ok"} {

            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            set TestVarName(4) "Initial Number of Col"; set TestVarType(4) "int"; set TestVarValue(4) $NcolFullSize; set TestVarMin(4) "0"; set TestVarMax(4) "100000"
            set TestVarName(5) "Window Size Row"; set TestVarType(5) "int"; set TestVarValue(5) $NwinTextStatL; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            set TestVarName(6) "Window Size Col"; set TestVarType(6) "int"; set TestVarValue(6) $NwinTextStatC; set TestVarMin(6) "1"; set TestVarMax(6) "100"
            TestVar 7
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]

                if {$TextStatFonc == "mean"} { set config 1 }
                if {$TextStatFonc == "homogeneity"} { set config 1 }
                if {$TextStatFonc == "contrast"} { set config 1 }
                if {$TextStatFonc == "dissimilarity"} { set config 1 }
                if {$TextStatFonc == "entropy"} { set config 1 }
                if {$TextStatFonc == "uniformity"} { set config 1 }

                if {$TextStatFonc == "VI"} { set config 2 }
                if {$TextStatFonc == "VA"} { set config 2 }
                if {$TextStatFonc == "VL"} { set config 2 }
                if {$TextStatFonc == "U"} { set config 2 }

                set Fonction "Creation of the Texture Parameter :"
                set Fonction2 "$TextStatFileOutput"    
                set MaskCmd ""
                set MaskDir [file dirname $TextStatFileInput]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                if {$config == 1 }  {
                    TextEditorRunTrace "Process The Function Soft/data_process_sngl/texture_statistics.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$TextStatFileInput\x22 -of \x22$TextStatFileOutput\x22 -ta $TextStatFonc -idf $InputFormat -odf $OutputFormat -nwr $NwinTextStatL -nwc $NwinTextStatC -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -dir $TextOrient -col $TextNcolor -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/data_process_sngl/texture_statistics.exe -if \x22$TextStatFileInput\x22 -of \x22$TextStatFileOutput\x22 -ta $TextStatFonc -idf $InputFormat -odf $OutputFormat -nwr $NwinTextStatL -nwc $NwinTextStatC  -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -dir $TextOrient -col $TextNcolor -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    }
                if {$config == 2 }  {
                    TextEditorRunTrace "Process The Function Soft/data_process_sngl/texture_analysis.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$TextStatFileInput\x22 -of \x22$TextStatFileOutput\x22 -ta $TextStatFonc -idf $InputFormat -odf $OutputFormat -nwr $NwinTextStatL -nwc $NwinTextStatC -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/data_process_sngl/texture_analysis.exe -if \x22$TextStatFileInput\x22 -of \x22$TextStatFileOutput\x22 -ta $TextStatFonc -idf $InputFormat -odf $OutputFormat -nwr $NwinTextStatL -nwc $NwinTextStatC -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    }
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                if [file exists $TextStatFileOutput] {EnviWriteConfig $TextStatFileOutput $FinalNlig $FinalNcol 4}

                if {$BMPTextStat == 1} {
                    set BMPFileInput $TextStatFileOutput
                    set BMPFileOutput [file rootname $TextStatFileOutput]
                    append BMPFileOutput ".bmp"
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                    set BMPDirInput $TextStatDirOutput
                    }
                }
            } else {
            if {"$VarWarning"=="no"} {Window hide $widget(Toplevel390); TextEditorRunTrace "Close Window Coefficient of Variation" "b"}
            }
        }
    } else {
        set VarError ""
        set ErrorMessage "ENTER A VALID INPUT DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel390" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/TextureAnalysis.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel390" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel390); TextEditorRunTrace "Close Window Texture Analysis" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel390" 1
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
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit85 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -side top 
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
Window show .top390

main $argc $argv
