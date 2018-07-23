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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top307
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd86 {
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
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent94 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra29 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra29
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit73 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra83 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra83
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd86
    namespace eval ::widgets::$site_6_0.lab88 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd90
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.che74 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd92 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd92
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd93 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd93
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.che74 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd92 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd92
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd94
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.che74 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd92 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd92
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd95
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd86
    namespace eval ::widgets::$site_6_0.lab88 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.cpd92 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd92
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra30 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra30
    namespace eval ::widgets::$site_3_0.fra22 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra22
    namespace eval ::widgets::$site_4_0.fra25 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra25
    namespace eval ::widgets::$site_5_0.tit71 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit71 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd73
    namespace eval ::widgets::$site_8_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd74
    namespace eval ::widgets::$site_8_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.fra72
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd76
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd73
    namespace eval ::widgets::$site_8_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd74
    namespace eval ::widgets::$site_8_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top307
            BMPCmplxCoh
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
## Procedure:  BMPCmplxCoh

proc ::BMPCmplxCoh {FNlig FNcol File1} {
global CmplxCohDirOutput BMPDirInput BMPFileInput BMPFileOutput 
global BMPCmplxCohConfig
global Fonction Fonction2 VarError ErrorMessage

set BMPCmplxCohConfig "true"

if [file exists "$File1.bin"] {
    set BMPDirInput $CmplxCohDirOutput
    set BMPFileInput "$File1.bin"
    set BMPFileOutput $File1
    append BMPFileOutput "_mod.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod gray  $FNcol  0  0  $FNlig  $FNcol 0 0 1
    set BMPFileOutput $File1
    append BMPFileOutput "_pha.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha jet  $FNcol  0  0  $FNlig  $FNcol 0 -180 180
    } else {
    set BMPCmplxCohConfig "false"
    set VarError ""
    set ErrorMessage "THE FILE $File1.bin DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
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
    wm geometry $top 200x200+150+150; update
    wm maxsize $top 1924 1062
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

proc vTclWindow.top307 {base} {
    if {$base == ""} {
        set base .top307
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
    wm geometry $top 500x410+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Complex Coherence Estimation"
    vTcl:DefineAlias "$top" "Toplevel307" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame2" vTcl:WidgetProc "Toplevel307" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame307_1" vTcl:WidgetProc "Toplevel307" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CmplxCohMasterDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry307_01" vTcl:WidgetProc "Toplevel307" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd81 \
        -ipad 0 -text {Input Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame307_2" vTcl:WidgetProc "Toplevel307" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CmplxCohSlaveDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry307_02" vTcl:WidgetProc "Toplevel307" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button35" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Master-Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame307_3" vTcl:WidgetProc "Toplevel307" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CmplxCohOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry307_03" vTcl:WidgetProc "Toplevel307" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame1" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd95
    label $site_6_0.cpd97 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd97" "Label307_01" vTcl:WidgetProc "Toplevel307" 1
    entry $site_6_0.ent94 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CmplxCohOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.ent94" "Entry307_04" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.ent94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DirName DataDirChannel1 CmplxCohOutputDir

set CmplxCohDirOutputTmp $CmplxCohOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set CmplxCohOutputDir $DirName
    } else {
    set CmplxCohOutputDir $CmplxCohDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button307_01" vTcl:WidgetProc "Toplevel307" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra29 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra29" "Frame9" vTcl:WidgetProc "Toplevel307" 1
    set site_3_0 $top.fra29
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel307" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel307" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel307" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel307" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel307" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel307" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel307" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel307" 1
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
        -text {Complex Coherences} 
    vTcl:DefineAlias "$top.tit73" "TitleFrame3" vTcl:WidgetProc "Toplevel307" 1
    bind $top.tit73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit73 getframe]
    frame $site_4_0.fra83 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra83" "Frame3" vTcl:WidgetProc "Toplevel307" 1
    set site_5_0 $site_4_0.fra83
    frame $site_5_0.cpd86
    set site_6_0 $site_5_0.cpd86
    label $site_6_0.lab88 \
        -text Linear 
    vTcl:DefineAlias "$site_6_0.lab88" "Label1" vTcl:WidgetProc "Toplevel307" 1
    label $site_6_0.cpd89 \
        -text Circular 
    vTcl:DefineAlias "$site_6_0.cpd89" "Label2" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.lab88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd90
    set site_6_0 $site_5_0.cpd90
    frame $site_6_0.cpd91
    set site_7_0 $site_6_0.cpd91
    checkbutton $site_7_0.che74 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohLinHH == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text HH -variable CohLinHH 
    vTcl:DefineAlias "$site_7_0.che74" "Checkbutton23" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.che74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd92
    set site_7_0 $site_6_0.cpd92
    checkbutton $site_7_0.cpd75 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohCirLL == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text LL -variable CohCirLL 
    vTcl:DefineAlias "$site_7_0.cpd75" "Checkbutton27" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd92 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd93
    set site_6_0 $site_5_0.cpd93
    frame $site_6_0.cpd91
    set site_7_0 $site_6_0.cpd91
    checkbutton $site_7_0.che74 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohLinHV == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text HV -variable CohLinHV 
    vTcl:DefineAlias "$site_7_0.che74" "Checkbutton24" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.che74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd92
    set site_7_0 $site_6_0.cpd92
    checkbutton $site_7_0.cpd75 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohCirLR == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text LR -variable CohCirLR 
    vTcl:DefineAlias "$site_7_0.cpd75" "Checkbutton28" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd92 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd94
    set site_6_0 $site_5_0.cpd94
    frame $site_6_0.cpd91
    set site_7_0 $site_6_0.cpd91
    checkbutton $site_7_0.che74 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohLinVV == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text VV -variable CohLinVV 
    vTcl:DefineAlias "$site_7_0.che74" "Checkbutton25" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.che74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd92
    set site_7_0 $site_6_0.cpd92
    checkbutton $site_7_0.cpd75 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohCirRR == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text RR -variable CohCirRR 
    vTcl:DefineAlias "$site_7_0.cpd75" "Checkbutton29" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd92 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd93 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd95" "Frame4" vTcl:WidgetProc "Toplevel307" 1
    set site_5_0 $site_4_0.cpd95
    frame $site_5_0.cpd86
    set site_6_0 $site_5_0.cpd86
    label $site_6_0.lab88 \
        -text Pauli 
    vTcl:DefineAlias "$site_6_0.lab88" "Label3" vTcl:WidgetProc "Toplevel307" 1
    label $site_6_0.cpd89 \
        -text Optimal 
    vTcl:DefineAlias "$site_6_0.cpd89" "Label4" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.lab88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd77
    set site_6_0 $site_5_0.cpd77
    frame $site_6_0.cpd92
    set site_7_0 $site_6_0.cpd92
    checkbutton $site_7_0.cpd73 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohPauliHHpVV == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text {HH + VV} -variable CohPauliHHpVV 
    vTcl:DefineAlias "$site_7_0.cpd73" "Checkbutton26" vTcl:WidgetProc "Toplevel307" 1
    checkbutton $site_7_0.cpd74 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohPauliHHmVV == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text {HH - VV} -variable CohPauliHHmVV 
    vTcl:DefineAlias "$site_7_0.cpd74" "Checkbutton34" vTcl:WidgetProc "Toplevel307" 1
    checkbutton $site_7_0.cpd75 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohOpt CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohPauliHVpVH == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text {HV + VH} -variable CohPauliHVpVH 
    vTcl:DefineAlias "$site_7_0.cpd75" "Checkbutton36" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd91
    set site_7_0 $site_6_0.cpd91
    checkbutton $site_7_0.cpd76 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohOptSVD == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text SVD -variable CohOptSVD 
    vTcl:DefineAlias "$site_7_0.cpd76" "Checkbutton31" vTcl:WidgetProc "Toplevel307" 1
    checkbutton $site_7_0.cpd77 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF

if {$CohOptPD == 1} {
    $widget(Checkbutton307_1) configure -state normal
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    }} \
        -text PD -variable CohOptPD 
    vTcl:DefineAlias "$site_7_0.cpd77" "Checkbutton32" vTcl:WidgetProc "Toplevel307" 1
    checkbutton $site_7_0.cpd78 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF
global NRTheta1 NRTheta3

if {$CohOptNR == 1} {
    $widget(Checkbutton307_1) configure -state normal
    set NRTheta1 "?"; set NRTheta3 "?"
    $widget(TitleFrame307_NR) configure -state normal 
    $widget(Entry307_NR1) configure -state normal; $widget(Entry307_NR1) configure -disabledbackground #FFFFFF; $widget(Label307_NR1) configure -state normal 
    $widget(Entry307_NR2) configure -state normal; $widget(Entry307_NR2) configure -disabledbackground #FFFFFF; $widget(Label307_NR2) configure -state normal 
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    set NRTheta1 ""; set NRTheta3 ""
    $widget(TitleFrame307_NR) configure -state disable
    $widget(Entry307_NR1) configure -state disable; $widget(Entry307_NR1) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_NR1) configure -state disable 
    $widget(Entry307_NR2) configure -state disable; $widget(Entry307_NR2) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_NR2) configure -state disable 
    }} \
        -text NR -variable CohOptNR 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton33" vTcl:WidgetProc "Toplevel307" 1
    checkbutton $site_7_0.cpd79 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF
global NptsMM

if {$CohOptMM == 1} {
    $widget(Checkbutton307_1) configure -state normal
    set NptsMM "?"
    $widget(TitleFrame307_MM) configure -state normal 
    $widget(Entry307_MM) configure -state normal; $widget(Entry307_MM) configure -disabledbackground #FFFFFF; $widget(Label307_MM) configure -state normal 
    $widget(Entry307_MM) configure -state normal; $widget(Entry307_MM) configure -disabledbackground #FFFFFF; $widget(Label307_MM) configure -state normal 
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    set NptsMM ""
    $widget(TitleFrame307_MM) configure -state disable
    $widget(Entry307_MM) configure -state disable; $widget(Entry307_MM) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_MM) configure -state disable 
    $widget(Entry307_MM) configure -state disable; $widget(Entry307_MM) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_MM) configure -state disable 
    }} \
        -text {L. MinMax} -variable CohOptMM 
    vTcl:DefineAlias "$site_7_0.cpd79" "Checkbutton35" vTcl:WidgetProc "Toplevel307" 1
    checkbutton $site_7_0.cpd80 \
        \
        -command {global CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH CohBMP
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF
global NptsDF

if {$CohOptDF == 1} {
    $widget(Checkbutton307_1) configure -state normal
    set NptsDF "?"
    $widget(TitleFrame307_DF) configure -state normal 
    $widget(Entry307_DF) configure -state normal; $widget(Entry307_DF) configure -disabledbackground #FFFFFF; $widget(Label307_DF) configure -state normal 
    $widget(Entry307_DF) configure -state normal; $widget(Entry307_DF) configure -disabledbackground #FFFFFF; $widget(Label307_DF) configure -state normal 
    } else {
    set config "false"
    if {$CohLinHH == 1} {set config "true"}
    if {$CohLinHV == 1} {set config "true"}
    if {$CohLinVV == 1} {set config "true"}
    if {$CohCirLL == 1} {set config "true"}
    if {$CohCirLR == 1} {set config "true"}
    if {$CohCirRR == 1} {set config "true"}
    if {$CohPauliHHpVV == 1} {set config "true"}
    if {$CohPauliHHmVV == 1} {set config "true"}
    if {$CohPauliHVpVH == 1} {set config "true"}
    if {$CohOptSVD == 1} {set config "true"}
    if {$CohOptPD == 1} {set config "true"}
    if {$CohOptNR == 1} {set config "true"}
    if {$CohOptMM == 1} {set config "true"}
    if {$CohOptDF == 1} {set config "true"}
    if {$config == "false" } {
        $widget(Checkbutton307_1) configure -state disable
        set CohBMP "0"
        }
    set NptsDF ""
    $widget(TitleFrame307_DF) configure -state disable
    $widget(Entry307_DF) configure -state disable; $widget(Entry307_DF) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_DF) configure -state disable 
    $widget(Entry307_DF) configure -state disable; $widget(Entry307_DF) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_DF) configure -state disable 
    }} \
        -text {L. Diff} -variable CohOptDF 
    vTcl:DefineAlias "$site_7_0.cpd80" "Checkbutton37" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd92 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd95 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra66 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame16" vTcl:WidgetProc "Toplevel307" 1
    set site_3_0 $top.fra66
    TitleFrame $site_3_0.cpd67 \
        -text {Numerical Radius} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame307_NR" vTcl:WidgetProc "Toplevel307" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame17" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.cpd81 \
        -padx 1 -text Theta1 
    vTcl:DefineAlias "$site_6_0.cpd81" "Label307_NR1" vTcl:WidgetProc "Toplevel307" 1
    entry $site_6_0.cpd82 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NRTheta1 -width 5 
    vTcl:DefineAlias "$site_6_0.cpd82" "Entry307_NR1" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame18" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.cpd81 \
        -padx 1 -text Theta3 
    vTcl:DefineAlias "$site_6_0.cpd81" "Label307_NR2" vTcl:WidgetProc "Toplevel307" 1
    entry $site_6_0.cpd82 \
        -background #ffffffffffff -disabledforeground #ff0000 \
        -foreground #ff0000 -justify center -textvariable NRTheta3 -width 5 
    vTcl:DefineAlias "$site_6_0.cpd82" "Entry307_NR2" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd68 \
        -text {Loci MinMax} 
    vTcl:DefineAlias "$site_3_0.cpd68" "TitleFrame307_MM" vTcl:WidgetProc "Toplevel307" 1
    bind $site_3_0.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    frame $site_5_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame19" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.cpd81 \
        -padx 1 -text {Num Points} 
    vTcl:DefineAlias "$site_6_0.cpd81" "Label307_MM" vTcl:WidgetProc "Toplevel307" 1
    entry $site_6_0.cpd82 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NptsMM -width 5 
    vTcl:DefineAlias "$site_6_0.cpd82" "Entry307_MM" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd69 \
        -text {Loci Diff} 
    vTcl:DefineAlias "$site_3_0.cpd69" "TitleFrame307_DF" vTcl:WidgetProc "Toplevel307" 1
    bind $site_3_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    frame $site_5_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame22" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.cpd81 \
        -padx 1 -text {Num Points} 
    vTcl:DefineAlias "$site_6_0.cpd81" "Label307_DF" vTcl:WidgetProc "Toplevel307" 1
    entry $site_6_0.cpd82 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NptsDF -width 5 
    vTcl:DefineAlias "$site_6_0.cpd82" "Entry307_DF" vTcl:WidgetProc "Toplevel307" 1
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra30 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra30" "Frame149" vTcl:WidgetProc "Toplevel307" 1
    set site_3_0 $top.fra30
    frame $site_3_0.fra22 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra22" "Frame248" vTcl:WidgetProc "Toplevel307" 1
    set site_4_0 $site_3_0.fra22
    frame $site_4_0.fra25 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra25" "Frame249" vTcl:WidgetProc "Toplevel307" 1
    set site_5_0 $site_4_0.fra25
    TitleFrame $site_5_0.tit71 \
        -text {Box Car Window} 
    vTcl:DefineAlias "$site_5_0.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel307" 1
    bind $site_5_0.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit71 getframe]
    frame $site_7_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame5" vTcl:WidgetProc "Toplevel307" 1
    set site_8_0 $site_7_0.cpd73
    label $site_8_0.cpd81 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_8_0.cpd81" "Label304" vTcl:WidgetProc "Toplevel307" 1
    entry $site_8_0.cpd82 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinRow -width 5 
    vTcl:DefineAlias "$site_8_0.cpd82" "Entry304" vTcl:WidgetProc "Toplevel307" 1
    pack $site_8_0.cpd81 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_7_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd74" "Frame6" vTcl:WidgetProc "Toplevel307" 1
    set site_8_0 $site_7_0.cpd74
    label $site_8_0.cpd81 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_8_0.cpd81" "Label305" vTcl:WidgetProc "Toplevel307" 1
    entry $site_8_0.cpd82 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinCol -width 5 
    vTcl:DefineAlias "$site_8_0.cpd82" "Entry305" vTcl:WidgetProc "Toplevel307" 1
    pack $site_8_0.cpd81 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.fra72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra72" "Frame10" vTcl:WidgetProc "Toplevel307" 1
    set site_6_0 $site_5_0.fra72
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame11" vTcl:WidgetProc "Toplevel307" 1
    set site_7_0 $site_6_0.cpd75
    checkbutton $site_7_0.cpd74 \
        -command {} -text BMP -variable CohBMP 
    vTcl:DefineAlias "$site_7_0.cpd74" "Checkbutton307_1" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd76 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd76" "Frame12" vTcl:WidgetProc "Toplevel307" 1
    set site_7_0 $site_6_0.cpd76
    checkbutton $site_7_0.cpd73 \
        \
        -command {global CohAvg FiltRow FiltCol

if {$CohAvg == "1" } {
    set FiltRow "7"; set FiltCol "7"
    $widget(TitleFrame307_4) configure -state normal; $widget(TitleFrame307_4) configure -text "Averaging Window"
    $widget(Entry307_4) configure -state normal; $widget(Entry307_4) configure -disabledbackground #FFFFFF; $widget(Label307_4) configure -state normal 
    $widget(Entry307_5) configure -state normal; $widget(Entry307_5) configure -disabledbackground #FFFFFF; $widget(Label307_5) configure -state normal 
    } else {
    set FiltRow ""; set FiltCol ""
    $widget(TitleFrame307_4) configure -state disable; $widget(TitleFrame307_4) configure -text ""
    $widget(Entry307_4) configure -state disable; $widget(Entry307_4) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_4) configure -state disable 
    $widget(Entry307_5) configure -state disable; $widget(Entry307_5) configure -disabledbackground $PSPBackgroundColor; $widget(Label307_5) configure -state disable 
    }} \
        -text Averaging -variable CohAvg 
    vTcl:DefineAlias "$site_7_0.cpd73" "Checkbutton6" vTcl:WidgetProc "Toplevel307" 1
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_5_0.cpd75 \
        -text {Averaging Window} 
    vTcl:DefineAlias "$site_5_0.cpd75" "TitleFrame307_4" vTcl:WidgetProc "Toplevel307" 1
    bind $site_5_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    frame $site_7_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame7" vTcl:WidgetProc "Toplevel307" 1
    set site_8_0 $site_7_0.cpd73
    label $site_8_0.cpd81 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_8_0.cpd81" "Label307_4" vTcl:WidgetProc "Toplevel307" 1
    entry $site_8_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable FiltRow -width 5 
    vTcl:DefineAlias "$site_8_0.cpd82" "Entry307_4" vTcl:WidgetProc "Toplevel307" 1
    pack $site_8_0.cpd81 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_7_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd74" "Frame8" vTcl:WidgetProc "Toplevel307" 1
    set site_8_0 $site_7_0.cpd74
    label $site_8_0.cpd81 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_8_0.cpd81" "Label307_5" vTcl:WidgetProc "Toplevel307" 1
    entry $site_8_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable FiltCol -width 5 
    vTcl:DefineAlias "$site_8_0.cpd82" "Entry307_5" vTcl:WidgetProc "Toplevel307" 1
    pack $site_8_0.cpd81 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd82 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.tit71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra72 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra25 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.fra22 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra36 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame20" vTcl:WidgetProc "Toplevel307" 1
    set site_3_0 $top.fra36
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 DirName
global CmplxCohMasterDirInput CmplxCohSlaveDirInput CmplxCohDirOutput CmplxCohOutputDir CmplxCohOutputSubDir
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global CmplxCohFonc CohLinHH CohLinHV CohLinVV CohCirLL CohCirLR CohCirRR
global CohPauliHHpVV CohPauliHHmVV CohPauliHVpVH
global CohOptSVD CohOptPD CohOptNR CohOptMM CohOptDF CohBMP BMPCmplxCohConfig
global NwinRow NwinCol FiltRow FiltCol CohAvg
global NRTheta1 NRTheta3 NptsMM NptsDF  PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType 

if {$OpenDirFile == 0} {

set config "false"
if {$CohLinHH =="1"} {set config "true"}
if {$CohLinHV =="1"} {set config "true"}
if {$CohLinVV =="1"} {set config "true"}
if {$CohCirLL =="1"} {set config "true"}
if {$CohCirLR =="1"} {set config "true"}
if {$CohCirRR =="1"} {set config "true"}
if {$CohPauliHHpVV =="1"} {set config "true"}
if {$CohPauliHHmVV =="1"} {set config "true"}
if {$CohPauliHVpVH =="1"} {set config "true"}
if {$CohOptSVD =="1"} {set config "true"}
if {$CohOptPD =="1"} {set config "true"}
if {$CohOptNR =="1"} {set config "true"}
if {$CohOptMM =="1"} {set config "true"}
if {$CohOptDF =="1"} {set config "true"}
if {$config == "false"} {
    set VarError ""
    set ErrorMessage "SELECT THE COHERENCE TYPE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

set config "true"
if {$NwinRow ==""} {set config "false"}
if {$NwinRow =="?"} {set config "false"}
if {$NwinRow =="0"} {set config "false"}
if {$NwinRow ==""} {set config "false"}
if {$NwinCol =="?"} {set config "false"}
if {$NwinCol =="0"} {set config "false"}
if {$NwinCol ==""} {set config "false"}
if {$CohAvg == "1"} {
    if {$FiltRow ==""} {set config "false"}
    if {$FiltRow =="?"} {set config "false"}
    if {$FiltRow =="0"} {set config "false"}
    if {$FiltRow ==""} {set config "false"}
    if {$FiltCol =="?"} {set config "false"}
    if {$FiltCol =="0"} {set config "false"}
    if {$FiltCol ==""} {set config "false"}
    }
if {$config == "false"} {
    set VarError ""
    set ErrorMessage "ENTER THE ANALYSIS WINDOW SIZE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

set CmplxCohDirOutput $CmplxCohOutputDir
if {$CmplxCohOutputSubDir != ""} {append CmplxCohDirOutput "/$CmplxCohOutputSubDir"}

    #####################################################################
    #Create Directory
    set CmplxCohDirOutput [PSPCreateDirectoryMask $CmplxCohDirOutput $CmplxCohOutputDir $CmplxCohMasterDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    if {$CohAvg == "1"} {
        set RowFilt $FiltRow; set ColFilt $FiltRow
        } else {
        set RowFilt 1; set ColFilt 1
        } 

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Box Car Window - Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinRow; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Box Car Window - Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinCol; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    set TestVarName(6) "Averaging Window - Row"; set TestVarType(6) "int"; set TestVarValue(6) $RowFilt; set TestVarMin(6) "1"; set TestVarMax(6) "1000"
    set TestVarName(7) "Averaging Window - Col"; set TestVarType(7) "int"; set TestVarValue(7) $ColFilt; set TestVarMin(7) "1"; set TestVarMax(7) "1000"
    set TestVarName(8) "Averaging Flag"; set TestVarType(8) "int"; set TestVarValue(8) $CohAvg; set TestVarMin(8) "0"; set TestVarMax(8) "1"
    TestVar 9
    if {$TestVarError == "ok"} {

    set configBMP "true"

    set MaskCmd ""
    if {$CmplxCohFonc == "S2"} {
        set ConfigFile "$CmplxCohDirOutput/config.txt"
        WriteConfig
        set MaskFileOut "$CmplxCohDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFileOut] {
            set MaskCmd "-mask \x22$MaskFileOut\x22"
            } else {
            set MaskFile1 "$CmplxCohMasterDirInput/mask_valid_pixels.bin"
            set MaskFile2 "$CmplxCohSlaveDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile1] {
                if [file exists $MaskFile2] {
                    set MaskFileOut "$CmplxCohDirOutput/mask_valid_pixels.bin"
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
    if {$CmplxCohFonc == "T6"} {
        set MaskFile "$CmplxCohMasterDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-maskm \x22$MaskFile\x22"}
        }


    if {$CohLinHH == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Linear Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_HH.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_HH.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_HH.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_HH.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_HH"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_HH"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }
    if {$CohLinHV == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Linear Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_HV.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_HV.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_HV.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_HV.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_HV"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_HV"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }
    if {$CohLinVV == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Linear Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type VV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type VV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type VV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type VV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_VV.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_VV.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_VV.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_VV.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_VV"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_VV"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }

    if {$CohCirLL == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Circular Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type LL -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type LL -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type LL -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type LL -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_LL.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_LL.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_LL.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_LL.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_LL"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_LL"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }
    if {$CohCirLR == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Circular Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type LR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type LR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type LR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type LR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_LR.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_LR.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_LR.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_LR.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_LR"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_LR"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }
    if {$CohCirRR == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Circular Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type RR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type RR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type RR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type RR -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_RR.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_RR.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_RR.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_RR.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_RR"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_RR"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }

    if {$CohPauliHHpVV == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Pauli Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HHpVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HHpVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HHpVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HHpVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_HHpVV.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_HHpVV.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_HHpVV.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_HHpVV.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_HHpVV"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_HHpVV"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }
    if {$CohPauliHHmVV == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Pauli Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HHmVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HHmVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HHmVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HHmVV -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_HHmVV.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_HHmVV.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_HHmVV.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_HHmVV.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_HHmVV"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_HHmVV"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }
    if {$CohPauliHVpVH == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Pauli Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HVpVH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -type HVpVH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HVpVH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -type HVpVH -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_HVpVH.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_HVpVH.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_HVpVH.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_HVpVH.bin" $FinalNlig $FinalNcol 6
            }
        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_HVpVH"
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_HVpVH"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }


    if {$CohOptSVD == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Optimal Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_opt_estimation.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_opt_estimation.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_opt_estimation.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_Opt1.bin" $FinalNlig $FinalNcol 6
        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_Opt2.bin" $FinalNlig $FinalNcol 6
        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_Opt3.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_Opt1.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_Opt1.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_Opt2.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_Opt2.bin"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_Opt3.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_Opt3.bin"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_Opt1.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_Opt2.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_Opt3.bin" $FinalNlig $FinalNcol 6
            }

        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_Opt1"  
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_Opt2"  
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_Opt3"  
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_Opt1"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_Opt2"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_Opt3"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }


    if {$CohOptPD == "1"} {
        set Fonction "Creation of the Binary Data Files:"
        set Fonction2 "Complex Optimal Coherences"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_opt_PD.exe" "k"
        if {$CmplxCohFonc == "S2"} {
            TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_opt_PD.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$CmplxCohFonc == "T6"} {
            TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_dual/complex_coherence_opt_PD.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_PDHigh.bin" $FinalNlig $FinalNcol 6
        EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_PDLow.bin" $FinalNlig $FinalNcol 6
        if {$CohAvg == "1"} {
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_PDHigh.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_PDHigh.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_PDLow.bin"
            set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_PDLow.bin"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_PDHigh.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_PDLow.bin" $FinalNlig $FinalNcol 6
            }

        if {$CohBMP =="1"} {
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_PDHigh"  
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_PDLow"  
            if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
            if {$CohAvg == "1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_PDHigh"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_PDLow"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                }
            }
        }


    if {$CohOptNR == "1"} {
        if {$NRTheta1 < 0} { set NRTheta1 [expr $NRTheta1 + 180] }
        if {$NRTheta3 < 0} { set NRTheta3 [expr $NRTheta3 + 180] }
        set TestVarName(0) "Theta 1"; set TestVarType(0) "float"; set TestVarValue(0) $NRTheta1; set TestVarMin(0) "0"; set TestVarMax(0) "360"
        set TestVarName(1) "Theta 3"; set TestVarType(1) "float"; set TestVarValue(1) $NRTheta3; set TestVarMin(1) "0"; set TestVarMax(1) "360"
        TestVar 2
        if {$TestVarError == "ok"} {
            set Fonction "Creation of the Binary Data Files:"
            set Fonction2 "Complex Optimal Coherences"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_opt_NR.exe" "k"
            if {$CmplxCohFonc == "S2"} {
                TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -teth $NRTheta1 -tetl $NRTheta3 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_dual/complex_coherence_opt_NR.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -teth $NRTheta1 -tetl $NRTheta3 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            if {$CmplxCohFonc == "T6"} {
                TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -teth $NRTheta1 -tetl $NRTheta3 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_dual/complex_coherence_opt_NR.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -teth $NRTheta1 -tetl $NRTheta3 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_Opt_NR1.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_Opt_NR2.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_Opt_NR3.bin" $FinalNlig $FinalNcol 6
            if {$CohAvg == "1"} {
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_Opt_NR1.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR1.bin"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_Opt_NR2.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR2.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_Opt_NR3.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR3.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR1.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR2.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR3.bin" $FinalNlig $FinalNcol 6
                }
    
            if {$CohBMP =="1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_Opt_NR1"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_Opt_NR2"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_Opt_NR3"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                if {$CohAvg == "1"} {
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR1"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR2"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_Opt_NR3"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    }
                }
            }
        }


    if {$CohOptMM == "1"} {
        set TestVarName(0) "Num Points"; set TestVarType(0) "int"; set TestVarValue(0) $NptsMM; set TestVarMin(0) "0"; set TestVarMax(0) "1000"
        TestVar 1
        if {$TestVarError == "ok"} {
            set Fonction "Creation of the Binary Data Files:"
            set Fonction2 "Complex Optimal Coherences"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_loci_minmax.exe" "k"
            if {$CmplxCohFonc == "S2"} {
                TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsMM -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_dual/complex_coherence_loci_minmax.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsMM -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            if {$CmplxCohFonc == "T6"} {
                TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsMM -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_dual/complex_coherence_loci_minmax.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsMM -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_MaxMag.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_MinMag.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_MaxPha.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_MinPha.bin" $FinalNlig $FinalNcol 6
            if {$CohAvg == "1"} {
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_MaxMag.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_MaxMag.bin"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_MinMag.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_MinMag.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_MaxPha.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_MaxPha.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_MinPha.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_MinPha.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_MaxMag.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_MinMag.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_MaxPha.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_MinPha.bin" $FinalNlig $FinalNcol 6
                }
    
            if {$CohBMP =="1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_MaxMag"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_MinMag"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_MaxPha"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_MinPha"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                if {$CohAvg == "1"} {
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_MaxMag"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_MinMag"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_MaxPha"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_MinPha"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    }
                }
            }
        }


    if {$CohOptDF == "1"} {
        set TestVarName(0) "Num Points"; set TestVarType(0) "int"; set TestVarValue(0) $NptsDF; set TestVarMin(0) "0"; set TestVarMax(0) "1000"
        TestVar 1
        if {$TestVarError == "ok"} {
            set Fonction "Creation of the Binary Data Files:"
            set Fonction2 "Complex Optimal Coherences"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_dual/complex_coherence_loci_difference.exe" "k"
            if {$CmplxCohFonc == "S2"} {
                TextEditorRunTrace "Arguments: -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsDF -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_dual/complex_coherence_loci_difference.exe -idm \x22$CmplxCohMasterDirInput\x22 -ids \x22$CmplxCohSlaveDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf S2T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsDF -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            if {$CmplxCohFonc == "T6"} {
                TextEditorRunTrace "Arguments: -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsDF -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_dual/complex_coherence_loci_difference.exe -id \x22$CmplxCohMasterDirInput\x22 -od \x22$CmplxCohDirOutput\x22 -iodf T6 -nwr $NwinRow -nwc $NwinCol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p $NptsDF -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_maxdiff_PhaLow.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_maxdiff_PhaHigh.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_maxdiff_MagLow.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_maxdiff_MagHigh.bin" $FinalNlig $FinalNcol 6
            if {$CohAvg == "1"} {
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_maxdiff_PhaLow.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_PhaLow.bin"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_maxdiff_PhaHigh.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_PhaHigh.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_maxdiff_MagLow.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_MagLow.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set CmplxFileIn "$CmplxCohDirOutput/cmplx_coh_maxdiff_MagHigh.bin"
                set CmplxFileOut "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_MagHigh.bin"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function Soft/calculator/file_boxcar.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/calculator/file_boxcar.exe -if \x22$CmplxFileIn\x22 -it cmplx -of \x22$CmplxFileOut\x22 -nwr $RowFilt -nwc $ColFilt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_PhaLow.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_PhaHigh.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_MagLow.bin" $FinalNlig $FinalNcol 6
                EnviWriteConfig "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_MagHigh.bin" $FinalNlig $FinalNcol 6
                }
    
            if {$CohBMP =="1"} {
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_maxdiff_PhaLow"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_maxdiff_PhaHigh"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_maxdiff_MagLow"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_maxdiff_MagHigh"  
                if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                if {$CohAvg == "1"} {
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_PhaLow"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_PhaHigh"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_MagLow"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    BMPCmplxCoh $FinalNlig $FinalNcol "$CmplxCohDirOutput/cmplx_coh_avg_maxdiff_MagHigh"  
                    if { $BMPCmplxCohConfig == "false" } { set configBMP "false" }
                    }
                }
            }
        }

    if { $configBMP == "true" } { $widget(Button307_1) configure -state normal }
    }
    #TestVar
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel307); TextEditorRunTrace "Close Window Complex Coherence Estimation" "b"}
    }
}
}
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel307" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but73 \
        -background #ffff00 \
        -command {global DataDir FileName
global CmplxCohDirOutput CmplxCohOutputDir CmplxCohOutputSubDir
global HistoDirInput HistoDirOutput HistoOutputDir HistoOutputSubDir
global HistoFileInput HistoFileOpen
global TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt
global BMPDirInput BMPViewFileInput
global LineXLensInit LineYLensInit line_color
global ConfigFile VarError ErrorMessage Fonction
global VarWarning WarningMesage WarningMessage2
global HistoExecFid HistoOutputFile
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
global Load_ViewBMPLens PSPTopLevel

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
if [file exists "$CmplxCohDirOutput/config.txt"] {
    set HistoDirInput $CmplxCohDirOutput
    set HistoDirOutput $CmplxCohDirOutput
    set HistoOutputDir $CmplxCohOutputDir
    set HistoOutputSubDir $CmplxCohOutputSubDir
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
                ClosePSPViewer;
                Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
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
                #set xwindow [winfo x $widget(Toplevel307)]; set ywindow [winfo y $widget(Toplevel307)]
                #set geometrie "500x300+"; append geometrie $xwindow; append geometrie "+"; append geometrie [expr $ywindow + 350]
                #wm geometry $widget(Toplevel260) $geometrie; update
                WidgetShowFromWidget $widget(Toplevel307) $widget(Toplevel260); TextEditorRunTrace "Open Window Histograms" "b"
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
    vTcl:DefineAlias "$site_3_0.but73" "Button307_1" vTcl:WidgetProc "Toplevel307" 1
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ComplexCoherenceEstimation.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel307" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global HistoExecFid GnuplotPipeFid GnuplotPipeHisto
global Load_SaveHisto Load_Histograms

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
Window hide $widget(Toplevel307); TextEditorRunTrace "Close Window Complex Coherence Estimation" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel307" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra29 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit73 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra30 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra36 \
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
Window show .top307

main $argc $argv
